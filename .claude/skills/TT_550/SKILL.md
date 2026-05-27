---
name: TT_550
description: 【DB 이관용 SQL 준비물 생성 (실DB 접속, Windows 기본, Python/PS 폴백)】 Windows 네이티브(PowerShell) 환경에서 사용자가 지정한 백엔드 디렉토리의 DB 설정 파일을 자동 스캔해 인하우스 PostgreSQL DB에 접속하고, `COMMENT ON TABLE` 의 `@migrate:` 마커가 달린 테이블만 자동 수집하여 그룹별 INSERT SQL 파일과 메타데이터(manifest.json)를 생성합니다. 산출물은 `output/05 이행(TT)/TT_550_DATA_{고객사명}_{YYMMDD}/` 폴더에 그룹별 `.sql` 파일 + `manifest.json` 으로 떨어지며, 이 폴더는 후속 스킬 /TT_551 의 입력이 됩니다. SQL 파일은 도구 중립적 plain SQL(Flyway 비의존)이라 고객사는 `psql -f` 한 줄로 적용 가능합니다. /TT_550 형식으로 실행하며 백엔드 경로·고객사명·dump 그룹은 실행 시 묻습니다. 실행 모드는 자동 감지: Python+psycopg2 가 있으면 PYTHON 모드(psycopg2로 wire protocol 접속, pg_dump 버전 충돌 무관), 없으면 POWERSHELL 모드(psql/pg_dump --inserts), 둘 다 없으면 에러로 종료합니다. 핵심 설계: (1) AI는 DB에 직접 INSERT/UPDATE 를 쏘지 않고 결정론적 SQL 텍스트만 생성, (2) 매핑은 DB 자체의 COMMENT 에 박혀 있어 외부 YAML/상수 동기화 불필요, (3) 고객사 대상 DB 적용은 옵션으로 마지막에 묻기(기본 No, Yes 시 host 재확인). DB 이관용 SQL 준비물 생성, dump SQL 파일 만들기, 공통코드/마스터 데이터 INSERT 스크립트 만들기, 이관계획서 생성 전 SQL 패키지 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "DB 이관 SQL 만들어줘", "공통코드 데이터 dump 떠줘", "마스터 데이터 INSERT 스크립트", "TT_550 실행해줘", "윈도우에서 DB 데이터 dump", "이관계획서용 SQL 패키지" 라고 말해도 이 스킬을 사용합니다. 단, DDL(스키마) 만 필요하면 /SD_333, DB 이관계획서 엑셀이 필요하면 /TT_551(이 스킬 실행 후 호출)을 사용합니다. Linux/WSL/macOS 환경에서는 /TT_550_BASH 를 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 이관용 SQL 준비물 생성 (실 DB 접속, Windows 기본, Python/PS 폴백) [TT_550]

지정된 백엔드 디렉토리에서 DB 접속 설정을 자동으로 찾아 **인하우스 PostgreSQL DB** 에 접속하고,
**`COMMENT ON TABLE ... IS '@migrate:{순번}_{슬러그} {설명}'`** 마커가 달린 테이블만 수집하여
그룹별 INSERT SQL 파일 + 메타데이터(`manifest.json`) 을 생성한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요.
>
> **이 스킬은 후속 `/TT_551` (이관계획서 엑셀 생성) 의 입력을 만든다.**
> 흐름: `TT_550` (SQL 준비물 + manifest) → `TT_551_WIN` (이관계획서 엑셀)
>
> **설계 원칙 3가지:**
> 1. **AI는 DB에 직접 변경을 쏘지 않는다** — `SELECT` 와 `pg_dump` 로 텍스트만 생성. 사람이 검토 후 `psql -f` 로 적용.
> 2. **매핑은 DB 자체에 박혀 있다** — `pg_description` 의 `@migrate:` 마커가 단일 진실의 원천. 외부 YAML·상수 없음.
> 3. **자동 적용은 옵션** — 사용자가 명시적 Yes + host 재확인 후에만 실행.
>
> **PostgreSQL 전용:** v1 범위. MySQL/MSSQL/Oracle 미지원.
> (DDL 만 필요하면 `/SD_333`.)

> **출력 SQL 은 도구 중립적**: Flyway 헤더·placeholder·checksum 없음.
> 고객사가 Flyway 를 쓰면 파일명을 `V{n}__...` 로 rename해서 본인 마이그레이션 디렉토리에 넣으면 됨.

