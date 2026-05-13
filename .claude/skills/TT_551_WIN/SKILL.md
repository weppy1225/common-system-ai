---
name: TT_551_WIN
description: 【DB 이관계획서 엑셀 생성 (Windows 전용)】 Windows 네이티브(PowerShell) 환경에서 선행 스킬 `/TT_550_WIN` 이 생성한 `output/05 이행(TT)/TT_550_DATA_{고객사명}_{YYMMDD}/` 폴더와 그 안의 `manifest.json` + 그룹별 `.sql` 파일들을 입력으로 받아, `template/05 이행(TT)/DB이관계획서_템플릿.xlsx` 를 base로 DB 이관계획서 엑셀 파일을 자동 생성합니다. 산출물은 `output/05 이행(TT)/TT_551_DB이관계획서_{고객사명}_{YYMMDD}.xlsx` 단일 파일이며, 자동으로 채워지는 항목(고객사·원본 DB·그룹 목록·테이블·row 수·SQL 파일명·적용 순서)과 사람이 입력하는 항목(담당자·이관 예정일자·사전 조건·롤백 계획)이 함께 들어갑니다. /TT_551_WIN 형식으로 실행하며 TT_550 출력 폴더 경로·담당자명·이관 예정일자는 실행 시 묻습니다. 템플릿 sentinel 컨벤션(`{{customer}}`, `{{rows:groups}}` 등)을 사용해 셀 위치 변경에도 유연하게 대응합니다. Python + openpyxl 사용. DB 이관계획서 작성, 이관 일정 보고서, 마스터 데이터 이관 산출물, TT_550 결과를 정리한 엑셀 산출물 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "DB 이관계획서 만들어줘", "이관계획서 엑셀로", "TT_551_WIN 실행해줘", "이관 산출물 만들어줘", "TT_550 결과를 엑셀로 정리" 라고 말해도 이 스킬을 사용합니다. 단, SQL dump 파일이 아직 없으면 먼저 /TT_550_WIN 을 실행해야 합니다. SQL dump만 필요하면 /TT_550_WIN, DDL(스키마) SQL 만 필요하면 /SD_333_WIN 을 사용합니다. Linux/WSL/macOS 환경에서는 별도의 기본 TT_551 스킬을 사용합니다(있는 경우).
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 이관계획서 엑셀 생성 (Windows 전용) [TT_551_WIN]

선행 스킬 `/TT_550_WIN` 이 생성한 SQL 패키지 폴더(`TT_550_DATA_*`)와 그 안의 `manifest.json` 을 입력으로,
`template/05 이행(TT)/DB이관계획서_템플릿.xlsx` 를 base로 **DB 이관계획서 엑셀** 을 자동 생성한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요.
>
> **전체 흐름:**
> ```
> [BE 팀] 테이블에 @migrate: 마커 부여
>           ↓
> /TT_550_WIN   → TT_550_DATA_*/{group}.sql + manifest.json 생성
>           ↓
> /TT_551_WIN   → 위 폴더 입력 → 이관계획서 엑셀 생성  ← (이 스킬)
> ```
>
> **이 스킬은 DB에 접속하지 않는다.** TT_550 의 산출물(텍스트 파일들)만 읽어 엑셀을 채운다.
> DB 정보가 필요하면 TT_550 단계에서 이미 `manifest.json` 에 기록되어 있다 (password 제외).

> **Python + openpyxl 필수.** PowerShell 폴백 없음. 다른 엑셀 산출물 스킬(PI_421_WIN, SD_332 등)과 동일한 도구 의존성.

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

## 사전 준비

### 1) 템플릿 파일 배치 (1회)

기존 `input/TT.551/TT_551_DB이관계획서_20260511.xlsx` 를 템플릿 위치로 이동/복사:

```
template/05 이행(TT)/DB이관계획서_템플릿.xlsx
```

### 2) 템플릿에 Sentinel Placeholder 박기 (1회, 사람이 엑셀에서 직접)

엑셀을 열어서 자동 채워질 셀에 sentinel 텍스트를 박는다. 위치는 자유 (스킬이 sentinel 을 찾아서 치환).

