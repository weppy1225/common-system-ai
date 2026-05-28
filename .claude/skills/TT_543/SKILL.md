---
name: TT_543
description: 【운영자매뉴얼 PPTX 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 프론트엔드 + 백엔드 디렉토리를 자동 스캔하여 "운영자(관리자)가 시스템·사용자·권한·메뉴·공통코드·사업장·센터·창고 등을 설정하는 관리성 메뉴"만 자동 식별합니다. 식별된 메뉴들을 실제 dev/배포 서버에 Playwright(헤드리스, 한국어 로케일 ko-KR)로 접속하여 화면 캡처한 뒤, `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`를 base로 python-pptx 기반의 운영자매뉴얼 PPTX를 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. PPT 양식·레이아웃·색상·도형 라벨링은 모두 TT_541(PC 사용자매뉴얼) 스킬과 동일한 양식을 따르며, 차이점은 (1) 대상 메뉴를 운영자/관리자 메뉴로만 필터링, (2) 표지 제목이 "운영자 매뉴얼" 입니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_543 형식으로 실행하며 FE 경로·BE 경로·고객사명·BASE_URL·로그인 정보는 실행 시 묻습니다. 산출물은 `output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx` 단일 파일로 떨어집니다. 운영자 매뉴얼 작성, 관리자 매뉴얼 작성, 시스템 설정 매뉴얼, 운영자용 PPT 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "운영자매뉴얼 만들어줘", "관리자 매뉴얼 PPT 뽑아줘", "TT_543 실행해줘", "관리자 화면 캡쳐해서 PPT 만들어줘", "운영자 매뉴얼 산출물 만들어줘", "WSL에서 운영자 매뉴얼 만들어줘", "Linux에서 관리자 매뉴얼 캡쳐해줘" 라고 말해도 이 스킬을 사용합니다. 단, PC 사용자 매뉴얼(입출고·재고 등 업무 화면)이 필요한 경우는 `/TT_541`, PDA 사용자 매뉴얼이 필요한 경우는 `/TT_542` 을 사용합니다.
type: skill
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 운영자 매뉴얼 PPTX 자동 생성 스킬 (Windows/WSL/Linux/Mac 통합) [TT_543]

대상 FE/BE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(프론트엔드 + 백엔드)에서 **운영자가 시스템/사용자/권한/메뉴/공통코드/사업장/센터/창고 등을 설정하는 관리성 메뉴**를 자동 식별하고, **Playwright 헤드리스 모드(한국어 로케일)** 로 메뉴별 화면을 캡처한 뒤, `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 base로 **python-pptx** 로 운영자매뉴얼 PPTX 를 `output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx` 파일로 생성한다.

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
- FE 프로젝트 경로 — `C:\zinide\workspace\wms-{업체코드}-fe` (Win) 또는 `/mnt/c/...` (WSL)
- BE 프로젝트 경로 — `C:\zinide\workspace\wms-{업체코드}-be`
- ex) BASE_URL — `localhost:5173`
- 로그인 정보 — `admin / 1111` (반드시 관리자 권한 계정)
- 전체메뉴 / 옵션-단일메뉴 : `smus01`
- 뷰포트: 데스크탑 1440×900

## 실행 스크립트
1. `.claude/skills/TT_543/scripts/01_scan_admin_menus.js` (Node.js) — FE+BE 스캔 + 운영자 메뉴 필터
2. `.claude/skills/TT_543/scripts/02_capture_screens.js` (Node.js + Playwright chromium 헤드리스, ko-KR) — 메뉴별 캡처
3. `.claude/skills/TT_543/scripts/03_make_pptx.py` (Python + python-pptx + Pillow) — PPTX 생성
4. `.claude/skills/TT_543/scripts/parse_vue_source.py` (Python) — 우측 설명 패널을 채우기 위한 Vue 소스 파서

## 템플릿
- `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`

---

> **PPT 양식 (BLOCKING)**
> PPTX 의 레이아웃 · 색상 · 도형 라벨링 · 배지 · 커넥터 · 설명 패널 · 페이지 번호 규칙은 모두 **TT_541(PC 사용자매뉴얼) 스킬과 동일한 양식**을 따른다. 차이점은 (1) 표지 제목 "운영자 매뉴얼", (2) 대상 메뉴를 운영자/관리자 메뉴로만 필터링 두 가지뿐.

> **PC/PDA 사용자 매뉴얼은 본 스킬의 범위가 아니다.** 입고·출고·재고 등 일반 업무 화면의 매뉴얼은 `/TT_541`(PC) 또는 `/TT_542`(PDA) 을 사용한다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python + python-pptx + Pillow.

---

## 사전 준비 (공통)

### 인자 확정 (AskUserQuestion 활용)

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | 프론트엔드 소스 루트. router 자동 스캔 | `C:\zinide\workspace\wms-cloud-fe` 또는 `/mnt/c/...` |
| **BE 프로젝트 경로** | 백엔드 소스 루트. Controller / @RequestMapping 추출 | `C:\zinide\workspace\wms-cloud-be` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버 | `http://localhost:5173` |
| **고객사명** | 출력 파일명. OS 금지문자 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 로그인 정보 추가. **운영자 매뉴얼은 관리자 권한 계정** 필수 | Y/N |
| **운영자 메뉴 확정** | 1단계 자동 스캔 후보 다중 선택 + 직접 입력 보강 | `smus01, smmn01, smcd01, ...` |
| **뷰포트** | 데스크탑 고정 (1440×900) | `1440x900` |

