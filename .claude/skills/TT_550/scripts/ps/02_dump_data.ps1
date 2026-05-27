# TT_550 5단계 (POWERSHELL 모드) - pg_dump --inserts 로 INSERT SQL 생성 후 헤더/BEGIN/COMMIT/검증쿼리 wrap
#
# 사용법:
#   .\02_dump_data.ps1 -DbTargetFile <db_target.json> -MarkersFile <markers.json> -SelectedFile <selected_groups.json> -OutputDir <output_dir> -PgDump <pg_dump.exe> -Psql <psql.exe> [-Customer <고객사명>]
#
# 출력: <OutputDir>/{group_key}.sql (선택된 그룹마다)
#       <OutputDir>/tmp/dump_results.json

param(
    [Parameter(Mandatory=$true)][string]$DbTargetFile,
    [Parameter(Mandatory=$true)][string]$MarkersFile,
    [Parameter(Mandatory=$true)][string]$SelectedFile,
    [Parameter(Mandatory=$true)][string]$OutputDir,
    [Parameter(Mandatory=$true)][string]$PgDump,
    [Parameter(Mandatory=$true)][string]$Psql,
    [string]$Customer = ""
)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
try { chcp 65001 | Out-Null } catch {}

$db = Get-Content $DbTargetFile -Raw -Encoding UTF8 | ConvertFrom-Json
$markers = Get-Content $MarkersFile -Raw -Encoding UTF8 | ConvertFrom-Json
$selected = Get-Content $SelectedFile -Raw -Encoding UTF8 | ConvertFrom-Json

$schema = if ($db.schema) { $db.schema } else { "public" }
$env:PGPASSWORD = $db.password
$env:PGCLIENTENCODING = "UTF8"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$selectedKeys = @($selected.groups)
$targetGroups = @($markers.groups | Where-Object { $selectedKeys -contains $_.group_key })

if ($targetGroups.Count -eq 0) {
    Write-Host "ERROR: 선택된 그룹이 없습니다." -ForegroundColor Red
    exit 2
}

$pgDumpVer = (& $PgDump --version 2>$null | Out-String).Trim()
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$pgVer = $markers.server_version
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-RowCount {
    param([string]$Table)
    $sql = "SELECT COUNT(*) FROM `"$schema`".`"$Table`";"
    $tmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmp, $sql, $utf8NoBom)
    $out = & $Psql -h $db.host -p $db.port -U $db.user -d $db.database -t -A -f $tmp 2>&1
    Remove-Item $tmp -Force
    if ($LASTEXITCODE -ne 0) { return -1 }
    return [int64](($out | Where-Object { $_ -match '^\d+$' }) -join '')
}

$dumpResults = New-Object System.Collections.Generic.List[hashtable]

