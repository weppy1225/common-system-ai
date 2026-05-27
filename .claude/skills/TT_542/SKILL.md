---
name: TT_542
description: 【PDA 사용자매뉴얼 PPTX 생성 (Windows 기본)】 Windows 네이티브(PowerShell) 환경에서 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스, 모바일 390×844)로 접속하여 PDA(모바일) 사용자 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 PDA 사용자매뉴얼 PPTX를 자동 생성합니다. PC(데스크탑) 메뉴는 자동 제외되며 별도 스킬 /TT_541 에서 처리합니다. PDA 자동 식별 기준: 라우트 경로에 `/bm/`·`/pda/`·`/mobile/` 포함, 부모 segment 가 `*m` 패턴(`iv3000m`·`md8000m` 등), 메뉴코드 끝이 `m`(`ivad01m`·`ivmvrq01m` 등). cloud-wms-doc 의 `dist-mobile/{그룹}/{메뉴}.html` 도 보조 메뉴명 매핑에 활용합니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_542 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output\05 이행(TT)\TT_542_사용자매뉴얼_PDA_{고객사명}.pptx 단일 파일로 떨어집니다. PDA 사용자 매뉴얼 작성, 모바일 사용자용 매뉴얼, PDA 화면 캡처 PPT, WMS 모바일 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "PDA 사용자매뉴얼 만들어줘", "모바일 매뉴얼 PPT 뽑아줘", "TT_542 실행해줘", "PDA 화면 캡쳐해서 PPT 만들어줘", "모바일 사용자 매뉴얼 산출물 만들어줘" 라고 말해도 이 스킬을 사용합니다. 단, PC 사용자 매뉴얼이 필요한 경우는 /TT_541, 운영자 매뉴얼은 /TT_543 을 사용합니다. WSL/Linux/Mac 환경에서는 /TT_542_BASH 를 사용합니다.
type: skill
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PDA 사용자 매뉴얼 PPTX 자동 생성 스킬 (Windows 기본) [TT_542]

대상 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(또는 사용자가 추가로 입력하는 BASE_URL)에서 dev 서버를 식별하고, **Playwright 헤드리스 모드(모바일 390×844, 한국어 로케일 ko-KR)** 로 **PDA 메뉴만** 캡처한 뒤, **사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx** 로 PDA 사용자매뉴얼 PPTX를 `output\05 이행(TT)\TT_542_사용자매뉴얼_PDA_{고객사명}.pptx` 파일로 생성한다.

---

## 자동 스캔
- FE 프로젝트 경로 — `C:\zinide\workspace\wms-{업체코드}-fe`
- BE 프로젝트 경로 — (사용 안 함, FE만 필요)
- ex) BASE_URL — `localhost:5173`
- 로그인 정보 — `test / 1111`
- 전체메뉴 / 옵션-단일메뉴 : `ivad01m`
- 뷰포트: 모바일 390×844 (`isMobile: true`)

## 실행 스크립트
1. `.claude/skills/TT_542/scripts/01_scan_project.js` (Node.js) — FE 스캔 + PC 자동 제외 (PDA만 keep)
2. `.claude/skills/TT_542/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스, 모바일 컨텍스트) — 메뉴별 캡처
3. `.claude/skills/TT_542/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) — PPTX 생성

## 템플릿
- `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`

---

> **PC(데스크탑) 메뉴는 본 스킬의 범위가 아니다.** PC 메뉴는 `/TT_541` 스킬에서 별도로 처리한다. 본 스킬은 1단계에서 PC 라우트(`/be/...`)와 PC 메뉴 코드를 자동 제외하고 PDA 메뉴만 남긴다.

> **운영자 매뉴얼은 본 스킬의 범위가 아니다.** 운영자/관리자 매뉴얼은 `/TT_543` 스킬에서 처리한다.