| Sentinel | 의미 | 치환값 예시 |
|---|---|---|
| `{{customer}}` | 고객사명 | `가나다물류` |
| `{{author}}` | 담당자 | `홍길동` |
| `{{generated_at}}` | 산출물 생성일시 | `2026-05-12 14:33` |
| `{{plan_date}}` | 이관 예정일자 | `2026-05-20` |
| `{{source_host}}` | 원본 DB host | `192.168.10.20` |
| `{{source_db}}` | 원본 DB 이름 | `wms-cloud-test` |
| `{{source_schema}}` | 원본 schema | `public` |
| `{{source_pg_version}}` | 원본 PG 버전 | `15.4` |
| `{{group_count}}` | 그룹 개수 | `3` |
| `{{table_count}}` | 테이블 총 개수 | `5` |
| `{{row_count_total}}` | 전체 row 합계 | `244` |
| `{{precondition}}` | 사전 조건 (사용자 입력) | (multiline 텍스트) |
| `{{rollback}}` | 롤백 계획 (사용자 입력) | (multiline 텍스트) |
| `{{warnings}}` | 마커 누락 경고 (있을 시) | `sm_legacy_temp, mdm_obsolete` |

### 3) 표 시작 마커 (반복 행 채울 위치)

표 데이터를 채워 넣을 시작 위치는 **마커 셀**로 지정. 마커 셀이 있는 **행**부터 데이터가 한 행씩 채워진다.

| 마커 | 반복 단위 | 채워지는 컬럼 (마커 행 기준 우측으로) |
|---|---|---|
| `{{rows:groups}}` | 그룹별 1행 | 순번 / 그룹키 / 그룹명 / 테이블 수 / row 합계 / SQL 파일명 / 파일 크기 |
| `{{rows:tables}}` | 그룹 × 테이블 1행 | 순번 / 그룹명 / 테이블명 / 테이블 설명 / row 수 / FK 부모 / SQL 파일명 / 적용 순서 |

> **컬럼 순서는 마커 행에서 좌→우 순으로 자동 매칭된다.** 마커 셀 자체가 첫 번째 컬럼이 되고, 같은 행의 우측 셀에 데이터가 순서대로 들어간다.
> 마커 셀이 있는 시트 안에서, 마커 행을 첫 행으로 보고 그 아래로 행을 늘려가며 채운다 (기존 서식·테두리·머지셀 보존).

### 4) Python 의존성 확인 (PowerShell)

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

python -c "import openpyxl" 2>$null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user openpyxl
}
```

> `python` 실행 실패 시 `py -3` 로 재시도.

---

## 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 우선 사용하고, 부족한 값은 `AskUserQuestion` 으로 묻는다.

| 입력 | 설명 | 자동 추출 가능 여부 |
|---|---|---|
| TT_550 출력 폴더 경로 | `output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}\` 절대/상대 경로. | △ — 폴더 미지정 시 가장 최근 `TT_550_DATA_*` 자동 탐색 후 확인 |
| 고객사명 | 출력 파일명용 | ✅ `manifest.json` 의 `customer` 에서 자동 추출 |
| 담당자명 | 이관계획서 작성자 | ❌ AskUserQuestion |
| 이관 예정일자 | 고객사 DB 적용 예정일 (YYYY-MM-DD) | ❌ AskUserQuestion |
| 사전 조건 | 이관 전 확인 사항 (multiline) | ❌ AskUserQuestion (선택, 빈 값 허용) |
| 롤백 계획 | 실패 시 복구 절차 (multiline) | ❌ AskUserQuestion (선택, 빈 값 허용) |

검증:
- TT_550 폴더가 없거나 `manifest.json` 이 없으면 `/TT_550_WIN` 먼저 실행하라고 안내 후 종료.
- 템플릿 파일이 없으면 사전 준비 1)·2) 단계를 안내 후 종료.
- 이관 예정일자가 YYYY-MM-DD 형식이 아니면 다시 묻는다.

---

## 경로 정의

```
BASE       = C:\zinide\workspace\cloud-wms-doc
TEMPLATE   = template\05 이행(TT)\DB이관계획서_템플릿.xlsx
INPUT_DIR  = output\05 이행(TT)\TT_550_DATA_{고객사명}_{YYMMDD}\
OUTPUT_FILE = output\05 이행(TT)\TT_551_DB이관계획서_{고객사명}_{YYMMDD}.xlsx
TMP_DIR    = output\05 이행(TT)\.tt551_tmp
SCRIPTS    = .claude\skills\TT_551_WIN\scripts
```

`{YYMMDD}` 는 오늘 날짜.

---

## 워크플로우 (5단계)

```
[1] 입력 받기 + TT_550 산출물 검증
[2] manifest.json 로딩 + 사용자 입력 보강
[3] 템플릿 복사 → 출력 파일 생성
[4] Sentinel 치환 + 표 반복 행 채우기
[5] 완료 보고
```

```
.claude\skills\TT_551_WIN\scripts\
├── 01_load_inputs.py     # 2단계 — manifest.json 로딩 + 검증
└── 02_fill_excel.py      # 3·4단계 — 템플릿 복사 + sentinel 치환 + 표 채우기
```

---

### 1단계 — 입력 받기 + TT_550 산출물 검증

`$ARGUMENTS` 와 `AskUserQuestion` 으로 입력 수집.

TT_550 폴더 자동 탐색 (사용자가 폴더 미지정 시):
```powershell
$candidates = Get-ChildItem "output\05 이행(TT)" -Directory -Filter "TT_550_DATA_*" |
              Sort-Object LastWriteTime -Descending
