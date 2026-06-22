---
name: SD_334
description: 실DB 접속 → ERD 뷰어 HTML 생성·갱신 (PostgreSQL, Windows/WSL/Linux 자동 감지). /SD_334
when_to_use: "DB 관계도 만들어줘", "ERD 뽑아줘", "ERD 갱신해줘", "ERD 뷰어 만들어줘" 요청 시 사용.
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, AskUserQuestion
---

# DB 관계도(ERD) HTML 자동 생성 (실DB, Windows/WSL/Linux/Mac 통합) [SD_334]

`{BE경로}/src/main/resource/prop/application-test.properties` 에서 PostgreSQL 접속정보를 파싱하고, `psql`/`psql.exe` 또는 `python3 + psycopg2` 로 `pg_catalog` 를 조회하여 테이블·컬럼·FK 데이터를 추출한 뒤, 기존 `deliverables/30-output/03 설계(SD)/SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용해서
`deliverables/30-output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html` ERD 뷰어 파일을 생성(또는 갱신)한다.

> **재사용 방식**: 기존 HTML 파일의 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한다. 뷰어 코드(CSS·JS 함수·SVG 마커·`SUBGROUP_DEF`·`MAPPING_TBLS`·`PARENT_GROUPS`·`getSubGroup`·`relayoutBySubGroup`·`drawLines`)는 템플릿 파일에 고정 보관되며 그대로 유지된다.

> **같은 DB를 보는 다른 산출물**:
> - `/SD_331` — 동일 DB에서 SD.212-테이블정의서 **엑셀** 생성
> - `/SD_333` — 동일 DB에서 DDL SQL 스크립트 생성

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 명령 없음
  → [Windows 섹션]의 PowerShell 블록 사용. `psql.exe` (PostgreSQL 클라이언트).
- WSL / Linux / macOS (Bash):    uname 명령 존재 (Linux/Darwin)
  → [Bash 섹션]의 bash 블록 사용. `psql` 또는 `python3 + psycopg2` 폴백.
```

> 두 섹션의 로직(접속정보 파싱 → TABLES/FKS SQL 추출 → 템플릿 로드 → 교체 → 저장)은 동일하다. SQL 자체는 양쪽이 동일하다.

---

## 사전 준비 (공통)

### 인자 확정

1. **BE 경로** — 사용자에게 백엔드 프로젝트 루트를 묻는다.
   - Windows 예: `C:\zinide\workspace_cloud\common-system-be`
   - WSL/Linux 예: `/mnt/c/zinide/workspace/wms-bnk-be`
   - 경로가 존재하지 않거나 그 아래에 `src/main/resource/prop/application-test.properties` 파일이 없으면 다시 묻는다.
2. **업체명** — 출력 파일명(`SD.211-ERD_{업체명}_{YYMMDD}.html`)에 들어가는 식별자. OS 예약 문자(`\ / : * ? " < > |`)는 자동으로 `_` 로 치환한다.

### 출력 HTML 파일 구조 (핵심 섹션)

```
<title>ERD - {업체명} WMS ({YYMMDD})</title>
...
<div id="sidebar-header">ERD Viewer · {업체명} WMS</div>
...
<script>
  const MAPPING_TBLS = new Set([...]);   ← 커넥터 테이블 목록 (템플릿 유지)
  const SUBGROUP_DEF = [...];            ← 서브그룹 정의 (템플릿 유지)
  const PARENT_GROUPS = {...};           ← 부모 그룹 정의 (템플릿 유지)
  const TABLES = [...];                  ← ★ DB에서 갱신
  const FKS = [...];                     ← ★ DB에서 갱신
  ...
</script>
```

### TABLES / FKS 데이터 구조

```javascript
// TABLES
{
  "id": "wms_inbiz",
  "phys": "wms_inbiz",
  "logi": "WMS_입하",
  "grp": "wms",
  "x": 0, "y": 0,
  "cols": [
    { "pkfk": "PK", "phys": "inbiz_seq", "type": "integer", "nn": "N", "logi": "입하 SEQ" }
  ]
}

// FKS
{"ft": "wms_inbiz_prod", "fc": "inbiz_seq", "tt": "wms_inbiz", "tc": "inbiz_seq"}
```

