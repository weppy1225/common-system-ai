---
name: TT_541
description: 【PC 사용자매뉴얼 PPTX 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스, 데스크탑 1440×900)로 접속하여 PC(데스크탑) 사용자 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 PC 사용자매뉴얼 PPTX를 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. PDA(모바일) 메뉴는 자동 제외되며 별도 스킬 /TT_542 에서 처리합니다. PDA 자동 식별 기준: 라우트 경로에 `/bm/`·`/pda/`·`/mobile/` 포함, 부모 segment 가 `*m` 패턴(`iv3000m` 등), 메뉴코드 끝이 `m`(`ivad01m` 등). 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_541 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx 단일 파일로 떨어집니다. PC 사용자 매뉴얼 작성, 데스크탑 사용자용 매뉴얼, 화면 캡처 PPT, WMS PC 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "PC 사용자매뉴얼 만들어줘", "사용자 매뉴얼 PPT 뽑아줘", "TT_541 실행해줘", "데스크탑 화면 캡쳐해서 PPT 만들어줘", "PC 사용자 매뉴얼 산출물 만들어줘", "WSL에서 사용자 매뉴얼 PPT 만들어줘", "Linux에서 PC 매뉴얼 캡쳐해줘" 라고 말해도 이 스킬을 사용합니다. 단, PDA 사용자 매뉴얼이 필요한 경우는 /TT_542, 운영자 매뉴얼은 /TT_543 을 사용합니다.
type: skill
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PC 사용자 매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_541]

대상 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(또는 사용자가 추가로 입력하는 BASE_URL)에서 dev 서버를 식별하고, **Playwright 헤드리스 모드(데스크탑 1440×900, 한국어 로케일 ko-KR)** 로 **PC 메뉴만** 캡처한 뒤, **사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx** 로 PC 사용자매뉴얼 PPTX를 `output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx` 파일로 생성한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션] — `python`/`node` 실행, Windows 경로(`\`).
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션] — `python3`/`node` 실행, POSIX 경로(`/`).
```

> Node.js 스크립트(`scripts/01_scan_project.js`, `scripts/02_capture_screens.js`)와 Python 스크립트(`scripts/03_make_pptx.py`)는 양쪽에서 동일하게 동작한다. 차이는 `python` vs `python3` 명령, 경로 구분자뿐.

---

## 자동 스캔
- FE 프로젝트 경로 — `C:\zinide\workspace\wms-{업체코드}-fe` (Win) 또는 `/mnt/c/zinide/workspace/wms-{업체코드}-fe` (WSL)
- BE 프로젝트 경로 — (사용 안 함, FE만 필요)
- ex) BASE_URL — `localhost:5173`
- 로그인 정보 — `test / 1111`
- 전체메뉴 / 옵션-단일메뉴 : `mdpd01`
- 뷰포트: 데스크탑 1440×900

## 실행 스크립트
1. `.claude/skills/TT_541/scripts/01_scan_project.js` (Node.js) — FE 스캔 + PDA 자동 제외
2. `.claude/skills/TT_541/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스) — 메뉴별 캡처
3. `.claude/skills/TT_541/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) — PPTX 생성

## 템플릿
- `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`

---

> **PDA(모바일) 메뉴는 본 스킬의 범위가 아니다.** PDA 메뉴는 `/TT_542` 스킬에서 별도로 처리한다.
> **운영자 매뉴얼은 본 스킬의 범위가 아니다.** 운영자/관리자(시스템관리·사용자관리·공통코드 등) 매뉴얼은 `/TT_543` 스킬에서 처리한다.

> **템플릿 (BLOCKING)**
> PPTX 는 반드시 `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 마스터 / 테마 / 레이아웃은 그대로 보존하고, 템플릿 안에 들어있던 예제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.
> 템플릿이 없으면 스킬 실행을 중단하고 사용자에게 알린다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.
> 이미지 위에 라벨을 합성(Pillow 등)하지 않으며, 결과 PPTX를 PowerPoint에서 열어 도형을 드래그·텍스트 수정·색상 변경할 수 있어야 한다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.
> Node 의존성은 스킬 내부 `node_modules`에서 자동 설치, Python 패키지는 `pip install --user python-pptx Pillow`로 자동 설치한다.

---

## 사전 준비 (공통)

### 인자 확정 (AskUserQuestion 활용)

다음 정보를 순서대로 확인한다. 인자(`$ARGUMENTS`)에 일부 값이 들어있으면 우선 사용.

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 띄울 프론트엔드 소스 루트. router 자동 스캔에 사용 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버. 없으면 사용자에게 `npm run dev` 안내 | `http://localhost:5173` |
| **고객사명** | 출력 파일명 `TT_541_사용자매뉴얼_PC_{고객사명}.pptx`. OS 금지문자(`\ / : * ? " < > |`) 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 `로그인 URL 추가 input`, `ID`, `PW`, `Origin/API URL(선택)` | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 추출된 PC 메뉴 후보 중 매뉴얼에 포함할 메뉴 다중 선택 | `mdpr01, mdct01, stdc01` |
| **뷰포트** | 데스크탑 고정 (1440×900) | `1440x900` |

