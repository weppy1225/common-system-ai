---
name: SD_333
description: 실DB 접속 → DDL SQL 파일 생성 (PostgreSQL, pg_catalog 기반, Windows/WSL/Linux 자동 감지). /SD_333
when_to_use: "DDL 뽑아줘", "DB 스키마 SQL로 추출", "CREATE TABLE 스크립트 만들어줘" 요청 시 사용.
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, AskUserQuestion
---

# DB Schema DDL 자동 생성 (실 DB 접속, Windows/WSL/Linux/Mac 통합) [SD_333]

지정된 디렉토리에서 DB 접속 설정을 자동으로 찾아 **PostgreSQL** 에 직접 접속하고,
`pg_catalog` 기반 쿼리로 스키마(SEQUENCE / TABLE / PK / UNIQUE / FK / INDEX) 를 추출하여
하나의 DDL `.sql` 파일로 저장한다.

> **목적:** 고객사 인계용 산출물(DB 스냅샷 SQL). 신규 환경에 그대로 실행해 동일 구조를 재현하기 위한 DDL.

> **PostgreSQL 전용:** pg_catalog 의존. MySQL/MSSQL/Oracle 의 DDL 생성은 v1 범위가 아니다.
> (테이블정의서 엑셀이 필요하면 `/SD_331`, ERD HTML 이 필요하면 `/SD_334` 사용.)

