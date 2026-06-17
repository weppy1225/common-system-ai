---
name: TT_543
description: 관리자매뉴얼 PPTX 생성 (관리자 메뉴 자동 탐지 + Playwright 화면 캡처, python-pptx). /TT_543
when_to_use: "관리자매뉴얼 만들어줘", "운영자 매뉴얼 PPT 뽑아줘", "운영자 화면 캡처해서 PPT 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 관리자매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_543]

입력 FE/BE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 경로(FE 프로젝트 + BE 소스경로)에서 **관리자가 시스템설정·권한·메뉴·공통코드·사업장·센터·창고 등을 설정하는 관리형 메뉴**를 자동 탐지하고, 실제 dev/스테이징 서버를 **Playwright 헤드리스(한국어 로캘 ko-KR)** 로 접속하여 화면을 캡처한 뒤, `template/05 이행(TT)/사용자매뉴얼_샘플.pptx` 를 base로 **python-pptx** 로 관리자매뉴얼 PPTX 를 `output/05 이행(TT)/TT_543_관리자매뉴얼_{고객사명}.pptx` 파일로 생성한다.

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
- FE 프로젝트 경로 → `C:\zinide\workspace\wms-{프로젝트코드}-fe` (Win) 또는 `/mnt/c/...` (WSL)
- BE 프로젝트 경로 → `C:\zinide\workspace\wms-{프로젝트코드}-be`
- ex) BASE_URL → `localhost:5173`
- 로그인 정보 → `admin / 1111` (반드시 관리자 권한 계정)
- 예시메뉴 / 시작-종료메뉴 : `smus01`
- 뷰포트: 데스크탑 1440×900

## 실행 스크립트
1. `.claude/skills/TT_543/scripts/01_scan_admin_menus.js` (Node.js) → FE+BE 스캔 + 관리자 메뉴 탐지
2. `.claude/skills/TT_543/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스, ko-KR) → 메뉴별 캡처
3. `.claude/skills/TT_543/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) → PPTX 생성
4. `.claude/skills/TT_543/scripts/parse_vue_source.py` (Python) → 우측 설명 영역 작성을 위한 Vue 소스 파싱

## 템플릿
- `template/05 이행(TT)/사용자매뉴얼_샘플.pptx`

---

> **PPT 형식 (BLOCKING)**
> PPTX 레이아웃 · 색상 · 도형 · 페이지 번호 규칙은 모두 **TT_541(PC 사용자매뉴얼) 스킬과 동일**하게 적용한다. 차이점은 (1) 대상 메뉴를 관리자 전용 메뉴로만 필터링하고, (2) 표지 제목을 "관리자매뉴얼"로 표기.

> **PC/PDA 사용자매뉴얼이 필요하면 이 스킬에서 처리하지 않는다.** 입고·출고·재고 등 현장 운영 화면은 `/TT_541`(PC) 또는 `/TT_542`(PDA) 를 사용한다.

> **PPT 직접 삽입 제약 (BLOCKING)**
> 텍스트박스·화살표·레이블·콜아웃 등의 요소는 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 계열로 PPT 파일에 직접 삽입한다.

> **의존성 안내**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.

---

## 사전 준비(공통)

### 매개변수 확인 (AskUserQuestion 사용)

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | router 자동 스캔. 관리자 메뉴 탐지 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BE 프로젝트 경로** | Controller / @RequestMapping 탐지 | `C:\zinide\workspace\wms-cloud-be` |
| **BASE_URL** | 이미 켜져 있는 dev/스테이징 서버 | `http://localhost:5173` |
| **고객사명** | 산출물 파일명. OS 금지문자 자동 `_` 교체 | `진아이드물류` |
| **로그인 필요 여부** | Y면 로그인 정보 직접 입력. **관리자매뉴얼이므로 관리자 권한 계정 필수** | Y/N |
| **관리자 메뉴 선택** | 1단계 자동 탐지 결과에서 원하는 메뉴 선택 + 직접 입력 보완 | `smus01, smmn01, smcd01, ...` |
| **뷰포트** | 데스크탑 고정 (1440×900) | `1440x900` |

### 경로 정의

