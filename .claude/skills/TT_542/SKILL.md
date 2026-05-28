---
name: TT_542
description: 【PDA 사용자매뉴얼 PPTX 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스, 모바일 390×844)로 접속하여 PDA(모바일) 사용자 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 PDA 사용자매뉴얼 PPTX를 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. PC(데스크탑) 메뉴는 자동 제외되며 별도 스킬 /TT_541 에서 처리합니다. PDA 자동 식별 기준: 라우트 경로에 `/bm/`·`/pda/`·`/mobile/` 포함, 부모 segment 가 `*m` 패턴(`iv3000m`·`md8000m` 등), 메뉴코드 끝이 `m`(`ivad01m`·`ivmvrq01m` 등). cloud-wms-doc 의 `dist-mobile/{그룹}/{메뉴}.html` 도 보조 메뉴명 매핑에 활용합니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_542 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx 단일 파일로 떨어집니다. PDA 사용자 매뉴얼 작성, 모바일 사용자용 매뉴얼, PDA 화면 캡처 PPT, WMS 모바일 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "PDA 사용자매뉴얼 만들어줘", "모바일 매뉴얼 PPT 뽑아줘", "TT_542 실행해줘", "PDA 화면 캡쳐해서 PPT 만들어줘", "모바일 사용자 매뉴얼 산출물 만들어줘", "WSL에서 PDA 매뉴얼 만들어줘", "Linux에서 모바일 매뉴얼 캡쳐해줘" 라고 말해도 이 스킬을 사용합니다. 단, PC 사용자 매뉴얼이 필요한 경우는 /TT_541, 운영자 매뉴얼은 /TT_543 을 사용합니다.
type: skill
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PDA 사용자 매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_542]

