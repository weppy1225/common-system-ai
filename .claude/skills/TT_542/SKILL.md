---
name: TT_542
description: PDA 사용자매뉴얼 PPTX 생성 (Playwright 모바일 390×844 화면 캡처, python-pptx). /TT_542
when_to_use: "PDA 사용자매뉴얼 만들어줘", "모바일 매뉴얼 PPT 뽑아줘", "PDA 화면 캡처해서 PPT 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PDA 사용자매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_542]

입력 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 경로(또는 사용자가 직접 입력하는 BASE_URL)에서 dev 서버를 확인하고, **Playwright 헤드리스 브라우저(모바일 390×844, 한국어 로캘 ko-KR)** 로 **PDA 메뉴별** 화면을 캡처한 뒤, **사용자매뉴얼 샘플 pptx 를 base로 python-pptx** 로 PDA 사용자매뉴얼 PPTX를 `deliverables/30-output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx` 파일로 생성한다.

---

## OS 분기 및 공통 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 블록] → `python`/`node` 실행, Windows 경로(`\`).
- WSL / Linux / macOS (Bash):    uname 결과 (Linux/Darwin)
  → [Bash 블록] → `python3`/`node` 실행, POSIX 경로(`/`).
```

> Node.js/Python 스크립트(`scripts/*.{js,py}`)는 같은 위치에서 동일하게 실행.

---

## 실행 변수
- FE 프로젝트 경로 → `C:\zinide\workspace\wms-{프로젝트코드}-fe` (Win) 또는 `/mnt/c/zinide/workspace/wms-{프로젝트코드}-fe` (WSL)
- BE 프로젝트 경로 → (사용 안 함. FE만 필요)
- ex) BASE_URL → `localhost:5173`
- 로그인 정보 → `test / 1111`
- 예시메뉴 / 시작-종료메뉴 : `ivad01m`
- 뷰포트: 모바일 390×844 (`isMobile: true`)

## 실행 스크립트
1. `.claude/skills/TT_542/scripts/01_scan_project.js` (Node.js) → FE 스캔 + PC 제외 (PDA만 keep)
2. `.claude/skills/TT_542/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스, 모바일 에뮬레이션) → 메뉴별 캡처
3. `.claude/skills/TT_542/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) → PPTX 생성

## 템플릿
- `template/05 이행(TT)/사용자매뉴얼_샘플.pptx`

---

> **PC(데스크탑) 메뉴는 이 스킬에서 처리하지 않는다.** PC 메뉴는 `/TT_541` 스킬에서 별도로 처리한다.
> **관리자매뉴얼이 필요하면 이 스킬에서 처리하지 않는다.** 관리자 메뉴에 대한 매뉴얼은 `/TT_543` 스킬에서 처리한다.

> **템플릿(BLOCKING)**
> PPTX 생성에는 반드시 `template/05 이행(TT)/사용자매뉴얼_샘플.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 레이아웃 / 폰트 / 색상은 그대로 유지하고, 실제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.

> **PPT 직접 삽입 제약 (BLOCKING)**
> 텍스트박스·화살표·레이블·콜아웃 등의 요소는 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 계열로 PPT 파일에 직접 삽입한다.

> **의존성 안내**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.

---

## 사전 준비(공통)

### 매개변수 확인 (AskUserQuestion 사용)

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 켤 프로젝트 루트 디렉토리 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BASE_URL** | 이미 켜져 있는 dev/스테이징 서버 | `http://localhost:5173` |
| **고객사명** | 산출물 파일명. OS 금지문자 자동 `_` 교체 | `진아이드물류` |
| **로그인 필요 여부** | Y면 로그인 정보 직접 입력으로 진행 | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 발견한 PDA 메뉴 선택 | `ivad01m, ivmv01m, iwpc01m` |
| **뷰포트** | 모바일 고정 (390×844, `isMobile: true`) | `390x844` |

### 경로 정의

모든 경로는 git 최상위 디렉토리(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (자동 감지)
TEMPLATE  = template/05 이행(TT)/사용자매뉴얼_샘플.pptx
OUT_DIR   = deliverables/30-output/05 이행(TT)
TMP_DIR   = deliverables/30-output/05 이행(TT)/tmp_542
SCRIPTS   = .claude/skills/TT_542/scripts
OUT_FILE  = deliverables/30-output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx
```

> **TMP 디렉토리 구분:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 은 `tmp_543` 사용.

---

# === Windows 블록 (PowerShell) ===

### W-0) 경로 자동 감지

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
$RepoPrefix = $RepoName -replace '-[^-]+$',''
$FeRoot    = Join-Path $Workspace "$RepoPrefix-fe"
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

### W-3) 화면 캡처 (모바일 에뮬레이션)

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

# === Bash 블록 (WSL/Linux/Mac) ===

### B-0) 경로 자동 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
REPO_PREFIX="${REPO_NAME%-*}"
FE_ROOT="$WORKSPACE/${REPO_PREFIX}-fe"
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

### B-3) 화면 캡처 (모바일 에뮬레이션)

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

## PDA 메뉴 포함 판단 기준 (공통, PC 제외)

### PDA 포함 기준 (포함 대상)

| 기준 | 예시 |
|---|---|
| 라우터 경로에 `/bm/` 포함 | `/bm/iv3000m/ivad01m`, `/bm/md8000m/mdpr01m` |
| 라우터 경로에 `/pda/` 포함 | `/pda/iv3000m/ivad01m` |
| 라우터 경로에 `/mobile/` 포함 | `/mobile/iw1000m/iwpc01m` |
| 경로 segment 중 `*m` 패턴 | `iv3000m`, `md8000m`, `ow5000m` |
| 메뉴 코드 끝이 `m` | `ivad01m`, `ivmvrq01m`, `sksp01m`, `skmg01m` |
| 메뉴 코드 prefix 가 `pda` | `pdamain` |

### PC 제외 기준 (제외 대상)

| 기준 | 예시 |
|---|---|
| 라우터 경로에 `/be/` 포함 | `/be/iv3000/ivad01` |
| 경로 segment 가 소문자+숫자 (끝에 'm' 없음) | `iv3000`, `md8000` |
| 메뉴 코드 끝이 'm' 이 아닌 것 | `ivad01`, `mdpr01` |

> **참고: wms-{프로젝트코드}-fe 라우터 구조**
> - PC: `src/router/modules/be/{그룹}.js` 에서 `path: '{그룹}'`
> - PDA: `src/router/modules/bm/{그룹m}.js` 에서 `path: '{그룹m}'`
> - PDA views: `src/views/bm/{그룹m}/{메뉴m}/{메뉴m}.vue`
> - 메뉴명 보완 출처: `prototype/{프로젝트}/{메뉴코드}m/{메뉴코드}m-wireframe.html` 에서 `<title>`

---

## 단계별 상세 동작 (공통)

### 1단계 → FE 프로젝트 스캔으로 PDA 메뉴 후보 추출

**스크립트**: `scripts/01_scan_project.js`
**출력**: `deliverables/30-output/05 이행(TT)/tmp_542/menu_candidates.json`

스크립트가 수행하는 것:
1. `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
2. router/views 파일에서 라우터 추출
3. `spec/{프로젝트}/{메뉴}/{메뉴}-02-ui.md` 및 `prototype/{프로젝트}/{메뉴코드}m/{메뉴코드}m-wireframe.html` 에서 메뉴명 보완
4. **PDA 포함 기준** 적용 → PDA 메뉴만 `menus[]` 에 keep
5. PC 메뉴는 `rejected[]` 에 기록

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
    { "code": "mdpr01", "name": "프로모션", "reason": "PC 메뉴 → /TT_541 에서 처리" }
  ],
  "scannedAt": "2026-05-15T14:00:00.000Z"
}
```

### 2단계 → 사용자 입력으로 캡처 설정 확정

AskUserQuestion으로 BASE_URL / dev 서버 / 메뉴 / 로그인 정보 / 고객사명 확정.

`deliverables/30-output/05 이행(TT)/tmp_542/capture_config.json` 저장

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "진아이드물류",
  "login": { "needed": true, "url": "/login", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 390, "height": 844, "isMobile": true, "hideSidebar": false },
  "menus": [
    { "code": "ivad01m", "name": "재고조정", "path": "/bm/iv3000m/ivad01m", "scenarios": ["main", "search", "register", "rowSelect"] }
  ]
}
```

### 3단계 → Playwright 헤드리스 화면 캡처 (모바일 뷰포트)

**스크립트**: `scripts/02_capture_screens.js`

#### 모바일 에뮬레이션 필수 (BLOCKING)

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

#### 기본 캡처 시나리오 (PDA 메뉴 특성에 맞게)

| 파일명 | 시나리오 | 캡처 영역 지정 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 | 헤더 + 검색바 + 첫 화면 |
| `02-search-result.png` | 검색 후 결과 렌더링 | 결과 목록 영역 |
| `03-register-popup.png` | "추가/등록/처리" 클릭 후 모달/시트 | 모달 전체 또는 시트 |
| `04-row-selected.png` | 결과 목록 항목 클릭 | 서브 영역 |

**절대 실제 데이터 변경 금지**: 처리/확인 탭 클릭 금지. 닫기 / 뒤로 가기 / ESC 로 닫기.

#### PDA 전용 셀렉터 힌트

| 역할 | 셀렉터 예시 |
|---|---|
| PDA 헤더 | `.pda-hdr`, `.mobile-header`, `header.app-header` |
| 검색어 입력 | `input.search-input`, `input[placeholder*="검색"]`, `.search-bar input` |
| 목록 항목 | `.card-list`, `.menu-cell`, `[class*="row-card"]`, `ul.item-list > li` |
| 확인 버튼 | `.bottom-action button`, `button.btn-primary`, `.cta-btn` |
| 모달 / 시트 | `.modal-bg`, `.bottom-sheet`, `.popup-layer`, `.pda-modal` |
| 뒤로 가기 | `.back-btn`, `button[aria-label="뒤로"]`, `.menu-hdr-close` |

### 4단계 → PPTX 생성 (모바일 비율, TT_541 형식 동일)

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**출력**: `deliverables/30-output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx`

#### 슬라이드 구성

1. **표지 슬라이드** → 제목 "사용자매뉴얼(PDA)", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** → PDA 메뉴 목록 (그룹별로 묶어 표시)
3. **메뉴 그룹 구분 표지** → 메뉴마다 1장
4. **메뉴 화면 슬라이드** → 메뉴마다 캡처 시나리오 수만큼

#### 화면 슬라이드 레이아웃 (PDA 모바일 비율 9:19.5)

- **이미지 영역**: 좌측 narrow 컬럼 (390×844 픽셀을 약 2.5×5.4in으로 비율 유지)
- **설명 영역**: 우측 wide 컬럼
- **텍스트박스**: 이미지 위에 색상 fill + 색상 텍스트
- **화살표**: 이미지 오른쪽 ~ 설명 영역 사이 "화살표 선"
- **페이지 번호**: 오른쪽 아래 9pt #888888

#### 색상 기준 (TT_541 과 동일)

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

- `spec/{프로젝트}/{메뉴코드(끝m없는)}/{메뉴코드(끝m없는)}-02-ui.md` 가 있으면 우선 참조
- `prototype/{프로젝트}/{메뉴코드}m/{메뉴코드}m-wireframe.html` 이 있으면 HTML의 텍스트 기준 참조
- PDA 사용자 관점으로 작성: 앱 조작방법/목록/처리 → 모바일 특성 설명 포함
- 변수명·API 경로·DB 컬럼명을 직접 노출하지 않는다.
---

## 5단계 → 완료 보고

```
✅ PDA 사용자매뉴얼 PPTX 생성 완료 [TT_542]

실행 환경 : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사명   : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : 390x844 (모바일, isMobile=true)
locale    : ko-KR

산출물 파일 : deliverables/30-output/05 이행(TT)/TT_542_사용자매뉴얼_PDA_{고객사명}.pptx
슬라이드  : 표지 1 + 목차 1 + 메뉴그룹 N + 화면 M = 총 K장
캡처 PDA 메뉴 ({N}개):
  [재고관련]
    - ivad01m   재고조정     (3장)
    - ivmv01m   재고이동     (3장)
    - ivmvrq01m 재고이동요청 (4장)
  [입고]
    - iwpc01m   입고처리     (3장)

제외된 PC 메뉴 ({P}개) → /TT_541 에서 처리:
  - mdpr01, mdct01, iwrq01, ...

PPT 파일에서 텍스트박스·화살표·설명 영역은 도형으로 직접 삽입되어 있습니다.
```

---

## 문제해결 & 대처법
| 문제 | 원인 | 대처법 |
|------|------|--------|
| PDA 메뉴가 인식 안 됨 | 메뉴 코드 끝이 'm' 이거나 경로 확인 필요 | 1단계 결과 `rejected[]` 를 사용자에게 보여주고 직접 PDA로 복구 |
| PC 메뉴가 PDA로 잘못 분류 | 메뉴 코드 끝이 의도치 않게 'm' | 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 로 직접 제거 |
| 모바일 렌더링이 데스크탑처럼 나옴 | Vue 컴포넌트가 `isMobile` 무시 | `isMobile: true` + `hasTouch: true` + 모바일 user-agent 모두 적용 |
| 팝업이 모바일 시트로 표시 안 됨 | `viewport` 넓이가 모바일인데 user-agent 가 데스크탑 | 위 조건 모두 적용 |
| 로그인 실패 | 3-factor 에서 origin 필드 처리 누락 | `capture_config.json` 에 `login.originField` 가 있으면 사용 |
| 이미지 늘어남 | width/height 비율 계산 오류 | `Geom` 클래스의 비율 유지 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 후 미사용 | `remove_all_slides()` 호출 |
| dev 서버 연결 실패 | `npm run dev` 가 실행 안 됨 | 사용자에게 별도 터미널에서 dev 서버를 켜도록 요청 |

---

## 관련 스킬

- PC 사용자매뉴얼 PPTX → `/TT_541`
- 관리자매뉴얼 PPTX → `/TT_543`
- PDA 화면 프로토타입 HTML → `/SD_312`
- 프로그램 목록 산출물 → `/PI_412`

---

## 주의사항 (OS 별)

### Windows 주의사항
- **Python 실행 명령**: `python` (PATH 등록 필요).
- **한글 인코딩 출력**: `chcp 65001` + `$env:PYTHONUTF8 = "1"`.

### Bash 주의사항
- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력 받기.
- **Playwright chromium**: WSL/Linux/macOS 각각 해당 OS 바이너리로 설치.
