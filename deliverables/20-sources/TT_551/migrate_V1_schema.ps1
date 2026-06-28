# ============================================================
# migrate_V1_schema.ps1
# DDL 적용: 시퀀스 선생성 → V1__create_schema.sql 적용
# 실행: .\migrate_V1_schema.ps1
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$DDL_FILE    = "$PROJECT_ROOT\input\TT.551\V1__create_schema.sql"
$SCRIPT_NAME = "V1__create_schema"
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $DDL_FILE)) {
    Write-Host "[ERROR] $DDL_FILE 파일이 없습니다." -ForegroundColor Red
    exit 1
}

# ============================================================
# STEP 1: test DB 시퀀스 목록 조회 → dev DB에 CREATE SEQUENCE
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 1: 시퀀스 생성 중..." -ForegroundColor Cyan
Write-Host "  TO  : $TO_HOST`:$TO_PORT/$TO_DB"

$seqQuery = "SELECT sequence_name FROM information_schema.sequences ORDER BY sequence_name;"
$tmpSeqQ  = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpSeqQ, $seqQuery, $utf8NoBom)

$env:PGPASSWORD = $FROM_PASS
$seqNames = & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -t -A -f $tmpSeqQ
Remove-Item $tmpSeqQ -Force

$seqSql = ($seqNames | Where-Object { $_ -ne '' } | ForEach-Object {
    "CREATE SEQUENCE IF NOT EXISTS `"$_`" INCREMENT 1 MINVALUE 1 NO CYCLE;"
}) -join "`n"

$tmpSeq = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpSeq, $seqSql, $utf8NoBom)

$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $tmpSeq
Remove-Item $tmpSeq -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] 시퀀스 생성 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red
    exit 1
}
Write-Host "  → 시퀀스 생성 완료 ($($seqNames.Count) 개)" -ForegroundColor Green

# ============================================================
# STEP 2: DDL 적용
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 2: DDL 적용 중..." -ForegroundColor Cyan
Write-Host "  FILE: $DDL_FILE"

$env:PGPASSWORD = $TO_PASS
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d $TO_DB -f $DDL_FILE

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] DDL 적용 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

# ============================================================
# STEP 3: 테이블 수 검증
# ============================================================
Write-Host ""
Write-Host "[$SCRIPT_NAME] STEP 3: 테이블 수 검증" -ForegroundColor Cyan
$verifySql = "SELECT COUNT(*) AS table_cnt FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
$tmpV = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpV, $verifySql, $utf8NoBom)

Write-Host "  [test DB]"; $env:PGPASSWORD = $FROM_PASS; & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -f $tmpV
Write-Host "  [dev DB]";  $env:PGPASSWORD = $TO_PASS;   & $PSQL -h $TO_HOST   -p $TO_PORT   -U $TO_USER   -d $TO_DB   -f $tmpV
Remove-Item $tmpV -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료. 테이블 수가 일치하면 DDL 이관 성공." -ForegroundColor Green
