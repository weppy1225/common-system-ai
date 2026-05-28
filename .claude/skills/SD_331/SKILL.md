---
name: SD_331
description: 【테이블정의서 엑셀 생성 (실DB 접속, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 직접 접속하고, 시스템 카탈로그에서 스키마를 추출하여 SD.212-테이블정의서 엑셀 파일을 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /SD_331 {디렉토리경로} 형식으로 실행합니다. 기존 /SD_212(테이블 MD 파싱)와 /SD_212_DDL(DDL 파일 파싱)과 달리, 살아있는 DB에 직접 붙어 information_schema/pg_catalog/sys.*/user_* 등을 조회해 테이블·컬럼·인덱스·제약조건·FK를 뽑아낸다는 점이 다릅니다. 사용자가 "DB에서 직접 테이블정의서 뽑아줘", "라이브 DB 스키마 엑셀로", "운영 DB 접속해서 테이블 명세서", "DB 카탈로그 추출", "SD_331 실행해줘", "WSL에서 테이블정의서 뽑아줘", "Linux에서 라이브 DB 스키마 엑셀로" 라고 말하면 이 스킬을 사용합니다. 단, 사용자가 단순히 "테이블정의서 만들어줘"라고만 말하고 DB 접속을 원치 않는 정황(MD 파일이나 DDL 파일을 언급)이면 /SD_212나 /SD_212_DDL 쪽이 맞을 수 있으니, 입력 소스(MD/DDL/실DB)를 먼저 확인하여 분기합니다.
allowed-tools: Bash, PowerShell, Read, Write, Edit, AskUserQuestion
---

# 테이블정의서 자동 생성 (실 DB 접속, Windows/WSL/Linux/Mac 통합) [SD_331]

대상 디렉토리: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리에서 DB 접속 설정 파일을 자동 스캔하고, 검출된 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 **직접 접속**하여 시스템 카탈로그(information_schema/pg_catalog/sys.*/user_*)에서 스키마(테이블·컬럼·인덱스·제약조건·FK)를 추출한 뒤,
`template/03 설계(SD)/SD.212-테이블정의서.xlsx` 템플릿을 기반으로
`output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx` 파일을 생성한다.

> 같은 산출물을 만드는 다른 명령:
> - `/SD_212` — BE 프로젝트 내 테이블 MD 파일을 파싱해서 생성 (DB 접속 없음)
> - `/SD_212_DDL` — DDL SQL 파일을 파싱해서 생성 (DB 접속 없음)
> 이 스킬(`/SD_331`)은 살아있는 DB에 직접 붙어 카탈로그 조회로 추출한다.

> **클라이언트 도구 불필요**: psql/mysql/sqlcmd/sqlplus 같은 OS 클라이언트가 설치되지 않은 환경을 가정한다. Python 라이브러리(psycopg2-binary / pymysql / pymssql / oracledb)만으로 직접 접속한다. 라이브러리는 필요할 때 `pip install --user`로 자동 설치한다.

---

## OS 분기 — 가장 먼저 실행

스킬 시작 시 환경 변수 `OS` / `uname` 로 실행 환경을 판별하고, 이후 단계에서 **해당 OS 섹션의 블록만** 실행한다.

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 명령 없음
  → [Windows 섹션]의 PowerShell 블록 사용. `PowerShell` 도구 또는 `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "..."` 패턴.
- WSL / Linux / macOS (Bash):    uname 명령 존재 (Linux/Darwin)
  → [Bash 섹션]의 bash 블록 사용. `Bash` 도구 그대로 사용.
```

> 두 섹션의 로직(디렉토리 스캔 → 후보 확정 → 의존성 확인 → DB 접속 → 스키마 추출 → 엑셀 생성 → tmp 삭제)은 동일하며, OS 셸 문법만 다르다. Python 스크립트(`scripts/*.py`)는 양쪽에서 그대로 공유한다.

---

## 사전 준비 (공통)

### 인자 확정

`$ARGUMENTS`가 비어 있으면 사용자에게 디렉토리 경로를 물어본다. 비어 있지 않더라도 경로가 존재하지 않으면 다시 물어본다.

### 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
TEMPLATE   = template/03 설계(SD)/SD.212-테이블정의서.xlsx
OUTPUT_DIR = output/03 설계(SD)
TMP_DIR    = output/03 설계(SD)/tmp
SCRIPTS    = .claude/skills/SD_331/scripts
```

`OUTPUT_DIR`과 `TMP_DIR`이 없으면 생성한다.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$BeRoot    = Join-Path $Workspace "wms-$ProjCode-be"
```

### W-1) 디렉토리 스캔으로 DB 접속정보 후보 추출

**스크립트**: `scripts/01_scan_config.py`
**입력**: 사용자 지정 디렉토리 경로
**출력**: `output/03 설계(SD)/tmp/db_candidates.json`

```powershell
Set-Location $DocRoot
python .claude/skills/SD_331/scripts/01_scan_config.py "{디렉토리경로}"
```

### W-2) 사용자 확인 및 누락 정보 보강

`db_candidates.json` 을 Read 툴로 읽어 후보 목록을 확인한다.

1. **후보가 0개**: AskUserQuestion으로 DB 종류와 접속정보(host, port, database, user, password)를 직접 입력받아 가상의 후보 1개를 만든다.
2. **후보가 1개**: 사용자에게 해당 정보로 진행할지, password가 누락되었으면 password를 입력할지 묻는다.
3. **후보가 2개 이상**: AskUserQuestion으로 어떤 후보를 사용할지 선택받는다.

선택된 후보의 password가 비어 있다면 **AskUserQuestion으로 password를 별도 질문한다.**

확정된 접속정보를 `output/03 설계(SD)/tmp/db_target.json`로 저장한다.

### W-3) 의존성 확인 및 자동 설치

```powershell
python .claude/skills/SD_331/scripts/02_extract_schema.py --check-only
```

누락된 라이브러리를 `python -m pip install --user <pkg>`로 설치한 뒤 재검증.

### W-4) DB 접속 및 스키마 추출

```powershell
python .claude/skills/SD_331/scripts/02_extract_schema.py
```

**출력**: `output/03 설계(SD)/tmp/schema.json`

### W-5) Excel 생성

```powershell
python .claude/skills/SD_331/scripts/03_generate_excel.py
```

**출력**: `output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx`

### W-6) 임시 파일 정리 (필수)

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
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"

TEMPLATE="$DOC_ROOT/template/03 설계(SD)/SD.212-테이블정의서.xlsx"
OUTPUT_DIR="$DOC_ROOT/output/03 설계(SD)"
TMP_DIR="$DOC_ROOT/output/03 설계(SD)/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/SD_331/scripts"
```

### B-1) 디렉토리 스캔으로 DB 접속정보 후보 추출

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_331/scripts/01_scan_config.py "{디렉토리경로}"
```

### B-2) 사용자 확인 및 누락 정보 보강

(W-2 와 동일 — `tmp/db_candidates.json` Read → 후보 확정 → `tmp/db_target.json` 저장)

### B-3) 의존성 확인 및 자동 설치

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_331/scripts/02_extract_schema.py --check-only
```

누락된 라이브러리를 `python3 -m pip install --user <pkg>`로 설치한 뒤 재검증.

### B-4) DB 접속 및 스키마 추출

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_331/scripts/02_extract_schema.py
```

### B-5) Excel 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_331/scripts/03_generate_excel.py
```

### B-6) 임시 파일 정리 (필수)

```bash
rm -rf "$DOC_ROOT/output/03 설계(SD)/tmp"
```

---

## 스캔 대상 파일 패턴 (공통, Python 스크립트가 처리)

| 패턴 | 추출 키 |
|---|---|
| `*.env`, `.env*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL`, `DB_DRIVER`, `DB_DIALECT` 등 |
| `application.yml` / `application.yaml` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `application.properties` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `database.yml` (Rails) | `adapter`, `host`, `port`, `database`, `username`, `password` |
| `settings.py` (Django) | `DATABASES['default']` |
| `knexfile.js` / `knexfile.ts` | `client`, `connection` |
| `appsettings*.json` (.NET) | `ConnectionStrings.*` |
| `web.config` (.NET) | `<connectionStrings>` |
| `config.json` / `db.config.json` / `database.json` 등 일반 JSON | host/port/database/user/password 키 자동 인식 |
| `docker-compose.yml` / `docker-compose.yaml` | `services.*.environment` (POSTGRES_USER 등) |
| `prisma/schema.prisma` | `datasource db { url = ... }` |

**중복 후보 제거 규칙**: `(driver, host, port, database)` 조합이 동일하면 같은 후보로 간주한다. user/password는 더 풍부한 쪽을 채택한다.

---

## db_target.json 스키마 (공통)

```json
{
  "driver": "postgresql",
  "host": "localhost",
  "port": 5432,
  "database": "wms_db",
  "user": "wms",
  "password": "...",
  "schema": "public"
}
```

> `driver` 값은 `postgresql` / `mysql` / `mssql` / `oracle` 중 하나로 정규화한다. (`mariadb` → `mysql`, `postgres` → `postgresql`, `sqlserver` / `mssql` 모두 → `mssql`)

> `schema` 는 PostgreSQL/MSSQL에서 의미 있다. 없으면 PostgreSQL은 `public`, MSSQL은 `dbo`, MySQL은 database 자체, Oracle은 사용자명 대문자로 둔다.

---

## 의존성 매핑 (공통)

| driver | Python 라이브러리 | 설치 명령 (Win/Bash 공통, `python`/`python3` 만 차이) |
|---|---|---|
| postgresql | psycopg2 | `pip install --user psycopg2-binary` |
| mysql | pymysql | `pip install --user pymysql` |
| mssql | pymssql | `pip install --user pymssql` |
| oracle | oracledb | `pip install --user oracledb` |
| (공통) | openpyxl | `pip install --user openpyxl` |

---

## 5단계 Excel 생성 상세 (공통)

`scripts/03_generate_excel.py`가 수행하는 일:

1. 템플릿 복사본 작성.
2. 첫 번째 테이블 시트(MDM_사업장)를 **블루프린트**로 사용. 데이터 행을 비우고 헤더·섹션 라벨만 남긴 뒤, 시트 이름을 `__BLUEPRINT__`로 변경.
3. 다른 모든 샘플 테이블 시트 삭제.
4. `Table List` 시트 데이터 행(3행 이후) 전부 삭제. 헤더는 유지.
5. 추출된 schema의 테이블마다:
   - `wb.copy_worksheet(__BLUEPRINT__)`로 새 시트 생성, 시트명 = logical table name (Excel 시트명 31자 제한 고려해 잘라쓰되 충돌 시 인덱스 부여).
   - Table info 채움: System Name(DB명), Schema Name, Logical Table Name, Pyshical Table Name, Author(현재 OS 사용자), Created On(오늘), RDBMS(driver).
   - Column info: 추출된 컬럼 채움. 행이 부족하면 `insert_rows`로 확장.
   - Index info / Constraint info / FK info / FK info (PK Side): 각 섹션별 동일한 방식.
6. `Table List` 시트 채움: No, Logical Table Name, Pyshical Table Name, Remark(테이블 comment).
7. `__BLUEPRINT__` 시트 삭제.
8. 최종 파일 저장.

---

## 완료 체크리스트 (공통)

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리 확정
- [ ] `tmp/db_candidates.json` 생성 (스캔 결과)
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장)
- [ ] 누락된 password 확인 후 보강
- [ ] 필요한 Python 라이브러리 import 가능 (`--check-only` 통과)
- [ ] DB 연결 성공 및 `tmp/schema.json` 생성
- [ ] 출력 파일 `output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx` 생성
- [ ] Table List 시트 + 테이블별 시트가 모두 존재
- [ ] 샘플 데이터(MDM_사업장 등)가 결과 파일에 남지 않음
- [ ] **`output/03 설계(SD)/tmp/` 폴더 삭제 완료** (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ 테이블정의서 생성 완료 [SD_331]

실행 환경:   Windows PowerShell   또는   Bash on Linux/Mac/WSL
대상 디렉토리: {디렉토리경로}
DB: {driver} {host}:{port}/{database} (schema={schema})
출력파일: output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx

수집 통계:
  - 테이블:     N개
  - 컬럼:       N개
  - 인덱스:     N개
  - 제약조건:   N개
  - FK:         N개

스캔된 설정 파일: {파일 목록}
```

---

## 주의사항 (공통)

- **비밀번호 노출**: AskUserQuestion으로 받은 비밀번호는 `tmp/db_target.json`에 평문으로 저장된다. **마지막 단계에서 `tmp/` 폴더를 자동 삭제**하므로 별도 안내 없이 정리되지만, 작업이 비정상 종료되어 폴더가 남아 있으면 즉시 수동 삭제한다.
- **대형 DB 보호**: 테이블 수가 1000개를 넘으면 진행 전에 사용자에게 한 번 확인한다(완료 시간이 길고 결과 파일이 커진다).
- **Excel 시트명 제한**: 31자, `: \ / ? * [ ]` 사용 불가. 자동으로 안전한 형태로 변환한다.
- **시트명 중복**: logical name이 같은 테이블이 둘 이상이면 `_2`, `_3` … 접미사를 붙인다.
- **권한 부족**: 시스템 카탈로그 조회 권한이 없으면 일부 정보(예: comment, FK)가 누락될 수 있다. 누락되면 빈 값으로 두고 나머지를 채운다.

### Windows 특화

- **Python 실행 명령**: `python` (PATH에 등록된 Windows Python). `py -3` 도 가능.
- **경로 구분자**: PowerShell은 `\` 와 `/` 모두 허용. `Join-Path` 사용을 권장.
- **한글 콘솔 깨짐**: `[Console]::OutputEncoding = [Text.UTF8Encoding]::new()` 로 UTF-8 강제.
- **pip --user 위치**: `%APPDATA%\Python\Python3X\Scripts` — PATH 추가 안내가 필요할 수 있음.

### Bash 특화

- **Python 실행 명령**: `python3` (WSL/Linux/macOS 기본).
- **pip --user 위치**: `~/.local/bin` — PATH 추가 안내가 필요할 수 있음.
- **WSL 경로**: Windows 드라이브는 `/mnt/c/...` 형태. `wslpath` 명령으로 변환 가능.