```
- 후보 0개 → `/TT_550_WIN` 먼저 실행 안내 후 종료.
- 후보 1개 → 사용자에게 "이 폴더로 진행할까요?" 확인.
- 후보 2개 이상 → `AskUserQuestion` 으로 선택.

선택된 폴더 안의 다음 파일들 존재 확인:
- `manifest.json` (필수)
- `.sql` 파일 1개 이상 (필수)

템플릿 파일 존재 확인:
- `template\05 이행(TT)\DB이관계획서_템플릿.xlsx`
- 없으면 사전 준비 안내 후 종료.

---

### 2단계 — manifest.json 로딩 + 사용자 입력 보강

**스크립트**: `scripts\01_load_inputs.py`
**입력**: `INPUT_DIR\manifest.json`, 사용자 입력 (담당자/일자/사전조건/롤백)
**출력**: `tmp\fill_data.json`

`manifest.json` 에서 자동 추출:
- `customer`
- `source_db.{host, database, schema, pg_version}`
- `groups[].{group_key, group_desc, sql_file, file_size_kb, tables[], insert_order, delete_order}`
- `warnings.unmarked_master_tables`

집계 계산:
- `group_count` = `len(groups)`
- `table_count` = `sum(len(g.tables) for g in groups)`
- `row_count_total` = `sum(t.rows for g in groups for t in g.tables)`

사용자 입력 추가:
- `author`, `plan_date`, `precondition`, `rollback`, `generated_at`

최종 `fill_data.json` 예시:
```json
{
  "scalars": {
    "customer": "가나다물류",
    "author": "홍길동",
    "generated_at": "2026-05-12 14:33",
    "plan_date": "2026-05-20",
    "source_host": "192.168.10.20",
    "source_db": "wms-cloud-test",
    "source_schema": "public",
    "source_pg_version": "15.4",
    "group_count": 3,
    "table_count": 5,
    "row_count_total": 244,
    "precondition": "1) 고객사 DB 백업 완료\n2) 운영 트래픽 차단 (점검 모드)\n3) DDL 적용 완료 확인",
    "rollback": "1) 트랜잭션 ROLLBACK 자동 (BEGIN/COMMIT 구조)\n2) 백업 RESTORE: pg_restore -d <db> <backup.dump>",
    "warnings": "sm_legacy_temp, mdm_obsolete"
  },
  "rows": {
    "groups": [
      { "no": 1, "group_key": "01_common_code", "group_desc": "공통코드", "table_count": 2, "row_sum": 99,  "sql_file": "01_common_code.sql", "file_size_kb": 8.2 },
      { "no": 2, "group_key": "02_biz",         "group_desc": "사업장",   "table_count": 2, "row_sum": 11,  "sql_file": "02_biz.sql",         "file_size_kb": 1.4 },
      { "no": 3, "group_key": "07_menu",        "group_desc": "메뉴",     "table_count": 1, "row_sum": 142, "sql_file": "07_menu.sql",        "file_size_kb": 24.0 }
    ],
    "tables": [
      { "no": 1, "group_desc": "공통코드", "table_name": "sm_comm_h",   "table_desc": "공통코드 헤더",   "rows": 12,  "fk_parent": "",          "sql_file": "01_common_code.sql", "apply_order": 1 },
      { "no": 2, "group_desc": "공통코드", "table_name": "sm_comm_d",   "table_desc": "공통코드 디테일", "rows": 87,  "fk_parent": "sm_comm_h", "sql_file": "01_common_code.sql", "apply_order": 2 },
      { "no": 3, "group_desc": "사업장",   "table_name": "mdm_biz",     "table_desc": "사업장 마스터",   "rows": 3,   "fk_parent": "",          "sql_file": "02_biz.sql",         "apply_order": 1 },
      { "no": 4, "group_desc": "사업장",   "table_name": "mdm_biz_biz", "table_desc": "사업장 매핑",     "rows": 8,   "fk_parent": "mdm_biz",   "sql_file": "02_biz.sql",         "apply_order": 2 },
      { "no": 5, "group_desc": "메뉴",     "table_name": "sm_menu",     "table_desc": "메뉴",            "rows": 142, "fk_parent": "",          "sql_file": "07_menu.sql",        "apply_order": 1 }
    ]
  }
}
```

---

### 3단계 — 템플릿 복사 → 출력 파일 생성

PowerShell:

```powershell
$outDir = "output\05 이행(TT)"
$customer = "{고객사명}"
$yymmdd = (Get-Date -Format "yyMMdd")
$outFile = Join-Path $outDir "TT_551_DB이관계획서_${customer}_${yymmdd}.xlsx"

