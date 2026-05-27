---
name: SD_333_BASH
description: 【DB Schema DDL SQL 생성 (실DB 접속, WSL/Linux/Mac)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 PostgreSQL DB에 직접 접속하고, pg_catalog 기반 쿼리로 SEQUENCE / TABLE / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEX 의 DDL(CREATE/ALTER 문)을 추출하여 `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 단일 SQL 파일로 자동 저장합니다. /SD_333_BASH 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. psql·pg_dump 등 OS 클라이언트가 설치되지 않아도 동작하며, Python + psycopg2-binary 만 있으면 됩니다. DDL 추출, DB Schema SQL 생성, CREATE TABLE/INDEX/FK 스크립트 만들기, DB 스냅샷 SQL 산출물 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "DDL 뽑아줘", "DB 스키마 SQL로 추출", "CREATE TABLE 스크립트 만들어줘", "PostgreSQL DDL 산출물", "SD_333_BASH 실행해줘", "WSL에서 DB Schema DDL 뽑아줘" 라고 말해도 이 스킬을 사용합니다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331_BASH, 인터랙티브 ERD HTML이 필요하면 /SD_334_BASH 쪽이 맞으니 산출물 형식(SQL/Excel/HTML)을 먼저 확인해 분기합니다. Windows 환경에서는 기본 SD_333 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB Schema DDL 자동 생성 (실 DB 접속, WSL/Linux/Mac) [SD_333_BASH]

지정된 디렉토리에서 DB 접속 설정을 자동으로 찾아 **PostgreSQL** 에 직접 접속하고,
`pg_catalog` 기반 쿼리로 스키마(SEQUENCE / TABLE / PK / UNIQUE / FK / INDEX) 를 추출하여
하나의 DDL `.sql` 파일로 저장한다.

> **실행 환경:** WSL · Linux · macOS. Bash에서 직접 `python3` 을 호출한다.
>
> **목적:** 고객사 인계용 산출물(DB 스냅샷 SQL). 신규 환경에 그대로 실행해 동일 구조를 재현하기 위한 DDL.
>
> **PostgreSQL 전용:** pg_catalog 의존. MySQL/MSSQL/Oracle 의 DDL 생성은 v1 범위가 아니다.
> (테이블정의서 엑셀이 필요하면 `SD_331_BASH`, ERD HTML 이 필요하면 `SD_334_BASH` 사용.)

> **클라이언트 도구 불필요:** `psql` / `pg_dump` 가 설치되지 않은 환경을 가정한다.
> Python 표준 라이브러리 + `psycopg2-binary` 만으로 직접 접속한다. (PG10 클라이언트 ↔ PG15 서버 버전 충돌 회피)

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 우선 사용하고, 부족한 값은 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 스캔 디렉토리 경로 | DB 접속 설정 파일이 들어 있는 프로젝트 루트의 절대경로. 예: `/mnt/c/zinide/workspace/wms-bnk-be` |
| 고객사명 | 출력 파일명에 들어감. 한글/공백 가능. 파일명 예약 문자는 자동 `_` 치환. |

검증:
- 디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의 (동적)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"

OUTPUT_DIR="$DOC_ROOT/output/03 설계(SD)"
TMP_DIR="$DOC_ROOT/output/03 설계(SD)/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/SD_333_BASH/scripts"
```

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 `mkdir -p` 로 생성한다.

### 3) Python 의존성 확인

```bash
python3 -c "import psycopg2" 2>/dev/null || python3 -m pip install --user psycopg2-binary
```

---

## 워크플로우 (3단계)

각 단계는 Bash에서 `python3` 으로 스크립트를 직접 실행한다.
`SD_333_BASH/scripts/` 는 `SD_333/scripts/` 와 동일한 Python 스크립트를 공유한다 (심볼릭 링크 또는 복사).
중간 산출물(`tmp/*.json`)이 정상 생성됐는지 확인한 뒤 다음 단계로 넘어간다.

```
.claude/skills/SD_333_BASH/scripts/
├── 01_scan_config.py   # 1단계 — DB 접속정보 후보 추출
└── 02_extract_ddl.py   # 2단계 — psycopg2로 접속 후 pg_catalog 기반 DDL 추출 + .sql 저장
```

---

### 1단계 — DB 접속정보 스캔 (디렉토리 → JSON)