> **클라이언트 도구 불필요:** `psql` / `pg_dump` 가 설치되지 않은 환경을 가정한다.
> Python 표준 라이브러리 + `psycopg2-binary` 만으로 직접 접속한다. (PG10 클라이언트 ↔ PG15 서버 버전 충돌 회피)

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션] — `python` 실행.
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션] — `python3` 실행.
```

> Python 스크립트(`scripts/*.py`)는 양쪽에서 공유. 스크립트 내부에서 `/mnt/c/...` ↔ `C:\...` 경로를 자동 정규화한다.

---

## 사전 준비 (공통)

### 1) 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 우선 사용하고, 부족한 값은 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 스캔 디렉토리 경로 | DB 접속 설정 파일이 들어 있는 프로젝트 루트의 절대경로. Windows(`C:\...`)/WSL(`/mnt/c/...`) 모두 허용. |
| 고객사명 | 출력 파일명에 들어감. OS 예약 문자(`<>:"|?*\\/`)는 자동 `_` 치환. |

검증:
- 디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
OUTPUT_DIR = deliverables/30-output/03 설계(SD)
TMP_DIR    = deliverables/30-output/03 설계(SD)/tmp
SCRIPTS    = .claude/skills/SD_333/scripts
```

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 생성한다. `{YYMMDD}` 는 오늘 날짜.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
$RepoPrefix = $RepoName -replace '-[^-]+$',''
$BeRoot = Join-Path $Workspace "$RepoPrefix-be"
```

### W-1) Python 의존성 확인

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

python -c "import psycopg2" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user psycopg2-binary }
```

> `python` 실행 실패 시 `py -3` 로 재시도.

### W-2) DB 접속정보 스캔

```powershell
Set-Location $DocRoot
python -u ".claude\skills\SD_333\scripts\01_scan_config.py" "{디렉토리경로}"
```

### W-3) DDL 추출 및 SQL 저장

```powershell
Set-Location $DocRoot
python -u ".claude\skills\SD_333\scripts\02_extract_ddl.py" "{고객사명}"
```

### W-4) 임시 파일 정리 (필수)

```powershell
Remove-Item -Recurse -Force "$DocRoot\output\03 설계(SD)\tmp"
```

---

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
REPO_PREFIX="${REPO_NAME%-*}"
BE_ROOT="$WORKSPACE/${REPO_PREFIX}-be"
```

### B-1) Python 의존성 확인

```bash
python3 -c "import psycopg2" 2>/dev/null || python3 -m pip install --user psycopg2-binary
```

### B-2) DB 접속정보 스캔

```bash
cd "$DOC_ROOT"
python3 -u .claude/skills/SD_333/scripts/01_scan_config.py "{디렉토리경로}"
```

### B-3) DDL 추출 및 SQL 저장

```bash
cd "$DOC_ROOT"
python3 -u .claude/skills/SD_333/scripts/02_extract_ddl.py "{고객사명}"
```

### B-4) 임시 파일 정리 (필수)

```bash
rm -rf "$DOC_ROOT/deliverables/30-output/03 설계(SD)/tmp"
```

---

## 1단계 스캔 — DB 접속정보 후보 (공통)

`scripts/01_scan_config.py` 가 수행하는 일. 지정 디렉토리(하위 포함)에서 아래 패턴 파일을 찾아 후보를 모은다.

| 패턴 | 추출 키 |
|---|---|
| `application.properties` / `application-*.properties` (Spring) | `db.url`, `db.username`, `db.password`, `spring.datasource.*` |
| `application.yml` / `application.yaml` / `application-*.yml` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `.env`, `.env.*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL` |
| `docker-compose.yml` / `docker-compose.yaml` | `services.*.environment` (POSTGRES_USER, POSTGRES_DB 등) |
| `database.yml` (Rails) | `adapter`, `host`, `port`, `database`, `username`, `password` |
| `settings.py` (Django) | `DATABASES['default']` |
| `prisma/schema.prisma` | `datasource db { url = ... }` |

**중복 후보 제거 규칙**: `(driver, host, port, database)` 조합이 같으면 같은 후보로 간주한다. user/password는 더 풍부한 쪽을 채택한다.

**PostgreSQL 외 driver**(mysql/mssql/oracle)는 후보에서 제외한다. (SD_333 은 PostgreSQL 전용.)

JDBC URL 파싱:
- `jdbc:log4jdbc:postgresql://host:port/db` → `log4jdbc:` 프리픽스 제거 후 host/port/db 추출
- `jdbc:postgresql://host:port/db?currentSchema=xxx` → schema 파라미터도 함께 추출

---

## 1.5단계 — 사용자 확인 및 누락 정보 보강 (공통)

`db_candidates.json` 을 Read 도구로 열어 후보를 확인한다.

1. **후보 0개**: `AskUserQuestion` 으로 host/port/database/user/password/schema 를 직접 입력 받아 가상 후보 1개를 만든다.
2. **후보 1개**: 사용자에게 해당 정보로 진행할지, password 누락 시 password 를 입력할지 묻는다.
3. **후보 2개 이상**: `AskUserQuestion` 으로 어떤 후보를 사용할지 선택 받는다.

선택된 후보의 password 가 비어 있으면 **AskUserQuestion으로 password 를 별도 질문**한다.

확정된 접속정보는 `deliverables/30-output/03 설계(SD)/tmp/db_target.json` 으로 저장한다.

```json
{
  "driver": "postgresql",
  "host": "localhost",
  "port": 5432,
  "database": "wms",
  "user": "wms",
  "password": "...",
  "schema": "public"
}
```

> `schema` 가 누락되면 PostgreSQL 기본값 `public` 으로 채운다.

---

## 2단계 DDL 추출 상세 (공통)

`scripts/02_extract_ddl.py` 가 수행하는 일.

1. `psycopg2.connect(...)` 로 DB 연결. 연결 실패 시 사유를 명확히 출력하고 종료.
2. 아래 7개 섹션을 순서대로 SQL 텍스트로 누적한다.

| 순서 | 섹션 | 소스 |
|---|---|---|
| 헤더 | DB 정보 + `SET` 설정 (encoding, timeout, standard_conforming_strings) | 고정 |
| 1 | SEQUENCES | `information_schema.sequences` |
| 2 | TABLES | `pg_class` + `pg_attribute` + `pg_attrdef` (타입은 `format_type`, default 는 `pg_get_expr`) |
| 3 | PRIMARY KEY CONSTRAINTS | `pg_constraint` (contype='p') |
| 4 | UNIQUE CONSTRAINTS | `pg_constraint` (contype='u') |
| 5 | FOREIGN KEY CONSTRAINTS | `pg_constraint` (contype='f') — ON UPDATE/DELETE 액션 포함 (`r/c/n`) |
| 6 | INDEXES | `pg_indexes` (PK/UNIQUE constraint 와 동명인 인덱스는 제외) |

3. 최종 SQL 본문을 `deliverables/30-output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 에 **UTF-8 (BOM 없음)** 으로 저장한다.

4. 통계 계산:
   - SEQUENCE / TABLE / PK / UNIQUE / FK / INDEX 건수
   - 파일 크기(KB) / 라인 수

5. 콘솔에 완료 보고를 출력한다.

> 모든 쿼리는 사용자가 지정한 `schema` (기본 `public`) 안의 객체로 한정한다.
> `pg_dump` 의 출력과 100% 동일하지는 않지만, 동일 구조를 재현하기 위한 핵심 DDL은 모두 포함된다.

---

## 완료 체크리스트 (공통)

- [ ] 입력(디렉토리 / 고객사명) 확정
- [ ] Python 3 설치 확인
- [ ] `psycopg2` import 가능 확인 (없으면 자동 설치)
- [ ] `tmp/db_candidates.json` 생성 — PostgreSQL 후보 1건 이상
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장, password 보강)
- [ ] DB 연결 성공
- [ ] `deliverables/30-output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 생성
- [ ] SEQUENCES / TABLES / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEXES 6개 섹션 모두 출력
- [ ] `tmp/` 삭제 완료 (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ DB Schema DDL 생성 완료 [SD_333]

실행 환경:     Windows PowerShell / Python    또는    Bash on Linux/Mac/WSL / Python3
대상 디렉토리: {디렉토리경로}
고객사:        {고객사명}
DB:            postgresql {host}:{port}/{database} (schema={schema}, version={server_version})

DDL 현황:
  - SEQUENCE    : N 건
  - TABLE       : N 건
  - PRIMARY KEY : N 건
  - UNIQUE      : N 건
  - FOREIGN KEY : N 건
  - INDEX       : N 건

출력 파일: deliverables/30-output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql
파일 크기: {N} KB ({N} 라인)
```

---

## 주의사항 (공통)

- **PostgreSQL 전용**: MySQL/MSSQL/Oracle 의 DDL 생성은 v1 범위가 아니다.
- **버전 호환**: psql 클라이언트 버전과 서버 버전이 달라도(예: PG10 ↔ PG15) `psycopg2` 는 동작한다.
- **schema 처리**: 사용자가 schema 를 지정하지 않으면 `public` 으로 한정. 여러 schema 추출은 분리 실행.
- **권한 부족**: `pg_catalog` / `information_schema` 조회 권한이 없으면 일부 섹션이 비어버린다. owner 또는 superuser 권장.
- **출력 파일 덮어쓰기**: 동일 파일명 존재 시 사용자에게 한 번 확인.
- **비밀번호 노출 방지**: 마지막 단계에서 `tmp/` 가 자동 삭제되지만, 비정상 종료 시 즉시 수동 삭제.

### Windows 특화

- **`python` vs `py`**: 우선 `python --version` 으로 확인. 실패 시 `py -3` 로 재시도.
- **한글 콘솔 출력 깨짐**: `chcp 65001` + `$env:PYTHONUTF8 = "1"` + `[Console]::OutputEncoding = [Text.UTF8Encoding]::new()` 로 UTF-8 모드 전환.
- **경로 공백·한글 처리**: `"output\03 설계(SD)"` 처럼 공백·한글 경로는 큰따옴표로 감싼다.

### Bash 특화

- **Python 실행 명령**: `python3`. macOS Homebrew 는 `python3`, `python` 은 Python 2.
- **WSL 경로**: 사용자가 `/mnt/c/...` 로 입력해도 스크립트가 자동 정규화.

### 함께 보면 좋은 스킬

- 엑셀 테이블정의서 → `/SD_331`
- 인터랙티브 ERD HTML → `/SD_334`
- 정적 ERD 뷰어(기존 템플릿 갱신) → `/SD_211`
