# ============================================================
# migrate_V0_create_db.ps1
# TO DB 신규 데이터베이스 생성
# 대상: wms-cloud-dev (localhost:15432)
# 실행: .\migrate_V0_create_db.ps1
# ※ 기존 DB가 있으면 DROP 후 재생성하므로 주의
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SCRIPT_NAME = "V0__create_db"
$utf8NoBom   = New-Object System.Text.UTF8Encoding($false)

Write-Host ""
Write-Host "[$SCRIPT_NAME] TO DB 데이터베이스 생성 중..." -ForegroundColor Cyan
Write-Host "  TO  : $TO_HOST`:$TO_PORT"
Write-Host "  DB  : $TO_DB"
Write-Host ""
Write-Host "  ⚠ 기존 '$TO_DB' 데이터베이스가 있으면 삭제 후 재생성합니다." -ForegroundColor Yellow

$env:PGPASSWORD = $TO_PASS

# postgres 기본 DB에 접속하여 생성 (wms-cloud-dev 가 없어도 연결 가능)
$createSql = @"
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TO_DB' AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS "$TO_DB";
CREATE DATABASE "$TO_DB" ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'C' TEMPLATE = template0;
"@

$tmpCreate = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpCreate, $createSql, $utf8NoBom)
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d postgres -f $tmpCreate
Remove-Item $tmpCreate -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] 데이터베이스 생성 실패 (exitcode=$LASTEXITCODE)" -ForegroundColor Red
    Write-Host "  힌트: '$TO_USER' 계정에 CREATEDB 권한이 있는지 확인하세요." -ForegroundColor Yellow
    exit 1
}

# 생성 확인
Write-Host ""
Write-Host "[$SCRIPT_NAME] 생성 확인"
$verifySql = "SELECT datname, encoding, datcollate FROM pg_database WHERE datname = '$TO_DB';"
$tmpVerify = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tmpVerify, $verifySql, $utf8NoBom)
& $PSQL -h $TO_HOST -p $TO_PORT -U $TO_USER -d postgres -f $tmpVerify
Remove-Item $tmpVerify -Force

Write-Host ""
Write-Host "[$SCRIPT_NAME] 완료. '$TO_DB' 데이터베이스가 생성됐습니다." -ForegroundColor Green