**스크립트**: `scripts/01_scan_config.py`
**입력**: 사용자 지정 디렉토리 경로
**출력**: `output/03 설계(SD)/tmp/db_candidates.json`

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_333_BASH/scripts/01_scan_config.py "{디렉토리경로}"
```

스크립트는 지정 디렉토리(하위 포함)에서 아래 패턴 파일을 찾아 후보를 모은다.

| 패턴 | 추출 키 |
|---|---|
| `application.properties` / `application-*.properties` (Spring) | `db.url`, `db.username`, `db.password`, `spring.datasource.*` |
| `application.yml` / `application.yaml` / `application-*.yml` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `.env`, `.env.*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL` |
| `docker-compose.yml` / `docker-compose.yaml` | `services.*.environment` (POSTGRES_USER, POSTGRES_DB 등) |
| `database.yml` (Rails) | `adapter`, `host`, `port`, `database`, `username`, `password` |
| `settings.py` (Django) | `DATABASES['default']` |
| `prisma/schema.prisma` | `datasource db { url = ... }` |

**PostgreSQL 외 driver**(mysql/mssql/oracle)는 후보에서 제외한다.

후보 결과(`db_candidates.json`):

```json
{
  "scanned_dir": "/mnt/c/zinide/workspace/wms-bnk-be",
  "candidates": [
    {
      "driver": "postgresql",
      "host": "localhost",
      "port": 5432,
      "database": "wms",
      "user": "wms",
      "password": "...",
      "schema": "public",
      "source_files": ["src/main/resource/prop/application-test.properties"]
    }
  ]
}
```

---

### 2단계 — 사용자 확인 및 누락 정보 보강

`db_candidates.json` 을 Read 도구로 열어 후보를 확인한다.

1. **후보 0개**: `AskUserQuestion` 으로 host/port/database/user/password/schema 를 직접 입력 받아 가상 후보 1개를 만든다.
2. **후보 1개**: 사용자에게 해당 정보로 진행할지, password 누락 시 password 를 입력할지 묻는다.
3. **후보 2개 이상**: `AskUserQuestion` 으로 어떤 후보를 사용할지 선택 받는다.

선택된 후보의 password 가 비어 있으면 **AskUserQuestion으로 password 를 별도 질문**한다.

확정된 접속정보는 `output/03 설계(SD)/tmp/db_target.json` 으로 저장한다.

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

---

### 3단계 — DDL 추출 및 SQL 저장

**스크립트**: `scripts/02_extract_ddl.py`
**입력**: `output/03 설계(SD)/tmp/db_target.json`, 고객사명
**출력**: `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql`

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_333_BASH/scripts/02_extract_ddl.py "{고객사명}"
```

스크립트가 수행하는 일:

1. `psycopg2.connect(...)` 로 DB 연결. 연결 실패 시 사유를 명확히 출력하고 종료한다.
2. 아래 7개 섹션을 순서대로 SQL 텍스트로 누적한다.

| 순서 | 섹션 | 소스 |
|---|---|---|
| 헤더 | DB 정보 + `SET` 설정 | 고정 |
| 1 | SEQUENCES | `information_schema.sequences` |
| 2 | TABLES | `pg_class` + `pg_attribute` + `pg_attrdef` |
| 3 | PRIMARY KEY CONSTRAINTS | `pg_constraint` (contype='p') |
| 4 | UNIQUE CONSTRAINTS | `pg_constraint` (contype='u') |
| 5 | FOREIGN KEY CONSTRAINTS | `pg_constraint` (contype='f') |
| 6 | INDEXES | `pg_indexes` (PK/UNIQUE 동명 인덱스 제외) |

3. 최종 SQL 본문을 `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 에 **UTF-8 (BOM 없음)** 으로 저장한다.

---

### 4단계 — 임시 파일 정리 (필수)

3단계가 성공적으로 끝나면 비밀번호 노출을 막기 위해 `tmp/` 폴더를 **반드시** 삭제한다.

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
rm -rf "$DOC_ROOT/output/03 설계(SD)/tmp"
```

- `tmp/db_target.json` 에는 DB 비밀번호가 평문으로 저장되므로 보관하지 않는다.
- 3단계가 실패한 경우에는 디버깅을 위해 `tmp/` 를 그대로 두고, 사용자에게 원인을 보고한다.

---

## 완료 체크리스트

- [ ] 입력(디렉토리 / 고객사명) 확정
- [ ] `python3 --version` 으로 Python 3 설치 확인
- [ ] `psycopg2` import 가능 확인 (없으면 `pip install --user psycopg2-binary`)
- [ ] `tmp/db_candidates.json` 생성 — PostgreSQL 후보 1건 이상
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장, password 보강)
- [ ] DB 연결 성공
- [ ] `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 생성
- [ ] SEQUENCES / TABLES / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEXES 6개 섹션 모두 출력
- [ ] `tmp/` 삭제 완료 (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ DB Schema DDL 생성 완료 [SD_333_BASH]

대상 디렉토리: {디렉토리경로}
고객사:        {고객사명}
DB:            postgresql {host}:{port}/{database} (schema={schema}, version={server_version})
실행 환경:     WSL/Linux/Mac / Python {버전} / psycopg2 {버전}

DDL 현황:
  - SEQUENCE    : N 건
  - TABLE       : N 건
  - PRIMARY KEY : N 건
  - UNIQUE      : N 건
  - FOREIGN KEY : N 건
  - INDEX       : N 건

출력 파일: output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql
파일 크기: {N} KB ({N} 라인)
```