### 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
BASE      = $DocRoot / $DOC_ROOT (동적 감지)
TEMPLATE  = template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx
OUT_DIR   = output/05 이행(TT)
TMP_DIR   = output/05 이행(TT)/tmp_543
SCRIPTS   = .claude/skills/TT_543/scripts
OUT_FILE  = output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx
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

### W-2) FE+BE 스캔 (운영자 메뉴 후보)

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

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

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

## 운영자 메뉴 자동 식별 기준 (공통, 핵심)

### A. FE 라우트 경로 패턴 (우선순위 高)

| 패턴 | 의미 |
|---|---|
| `/sm/...` | System Management — 시스템 관리 메뉴 그룹 |
| `/admin/...` | 관리자 전용 |
| `/mgmt/...`, `/manage/...` | 관리 메뉴 |
| `/system/...` | 시스템 설정 |
| `/setting/...`, `/config/...` | 설정 |
| `/master/...`, `/md/.../mdm*` | 마스터 데이터 |
| `/permission/...`, `/role/...`, `/auth/...` | 권한 관리 |

### B. 메뉴 코드 접두사 패턴

| 패턴 | 메뉴 종류 |
|---|---|
| `sm*` (예: `smus01`, `smmn01`, `smcd01`, `smgr01`) | 시스템 관리 |
| `mdm*` (예: `mdmbz01`, `mdmce01`, `mdmwh01`, `mdmlc01`) | 마스터 데이터 |
| `adm*`, `sys*`, `cfg*` | 관리/시스템/설정 |
| `usr*`, `mn*`, `rl*` | 사용자/메뉴/권한 |

### C. 메뉴명 키워드 (보조)

`관리자`, `사용자관리`, `권한`, `메뉴관리`, `공통코드`, `시스템 파라미터`, `시스템 설정`, `사업장`, `센터`, `창고`, `로케이션`, `그룹 관리`

### D. BE Controller / @RequestMapping 보강

| 패턴 | 추출 |
|---|---|
| `package ...sm.controller.*` 또는 `package ...admin.controller.*` | URL prefix `/sm`, `/admin` |
| `@RequestMapping("/sm/...")` | `/sm/...` 라우트 발견 |
| `@RequestMapping("/mdm/...")` | `/mdm/...` 라우트 발견 |
| `@RequestMapping("/system/...")` | `/system/...` 라우트 발견 |
| 클래스명 `SmUserController`, `MdmBizController` 등 | 명명규칙 기반 메뉴 코드 추정 |

### E. 제외 기준 (자동 필터)

- `/pda/...` 또는 메뉴코드 끝이 `m` (PDA)
- 입고/출고/재고/반품/피킹/배송 (`iw*`, `ob*`, `iv*`, `rt*`, `pk*`, `dl*`)
- 로그인·헬프·404 등 인증/공통 페이지

---

## 단계별 워크플로우 상세 (공통)

