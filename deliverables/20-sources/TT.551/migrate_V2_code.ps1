# ============================================================
# migrate_V2_code.ps1
# 공통코드 이관: test → dev  (psql \copy 방식 — pg_dump 버전 불일치 우회)
# 대상: sm_comm_h, sm_comm_d
# 실행: .\migrate_V2_code.ps1
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SCRIPT_NAME = "V2__code"
$TSV_DIR     = $env:TEMP   # 한글/공백 없는 경로
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)
$TABLES      = @("sm_comm_h","sm_comm_d")

# 임시 SQL 파일을 BOM 없이 생성하고 psql 실행 후 삭제
function Run-Sql($connHost, $connPort, $connUser, $connPass, $connDb, $sql) {
    $tmpSql = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpSql, $sql, $utf8NoBom)
    $env:PGPASSWORD = $connPass
    & $PSQL -h $connHost -p $connPort -U $connUser -d $connDb -f $tmpSql
    $ec = $LASTEXITCODE
    Remove-Item $tmpSql -Force
    return $ec
}

# ============================================================
# STEP 1: FROM DB 에서 테이블별 COPY TO FILE
# ============================================================
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

# ============================================================
# STEP 2: TO DB 적용 (자식 테이블 먼저 DELETE)
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 2: dev DB 적용 중..." -ForegroundColor Cyan
Write-Host "  TO  : $TO_HOST`:$TO_PORT/$TO_DB"

$tmpDel = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpDel, "DELETE FROM sm_comm_d; DELETE FROM sm_comm_h;", $utf8NoBom)
$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpDel
Remove-Item $tmpDel -Force
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] 기존 데이터 삭제 실패" -ForegroundColor Red; exit 1 }

foreach ($tbl in $TABLES) {
    $tsvPath = "$TSV_DIR\${tbl}.tsv".Replace('\','/')
    $tmpSql  = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpSql, "\copy `"$tbl`" FROM '$tsvPath'", $utf8NoBom)
    $env:PGPASSWORD = $TO_PASS
    & $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpSql
    Remove-Item $tmpSql -Force
    if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] $tbl 적용 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red; exit 1 }
    Write-Host "  → $tbl 완료" -ForegroundColor Green
}

# ============================================================
# STEP 3: 건수 검증
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 3: 건수 검증" -ForegroundColor Cyan

$verifySql = "SELECT 'sm_comm_h' AS tbl, COUNT(*) AS cnt FROM sm_comm_h UNION ALL SELECT 'sm_comm_d', COUNT(*) FROM sm_comm_d;"
$tmpV = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpV, $verifySql, $utf8NoBom)

Write-Host "  [test DB]"
$env:PGPASSWORD = $FROM_PASS
& $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -f $tmpV

Write-Host "  [dev DB]"
$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpV

Remove-Item $tmpV -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료. test/dev 건수가 일치하면 이관 성공." -ForegroundColor Green
