---
name: RA_222
description: 회의록 엑셀 분석 → 요구사항정의서 엑셀 자동 생성 (Windows/WSL/Linux 자동 감지). "요구사항 뽑아줘", "회의록 정리해줘", "RA 산출물 만들어줘", "요구사항정의서 만들어줘" 요청 시 사용. /RA_222 {고객사명}
allowed-tools: Bash, PowerShell, Read, Write, Edit, Agent
---

# 요구사항정의서 자동 생성 (Windows/WSL/Linux/Mac 통합) [RA_222]

업체명: **$ARGUMENTS**

`input/RA.212/` 폴더의 회의록 Excel 파일들을 3-에이전트 파이프라인으로 분석하여
`output/02 분析(RA)/RA.222-요구사항정의서_{업체명}_{YYMMDD}.xlsx` 파일을 생성한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션] — `python` 실행.
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션] — `python3` 실행.
```

> Python 스크립트(`scripts/*.py`)는 양쪽에서 공유. 차이는 `python` vs `python3` 명령뿐.

---

## 사전 준비 (공통)

### 업체명 확정

`$ARGUMENTS`가 비어 있으면 `input/RA.212/` 파일명에서 자동 추출한다.
파일명 패턴: `{코드}-{문서명}_{업체명}_{날짜}.xlsx` → 두 번째 `_` 구분자 사이 값.

### 출력 경로

```
OUTPUT_DIR  = output/02 분析(RA)
TMP_DIR     = output/02 분析(RA)/tmp
OUTPUT_FILE = output/02 분析(RA)/RA.222-요구사항정의서_{업체명}_{YYMMDD}.xlsx
TEMPLATE    = template/02 분析(RA)/RA.314-요구사항정의서.xlsx
```

`OUTPUT_DIR` 과 `TMP_DIR` 폴더가 없으면 생성한다.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
```

### W-1) 에이전트 1 호출 명령 (회의록 읽기)

```powershell
Set-Location $DocRoot
python ".claude\skills\RA_222\scripts\01_read_meetings.py"
```

### W-3) 에이전트 3 호출 명령 (Excel 생성)

```powershell
Set-Location $DocRoot
python ".claude\skills\RA_222\scripts\03_generate_excel.py"
```

---

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
```

### B-1) 에이전트 1 호출 명령 (회의록 읽기)

```bash
cd "$DOC_ROOT"
python3 .claude/skills/RA_222/scripts/01_read_meetings.py
```

### B-3) 에이전트 3 호출 명령 (Excel 생성)

```bash
cd "$DOC_ROOT"
python3 .claude/skills/RA_222/scripts/03_generate_excel.py
```

---

## 3-에이전트 파이프라인 (공통)

3개 에이전트를 **순차적으로** `Agent` 툴로 실행한다.
각 에이전트는 중간 결과를 JSON 파일로 저장하여 다음 에이전트에 전달한다.

---

### 에이전트 1 — 회의록 읽기

**목적**: `input/RA.212/` 의 모든 xlsx 파일을 읽어 원문 내용을 JSON으로 추출한다.

**에이전트 프롬프트**:

```
스킬 경로: .claude/skills/RA_222
실행 환경에 따라 OS 분기 블록의 명령을 Bash 도구로 실행하라:
- Windows: powershell.exe -Command "Set-Location <DocRoot>; python '.claude\skills\RA_222\scripts\01_read_meetings.py'"
- Bash:    cd <DocRoot> && python3 .claude/skills/RA_222/scripts/01_read_meetings.py

실행 후 "저장 완료" 메시지와 파일 목록을 확인하고 결과를 반환하라.
스크립트가 없거나 실행 오류 시 스크립트 내용을 Read 툴로 읽어 직접 실행하라.
```

---

### 에이전트 2 — 요구사항 분석

**목적**: 추출된 원문에서 요구사항을 도출하여 9개 부문으로 분류한다.

**에이전트 프롬프트**:

```
업체명: {$ARGUMENTS 또는 파일명 자동 추출값}

output/02 분析(RA)/tmp/meeting_raw.json 파일을 Read 툴로 읽어 회의록 내용을 분석하라.

[회의록 구조 파싱 힌트]
- 각 sheet_name = 회의 날짜 (예: "20260319(목)") → 작성일자 추출
- rows 배열에서 "▶ 회의 내용" 또는 "회의 내용" 이후 행이 핵심 협의 내용
- "1. WMS 업무 협의", "2. ERP 인터페이스 협의" 등 섹션별 분류 단서 존재
- 번호+하위번호 체계(1) 2) ①)로 기재된 항목이 개별 요구사항 후보
- 시트명 날짜 추출: "20260319(목)" → "2026-03-19"

[분류 기준 - 9개 부문]
| 코드 | 부문  | 도출 기준                                        |
|------|-------|------------------------------------------------|
| CO   | 공통  | 시스템 구성, 사용자/권한, 알람, 공통 기능           |
| MD   | 기준  | 기준정보 (사업장, 창고, 품목, 거래처 등)            |
| IW   | 입고  | 입하/입고처리 관련 협의 사항                       |
| RM   | 반품  | 반품처리 관련 협의 사항                            |
| IV   | 재고  | 재고조회, 재고조정, 실사 관련 협의 사항             |
| OW   | 출고  | 출고지시, 출하, 배송 관련 협의 사항                |
| IF   | I/F   | ERP/물류사/DAS 등 인터페이스 연동 협의 사항         |
| PDA  | PDA   | PDA 기기 관련 협의 사항                           |
| ERR  | 예외  | 예외처리, 오류 대응, 기타 비기능 요건              |

[요구사항 ID 체계]
FUR-{코드}-{순번3자리} (예: FUR-CO-001, FUR-IW-003)

[각 요구사항 항목]
- 요구사항명: 간결한 기능명 (예: "세트해체 처리")
- 내용: 회의 결정사항 기반 상세 설명. 임의 내용 작성 금지
- 부문: CO / MD / IW / RM / IV / OW / IF / PDA / ERR
- 요구처: I/F 항목 → "IT솔루션팀", 나머지 → "물류팀"
- 작성일자: 해당 협의가 이루어진 회의 날짜 (YYYY-MM-DD)
- 우선순위: A(필수) / B(권장) / C(선택)
- 수용여부: "수용" / "수용불가" / "고려"
- 비고: 특이사항 (없으면 빈 문자열)

[원칙]
- 회의록에 없는 내용을 임의로 만들지 않는다
- 메뉴현황에만 있고 회의록 협의 내용이 없으면 "메뉴 존재 확인" 수준으로만 기재
- 부문 순서: CO → MD → IW → RM → IV → OW → IF → PDA → ERR

분석 결과를 아래 JSON 구조로 output/02 분析(RA)/tmp/requirements.json 에 저장하라:

{
  "company": "{업체명}",
  "generated_at": "YYYY-MM-DD",
  "requirements": [
    {
      "id": "FUR-CO-001",
      "name": "요구사항명",
      "section_code": "CO",
      "section_name": "공통",
      "content": "상세 내용",
      "requester": "물류팀",
      "date": "YYYY-MM-DD",
      "priority": "A",
      "acceptance": "수용",
      "remark": ""
    }
  ]
}

저장 후 부문별 건수 요약을 출력하라.
```

---

### 에이전트 3 — Excel 생성

**목적**: 분류된 요구사항을 템플릿 Excel에 기입하여 최종 산출물을 생성한다.

**에이전트 프롬프트**:

```
스킬 경로: .claude/skills/RA_222
실행 환경에 따라 OS 분기 블록의 명령을 Bash 도구로 실행하라:
- Windows: powershell.exe -Command "Set-Location <DocRoot>; python '.claude\skills\RA_222\scripts\03_generate_excel.py'"
- Bash:    cd <DocRoot> && python3 .claude/skills/RA_222/scripts/03_generate_excel.py

실행 후 "생성 완료" 메시지와 부문별 건수를 확인하고 결과를 반환하라.
```

---

## 완료 체크리스트 (공통)

- [ ] `input/RA.212/` 파일 전체 읽기 완료 (회의록 전 시트, 메뉴현황 전 시트)
- [ ] 업체명 확정 ($ARGUMENTS 또는 파일명 자동 추출)
- [ ] 요구사항 ID 체계 `FUR-{코드}-{순번3자리}` 정확히 부여
- [ ] 회의록에 없는 내용을 임의로 작성하지 않음
- [ ] 부문 순서: CO → MD → IW → RM → IV → OW → IF → PDA → ERR
- [ ] 요구처: I/F 항목은 IT솔루션팀, 나머지는 물류팀
- [ ] 작성일자: 해당 협의가 이루어진 회의 날짜 기준
- [ ] `output/02 분析(RA)/RA.222-요구사항정의서_{업체명}_{YYMMDD}.xlsx` 생성 확인

---

## 완료 보고 형식

```
✓ 요구사항정의서 생성 완료 [RA_222]

실행 환경: Windows PowerShell  또는  Bash on Linux/Mac/WSL
업체명:    {업체명}
출력파일:  output/02 분析(RA)/RA.222-요구사항정의서_{업체명}_{YYMMDD}.xlsx

요구사항 현황:
  - 공통(CO):   N건
  - 기준(MD):   N건
  - 입고(IW):   N건
  - 반품(RM):   N건
  - 재고(IV):   N건
  - 출고(OW):   N건
  - I/F(IF):    N건
  - PDA:        N건
  - 예외(ERR):  N건
  ─────────────
  - 합계:       N건

회의록 파일: {읽은 파일 목록}
```

---

## 주의사항

### Windows 특화

- **Python 실행 명령**: `python` (PATH 등록 필요). `py -3` 도 가능.
- **경로**: Windows 경로 형식(`\`)을 사용한다.

### Bash 특화

- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력. 스크립트 내부에서 자동 처리.
