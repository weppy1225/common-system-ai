---
name: PI_422
description: 통합테스트보고서 엑셀 생성 (ui.md 스캔→시나리오 자동 생성, Windows/WSL/Linux 자동 감지). /PI_422
when_to_use: "통합테스트보고서 만들어줘", "통합테스트 산출물 만들어줘", "통합테스트 시나리오 정리" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 통합테스트보고서 자동 생성 (Windows/WSL/Linux/Mac 통합) [PI_422]

`spec/{프로젝트}/` 아래 모든 `ui.md` 파일을 스캔하여 메뉴 목록을 추출하고,
메뉴별 기본 테스트 시나리오를 자동 생성한 뒤 `deliverables/10-templates/04 구현(PI)/PI_214-통합테스트보고서.xlsx` 템플릿을 복사·채워 `deliverables/30-output/04 구현(PI)/PI.422_통합테스트보고서_{고객사명}.xlsx` 로 저장한다.

> **의존성 안내**: Node.js + **xlsx-populate** 라이브러리(`deliverables/30-output/04 구현(PI)/node_modules/xlsx-populate`)
> Python 은 사용하지 않는다 (환경에 설치되어 있지 않아도 됨).
>
> 일반 `xlsx`(SheetJS Community) 는 셀 스타일을 유지하지 않아 템플릿 형식(병합/스타일/폰트/색상)을 모두 잃게 된다. 이 스킬은 형식 유지가 검증된 `xlsx-populate` 만 사용한다.

---

## OS 분기 및 공통 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 블록] → PowerShell 블록 사용.
- WSL / Linux / macOS (Bash):    uname 결과 (Linux/Darwin)
  → [Bash 블록] → bash 블록 사용.
```

> Node.js 스크립트(`scripts/gen_pi422.js`)는 같은 위치에서 동일하게 실행. 스크립트 내에서 `path.resolve(__dirname, '..', '..', '..', '..')` 패턴으로 BASE_DIR을 자동 감지하므로 OS를 구분하지 않는다.

---

## 사전 준비(공통)

### 1) 입력 확인

`$ARGUMENTS` 가 비어있으면 AskUserQuestion 으로 다음 정보를 묻는다.

| 입력 | 설명 |
|---|---|
| 고객사명 | 산출물 파일명에 들어갈 고객사/프로젝트 이름 |
| 담당자명 | 테스트 담당자의 이름 (예: 홍길동) |
| 테스트 기간 | 시작일 ~ 종료일 (예: 2026-05-12 ~ 2026-05-23) |
| SYSTEM | WMS(WEB), WMS(PDA) 등 테스트 대상 시스템명 (기본값: WMS(WEB)) |

### 2) 경로 정의

모든 경로는 git 최상위 디렉토리(`$DocRoot` / `$DOC_ROOT`) 기준.

```
DIST_DIR    = spec/{프로젝트}/   # 프로젝트명은 워크스페이스 폴더명에서 도출
OUTPUT_DIR  = deliverables/30-output/04 구현(PI)
SCRIPT      = .claude/skills/PI_422/scripts/gen_pi422.js
TEMPLATE    = deliverables/10-templates/04 구현(PI)/PI_214-통합테스트보고서.xlsx
OUTFILE     = deliverables/30-output/04 구현(PI)/PI.422_통합테스트보고서_{고객사명}.xlsx
XLSX_LIB    = deliverables/30-output/04 구현(PI)/node_modules/xlsx-populate
```

---

# === Windows 블록 (PowerShell) ===

### W-0) 경로 자동 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
$RepoPrefix = $RepoName -replace '-[^-]+$',''
```

### W-1) xlsx-populate 라이브러리 확인

```powershell
Set-Location $DocRoot
node -e "require('./deliverables/30-output/04 구현(PI)/node_modules/xlsx-populate'); console.log('ok')"
```

실패하면 `deliverables/30-output/04 구현(PI)/` 로 이동 후 `npm install xlsx-populate@^1.21.0` 실행.

### W-2) 스크립트 실행

```powershell
Set-Location $DocRoot
node ".claude/skills/PI_422/scripts/gen_pi422.js" "{고객사명}" "{담당자명}" "{테스트시작일}" "{테스트종료일}" "{SYSTEM}"
```

---

# === Bash 블록 (WSL/Linux/Mac) ===

### B-0) 경로 자동 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
REPO_PREFIX="${REPO_NAME%-*}"