### 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (동적 감지)
TEMPLATE  = template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx
OUT_DIR   = output/05 이행(TT)
TMP_DIR   = output/05 이행(TT)/tmp_541
SCRIPTS   = .claude/skills/TT_541/scripts
OUT_FILE  = output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx
```

> **TMP 디렉토리 분리:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 는 `tmp_543` 를 사용하여 동시 실행해도 충돌하지 않게 한다.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

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

# Node 측 (캡처용) — 스킬 내부 scripts 폴더에 격리 설치
Set-Location "$DocRoot\.claude\skills\TT_541\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
npx playwright install chromium 2>$null

# Python 측 (PPTX 생성용)
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

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

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

## PC 메뉴 자동 식별 기준 (공통, PDA 자동 제외)

본 스킬은 cloud-wms-fe 등 일반적인 router 구조에서 **PC(데스크탑) 메뉴만** 추출한다. 아래 기준 중 하나라도 만족하면 **PDA로 간주하여 자동 제외**한다.

### PDA 식별 패턴 (제외 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/bm/` 포함 | `/bm/iv3000m/ivad01m` |
| 라우트 경로에 `/pda/` 포함 | `/pda/iv3000m/ivad01m` |
| 라우트 경로에 `/mobile/` 포함 | `/mobile/iw1000m/iwpc01m` |
| 부모 segment 가 `*m` 패턴 (영문+숫자+'m') | `iv3000m`, `md8000m`, `ow5000m` |
| 메뉴 코드 끝이 `m` (영문+숫자+'m') | `ivad01m`, `ivmvrq01m`, `sksp01m` |
| 메뉴 코드 prefix 가 `pda` | `pdamain` |

### PC 식별 패턴 (포함 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/be/` 포함 | `/be/iv3000/ivad01`, `/be/md8000/mdpr01` |
| 부모 segment 가 영문+숫자 (끝 'm' 없음) | `iv3000`, `md8000`, `ow5000` |
| 메뉴 코드 끝이 'm' 이 아님 | `ivad01`, `mdpr01`, `iwrq01` |

> **자동 식별이 완벽하지 않을 수 있다.** 1단계 스캔 결과는 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 최종 확정.

---

## 단계별 워크플로우 상세 (공통)

### 1단계 — FE 프로젝트 스캔으로 PC 메뉴 후보 추출

**스크립트**: `scripts/01_scan_project.js`
**입력**: FE 프로젝트 경로
**출력**: `output/05 이행(TT)/tmp_541/menu_candidates.json`

스크립트가 수행하는 일:

1. `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
2. `src/router/index.*`, `src/router/modules/**/*.{js,ts}`, `src/views/**/*.vue`, `src/pages/**/*.tsx` 에서 라우트 추출
3. `dist/{메뉴코드}/ui.md` 또는 `menu-index.md` 에서 메뉴명 매핑
4. **PDA 필터 적용**: 위 "PDA 식별 패턴" 통과한 메뉴는 자동 제외하고 `rejected[]` 에 분리 기록
5. PC 메뉴만 `menus[]` 에 남김

`menu_candidates.json` 포맷:

```json
{
  "fePath": "C:\\zinide\\workspace\\wms-cloud-fe",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "menus": [
    { "code": "mdpr01", "name": "사은품관리", "path": "/be/md8000/mdpr01", "viewportHint": "desktop" }
  ],
  "rejected": [
    { "code": "ivad01m", "name": "재고조정", "reason": "PDA 메뉴(코드 끝 m 또는 경로 /bm/·/pda/·/mobile/)" }
  ],
  "scannedAt": "2026-05-15T14:00:00.000Z"
}
```

### 2단계 — 사용자 입력으로 캡처 대상 확정

`menu_candidates.json` 을 사용자에게 보여주고, AskUserQuestion으로 다음을 확정.

1. **BASE_URL 확정**
2. **dev 서버 기동 여부** — 이미 떠 있으면 그대로 사용. 아니면 사용자에게 `npm run dev` 안내.
3. **메뉴 선택** — 다중 선택.
4. **로그인 정보** — 필요 시.
5. **고객사명** 확정.
6. **뷰포트** — 데스크탑 고정 (1440×900).

확정된 값은 `output/05 이행(TT)/tmp_541/capture_config.json` 으로 저장.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": { "needed": true, "url": "/", "originField": "http://168.126.28.62:8085/api", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 1440, "height": 900, "hideSidebar": true },
  "menus": [
    { "code": "mdpr01", "name": "사은품관리", "path": "/be/md8000/mdpr01", "scenarios": ["main", "search", "register", "rowSelect", "edit"] }
  ]
}
```