모든 경로는 git 최상위 디렉토리(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (자동 감지)
TEMPLATE  = template/05 이행(TT)/사용자매뉴얼_샘플.pptx
OUT_DIR   = output/05 이행(TT)
TMP_DIR   = output/05 이행(TT)/tmp_543
SCRIPTS   = .claude/skills/TT_543/scripts
OUT_FILE  = output/05 이행(TT)/TT_543_관리자매뉴얼_{고객사명}.pptx
```

> **TMP 디렉토리 구분:** TT_541 은 `tmp_541`, TT_542 는 `tmp_542`, TT_543 은 `tmp_543` 사용.

---

# === Windows 블록 (PowerShell) ===

### W-0) 경로 자동 감지

```powershell
$DocRoot   = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName  = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$FeRoot    = Join-Path $Workspace "wms-$ProjCode-fe"
$BeRoot    = Join-Path $Workspace "wms-$ProjCode-be"
```

### W-1) 의존성 자동 설치

```powershell
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

Set-Location "$DocRoot\.claude\skills\TT_543\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
npx playwright install chromium 2>$null

python -c "from pptx import Presentation; from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user python-pptx Pillow }
```

### W-2) FE+BE 스캔 (관리자 메뉴 탐지)

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_543\scripts\01_scan_admin_menus.js" "{FE경로}" "{BE경로}"
```

### W-3) 화면 캡처

```powershell
Set-Location $DocRoot
node ".claude\skills\TT_543\scripts\02_capture_screens.js"
```

### W-4) PPTX 생성

```powershell
Set-Location $DocRoot
python ".claude\skills\TT_543\scripts\03_make_pptx.py"
```

### W-5) 임시 파일 정리

```powershell
Remove-Item -Recurse -Force "$DocRoot\output\05 이행(TT)\tmp_543"
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
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"
```

### B-1) 의존성 자동 설치

```bash
cd "$DOC_ROOT/.claude/skills/TT_543/scripts"
[ ! -f package.json ] && npm init -y
[ ! -d node_modules/playwright ] && npm install playwright
npx playwright install chromium 2>/dev/null

python3 -c "from pptx import Presentation; from PIL import Image" 2>/dev/null || pip3 install --user python-pptx Pillow
```

### B-2) FE+BE 스캔

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_543/scripts/01_scan_admin_menus.js "{FE경로}" "{BE경로}"
```

### B-3) 화면 캡처

```bash
cd "$DOC_ROOT"
node .claude/skills/TT_543/scripts/02_capture_screens.js
```

### B-4) PPTX 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/TT_543/scripts/03_make_pptx.py
```

### B-5) 임시 파일 정리

```bash
rm -rf "$DOC_ROOT/output/05 이행(TT)/tmp_543"
```

---

## 관리자 메뉴 탐지 기준 (공통, 중요)

### A. FE 라우터 경로 패턴 (우선 적용)

| 패턴 | 분류 |
|---|---|
| `/sm/...` | 시스템 관리 → 관리자 메뉴 그룹 |
| `/admin/...` | 관리자 전용 |
| `/mgmt/...`, `/manage/...` | 관리형 메뉴 |
| `/system/...` | 시스템 설정 |
| `/setting/...`, `/config/...` | 설정 |
| `/master/...`, `/md/.../mdm*` | 마스터 데이터 |
| `/permission/...`, `/role/...`, `/auth/...` | 권한 관리 |

### B. 메뉴 코드 패턴으로 탐지

| 패턴 | 메뉴 분류 |
|---|---|
| `sm*` (예: `smus01`, `smmn01`, `smcd01`, `smgr01`) | 시스템 관리 |
| `mdm*` (예: `mdmbz01`, `mdmce01`, `mdmwh01`, `mdmlc01`) | 마스터 데이터 |
| `adm*`, `sys*`, `cfg*` | 관리·시스템 설정 |
| `usr*`, `mn*`, `rl*` | 사용자 메뉴/권한 |

### C. 메뉴명 키워드 판단(보완)

`관리자`, `사용자관리`, `권한`, `메뉴관리`, `공통코드`, `시스템알림`, `시스템설정`, `사업장`, `센터`, `창고`, `로그`, `그룹 관리`

### D. BE Controller / @RequestMapping 보완

| 패턴 | 탐지 |
|---|---|
| `package ...sm.controller.*` 또는 `package ...admin.controller.*` | URL prefix `/sm`, `/admin` |
| `@RequestMapping("/sm/...")` | `/sm/...` 라우터 연결 |
| `@RequestMapping("/mdm/...")` | `/mdm/...` 라우터 연결 |
| `@RequestMapping("/system/...")` | `/system/...` 라우터 연결 |
| 클래스명 `SmUserController`, `MdmBizController` 등 | 네이밍 기반 메뉴 코드 추정 |

### E. 제외 기준 (현장 운영 화면)

- `/pda/...` 또는 메뉴코드 끝이 `m` (PDA)
- 입고/출고/재고/반품/피킹/출하 (`iw*`, `ob*`, `iv*`, `rt*`, `pk*`, `dl*`)
- 로그인·공통·알림 페이지

---

## 단계별 상세 동작 (공통)

### 1단계 → FE + BE 프로젝트 스캔으로 관리자 메뉴 후보 추출

**스크립트**: `scripts/01_scan_admin_menus.js`
**출력**: `output/05 이행(TT)/tmp_543/admin_menu_candidates.json`

스크립트가 수행하는 것:

1. **FE 패키지 스캔** (TT_541 의 `01_scan_project.js` 와 동일 로직 + 관리자 필터링):
   - dev 포트, 라우터, 메뉴명 추출
   - 관리자 탐지 기준(A/B/C) 적용, 제외 기준(E) 적용
2. **BE 패키지 스캔**:
   - `**/*.java`, `**/*.kt` 에서 `@RestController`, `@Controller`, `@RequestMapping("/...")` 탐지
   - 클래스명·패키지에서 `sm`, `admin`, `mdm`, `sys` 패턴 추출
   - 탐지한 URL prefix 를 FE 라우터와 교차 매핑하여 FE 누락 메뉴 보완
3. **결과 정제**: 중복 제거, 탐지 근거 기록

```json
{
  "fePath": "C:\\zinide\\workspace\\wms-cloud-fe",
  "bePath": "C:\\zinide\\workspace\\wms-cloud-be",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "adminMenus": [
    { "code": "smus01", "name": "사용자관리", "path": "/sm/smus01", "category": "시스템관리", "source": ["fe-route", "be-controller"], "viewportHint": "desktop" },
    { "code": "mdmbz01", "name": "사업장관리", "path": "/md/mdmbz01", "category": "마스터", "source": ["fe-route"], "viewportHint": "desktop" }
  ],
  "rejected": [
    { "code": "iwrq01", "name": "입고예정", "reason": "현장운영화면(입고)" },
    { "code": "brsc01m", "name": "재고조회", "reason": "PDA 메뉴" }
  ],
  "scannedAt": "2026-05-12T14:00:00.000Z"
}
```

### 2단계 → 사용자 입력으로 캡처 설정 확정

AskUserQuestion으로 BASE_URL / dev 서버 / 관리자 메뉴(multiSelect) / 관리자 로그인 정보 / 고객사명 / 뷰포트 확정.

`output/05 이행(TT)/tmp_543/capture_config.json` 저장

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "진아이드물류",
  "login": { "needed": true, "url": "/", "originField": "http://168.126.28.62:8085/api", "id": "admin", "pw": "********" },
  "viewport": { "width": 1440, "height": 900, "hideSidebar": true },
  "menus": [
    { "code": "smus01", "name": "사용자관리", "path": "/sm/smus01", "category": "시스템관리", "scenarios": ["main", "search", "register", "rowSelect", "edit"] }
  ]
}
```

### 3단계 → Playwright 헤드리스 화면 캡처 (한국어 로캘)

**스크립트**: `scripts/02_capture_screens.js`

#### 한국어 로캘 필수 (BLOCKING)

```js
const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--lang=ko-KR'],
});
const ctx = await browser.newContext({
    locale: 'ko-KR',
    timezoneId: 'Asia/Seoul',
    extraHTTPHeaders: { 'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7' },
    viewport: { width: 1440, height: 900 },
});
```

#### 기본 캡처 시나리오

5단계로 캡처하되, PPT 슬라이드에는 **01-main 은 제외**하고 나머지 4개 시나리오만 사용한다 (01-main 은 기본 진입 확인용).

| 파일명 | 시나리오 | PPT 사용 여부 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 | 슬라이드 표지용(캡처만) |
| `02-search-result.png` | "검색" 클릭 + 결과 렌더링 | "메인 화면" 슬라이드 |
| `03-register-popup.png` | "추가/등록" 클릭 → 팝업 열림 → 닫기 | "등록 팝업" 슬라이드 |
| `04-row-selected.png` | 결과 그리드 행 클릭 | "행 선택" 슬라이드 |
| `05-edit-popup.png` | 행 선택 후 "수정" 클릭 → 팝업 열림 → 닫기 | "수정 팝업" 슬라이드 |

**절대 실제 데이터 변경 금지 (관리자매뉴얼이므로 특히 중요)**
- 관리자 메뉴(사용자관리·공통코드·시스템설정 등)에서 실제 INSERT/UPDATE/DELETE 가 발생하면 시스템 전체에 영향.
- 팝업은 열기만 하고 확인·저장 버튼 클릭 금지.
- 닫기 / ESC / 뒤로 가기로 팝업 닫기.

### 4단계 → PPTX 생성 (TT_541 형식 동일)

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**출력**: `output/05 이행(TT)/TT_543_관리자매뉴얼_{고객사명}.pptx`

#### TT_541 과 완전히 동일하게 처리 (BLOCKING)

아래 항목은 TT_541 의 `03_make_pptx.py` 와 **완전히 동일하게** 처리. 형식 변경 금지.

- 슬라이드 크기: 13.33 × 7.5 인치 (16:9)
- 색상 상수: `COLOR_RED/ORANGE/BLUE/GREEN/GRAY/NAVY/DARK/WARN/TITLE_BG/...`
- 폰트: 맑은 고딕
- 레이아웃: 표지 (제목 및 #2D4B73, 크기 16pt) + 이미지 영역(0~10in) + 설명 영역(10~13.33in) + 페이지 번호
- 영역 텍스트박스·콜아웃·화살표 삽입·페이지 번호·템플릿 처리(`remove_all_slides()`)

#### TT_541 과 다른 점 (관리자매뉴얼 전용)

1. **표지 제목**: `사용자매뉴얼` → `관리자매뉴얼`
2. **표지 부제**: `{고객사명} WMS` 유지
3. **산출물 파일명**: `TT_543_관리자매뉴얼_{고객사명}.pptx`
4. **TMP 경로**: `tmp_541` → `tmp_543`
5. **카테고리 구분 표지**: 메뉴 카테고리(`시스템관리` / `마스터`) 가 있으면 카테고리 구분 표지 페이지 앞에 추가
6. **설명 영역 차이**: TT_541 은 현장 사용자 기준. TT_543 은 관리자 기준("새 사용자 등록 → [추가] 버튼", "권한 변경", "사용자 비활성화")

#### 슬라이드 구성

1. **표지** → 제목 "관리자매뉴얼", 부제 "{고객사명} WMS", 작성일자
2. **목차** → 관리자 메뉴 목록 (카테고리별 묶음)
3. **카테고리 구분 표지** → 시스템관리 / 마스터 등 (선택)
4. **메뉴 그룹 표지** → 메뉴마다 1장
5. **메뉴 화면 슬라이드** → 메뉴마다 캡처 시나리오 수만큼

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

#### 설명 영역 작성 규칙 (BLOCKING → Vue 소스 기반)

**우측 설명 영역은 현장 사용자 화면 설명이 아니라 관리자 조작 안내이므로 반드시 실제 Vue 소스에서 추출한 정보로 작성한다.**

`scripts/parse_vue_source.py` 가 `{FE경로}/src/views/**/{메뉴코드}/*.vue` 를 파싱하여 추출:

| 추출 항목 | 추출 위치 |
|---|---|
| `has_search`, `search_fields` | `<SearchSection>` + 내부 `<ZCell :title="$t('message.XXX')">` |
| `grid_columns` | `headerText: 'XXX'` (visible:false 제외) |
| `toolbar_buttons` | `<ZBtn*>` 컴포넌트 (`ZBtnRowAdd`/`ZBtnRowDel`/`ZBtnRowSave`/`ZBtnProc` 등) + 비활성 조건 |
| `has_popup_edit` | 같은 폴더 안에 `*Edt.vue` 또는 `*Popup.vue` 파일 존재 여부 |
| `apis` | `axios.{get,post,put,delete}('/path', ...)` URL |

`synth_regions_desc()` 가 위 정보로 설명 생성:
1. **검색 영역 없는 메뉴**: 텍스트박스에 "그리드 영역" / "기능 버튼" 으로 표시.
2. **검색 영역 있는 메뉴**: `search_fields` 를 그대로 텍스트로 서술.
3. **그리드 컬럼**: `grid_columns` 를 3개만 묶어 대표 표시.
4. **기능 버튼**: `toolbar_buttons` 에서 핵심 버튼만 제외.
5. **팝업 여부**: `has_popup_edit` 로 "팝업 삽입" / "인라인 편집" 분기.

**관리자매뉴얼이므로 관리자 전용 시나리오로 안내:**
- 사용자관리: "새 사용자 등록", "권한 변경", "사용자 비활성화"
- 메뉴관리: "메뉴 추가 / 순서 변경 / 사용 설정"
- 공통코드: "코드 그룹 추가 / 코드 항목 등록"

변수명·DB 컬럼명·API 경로는 직접 노출하지 않는다.

> 단, `spec/{메뉴코드}/{메뉴코드}-02-ui.md` 는 이 스킬에서 사용하지 않는다. Vue 소스가 더 정확.

---

## 6단계 → 완료 보고

```
✅ 관리자매뉴얼 PPTX 생성 완료 [TT_543]

실행 환경    : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사명      : {고객사명}
FE 경로      : {FE 프로젝트 경로}
BE 경로      : {BE 프로젝트 경로}
BASE_URL     : {BASE_URL}
뷰포트      : {width}x{height}, locale=ko-KR

산출물 파일    : output/05 이행(TT)/TT_543_관리자매뉴얼_{고객사명}.pptx
슬라이드     : 표지 1 + 목차 1 + 메뉴그룹 N + 화면 M = 총 K장
캡처 관리자 메뉴 ({N}개):
  [시스템관리]
    - smus01  사용자관리      (5장: 메인/검색/등록/행선택/수정)
    - smmn01  메뉴관리        (4장)
    - smcd01  공통코드관리    (5장)
  [마스터]
    - mdmbz01 사업장관리      (5장)
    - mdmce01 센터관리        (5장)
    - mdmwh01 창고관리        (4장)

PPT 파일에서 텍스트박스·화살표·설명 영역은 도형으로 직접 삽입되어 있습니다.
PPT 형식은 TT_541 사용자매뉴얼과 동일하되, 표지 제목만 "관리자매뉴얼"로 다릅니다.
```

---

## 메뉴별 재실행

이미 생성된 PPTX에 메뉴를 추가하거나 수정하고 싶을 때는 이 스킬을 다시 실행하고 2단계에서 해당 메뉴만 선택한다. `tmp_543/screens/{메뉴코드}/` 는 메뉴별로 디렉토리가 분리되어 있다.

PPTX 는 항상 `OUT_FILE` 경로에 **항상 새로 생성**한다.

---

## 문제해결 & 대처법
| 문제 | 원인 | 대처법 |
|------|------|--------|
| 관리자 메뉴 탐지가 안 됨 | 라우터에 `/sm/...` 가 없거나 다른 prefix 사용 | 1단계 결과를 사용자에게 보여주고 직접 입력 보완 |
| 화면 언어가 영어로 캡처됨 | `Accept-Language` 가 영어 | `--lang=ko-KR` + `locale='ko-KR'` + `Accept-Language: ko-KR` 모두 적용 |
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` | `getPopupBBox()` 에서 visible layer-wrapper 위에 레이어 찾기 |
| 로그인 실패 | 3-factor 에서 origin 필드 처리 누락 | `capture_config.json` 에 `login.originField` 가 있으면 자동 입력 |
| PPT 형식이 TT_541 과 다르게 나옴 | `03_make_pptx.py` 가 별도 버전 | TT_541 / TT_542 / TT_543 스크립트 모두 동일 파일로 관리 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 후 미사용 | `remove_all_slides()` 호출 |
| 관리자 계정 권한 부족 | 일반 사용자로 로그인 | 2단계에서 `login.id` 반드시 관리자 계정 권한 계정 |
| dev 서버 연결 실패 | `npm run dev` 가 실행 안 됨 | 사용자에게 별도 터미널에서 dev 서버를 켜도록 요청 |

---

## 완료 체크리스트
- [ ] 입력(FE 경로 / BE 경로 / 고객사명) 확정
- [ ] Node/Python 의존성 설치 확인
- [ ] Playwright `chromium` 바이너리 설치 확인
- [ ] `python-pptx`, `Pillow` import 확인
- [ ] `tmp_543/admin_menu_candidates.json` 생성 → 관리자 메뉴 후보 1건 이상
- [ ] 사용자가 관리자 메뉴 선택 + 관리자 로그인 정보 입력
- [ ] `tmp_543/capture_config.json` 저장(`locale: ko-KR`)
- [ ] 메뉴별 `tmp_543/screens/{메뉴코드}/*.png` 생성
- [ ] `output/05 이행(TT)/TT_543_관리자매뉴얼_{고객사명}.pptx` 생성 성공
- [ ] PowerPoint 에서 도형 삽입 정상 여부 확인
- [ ] `tmp_543/` 삭제

---

## 관련 스킬

- PC 사용자매뉴얼 PPTX → `/TT_541`
- PDA 사용자매뉴얼 PPTX → `/TT_542`
- 프로그램 목록 산출물 → `/PI_412`
- DB 이관 데이터 dump SQL → `/TT_551`
- 공통코드정의서 엑셀 → `/SD_332`

---

## 주의사항 (OS 별)

### Windows 주의사항
- **`python` vs `py`**: `python --version` 확인 후 실패 시 `py -3` 대신.
- **한글 인코딩 출력**: `chcp 65001` + `$env:PYTHONUTF8 = "1"`.

### Bash 주의사항
- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력 받기.
- **Playwright chromium**: WSL/Linux/macOS 각각 해당 OS 바이너리로 설치.