> **템플릿 (BLOCKING)**
> PPTX 는 반드시 `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 마스터 / 테마 / 레이아웃은 그대로 보존하고, 템플릿 안에 들어있던 예제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.
> 템플릿이 없으면 스킬 실행을 중단하고 사용자에게 알린다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.
> 이미지 위에 라벨을 합성(Pillow 등)하지 않으며, 결과 PPTX를 PowerPoint에서 열어 도형을 드래그·텍스트 수정·색상 변경할 수 있어야 한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요. 모든 경로는 Windows 네이티브 경로(`C:\...`) 로 처리한다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python3 + python-pptx + Pillow.
> Node 의존성은 스킬 내부 `node_modules`에서 자동 설치, Python 패키지는 `pip install --user python-pptx Pillow`로 자동 설치한다.

---

## 사전 준비

### 인자 확정 (AskUserQuestion 활용)

다음 정보를 순서대로 확인한다. 인자(`$ARGUMENTS`)에 일부 값이 들어있으면 우선 사용하고, 없는 값만 사용자에게 묻는다.

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 띄울 프론트엔드 소스 루트. router 자동 스캔에 사용 | `C:\zinide\workspace\wms-cloud-fe` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버가 있으면 직접 입력. 없으면 `프로젝트 경로 + npm run dev`로 띄울지 확인 | `http://localhost:5173` |
| **고객사명** | 출력 파일명 `TT_542_사용자매뉴얼_PDA_{고객사명}.pptx`의 `{고객사명}`. 윈도우 파일명 금지문자(`\ / : * ? " < > \|`)는 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 `로그인 URL 추가 input`, `ID`, `PW`, `Origin/API URL(선택)`을 물어본다 | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 추출된 PDA 메뉴 후보 중 매뉴얼에 포함할 메뉴를 사용자가 다중 선택 | `ivad01m, ivmv01m, iwpc01m` |
| **뷰포트** | 모바일 고정 (390×844, `isMobile: true`) | `390x844` |

### 경로 정의 (PowerShell 동적 감지)

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$FeRoot    = Join-Path $Workspace "wms-$ProjCode-fe"

$BASE      = $DocRoot
$TEMPLATE  = Join-Path $BASE "template\05 이행(TT)\사용자_매뉴얼_템플릿.pptx"
$OUT_DIR   = Join-Path $BASE "output\05 이행(TT)"
$TMP_DIR   = Join-Path $BASE "output\05 이행(TT)\tmp_542"
$SCRIPTS   = Join-Path $BASE ".claude\skills\TT_542\scripts"
$OUT_FILE  = Join-Path $BASE "output\05 이행(TT)\TT_542_사용자매뉴얼_PDA_{고객사명}.pptx"
```

> **TMP 디렉토리 분리:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 는 `tmp_543` 를 사용하여 동시에 실행해도 충돌하지 않게 한다.

`OUTPUT_DIR`·`TMP_DIR`·`SCREEN_DIR`·`SCRIPTS\node_modules`가 없으면 자동 생성한다.
`TEMPLATE` 이 없으면 즉시 중단하고 사용자에게 알린다.

### 의존성 자동 설치 (PowerShell)

```powershell
# UTF-8 콘솔 강제 (한글 깨짐 방지)
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

# Node 측 (캡처용) — 스킬 내부 scripts 폴더에 격리 설치
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Set-Location "$DocRoot\.claude\skills\TT_542\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
npx playwright install chromium 2>$null

# Python 측 (PPTX 생성용)
python -c "from pptx import Presentation; from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user python-pptx Pillow
}
```

---

## PDA 메뉴 자동 식별 기준 (PC 자동 제외)

본 스킬은 wms-{업체코드}-fe 등 일반적인 router 구조에서 **PDA(모바일) 메뉴만** 추출한다. 아래 기준 중 하나라도 만족하면 **PDA로 간주하여 포함**하고, 아니면 PC로 간주하여 `rejected[]` 에 분리한다.

### PDA 식별 패턴 (포함 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/bm/` 포함 | `/bm/iv3000m/ivad01m`, `/bm/md8000m/mdpr01m` |
| 라우트 경로에 `/pda/` 포함 | `/pda/iv3000m/ivad01m` |
| 라우트 경로에 `/mobile/` 포함 | `/mobile/iw1000m/iwpc01m` |
| 부모 segment 가 `*m` 패턴 (영문+숫자+'m') | `iv3000m`, `md8000m`, `ow5000m` |
| 메뉴 코드 끝이 `m` (영문+숫자+'m') | `ivad01m`, `ivmvrq01m`, `sksp01m`, `skmg01m` |
| 메뉴 코드 prefix 가 `pda` | `pdamain` |

### PC 식별 패턴 (제외 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/be/` 포함 | `/be/iv3000/ivad01`, `/be/md8000/mdpr01` |
| 부모 segment 가 영문+숫자 (끝 'm' 없음) | `iv3000`, `md8000`, `ow5000` |
| 메뉴 코드 끝이 'm' 이 아님 | `ivad01`, `mdpr01`, `iwrq01` |

