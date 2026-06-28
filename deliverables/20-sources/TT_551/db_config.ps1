# ============================================================
# db_config.ps1
# DB 접속정보 공통 설정 — 모든 migrate_V*.ps1 에서 dot-source
#   . "$PSScriptRoot\db_config.ps1"
# ============================================================

# 한글 출력 인코딩 UTF-8 설정
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding            = [System.Text.Encoding]::UTF8

# 프로젝트 루트(AI 허브) → 워크스페이스 → 프로젝트명 도출 (→ .claude/rules/repo-paths.md)
$PROJECT_ROOT    = (Resolve-Path "$PSScriptRoot\..\..\..").Path
$WORKSPACE       = Split-Path $PROJECT_ROOT
$REPO_PREFIX     = (Split-Path $WORKSPACE -Leaf) -replace '^workspace-',''   # 워크스페이스 폴더명에서 workspace- 제거 → 프로젝트명
$DB_USER_PREFIX  = $REPO_PREFIX -replace '-','_'                             # 계정명은 언더스코어 (예: bnk-wms → bnk_wms)
# 형제 BE 프로젝트 루트 (없으면 *-be 폴백)
$BE_PROJECT_ROOT = Join-Path $WORKSPACE "$REPO_PREFIX-be"
if (-not (Test-Path $BE_PROJECT_ROOT)) { $BE_PROJECT_ROOT = (Get-ChildItem $WORKSPACE -Directory -Filter '*-be' | Select-Object -First 1).FullName }

# DB 접속정보 — DB명/계정은 프로젝트명 기반: {프로젝트}-{env} / {프로젝트}_{env}_sa (운영은 env 접미사 없음)
#   ⚠ 실제 서버 DB·계정이 이 규칙으로 생성돼 있어야 한다.
$FROM_HOST = "168.126.28.62"
$FROM_PORT = "15432"
$FROM_DB   = "$REPO_PREFIX-test"
$FROM_USER = "${DB_USER_PREFIX}_test_sa"
$FROM_PASS = "Z1nPass01!Q2w3e4r"

$TO_HOST   = "localhost"
$TO_PORT   = "15432"
$TO_DB     = "$REPO_PREFIX-dev"
$TO_USER   = "${DB_USER_PREFIX}_dev_sa"
$TO_PASS   = "Z1nPass01!Q2w3e4r"

# pg_dump / psql 경로 — PostgreSQL 설치 경로 자동 탐지 (버전 무관)
$PG_BIN = (Get-Item "C:\Program Files\PostgreSQL\*\bin" -ErrorAction SilentlyContinue |
           Sort-Object Name -Descending | Select-Object -First 1).FullName
$PG_DUMP = if ($PG_BIN) { "$PG_BIN\pg_dump.exe" } else { "pg_dump" }
$PSQL    = if ($PG_BIN) { "$PG_BIN\psql.exe"    } else { "psql"    }

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
