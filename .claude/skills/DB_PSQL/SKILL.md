---
name: DB_PSQL
description: >
  현재 프로젝트의 DB를 조회한다. workspace 폴더명으로 시스템을 자동 감지하고,
  BE properties 파일에서 접속 정보를 읽어 MCP 또는 psql로 실행한다.
  "DB 조회", "테이블 확인", "컬럼 구조", "공통코드 값", "스키마 확인" 요청 시 사용.
when_to_use: "DB 테이블 목록", "컬럼 확인", "공통코드 조회", "스키마 확인", "DB 조회해줘" 요청 시 사용.
allowed-tools: Read, Glob, Bash, PowerShell, AskUserQuestion
---

# DB_PSQL 실행 절차

## STEP 1 — 프로젝트 자동 감지

PowerShell로 workspace 폴더명에서 `$PROJECT`와 `$BE_DIR`을 도출한다.

```powershell
$AI_DIR = git rev-parse --show-toplevel
$WS     = Split-Path $AI_DIR -Parent
$PROJECT = (Split-Path $WS -Leaf) -replace '^workspace-', ''
$BE_DIR  = Join-Path $WS "$PROJECT-be"
if (-not (Test-Path $BE_DIR)) {
    $BE_DIR = (Get-ChildItem $WS -Directory -Filter '*-be' | Select-Object -First 1).FullName
}
Write-Host "PROJECT=$PROJECT  BE_DIR=$BE_DIR"
```

---

## STEP 2 — 환경 선택 (AskUserQuestion)

`$BE_DIR/src/main/resource/prop/` 에서 `application-*.properties` 목록을 확인한다.

```powershell
Get-ChildItem "$BE_DIR\src\main\resource\prop" -Filter "application-*.properties" |
    Select-Object -ExpandProperty BaseName |
    ForEach-Object { $_ -replace 'application-', '' }
# 예: dev, test, prod
```

파일이 **2개 이상** 이면 `AskUserQuestion`으로 환경을 묻는다.
파일이 **1개** 이면 그 환경을 자동 선택한다.

> AskUserQuestion 질문 예시:
> - 질문: "어떤 환경의 DB에 접속할까요?"
> - 옵션: 발견된 환경 목록 (dev / test / prod)

---

## STEP 3 — properties 파일 읽기 및 파싱

선택된 `$ENV` 로 파일을 Read 도구로 읽는다.

```
파일 경로: $BE_DIR/src/main/resource/prop/application-{$ENV}.properties
```

다음 키를 파싱한다.

| 키 | 용도 |
|---|---|
| `db.url` | 메인 DB 접속 URL |
| `db.username` | 메인 DB 계정 |
| `db.password` | 메인 DB 비밀번호 |
| `db.erp.url` | ERP DB URL (존재 시) |

**URL 정규화** — `jdbc:log4jdbc:` 또는 `jdbc:` 접두어를 제거해 표준 URL을 추출한다.

```
jdbc:log4jdbc:postgresql://host:port/dbname  →  postgresql://host:port/dbname
jdbc:log4jdbc:sqlserver://host:port;...      →  sqlserver://host:port;...
```

---

## STEP 4 — psql로 쿼리 실행

STEP 3에서 파싱한 접속 정보로 Bash 도구를 통해 psql을 실행한다.

```bash
PGPASSWORD='{db.password}' psql \
  -h {host} -p {port} -U {db.username} -d {dbname} \
  -c "{쿼리}"
```

**ERP(SQL Server) 테이블은 psql로 조회 불가** — DB 클라이언트(DBeaver 등)를 직접 사용한다.

> psql PATH 확인: `which psql` 또는 `psql --version`
> 없으면 Bash로 `find /c/Program\ Files/PostgreSQL -name psql.exe 2>/dev/null | head -1` 로 경로 탐색 후 사용한다.

---

## STEP 5 — 스키마 문서 참조 경로

DB 직접 조회 전에 아래 문서에서 테이블·컬럼 정보를 먼저 확인한다.

| 문서 | 경로 |
|---|---|
| 전체 테이블 목록 | `spec/{$PROJECT}/_knowledge/db-schema/00-tables-overview.md` |
| 테이블 상세 | `spec/{$PROJECT}/_knowledge/db-schema/01-*.md` ~ `05-*.md` |
| 공통코드 값 | `spec/{$PROJECT}/_knowledge/db-schema/90-common-code.md` |
