# ============================================================
# migrate_V10_functions.ps1
# 함수/프로시저 설치: DEV_DOC → dev DB
# 대상: fn_*, sp_* (12개 SQL 파일)
# 소스: {BE_PROJECT_ROOT}\DEV_DOC\sql\postgres
# 실행: .\migrate_V10_functions.ps1
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SQL_DIR     = "$BE_PROJECT_ROOT\DEV_DOC\sql\postgres"
$SCRIPT_NAME = "V10__functions"

$SQL_FILES = @(
    "fn_add_dt.sql",
    "fn_concat.sql",
    "fn_currval.sql",
    "fn_get_dt.sql",
    "fn_get_dt_diff.sql",
    "fn_get_ymd.sql",
    "fn_get_yyyymmdd.sql",
    "fn_length.sql",
    "fn_now_dt.sql",
    "sp_nextval.sql",
    "sp_set_use_wes.sql",
    "sp_unset_use_wes.sql"
)

# ============================================================
# STEP 1: dev DB에 함수/프로시저 적용
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 1: 함수/프로시저 dev DB 적용 중..." -ForegroundColor Cyan
Write-Host "  TO  : $TO_HOST`:$TO_PORT/$TO_DB"
Write-Host "  SRC : $SQL_DIR"

if (-not (Test-Path $SQL_DIR)) {
    Write-Host "[ERROR] SQL 소스 디렉토리가 없습니다: $SQL_DIR" -ForegroundColor Red
    exit 1
}

$env:PGPASSWORD = $TO_PASS

foreach ($file in $SQL_FILES) {
    $filePath = "$SQL_DIR\$file"

    if (-not (Test-Path $filePath)) {
        Write-Host "  [SKIP] $file — 파일 없음" -ForegroundColor DarkGray
        continue
    }

    & $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $filePath

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] $file 적용 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }

    Write-Host "  → $file 완료" -ForegroundColor Green
}

# ============================================================
# STEP 2: 설치 검증
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 2: 설치 검증" -ForegroundColor Cyan

$verifySql = "SELECT proname, oid FROM pg_proc WHERE proname IN ('fn_add_dt','fn_concat','fn_currval','fn_get_dt','fn_get_dt_diff','fn_get_ymd','fn_get_yyyymmdd','fn_length','fn_now_dt','sp_nextval','sp_set_use_wes','sp_unset_use_wes') ORDER BY proname;"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$tmpV = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpV, $verifySql, $utf8NoBom)

Write-Host "  [dev DB 설치 목록]"
$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpV
Remove-Item $tmpV -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료." -ForegroundColor Green
Write-Host "  ※ sp_set_use_wes, sp_unset_use_wes 는 PROCEDURE → FUNCTION 으로 변환됨 (PostgreSQL 10 호환). 호출 시 CALL 대신 SELECT 사용." -ForegroundColor Yellow
