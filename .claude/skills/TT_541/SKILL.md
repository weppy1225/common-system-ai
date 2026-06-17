---
name: TT_541
description: PC 사용자매뉴얼 PPTX 생성 (Playwright 데스크탑 1440×900 화면 캡처, python-pptx). /TT_541
when_to_use: "PC 사용자매뉴얼 만들어줘", "사용자 매뉴얼 PPT 뽑아줘", "데스크탑 화면 캡처해서 PPT 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PC 사용자매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_541]

입력 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 경로(또는 사용자가 직접 입력하는 BASE_URL)에서 dev 서버를 확인하고, **Playwright 헤드리스 브라우저(데스크탑 1440×900, 한국어 로캘 ko-KR)** 로 **PC 메뉴별** 화면을 캡처한 뒤, **사용자매뉴얼 샘플 pptx 를 base로 python-pptx** 로 PC 사용자매뉴얼 PPTX를 `output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx` 파일로 생성한다.

---

## OS 분기 및 공통 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 블록] → `python`/`node` 실행, Windows 경로(`\`).
- WSL / Linux / macOS (Bash):    uname 결과 (Linux/Darwin)
  → [Bash 블록] → `python3`/`node` 실행, POSIX 경로(`/`).
```

> Node.js 스크립트(`scripts/01_scan_project.js`, `scripts/02_capture_screens.js`)와 Python 스크립트(`scripts/03_make_pptx.py`)는 같은 위치에서 동일하게 실행된다. 차이는 `python` vs `python3` 명령, 경로 구분자뿐.

---

## 실행 변수
- FE 프로젝트 경로 → `C:\zinide\workspace\wms-{프로젝트코드}-fe` (Win) 또는 `/mnt/c/zinide/workspace/wms-{프로젝트코드}-fe` (WSL)
- BE 프로젝트 경로 → (사용 안 함. FE만 필요)
- ex) BASE_URL → `localhost:5173`
- 로그인 정보 → `test / 1111`
- 예시메뉴 / 시작-종료메뉴 : `mdpd01`
- 뷰포트: 데스크탑 1440×900

## 실행 스크립트
1. `.claude/skills/TT_541/scripts/01_scan_project.js` (Node.js) → FE 스캔 + PDA 제외
2. `.claude/skills/TT_541/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스) → 메뉴별 캡처
3. `.claude/skills/TT_541/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) → PPTX 생성

## 템플릿
- `template/05 이행(TT)/사용자매뉴얼_샘플.pptx`

---

> **PDA(모바일) 메뉴는 이 스킬에서 처리하지 않는다.** PDA 메뉴는 `/TT_542` 스킬에서 별도로 처리한다.
> **관리자매뉴얼이 필요하면 이 스킬에서 처리하지 않는다.** 관리자(사용자관리·사업장·센터·창고·메뉴·권한 설정을 다루는 메뉴)에 대한 매뉴얼은 `/TT_543` 스킬에서 처리한다.

> **템플릿(BLOCKING)**
> PPTX 생성에는 반드시 `template/05 이행(TT)/사용자매뉴얼_샘플.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 레이아웃 / 폰트 / 색상은 그대로 유지하고, 템플릿 슬라이드에 들어있는 실제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.
> 템플릿이 없으면 스킬 실행을 중단하고 사용자에게 알린다.

> **PPT 직접 삽입 제약 (BLOCKING)**
> 텍스트박스·화살표·레이블·콜아웃 등의 요소는 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 계열로 PPT 파일에 직접 삽입한다.
> 단, 이미지는 Pillow로 처리하지 않으면 결과 PPTX를 PowerPoint에서 열어 도형편집·슬라이드 설정·색상 변경 등을 할 수 없게 되므로 가능하면 직접 삽입한다.

> **의존성 안내**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.
> Node 의존성은 스킬 폴더 `node_modules`에서 자동 설치, Python 패키지는 `pip install --user python-pptx Pillow`로 자동 설치한다.

---

## 사전 준비(공통)

### 매개변수 확인 (AskUserQuestion 사용)