### grp 파생 규칙

| 테이블 접두사 | grp |
|---|---|
| `wms_*` | `wms` |
| `mdm_*` | `mdm` |
| `sm_*` | `sm` |
| `sif_*` | `sif` |
| `wes_*` | `wes` |
| 그 외 | `sm` |

---

# === Windows 섹션 (PowerShell) ===

전 단계를 하나의 PowerShell 블록 안에서 실행한다 (변수가 단계 간에 유지되어야 함). Bash 도구에서 `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "..."` 패턴으로 호출한다.

### W-0) 경로 동적 감지

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
$RepoPrefix = $RepoName -replace '-[^-]+$',''
$BeRoot    = Join-Path $Workspace "$RepoPrefix-be"
```

경로:
```
PROP_FILE  = {BE경로}\src\main\resource\prop\application-test.properties
PSQL       = C:\Program Files\PostgreSQL\10\bin\psql.exe
OUTPUT_DIR = $DocRoot\output\03 설계(SD)
TEMPLATE   = $DocRoot\output\03 설계(SD)\SD.211-ERD_*.html (최신 LastWriteTime)
OUT_FILE   = $DocRoot\output\03 설계(SD)\SD.211-ERD_{업체명}_{YYMMDD}.html
```

### W-1) DB 접속 정보 파싱

```powershell
param([string]$BE_PATH, [string]$ARGUMENTS)

$propFile = "$BE_PATH\src\main\resource\prop\application-test.properties"
if (-not (Test-Path $propFile)) { Write-Error "DB 접속 설정 파일 없음: $propFile"; return }

$props = @{}
Get-Content $propFile -Encoding UTF8 | Where-Object { $_ -match "^[^#].*=" } | ForEach-Object {
    $k, $v = $_ -split "=", 2
    $props[$k.Trim()] = $v.Trim()
}
$dbUrl = $props["db.url"] -replace "jdbc:log4jdbc:", "jdbc:"
if ($dbUrl -match "jdbc:postgresql://([^:]+):(\d+)/(.+)") {
    $dbHost = $Matches[1]; $dbPort = $Matches[2]; $dbName = $Matches[3]
}
$dbUser = $props["db.username"]
$dbPass = $props["db.password"]
$env:PGPASSWORD = $dbPass
$psql = "C:\Program Files\PostgreSQL\10\bin\psql.exe"
$psqlArgs = @("-h", $dbHost, "-p", $dbPort, "-U", $dbUser, "-d", $dbName, "-t", "-A")

function Invoke-PSQL([string]$sql) { return & $psql @psqlArgs -c $sql 2>&1 }

Write-Host "DB 접속: $dbHost`:$dbPort/$dbName (user=$dbUser)"
```

### W-2) TABLES 데이터 추출

SQL은 §공통 SQL 참조.

```powershell
$tableRows = Invoke-PSQL $tablesSql
$tableRows = $tableRows | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "^(ERROR|FATAL|WARNING)" }
$tablesJS = "const TABLES=[" + ($tableRows -join ",") + "];"
```

### W-3) FKS 데이터 추출

```powershell
$fkRows = Invoke-PSQL $fksSql
$fkRows = $fkRows | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "^(ERROR|FATAL|WARNING)" }
$fksJS = "const FKS=[" + ($fkRows -join ",") + "];"
```

### W-4) 출력 파일 준비 & 템플릿 로드

```powershell
$projectRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$outputDir   = "$projectRoot\output\03 설계(SD)"
$yymmdd      = (Get-Date).ToString("yyMMdd")
$safeName    = $ARGUMENTS -replace '[\\/:*?"<>|]', '_'
$outputFile  = "$outputDir\SD.211-ERD_${safeName}_${yymmdd}.html"

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

