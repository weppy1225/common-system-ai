# ============================================================
# db_config.ps1
# DB 접속정보 공통 설정 — 모든 migrate_V*.ps1 에서 dot-source
#   . "$PSScriptRoot\db_config.ps1"
# ============================================================

# 한글 출력 인코딩 UTF-8 설정
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding            = [System.Text.Encoding]::UTF8

$FROM_HOST = "168.126.28.62"
$FROM_PORT = "15432"
$FROM_DB   = "wms-cloud-test"
$FROM_USER = "wms_cloud_test_sa"
$FROM_PASS = "Z1nPass01!Q2w3e4r"

$TO_HOST   = "localhost"
$TO_PORT   = "15432"
$TO_DB     = "wms-cloud-dev"
$TO_USER   = "wms_cloud_dev_sa"
$TO_PASS   = "Z1nPass01!Q2w3e4r"

# pg_dump / psql 경로 — PostgreSQL 설치 경로 자동 탐지 (버전 무관)
$PG_BIN = (Get-Item "C:\Program Files\PostgreSQL\*\bin" -ErrorAction SilentlyContinue |
           Sort-Object Name -Descending | Select-Object -First 1).FullName
$PG_DUMP = if ($PG_BIN) { "$PG_BIN\pg_dump.exe" } else { "pg_dump" }
$PSQL    = if ($PG_BIN) { "$PG_BIN\psql.exe"    } else { "psql"    }

# 프로젝트 루트 (TT_551 → 05 이행(TT) → output → 루트)
$PROJECT_ROOT    = (Resolve-Path "$PSScriptRoot\..\..\..").Path
# BE 프로젝트 루트 (cloud-wms-doc 와 같은 워크스페이스 내 형제 프로젝트)
$BE_PROJECT_ROOT = Join-Path (Split-Path $PROJECT_ROOT) "cloud-wms-be"

# test DB 컬럼 순서 기반 CSV 반환 — \copy FROM 컬럼 리스트 지정에 사용
# 목적: test DB와 dev DB 컬럼 순서가 다를 때 \copy 데이터 오염 방지
function Get-TestColCsv {
    param([string]$tbl)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $q = "SELECT string_agg('""' || column_name || '""', ',' ORDER BY ordinal_position) FROM information_schema.columns WHERE table_name = '$tbl' AND table_schema = 'public';"
    $tmpQ = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpQ, $q, $utf8NoBom)
    $env:PGPASSWORD = $FROM_PASS
    $result = & $PSQL -h $FROM_HOST -p $FROM_PORT -U $FROM_USER -d $FROM_DB -t -A -f $tmpQ
    Remove-Item $tmpQ -Force
    return ($result | Where-Object { $_ -ne '' }) -join ''
}
