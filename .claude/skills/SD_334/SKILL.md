---
name: SD_334
description: 【DB 관계도(ERD) HTML 생성 (PowerShell · 실DB)】 Windows 네이티브 PowerShell 환경에서 사용자가 지정한 백엔드 디렉토리의 `application-test.properties` 를 자동 탐색하여 PostgreSQL DB 접속정보를 파싱하고, `psql.exe` 로 `pg_catalog` 에 직접 접속해 테이블·컬럼·FK를 추출한 뒤, 기존 `output\03 설계(SD)\SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용하여 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한 ERD 뷰어 HTML 파일을 생성한다. 뷰어 코드(CSS·JS 함수·SVG 마커·SUBGROUP_DEF·MAPPING_TBLS 등)는 템플릿에서 그대로 유지하므로 새 테이블 그룹이 추가될 때만 템플릿 파일을 직접 수정하면 된다. /SD_334 형식으로 실행하며 BE 경로·업체명은 실행 시 묻는다. 산출물은 `output\03 설계(SD)\SD.211-ERD_{업체명}_{YYMMDD}.html` 단일 HTML 파일로 떨어지며 브라우저에서 바로 열어 노드 드래그·줌·검색·계층 레이아웃 토글이 가능하다. DB 관계도 작성, ERD HTML 생성·갱신, 테이블 관계 시각화, 산출물용 ERD 뷰어 만들기 요청 시 반드시 이 스킬을 사용한다. 사용자가 "DB 관계도 만들어줘", "ERD 뽑아줘", "ERD 갱신해줘", "테이블 관계 시각화", "ERD 뷰어 만들어줘", "SD_334 실행해줘", "관계도 산출물 만들어줘" 라고 말해도 이 스킬을 사용한다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331 을 사용한다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 관계도(ERD) HTML 자동 생성 (실DB · PowerShell) [SD_334]

`{BE경로}\src\main\resource\prop\application-test.properties` 에서 PostgreSQL 접속정보를 파싱하고, `psql.exe` 로 `pg_catalog` 를 조회하여 테이블·컬럼·FK 데이터를 추출한 뒤, 기존 `output\03 설계(SD)\SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용해서
`output\03 설계(SD)\SD.211-ERD_{업체명}_{YYMMDD}.html` ERD 뷰어 파일을 생성(또는 갱신)한다.

> **재사용 방식**: 기존 HTML 파일의 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한다. 뷰어 코드(CSS·JS 함수·SVG 마커·`SUBGROUP_DEF`·`MAPPING_TBLS`·`PARENT_GROUPS`·`getSubGroup`·`relayoutBySubGroup`·`drawLines`)는 템플릿 파일에 고정 보관되며 그대로 유지된다.

> **Windows 전용**: PowerShell 직접 실행 방식이며 `psql.exe` (PostgreSQL 클라이언트)와 Windows 경로 (`C:\Program Files\PostgreSQL\10\bin\psql.exe`) 를 사용한다. WSL/Linux/macOS에서는 동작하지 않는다.

> **같은 DB를 보는 다른 산출물**:
> - `/SD_331` — 동일 DB에서 SD.212-테이블정의서 **엑셀** 생성
> - `/SD_333_WIN` — 동일 DB에서 DDL SQL 스크립트 생성

---

## 사전 준비

### 인자 확정

1. **BE 경로** — 사용자에게 백엔드 프로젝트 루트를 묻는다. 입력 예: `C:\zinide\workspace_cloud\cloud-wms-be`. 경로가 존재하지 않거나 그 아래에 `src\main\resource\prop\application-test.properties` 파일이 없으면 다시 묻는다.
2. **업체명** — 출력 파일명(`SD.211-ERD_{업체명}_{YYMMDD}.html`)에 들어가는 식별자. 윈도우 파일명에서 사용 불가능한 문자(`\ / : * ? " < > |`)는 스크립트가 자동으로 `_` 로 치환한다.

### 경로 정의

```
BASE         = C:\zinide\workspace\cloud-wms-doc
PROP_FILE    = {BE경로}\src\main\resource\prop\application-test.properties
PSQL         = C:\Program Files\PostgreSQL\10\bin\psql.exe
OUTPUT_DIR   = output\03 설계(SD)
TEMPLATE     = output\03 설계(SD)\SD.211-ERD_*.html (최신 LastWriteTime)
OUT_FILE     = output\03 설계(SD)\SD.211-ERD_{업체명}_{YYMMDD}.html
```

`OUTPUT_DIR` 이 없으면 생성한다. 템플릿 파일이 없으면 즉시 에러로 종료하고 사용자에게 안내한다 (기존 ERD 뷰어 파일이 한 번은 작성되어 있어야 한다는 의미).

---

## 출력 HTML 파일 구조 (핵심 섹션)

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

---

## TABLES 항목 구조

