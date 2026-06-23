---
name: db-psql
description: >
  PostgreSQL DB를 psql로 직접 조회할 때 사용하는 접속 정보 동적 로딩과 실행 패턴.
  "psql로 조회", "DB에서 확인", "DB 직접 조회", "테스트 데이터 조회", "테스트 데이터 찾아줘",
  "DB에서 확인해줘", "상품번호 조회", "주문번호 찾아줘", "테이블 구조 확인" 등 개발·테스트 중
  DB를 직접 확인해야 할 때 반드시 이 스킬을 사용한다. 사용자가 "psql"을 명시하지 않아도
  DB 데이터를 확인하거나 테스트용 번호를 조회하는 맥락이면 자동으로 이 스킬을 참조한다.
  주의: 대상은 PostgreSQL만이다. ERP DB는 SQL Server라 psql 대상이 아니다.
---
# DB psql 조회 스킬

## 1. psql 실행 환경 (MUST)

| 항목 | 값 |
| ---- | ---- |
| psql 경로 | `C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe` |
| 실행 도구 | **PowerShell 도구** (Bash 도구에서는 psql 못 찾음) |
| 대상 DB | 현재 워크스페이스 BE 레포의 `application-dev.properties` 기준 |

MUST: psql 은 **PowerShell 도구**로 실행한다. Bash 도구에는 psql 이 PATH 에 없다.

## 2. 접속 정보 동적 로딩 (MUST — 실행 전 항상 수행)

접속 정보(host·port·dbname·user·password)는 스킬에 하드코딩하지 않는다.
**매번 실행 직전** 아래 순서로 BE 레포의 `application-dev.properties` 에서 읽는다.

### Step 0 — BE 레포 경로 탐색 (repo-paths.md 규칙)

```powershell
$AI_DIR = & "C:\Program Files\Git\cmd\git.exe" rev-parse --show-toplevel 2>$null
if (-not $AI_DIR) { $AI_DIR = Get-Location }
$WS      = Split-Path $AI_DIR -Parent
$PROJECT = (Split-Path $WS -Leaf) -replace '^workspace-', ''
$BE_DIR  = Join-Path $WS "$PROJECT-be"
if (-not (Test-Path $BE_DIR)) {
    $BE_DIR = (Get-ChildItem $WS -Directory -Filter '*-be' | Select-Object -First 1).FullName
}
```

### Step 1 — properties 파일 파싱

```powershell
$propFile = "$BE_DIR\src\main\resource\prop\application-dev.properties"
$props = @{}
Get-Content $propFile | Where-Object { $_ -match '^[^#].*=' } | ForEach-Object {
    $k, $v = $_ -split '=', 2
    $props[$k.Trim()] = $v.Trim()
}
```

### Step 2 — URL에서 host·port·dbname 추출

`db.url` 형식: `jdbc:log4jdbc:postgresql://host:port/dbname`

```powershell
if ($props['db.url'] -match '//([^:/]+):(\d+)/([^?/\s]+)') {
    $PG_HOST = $Matches[1]
    $PG_PORT = $Matches[2]
    $PG_DB   = $Matches[3]
}
$PG_USER          = $props['db.username']
$env:PGPASSWORD   = $props['db.password']
```

NEVER: 비밀번호를 이 스킬 파일·코드·문서·커밋에 평문으로 적지 않는다.

## 3. psql 실행 패턴

위 Step 0~2 로딩 후 아래 패턴으로 실행한다.

### 단건 SQL

```powershell
& "C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe" `
    -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c "<SQL>"
```

### 멀티라인 SQL (here-string)

긴 SQL 은 PowerShell here-string(`@'...'@`)으로 실행한다. 닫는 `'@` 는 **0번 컬럼**에 둔다.

```powershell
$sql = @'
SELECT
    prod_seq
  , prod_no
  , prod_nm
FROM mdm_prod
WHERE use_yn = 'Y'
ORDER BY reg_dt DESC
LIMIT 20;
'@
& "C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe" `
    -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c $sql
```

### 한글 인코딩 주의 (NEVER)

NEVER: SQL 주석·문자열에 한글을 넣어 `0xbc` 같은 UTF8 인코딩 오류가 나지 않도록 한다.

❌ 잘못된 예 — SQL 안에 한글 주석
```
오류:  "UTF8" 인코딩에서 사용할 수 없는 문자가 있음: 0xbc
```

✅ 올바른 예 — SQL 은 영문·식별자만. 한글 설명은 PowerShell 주석(`#`)으로 분리.

## 4. 자주 쓰는 조회 패턴

> **테이블 목록·컬럼 정보가 필요하면** psql 탐색 전에 아래 문서를 먼저 보는 것이 빠르다.
> `spec/kyochon_oms/_knowledge/db-schema/00-tables-overview.md` (전체 목록 + 도메인별 분류)

MUST: 테이블·컬럼 용도는 **comment 로 확인**한다. 이름만 보고 단정하지 않는다.

### 4-1. 테이블·컬럼 comment 조회 (가장 먼저, MUST)

```powershell
$sql = @'
SELECT c.relname AS tbl, a.attnum AS no, a.attname AS col,
       format_type(a.atttypid, a.atttypmod) AS type,
       col_description(c.oid, a.attnum) AS comment
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
WHERE n.nspname = 'public' AND c.relname = 'shop_prod'
ORDER BY a.attnum;
'@
& "C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe" `
    -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c $sql
```

### 4-2. comment 로 테이블 찾기

```powershell
$sql = @'
SELECT c.relname AS tbl, obj_description(c.oid) AS comment
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r' AND n.nspname = 'public'
  AND c.relname LIKE '%shop%'
ORDER BY c.relname;
'@
& "C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe" `
    -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c $sql
```

### 4-3. 공통코드 조회 (sm_comm_h / sm_comm_d)

공통코드 테이블: `sm_comm_h`(상위=`comm_h_cd`/`comm_h_nm`), `sm_comm_d`(상세=`comm_h_cd`/`comm_d_cd`/`comm_d_nm`).

```powershell
$sql = @'
SELECT comm_h_cd, comm_d_cd, comm_d_nm, disp_no
FROM sm_comm_d
WHERE comm_h_cd = 'ORDER_STS_CD'
  AND use_yn = 'Y'
ORDER BY disp_no;
'@
& "C:\Program Files\PostgreSQL\15\pgAdmin 4\runtime\psql.exe" `
    -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DB -c $sql
```

## 5. 주의사항 (MUST/NEVER)

| 강도 | 규칙 |
| ---- | ---- |
| NEVER | 비밀번호를 스킬·코드·문서·커밋에 평문 포함 |
| NEVER | 물리 삭제(`DELETE FROM`) 실행. 소프트 삭제 원칙(`use_yn='N'`) 준수 |
| NEVER | SQL 안에 한글 포함 (UTF8 인코딩 오류 원인) |
| MUST | dev DB 에 UPDATE/DELETE 실행 시 트랜잭션(`BEGIN;` … `COMMIT;`/`ROLLBACK;`) 사용 |
| MUST | 컬럼 단정 전 `\d <테이블>` 또는 comment 조회로 실제 컬럼 확인 |
| MUST | ERP DB(SQL Server)는 psql 대상 아님 |