$templateFile = Get-ChildItem $outputDir -Filter "SD.211-ERD_*.html" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $templateFile) {
    Write-Error "ERD 템플릿 파일 없음. output\03 설계(SD)\SD.211-ERD_*.html 파일이 최소 1개 필요합니다."; return
}
$html = Get-Content $templateFile.FullName -Raw -Encoding UTF8
```

### W-5) TABLES / FKS 교체 + 헤더 갱신 + 저장

```powershell
$startTbl = $html.IndexOf('const TABLES=[')
$endTbl   = $html.IndexOf('];', $startTbl) + 2
$html = $html.Substring(0, $startTbl) + $tablesJS + $html.Substring($endTbl)

$startFks = $html.IndexOf('const FKS=[')
$endFks   = $html.IndexOf('];', $startFks) + 2
$html = $html.Substring(0, $startFks) + $fksJS + $html.Substring($endFks)

$html = [regex]::Replace($html, '<title>ERD - [^<]+</title>', "<title>ERD - $safeName WMS ($yymmdd)</title>")
$html = [regex]::Replace($html, 'ERD Viewer · [^<]+', "ERD Viewer · $safeName WMS")

[System.IO.File]::WriteAllText($outputFile, $html, [System.Text.Encoding]::UTF8)
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

OUTPUT_DIR="$DOC_ROOT/deliverables/30-output/03 설계(SD)"
```

### B-1) DB 접속정보 파싱

```bash
PROP_FILE="${BE_PATH}/src/main/resource/prop/application-test.properties"
if [ ! -f "$PROP_FILE" ]; then echo "DB 설정 파일 없음: $PROP_FILE"; exit 1; fi

DB_URL=$(grep -m1 'db\.url' "$PROP_FILE" | cut -d'=' -f2- | sed 's/jdbc:log4jdbc://; s/jdbc://')
DB_HOST=$(echo "$DB_URL" | grep -oP '(?<=postgresql://)([^:/]+)')
DB_PORT=$(echo "$DB_URL" | grep -oP '(?<=:)(\d+)(?=/)' | head -1)
DB_NAME=$(echo "$DB_URL" | grep -oP '(?<=/)[^/?]+' | head -1)
DB_USER=$(grep -m1 'db\.username' "$PROP_FILE" | cut -d'=' -f2-)
DB_PASS=$(grep -m1 'db\.password' "$PROP_FILE" | cut -d'=' -f2-)
```

### B-2) TABLES / FKS 추출

`psql` 이 있으면 직접 사용, 없으면 `python3 + psycopg2` 로 폴백.

```bash
export PGPASSWORD="$DB_PASS"
PSQL_CMD="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -A"

TABLES_JS=$($PSQL_CMD -c "$TABLES_SQL" | grep -v '^$')
FKS_JS=$($PSQL_CMD -c "$FKS_SQL" | grep -v '^$')
```

(`TABLES_SQL` / `FKS_SQL` 본문은 §공통 SQL 참조)

### B-3) 템플릿 로드 및 교체 (Python 사용)

문자열 특수문자 처리를 위해 Python을 활용한다.

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
OUTPUT_DIR="$DOC_ROOT/deliverables/30-output/03 설계(SD)"
YYMMDD=$(date '+%y%m%d')
SAFE_NAME=$(echo "$업체명" | tr '\\/:*?"<>|' '_')
OUT_FILE="$OUTPUT_DIR/SD.211-ERD_${SAFE_NAME}_${YYMMDD}.html"

TEMPLATE=$(ls -t "$OUTPUT_DIR"/SD.211-ERD_*.html 2>/dev/null | head -1)
if [ -z "$TEMPLATE" ]; then echo "ERD 템플릿 파일 없음"; exit 1; fi

python3 - <<PYEOF
import re
html = open("$TEMPLATE", encoding='utf-8').read()
tables_js = 'const TABLES=[' + ','.join("""${TABLES_JS}""".strip().split('\n')) + '];'
fks_js    = 'const FKS=['    + ','.join("""${FKS_JS}""".strip().split('\n'))    + '];'

start = html.index('const TABLES=['); end = html.index('];', start) + 2
html  = html[:start] + tables_js + html[end:]
start = html.index('const FKS=[');    end = html.index('];', start) + 2
html  = html[:start] + fks_js + html[end:]

html = re.sub(r'<title>ERD - [^<]+</title>', '<title>ERD - $SAFE_NAME WMS ($YYMMDD)</title>', html)
html = re.sub(r'ERD Viewer · [^<]+', 'ERD Viewer · $SAFE_NAME WMS', html)

with open("$OUT_FILE", 'w', encoding='utf-8') as f:
    f.write(html)
print(f"출력: $OUT_FILE")
PYEOF
```