### 1단계 — FE + BE 프로젝트 스캔으로 운영자 메뉴 후보 추출

**스크립트**: `scripts/01_scan_admin_menus.js`
**출력**: `output/05 이행(TT)/tmp_543/admin_menu_candidates.json`

스크립트가 수행하는 일:

1. **FE 측 스캔** (TT_541 의 `01_scan_project.js` 와 동일 로직 + 운영자 필터):
   - dev 포트, 라우트, 메뉴명 매핑
   - 운영자 필터 (A/B/C) 적용, 제외 기준(E) 적용
2. **BE 측 스캔**:
   - `**/*.java`, `**/*.kt` 에서 `@RestController`, `@Controller`, `@RequestMapping("/...")` 추출
   - 패키지명/클래스명에서 `sm`, `admin`, `mdm`, `sys` 패턴 매칭
   - 추출된 URL prefix 를 FE 라우트와 교차 매칭하여 FE 측 누락 메뉴 보강
3. **결과 머지**: 중복 제거, 식별 근거 기록

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
    { "code": "iwrq01", "name": "입고예정", "reason": "일반업무메뉴(입고)" },
    { "code": "brsc01m", "name": "센터입고", "reason": "PDA 메뉴" }
  ],
  "scannedAt": "2026-05-12T14:00:00.000Z"
}
```

### 2단계 — 사용자 입력으로 캡처 대상 확정

AskUserQuestion으로 BASE_URL / dev 서버 / 운영자 메뉴(multiSelect) / 관리자 로그인 / 고객사명 / 뷰포트 확정.

`output/05 이행(TT)/tmp_543/capture_config.json` 저장.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": { "needed": true, "url": "/", "originField": "http://168.126.28.62:8085/api", "id": "admin", "pw": "********" },
  "viewport": { "width": 1440, "height": 900, "hideSidebar": true },
  "menus": [
    { "code": "smus01", "name": "사용자관리", "path": "/sm/smus01", "category": "시스템관리", "scenarios": ["main", "search", "register", "rowSelect", "edit"] }
  ]
}
```

### 3단계 — Playwright 헤드리스 화면 캡처 (한국어 로케일)

**스크립트**: `scripts/02_capture_screens.js`

#### 한국어 로케일 강제 (BLOCKING)

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

#### 표준 캡처 시나리오

5단계로 캡처하지만 PPT 슬라이드에는 **01-main 을 제외** 한 4개 시나리오만 사용한다 (01-main 은 초기 진입 빈 화면이라 가치 낮음).

| 파일명 | 트리거 | PPT 사용 여부 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 | 슬라이드 미생성 (캡처는 유지) |
| `02-search-result.png` | "검색" 클릭 + 결과 로드 | "메인 화면" 슬라이드 |
| `03-register-popup.png` | "추가/등록" 클릭 → 팝업 → 취소 | "등록 팝업" 슬라이드 |
| `04-row-selected.png` | 결과 그리드 첫 행 클릭 | "행 선택" 슬라이드 |
| `05-edit-popup.png` | 행 선택 후 "수정" → 팝업 → 취소 | "수정 팝업" 슬라이드 |

**⚠ 실제 데이터 변경 금지 원칙 (운영자 메뉴는 특히 중요)**
- 운영자 메뉴(사용자관리·메뉴관리·공통코드 등)에서 실제 INSERT/UPDATE/DELETE 가 발생하면 시스템 전체에 영향.
- 팝업은 열기만, 확인·저장·승인 절대 금지.
- 취소 / ESC / ✕ 닫기로 팝업 닫기.

### 4단계 — PPTX 생성 (TT_541 양식 그대로)

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)
**출력**: `output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx`

#### TT_541 와 동일한 처리 (BLOCKING)

다음 항목은 TT_541 의 `03_make_pptx.py` 와 **완전히 동일하게** 처리. 양식 변경 금지.