> **Bash 도구 사용 규칙 (중요):**
> Bash 도구로 명령을 실행할 때는 반드시 다음 패턴 중 하나를 사용한다.
>
> ```
> powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell 명령>"
> ```
> 또는 PowerShell 7+ 이 있다면
> ```
> pwsh -NoProfile -Command "<PowerShell 명령>"
> ```

---

## 사전 준비 (BE 팀 1회, 신규 테이블 추가 시 같이 갱신)

대상 테이블에 `COMMENT ON TABLE` 으로 마커 부여. **컨벤션: `@migrate:{2자리순번}_{영문슬러그} {한글 설명}`**

```sql
COMMENT ON TABLE sm_comm_h    IS '@migrate:01_common_code 공통코드 헤더';
COMMENT ON TABLE sm_comm_d    IS '@migrate:01_common_code 공통코드 디테일';
COMMENT ON TABLE mdm_biz      IS '@migrate:02_biz 사업장 마스터';
COMMENT ON TABLE mdm_biz_biz  IS '@migrate:02_biz 사업장 매핑';
COMMENT ON TABLE mdm_center   IS '@migrate:03_center 센터 마스터';
COMMENT ON TABLE sm_menu      IS '@migrate:07_menu 메뉴';
-- 마커 없는 테이블은 자동 제외 (운영 로그/세션/임시 테이블 등)
```

JPA/Hibernate 6+ 환경이면 코드에서 관리 가능 (`@org.hibernate.annotations.Comment("@migrate:...")`).

**그룹 키 형식**: `{2자리순번}_{영문슬러그}` — 순번이 정렬 순서가 되고, 슬러그는 출력 파일명에 그대로 사용된다.
순번이 같으면 안 됨. 슬러그는 영문 소문자 + 언더스코어만.

---

## 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 우선 사용하고, 부족한 값은 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 백엔드 경로 | DB 접속 설정 파일이 있는 백엔드 프로젝트 루트의 절대경로. Windows·WSL 경로 모두 허용. |
| 고객사명 | 출력 폴더명에 들어감. 한글/공백 가능. 파일명 예약 문자(`<>:"\|?*\\/`)는 자동 `_` 치환. |
| Dump 그룹 (멀티) | 마커 스캔 결과에서 발견된 그룹 중 사용자가 멀티 선택. `AskUserQuestion multiSelect: true`. |
| 자동 적용 여부 | dump 완료 후 묻기. 기본 No. Yes 시 대상 DB 접속정보 별도 입력. |

검증:
- 백엔드 경로가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.
- 마커가 0개면 BE 팀에 마커 등록을 요청한 뒤 종료한다.

---

## 경로 정의 (PowerShell 동적 감지)

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$BeRoot    = Join-Path $Workspace "wms-$ProjCode-be"

$BASE       = $DocRoot
$OUTPUT_DIR = Join-Path $BASE "output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}"
$TMP_DIR    = Join-Path $BASE "output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}\tmp"
$SCRIPTS    = Join-Path $BASE ".claude\skills\TT_550\scripts"
```

산출물 구조:
```
OUTPUT_DIR\
├── 01_common_code.sql        # 그룹별 SQL (선택된 그룹만)
├── 02_biz.sql
├── 07_menu.sql
└── manifest.json             # TT_551_WIN 이 입력으로 읽음
```

> `manifest.json` 은 `tmp\` 삭제 후에도 남는다. 비밀번호는 포함하지 않는다.

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 `New-Item -ItemType Directory -Force` 로 생성.
`{YYMMDD}` 는 오늘 날짜(서버 로컬 시간).

---

## 워크플로우 (8단계)

```
[0] 실행 모드 자동 감지 (PYTHON 우선, POWERSHELL 폴백)
[1] BE 경로 스캔 → DB 접속정보 추출
[2] 사용자 확인 + password 보강
[3] 마커 스캔 → 그룹별 테이블 + FK 의존성 수집
[4] 사용자에게 발견된 그룹 보여주고 멀티 선택
[5] 그룹별 SQL 파일 생성
[6] manifest.json 작성 (TT_551_WIN 이 읽을 메타데이터)
[7] 자동 적용 옵션 (Yes/No, 기본 No)
[8] tmp 정리 (manifest.json 은 보존)
```

```
.claude\skills\TT_550\scripts\
├── _detect_mode.ps1              # 0단계 — 환경 감지 (Python+psycopg2 / pg_dump+psql)
├── _scan_config.py               # 1단계 — BE 경로 파싱 (Python 표준 라이브러리만, 양쪽 모드 공용)
│
├── py\                            # PYTHON 모드 백엔드 (psycopg2)
│   ├── 01_collect_markers.py     # 3단계 — pg_description + FK 조회
│   ├── 02_dump_data.py           # 5단계 — SELECT → INSERT 직렬화
│   └── 03_write_manifest.py      # 6단계 — manifest.json 작성
│
└── ps\                            # POWERSHELL 모드 백엔드 (psql / pg_dump)
    ├── 01_collect_markers.ps1    # 3단계 — psql 호출
    ├── 02_dump_data.ps1          # 5단계 — pg_dump --inserts 호출
    └── 03_write_manifest.ps1     # 6단계 — manifest.json 작성
