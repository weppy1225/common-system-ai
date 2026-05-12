# TT_550_WIN 3단계 (POWERSHELL 모드) - psql 로 @migrate: 마커 + FK 의존성 수집
#
# 사용법:
#   .\01_collect_markers.ps1 -DbTargetFile <db_target.json> -OutFile <markers.json> -Psql <psql.exe 경로>
#
# 출력: markers.json (스키마는 PYTHON 모드와 동일)

param(
    [Parameter(Mandatory=$true)][string]$DbTargetFile,
    [Parameter(Mandatory=$true)][string]$OutFile,
    [Parameter(Mandatory=$true)][string]$Psql
)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
try { chcp 65001 | Out-Null } catch {}

$db = Get-Content $DbTargetFile -Raw -Encoding UTF8 | ConvertFrom-Json
$schema = if ($db.schema) { $db.schema } else { "public" }
$env:PGPASSWORD = $db.password
$env:PGCLIENTENCODING = "UTF8"

function Invoke-Psql {
    param([string]$Sql)
    $tmp = [System.IO.Path]::GetTempFileName()
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($tmp, $Sql, $utf8)
    $out = & $Psql -h $db.host -p $db.port -U $db.user -d $db.database -t -A -F "`t" -f $tmp 2>&1
    $ec = $LASTEXITCODE
    Remove-Item $tmp -Force
    if ($ec -ne 0) {
        throw "psql 실패 (exit=$ec): $($out | Out-String)"
    }
    return $out
}

# 1) 서버 버전
$ver = (Invoke-Psql "SHOW server_version;" | Select-Object -First 1).Trim()

# 2) 마커 수집
$sqlMarkers = @"
SELECT
    c.relname,
    COALESCE(substring(obj_description(c.oid, 'pg_class') FROM '@migrate:(\S+)'), ''),
    COALESCE(trim(substring(obj_description(c.oid, 'pg_class') FROM '@migrate:\S+\s+(.*)$')), ''),
    COALESCE(c.reltuples::bigint::text, '0')
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = '$schema'
  AND c.relkind = 'r'
  AND obj_description(c.oid, 'pg_class') LIKE '@migrate:%'
ORDER BY 2, 1;
"@

$rawMarkers = Invoke-Psql $sqlMarkers
$groups = @{}
foreach ($line in $rawMarkers) {
    if (-not $line -or $line.Trim() -eq "") { continue }
    $parts = $line -split "`t"
    if ($parts.Count -lt 4) { continue }
    $tname = $parts[0]
    $gkey = $parts[1]
    $tdesc = $parts[2]
    $rows = [int64]$parts[3]
    if (-not $gkey) { continue }
    if (-not $groups.ContainsKey($gkey)) {
        $groups[$gkey] = @{
            group_key = $gkey
            group_desc = ""
            tables = New-Object System.Collections.Generic.List[hashtable]
            fk_edges = New-Object System.Collections.Generic.List[hashtable]
            insert_order = $null
            delete_order = $null
        }
    }
    $null = $groups[$gkey].tables.Add(@{ name = $tname; desc = $tdesc; approx_rows = $rows })
}

# 그룹 desc 추정: 첫 테이블 desc의 첫 토큰
foreach ($gk in $groups.Keys) {
    $firstDesc = if ($groups[$gk].tables.Count -gt 0) { $groups[$gk].tables[0].desc } else { "" }
    if ($firstDesc) {
        $tokens = $firstDesc -split '\s+'
        $groups[$gk].group_desc = $tokens[0]
    } else {
        $groups[$gk].group_desc = $gk
    }
}

# 3) 각 그룹별 FK 의존성
function Sort-Topo {
    param([string[]]$Tables, [hashtable[]]$Edges)
    $inDeg = @{}
    foreach ($t in $Tables) { $inDeg[$t] = 0 }
    $graph = @{}
    foreach ($t in $Tables) { $graph[$t] = New-Object System.Collections.Generic.List[string] }
    foreach ($e in $Edges) {
        if ($e.child -eq $e.parent) { continue }
        if (-not $inDeg.ContainsKey($e.child) -or -not $inDeg.ContainsKey($e.parent)) { continue }
        $null = $graph[$e.parent].Add($e.child)
        $inDeg[$e.child] += 1
    }
    $queue = New-Object System.Collections.Generic.Queue[string]
    foreach ($t in $Tables) { if ($inDeg[$t] -eq 0) { $queue.Enqueue($t) } }
    $order = New-Object System.Collections.Generic.List[string]
    while ($queue.Count -gt 0) {
        $t = $queue.Dequeue()
        $null = $order.Add($t)
        foreach ($nxt in $graph[$t]) {
            $inDeg[$nxt] -= 1
            if ($inDeg[$nxt] -eq 0) { $queue.Enqueue($nxt) }
        }
    }
    if ($order.Count -ne $Tables.Count) { return $null }
    return $order.ToArray()
}