- 슬라이드 크기: 13.33 × 7.5 인치 (16:9)
- 색상 상수: `COLOR_RED/ORANGE/BLUE/GREEN/GRAY/NAVY/DARK/WARN/TITLE_BG/...`
- 폰트: 맑은 고딕
- 레이아웃: 제목 바(#2D4B73, 흰 16pt) + 이미지영역(0~10in) + 설명패널(10~13.33in) + 페이지 번호
- 영역 라벨링·설명 패널·인라인 버튼 이미지·페이지 번호·템플릿 처리(`remove_all_slides()`)

#### TT_541 와 다른 부분 (운영자 매뉴얼 특화)

1. **표지 제목**: `사용자 매뉴얼` → `운영자 매뉴얼`
2. **표지 부제**: `{고객사명} WMS` 유지
3. **출력 파일명**: `TT_543_운영자매뉴얼_{고객사명}.pptx`
4. **TMP 경로**: `tmp_541` → `tmp_543`
5. **카테고리 헤더**: 메뉴 카테고리(`시스템관리`, `마스터`)가 다르면 카테고리 전환 시 섹션 표지 추가
6. **설명 패널 톤**: TT_541 은 일반 사용자 톤, TT_543 은 운영자 톤 ("신규 사용자 등록 시 [추가] 버튼", "권한 변경 후 [저장] 클릭")

#### 슬라이드 구성

1. **표지** — 제목 "운영자 매뉴얼", 부제 "{고객사명} WMS", 작성일자
2. **목차** — 운영자 메뉴 목록 (카테고리별 묶음)
3. **카테고리 섹션 표지** — 시스템관리 / 마스터 / 권한 등 (선택)
4. **메뉴 섹션 표지** — 메뉴마다 1장
5. **메뉴 화면 슬라이드** — 메뉴마다 캡처 시나리오 수만큼

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

#### 설명 패널 작성 원칙 (BLOCKING — Vue 소스 기반)

**우측 설명 패널은 일반 디폴트 문구가 아니라 실제 Vue 소스 코드에서 추출한 정보로 작성한다.**

`scripts/parse_vue_source.py` 가 `{FE경로}/src/views/**/{메뉴코드}/*.vue` 를 정규식 분석:

| 추출 항목 | 출처 |
|---|---|
| `has_search`, `search_fields` | `<SearchSection>` + 내부 `<ZCell :title="$t('message.XXX')">` |
| `grid_columns` | `headerText: 'XXX'` (visible:false 제외) |
| `toolbar_buttons` | `<ZBtn*>` 컴포넌트 (`ZBtnRowAdd`/`ZBtnRowDel`/`ZBtnRowSave`/`ZBtnProc` 등) + 슬롯 텍스트 |
| `has_popup_edit` | 같은 폴더에 `*Edt.vue` 또는 `*Popup.vue` 존재 여부 |
| `apis` | `axios.{get,post,put,delete}('/path', ...)` URL |

`synth_regions_desc()` 가 이 정보로 설명 작성:
1. **검색 영역 없는 메뉴**: 라벨에 "검색 조건" 표시 안 함. "그리드 영역" / "기능 버튼" 으로 라벨링.
2. **검색 영역 있는 메뉴**: `search_fields` 를 그대로 본문에 나열.
3. **그리드 컬럼**: `grid_columns` 를 3개씩 묶어 콤마 표시.
4. **기능 버튼**: `toolbar_buttons` 에서 메타 버튼 자동 제외.
5. **편집 방식**: `has_popup_edit` 으로 "팝업 편집" / "인라인 편집" 분기.

**운영자 매뉴얼이므로 운영자 관점 시나리오로 기술:**
- 사용자관리: "신규 사용자 등록", "권한 변경", "사용자 비활성화"
- 메뉴관리: "메뉴 추가 / 순서 변경 / 사용 권한 부여"
- 공통코드: "코드 그룹 추가 / 상세 코드 등록"

코드 변수명·DB 컬럼명·API 경로는 본문에 직접 노출하지 않는다.

> ⚠ `dist/{메뉴코드}/ui.md` 는 더 이상 사용하지 않는다. Vue 소스가 진실의 원본.

---

## 6단계 — 완료 보고

```
✓ 운영자매뉴얼 PPTX 생성 완료 [TT_543]

실행 환경    : Windows PowerShell  또는  Bash on Linux/Mac/WSL
고객사       : {고객사명}
FE 경로      : {FE 프로젝트 경로}
BE 경로      : {BE 프로젝트 경로}
BASE_URL     : {BASE_URL}
뷰포트       : {width}x{height}, locale=ko-KR

출력 파일    : output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx
슬라이드     : 표지 1 + 목차 1 + 메뉴섹션 N + 화면 M = 총 K장

캡처 운영자 메뉴 ({N}개):
  [시스템관리]
    - smus01  사용자관리       (5장: 메인/검색/등록/행선택/수정)
    - smmn01  메뉴관리         (4장)
    - smcd01  공통코드관리     (5장)
  [마스터]
    - mdmbz01 사업장관리       (5장)
    - mdmce01 센터관리         (5장)
    - mdmwh01 창고관리         (4장)

PPT 안에서 라벨·테두리·배지·설명 패널은 도형으로 직접 편집 가능합니다.
PPT 양식은 TT_541 사용자매뉴얼과 동일하며, 표지 제목만 "운영자 매뉴얼"로 다릅니다.
```

---

## 메뉴별 단독 실행

이미 만든 PPTX 에 메뉴를 한두 개만 추가/교체할 때는 같은 스킬을 다시 실행하고 2단계에서 해당 메뉴만 선택하면 된다. `tmp_543/screens/{메뉴코드}/` 는 메뉴별로 분리.

PPTX 는 매번 `OUT_FILE` 경로에 **전체 다시** 작성된다.

---

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| 운영자 메뉴 자동 식별이 누락됨 | 라우트가 `/sm/...` 가 아닌 비표준 경로 | 1단계 결과를 사용자에게 보여주고 직접 입력 보강 |
| 한글 메뉴명이 영어로 캡처됨 | `Accept-Language` 가 영어 | `--lang=ko-KR` + `locale='ko-KR'` + `Accept-Language: ko-KR` 모두 적용 |
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` | `getPopupBBox()` 에서 visible layer-wrapper 중 가장 큰 것 채택 |
| 로그인 실패 | 3-필드 폼 origin 필드 누락 | `capture_config.json` 의 `login.originField` 값 자동 입력 |
| PPT 양식이 TT_541 과 미세하게 다름 | `03_make_pptx.py` 가 별도 유지 | TT_541 / TT_542 / TT_543 양쪽 함께 수정 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 | `remove_all_slides()` |
| 운영자 계정 권한 부족 | 일반 사용자 계정으로 로그인 | 2단계에서 `login.id` 는 반드시 관리자 권한 계정 |
| dev 서버 미기동 | `npm run dev` 안됨 | 사용자에게 별도 터미널에서 dev 서버 띄우라고 안내 |

---

## 완료 체크리스트

- [ ] 입력(FE 경로 / BE 경로 / 고객사명) 확정
- [ ] Node/Python 런타임 설치 확인
- [ ] Playwright `chromium` 브라우저 설치 확인
- [ ] `python-pptx`, `Pillow` import 가능
- [ ] `tmp_543/admin_menu_candidates.json` 생성 — 운영자 메뉴 후보 1건 이상
- [ ] 사용자가 운영자 메뉴 다중 선택 + 관리자 로그인 정보 입력
- [ ] `tmp_543/capture_config.json` 저장 (`locale: ko-KR`)
- [ ] 메뉴별 `tmp_543/screens/{메뉴코드}/*.png` 생성
- [ ] `output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx` 생성 성공
- [ ] PowerPoint 에서 도형 편집 가능 여부 확인
- [ ] `tmp_543/` 삭제

---

## 함께 보면 좋은 스킬

- PC 사용자 매뉴얼 PPTX → `/TT_541`
- PDA 사용자 매뉴얼 PPTX → `/TT_542`
- 프로그램 목록 엑셀 → `/PI_412`
- DB 이관 데이터 dump SQL → `/TT_551`
- 공통코드정의서 엑셀 → `/SD_332`

---

## 주의사항 (OS 특화)

### Windows 특화
- **`python` vs `py`**: `python --version` 확인 후 실패 시 `py -3` 재시도.
- **한글 콘솔 깨짐**: `chcp 65001` + `$env:PYTHONUTF8 = "1"`.

### Bash 특화
- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력 가능.
- **Playwright chromium**: WSL/Linux/macOS 각각 해당 OS 바이너리.