```

> **BE 스캔은 항상 Python으로 통일**: psycopg2 없이 표준 라이브러리만 사용하므로 PS 모드라도 Python 자체는 필요. `_detect_mode.ps1` 가 Python 부재 시 즉시 에러로 종료한다.

각 모드 스크립트는 **동일한 입출력 계약**을 따른다. SKILL.md 본문은 모드 분기만 처리.

---

### 0단계 — 실행 모드 자동 감지

`scripts\_detect_mode.ps1` 가 다음 순서로 환경을 확인:

| 우선순위 | 조건 | 결정 |
|---|---|---|
| 1 | `python -c "import psycopg2"` 성공 | `PYTHON` 모드 |
| 2 | `pg_dump --version` + `psql --version` 모두 성공 | `POWERSHELL` 모드 |
| 3 | 둘 다 실패 | 에러 종료 + 설치 안내 |

PowerShell:

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

# Python + psycopg2 체크
$pyOk = $false
$pyExe = $null
foreach ($cmd in @("python","py -3")) {
    & cmd /c "$cmd -c `"import psycopg2`"" 2>$null
    if ($LASTEXITCODE -eq 0) { $pyOk = $true; $pyExe = $cmd; break }
}

# PostgreSQL 클라이언트 체크
$pgOk = $false
$PG_BIN = (Get-Item "C:\Program Files\PostgreSQL\*\bin" -ErrorAction SilentlyContinue |
           Sort-Object Name -Descending | Select-Object -First 1).FullName
$pgDump = if ($PG_BIN) { "$PG_BIN\pg_dump.exe" } else { (Get-Command pg_dump -ErrorAction SilentlyContinue).Source }
$psql   = if ($PG_BIN) { "$PG_BIN\psql.exe"    } else { (Get-Command psql    -ErrorAction SilentlyContinue).Source }
if ($pgDump -and $psql) { $pgOk = $true }

if     ($pyOk) { $mode = "PYTHON" }
elseif ($pgOk) { $mode = "POWERSHELL" }
else {
    Write-Host "ERROR: TT_550 실행을 위해 다음 중 하나가 필요합니다:" -ForegroundColor Red
    Write-Host "  [A] Python 3 + psycopg2-binary  (권장)"
    Write-Host "      → pip install --user psycopg2-binary"
    Write-Host "  [B] PostgreSQL 클라이언트 (psql.exe + pg_dump.exe)"
    Write-Host "      → https://www.postgresql.org/download/windows/"
    exit 1
}

Write-Host "[TT_550] 실행 모드: $mode" -ForegroundColor Cyan
```

모드와 도구 경로는 `$TMP_DIR\mode.json` 에 저장.

---

### 1단계 — BE 경로 스캔 (양쪽 모드 공용)

**스크립트**: `scripts\_scan_config.py` (Python 표준 라이브러리만 사용, psycopg2 불필요)
**입력**: 백엔드 경로
**출력**: `tmp\db_candidates.json`

호출:
```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
python "$DocRoot\.claude\skills\TT_550\scripts\_scan_config.py" "{BE경로}" "{출력 json 경로}"
```

아래 패턴 파일을 재귀로 찾아 후보를 모은다.

| 패턴 | 추출 키 |
|---|---|
| `application.properties` / `application-*.properties` (Spring) | `spring.datasource.*`, `db.url/username/password` |
| `application.yml` / `application.yaml` / `application-*.yml` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `.env`, `.env.*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL` |
| `docker-compose.yml` | `services.*.environment` (POSTGRES_USER, POSTGRES_DB 등) |

JDBC URL 파싱:
- `jdbc:log4jdbc:postgresql://host:port/db` → `log4jdbc:` 프리픽스 제거 후 host/port/db 추출
- `jdbc:postgresql://host:port/db?currentSchema=xxx` → schema 파라미터도 함께 추출

