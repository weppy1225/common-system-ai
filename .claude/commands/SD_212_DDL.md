# DB Schema DDL 생성 명령어

업체명: **$ARGUMENTS**

BE 프로젝트의 DB 접속 정보를 읽어 PostgreSQL public 스키마의 DDL(CREATE TABLE, INDEX, FK 등)을  
`output\03 설계(SD)\SD.211-DB_Schema(DDL)_{업체명}_{YYMMDD}.sql` 파일로 추출한다.

---

## 입출력 경로

| 구분 | 경로 |
|---|---|
| DB 접속정보 | `C:\zinide\workspace_cloud\cloud-wms-be\src\main\resource\prop\application-test.properties` |
| psql 경로 | `C:\Program Files\PostgreSQL\10\bin\psql.exe` |
| 출력 | `output\03 설계(SD)\SD.211-DB_Schema(DDL)_{업체명}_{YYMMDD}.sql` |

- `{업체명}`: $ARGUMENTS
- `{YYMMDD}`: 오늘 날짜 (예: 260506)
- 출력 폴더가 없으면 생성

---

## DB 접속 정보 파싱 규칙

`application-test.properties` 파일에서 아래 키를 읽는다.

```
db.url=jdbc:log4jdbc:postgresql://{host}:{port}/{dbname}
db.username={username}
db.password={password}
```

- `db.url`에서 `log4jdbc:` 프리픽스 제거 후 host / port / dbname 파싱
- 패턴: `jdbc:(?:log4jdbc:)?postgresql://([^:]+):(\d+)/(.+)`

> **주의**: pg_dump는 서버(PG15)↔클라이언트(PG10) 버전 충돌로 사용 불가.  
> psql은 버전 제약이 없으므로 psql + pg_catalog SQL 쿼리로 DDL을 직접 생성한다.

---

## SQL 출력 구성 (7개 섹션)

| 순서 | 섹션 | 소스 |
|---|---|---|
| 헤더 | SET 설정 (encoding, timeout) | 고정 |
| 1 | SEQUENCES | `information_schema.sequences` |
| 2 | TABLES | `pg_class` + `pg_attribute` + `pg_attrdef` |
| 3 | PRIMARY KEY CONSTRAINTS | `pg_constraint` (contype='p') |
| 4 | UNIQUE CONSTRAINTS | `pg_constraint` (contype='u') |
| 5 | FOREIGN KEY CONSTRAINTS | `pg_constraint` (contype='f') |
| 6 | INDEXES | `pg_indexes` (PK/UQ 제외) |

---

## 실행 절차

### 1단계 — DB 접속 정보 파싱

```powershell
$propFile = "C:\zinide\workspace_cloud\cloud-wms-be\src\main\resource\prop\application-test.properties"
$props = @{}
Get-Content $propFile -Encoding UTF8 | Where-Object { $_ -match "^[^#].*=" } | ForEach-Object {
    $k, $v = $_ -split "=", 2
    $props[$k.Trim()] = $v.Trim()
}

$dbUrl = $props["db.url"] -replace "jdbc:log4jdbc:", "jdbc:"
if ($dbUrl -match "jdbc:postgresql://([^:]+):(\d+)/(.+)") {
    $dbHost = $Matches[1]
    $dbPort = $Matches[2]
    $dbName = $Matches[3]
}
$dbUser = $props["db.username"]
$dbPass = $props["db.password"]

$env:PGPASSWORD = $dbPass
$psql = "C:\Program Files\PostgreSQL\10\bin\psql.exe"
$psqlArgs = @("-h", $dbHost, "-p", $dbPort, "-U", $dbUser, "-d", $dbName, "-t", "-A")

function Invoke-PSQL([string]$sql) {
    return & $psql @psqlArgs -c $sql 2>&1
}
```

### 2단계 — 출력 파일 준비

```powershell
$projectRoot = "C:\zinide\workspace_cloud\cloud-wms-doc"
$outputDir   = "$projectRoot\output\03 설계(SD)"
$yymmdd      = (Get-Date).ToString("yyMMdd")
$outputFile  = "$outputDir\SD.211-DB_Schema(DDL)_$($ARGUMENTS)_${yymmdd}.sql"

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force }

$out = [System.Collections.Generic.List[string]]::new()
```

### 3단계 — 헤더 출력

```powershell
$out.Add("-- ============================================================")
$out.Add("-- Database  : $dbName")
$out.Add("-- Schema    : public")
$out.Add("-- Generated : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$out.Add("-- ============================================================")
$out.Add("")
$out.Add("SET statement_timeout = 0;")
$out.Add("SET lock_timeout = 0;")
$out.Add("SET client_encoding = 'UTF8';")
$out.Add("SET standard_conforming_strings = on;")
$out.Add("")
```

### 4단계 — SEQUENCES 추출

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 1. SEQUENCES")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT
    'CREATE SEQUENCE IF NOT EXISTS ' || quote_ident(sequence_name) ||
    E'\n  INCREMENT BY ' || increment ||
    E'\n  MINVALUE ' || minimum_value ||
    E'\n  MAXVALUE ' || maximum_value ||
    E'\n  START WITH ' || start_value ||
    CASE WHEN cycle_option='YES' THEN E'\n  CYCLE' ELSE E'\n  NO CYCLE' END ||
    E';\n'
