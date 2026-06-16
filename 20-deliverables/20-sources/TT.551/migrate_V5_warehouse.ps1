# ============================================================
# migrate_V5_warehouse.ps1
# 창고 이관: test → dev  (psql \copy 방식)
# 대상: mdm_wh, mdm_biz_wh
# 실행: .\migrate_V5_warehouse.ps1
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SCRIPT_NAME = "V5__warehouse"
$TSV_DIR     = $env:TEMP
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)
$TABLES      = @("mdm_wh","mdm_biz_wh")

Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 1: test DB 데이터 추출 중..." -ForegroundColor Cyan
Write-Host "  FROM: $FROM_HOST`:$FROM_PORT/$FROM_DB"
foreach ($tbl in $TABLES) {
    $tsvPath = "$TSV_DIR\${tbl}.tsv".Replace('\','/')
    $tmpSql  = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpSql, "\copy `"$tbl`" TO '$tsvPath'", $utf8NoBom)
    $env:PGPASSWORD = $FROM_PASS
    & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -f $tmpSql
    Remove-Item $tmpSql -Force
    if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] $tbl 추출 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red; exit 1 }
    $cnt = (Get-Content "$TSV_DIR\${tbl}.tsv" | Measure-Object -Line).Lines
    Write-Host "  → $tbl : $cnt 건" -ForegroundColor Green
}

Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 2: dev DB 적용 중..." -ForegroundColor Cyan
Write-Host "  TO  : $TO_HOST`:$TO_PORT/$TO_DB"
$tmpDel = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpDel, "DELETE FROM mdm_biz_wh; DELETE FROM mdm_wh;", $utf8NoBom)
$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpDel
Remove-Item $tmpDel -Force
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] 기존 데이터 삭제 실패" -ForegroundColor Red; exit 1 }
foreach ($tbl in $TABLES) {
    $tsvPath = "$TSV_DIR\${tbl}.tsv".Replace('\','/')
    $cols    = Get-TestColCsv $tbl
    $tmpSql  = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpSql, "\copy `"$tbl`" ($cols) FROM '$tsvPath'", $utf8NoBom)
    $env:PGPASSWORD = $TO_PASS
    & $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpSql
    Remove-Item $tmpSql -Force
    if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] $tbl 적용 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red; exit 1 }
    Write-Host "  → $tbl 완료" -ForegroundColor Green
}

Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 3: 건수 검증" -ForegroundColor Cyan
$verifySql = "SELECT 'mdm_wh' AS tbl, COUNT(*) AS cnt FROM mdm_wh UNION ALL SELECT 'mdm_biz_wh', COUNT(*) FROM mdm_biz_wh;"
$tmpV = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpV, $verifySql, $utf8NoBom)
Write-Host "  [test DB]"; $env:PGPASSWORD = $FROM_PASS; & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -f $tmpV
Write-Host "  [dev DB]";  $env:PGPASSWORD = $TO_PASS;   & $PSQL -h $TO_HOST   -p $TO_PORT   -U $TO_USER   -d $TO_DB   -f $tmpV
Remove-Item $tmpV -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료. test/dev 건수가 일치하면 이관 성공." -ForegroundColor Green