Copy-Item -Path "template\05 이행(TT)\DB이관계획서_템플릿.xlsx" `
          -Destination $outFile -Force
```

> 출력 파일이 이미 존재하면 사용자에게 덮어쓸지 확인.

---

### 4단계 — Sentinel 치환 + 표 반복 행 채우기

**스크립트**: `scripts\02_fill_excel.py`
**입력**: `tmp\fill_data.json`, 출력 엑셀 파일 경로
**출력**: 채워진 `OUTPUT_FILE`

스크립트 동작:

```python
import openpyxl
from openpyxl import load_workbook

wb = load_workbook(OUTPUT_FILE)

# 1) 스칼라 sentinel 치환 — 모든 시트 모든 셀 순회
for ws in wb.worksheets:
    for row in ws.iter_rows():
        for cell in row:
            if not isinstance(cell.value, str):
                continue
            for key, val in fill_data["scalars"].items():
                token = "{{" + key + "}}"
                if token in cell.value:
                    cell.value = cell.value.replace(token, str(val))

# 2) 표 반복 행 채우기 — {{rows:xxx}} 마커 찾기
for ws in wb.worksheets:
    for row in ws.iter_rows():
        for cell in row:
            if not isinstance(cell.value, str):
                continue
            if cell.value.strip().startswith("{{rows:"):
                row_key = cell.value.strip()[len("{{rows:"):-2]   # "groups" or "tables"
                _fill_table_rows(ws, cell, fill_data["rows"][row_key])

wb.save(OUTPUT_FILE)
```

`_fill_table_rows` 의 핵심 동작:
1. 마커 셀이 있는 행을 첫 데이터 행으로 본다.
2. 같은 행의 마커 셀부터 우측으로 dict 의 값 순서대로 1개씩 채운다 (첫 셀에는 마커 대신 첫 컬럼 값).
3. 데이터가 1행 초과면 행 삽입 (`ws.insert_rows`) 으로 아래로 늘리고 같은 방식으로 채운다.
4. **기존 서식 보존**: `cell.font`, `cell.alignment`, `cell.border` 를 마커 행에서 복사하여 신규 행에 적용.
5. **머지셀 처리**: 마커 셀이 머지셀 안에 있으면 같은 머지 패턴을 신규 행에도 적용 (openpyxl 의 `merged_cells.ranges` 사용).

> 표 컬럼 매칭: 마커 행 기준 좌→우로 dict 키 순서대로 채운다. 키 순서는 `fill_data.json` 의 dict 순서를 따른다.
> 만약 표 컬럼 수가 dict 키 수와 다르면 콘솔에 경고 + 짧은 쪽에 맞춰 채운다 (남는 셀은 빈 칸, 남는 키는 무시).

---

### 5단계 — 완료 보고