---

## 공통 SQL — TABLES

```sql
SELECT
  '{"id":"' || c.relname || '","phys":"' || c.relname || '","logi":"' ||
  replace(replace(COALESCE(d.description, c.relname), chr(10), ' '), '"', '\"') ||
  '","grp":"' ||
  CASE
    WHEN c.relname LIKE 'wms_%' THEN 'wms'
    WHEN c.relname LIKE 'mdm_%' THEN 'mdm'
    WHEN c.relname LIKE 'sm_%'  THEN 'sm'
    WHEN c.relname LIKE 'sif_%' THEN 'sif'
    WHEN c.relname LIKE 'wes_%' THEN 'wes'
    ELSE 'sm'
  END || '","x":0,"y":0,"cols":[' ||
  (
    SELECT string_agg(
      '{"pkfk":"' ||
      CASE
        WHEN EXISTS(SELECT 1 FROM pg_constraint pk WHERE pk.conrelid=c.oid AND pk.contype='p' AND a.attnum=ANY(pk.conkey))
         AND EXISTS(SELECT 1 FROM pg_constraint fk WHERE fk.conrelid=c.oid AND fk.contype='f' AND a.attnum=ANY(fk.conkey))
        THEN 'PK FK'
        WHEN EXISTS(SELECT 1 FROM pg_constraint pk WHERE pk.conrelid=c.oid AND pk.contype='p' AND a.attnum=ANY(pk.conkey))
        THEN 'PK'
        WHEN EXISTS(SELECT 1 FROM pg_constraint fk WHERE fk.conrelid=c.oid AND fk.contype='f' AND a.attnum=ANY(fk.conkey))
        THEN 'FK'
        ELSE ''
      END ||
      '","phys":"' || a.attname ||
      '","type":"' || pg_catalog.format_type(a.atttypid, a.atttypmod) ||
      '","nn":"'   || CASE WHEN a.attnotnull THEN 'N' ELSE 'Y' END ||
      '","logi":"' || replace(replace(COALESCE(d2.description, a.attname), chr(10), ' '), '"', '\"') ||
      '"}',
      ',' ORDER BY a.attnum
    )
    FROM pg_attribute a
    LEFT JOIN pg_description d2 ON d2.objoid = c.oid AND d2.objsubid = a.attnum
    WHERE a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
  ) || ']}'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_description d ON d.objoid = c.oid AND d.objsubid = 0
WHERE c.relkind = 'r' AND n.nspname = 'public'
ORDER BY c.relname;
```

> Windows PowerShell 헤레독 안에서는 `"` 를 `\"` 로 추가 이스케이프해야 한다. Bash 헤레독 안에서도 `\"` 이스케이프 필요. 양쪽 SKILL.md 원본의 이스케이프 형식을 참고.

## 공통 SQL — FKS

```sql
SELECT '{"ft":"' || tc.relname ||
  '","fc":"' || a_from.attname ||
  '","tt":"' || pc.relname ||
  '","tc":"' || a_to.attname || '"}'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_class pc ON pc.oid = con.confrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
JOIN LATERAL unnest(con.conkey, con.confkey) AS u(fk_col, pk_col) ON true
JOIN pg_attribute a_from ON a_from.attrelid = tc.oid AND a_from.attnum = u.fk_col
JOIN pg_attribute a_to   ON a_to.attrelid   = pc.oid AND a_to.attnum   = u.pk_col
WHERE con.contype = 'f' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname, u.fk_col;
```

