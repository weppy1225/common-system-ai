# TT_550_WIN 6단계 (POWERSHELL 모드) - manifest.json 작성
#
# 사용법:
#   .\03_write_manifest.ps1 -DbTargetFile <db_target.json> -MarkersFile <markers.json> -DumpResultsFile <dump_results.json> -OutputDir <output_dir> -Customer <고객사명> [-ModeFile <mode.json>]
#
# manifest 에는 password/user 미포함.

param(
    [Parameter(Mandatory=$true)][string]$DbTargetFile,
    [Parameter(Mandatory=$true)][string]$MarkersFile,
    [Parameter(Mandatory=$true)][string]$DumpResultsFile,
    [Parameter(Mandatory=$true)][string]$OutputDir,
    [Parameter(Mandatory=$true)][string]$Customer,
    [string]$ModeFile = ""
)

$ErrorActionPreference = "Stop"
$db = Get-Content $DbTargetFile -Raw -Encoding UTF8 | ConvertFrom-Json
$markers = Get-Content $MarkersFile -Raw -Encoding UTF8 | ConvertFrom-Json
$dumpResults = Get-Content $DumpResultsFile -Raw -Encoding UTF8 | ConvertFrom-Json
$modeInfo = $null
if ($ModeFile -and (Test-Path $ModeFile)) {
    $modeInfo = Get-Content $ModeFile -Raw -Encoding UTF8 | ConvertFrom-Json
}

# 마커 측 desc 인덱스
$tableDescs = @{}
foreach ($g in $markers.groups) {
    foreach ($t in $g.tables) {
        $tableDescs["$($g.group_key)|$($t.name)"] = $t.desc
    }
}
$groupDescs = @{}
foreach ($g in $markers.groups) { $groupDescs[$g.group_key] = $g.group_desc }

$groupsOut = New-Object System.Collections.Generic.List[hashtable]
foreach ($d in $dumpResults.dumps) {
    $tablesOut = New-Object System.Collections.Generic.List[hashtable]
    foreach ($t in $d.tables) {
        $key = "$($d.group_key)|$($t.name)"
        $desc = if ($tableDescs.ContainsKey($key)) { $tableDescs[$key] } else { "" }
        $null = $tablesOut.Add(@{
            name = $t.name
            desc = $desc
            rows = $t.rows
        })
    }
    $gdesc = if ($d.group_desc) { $d.group_desc } else { $groupDescs[$d.group_key] }
    $null = $groupsOut.Add(@{
        group_key = $d.group_key
        group_desc = $gdesc
        sql_file = $d.sql_file
        file_size_kb = $d.file_size_kb
        tables = $tablesOut.ToArray()
        insert_order = $d.insert_order
        delete_order = $d.delete_order
    })
}

$now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")

$toolVersions = [pscustomobject]@{
    python = if ($modeInfo) { $modeInfo.python_version } else { $null }
    psycopg2 = if ($modeInfo) { $modeInfo.psycopg2_version } else { $null }
    pg_dump = if ($modeInfo) { $modeInfo.pg_dump_version } else { $dumpResults.tool_versions.pg_dump }
    psql = if ($modeInfo) { $modeInfo.psql_version } else { $null }
}

$manifest = [pscustomobject]@{
    skill = "TT_550_WIN"
    version = "1"
    generated_at = $now
    mode = if ($dumpResults.mode) { $dumpResults.mode } elseif ($modeInfo) { $modeInfo.mode } else { "POWERSHELL" }
    tool_versions = $toolVersions
    customer = $Customer
    source_db = [pscustomobject]@{
        host = $db.host
        port = [int]$db.port
        database = $db.database
        schema = if ($db.schema) { $db.schema } else { "public" }
        pg_version = $markers.server_version
    }
    groups = @($groupsOut | ForEach-Object {
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
    warnings = $markers.warnings
    applied_to_target_db = $null
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}
$outFile = Join-Path $OutputDir "manifest.json"
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outFile, ($manifest | ConvertTo-Json -Depth 10), $utf8)

Write-Host "[TT_550_WIN] manifest.json 작성 완료: $outFile" -ForegroundColor Green