```javascript
{
  "id": "wms_inbiz",           // phys와 동일
  "phys": "wms_inbiz",         // 물리 테이블명
  "logi": "WMS_입하",           // pg_description 코멘트 → 없으면 phys 그대로
  "grp": "wms",                // 접두사 파생 (아래 표 참조)
  "x": 0,                      // 초기 좌표 (relayoutBySubGroup이 자동 계산)
  "y": 0,
  "cols": [
    {
      "pkfk": "PK",            // "PK" | "FK" | "PK FK" | ""
      "phys": "inbiz_seq",
      "type": "integer",
      "nn": "N",               // N = NOT NULL, Y = Nullable
      "logi": "입하 SEQ"       // 컬럼 코멘트 → 없으면 phys 그대로
    }
  ]
}
```

## FKS 항목 구조

```javascript
{"ft": "wms_inbiz_prod", "fc": "inbiz_seq", "tt": "wms_inbiz", "tc": "inbiz_seq"}
// ft=child 테이블, fc=child 컬럼, tt=parent 테이블, tc=parent 컬럼
// 복합 FK → 컬럼 쌍마다 별도 항목 (unnest 처리)
```

---

## grp 파생 규칙

| 테이블 접두사 | grp |
|---|---|
| `wms_*` | `wms` |
| `mdm_*` | `mdm` |
| `sm_*` | `sm` |
| `sif_*` | `sif` |
| `wes_*` | `wes` |
| 그 외 | `sm` |

---

## 실행 절차 (PowerShell 단일 블록)

전 단계를 하나의 PowerShell 블록 안에서 실행한다 (변수가 단계 간에 유지되어야 함). Bash 도구에서 `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "..."` 패턴으로 호출한다.

### 1단계 — DB 접속 정보 파싱

```powershell
param([string]$BE_PATH, [string]$ARGUMENTS)

$propFile = "$BE_PATH\src\main\resource\prop\application-test.properties"
if (-not (Test-Path $propFile)) {
    Write-Error "DB 접속 설정 파일 없음: $propFile"
    return
}

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

function Invoke-PSQL([string]$sql) {
    return & $psql @psqlArgs -c $sql 2>&1
}

Write-Host "DB 접속: $dbHost`:$dbPort/$dbName (user=$dbUser)"
```

### 2단계 — TABLES 데이터 추출

SQL이 JavaScript 객체 문자열을 직접 생성한다.

```powershell
$tablesSql = @"
SELECT
  '{\"id\":\"' || c.relname || '\",\"phys\":\"' || c.relname || '\",\"logi\":\"' ||
  replace(replace(COALESCE(d.description, c.relname), chr(10), ' '), '"', '\"') ||
  '\",\"grp\":\"' ||
  CASE
    WHEN c.relname LIKE 'wms_%' THEN 'wms'
    WHEN c.relname LIKE 'mdm_%' THEN 'mdm'
    WHEN c.relname LIKE 'sm_%'  THEN 'sm'
    WHEN c.relname LIKE 'sif_%' THEN 'sif'
    WHEN c.relname LIKE 'wes_%' THEN 'wes'
    ELSE 'sm'
  END || '\",\"x\":0,\"y\":0,\"cols\":[' ||
  (
    SELECT string_agg(
      '{\"pkfk\":\"' ||
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
      '\",\"phys\":\"' || a.attname ||
      '\",\"type\":\"' || pg_catalog.format_type(a.atttypid, a.atttypmod) ||
      '\",\"nn\":\"'   || CASE WHEN a.attnotnull THEN 'N' ELSE 'Y' END ||
      '\",\"logi\":\"' || replace(replace(COALESCE(d2.description, a.attname), chr(10), ' '), '"', '\"') ||
      '\"}',
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
"@

$tableRows = Invoke-PSQL $tablesSql
$tableRows = $tableRows | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "^(ERROR|FATAL|WARNING)" }
$tablesJS = "const TABLES=[" + ($tableRows -join ",") + "];"
Write-Host "TABLES 추출: $($tableRows.Count) 건"
```

### 3단계 — FKS 데이터 추출

복합 FK는 `unnest` 로 컬럼 쌍마다 분리한다.

```powershell
$fksSql = @"
SELECT
  '{\"ft\":\"' || tc.relname ||
  '\",\"fc\":\"' || a_from.attname ||
  '\",\"tt\":\"' || pc.relname ||
  '\",\"tc\":\"' || a_to.attname || '\"}'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_class pc ON pc.oid = con.confrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
JOIN LATERAL unnest(con.conkey, con.confkey) AS u(fk_col, pk_col) ON true
JOIN pg_attribute a_from ON a_from.attrelid = tc.oid AND a_from.attnum = u.fk_col
JOIN pg_attribute a_to   ON a_to.attrelid   = pc.oid AND a_to.attnum   = u.pk_col
WHERE con.contype = 'f' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname, u.fk_col;
"@

$fkRows = Invoke-PSQL $fksSql
$fkRows = $fkRows | Where-Object { $_ -and $_.Trim() -ne "" -and $_ -notmatch "^(ERROR|FATAL|WARNING)" }
$fksJS = "const FKS=[" + ($fkRows -join ",") + "];"
Write-Host "FKS 추출: $($fkRows.Count) 건"
```

### 4단계 — 출력 파일 준비 & 템플릿 로드

```powershell
$projectRoot = "C:\zinide\workspace\cloud-wms-doc"
$outputDir   = "$projectRoot\output\03 설계(SD)"
$yymmdd      = (Get-Date).ToString("yyMMdd")
$safeName    = $ARGUMENTS -replace '[\\/:*?"<>|]', '_'
$outputFile  = "$outputDir\SD.211-ERD_${safeName}_${yymmdd}.html"

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

# 최신 기존 ERD 파일을 템플릿으로 사용
$templateFile = Get-ChildItem $outputDir -Filter "SD.211-ERD_*.html" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $templateFile) {
    Write-Error "ERD 템플릿 파일 없음. output\03 설계(SD)\SD.211-ERD_*.html 파일이 최소 1개 필요합니다."
    return
}

