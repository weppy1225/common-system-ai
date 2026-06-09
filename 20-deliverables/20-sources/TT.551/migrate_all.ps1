# ============================================================
# migrate_all.ps1
# 전체 이관 순서 실행: V0 ~ V10
#   V0  : TO DB 데이터베이스 생성
#   V1  : DDL (스키마 생성)
#   V2~V9: 데이터 이관 (test → dev)
#   V10 : 함수/프로시저 설치
# 실행: .\migrate_all.ps1
# 개별 실행: .\migrate_V3_biz.ps1 (특정 그룹만 재실행)
# ============================================================

. "$PSScriptRoot\db_config.ps1"

$SCRIPTS = @(
    "migrate_V0_create_db.ps1",
    "migrate_V1_schema.ps1",
    "migrate_V2_code.ps1",
    "migrate_V3_biz.ps1",
    "migrate_V4_center.ps1",
    "migrate_V5_warehouse.ps1",
    "migrate_V6_location.ps1",
    "migrate_V7_config.ps1",
    "migrate_V8_menu.ps1",
    "migrate_V9_user.ps1",
    "migrate_V10_functions.ps1"
)

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host " DB 이관 전체 실행 V0~V10 (DB생성 → DDL → 데이터 → 함수)" -ForegroundColor Yellow
Write-Host "  FROM: $FROM_HOST`:$FROM_PORT/$FROM_DB" -ForegroundColor Yellow
Write-Host "  TO  : $TO_HOST`:$TO_PORT/$TO_DB" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow

$total   = $SCRIPTS.Count
$success = 0
$failed  = @()

foreach ($script in $SCRIPTS) {
    $scriptPath = "$PSScriptRoot\$script"

    if (-not (Test-Path $scriptPath)) {
        Write-Host ""
        Write-Host "[SKIP] $script — 파일 없음" -ForegroundColor DarkGray
        continue
    }

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host " 실행: $script" -ForegroundColor DarkCyan
    Write-Host "============================================================" -ForegroundColor DarkCyan

    & $scriptPath

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "[FAIL] $script 실패. 이관을 중단합니다." -ForegroundColor Red
        $failed += $script
        break
    }

    $success++
}

# ============================================================
# 최종 결과
# ============================================================
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host " 이관 결과: $success / $total 완료" -ForegroundColor Yellow

if ($failed.Count -gt 0) {
    Write-Host " 실패: $($failed -join ', ')" -ForegroundColor Red
    Write-Host " 위 스크립트를 개별 실행하여 오류를 확인하세요." -ForegroundColor Red
} else {
    Write-Host " 전체 이관 성공." -ForegroundColor Green
}
Write-Host "============================================================" -ForegroundColor Yellow
