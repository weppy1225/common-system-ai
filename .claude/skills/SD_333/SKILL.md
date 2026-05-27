---
name: SD_333
description: 【DB Schema DDL SQL 생성 (실DB 접속, Windows)】 Windows 네이티브(PowerShell) 환경에서 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 PostgreSQL DB에 직접 접속하고, pg_catalog 기반 쿼리로 SEQUENCE / TABLE / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEX 의 DDL(CREATE/ALTER 문)을 추출하여 `output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 단일 SQL 파일로 자동 저장합니다. /SD_333 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. psql.exe·pg_dump 등 OS 클라이언트가 설치되지 않아도 동작하며, Python + psycopg2-binary 만 있으면 됩니다. (PG10 클라이언트 ↔ PG15 서버처럼 버전이 안 맞는 환경에서도 사용 가능.) DDL 추출, DB Schema SQL 생성, CREATE TABLE/INDEX/FK 스크립트 만들기, DB 스냅샷 SQL 산출물 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "DDL 뽑아줘", "DB 스키마 SQL로 추출", "CREATE TABLE 스크립트 만들어줘", "PostgreSQL DDL 산출물", "SD_333 실행해줘", "윈도우에서 DB Schema DDL 뽑아줘" 라고 말해도 이 스킬을 사용합니다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331, 인터랙티브 ERD HTML이 필요하면 /SD_334 쪽이 맞으니 산출물 형식(SQL/Excel/HTML)을 먼저 확인해 분기합니다. WSL/Linux/macOS 환경에서는 SD_333_BASH 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB Schema DDL 자동 생성 (실 DB 접속, Windows) [SD_333]

지정된 디렉토리에서 DB 접속 설정을 자동으로 찾아 **PostgreSQL** 에 직접 접속하고,
`pg_catalog` 기반 쿼리로 스키마(SEQUENCE / TABLE / PK / UNIQUE / FK / INDEX) 를 추출하여
하나의 DDL `.sql` 파일로 저장한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요.
>
> **목적:** 고객사 인계용 산출물(DB 스냅샷 SQL). 신규 환경에 그대로 실행해 동일 구조를 재현하기 위한 DDL.
>
> **PostgreSQL 전용:** pg_catalog 의존. MySQL/MSSQL/Oracle 의 DDL 생성은 v1 범위가 아니다.
> (테이블정의서 엑셀이 필요하면 `SD_331`, ERD HTML 이 필요하면 `SD_334` 사용.)

> **클라이언트 도구 불필요:** `psql.exe` / `pg_dump.exe` 가 설치되지 않은 환경을 가정한다.
> Python 표준 라이브러리 + `psycopg2-binary` 만으로 직접 접속한다. (PG10 클라이언트 ↔ PG15 서버 버전 충돌 회피)

> **Bash 도구 사용 규칙 (중요):**
> 이 스킬은 Windows 네이티브 환경을 가정한다. Bash 도구로 명령을 실행할 때는 반드시 다음 패턴 중 하나를 사용한다.
>
> ```
> powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell 명령>"
> ```
> 또는 PowerShell 7+ 이 있다면
> ```
> pwsh -NoProfile -Command "<PowerShell 명령>"
> ```
>
> Python 자체는 cross-platform이므로 `python ...` / `py -3 ...` 명령은 PowerShell에서 그대로 실행하면 된다.

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 우선 사용하고, 부족한 값은 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 스캔 디렉토리 경로 | DB 접속 설정 파일이 들어 있는 프로젝트 루트의 절대경로. Windows 경로(`C:\zinide\workspace\wms-bnk-be`) 또는 WSL 경로(`/mnt/c/...`) 모두 허용. 스크립트가 자동 정규화한다. |
| 고객사명 | 출력 파일명에 들어감. 한글/공백 가능. 파일명 예약 문자(`<>:"\|?*\\/`)는 자동 `_` 치환. |

검증:
- 디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의 (동적)

스킬 실행 시 PowerShell로 프로젝트 루트를 동적으로 감지한다.

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$BeRoot    = Join-Path $Workspace "wms-$ProjCode-be"
$FeRoot    = Join-Path $Workspace "wms-$ProjCode-fe"

$OUTPUT_DIR = "$DocRoot\output\03 설계(SD)"
$TMP_DIR    = "$DocRoot\output\03 설계(SD)\tmp"
$SCRIPTS    = "$DocRoot\.claude\skills\SD_333\scripts"
```

Bash 도구에서 호출할 때는:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\';
Set-Location $DocRoot;
...
"
```

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 `New-Item -ItemType Directory -Force` 로 생성한다.
`{YYMMDD}` 는 오늘 날짜(서버 로컬 시간).