> **참고: wms-{업체코드}-fe 라우트 구조**
> - PC: `src/router/modules/be/{그룹}.js` → `path: '{그룹}'`, children `[{ path: '{메뉴}', menuCd: 'XXX' }]`
> - PDA: `src/router/modules/bm/{그룹m}.js` → `path: '{그룹m}'`, children `[{ path: '{메뉴m}', menuCd: 'XXXM' }]`
> - PC views: `src/views/be/{그룹}/{메뉴}/{메뉴}.vue`
> - PDA views: `src/views/bm/{그룹m}/{메뉴m}/{메뉴m}.vue`
>
> 메뉴명 보조 매핑은 `dist-mobile/{그룹m}/{메뉴대문자}.html` 의 `<title>` 태그에서 추출한다 (예: `dist-mobile/iv3000m/IVMV01.html`).

> **자동 식별이 완벽하지 않을 수 있다.** 1단계 스캔 결과는 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 최종 확정한다. 누락된 메뉴는 사용자가 직접 입력할 수 있게 한다.

---

## 단계별 워크플로우

각 단계는 PowerShell 로 스크립트를 실행하고, 그 결과 JSON 을 다음 단계가 읽는 방식으로 진행된다.

---

### 1단계 — FE 프로젝트 스캔으로 PDA 메뉴 후보 추출

**스크립트**: `scripts\01_scan_project.js`

**입력**: FE 프로젝트 경로
**출력**: `output\05 이행(TT)\tmp_542\menu_candidates.json`

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Set-Location $DocRoot
node ".claude\skills\TT_542\scripts\01_scan_project.js" "{FE경로}"
```

스크립트가 수행하는 일:

1. `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
2. `src/router/index.*`, `src/router/modules/**/*.{js,ts}`, `src/views/**/*.vue`, `src/pages/**/*.tsx` 에서 라우트 추출
3. `dist/{메뉴}/ui.md` 및 `dist-mobile/{그룹m}/{메뉴}.html` 의 `<title>` 에서 메뉴명 매핑
4. **PDA 필터 적용**: 위 "PDA 식별 패턴" 통과한 메뉴만 `menus[]` 에 keep
5. PC 메뉴는 `rejected[]` 에 분리 기록

`menu_candidates.json` 포맷:

```json
{
  "fePath": "C:\\zinide\\workspace\\wms-cloud-fe",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "menus": [
    { "code": "ivad01m", "name": "재고조정", "path": "/bm/iv3000m/ivad01m", "viewportHint": "pda" },
    { "code": "ivmv01m", "name": "재고이동", "path": "/bm/iv3000m/ivmv01m", "viewportHint": "pda" },
    { "code": "ivmvrq01m", "name": "재고이동요청", "path": "/bm/iv3000m/ivmvrq01m", "viewportHint": "pda" },
    { "code": "iwpc01m", "name": "입고처리", "path": "/bm/iw1000m/iwpc01m", "viewportHint": "pda" }
  ],
  "rejected": [
    { "code": "mdpr01", "name": "사은품관리", "reason": "PC 메뉴(/be/... 또는 코드 끝이 m이 아님) — /TT_541 에서 처리" },
    { "code": "iwrq01", "name": "입고예정", "reason": "PC 메뉴(/be/... 또는 코드 끝이 m이 아님) — /TT_541 에서 처리" }
  ],
  "scannedAt": "2026-05-15T14:00:00.000Z"
}
```

---

### 2단계 — 사용자 입력으로 캡처 대상 확정

`menu_candidates.json` 을 사용자에게 보여주고, AskUserQuestion으로 다음을 확정한다.

1. **BASE_URL 확정** — `guessedBaseUrl` 기본값. 사용자가 다른 URL을 쓰면 직접 입력.
2. **dev 서버 기동 여부** — 이미 떠 있으면 그대로 사용. 안 떠 있으면 사용자에게 `npm run dev` 를 실행하라고 안내.
3. **PDA 메뉴 선택** — `menus[]` 중 매뉴얼에 포함할 메뉴 다중 선택.
4. **로그인 정보** — 필요 시 `loginUrl`, `id`, `pw`, `originField`.
5. **고객사명** 확정.
6. **뷰포트** — 모바일 고정 (390×844, `isMobile: true`).

