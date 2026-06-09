# ============================================================
# migrate_V7_config.ps1
# 시스템파라미터 이관: test → dev  (psql \copy 방식)
# 대상: sm_biz_config, sm_opt_config, sm_dlv_config,
#       sm_ob_proc_opt_config, sm_prod_opt_config
# 실행: .\migrate_V7_config.ps1
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SCRIPT_NAME = "V7__config"
$TSV_DIR     = $env:TEMP
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)
$TABLES      = @("sm_biz_config","sm_opt_config","sm_dlv_config","sm_ob_proc_opt_config","sm_prod_opt_config")

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
[System.IO.File]::WriteAllText($tmpDel, "DELETE FROM sm_prod_opt_config; DELETE FROM sm_ob_proc_opt_config; DELETE FROM sm_dlv_config; DELETE FROM sm_opt_config; DELETE FROM sm_biz_config;", $utf8NoBom)
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
$verifySql = "SELECT 'sm_biz_config' AS tbl, COUNT(*) AS cnt FROM sm_biz_config UNION ALL SELECT 'sm_opt_config', COUNT(*) FROM sm_opt_config UNION ALL SELECT 'sm_dlv_config', COUNT(*) FROM sm_dlv_config UNION ALL SELECT 'sm_ob_proc_opt_config', COUNT(*) FROM sm_ob_proc_opt_config UNION ALL SELECT 'sm_prod_opt_config', COUNT(*) FROM sm_prod_opt_config;"
$tmpV = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpV, $verifySql, $utf8NoBom)
Write-Host "  [test DB]"; $env:PGPASSWORD = $FROM_PASS; & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -f $tmpV
Write-Host "  [dev DB]";  $env:PGPASSWORD = $TO_PASS;   & $PSQL -h $TO_HOST   -p $TO_PORT   -U $TO_USER   -d $TO_DB   -f $tmpV
Remove-Item $tmpV -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료. test/dev 건수가 일치하면 이관 성공." -ForegroundColor Green