foreach ($gk in @($groups.Keys)) {
    $tableNames = @($groups[$gk].tables | ForEach-Object { $_.name })
    if ($tableNames.Count -le 1) {
        $groups[$gk].insert_order = $tableNames
        $groups[$gk].delete_order = @($tableNames | Sort-Object -Descending:$true | ForEach-Object { $_ })
        # 단일 테이블이면 reverse도 자기 자신
        $groups[$gk].delete_order = $tableNames
        continue
    }

    $tblList = ($tableNames | ForEach-Object { "'$_'" }) -join ","
    $sqlFk = @"
SELECT
    conrelid::regclass::text,
    confrelid::regclass::text
FROM pg_constraint
WHERE contype = 'f'
  AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = '$schema')
  AND conrelid::regclass::text  = ANY(ARRAY[$tblList]::text[])
  AND confrelid::regclass::text = ANY(ARRAY[$tblList]::text[]);
"@
    $rawFk = Invoke-Psql $sqlFk
    $edges = New-Object System.Collections.Generic.List[hashtable]
    foreach ($line in $rawFk) {
        if (-not $line -or $line.Trim() -eq "") { continue }
        $parts = $line -split "`t"
        if ($parts.Count -lt 2) { continue }
        $child = $parts[0].Split('.')[-1].Trim('"')
        $parent = $parts[1].Split('.')[-1].Trim('"')
        $null = $edges.Add(@{ child = $child; parent = $parent })
    }
    $groups[$gk].fk_edges = $edges.ToArray()

    $order = Sort-Topo -Tables $tableNames -Edges $edges.ToArray()
    if ($null -eq $order) {
        $groups[$gk].insert_order = $null
        $groups[$gk].delete_order = $null
        Write-Host "[TT_550_WIN] ⚠ $gk : FK 순환 의존성 감지" -ForegroundColor Yellow
    } else {
        $groups[$gk].insert_order = $order
        $reversed = New-Object System.Collections.Generic.List[string]
        for ($i = $order.Count - 1; $i -ge 0; $i--) { $null = $reversed.Add($order[$i]) }
        $groups[$gk].delete_order = $reversed.ToArray()
    }
}

# 4) 마커 없는 sm_/mdm_ 테이블
$sqlUnmarked = @"
SELECT c.relname
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = '$schema'
  AND c.relkind = 'r'
  AND (c.relname LIKE 'sm\_%' ESCAPE '\' OR c.relname LIKE 'mdm\_%' ESCAPE '\')
  AND (obj_description(c.oid, 'pg_class') IS NULL
       OR obj_description(c.oid, 'pg_class') NOT LIKE '@migrate:%')
ORDER BY c.relname;
"@
$unmarked = @(Invoke-Psql $sqlUnmarked | Where-Object { $_ -and $_.Trim() -ne "" } | ForEach-Object { $_.Trim() })

# 5) JSON 저장
$result = [pscustomobject]@{
    schema = $schema
    server_version = $ver
    groups = @($groups.Values | Sort-Object { $_.group_key } | ForEach-Object {
        [pscustomobject]@{
            group_key = $_.group_key
            group_desc = $_.group_desc
            tables = @($_.tables | ForEach-Object { [pscustomobject]$_ })
            fk_edges = @($_.fk_edges | ForEach-Object { [pscustomobject]$_ })
            insert_order = $_.insert_order
            delete_order = $_.delete_order
        }
    })
    warnings = [pscustomobject]@{
        unmarked_master_tables = $unmarked
    }
}

$outDir = Split-Path $OutFile -Parent
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($result | ConvertTo-Json -Depth 10), $utf8)

$totalTables = @($groups.Values | ForEach-Object { $_.tables.Count }) | Measure-Object -Sum
Write-Host "[TT_550_WIN] 마커 스캔 완료: $($groups.Count) 그룹 / $($totalTables.Sum) 테이블 → $OutFile" -ForegroundColor Green
foreach ($gk in ($groups.Keys | Sort-Object)) {
    $rowsApprox = ($groups[$gk].tables | Measure-Object -Property approx_rows -Sum).Sum
    Write-Host ("  [{0}] {1}  ({2} tables, ~{3} rows)" -f $gk, $groups[$gk].group_desc, $groups[$gk].tables.Count, $rowsApprox)
}
if ($unmarked.Count -gt 0) {
    Write-Host "[TT_550_WIN] ⚠ 마커 없는 sm_/mdm_ 테이블 $($unmarked.Count)개: $($unmarked -join ', ')" -ForegroundColor Yellow
}

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