**중복 후보 제거 규칙**: `(driver, host, port, database)` 조합이 같으면 같은 후보로 간주. user/password는 더 풍부한 쪽 채택.

**PostgreSQL 외 driver**(mysql/mssql/oracle)는 후보에서 제외.

---

### 2단계 — 사용자 확인 및 password 보강

`db_candidates.json` 을 Read 도구로 열어 후보 확인:

1. **후보 0개** → `AskUserQuestion` 으로 host/port/database/user/password/schema 직접 입력.
2. **후보 1개** → 사용자에게 확인 + password 누락 시 입력 요청.
3. **후보 2개 이상** → `AskUserQuestion` 으로 선택.

확정 정보는 `tmp\db_target.json` 으로 저장.

> **보안 경고**: `tmp\db_target.json` 은 password 평문 저장. 8단계에서 자동 삭제하지만 비정상 종료 시 즉시 수동 삭제.

---

### 3단계 — 마커 스캔 + FK 의존성 수집

**스크립트 (모드별)**:
- `PYTHON`: `scripts\py\01_collect_markers.py`
- `POWERSHELL`: `scripts\ps\01_collect_markers.ps1`

**입력**: `tmp\db_target.json`
**출력**: `tmp\markers.json`

핵심 쿼리 1: `@migrate:` 마커 수집

```sql
SELECT
    c.relname                                                                AS table_name,
    obj_description(c.oid, 'pg_class')                                       AS comment,
    substring(obj_description(c.oid, 'pg_class') FROM '@migrate:(\S+)')      AS group_key,
    trim(substring(obj_description(c.oid, 'pg_class') FROM '@migrate:\S+\s+(.*)$'))
                                                                             AS table_desc,
    c.reltuples::bigint                                                      AS approx_rows
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = $1
  AND c.relkind = 'r'
  AND obj_description(c.oid, 'pg_class') LIKE '@migrate:%'
ORDER BY group_key, table_name;
```

핵심 쿼리 2: 같은 그룹 안의 FK 의존성 (DELETE 역순 / INSERT 정순 결정용)

```sql
SELECT
    conrelid::regclass::text  AS child_table,
    confrelid::regclass::text AS parent_table
FROM pg_constraint
WHERE contype = 'f'
  AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = $1)
  AND conrelid::regclass::text  = ANY($2::text[])
  AND confrelid::regclass::text = ANY($2::text[]);
```

추가 휴리스틱: `sm_*` / `mdm_*` prefix 인데 마커 없는 테이블은 **콘솔 경고만** 출력 (dump 대상 X).

`markers.json` 스키마:
```json
{
  "schema": "public",
  "server_version": "15.4",
  "groups": [
    {
      "group_key": "01_common_code",
      "group_desc": "공통코드",
      "tables": [
        { "name": "sm_comm_h", "desc": "공통코드 헤더",   "approx_rows": 12 },
        { "name": "sm_comm_d", "desc": "공통코드 디테일", "approx_rows": 87 }
      ],
      "fk_edges": [
        { "child": "sm_comm_d", "parent": "sm_comm_h" }
      ],
      "insert_order": ["sm_comm_h", "sm_comm_d"],
      "delete_order": ["sm_comm_d", "sm_comm_h"]
    }
  ],
  "warnings": {
    "unmarked_master_tables": ["sm_legacy_temp", "mdm_obsolete"]
  }
}
```

> **FK 순환 의존성**: 토폴로지 정렬 실패 시 `insert_order` 에 `null` 을 넣고 콘솔에 경고. 사용자에게 수동으로 순서 입력받거나 해당 그룹 skip.

---

### 4단계 — 사용자에게 발견 그룹 표시 + 멀티 선택