foreach ($g in $targetGroups) {
    $gk = $g.group_key
    $gdesc = $g.group_desc
    $insertOrder = @($g.insert_order)
    $deleteOrder = @($g.delete_order)
    if ($null -eq $g.insert_order -or $insertOrder.Count -eq 0) {
        Write-Host "[TT_550] ⚠ ${gk}: FK 순환 의존성으로 skip" -ForegroundColor Yellow
        continue
    }

    $outFile = Join-Path $OutputDir "$gk.sql"

    # 헤더 + BEGIN + DELETE
    $headerLines = @()
    $headerLines += "-- ============================================================="
    $headerLines += "-- TT_550: $gk ($gdesc)"
    $headerLines += "-- 고객사:     $Customer"
    $headerLines += "-- 생성일시:   $now"
    $headerLines += "-- 실행 모드:  POWERSHELL ($pgDumpVer)"
    $headerLines += "-- 원본 DB:   $($db.host):$($db.port)/$($db.database) (schema=$schema, PG $pgVer)"
    $headerLines += "-- 대상 테이블: $($insertOrder -join ', ')"
    $headerLines += "-- 적용 방법: psql -h <host> -U <user> -d <db> -f $gk.sql"
    $headerLines += "-- ============================================================="
    $headerLines += "SET client_encoding = 'UTF8';"
    $headerLines += "SET standard_conforming_strings = on;"
    $headerLines += "BEGIN;"
    $headerLines += ""
    $headerLines += "-- FK 역순 DELETE"
    foreach ($t in $deleteOrder) {
        $headerLines += "DELETE FROM `"$schema`".`"$t`";"
    }
    $headerLines += ""
    $headerLines += "-- FK 정순 INSERT"

    [System.IO.File]::WriteAllText($outFile, (($headerLines -join "`n") + "`n"), $utf8NoBom)

    # 각 테이블의 row count 먼저 측정
    $rowCounts = @{}
    foreach ($t in $insertOrder) { $rowCounts[$t] = Get-RowCount -Table $t }

    # pg_dump --inserts → 임시 파일로 받은 뒤 SET/-- 주석 필터링하여 본문에 append
    $tableArgs = @()
    foreach ($t in $insertOrder) { $tableArgs += "-t"; $tableArgs += "$schema.$t" }

    $tmpDump = [System.IO.Path]::GetTempFileName()
    & $PgDump -h $db.host -p $db.port -U $db.user -d $db.database `
              --data-only --inserts --column-inserts `
              --no-owner --no-privileges `
              --rows-per-insert=1 `
              @tableArgs 2>$null |
        Out-File -Encoding UTF8 -FilePath $tmpDump

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[TT_550] ⚠ ${gk}: pg_dump 실패 (exit=$LASTEXITCODE)" -ForegroundColor Yellow
        Remove-Item $tmpDump -Force -ErrorAction SilentlyContinue
        continue
    }

    # pg_dump 출력에서 헤더 SET/주석/빈줄 제거하고 append
    $bodyLines = Get-Content $tmpDump -Encoding UTF8 |
                 Where-Object { $_ -notmatch '^(SET\s|--|\s*$|SELECT pg_catalog\.|--$)' }
    Remove-Item $tmpDump -Force

    [System.IO.File]::AppendAllText($outFile, (($bodyLines -join "`n") + "`n"), $utf8NoBom)

    # COMMIT + 검증 쿼리
    $footerLines = @()
    $footerLines += ""
    $footerLines += "COMMIT;"
    $footerLines += ""
    $footerLines += "-- 적용 후 검증"
    $verifyParts = @()
    foreach ($t in $insertOrder) {
        $verifyParts += "SELECT '$t' AS tbl, COUNT(*) FROM `"$schema`".`"$t`""
    }
    $footerLines += ($verifyParts -join "`nUNION ALL`n") + ";"

    [System.IO.File]::AppendAllText($outFile, (($footerLines -join "`n") + "`n"), $utf8NoBom)

    $sizeKb = [math]::Round((Get-Item $outFile).Length / 1024, 1)
    $tablesEntry = @()
    foreach ($t in $insertOrder) {
        $tablesEntry += @{ name = $t; rows = $rowCounts[$t] }
    }

    $null = $dumpResults.Add(@{
        group_key = $gk
        group_desc = $gdesc
        sql_file = "$gk.sql"
        file_size_kb = $sizeKb
        tables = $tablesEntry
        insert_order = $insertOrder
        delete_order = $deleteOrder
    })

    $totalRows = ($rowCounts.Values | Measure-Object -Sum).Sum
    Write-Host "[TT_550] ✓ [$gk] $gdesc : $totalRows rows → $gk.sql ($sizeKb KB)" -ForegroundColor Green
}

# dump_results.json (manifest 작성용)
$tmpDir = Join-Path $OutputDir "tmp"
if (-not (Test-Path $tmpDir)) { New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null }
$resultObj = [pscustomobject]@{
    dumps = @($dumpResults | ForEach-Object {
        [pscustomobject]@{
            group_key = $_.group_key
            group_desc = $_.group_desc
            sql_file = $_.sql_file
            file_size_kb = $_.file_size_kb
            tables = @($_.tables | ForEach-Object { [pscustomobject]$_ })
            insert_order = $_.insert_order
            delete_order = $_.delete_order
        }
    })
    generated_at = $now
    mode = "POWERSHELL"
    tool_versions = [pscustomobject]@{ pg_dump = $pgDumpVer }
}
[System.IO.File]::WriteAllText((Join-Path $tmpDir "dump_results.json"),
    ($resultObj | ConvertTo-Json -Depth 10), $utf8NoBom)

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