---

## SUBGROUP_DEF / getSubGroup 관리 규칙

`SUBGROUP_DEF` 와 `getSubGroup` 함수는 템플릿 파일에 고정 보관된다.
새 테이블 그룹(서브그룹)이 추가될 때만 템플릿 파일을 직접 수정한다.

### 현재 서브그룹 prefix 매핑 (getSubGroup 기준)

| prefix (startsWith) | sub-group id | 비고 |
|---|---|---|
| `wms_inbiz` | `wms-inbiz` | 입하 |
| `wms_inwh` | `wms-inwh` | 입고 |
| `wms_inven_ad` | `wms-inven-ad` | 재고조정 |
| `wms_inven_etc` | `wms-inven-etc` | 예외출고 |
| `wms_inven_mv` | `wms-inven-mv` | 재고이동 |
| `wms_inven_st` | `wms-inven-st` | 세트작업 |
| `wms_inven_rp` | `wms-inven-rp` | 품목전환 |
| `wms_inven` | `wms-inven` | 재고(기타) |
| `wms_outbiz` | `wms-outbiz` | 출하 |
| `wms_outwh` | `wms-outwh` | 출고 |
| `wms_invoice` | `wms-invoice` | 송장 |
| `wms_load` | `wms-load` | 상차 |
| `wms_return` | `wms-return` | 반품 |
| `wms_st` | `wms-st` | 재고실사 |
| `mdm_biz` | `mdm-biz` | 사업장 |
| `mdm_cont` | `mdm-cont` | 거래처 |
| `mdm_prod`, `mdm_rp` | `mdm-prod` | 품목 |
| `mdm_st` | `mdm-st` | 세트 |
| `mdm_wh`, `mdm_loc` | `mdm-wh` | 창고/위치 |
| `mdm_user` | `mdm-user` | 사용자 |
| `mdm_*` (기타) | `mdm-etc` | 기타(MDM) |
| `sm_comm` | `sm-comm` | 공통코드 |
| `sm_menu` | `sm-menu` | 메뉴 |
| `sm_log` | `sm-log` | 로그 |
| `sm_alarm`, `sm_push` | `sm-alarm` | 알람/푸시 |
| `sm_qrtz` | `sm-qrtz` | 스케줄러 |
| `sm_api`, `sm_biz`, `sm_dlv`, `sm_ob_proc`, `sm_opt`, `sm_prod_opt` | `sm-config` | 설정 |
| `sm_*` (기타) | `sm-etc` | 기타(SM) |
| `sif_` | `sif` | SIF 연동 |
| `wes_` | `wes` | WES |

### 커넥터 테이블 (MAPPING_TBLS / BEFORE_SG)

| 테이블 | 앞에 배치되는 서브그룹 |
|---|---|
| `wms_inbiz_inwh` | `wms-inwh` |
| `wms_outbiz_outwh` | `wms-outwh` |
| `wms_outbiz_invoice` | `wms-invoice` |
| `wms_outbiz_load` | `wms-load` |

새 커넥터 테이블이 생기면 HTML 파일의 `MAPPING_TBLS`, `BEFORE_SG` 양쪽에 모두 추가한다.

---

## 레이아웃 자동 배치 규칙 (참고)

- 부모 그룹 순서: `wms → mdm → sm → sif → wes`
- 각 서브그룹 내 테이블은 이름 길이 → 알파벳 순으로 정렬 후 1행으로 배치
- 서브그룹 간격: 50px / 부모 그룹 간격: 80px / 커넥터 행 간격: 24px
- 테이블 폭: 320px (CSS) / 배치 계산 폭: 300px / 간격: 28px