콘솔 출력 형식:
```
[TT_550] @migrate 마커 스캔 결과
  발견된 그룹 6개 / 테이블 14개 (PostgreSQL 15.4)

  [01_common_code] 공통코드           (2 tables, ~99 rows)
     • sm_comm_h     공통코드 헤더    ~12
     • sm_comm_d     공통코드 디테일  ~87

  [02_biz] 사업장                    (2 tables, ~11 rows)
     • mdm_biz       사업장 마스터    ~3
     • mdm_biz_biz   사업장 매핑      ~8

  [07_menu] 메뉴                     (1 tables, ~142 rows)
     • sm_menu       메뉴             ~142

  ⚠ 마커 없는 sm_/mdm_ 테이블 2개 발견 (혹시 누락?):
     • sm_legacy_temp
     • mdm_obsolete
```

`AskUserQuestion` `multiSelect: true` 로 그룹 선택 결과 → `tmp\selected_groups.json`

---

### 5단계 — 그룹별 SQL 파일 생성

**스크립트 (모드별)**:
- `PYTHON`: `scripts\py\02_dump_data.py`
- `POWERSHELL`: `scripts\ps\02_dump_data.ps1`

**입력**: `tmp\db_target.json`, `tmp\markers.json`, `tmp\selected_groups.json`, 고객사명
**출력**: `OUTPUT_DIR\{group_key}.sql` (선택된 그룹마다 1개씩)

#### PYTHON 모드 (psycopg2 직접 직렬화)

각 그룹에 대해:
1. `markers.json` 에서 `insert_order` / `delete_order` 읽기
2. 헤더 + `SET` + `BEGIN;` 작성
3. `delete_order` 순서로 `DELETE FROM ...` 추가
4. `insert_order` 순서로 각 테이블:
   - `cur.execute(f'SELECT * FROM "{schema}"."{table}"')`
   - `information_schema.columns` 로 컬럼명·타입 조회
   - 행별로 `INSERT INTO "..." ("c1","c2") VALUES (...)` 텍스트 생성
   - 타입별 직렬화: NULL, 문자열 이스케이프, boolean, date/timestamp, bytea, json/jsonb, array
5. `COMMIT;` + 검증 쿼리 추가

#### POWERSHELL 모드 (pg_dump 호출)

각 그룹에 대해:
1. 헤더 + `SET` + `BEGIN;` 작성 → `Set-Content`
2. `delete_order` 순서로 `DELETE FROM ...` 추가 → `Add-Content`
3. 그룹 테이블 전체에 대해 `pg_dump` 1회 호출:
   ```powershell
   $tableArgs = $insertOrder | ForEach-Object { '-t', "$schema.$_" }
   $env:PGPASSWORD = $db.password
   & $pgDump -h $db.host -p $db.port -U $db.user -d $db.database `
             --data-only --inserts --column-inserts `
             --no-owner --no-privileges `
             --rows-per-insert=1 `
             @tableArgs |
       Where-Object { $_ -notmatch '^(SET |--|\s*$)' } |
       Add-Content $outFile
   ```
4. `COMMIT;` + 검증 쿼리 → `Add-Content`

#### 출력 SQL 파일 형식 (양쪽 모드 동일)

```sql
-- =============================================================
-- TT_550: 01_common_code (공통코드)
-- 고객사:     {고객사명}
-- 생성일시:   2026-05-12 14:33:21
-- 실행 모드:  PYTHON (psycopg2 3.1.18)
-- 원본 DB:   192.168.10.20:5432/wms-cloud-test (schema=public, PG 15.4)
-- 대상 테이블: sm_comm_h, sm_comm_d
-- 적용 방법: psql -h <host> -U <user> -d <db> -f 01_common_code.sql
-- =============================================================
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
BEGIN;

-- FK 역순 DELETE
DELETE FROM "public"."sm_comm_d";
DELETE FROM "public"."sm_comm_h";

-- FK 정순 INSERT
INSERT INTO "public"."sm_comm_h" ("comm_h_cd","comm_h_nm","use_yn") VALUES ('USE_YN','사용여부','Y');
-- ... (12 rows)

INSERT INTO "public"."sm_comm_d" ("comm_h_cd","comm_d_cd","comm_d_nm") VALUES ('USE_YN','Y','사용');
-- ... (87 rows)

COMMIT;

-- 적용 후 검증
SELECT 'sm_comm_h' AS tbl, COUNT(*) FROM "public"."sm_comm_h"
UNION ALL
SELECT 'sm_comm_d', COUNT(*) FROM "public"."sm_comm_d";
```