대상 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(또는 사용자가 추가로 입력하는 BASE_URL)에서 dev 서버를 식별하고, **Playwright 헤드리스 모드(모바일 390×844, 한국어 로케일 ko-KR)** 로 **PDA 메뉴만** 캡처한 뒤, **사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx** 로 PDA 사용자매뉴얼 PPTX를 `output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx` 파일로 생성한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션] — `python`/`node` 실행, Windows 경로(`\`).
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션] — `python3`/`node` 실행, POSIX 경로(`/`).
```

> Node.js/Python 스크립트(`scripts/*.{js,py}`)는 양쪽에서 동일하게 동작.

---

## 자동 스캔
- FE 프로젝트 경로 — `C:\zinide\workspace\wms-{업체코드}-fe` (Win) 또는 `/mnt/c/zinide/workspace/wms-{업체코드}-fe` (WSL)
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

> **PC(데스크탑) 메뉴는 본 스킬의 범위가 아니다.** PC 메뉴는 `/TT_541` 스킬에서 별도로 처리한다.
> **운영자 매뉴얼은 본 스킬의 범위가 아니다.** 운영자/관리자 매뉴얼은 `/TT_543` 스킬에서 처리한다.

> **템플릿 (BLOCKING)**
> PPTX 는 반드시 `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 마스터 / 테마 / 레이아웃은 그대로 보존하고, 예제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.

---

## 사전 준비 (공통)

### 인자 확정 (AskUserQuestion 활용)

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 띄울 프론트엔드 소스 루트 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버 | `http://localhost:5173` |
| **고객사명** | 출력 파일명. OS 금지문자 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 로그인 정보 추가로 묻기 | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 추출된 PDA 메뉴 다중 선택 | `ivad01m, ivmv01m, iwpc01m` |
| **뷰포트** | 모바일 고정 (390×844, `isMobile: true`) | `390x844` |

### 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (동적 감지)
TEMPLATE  = template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx
OUT_DIR   = output/05 이행(TT)
TMP_DIR   = output/05 이행(TT)/tmp_542
SCRIPTS   = .claude/skills/TT_542/scripts
OUT_FILE  = output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx
```

> **TMP 디렉토리 분리:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 는 `tmp_543` 사용.

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

Set-Location "$DocRoot\.claude\skills\TT_542\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
npx playwright install chromium 2>$null

python -c "from pptx import Presentation; from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user python-pptx Pillow }
```

### W-2) FE 스캔

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_542\scripts\01_scan_project.js" "{FE경로}"
```

### W-3) 화면 캡처 (모바일 컨텍스트)

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_542\scripts\02_capture_screens.js"
```

### W-4) PPTX 생성

```powershell
Set-Location $DocRoot
python ".claude\skills\TT_542\scripts\03_make_pptx.py"
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
cd "$DOC_ROOT/.claude/skills/TT_542/scripts"
[ ! -f package.json ] && npm init -y
[ ! -d node_modules/playwright ] && npm install playwright
npx playwright install chromium 2>/dev/null

python3 -c "from pptx import Presentation; from PIL import Image" 2>/dev/null || pip3 install --user python-pptx Pillow
```

### B-2) FE 스캔

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_542/scripts/01_scan_project.js "{FE경로}"
```

### B-3) 화면 캡처 (모바일 컨텍스트)

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_542/scripts/02_capture_screens.js
```

### B-4) PPTX 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/TT_542/scripts/03_make_pptx.py
```

---

## PDA 메뉴 자동 식별 기준 (공통, PC 자동 제외)

### PDA 식별 패턴 (포함 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/bm/` 포함 | `/bm/iv3000m/ivad01m`, `/bm/md8000m/mdpr01m` |
| 라우트 경로에 `/pda/` 포함 | `/pda/iv3000m/ivad01m` |
| 라우트 경로에 `/mobile/` 포함 | `/mobile/iw1000m/iwpc01m` |
| 부모 segment 가 `*m` 패턴 | `iv3000m`, `md8000m`, `ow5000m` |
| 메뉴 코드 끝이 `m` | `ivad01m`, `ivmvrq01m`, `sksp01m`, `skmg01m` |
| 메뉴 코드 prefix 가 `pda` | `pdamain` |

### PC 식별 패턴 (제외 대상)

| 패턴 | 예시 |
|---|---|
| 라우트 경로에 `/be/` 포함 | `/be/iv3000/ivad01` |
| 부모 segment 가 영문+숫자 (끝 'm' 없음) | `iv3000`, `md8000` |
| 메뉴 코드 끝이 'm' 이 아님 | `ivad01`, `mdpr01` |

> **참고: wms-{업체코드}-fe 라우트 구조**
> - PC: `src/router/modules/be/{그룹}.js` → `path: '{그룹}'`
> - PDA: `src/router/modules/bm/{그룹m}.js` → `path: '{그룹m}'`
> - PDA views: `src/views/bm/{그룹m}/{메뉴m}/{메뉴m}.vue`
> - 메뉴명 보조 매핑: `dist-mobile/{그룹m}/{메뉴대문자}.html` 의 `<title>`

---

## 단계별 워크플로우 상세 (공통)

### 1단계 — FE 프로젝트 스캔으로 PDA 메뉴 후보 추출

**스크립트**: `scripts/01_scan_project.js`
**출력**: `output/05 이행(TT)/tmp_542/menu_candidates.json`

스크립트가 수행하는 일:
1. `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
2. router/views 파일에서 라우트 추출
3. `dist/{메뉴}/ui.md` 및 `dist-mobile/{그룹m}/{메뉴}.html` 에서 메뉴명 매핑
4. **PDA 필터 적용**: PDA 식별 패턴 통과한 메뉴만 `menus[]` 에 keep
5. PC 메뉴는 `rejected[]` 에 분리

```json
{
  "fePath": "C:\\zinide\\workspace\\wms-cloud-fe",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "menus": [
    { "code": "ivad01m", "name": "재고조정", "path": "/bm/iv3000m/ivad01m", "viewportHint": "pda" }
  ],
  "rejected": [
    { "code": "mdpr01", "name": "사은품관리", "reason": "PC 메뉴 — /TT_541 에서 처리" }
  ],
  "scannedAt": "2026-05-15T14:00:00.000Z"
}
```

### 2단계 — 사용자 입력으로 캡처 대상 확정

AskUserQuestion으로 BASE_URL / dev 서버 / 메뉴 / 로그인정보 / 고객사명 확정.

`output/05 이행(TT)/tmp_542/capture_config.json` 저장.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": { "needed": true, "url": "/login", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 390, "height": 844, "isMobile": true, "hideSidebar": false },
  "menus": [
    { "code": "ivad01m", "name": "재고조정", "path": "/bm/iv3000m/ivad01m", "scenarios": ["main", "search", "register", "rowSelect"] }
  ]
}
```

### 3단계 — Playwright 헤드리스 화면 캡처 (모바일 뷰포트)

**스크립트**: `scripts/02_capture_screens.js`

#### 모바일 컨텍스트 강제 (BLOCKING)

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

#### 표준 캡처 시나리오 (PDA 메뉴 특성에 맞춤)

| 파일명 | 트리거 | 캡처 영역 측정 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 | 헤더 + 검색바 + 첫 화면 |
| `02-search-result.png` | 검색 후 결과 로드 | 결과 목록 영역 |
| `03-register-popup.png` | "추가/등록/처리" 클릭 → 모달/페이지 | 모달 전체 또는 페이지 |
| `04-row-selected.png` | 결과 카드 첫 행 탭 | 디테일 영역 |

**⚠ 실제 데이터 변경 금지 원칙**: 처리/저장 액션 절대 클릭 금지. 취소 / ← 뒤로 가기 / ESC 로 닫기.

#### PDA 특화 셀렉터 우선순위

| 의도 | 셀렉터 후보 |
|---|---|
| PDA 헤더 | `.pda-hdr`, `.mobile-header`, `header.app-header` |
| 검색 입력 | `input.search-input`, `input[placeholder*="검색"]`, `.search-bar input` |
| 카드 목록 | `.card-list`, `.menu-cell`, `[class*="row-card"]`, `ul.item-list > li` |
| 액션 버튼 | `.bottom-action button`, `button.btn-primary`, `.cta-btn` |
| 모달 / 시트 | `.modal-bg`, `.bottom-sheet`, `.popup-layer`, `.pda-modal` |
| 뒤로 가기 | `.back-btn`, `button[aria-label="뒤로"]`, `.menu-hdr-close` |

### 4단계 — PPTX 생성 (모바일 종횡비, TT_541 양식 그대로)

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**출력**: `output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx`

#### 슬라이드 구성

1. **표지 슬라이드** — 제목 "사용자 매뉴얼 (PDA)", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** — PDA 메뉴 목록 (그룹별로 묶어서)
3. **메뉴 섹션 표지** — 메뉴마다 1장
4. **메뉴 화면 슬라이드** — 메뉴마다 캡처된 시나리오 수만큼

#### 화면 슬라이드 레이아웃 (PDA 모바일 종횡비 9:19.5)

- **이미지 영역**: 좌측 narrow 컬럼 (390×844 → 약 2.5×5.4in, 종횡비 보존)
- **설명 패널**: 우측 wide 컬럼
- **라벨 박스**: 이미지 위에 투명 fill + 색상 테두리
- **배지**: 이미지 우측 끝 ~ 설명 패널 사이 "배지 존"
- **페이지 번호**: 우하단 9pt #888888

#### 색상 매핑 (TT_541 과 동일)

| 목적 | HEX |
|---|---|
| 검색 조건 / 첫 번째 영역 | `DC1E1E` (빨강) |
| 두 번째 영역 | `C86E00` (주황) |
| 세 번째 영역 | `1E64C8` (파랑) |
| 빈 영역·초기 상태 | `6E6E6E` (회색) |
| 데이터 있는 결과 그리드 | `148C3C` (녹색) |
| 중립 헤딩 | `1A3A5C` (남색) |
| 일반 본문 | `333333` |
| 경고 (⚠) | `CC2222` |

#### 설명 패널 작성 원칙

- `dist/{메뉴코드(끝m없는)}/ui.md` 가 존재하면 보조 활용
- `dist-mobile/{그룹m}/{메뉴}.html` 이 있으면 HTML 안의 라벨 텍스트 우선 활용
- PDA 사용자 관점으로 기술: 탭/스와이프/스캔 등 모바일 인터랙션 위주
- 코드 변수명·API 경로·DB 컬럼명을 직접 드러내지 않는다

---

## 5단계 — 완료 보고

```
✓ PDA 사용자매뉴얼 PPTX 생성 완료 [TT_542]

실행 환경 : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사    : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : 390x844 (모바일, isMobile=true)
locale    : ko-KR

출력 파일 : output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx
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

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| PDA 메뉴가 누락됨 | 메뉴 코드 끝에 'm' 이 없고 라우트 경로도 비표준 | 1단계 결과 `rejected[]` 를 사용자에게 보여주고 직접 PDA로 복원 |
| PC 메뉴가 PDA로 잘못 분류됨 | 메뉴 코드 끝이 우연히 'm' 인데 PC | 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 직접 제거 |
| 모바일 렌더링이 데스크탑처럼 나옴 | Vue 컴포넌트가 `isMobile` 미확인 | `isMobile: true` + `hasTouch: true` + 모바일 user-agent 모두 적용 |
| 모달이 모바일 시트로 안 뜸 | `viewport` 만 모바일이고 user-agent 는 데스크탑 | 위 조건 모두 충족 |
| 로그인 실패 | 3-필드 폼에서 origin 필드 처리 누락 | `capture_config.json` 의 `login.originField` 값 활용 |
| 이미지 왜곡 | width/height 비율 어긋남 | `Geom` 클래스 종횡비 보존 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 | `remove_all_slides()` 호출 |
| dev 서버 미기동 | `npm run dev` 가 실행 안됨 | 사용자에게 별도 터미널에서 dev 서버를 띄우라고 안내 |

---

## 함께 보면 좋은 스킬

- PC 사용자 매뉴얼 PPTX → `/TT_541`
- 운영자 매뉴얼 PPTX → `/TT_543`
- PDA 화면 프로토타입 HTML 생성 → `/SD_312`
- 프로그램 목록 엑셀 → `/PI_412`

---

## 주의사항 (OS 특화)

### Windows 특화
- **Python 실행 명령**: `python` (PATH 등록 필요).
- **한글 콘솔 깨짐**: `chcp 65001` + `$env:PYTHONUTF8 = "1"`.

### Bash 특화
- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력 가능.
- **Playwright chromium**: WSL/Linux/macOS 각각 해당 OS 바이너리 다운로드.