$html = Get-Content $templateFile.FullName -Raw -Encoding UTF8
Write-Host "템플릿: $($templateFile.Name)"
```

### 5단계 — TABLES / FKS 교체

`IndexOf` 로 정확한 블록 경계를 찾아 교체한다.

```powershell
# const TABLES=[...]; 교체
$startTbl = $html.IndexOf('const TABLES=[')
if ($startTbl -lt 0) { Write-Error "const TABLES=[ 블록을 찾지 못했습니다."; return }
$endTbl   = $html.IndexOf('];', $startTbl) + 2
$html = $html.Substring(0, $startTbl) + $tablesJS + $html.Substring($endTbl)

# const FKS=[...]; 교체
$startFks = $html.IndexOf('const FKS=[')
if ($startFks -lt 0) { Write-Error "const FKS=[ 블록을 찾지 못했습니다."; return }
$endFks   = $html.IndexOf('];', $startFks) + 2
$html = $html.Substring(0, $startFks) + $fksJS + $html.Substring($endFks)
```

### 6단계 — 제목 · 헤더 업체명 교체

```powershell
# <title> 교체
$html = [regex]::Replace($html, '<title>ERD - [^<]+</title>',
    "<title>ERD - $safeName WMS ($yymmdd)</title>")

# sidebar 헤더 교체
$html = [regex]::Replace($html, 'ERD Viewer · [^<]+',
    "ERD Viewer · $safeName WMS")
```

### 7단계 — 파일 저장

```powershell
[System.IO.File]::WriteAllText($outputFile, $html, [System.Text.Encoding]::UTF8)

$size   = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
$tblCnt = ([regex]::Matches($tablesJS, '"id":"')).Count
$fkCnt  = ([regex]::Matches($fksJS, '"ft":"')).Count
Write-Host "출력: $outputFile (${size} KB) — TABLES=$tblCnt, FKS=$fkCnt"
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

그룹 간 연결을 나타내는 매핑 테이블. 레이아웃 시 해당 그룹 직전에 별도 행으로 배치된다.

| 테이블 | 앞에 배치되는 서브그룹 |
|---|---|
| `wms_inbiz_inwh` | `wms-inwh` |
| `wms_outbiz_outwh` | `wms-outwh` |
| `wms_outbiz_invoice` | `wms-invoice` |
| `wms_outbiz_load` | `wms-load` |

새 커넥터 테이블이 생기면 HTML 파일의 `MAPPING_TBLS`, `BEFORE_SG` 양쪽에 모두 추가한다.

---

## 레이아웃 자동 배치 규칙 (참고)

`relayoutBySubGroup()` 함수가 아래 규칙으로 테이블을 배치한다.

- 부모 그룹 순서: `wms → mdm → sm → sif → wes`
- 각 서브그룹 내 테이블은 이름 길이 → 알파벳 순으로 정렬 후 1행으로 배치
- 서브그룹 간격: 50px / 부모 그룹 간격: 80px / 커넥터 행 간격: 24px
- 테이블 폭: 320px (CSS) / 배치 계산 폭: 300px / 간격: 28px

FK 관계선은 `drawLines()` 함수가 담당한다.
- 인접 테이블(gap < 60px): 아래 방향으로 U자 우회 (`loopY = max_bottom + 80`)
- 원거리 테이블: S자 베지어 커브 (수평 연결)
- 선 색상: 주황색(`#f97316`) / 굵기: 2.5px / `vector-effect: non-scaling-stroke`

---

## 완료 체크리스트

- [ ] BE 경로 확정 및 `application-test.properties` 존재 확인
- [ ] DB 접속 정보 파싱 완료 (host / port / dbname / user)
- [ ] `psql.exe` 연결 정상
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
✓ ERD 뷰어 생성 완료

업체명  : {업체명}
DB      : {host}:{port}/{dbname}
템플릿  : SD.211-ERD_{이전업체}_{이전날짜}.html
출력파일: output\03 설계(SD)\SD.211-ERD_{업체명}_{YYMMDD}.html
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

## 참고: scripts 폴더

`.claude\skills\SD_334\scripts\` 의 Python 스크립트들(`01_scan_config.py`, `02_extract_schema.py`, `03_generate_html.py`)은 이전 vis-network 기반 구현의 참고용으로 보존되어 있으며, 현재 이 스킬에서는 호출하지 않는다. 모든 처리는 위 PowerShell 절차로 진행된다.