---

### 6단계 — manifest.json 작성 (TT_551_WIN 입력)

**스크립트 (모드별)**:
- `PYTHON`: `scripts\py\03_write_manifest.py`
- `POWERSHELL`: `scripts\ps\03_write_manifest.ps1`

**입력**: `tmp\markers.json`, `tmp\selected_groups.json`, 생성된 SQL 파일들, 모드 정보
**출력**: `OUTPUT_DIR\manifest.json` ← **이 파일은 8단계 tmp 정리 후에도 보존**

각 그룹/테이블의 **실제 row count** 는 5단계에서 dump 직전 `SELECT COUNT(*)` 로 측정한 값을 사용 (approx_rows 가 아닌 정확한 값).

`manifest.json` 스키마:
```json
{
  "skill": "TT_550",
  "version": "1",
  "generated_at": "2026-05-12T14:33:21+09:00",
  "mode": "PYTHON",
  "tool_versions": {
    "python": "3.11.5",
    "psycopg2": "3.1.18",
    "pg_dump": null
  },
  "customer": "가나다물류",
  "source_db": {
    "host": "192.168.10.20",
    "port": 5432,
    "database": "wms-cloud-test",
    "schema": "public",
    "pg_version": "15.4"
  },
  "groups": [
    {
      "group_key": "01_common_code",
      "group_desc": "공통코드",
      "sql_file": "01_common_code.sql",
      "file_size_kb": 8.2,
      "tables": [
        { "name": "sm_comm_h", "desc": "공통코드 헤더",   "rows": 12 },
        { "name": "sm_comm_d", "desc": "공통코드 디테일", "rows": 87 }
      ],
      "insert_order": ["sm_comm_h", "sm_comm_d"],
      "delete_order": ["sm_comm_d", "sm_comm_h"]
    }
  ],
  "warnings": {
    "unmarked_master_tables": ["sm_legacy_temp", "mdm_obsolete"]
  },
  "applied_to_target_db": null
}
```

> **보안**: password / user 정보는 manifest에 포함하지 않는다. host/database/schema 까지만.
> Yes 로 자동 적용한 경우 `applied_to_target_db` 에 적용된 host/database (password 제외)와 적용 시각·결과 row count 가 기록된다.

---

### 7단계 — 대상 DB 자동 적용 (옵션, 기본 No)

5·6단계 성공 직후 `AskUserQuestion` 으로 묻기:

```
방금 생성된 SQL 파일을 고객사 대상 DB에 지금 자동 적용할까요?
  A) No, dump만 하고 종료 (권장)
  B) Yes, 대상 DB 접속 정보를 입력하고 적용
```

**기본 No.** No 선택 시 8단계로 진행.

**Yes 를 선택한 경우:**
1. `AskUserQuestion` 으로 대상 DB host/port/database/user/password/schema 입력.
2. **인하우스 DB host 와 동일하면 즉시 중단** + 경고 메시지.
3. 콘솔에 대상 DB 정보 출력 후 `Y/n` 으로 최종 확정.
4. 선택된 그룹의 SQL 파일을 group_key 순번 순서로 적용:
   - `PYTHON` 모드: psycopg2 로 파일 통째 실행. 파일 1개 = 1 트랜잭션. 실패 시 ROLLBACK + 중단.
   - `POWERSHELL` 모드: `psql -v ON_ERROR_STOP=1 -1 -f file.sql`.
5. 각 파일 적용 후 검증 쿼리 결과를 콘솔에 출력. 인하우스 row count 와 비교 가능.
6. `manifest.json` 에 `applied_to_target_db` 정보 갱신.

> **위험 경고:** 적용은 비가역. host 재확인 + 동일 host 차단을 반드시 거친다.

---

### 8단계 — 임시 파일 정리 (manifest.json 은 보존)

5·6단계(또는 7단계) 성공 시 `tmp\` 폴더 **반드시** 삭제. **단, `OUTPUT_DIR\manifest.json` 은 유지.**

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Remove-Item -Recurse -Force "$DocRoot\output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}\tmp"
```