```
✓ DB 이관계획서 엑셀 생성 완료 [TT_551_WIN]

입력 (TT_550 산출물):
  폴더:        output\05 이행(TT)\TT_550_DATA_가나다물류_260512\
  manifest:    manifest.json (3 groups, 5 tables, 244 rows)
  SQL 파일:    01_common_code.sql, 02_biz.sql, 07_menu.sql

엑셀 자동 채움:
  표지:        고객사·담당자·생성일시·이관예정일자
  원본 DB:     192.168.10.20:5432/wms-cloud-test (schema=public, PG 15.4)
  그룹 표:     3 행 (01_common_code, 02_biz, 07_menu)
  테이블 표:   5 행 (FK 정순)
  경고:        sm_legacy_temp, mdm_obsolete (마커 누락)

사용자 입력:
  담당자:      홍길동
  이관 예정일: 2026-05-20
  사전 조건:   3 항목
  롤백 계획:   2 항목

출력 파일:    output\05 이행(TT)\TT_551_DB이관계획서_가나다물류_260512.xlsx
파일 크기:    {N} KB

다음 단계:
  - 엑셀 열어서 자동 채움 결과 검토 + 빠진 항목 수동 보완
  - 고객사 협의 후 이관 예정일자 확정
  - 이관일에 psql -f 로 SQL 파일을 순번 순서대로 적용
```

---

## 완료 체크리스트

- [ ] TT_550 출력 폴더 경로 확정 (`manifest.json` + `.sql` 파일들 존재 확인)
- [ ] 템플릿 파일 존재 (`template\05 이행(TT)\DB이관계획서_템플릿.xlsx`)
- [ ] `python -c "import openpyxl"` 성공 (필요 시 `pip install --user openpyxl`)
- [ ] 사용자 입력 4가지 (담당자/이관예정일자/사전조건/롤백) 수집
- [ ] `tmp\fill_data.json` 생성
- [ ] 출력 엑셀 파일 생성 (`OUTPUT_FILE`)
- [ ] 스칼라 sentinel 치환 완료
- [ ] 표 반복 행 채우기 완료 (groups / tables)
- [ ] `tmp\` 삭제

---

## 주의사항

- **이 스킬은 DB에 접속하지 않는다.** 모든 정보는 `manifest.json` + `.sql` 파일에서 추출. DB 변경/조회 일절 없음.
- **템플릿 sentinel 컨벤션 1회 셋업 필요**: 첫 사용 시 `template/05 이행(TT)/DB이관계획서_템플릿.xlsx` 를 열어 자동 채울 셀에 `{{customer}}`, `{{rows:groups}}` 같은 sentinel 을 박아둔다. 이후 자동.
- **서식 보존**: openpyxl `load_workbook` 이 사용자가 만든 셀 서식·테두리·머지·차트·이미지를 보존한다.
- **표 행 확장**: 표 안에 데이터 행이 마커 행 하나뿐인 경우, 데이터 개수만큼 행을 자동 삽입한다. 기존 서식·테두리가 복제된다.
- **머지셀 주의**: 마커가 머지셀 안에 있으면 머지 패턴도 함께 복제된다. 머지셀 안에서 sentinel 위치를 너무 복잡하게 잡으면 의도와 다르게 채워질 수 있으니 단순한 위치(좌상단 단일 셀)에 두는 것을 권장.
- **여러 시트 지원**: sentinel/마커 는 통합문서 전체 시트를 순회한다. 시트 1개에 모든 sentinel을 모아두든, 여러 시트에 나눠두든 무관.
- **데이터가 0건인 그룹**: TT_550 에서 dump 0건 그룹이 있으면 manifest 에는 들어가지만 row_sum=0 으로 표시.
- **한글 콘솔 출력 깨짐 방지**:
  ```powershell
  $env:PYTHONUTF8 = "1"
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  chcp 65001 | Out-Null
  ```
- **경로 공백·한글 처리**: `output\05 이행(TT)` 처럼 공백·한글 포함 경로는 반드시 큰따옴표.
- **출력 파일이 이미 존재하면**: 덮어쓸지 사용자 확인.
- **사용자 입력 multiline 처리**: 사전조건/롤백은 여러 줄 입력이 가능하므로 `AskUserQuestion` 의 "Other" 분기로 자유 텍스트 받기. 셀 안에서 줄바꿈은 `\n` → `cell.alignment.wrap_text=True` + Excel 줄바꿈으로 처리.
- **함께 보면 좋은 스킬:**
  - 선행: `/TT_550_WIN` (이 스킬의 입력 생성)
  - DDL(스키마) SQL → `/SD_333_WIN`
  - 공통코드정의서 엑셀 → `/SD_332`