다음 정보를 순서대로 확인한다. 매개변수(`$ARGUMENTS`)에 이미 값이 입력되어 있으면 해당 항목 건너뜀.

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 켤 프로젝트 루트 디렉토리 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BASE_URL** | 이미 켜져 있는 dev/스테이징 서버. 없으면 사용자에게 `npm run dev` 실행 요청 | `http://localhost:5173` |
| **고객사명** | 산출물 파일명 `TT_541_사용자매뉴얼_PC_{고객사명}.pptx`. OS 금지문자(`\ / : * ? " < > |`) 자동 `_` 교체 | `진아이드물류` |
| **로그인 필요 여부** | Y면 `로그인 URL 직접 input`, `ID`, `PW`, `Origin/API URL(선택)` | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 발견한 PC 메뉴 전체 목록에서 포함할 메뉴 선택 | `mdpr01, mdct01, stdc01` |
| **뷰포트** | 데스크탑 고정 (1440×900) | `1440x900` |

### 경로 정의

모든 경로는 git 최상위 디렉토리(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (자동 감지)
TEMPLATE  = template/05 이행(TT)/사용자매뉴얼_샘플.pptx
OUT_DIR   = output/05 이행(TT)
TMP_DIR   = output/05 이행(TT)/tmp_541
SCRIPTS   = .claude/skills/TT_541/scripts
OUT_FILE  = output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx
```

> **TMP 디렉토리 구분:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 은 `tmp_543` 을 사용하여 동시 실행해도 충돌하지 않도록 한다.

---

# === Windows 블록 (PowerShell) ===

### W-0) 경로 자동 감지

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$FeRoot    = Join-Path $Workspace "wms-$ProjCode-fe"
```

### W-1) 의존성 자동 설치

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

# Node 패키지(캡처) → 스킬 폴더 아래 로컬 설치
Set-Location "$DocRoot\.claude\skills\TT_541\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
npx playwright install chromium 2>$null

# Python 패키지(PPTX 생성)
python -c "from pptx import Presentation; from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user python-pptx Pillow }
```

### W-2) FE 스캔

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_541\scripts\01_scan_project.js" "{FE경로}"
```

### W-3) 화면 캡처

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_541\scripts\02_capture_screens.js"
```

### W-4) PPTX 생성

```powershell
Set-Location $DocRoot
python ".claude\skills\TT_541\scripts\03_make_pptx.py"
```

---

# === Bash 블록 (WSL/Linux/Mac) ===

### B-0) 경로 자동 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"
```

### B-1) 의존성 자동 설치

```bash
cd "$DOC_ROOT/.claude/skills/TT_541/scripts"
[ ! -f package.json ] && npm init -y
[ ! -d node_modules/playwright ] && npm install playwright
npx playwright install chromium 2>/dev/null

python3 -c "from pptx import Presentation; from PIL import Image" 2>/dev/null || pip3 install --user python-pptx Pillow
```

### B-2) FE 스캔

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_541/scripts/01_scan_project.js "{FE경로}"
```

### B-3) 화면 캡처

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_541/scripts/02_capture_screens.js
```

### B-4) PPTX 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/TT_541/scripts/03_make_pptx.py
```

---

## PC 메뉴 포함 판단 기준 (공통, PDA 제외)

이 스킬은 cloud-wms-fe 에 등록된 router 설정에서 **PC(데스크탑) 메뉴만** 추출한다. 아래 기준 중 하나라도 해당하면 **PDA로 분류하여 제외**한다.

### PDA 제외 기준 (제외 대상)

| 기준 | 예시 |
|---|---|
| 라우터 경로에 `/bm/` 포함 | `/bm/iv3000m/ivad01m` |
| 라우터 경로에 `/pda/` 포함 | `/pda/iv3000m/ivad01m` |
| 라우터 경로에 `/mobile/` 포함 | `/mobile/iw1000m/iwpc01m` |
| 경로 segment 중 `*m` 패턴 (소문자+숫자+'m') | `iv3000m`, `md8000m`, `ow5000m` |
| 메뉴 코드 끝이 `m` (소문자+숫자+'m') | `ivad01m`, `ivmvrq01m`, `sksp01m` |
| 메뉴 코드 prefix 가 `pda` | `pdamain` |

### PC 포함 기준 (포함 대상)

| 기준 | 예시 |
|---|---|
| 라우터 경로에 `/be/` 포함 | `/be/iv3000/ivad01`, `/be/md8000/mdpr01` |
| 경로 segment 가 소문자+숫자 (끝에 'm' 없음) | `iv3000`, `md8000`, `ow5000` |
| 메뉴 코드 끝이 'm' 이 아닌 것 | `ivad01`, `mdpr01`, `iwrq01` |

> **포함 판단이 불명확할 때** 1단계 스캔 결과를 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 로 직접 선택.

---

## 단계별 상세 동작 (공통)

### 1단계 → FE 프로젝트 스캔으로 PC 메뉴 후보 추출

**스크립트**: `scripts/01_scan_project.js`
**입력**: FE 프로젝트 경로
**출력**: `output/05 이행(TT)/tmp_541/menu_candidates.json`

스크립트가 수행하는 것:

1. `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
2. `src/router/index.*`, `src/router/modules/**/*.{js,ts}`, `src/views/**/*.vue`, `src/pages/**/*.tsx` 에서 라우터 추출
3. `spec/{메뉴코드}/{메뉴코드}-02-ui.md` 또는 `menu-index.md` 에서 메뉴명 보완
4. **PDA 제외 기준** 적용 → 제외 메뉴는 `rejected[]` 에 기록
5. PC 메뉴만 `menus[]` 에 포함

`menu_candidates.json` 형식:

```json
{
  "fePath": "C:\\zinide\\workspace\\wms-cloud-fe",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "menus": [
    { "code": "mdpr01", "name": "프로모션", "path": "/be/md8000/mdpr01", "viewportHint": "desktop" }
  ],
  "rejected": [
    { "code": "ivad01m", "name": "재고조정", "reason": "PDA 메뉴(코드 끝 m 또는 경로 /bm/·/pda/·/mobile/)" }
  ],
  "scannedAt": "2026-05-15T14:00:00.000Z"
}
```

### 2단계 → 사용자 입력으로 캡처 설정 확정

`menu_candidates.json` 을 사용자에게 보여주고, AskUserQuestion으로 다음을 확정.

1. **BASE_URL 확정**
2. **dev 서버 구동 여부** → 이미 켜져있으면 그대로 사용. 아니면 사용자에게 `npm run dev` 실행 요청.
3. **메뉴 선택** → 원하는 메뉴 선택.
4. **로그인 정보** → 필요 여부.
5. **고객사명** 확정.
6. **뷰포트** → 데스크탑 고정 (1440×900).

확정된 값을 `output/05 이행(TT)/tmp_541/capture_config.json` 으로 저장

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "진아이드물류",
  "login": { "needed": true, "url": "/", "originField": "http://168.126.28.62:8085/api", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 1440, "height": 900, "hideSidebar": true },
  "menus": [
    { "code": "mdpr01", "name": "프로모션", "path": "/be/md8000/mdpr01", "scenarios": ["main", "search", "register", "rowSelect", "edit"] }
  ]
}
```

### 3단계 → Playwright 헤드리스 화면 캡처

**스크립트**: `scripts/02_capture_screens.js`
**입력**: `tmp_541/capture_config.json`
**출력**:
- `tmp_541/screens/{메뉴코드}/01-main.png`
- `tmp_541/screens/{메뉴코드}/02-search-result.png`
- `tmp_541/screens/{메뉴코드}/03-register-popup.png` (등록 팝업있는 경우)
- `tmp_541/screens/{메뉴코드}/04-row-selected.png`
- `tmp_541/screens/{메뉴코드}/05-edit-popup.png` (수정 팝업있는 경우)
- `tmp_541/screens/{메뉴코드}/coords.json` (각 영역 DOM bounding box)

#### 기본 캡처 시나리오

| 파일명 | 시나리오 | 캡처 영역 지정 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 (검색 조건 비어있음) | search-area, grid 영역 |
| `02-search-result.png` | "검색" 버튼 클릭 + 결과 렌더링 완료 | 결과 grid |
| `03-register-popup.png` | "추가/등록" 버튼 클릭 → 팝업 열림 → 캡처 → 닫기 | 팝업 bbox |
| `04-row-selected.png` | 결과 그리드 행 클릭 | 서브 그리드 영역 |
| `05-edit-popup.png` | 행 선택 후 "수정" 버튼 클릭 → 팝업 열림 → 캡처 → 닫기 | 팝업 bbox |

**절대 실제 데이터 변경 금지 조건**
- 팝업은 열기만 하고 확인·저장 버튼 클릭 금지.
- 닫기 / ESC 로 팝업 닫기.
- 검색 이외의 INSERT/UPDATE/DELETE 실행이 필요한 시나리오는 절대 실행 금지.

#### 사이드바 처리

뷰포트에 사이드바가 포함되어 화면이 좁아지는 경우, 캡처 직전에 사이드바를 `display:none`으로 숨기고 메인 영역의 `width:100vw`로 확장. `capture_config.json`에 `viewport.hideSidebar=false`로 끌 수 있다.

### 4단계 → PPTX 생성

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**입력**:
- 템플릿: `template/05 이행(TT)/사용자매뉴얼_샘플.pptx` (필수)
- `tmp_541/capture_config.json`
- `tmp_541/screens/{메뉴코드}/*.png`
- `tmp_541/screens/{메뉴코드}/coords.json`

**출력**: `output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx`

#### 템플릿 처리 규칙 (BLOCKING)

1. `Presentation(TEMPLATE)` 으로 템플릿 PPTX 를 연다.
2. 템플릿에 있는 실제 슬라이드는 `remove_all_slides()` 로 모두 제거. 슬라이드 레이아웃 / 색상 / 폰트 / 스타일은 그대로 유지.
3. 새 슬라이드를 (메뉴그룹 구분 + 화면별 N 시나리오별) 순서로 추가한다.
4. 페이지 번호는 모든 슬라이드 생성 완료 후 `i / total` 로 일괄 삽입.

#### 슬라이드 구성

1. **표지 슬라이드** → 제목 "사용자매뉴얼(PC)", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** → 메뉴 목록에서 자동 생성
3. **메뉴 그룹 구분 표지** → 메뉴마다 1장(메뉴명 [메뉴코드])
4. **메뉴 화면 슬라이드** → 메뉴마다 캡처 시나리오 수만큼 (보통 3~5장)

#### 화면 슬라이드 레이아웃 (16:9 슬라이드, 데스크탑)

- **이미지 영역**: 0~10in (데스크탑 1440×900 비율에 맞게)
- **설명 영역**: 10~13.33in
- **텍스트박스**: 이미지 위에 색상 fill + 색상 텍스트(python-pptx `add_shape`)
- **화살표**: 이미지 오른쪽 (IMG_R) ~ 설명 영역 사이 "화살표 선"
- **커넥터**: 화살표 양쪽 끝에 점(`add_connector`)
- **페이지 번호**: 오른쪽 아래 9pt #888888

#### 색상 기준

| 용도 | HEX |
|---|---|
| 검색 조건 / 빨간 텍스트박스 영역 | `DC1E1E` (빨강) |
| 저장 텍스트박스 영역 | `C86E00` (주황) |
| 조회 텍스트박스 영역 | `1E64C8` (파랑) |
| 기타 영역·기본 상태 | `6E6E6E` (회색) |
| 데이터가 있는 결과 그리드 | `148C3C` (녹색) |
| 강조 헤더(팝업·확인) | `1A3A5C` (진파랑) |
| 본문 텍스트 | `333333` |
| 경고 (에러) | `CC2222` |

#### 설명 영역 작성 규칙

- `spec/{메뉴코드}/{메뉴코드}-02-ui.md` 가 있으면 거기서 우선 참조 (메뉴명, 검색 조건, 그리드 컬럼, 업무규칙).
- ui.md 가 없는 경우 캡처한 DOM에서 추출한 텍스트/플레이스홀더로 보완.
- **PC 사용자매뉴얼이므로 변수명·API 경로·DB 컬럼명을 직접 노출하지 않는다.** 사용자가 화면에서 보이는 레이블·버튼·텍스트 기준으로 작성.

---

## 5단계 → 완료 보고

```
✅ PC 사용자매뉴얼 PPTX 생성 완료 [TT_541]

실행 환경 : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사명   : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : 1440x900 (데스크탑)
locale    : ko-KR

산출물 파일 : output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx
슬라이드  : 표지 1 + 목차 1 + 메뉴그룹 N + 화면 M = 총 K장
캡처 PC 메뉴 ({N}개):
  - mdpr01  프로모션  (5장: 메인/검색/등록/행선택/수정)
  - mdct01  거래처    (4장: 메인/검색/등록/수정)
  - ...

제외된 PDA 메뉴 ({P}개) → /TT_542 에서 처리:
  - ivad01m, ivmv01m, ivmvrq01m, sksp01m, ...

PPT 파일에서 텍스트박스·화살표·설명 영역은 도형으로 직접 삽입되어 있습니다.
```

---

## 메뉴별 재실행

이미 생성된 PPTX에 메뉴를 추가하거나 수정하고 싶을 때는 이 스킬을 다시 실행하고 2단계에서 해당 메뉴만 선택하면 된다. `tmp_541/screens/{메뉴코드}/`는 메뉴별로 디렉토리가 분리되어 있어 나머지 메뉴의 캡처는 그대로 유지된다.

PPTX는 항상 `OUT_FILE` 경로에 **항상 새로 생성**한다 (기존 슬라이드 병합 없이).

---

## 문제해결 & 대처법
| 문제 | 원인 | 대처법 |
|------|------|--------|
| PDA 메뉴가 PC 목록에 섞임 | 메뉴 코드 끝이 'm' 이거나 경로에 /bm/ 포함 | 1단계 결과를 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 로 직접 제거 |
| PC 메뉴가 PDA로 잘못 분류 | 메뉴 코드 끝이 의도치 않게 'm' | 1단계 결과 `rejected[]` 를 사용자에게 보여주고 직접 PC로 복구 |
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` 또는 `display:none` 상태 팝업 | `02_capture_screens.js` 가 팝업 열기 전 visible 여부를 확인하여 조건별 처리 |
| 로그인 실패 "사이트를 입력하세요" | 3-factor 로그인에서 origin 필드 처리 누락 | `capture_config.json` 에 `login.originField` 값이 있으면 해당 input 자동 입력 |
| 이미지 늘어남 | width/height 비율 계산 오류 | `03_make_pptx.py` `Geom` 클래스의 `min(IMG_COL_W/PX_W, IMG_AREA_H/PX_H)` 로 비율 유지 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 후 미사용 | `remove_all_slides()` 로 sldIdLst 와 _Relationships._rels 를 직접 삭제 |
| 화살표 텍스트 잘림 | 화살표를 이미지 위에 겹침 | 화살표는 이미지 오른쪽 (IMG_R) ~ 설명 영역 사이 "화살표 선"으로만 삽입 |
| dev 서버 연결 실패 | `npm run dev` 가 실행 안 됨 | 사용자에게 별도 터미널에서 dev 서버를 켜도록 요청 (BLOCKING) |

---

## 관련 스킬

- PDA 사용자매뉴얼 PPTX → `/TT_542`
- 관리자매뉴얼 PPTX → `/TT_543`
- 프로그램 목록 산출물 → `/PI_412`
- DB 이관 데이터 dump SQL → `/TT_551`

---

## 주의사항 (OS 별)

### Windows 주의사항

- **Python 실행 명령**: `python` (PATH 등록 필요). `py -3` 도 허용.
- **한글 인코딩 출력**: `chcp 65001` + `$env:PYTHONUTF8 = "1"` + `[Console]::OutputEncoding = [Text.UTF8Encoding]::new()`.
- **경로 공백·한글 처리**: `"output\05 이행(TT)"` 처럼 공백·한글 포함 경로는 이스케이프 없이 따옴표로 감싼다.
- **Playwright chromium**: 최초 1회 `npx playwright install chromium` 필요.

### Bash 주의사항

- **Python 실행 명령**: `python3`.
- **pip3**: `pip3 install --user` 사용. macOS Homebrew Python 도 동일.
- **WSL 경로**: 사용자가 `/mnt/c/...` 로 입력 시 그대로 사용. FE 경로는 WSL 내에서 접근 가능한 경로로 전달.
- **Playwright chromium**: WSL에서는 Linux 바이너리로 설치. macOS는 Darwin 바이너리.