DIST_DIR="$DOC_ROOT/dist"
OUTPUT_DIR="$DOC_ROOT/deliverables/30-output/04 구현(PI)"
SCRIPT="$DOC_ROOT/.claude/skills/PI_422/scripts/gen_pi422.js"
TEMPLATE="$DOC_ROOT/deliverables/10-templates/04 구현(PI)/PI_214-통합테스트보고서.xlsx"
XLSX_LIB="$OUTPUT_DIR/node_modules/xlsx-populate"
```

### B-1) xlsx-populate 라이브러리 확인

```bash
node -e "require('$DOC_ROOT/deliverables/30-output/04 구현(PI)/node_modules/xlsx-populate'); console.log('ok')"
```

실패하면 `deliverables/30-output/04 구현(PI)/` 로 이동 후 `npm install xlsx-populate@^1.21.0` 실행.

### B-2) 스크립트 실행

```bash
cd "$DOC_ROOT"
node ".claude/skills/PI_422/scripts/gen_pi422.js" "{고객사명}" "{담당자명}" "{테스트시작일}" "{테스트종료일}" "{SYSTEM}"
```

---

## 스크립트 동작 상세 (공통)

`gen_pi422.js` 가 수행하는 것:

### 2-1. spec/{프로젝트}/ 스캔 + prototype/{프로젝트}/_common-m/menu.html 스캔

- `spec/{프로젝트}/` 하위 모든 폴더에서 `ui.md` 파일을 탐색한다 (WEB 메뉴).
- `prototype/{프로젝트}/_common-m/menu.html` 에서 `.menu-cell` href 를 파싱하여 PDA 메뉴 목록 추출.
  - 메뉴코드: href 경로에서 추출 (예: `iv3000m/IVMV01.html` → `IVMV01`)
  - 메뉴명: `<img alt="...">` 값 사용
- `spec/{프로젝트}/{menuCode.toLowerCase()}/{menuCode.toLowerCase()}-02-ui.md` 있으면 해당 파일에서 (메뉴그룹명·메뉴명·목적) 사용
  - ui.md 없으면 그룹 폴더명(예: iv3000m)을 목적으로, 조회 4건만 생성
  - SYSTEM 컬럼은 PDA 메뉴에 `WMS(PDA)` 고정 (WEB 메뉴는 입력값을 사용)
- 각 `ui.md` 에서 아래 정보를 파싱한다:

| 파싱 항목 | 컬럼 |
|---|---|
| 메뉴그룹명 | `화면구성` 섹션의 `메뉴그룹명` 값 |
| 메뉴코드 | `화면구성` 섹션의 `메뉴코드` 값 |
| 메뉴명 | `화면구성` 섹션의 `메뉴명` 값 |
| UI유형 | `화면구성` 섹션의 `UI유형` 값 |
| 목적 | `화면구성` 섹션의 `목적` 값 |
| 업무규칙 | `공통 업무규칙` 섹션의 번호 목록 |
| 버튼 기능 | `기능 버튼` 섹션 (추가/수정/삭제/검색 등 자동 감지) |

### 2-2. 테스트 시나리오 자동 생성

**기본 시나리오 (모든 메뉴 공통)**:

| 기능 | 처리내용 | 확인내용 |
|---|---|---|
| 조회 | {메뉴명} 조회 | 검색 조건이 정상 작동 하는지? |
| 조회 | {메뉴명} 조회 | 검색 결과 목록이 정상 표시 되는지? |
| 조회 | {메뉴명} 조회 | 페이지 처리가 정상 작동 하는지? |

**버튼 기능별 추가 시나리오**:

| 버튼 감지 | 처리내용 | 확인내용 |
|---|---|---|
| 추가/등록 | {메뉴명} 등록 | 새 데이터 등록이 정상 작동 하는지? |
| 추가/등록 | {메뉴명} 등록 | 필수 항목 미입력 시 유효성 검사가 정상 작동 하는지? |
| 수정 | {메뉴명} 수정 | 기존 데이터 수정이 정상 작동 하는지? |
| 수정 | {메뉴명} 수정 | 수정 후 목록 반영이 정상 작동 하는지? |
| 삭제 | {메뉴명} 삭제 | 데이터 삭제가 정상 작동 하는지? |
| 삭제 | {메뉴명} 삭제 | 삭제 후 목록 갱신이 정상 작동 하는지? |
| 검색 | {메뉴명} 검색 | 선택 검색 조건 변경이 정상 작동 하는지? |
| 검색 | {메뉴명} 검색 | 검색한 데이터 목록 반영이 정상 작동 하는지? |

**업무규칙별 시나리오** (ui.md 업무규칙 섹션에서 자동 추출):
- 각 업무규칙 항목을 `확인내용` 으로 변환하여 테스트 케이스 1건씩 추가.
- `처리내용` 은 `{메뉴명} 업무규칙` 으로 고정.

### 2-3. 테스트 ID 채번

```
{메뉴코드}-{순번3자리}
예: MDCT01-001, MDCT01-002 ...
```

### 2-4. 템플릿 복사 및 데이터 채우기

1. `deliverables/10-templates/04 구현(PI)/PI_214-통합테스트보고서.xlsx` 를 `xlsx-populate.fromFileAsync()` 로 열어 모든 시트의 기존 스타일을 그대로 유지한다.
2. `통합테스트 시나리오` 시트의 3행 ~ 218행 까지 **기존 값을 모두 초기화** (`cell.value(undefined)`).
3. 3행부터 생성된 테스트 케이스를 `cell.value(...)` 로 채운다.

   | 컬럼 | 값 |
   |---|---|
   | A (업무화면) | 메뉴그룹명 |
   | B (테스트ID) | MDCT01-001 형식 |
   | C (항목) | 메뉴명 |
   | D (처리내용) | 처리내용 |
   | E (SYSTEM) | 입력값의 SYSTEM명 |
   | F (확인내용) | 확인내용 |
   | G (확인자) | 공란 |
   | H (확인일) | 입력값의 담당자명 |
   | I (확인결과) | 공란 |
   | J~L | 공란 |

4. `통합테스트 진행화면` 시트의 기존 데이터는 건드리지 않는다.
5. 표지 시트의 고객사명·테스트 기간 값도 자동으로 업데이트하지 않는다 (수동 갱신).
6. 완성 파일은 `deliverables/30-output/04 구현(PI)/PI.422_통합테스트보고서_{고객사명}.xlsx` 로 `wb.toFileAsync()` 로 저장한다.

> **형식 유지 검증 결과** (벤치마크 기준):
> - xlsx-populate: 병합/스타일/폰트/색상 시트 7개 모두 유지, 실행 397ms, 산출물 195KB.
> - ExcelJS: 데이터는 채우나 폰트 sz10→sz11 변환 발생 후 사용 불가.
> - xlsx (SheetJS Community): 모든 셀 스타일 잃음, 산출물 5.7MB로 비정상 → 사용 불가.

### 3) 결과 확인

스크립트 완료 후 아래를 확인한다:
- 산출물 파일 존재 여부
- 생성된 전체 테스트 케이스 수
- 메뉴별 케이스 수 요약

---

## 완료 보고 형식

```
✅ 통합테스트보고서 생성 완료 [PI_422]