### 3단계 — Playwright 헤드리스 화면 캡처

**스크립트**: `scripts/02_capture_screens.js`
**입력**: `tmp_541/capture_config.json`
**출력**:
- `tmp_541/screens/{메뉴코드}/01-main.png`
- `tmp_541/screens/{메뉴코드}/02-search-result.png`
- `tmp_541/screens/{메뉴코드}/03-register-popup.png` (등록 시나리오 있는 경우)
- `tmp_541/screens/{메뉴코드}/04-row-selected.png`
- `tmp_541/screens/{메뉴코드}/05-edit-popup.png` (수정 시나리오 있는 경우)
- `tmp_541/screens/{메뉴코드}/coords.json` (각 영역 DOM bounding box)

#### 표준 캡처 시나리오

| 파일명 | 트리거 | 캡처 영역 측정 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 (검색 조건 비어있음) | search-area, grid 영역 |
| `02-search-result.png` | "검색" 버튼 클릭 + 결과 로드 대기 | 결과 grid |
| `03-register-popup.png` | "추가/등록" 버튼 클릭 → 팝업 오픈 후 캡처 → 취소로 닫음 | 팝업 bbox |
| `04-row-selected.png` | 결과 그리드 첫 행 클릭 | 디테일 영역 |
| `05-edit-popup.png` | 행 선택 후 "수정" 버튼 클릭 → 팝업 오픈 후 캡처 → 취소로 닫음 | 팝업 bbox |

**⚠ 실제 데이터 변경 금지 원칙**
- 팝업은 열기만 함. 확인·저장·승인 버튼 클릭 금지.
- 취소 / ESC 로 팝업 닫기.
- 검색은 가능, INSERT/UPDATE/DELETE 동작은 절대 실행 금지.

#### 사이드바 숨김

뷰포트에 사이드바가 포함되어 화면을 가리는 경우, 캡처 직전에 사이드바를 `display:none`으로 숨기고 메인 영역을 `width:100vw`로 늘린다. `capture_config.json`의 `viewport.hideSidebar=false`로 끌 수 있다.

### 4단계 — PPTX 생성

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**입력**:
- 템플릿: `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` (필수)
- `tmp_541/capture_config.json`
- `tmp_541/screens/{메뉴코드}/*.png`
- `tmp_541/screens/{메뉴코드}/coords.json`

**출력**: `output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx`

#### 템플릿 처리 방식 (BLOCKING)

1. `Presentation(TEMPLATE)` 으로 템플릿 PPTX 를 연다.
2. 템플릿 안의 예제 슬라이드는 `remove_all_slides()` 로 모두 제거. 슬라이드 마스터 / 레이아웃 / 테마 / 폰트 / 색상은 그대로 보존.
3. 표지 → 목차 → (메뉴섹션 → 화면들) × N 순서로 새 슬라이드를 추가.
4. 페이지 번호는 모든 슬라이드 작성 완료 후 `i / total` 로 일괄 부여.

#### 슬라이드 구성

1. **표지 슬라이드** — 제목 "사용자 매뉴얼 (PC)", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** — 메뉴 목록을 자동 나열
3. **메뉴 섹션 표지** — 메뉴마다 1장 (메뉴명 [메뉴코드])
4. **메뉴 화면 슬라이드** — 메뉴마다 캡처된 시나리오 수만큼 (보통 3~5장)

#### 화면 슬라이드 레이아웃 (16:9 와이드, 데스크탑)

- **이미지 영역**: 0~10in (데스크탑 1440×900 종횡비 보존)
- **설명 패널**: 10~13.33in
- **라벨 박스**: 이미지 위에 투명 fill + 색상 테두리 (python-pptx `add_shape`)
- **배지**: 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존"
- **커넥터**: 배지 ↔ 영역 중심점 연결선 (`add_connector`)
- **페이지 번호**: 우하단 9pt #888888

#### 색상 매핑

| 목적 | HEX |
|---|---|
| 검색 조건 / 첫 번째 영역 | `DC1E1E` (빨강) |
| 두 번째 영역 | `C86E00` (주황) |
| 세 번째 영역 | `1E64C8` (파랑) |
| 빈 영역·초기 상태 | `6E6E6E` (회색) |
| 데이터 있는 결과 그리드 | `148C3C` (녹색) |
| 중립 헤딩(팝업·요약) | `1A3A5C` (남색) |
| 일반 본문 | `333333` |
| 경고 (⚠) | `CC2222` |

#### 설명 패널 작성 원칙