확정된 값은 `output\05 이행(TT)\tmp_542\capture_config.json` 으로 저장한다.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": { "needed": true, "url": "/login", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 390, "height": 844, "isMobile": true, "hideSidebar": false },
  "menus": [
    { "code": "ivad01m", "name": "재고조정", "path": "/bm/iv3000m/ivad01m", "scenarios": ["main", "search", "register", "rowSelect"] },
    { "code": "ivmv01m", "name": "재고이동", "path": "/bm/iv3000m/ivmv01m", "scenarios": ["main", "search", "process"] }
  ]
}
```

> **참고:** PDA 메뉴는 사이드바가 없거나 모바일 전용 헤더만 있으므로 `hideSidebar: false` 가 기본이다.

---

### 3단계 — Playwright 헤드리스 화면 캡처 (모바일 뷰포트)

**스크립트**: `scripts\02_capture_screens.js`

**입력**: `tmp_542\capture_config.json`
**출력**:
- `tmp_542\screens\{메뉴코드}\01-main.png`
- `tmp_542\screens\{메뉴코드}\02-search-result.png`
- `tmp_542\screens\{메뉴코드}\03-register-popup.png` (등록/처리 시나리오)
- `tmp_542\screens\{메뉴코드}\04-row-selected.png`
- `tmp_542\screens\{메뉴코드}\coords.json`

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Set-Location $DocRoot
node ".claude\skills\TT_542\scripts\02_capture_screens.js"
```

#### 모바일 컨텍스트 강제 (BLOCKING)

Playwright 브라우저는 반드시 모바일 환경으로 실행한다.

```js
const ctx = await browser.newContext({
    locale: 'ko-KR',
    timezoneId: 'Asia/Seoul',
    viewport: { width: 390, height: 844 },
    isMobile: true,
    hasTouch: true,
    userAgent: 'Mozilla/5.0 (Linux; Android 10; SM-G975N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36',
    extraHTTPHeaders: { 'Accept-Language': 'ko-KR,ko;q=0.9' },
});
```

- `isMobile: true` + `hasTouch: true`: Vue 컴포넌트가 모바일 모드로 렌더링
- 모바일 user-agent: 서버가 디바이스를 모바일로 인식

#### 표준 캡처 시나리오 (PDA 메뉴 특성에 맞춤)

| 파일명 | 트리거 | 캡처 영역 측정 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 (목록형 메뉴) | 헤더 + 검색바 + 첫 화면 |
| `02-search-result.png` | 검색바에서 키워드 입력 또는 필터 클릭 후 결과 로드 | 결과 목록 영역 |
| `03-register-popup.png` | "추가/등록/처리" 버튼 클릭 → 모달/페이지 캡처 | 모달 전체 또는 페이지 |
| `04-row-selected.png` | 결과 카드 첫 행 탭 → 디테일 화면 | 디테일 영역 |

**⚠ 실제 데이터 변경 금지 원칙**
- 처리/저장 액션 절대 클릭 금지.
- 취소 / ← 뒤로 가기 / ESC 로 모달·페이지 닫기.

#### PDA 특화 셀렉터 우선순위

wms-{업체코드}-fe `views/bm/**/*.vue` 컴포넌트 기준.

| 의도 | 셀렉터 후보 |
|---|---|
| PDA 헤더 | `.pda-hdr`, `.mobile-header`, `header.app-header` |
| 검색 입력 | `input.search-input`, `input[placeholder*="검색"]`, `.search-bar input` |
| 카드 목록 | `.card-list`, `.menu-cell`, `[class*="row-card"]`, `ul.item-list > li` |
| 액션 버튼 | `.bottom-action button`, `button.btn-primary`, `.cta-btn` |
| 모달 / 시트 | `.modal-bg`, `.bottom-sheet`, `.popup-layer`, `.pda-modal` |
| 뒤로 가기 | `.back-btn`, `button[aria-label="뒤로"]`, `.menu-hdr-close` |

---

### 4단계 — PPTX 생성 (모바일 종횡비, TT_541 양식 그대로)

**스크립트**: `scripts\03_make_pptx.py` (python-pptx)

**입력**:
- 템플릿: `template\05 이행(TT)\사용자_매뉴얼_템플릿.pptx`
- `tmp_542\capture_config.json`
- `tmp_542\screens\{메뉴코드}\*.png`
- `tmp_542\screens\{메뉴코드}\coords.json`