> **BASE_DIR 자동 추론:** Python 스크립트 내부에서 `Path(__file__).resolve().parents[4]` 로 프로젝트 루트를 자동 추론하므로, Windows/WSL 어느 환경에서 호출되어도 정상 동작한다.

### 3) Python 의존성 확인 (PowerShell)

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

python -c "import psycopg2" 2>$null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user psycopg2-binary
}
```

> `python` 실행 실패 시 `py -3` 로 재시도한다.

---

## 워크플로우 (3단계)

각 단계는 Bash 도구로 PowerShell 명령을 호출하여 `.claude\skills\SD_333\scripts\` 안의 Python 스크립트를 실행한다.
중간 산출물(`tmp\*.json`)이 정상 생성됐는지 확인한 뒤 다음 단계로 넘어간다.
중간 단계에서 실패하면 `tmp\` 를 남겨 디버깅한다.

```
.claude\skills\SD_333\scripts\
├── 01_scan_config.py   # 1단계 — DB 접속정보 후보 추출
└── 02_extract_ddl.py   # 2단계 — psycopg2로 접속 후 pg_catalog 기반 DDL 추출 + .sql 저장
```

---

### 1단계 — DB 접속정보 스캔 (디렉토리 → JSON)

**스크립트**: `scripts\01_scan_config.py`
**입력**: 사용자 지정 디렉토리 경로 (Windows·WSL 형식 모두 가능)
**출력**: `output\03 설계(SD)\tmp\db_candidates.json`

Bash 도구를 통해 호출할 때는:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\';
Set-Location $DocRoot;
python -u '.claude\skills\SD_333\scripts\01_scan_config.py' '<디렉토리>'
"
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

**중복 후보 제거 규칙**: `(driver, host, port, database)` 조합이 같으면 같은 후보로 간주한다. user/password는 더 풍부한 쪽을 채택한다.

**PostgreSQL 외 driver**(mysql/mssql/oracle)는 후보에서 제외한다. (SD_333 은 PostgreSQL 전용.)

JDBC URL 파싱:
- `jdbc:log4jdbc:postgresql://host:port/db` → `log4jdbc:` 프리픽스 제거 후 host/port/db 추출
- `jdbc:postgresql://host:port/db?currentSchema=xxx` → schema 파라미터도 함께 추출

후보 결과(`db_candidates.json`)는 다음 형태로 저장된다.

```json
{
  "scanned_dir": "C:/zinide/workspace/wms-bnk-be",
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
> 보안: 비밀번호는 `tmp\db_target.json` 에 평문으로 저장된다. 3단계에서 자동 삭제하지만, 작업이 비정상 종료되면 즉시 수동 삭제한다.

확정된 접속정보는 `output\03 설계(SD)\tmp\db_target.json` 으로 저장한다.

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

### 3단계 — DDL 추출 및 SQL 저장

**스크립트**: `scripts\02_extract_ddl.py`
**입력**: `output\03 설계(SD)\tmp\db_target.json`, 고객사명
**출력**: `output\03 설계(SD)\SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql`

Bash 도구를 통해 호출할 때는:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\';
Set-Location $DocRoot;
python -u '.claude\skills\SD_333\scripts\02_extract_ddl.py' '<고객사명>'
"
```

스크립트가 수행하는 일:

1. `psycopg2.connect(...)` 로 DB 연결. 연결 실패 시 사유를 명확히 출력하고 종료한다.
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

3. 최종 SQL 본문을 `output\03 설계(SD)\SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 에 **UTF-8 (BOM 없음)** 으로 저장한다.

4. 통계 계산:
   - SEQUENCE / TABLE / PK / UNIQUE / FK / INDEX 건수
   - 파일 크기(KB) / 라인 수

5. 콘솔에 완료 보고를 출력한다(아래 형식 참조).

> 모든 쿼리는 사용자가 지정한 `schema` (기본 `public`) 안의 객체로 한정한다.
> `pg_dump` 의 출력과 100% 동일하지는 않지만, 동일 구조를 재현하기 위한 핵심 DDL은 모두 포함된다.

---

### 4단계 — 임시 파일 정리 (필수)

3단계가 성공적으로 끝나면 비밀번호 노출을 막기 위해 `tmp\` 폴더를 **반드시** 삭제한다.

Bash 도구를 통해 호출할 때는:

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\';
Remove-Item -Recurse -Force \"$DocRoot\output\03 설계(SD)\tmp\"
"
```