- `dist/{메뉴코드}/ui.md` 가 존재하면 그 내용을 우선 활용 (메뉴명, 검색조건, 그리드 컬럼, 업무규칙).
- ui.md 가 없는 경우 캡처된 DOM에서 추출한 라벨/플레이스홀더로 대체.
- **PC 사용자 매뉴얼이므로 코드 변수명·API 경로·DB 컬럼명을 직접 드러내지 않는다.** 사용자가 화면에서 볼 수 있는 한글 라벨 기준으로 작성.

---

## 5단계 — 완료 보고

```
✓ PC 사용자매뉴얼 PPTX 생성 완료 [TT_541]

실행 환경 : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사    : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : 1440x900 (데스크탑)
locale    : ko-KR

출력 파일 : output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx
슬라이드  : 표지 1 + 목차 1 + 메뉴섹션 N + 화면 M = 총 K장

캡처 PC 메뉴 ({N}개):
  - mdpr01  사은품관리   (5장: 메인/검색/등록/행선택/수정)
  - mdct01  거래처관리   (4장: 메인/검색/등록/수정)
  - ...

자동 제외된 PDA 메뉴 ({P}개) — /TT_542 에서 처리:
  - ivad01m, ivmv01m, ivmvrq01m, sksp01m, ...

PPT 안에서 라벨·테두리·배지·설명 패널은 도형으로 직접 편집 가능합니다.
```

---

## 메뉴별 단독 실행

이미 만든 PPTX에 메뉴를 한두 개만 추가/교체할 때는 같은 스킬을 다시 실행하고 2단계에서 해당 메뉴만 선택하면 된다. `tmp_541/screens/{메뉴코드}/`는 메뉴별로 분리되므로 다른 메뉴의 캡처는 보존된다.

PPTX는 매번 `OUT_FILE` 경로에 **전체 다시** 작성된다 (부분 슬라이드 패치는 지원하지 않음).

---

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| PDA 메뉴가 PC 목록에 잘못 포함됨 | 메뉴 코드 끝에 'm' 이 없고 라우트 경로도 비표준 | 1단계 결과를 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 직접 제거 |
| PC 메뉴가 PDA로 잘못 분류됨 | 메뉴 코드 끝이 우연히 'm' | 1단계 결과 `rejected[]` 를 사용자에게 보여주고 직접 PC로 복원 |
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` 또는 `display:none` 토글 팝업 | `02_capture_screens.js` 가 팝업 헤더 색상을 픽셀 스캔하여 좌표 보정 |
| 로그인 실패 "아이디를 입력해주세요" | 테스트 서버 3-필드 폼에서 origin 필드 처리 누락 | `capture_config.json` 의 `login.originField` 값이 있으면 첫 번째 input 에 자동 입력 |
| 이미지 왜곡 | width/height 비율 어긋남 | `03_make_pptx.py` `Geom` 클래스가 `min(IMG_COL_W/PX_W, IMG_AREA_H/PX_H)` 으로 종횡비 보존 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 시 | `remove_all_slides()` 로 sldIdLst 와 _Relationships._rels 를 직접 비움 |
| 라벨이 본문 글자를 가림 | 배지를 이미지 위에 그림 | 배지는 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존"에만 배치 |
| dev 서버 미기동 | `npm run dev` 가 실행 안됨 | 사용자에게 별도 터미널에서 dev 서버를 띄우라고 안내 (BLOCKING) |

---

## 함께 보면 좋은 스킬

- PDA 사용자 매뉴얼 PPTX → `/TT_542`
- 운영자 매뉴얼 PPTX → `/TT_543`
- 프로그램 목록 엑셀 → `/PI_412`
- DB 이관 데이터 dump SQL → `/TT_551`

---

## 주의사항 (OS 특화)

### Windows 특화

- **Python 실행 명령**: `python` (PATH 등록 필요). `py -3` 도 가능.
- **한글 콘솔 출력 깨짐**: `chcp 65001` + `$env:PYTHONUTF8 = "1"` + `[Console]::OutputEncoding = [Text.UTF8Encoding]::new()`.
- **경로 공백·한글 처리**: `"output\05 이행(TT)"` 처럼 공백·한글 경로는 큰따옴표로 감싼다.
- **Playwright chromium**: 최초 1회 `npx playwright install chromium` 필요.

### Bash 특화

- **Python 실행 명령**: `python3`.
- **pip3**: `pip3 install --user` 사용. macOS Homebrew Python 도 동일.
- **WSL 경로**: 사용자가 `/mnt/c/...` 로 입력 가능. FE 경로는 WSL 안에서 접근 가능한 경로로 지정.
- **Playwright chromium**: WSL에서는 Linux 바이너리 다운로드. macOS는 Darwin 바이너리.