**출력**: `output\05 이행(TT)\TT_542_사용자매뉴얼_PDA_{고객사명}.pptx`

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Set-Location $DocRoot
python ".claude\skills\TT_542\scripts\03_make_pptx.py"
```

#### 슬라이드 구성

1. **표지 슬라이드** — 제목 "사용자 매뉴얼 (PDA)", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** — PDA 메뉴 목록을 자동 나열 (그룹별로 묶어서)
3. **메뉴 섹션 표지** — 메뉴마다 1장 (메뉴명 [메뉴코드])
4. **메뉴 화면 슬라이드** — 메뉴마다 캡처된 시나리오 수만큼 (보통 2~4장)

#### 화면 슬라이드 레이아웃 (PDA 모바일 종횡비 9:19.5)

- **이미지 영역**: 좌측 narrow 컬럼 (PDA 캡처는 세로형이라 가로 폭을 좁게)
  - 모바일 캡처 크기: 390×844 → PPT 표시 크기: 약 2.5×5.4in (종횡비 보존)
- **설명 패널**: 우측 wide 컬럼 (이미지 우측 ~ 13.33in)
- **라벨 박스**: 이미지 위에 투명 fill + 색상 테두리
- **배지**: 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존"에만 배치
- **페이지 번호**: 우하단 9pt #888888

> PPT 양식은 TT_541 과 동일하다. 차이점은 이미지 종횡비가 세로형(모바일)이라는 점뿐이며, `Geom` 클래스가 `min(IMG_COL_W/PX_W, IMG_AREA_H/PX_H)` 으로 자동 보존한다.

#### 색상 매핑 (TT_541 과 동일)

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

- `dist/{메뉴코드(끝m없는)}/ui.md` 가 존재하면 그 내용을 보조 활용 (PC ui.md 는 PDA와 약간 다를 수 있음)
- `dist-mobile/{그룹m}/{메뉴}.html` 이 있으면 HTML 안의 라벨 텍스트를 우선 활용
- PDA 사용자 관점으로 기술: 탭/스와이프/스캔 등 모바일 인터랙션 위주
- 코드 변수명·API 경로·DB 컬럼명을 직접 드러내지 않는다

---

### 5단계 — 완료 보고

```
✓ PDA 사용자매뉴얼 PPTX 생성 완료 [TT_542]

고객사    : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : 390x844 (모바일, isMobile=true)
locale    : ko-KR

출력 파일 : output\05 이행(TT)\TT_542_사용자매뉴얼_PDA_{고객사명}.pptx
슬라이드  : 표지 1 + 목차 1 + 메뉴섹션 N + 화면 M = 총 K장

캡처 PDA 메뉴 ({N}개):
  [재고관리]
    - ivad01m   재고조정     (3장)
    - ivmv01m   재고이동     (3장)
    - ivmvrq01m 재고이동요청 (4장)
  [입고]
    - iwpc01m   입고처리     (3장)

자동 제외된 PC 메뉴 ({P}개) — /TT_541 에서 처리:
  - mdpr01, mdct01, iwrq01, ...

PPT 안에서 라벨·테두리·배지·설명 패널은 도형으로 직접 편집 가능합니다.
```

---

## 메뉴별 단독 실행

이미 만든 PPTX에 메뉴를 한두 개만 추가/교체할 때는 같은 스킬을 다시 실행하고 2단계에서 해당 메뉴만 선택하면 된다. `tmp_542\screens\{메뉴코드}\`는 메뉴별로 분리되므로 다른 메뉴의 캡처는 보존된다.

PPTX는 매번 `OUT_FILE` 경로에 **전체 다시** 작성된다.

---

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| PDA 메뉴가 누락됨 | 메뉴 코드 끝에 'm' 이 없고 라우트 경로도 비표준 | 1단계 결과 `rejected[]` 를 사용자에게 보여주고 사용자가 직접 PDA로 복원 |
| PC 메뉴가 PDA로 잘못 분류됨 | 메뉴 코드 끝이 우연히 'm' 인데 PC 메뉴 | 1단계 결과를 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 직접 제거 |
| 모바일 렌더링이 데스크탑처럼 나옴 | Vue 컴포넌트가 `isMobile` 미확인 | `02_capture_screens.js` 가 `isMobile: true` + `hasTouch: true` + 모바일 user-agent 모두 적용 |
| 모달이 모바일 시트로 안 뜸 | `viewport` 만 모바일이고 user-agent 는 데스크탑 | 위 조건 모두 충족 + 디바이스 에뮬레이션 활성화 |
| 로그인 실패 "아이디를 입력해주세요" | 테스트 서버 3-필드 폼에서 origin 필드 처리 누락 | `capture_config.json` 의 `login.originField` 값이 있으면 자동 입력 |
| 이미지 왜곡 | width/height 비율을 종횡비와 다르게 지정 | `03_make_pptx.py` `Geom` 클래스가 종횡비 보존 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 시 예제가 결과에도 포함 | `remove_all_slides()` 호출 |
| dev 서버 미기동 | `npm run dev` 가 실행 안됨 | 사용자에게 별도 터미널에서 dev 서버를 띄우라고 안내 |

---

## 함께 보면 좋은 스킬

- PC 사용자 매뉴얼 PPTX → `/TT_541`
- 운영자 매뉴얼 PPTX → `/TT_543`
- PDA 화면 프로토타입 HTML 생성 → `/SD_312`
- 프로그램 목록 엑셀 → `/PI_412`