FROM information_schema.sequences
WHERE sequence_schema = 'public'
ORDER BY sequence_name;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 5단계 — TABLES 추출

컬럼 타입(`format_type`), DEFAULT 값(`pg_get_expr`), NOT NULL 포함.

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 2. TABLES")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT
    'CREATE TABLE ' || quote_ident(c.relname) || ' (' ||
    string_agg(
        E'\n    ' || quote_ident(a.attname) || ' ' ||
        pg_catalog.format_type(a.atttypid, a.atttypmod) ||
        CASE WHEN ad.adbin IS NOT NULL
             THEN ' DEFAULT ' || pg_get_expr(ad.adbin, ad.adrelid) ELSE '' END ||
        CASE WHEN a.attnotnull THEN ' NOT NULL' ELSE '' END,
        ','
        ORDER BY a.attnum
    ) ||
    E'\n);\n'
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
LEFT JOIN pg_catalog.pg_attrdef ad ON ad.adrelid = c.oid AND ad.adnum = a.attnum
WHERE c.relkind = 'r' AND n.nspname = 'public'
GROUP BY c.relname, c.oid
ORDER BY c.relname;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 6단계 — PRIMARY KEY CONSTRAINTS 추출

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 3. PRIMARY KEY CONSTRAINTS")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' PRIMARY KEY (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    E');\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'p' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 7단계 — UNIQUE CONSTRAINTS 추출

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 4. UNIQUE CONSTRAINTS")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' UNIQUE (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    E');\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'u' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 8단계 — FOREIGN KEY CONSTRAINTS 추출

ON UPDATE / ON DELETE 액션 포함 (`a`=NO ACTION, `r`=RESTRICT, `c`=CASCADE, `n`=SET NULL).

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 5. FOREIGN KEY CONSTRAINTS")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' FOREIGN KEY (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    ') REFERENCES ' || quote_ident(fc.relname) || ' (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.confkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = fc.oid AND att.attnum = u.k) ||
    ')' ||
    CASE con.confupdtype
        WHEN 'r' THEN ' ON UPDATE RESTRICT'
        WHEN 'c' THEN ' ON UPDATE CASCADE'
        WHEN 'n' THEN ' ON UPDATE SET NULL'
        ELSE '' END ||
    CASE con.confdeltype
        WHEN 'r' THEN ' ON DELETE RESTRICT'
        WHEN 'c' THEN ' ON DELETE CASCADE'
        WHEN 'n' THEN ' ON DELETE SET NULL'
        ELSE '' END ||
    E';\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_class fc ON fc.oid = con.confrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'f' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 9단계 — INDEXES 추출 (PK/UQ 제외)

```powershell
$out.Add("-- ============================================================")
$out.Add("-- 6. INDEXES")
$out.Add("-- ============================================================")

$rows = Invoke-PSQL @"
SELECT indexdef || E';\n'
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname NOT IN (
      SELECT con.conname
      FROM pg_constraint con
      JOIN pg_namespace ns ON ns.oid = con.connamespace
      WHERE con.contype IN ('p','u') AND ns.nspname = 'public'
  )
ORDER BY tablename, indexname;
"@
foreach ($r in $rows) { if ($null -ne $r) { $out.Add($r) } }
```

### 10단계 — 파일 저장

```powershell
$out | Out-File -FilePath $outputFile -Encoding UTF8

$size      = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
$lineCount = (Get-Content $outputFile -Encoding UTF8).Count

$seqCnt = ($out | Where-Object { $_ -match "^CREATE SEQUENCE" }).Count
$tblCnt = ($out | Where-Object { $_ -match "^CREATE TABLE" }).Count
$pkCnt  = ($out | Where-Object { $_ -match "PRIMARY KEY \(" }).Count
$uqCnt  = ($out | Where-Object { $_ -match "ADD CONSTRAINT .* UNIQUE" }).Count
$fkCnt  = ($out | Where-Object { $_ -match "FOREIGN KEY" }).Count
$idxCnt = ($out | Where-Object { $_ -match "^CREATE (UNIQUE )?INDEX" }).Count
```

---

## 완료 체크리스트

- [ ] DB 접속 정보 파싱 완료 (host / port / dbname / user / password)
- [ ] psql 연결 정상 (버전 무관)
- [ ] SEQUENCES 추출 완료
- [ ] TABLES 추출 완료 (컬럼 타입·DEFAULT·NOT NULL 포함)
- [ ] PRIMARY KEY CONSTRAINTS 추출 완료
- [ ] UNIQUE CONSTRAINTS 추출 완료
- [ ] FOREIGN KEY CONSTRAINTS 추출 완료 (ON UPDATE/DELETE 액션 포함)
- [ ] INDEXES 추출 완료 (PK/UQ 제외 순수 인덱스)
- [ ] 출력 파일 경로·파일명 규칙 준수

---

## 완료 보고 형식

```
✓ DB Schema DDL 생성 완료

업체명  : {업체명}
DB      : {host}:{port}/{dbname} (PostgreSQL {version})
출력파일: output/03 설계(SD)/SD.211-DB_Schema(DDL)_{업체명}_{YYMMDD}.sql
파일크기: {N} KB  ({N} 라인)

DDL 현황:
  - SEQUENCE    : N 건
  - TABLE       : N 건
  - PRIMARY KEY : N 건
  - UNIQUE      : N 건
  - FOREIGN KEY : N 건
  - INDEX       : N 건
```