- `tmp\db_target.json` 에는 DB 비밀번호가 평문으로 저장되므로 보관하지 않는다.
- 3단계가 실패한 경우(연결 실패 등)에는 디버깅을 위해 `tmp\` 를 그대로 두고, 사용자에게 원인을 보고한다.
- 삭제 결과(성공/실패)를 사용자에게 한 줄로 보고한다.

---

## 완료 체크리스트

- [ ] 입력(디렉토리 / 고객사명) 확정
- [ ] `python --version` 으로 Python 3 설치 확인
- [ ] `psycopg2` import 가능 확인 (없으면 `pip install --user psycopg2-binary`)
- [ ] `tmp\db_candidates.json` 생성 — PostgreSQL 후보 1건 이상
- [ ] 사용자가 후보 1개 확정 (`tmp\db_target.json` 저장, password 보강)
- [ ] DB 연결 성공
- [ ] `output\03 설계(SD)\SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql` 생성
- [ ] SEQUENCES / TABLES / PRIMARY KEY / UNIQUE / FOREIGN KEY / INDEXES 6개 섹션 모두 출력
- [ ] `tmp\` 삭제 완료 (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ DB Schema DDL 생성 완료 [SD_333]

대상 디렉토리: {디렉토리경로}
고객사:        {고객사명}
DB:            postgresql {host}:{port}/{database} (schema={schema}, version={server_version})
실행 환경:     Windows PowerShell {PSVersion} / Python {버전} / psycopg2 {버전}

DDL 현황:
  - SEQUENCE    : N 건
  - TABLE       : N 건
  - PRIMARY KEY : N 건
  - UNIQUE      : N 건
  - FOREIGN KEY : N 건
  - INDEX       : N 건

출력 파일: output\03 설계(SD)\SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql
파일 크기: {N} KB ({N} 라인)
```

---

## 주의사항 (Windows 특화)

- **PowerShell 실행 정책:** 시스템 정책이 `Restricted` 면 스크립트 실행이 막힐 수 있다. Bash 도구로 `powershell.exe` 호출 시 `-ExecutionPolicy Bypass` 를 함께 지정한다.
- **`python` vs `py`:** Windows에서는 `python` 또는 `py -3` 중 하나로 호출해야 한다. 우선 `python --version` 으로 확인하고, 실패하면 `py -3 --version` 으로 재시도한다.
- **한글 콘솔 출력 깨짐:** PowerShell 콘솔이 cp949면 한글이 깨질 수 있다. 실행 전에 한 번 다음 명령으로 UTF-8 모드로 전환한다.
  ```powershell
  $env:PYTHONUTF8 = "1"
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  chcp 65001 | Out-Null
  ```
- **경로 공백·한글 처리:** `output\03 설계(SD)` 처럼 공백·한글이 포함된 경로는 반드시 큰따옴표로 감싼다. Python에서는 `pathlib.Path` 가 자동 처리한다.
- **Windows·WSL 경로 자동 변환:** `01_scan_config.py` 가 `/mnt/c/...` ↔ `C:\...` 를 자동 정규화한다.
- **PostgreSQL 전용:** MySQL/MSSQL/Oracle 의 DDL 생성은 v1 범위가 아니다. driver 가 `postgresql` 이 아닌 후보는 1단계에서 자동 제외한다.
- **버전 호환:** psql 클라이언트 버전과 서버 버전이 달라도(예: PG10 ↔ PG15) `psycopg2` 는 동작한다. `pg_dump` 의존성을 피하기 위해 이 스킬을 사용한다.
- **schema 처리:** 사용자가 schema 를 지정하지 않으면 `public` 으로 한정한다. 여러 schema 를 추출하려면 분리해서 여러 번 실행한다.
- **권한 부족:** `pg_catalog` / `information_schema` 조회 권한이 없는 사용자로 접속하면 일부 섹션이 비어버린다. 가급적 owner 또는 superuser 로 접속한다.
- **출력 파일이 이미 존재하면** 사용자에게 덮어쓸지 한 번 확인한 뒤 진행한다.
- **비밀번호 노출 방지:** 4단계에서 `tmp\` 가 자동 삭제되지만, 비정상 종료 시 폴더가 남아 있으면 즉시 수동 삭제한다.
- **함께 보면 좋은 스킬:**
  - 엑셀 테이블정의서 → `/SD_331`
  - 인터랙티브 ERD HTML → `/SD_334`
  - 정적 ERD 뷰어(기존 템플릿 갱신) → `/SD_211`