- `tmp\db_target.json` 에는 DB 비밀번호가 평문 저장되므로 보관 금지.
- 실패 시(연결 실패 등) 디버깅 위해 `tmp\` 그대로 두고 사용자에게 보고.
- 삭제 결과(성공/실패)를 한 줄로 보고.

---

## 완료 체크리스트

- [ ] 입력(백엔드 경로 / 고객사명) 확정
- [ ] 실행 모드 자동 감지 (`PYTHON` / `POWERSHELL`)
- [ ] `tmp\db_candidates.json` 생성 — PostgreSQL 후보 1건 이상
- [ ] 사용자가 후보 1개 확정 (`tmp\db_target.json` 저장, password 보강)
- [ ] 인하우스 DB 연결 성공
- [ ] `tmp\markers.json` 생성 — `@migrate:` 마커 그룹 1개 이상
- [ ] 사용자가 dump 그룹 멀티 선택 (`tmp\selected_groups.json`, 1개 이상)
- [ ] 선택된 그룹별로 `OUTPUT_DIR\{group_key}.sql` 생성
- [ ] **`OUTPUT_DIR\manifest.json` 생성 (TT_551_WIN 입력용)**
- [ ] 자동 적용 옵션 질문 → 응답에 따라 처리 (Yes 시 host 재확인)
- [ ] `tmp\` 삭제 완료 (`manifest.json` 은 보존)

---

## 완료 보고 형식

```
✓ DB 이관 SQL 준비물 생성 완료 [TT_550]

실행 모드:    PYTHON (psycopg2 3.1.18)
백엔드 경로:  C:\zinide\workspace\wms-cloud-be
고객사:       {고객사명}
인하우스 DB:  postgresql 192.168.10.20:5432/wms-cloud-test (schema=public, PG 15.4)

Dump 결과 (3 groups, 5 tables, 244 rows):
  [01_common_code] 공통코드   sm_comm_h(12) + sm_comm_d(87)       → 01_common_code.sql (8.2 KB)
  [02_biz]         사업장     mdm_biz(3) + mdm_biz_biz(8)         → 02_biz.sql        (1.4 KB)
  [07_menu]        메뉴       sm_menu(142)                         → 07_menu.sql       (24 KB)

⚠ 마커 없는 sm_/mdm_ 테이블 2개 발견 (확인 필요):
  - sm_legacy_temp
  - mdm_obsolete

출력 폴더:    output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}\
파일 개수:    4 개 (.sql 3 + manifest.json 1, 전체 33.6 KB)

대상 DB 자동 적용: 미실행 (사용자 No 선택)

다음 단계:
  → /TT_551 실행 시 위 출력 폴더를 입력으로 받아 DB 이관계획서 엑셀을 생성합니다.
  → 고객사 적용: psql -h <고객사호스트> -U <user> -d <db> -f 01_common_code.sql
                (group_key 순번 순서대로 적용)
```

---

## 주의사항 (Windows 특화)

- **PowerShell 실행 정책:** `Restricted` 면 `powershell.exe -ExecutionPolicy Bypass` 사용.
- **`python` vs `py`:** Windows에서는 0단계에서 자동 선택.
- **한글 콘솔 출력 깨짐:** UTF-8 모드 전환:
  ```powershell
  $env:PYTHONUTF8 = "1"
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  chcp 65001 | Out-Null
  ```
- **경로 공백·한글 처리:** `output\05 이행(TT)` 처럼 공백·한글 포함 경로는 반드시 큰따옴표.
- **POWERSHELL 모드의 pg_dump 버전 충돌:** 클라이언트 ≥ 서버 필요. PG 버전 격차가 크면 `PYTHON` 모드 사용 권장.
- **PostgreSQL 전용:** MySQL/MSSQL/Oracle 미지원.
- **schema 처리:** 미지정 시 `public` 으로 한정.
- **권한 부족:** 일부 테이블 SELECT 불가 시 해당 테이블만 skip + 완료 보고에 명시.
- **출력 폴더가 이미 존재하면:** 사용자에게 덮어쓸지 한 번 확인.
- **비밀번호 노출 방지:** 8단계에서 `tmp\` 자동 삭제. 비정상 종료 시 즉시 수동 삭제.
- **자동 적용은 비가역:** Yes 선택 시 host 재확인 + 인하우스/대상 동일 host 차단 필수.
- **함께 보면 좋은 스킬:**
  - DB 이관계획서 엑셀 → `/TT_551` (이 스킬 실행 후 호출)
  - DDL(스키마) SQL → `/SD_333`
  - 공통코드정의서 엑셀 → `/SD_332`