FK 관계선은 `drawLines()` 함수가 담당한다.
- 인접 테이블(gap < 60px): 아래 방향으로 U자 우회 (`loopY = max_bottom + 80`)
- 원거리 테이블: S자 베지어 커브 (수평 연결)
- 선 색상: 주황색(`#f97316`) / 굵기: 2.5px / `vector-effect: non-scaling-stroke`

---

## 완료 체크리스트 (공통)

- [ ] BE 경로 확정 및 `application-test.properties` 존재 확인
- [ ] DB 접속 정보 파싱 완료 (host / port / dbname / user)
- [ ] DB 클라이언트 연결 정상 (`psql.exe` 또는 `psql` 또는 `psycopg2`)
- [ ] TABLES 추출 완료 (행 수 = 실제 테이블 수)
- [ ] FKS 추출 완료 (행 수 = FK 총 컬럼 쌍 수)
- [ ] 추출된 JSON 형식 오류 없음 (ERROR/FATAL 메시지 없음)
- [ ] 템플릿 파일 확인 (`SD.211-ERD_*.html` 최신 파일 존재)
- [ ] `const TABLES=[...]` 교체 완료
- [ ] `const FKS=[...]` 교체 완료
- [ ] 제목·헤더 업체명 교체 완료
- [ ] 출력 파일 경로·파일명 규칙 준수 (`SD.211-ERD_{업체명}_{YYMMDD}.html`)
- [ ] 파일 크기 150KB 이상 (뷰어 코드 + 데이터)

---

## 완료 보고 형식

```
✓ ERD 뷰어 생성 완료 [SD_334]

실행 환경:   Windows PowerShell   또는   Bash on Linux/Mac/WSL
업체명  : {업체명}
DB      : {host}:{port}/{dbname}
템플릿  : SD.211-ERD_{이전업체}_{이전날짜}.html
출력파일: deliverables/30-output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html
파일크기: {N} KB

데이터 현황:
  - 테이블 : N 건
  - FK 관계 : N 건

주요 서브그룹 테이블 수:
  - wms-inbiz: N / wms-inwh: N / wms-inven: N
  - wms-outbiz: N / wms-outwh: N / wms-return: N / wms-st: N
  - mdm: N / sm: N / sif: N / wes: N
```

---

## 주의사항 (공통)

- **템플릿 필수**: 최소 1개의 `SD.211-ERD_*.html` 파일이 `deliverables/30-output/03 설계(SD)/` 에 존재해야 한다 (최초 1회는 수동 작성 필요).
- **새 서브그룹 추가**: `SUBGROUP_DEF` / `getSubGroup` / `MAPPING_TBLS` 변경은 템플릿 HTML 파일 직접 수정.
- **logical name 갱신**: `pg_description` 코멘트가 있으면 그것을 사용. 없으면 `phys` 그대로.

### Windows 특화

- **psql.exe 경로**: `C:\Program Files\PostgreSQL\10\bin\psql.exe` 가정. 버전이 다르면 경로 조정 (`PostgreSQL\15\bin` 등).
- **PGPASSWORD 환경변수**: PowerShell 세션 한정 — 호출 종료 시 자동 폐기.
- **PowerShell 헤레독 이스케이프**: `"` → `\"`, `$` → ``` `$ ``` (백틱 이스케이프).

### Bash 특화

- **psql 우선, psycopg2 폴백**: `command -v psql` 로 확인 후 분기.
- **WSL 경로**: BE 경로를 `/mnt/c/...` 형태로 입력. `wslpath -w` 로 Windows 경로 변환은 필요 없음 (Bash에서 직접 사용).
- **PGPASSWORD 환경변수**: `export` 로 셸 한정 유효.

---

## 참고: scripts 폴더

`.claude/skills/SD_334/scripts/` 의 Python 스크립트들(`01_scan_config.py`, `02_extract_schema.py`, `03_generate_html.py`)은 이전 vis-network 기반 구현의 참고용으로 보존되어 있으며, 현재 이 스킬에서는 호출하지 않는다. 모든 처리는 위 PowerShell/Bash 절차로 진행된다.