실행 환경: Windows PowerShell  또는  Bash on Linux/Mac/WSL
산출물 파일: deliverables/30-output/04 구현(PI)/PI.422_통합테스트보고서_{고객사명}.xlsx
담당자:    {담당자명}
기간:     {시작일} ~ {종료일}

탐지 메뉴: N개 / 전체 테스트 케이스: N건
메뉴별 케이스:
  - 기준정보 / 거래처관리 [MDCT01]: N건
  - 기준정보 / 프로모션관리 [MDPR01]: N건
  ...
```

---

## 주의사항 (공통)

- **Node.js 필수**: Python 은 사용하지 않는다. 라이브러리 경로: `deliverables/30-output/04 구현(PI)/node_modules/xlsx-populate`.
- **xlsx (SheetJS Community) 절대 사용 금지**: 셀 스타일을 유지하지 않아 템플릿 형식이 모두 사라진다.
- **ui.md 없으면 건너뜀**: 해당 메뉴 폴더를 경고 없이 건너뛰고 다음 폴더 보고한다.
- **템플릿 필수**: `deliverables/10-templates/04 구현(PI)/PI_214-통합테스트보고서.xlsx` 가 없으면 종료하고 사용자에게 알린다.
- **기존 파일 덮어쓰기**: 동일 파일명 있으면 확인 없이 덮어쓴다 (별도 확인 없음).
- **spec/{프로젝트}/ 없으면**: 스크립트가 경고 메시지를 출력하고 종료한다.
- **케이스 행 제한**: 템플릿이 3~218행(216건) 수용한다. 케이스가 더 많으면 이후 행이 잘려 산출물에 포함되지 않는다 (스크립트가 WARN 로그 출력).
