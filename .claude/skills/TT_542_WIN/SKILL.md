---
name: TT_542_WIN
description: 【운영자매뉴얼 PPTX 생성 (Windows 전용)】 Windows 네이티브(PowerShell) 환경에서 사용자가 지정한 프론트엔드 + 백엔드 디렉토리를 자동 스캔하여 "운영자(관리자)가 시스템·사용자·권한·메뉴·공통코드·사업장·센터·창고 등을 설정하는 관리성 메뉴"만 자동 식별합니다. 식별된 메뉴들을 실제 dev/배포 서버에 Playwright(헤드리스, 한국어 로케일 ko-KR)로 접속하여 화면 캡처한 뒤, `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`를 base로 python-pptx 기반의 운영자매뉴얼 PPTX를 자동 생성합니다. PPT 양식·레이아웃·색상·도형 라벨링은 모두 TT_541 사용자매뉴얼 스킬과 동일한 양식을 따르며, 차이점은 (1) 대상 메뉴를 운영자/관리자 메뉴로만 필터링, (2) 표지 제목이 "운영자 매뉴얼", (3) Windows 경로 사용입니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_542_WIN 형식으로 실행하며 FE 경로·BE 경로·고객사명·BASE_URL·로그인 정보는 실행 시 묻습니다. 산출물은 `output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx` 단일 파일로 떨어집니다. 운영자 매뉴얼 작성, 관리자 매뉴얼 작성, 시스템 설정 매뉴얼, 운영자용 PPT 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "운영자매뉴얼 만들어줘", "관리자 매뉴얼 PPT 뽑아줘", "TT_542_WIN 실행해줘", "윈도우에서 운영자 매뉴얼 만들어줘", "관리자 화면 캡쳐해서 PPT 만들어줘", "운영자 매뉴얼 산출물 만들어줘" 라고 말해도 이 스킬을 사용합니다. 단, 일반 사용자 매뉴얼(입출고·재고 등 업무 화면)이 필요한 경우는 `/TT_541` 을 사용합니다. Linux/WSL/macOS 환경에서는 별도의 기본 TT_542 스킬을 사용합니다(있는 경우).
type: skill
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 운영자 매뉴얼 PPTX 자동 생성 스킬 (Windows 전용) [TT_542_WIN]

대상 FE/BE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(프론트엔드 + 백엔드)에서 **운영자가 시스템/사용자/권한/메뉴/공통코드/사업장/센터/창고 등을 설정하는 관리성 메뉴**를 자동 식별하고, **Playwright 헤드리스 모드(한국어 로케일)** 로 메뉴별 화면을 캡처한 뒤, `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 base로 **python-pptx** 로 운영자매뉴얼 PPTX 를 `output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx` 파일로 생성한다.

> **PPT 양식 (BLOCKING)**
> PPTX 의 레이아웃 · 색상 · 도형 라벨링 · 배지 · 커넥터 · 설명 패널 · 페이지 번호 규칙은 모두 **TT_541 사용자매뉴얼 스킬과 동일한 양식**을 따른다. 차이점은 (1) 표지 제목 "운영자 매뉴얼", (2) 대상 메뉴를 운영자/관리자 메뉴로만 필터링, (3) Windows 경로 사용 세 가지뿐이다.
>
> 템플릿 (`template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`) 는 TT_541 과 동일한 파일을 그대로 base 로 사용한다. 템플릿의 슬라이드 마스터 / 테마 / 레이아웃은 그대로 보존하고, 템플릿 안에 들어있던 예제 슬라이드는 모두 제거한 뒤 새 슬라이드를 추가한다.
> 템플릿이 없으면 스킬 실행을 중단하고 사용자에게 알린다.

> **사용자 매뉴얼은 본 스킬의 범위가 아니다.** 입고·출고·재고 등 일반 업무 화면의 매뉴얼은 `/TT_541` 또는 별도 사용자 매뉴얼 스킬을 사용한다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.
> 이미지 위에 라벨을 합성(Pillow 등)하지 않으며, 결과 PPTX를 PowerPoint에서 열어 도형을 드래그·텍스트 수정·색상 변경할 수 있어야 한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요. 모든 경로는 Windows 네이티브 경로(`C:\...`) 로 처리한다.
>
> **Bash 도구 사용 규칙 (중요):**
> 이 스킬은 Windows 네이티브 환경을 가정한다. Bash 도구로 PowerShell 을 호출할 때는 반드시 다음 패턴을 사용한다.
>
> ```
> powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell 명령>"
> ```
> 또는 PowerShell 도구를 직접 사용한다.
>
> Node·Python 은 cross-platform 이므로 `node ...`, `python ...` 명령은 PowerShell 에서 그대로 실행하면 된다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python3 + python-pptx + Pillow.
> Node 의존성은 스킬 내부 `node_modules`에서 자동 설치, Python 패키지는 `pip install --user python-pptx Pillow`로 자동 설치한다.

> **자동 로드 권장 스킬 (PPT 양식 일관성)**
> 이 스킬은 PPT 생성 단계에서 TT_541 의 양식·도형·색상 상수를 그대로 차용한다. TT_541 스킬의 `scripts/03_make_pptx.py` 가 존재하면 동일 로직을 재사용하므로, 같은 저장소에서 TT_541 / TT_542_WIN 을 함께 유지하면 양식이 자동으로 동기화된다.

---

## 사전 준비

### 인자 확정 (AskUserQuestion 활용)

다음 정보를 순서대로 확인한다. 인자(`$ARGUMENTS`)에 일부 값이 들어있으면 우선 사용하고, 없는 값만 사용자에게 묻는다.

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 띄울 프론트엔드 소스 루트. router 자동 스캔에 사용 | `C:\zinide\workspace_cloud\cloud-wms-fe` |
| **BE 프로젝트 경로** | 백엔드 소스 루트. Controller / @RequestMapping / 패키지명에서 운영자 메뉴 후보 추출에 사용 | `C:\zinide\workspace_cloud\cloud-wms-be` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버가 있으면 직접 입력. 없으면 `FE 경로 + npm run dev`로 띄울지 확인 | `http://localhost:5173` |
| **고객사명** | 출력 파일명 `TT_542_운영자매뉴얼_{고객사명}.pptx`의 `{고객사명}`. 윈도우 파일명 금지문자(`\ / : * ? " < > \|`)는 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 `로그인 URL 추가 input`, `ID`, `PW`, `Origin/API URL(선택)`을 물어본다. **운영자 매뉴얼은 관리자 권한 계정으로 로그인해야 함** | Y/N |
| **운영자 메뉴 후보 확정** | 1단계 자동 스캔으로 추출된 운영자 메뉴 후보를 사용자가 다중 선택으로 확정. 자동 식별이 누락한 메뉴는 직접 입력 가능 | `smus01, smmn01, smcd01, ...` |
| **뷰포트** | 운영자 화면은 통상 데스크탑(1440×900) 고정. PDA 메뉴는 운영자 매뉴얼에 거의 포함되지 않음 | `1440x900` |

### 경로 정의

```
BASE       = C:\zinide\workspace\cloud-wms-doc
TEMPLATE   = template\05 이행(TT)\사용자_매뉴얼_템플릿.pptx     ← 필수 (TT_541과 동일 파일)
OUTPUT_DIR = output\05 이행(TT)
TMP_DIR    = output\05 이행(TT)\tmp_542
SCREEN_DIR = output\05 이행(TT)\tmp_542\screens\{메뉴코드}
SCRIPTS    = .claude\skills\TT_542_WIN\scripts
OUT_FILE   = output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx
```

> **TT_541 과 TMP 디렉토리 분리:** TT_541 은 `output\05 이행(TT)\tmp` 를 쓰므로, TT_542_WIN 은 `output\05 이행(TT)\tmp_542` 로 별도 분리하여 동시에 실행해도 충돌하지 않게 한다.

`OUTPUT_DIR`·`TMP_DIR`·`SCREEN_DIR`·`SCRIPTS\node_modules` 가 없으면 자동 생성한다.
`TEMPLATE` 이 없으면 즉시 중단하고 사용자에게 알린다.

### 의존성 자동 설치 (PowerShell)

```powershell
# UTF-8 콘솔 강제 (한글 깨짐 방지)
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
chcp 65001 | Out-Null

# Node 측 (캡처용) — 스킬 내부 scripts 폴더에 격리 설치
Set-Location "C:\zinide\workspace\cloud-wms-doc\.claude\skills\TT_542_WIN\scripts"
if (-not (Test-Path "package.json")) { npm init -y | Out-Null }
if (-not (Test-Path "node_modules\playwright")) { npm install playwright | Out-Null }
# Chromium 브라우저 다운로드 (한 번만)
npx playwright install chromium 2>$null

# Python 측 (PPTX 생성용)
python -c "from pptx import Presentation; from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user python-pptx Pillow
}
```

> `python` 실행 실패 시 `py -3` 로 재시도한다.
> `npx playwright install chromium` 은 한 번만 실행하면 된다. 이미 설치된 경우 즉시 통과한다.

---

## 운영자 메뉴 자동 식별 기준 (핵심)

본 스킬의 가장 중요한 차별점은 **"운영자/관리자가 설정하는 관리성 메뉴"만 필터링**하는 것이다. 식별 기준은 다음과 같다.

### A. FE 라우트 경로 패턴 (우선순위 高)

| 패턴 | 의미 |
|---|---|
| `/sm/...` | System Management — 시스템 관리 메뉴 그룹 |
| `/admin/...` | 관리자 전용 |
| `/mgmt/...`, `/manage/...` | 관리 메뉴 |
| `/system/...` | 시스템 설정 |
| `/setting/...`, `/config/...` | 설정 |
| `/master/...`, `/md/.../mdm*` | 마스터 데이터 (사업장·센터·창고 등) |
| `/permission/...`, `/role/...`, `/auth/...` | 권한 관리 |

### B. 메뉴 코드 접두사 패턴

| 패턴 | 메뉴 종류 |
|---|---|
| `sm*` (예: `smus01`, `smmn01`, `smcd01`, `smgr01`) | 시스템 관리 (사용자/메뉴/공통코드/그룹) |
| `mdm*` (예: `mdmbz01`, `mdmce01`, `mdmwh01`, `mdmlc01`) | 마스터 데이터 관리 |
| `adm*`, `sys*`, `cfg*` | 관리/시스템/설정 |
| `usr*`, `mn*`, `rl*` | 사용자/메뉴/권한 |

### C. 메뉴명 키워드 (보조)

메뉴명에 다음 키워드가 포함된 경우 운영자 메뉴 후보로 본다.
`관리자`, `사용자관리`, `권한`, `메뉴관리`, `공통코드`, `시스템 파라미터`, `시스템 설정`, `사업장`, `센터`, `창고`, `로케이션`, `그룹 관리`

### D. BE Controller / @RequestMapping 보강

백엔드 디렉토리에서 다음 패턴의 Controller 파일이 있으면, 그 URL 접두사를 FE 라우트와 매칭해 메뉴 후보를 보강한다.

| 패턴 | 추출 |
|---|---|
| `package ...sm.controller.*` 또는 `package ...admin.controller.*` | URL prefix `/sm`, `/admin` |
| `@RequestMapping("/sm/...")` | `/sm/...` 라우트 발견 |
| `@RequestMapping("/mdm/...")` | `/mdm/...` 라우트 발견 |
| `@RequestMapping("/system/...")` | `/system/...` 라우트 발견 |
| 클래스명 `SmUserController`, `MdmBizController`, `AdminMenuController` 등 | 명명규칙 기반 메뉴 코드 추정 |

### E. 제외 기준 (자동 필터)

다음에 해당하면 운영자 메뉴 후보에서 자동 제외한다.

- `/pda/...` 또는 메뉴코드 끝이 `m` (PDA) — PDA 메뉴는 운영자가 쓰지 않는다.
- 입고/출고/재고/반품/피킹/배송 관련 (`iw*`, `ob*`, `iv*`, `rt*`, `pk*`, `dl*`) — 일반 사용자 메뉴 (TT_541 범위).
- 로그인·헬프·404 등 인증/공통 페이지.

> **자동 식별이 완벽하지 않을 수 있다.** 1단계 스캔 결과는 사용자에게 보여주고 `AskUserQuestion(multiSelect)` 으로 최종 확정한다. 누락된 메뉴는 사용자가 직접 입력할 수 있게 한다.

---

## 단계별 워크플로우

각 단계는 PowerShell 로 스크립트를 실행하고, 그 결과 JSON 을 다음 단계가 읽는 방식으로 진행된다. 각 단계 완료 후 산출물(`tmp_542\*.json` 또는 `screens\*.png`) 존재 여부를 확인한다.

```
.claude\skills\TT_542_WIN\scripts\
├── 01_scan_admin_menus.js   # 1단계 — FE + BE 스캔으로 운영자 메뉴 후보 추출
├── 02_capture_screens.js    # 2단계 — Playwright 헤드리스 캡처 (ko-KR, headless)
├── 03_make_pptx.py          # 3단계 — python-pptx 로 PPTX 생성 (TT_541 양식 그대로)
└── parse_vue_source.py      # 우측 설명 패널을 채우기 위한 Vue 소스 파서
                             # SearchSection 유무 / 검색필드 / 그리드 컬럼 / 버튼 / API 추출
```

---

### 1단계 — FE + BE 프로젝트 스캔으로 운영자 메뉴 후보 추출

**스크립트**: `scripts\01_scan_admin_menus.js`

**입력**: FE 프로젝트 경로, BE 프로젝트 경로
**출력**: `output\05 이행(TT)\tmp_542\admin_menu_candidates.json`

PowerShell:

```powershell
Set-Location "C:\zinide\workspace\cloud-wms-doc"
node ".claude\skills\TT_542_WIN\scripts\01_scan_admin_menus.js" "{FE경로}" "{BE경로}"
```

스크립트가 수행하는 일:

1. **FE 측 스캔** (TT_541 의 `01_scan_project.js` 와 동일 로직 + 운영자 필터):
   - `package.json`, `vite.config.*`, `next.config.*` 에서 dev 포트 추출
   - `src/router/**/*.{js,ts}`, `src/views/**/*.vue`, `src/pages/**/*.tsx` 에서 라우트 추출
   - `dist\{메뉴코드}\ui.md` 또는 `menu-index.md` 에서 메뉴명 매핑
   - **운영자 필터 적용**: 위 "운영자 메뉴 자동 식별 기준 A/B/C" 통과한 메뉴만 후보로 유지
   - "제외 기준 E" 해당 메뉴는 자동 제거
2. **BE 측 스캔**:
   - `**/*.java`, `**/*.kt` 파일에서 `@RestController`, `@Controller`, `@RequestMapping("/...")` 추출
   - 클래스명·패키지명에서 `sm`, `admin`, `mdm`, `sys` 패턴 매칭
   - 추출된 URL prefix 를 FE 라우트와 교차 매칭하여 FE 측 누락 메뉴 보강
3. **결과 머지**:
   - FE 발견 + BE 보강 결과를 머지하고 중복 제거
   - 각 메뉴에 식별 근거(`source: ["fe-route", "fe-name", "be-controller"]`) 기록

`admin_menu_candidates.json` 포맷:

```json
{
  "fePath": "C:\\zinide\\workspace_cloud\\cloud-wms-fe",
  "bePath": "C:\\zinide\\workspace_cloud\\cloud-wms-be",
  "framework": "vue3-vite",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "adminMenus": [
    {
      "code": "smus01",
      "name": "사용자관리",
      "path": "/sm/smus01",
      "category": "시스템관리",
      "source": ["fe-route", "be-controller"],
      "viewportHint": "desktop"
    },
    {
      "code": "smmn01",
      "name": "메뉴관리",
      "path": "/sm/smmn01",
      "category": "시스템관리",
      "source": ["fe-route"],
      "viewportHint": "desktop"
    },
    {
      "code": "smcd01",
      "name": "공통코드관리",
      "path": "/sm/smcd01",
      "category": "시스템관리",
      "source": ["fe-route", "be-controller"],
      "viewportHint": "desktop"
    },
    {
      "code": "mdmbz01",
      "name": "사업장관리",
      "path": "/md/mdmbz01",
      "category": "마스터",
      "source": ["fe-route"],
      "viewportHint": "desktop"
    }
  ],
  "rejected": [
    { "code": "iwrq01", "name": "입고예정", "reason": "일반업무메뉴(입고)" },
    { "code": "brsc01m", "name": "센터입고", "reason": "PDA 메뉴" }
  ],
  "scannedAt": "2026-05-12T14:00:00.000Z"
}
```

추출 실패 시 `adminMenus: []` 로 비워두고 사용자에게 직접 메뉴 목록을 입력받는다.

---

### 2단계 — 사용자 입력으로 캡처 대상 확정

`admin_menu_candidates.json` 을 사용자에게 보여주고, `AskUserQuestion` 으로 다음을 확정한다.

1. **BASE_URL 확정** — `guessedBaseUrl` 기본값. 사용자가 다른 URL 을 쓰면 직접 입력.
2. **dev 서버 기동 여부** — 이미 떠 있으면 그대로 사용. 안 떠 있으면 사용자에게 `npm run dev` 를 실행하라고 안내(자동 기동은 기본 미사용).
3. **운영자 메뉴 선택** — `adminMenus[]` 를 `multiSelect: true` 로 다중 선택. 누락된 메뉴는 "직접 입력" 으로 추가.
4. **로그인 정보** — **운영자 매뉴얼은 관리자 권한 계정으로 로그인해야 한다.** `loginUrl`, `id`(관리자 계정), `pw`, `originField`(있는 경우만).
5. **고객사명** 확정 (윈도우 파일명 금지문자 치환).
6. **뷰포트** — 기본 `1440x900` (운영자 화면은 데스크탑 고정).

확정된 값은 `output\05 이행(TT)\tmp_542\capture_config.json` 으로 저장한다.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": {
    "needed": true,
    "url": "/",
    "originField": "http://168.126.28.62:8085/api",
    "id": "admin",
    "pw": "********"
  },
  "viewport": { "width": 1440, "height": 900, "hideSidebar": true },
  "menus": [
    { "code": "smus01", "name": "사용자관리", "path": "/sm/smus01",
      "category": "시스템관리",
      "scenarios": ["main", "search", "register", "rowSelect", "edit"] },
    { "code": "smmn01", "name": "메뉴관리", "path": "/sm/smmn01",
      "category": "시스템관리",
      "scenarios": ["main", "search", "register", "rowSelect", "edit"] },
    { "code": "smcd01", "name": "공통코드관리", "path": "/sm/smcd01",
      "category": "시스템관리",
      "scenarios": ["main", "search", "register", "rowSelect", "edit"] }
  ]
}
```

---

### 3단계 — Playwright 헤드리스 화면 캡처 (한국어 로케일)

**스크립트**: `scripts\02_capture_screens.js`

**입력**: `tmp_542\capture_config.json`
**출력**:
- `tmp_542\screens\{메뉴코드}\01-main.png`
- `tmp_542\screens\{메뉴코드}\02-search-result.png`
- `tmp_542\screens\{메뉴코드}\03-register-popup.png` (등록 시나리오 있는 경우)
- `tmp_542\screens\{메뉴코드}\04-row-selected.png`
- `tmp_542\screens\{메뉴코드}\05-edit-popup.png` (수정 시나리오 있는 경우)
- `tmp_542\screens\{메뉴코드}\coords.json` (각 영역 DOM bounding box)
- `tmp_542\screens\{메뉴코드}\buttons\*.png` (툴바 / 팝업 버튼 아이콘)

PowerShell:

```powershell
Set-Location "C:\zinide\workspace\cloud-wms-doc"
node ".claude\skills\TT_542_WIN\scripts\02_capture_screens.js"
```

#### 한국어 로케일 강제 (BLOCKING)

Playwright 브라우저는 반드시 한국어 환경으로 실행한다.

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

- `--lang=ko-KR`: Chromium UI 언어
- `locale: 'ko-KR'`: `navigator.language` 와 `Intl` API 가 한국어를 반환
- `timezoneId: 'Asia/Seoul'`: 화면에 표시되는 날짜·시간이 한국 시간 기준
- `Accept-Language` 헤더: 서버가 i18n 분기 시 한국어를 받아옴

> 일부 시스템은 `Accept-Language` 또는 사용자 설정 언어에 따라 메뉴명을 영어로 표시할 수 있다. 운영자 매뉴얼은 한글 화면이 기본이므로 위 3가지를 모두 적용해야 한다.

#### 표준 캡처 시나리오 (메뉴별 자동 적용)

5단계로 캡처하지만 PPT 슬라이드에는 **01-main 을 제외** 한 4개 시나리오만 사용한다.
(01-main 은 검색 결과 없이 비어있는 초기 진입 화면이라 운영자에게 정보 가치가 낮음.)

| 파일명 | 트리거 | PPT 사용 여부 |
|---|---|---|
| `01-main.png` | 메뉴 진입 직후 (검색 조건 비어있음) | ❌ 슬라이드 미생성 (캡처는 유지하여 향후 확장 대비) |
| `02-search-result.png` | "검색" 버튼 클릭 + 결과 로드 대기 (검색 영역 없는 메뉴는 진입 직후 자동조회 결과) | ✅ "메인 화면" 슬라이드 |
| `03-register-popup.png` | "추가/등록" 버튼 클릭 → 팝업 오픈 후 캡처 → 취소로 닫음 | ✅ "등록 팝업" 슬라이드 |
| `04-row-selected.png` | 결과 그리드 첫 행 클릭 | ✅ "행 선택" 슬라이드 |
| `05-edit-popup.png` | 행 선택 후 "수정" 버튼 클릭 → 팝업 오픈 후 캡처 → 취소로 닫음 | ✅ "수정 팝업" 슬라이드 |

**⚠ 실제 데이터 변경 금지 원칙 (운영자 메뉴는 특히 중요)**
- 운영자 메뉴(사용자관리·메뉴관리·공통코드 등)에서 실제 INSERT/UPDATE/DELETE 가 발생하면 시스템 전체에 영향을 준다.
- 팝업은 열기만 함. 확인·저장·승인 버튼 클릭 **절대 금지**.
- 취소 / ESC / ✕ 닫기 버튼으로 팝업 닫기.
- 검색은 가능, 수정 액션은 절대 실행 금지.

#### 셀렉터 우선순위 (TT_541 과 동일)

cloud-wms-doc wireframe.html 및 wms-bnk-fe Vue 컴포넌트를 동시에 지원한다.
구체 셀렉터 풀은 `scripts/02_capture_screens.js` 의 `SEL` 객체를 참조한다.

#### 사이드바 숨김

뷰포트에 사이드바가 포함되어 화면을 가리는 경우, 캡처 직전에 사이드바를 `display:none` 으로 숨기고 메인 영역을 `width:100vw` 로 늘린다.
사이드바 자체를 매뉴얼에 포함해야 하면 `capture_config.json` 의 `viewport.hideSidebar=false` 로 끈다.

---

### 4단계 — PPTX 생성 (TT_541 양식 그대로, 표지·파일명만 운영자 매뉴얼로)

**스크립트**: `scripts\03_make_pptx.py` (python-pptx)

**입력**:
- 템플릿: `template\05 이행(TT)\사용자_매뉴얼_템플릿.pptx` (필수, TT_541 과 동일 파일)
- `tmp_542\capture_config.json`
- `tmp_542\screens\{메뉴코드}\*.png`
- `tmp_542\screens\{메뉴코드}\coords.json`

**출력**: `output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx`

PowerShell:

```powershell
Set-Location "C:\zinide\workspace\cloud-wms-doc"
python ".claude\skills\TT_542_WIN\scripts\03_make_pptx.py"
```

#### TT_541 와 동일한 처리 (BLOCKING)

다음 항목은 TT_541 의 `03_make_pptx.py` 와 **완전히 동일하게** 처리한다. 양식 변경은 금지한다.

- 슬라이드 크기: 13.33 × 7.5 인치 (16:9)
- 색상 상수: `COLOR_RED/ORANGE/BLUE/GREEN/GRAY/NAVY/DARK/WARN/TITLE_BG/...`
- 폰트: 맑은 고딕
- 레이아웃: 제목 바(#2D4B73, 흰 16pt) + 이미지영역(0~10in) + 설명패널(10~13.33in) + 페이지 번호(우하단 9pt)
- 영역 라벨링: `add_region_labels()` — 색상 테두리 + 좌상단 원형 번호 배지
- 설명 패널: `add_desc_panel()` — `■ 헤딩` + `· 본문` + `⚠ 경고` 라인
- 인라인 버튼 이미지: `[버튼명]` 토큰이 본문에 있으면 해당 버튼 PNG 로 자동 치환
- 페이지 번호: 모든 슬라이드 작성 완료 후 `i / total` 로 일괄 부여
- 템플릿 처리: `Presentation(TEMPLATE)` → `remove_all_slides()` → 새 슬라이드 추가

#### TT_541 와 다른 부분 (운영자 매뉴얼 특화)

1. **표지 제목**: `사용자 매뉴얼` → `운영자 매뉴얼`
2. **표지 부제**: `{고객사명} WMS` 는 유지
3. **출력 파일명**: `TT_542_운영자매뉴얼_{고객사명}.pptx`
4. **TMP 경로**: `tmp` → `tmp_542`
5. **카테고리 헤더(선택)**: 메뉴 카테고리(`시스템관리`, `마스터`)가 다른 경우 카테고리 전환 시 별도 섹션 표지를 추가하여 구분(시스템관리 → 마스터 등). 한 카테고리만 있으면 생략.
6. **설명 패널 톤**: TT_541 은 "사용자가 일상 업무에서 사용"하는 톤이지만, TT_542 는 "운영자가 시스템을 설정"하는 톤. ui.md 가 있으면 그대로 사용하되, 자동 생성되는 디폴트 문구는 운영자 톤(예: "신규 사용자 등록 시 [추가] 버튼을 클릭합니다", "권한 변경 후 [저장] 클릭")으로 살짝 다르게 처리.

#### 슬라이드 구성

1. **표지 슬라이드** — 제목 "운영자 매뉴얼", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** — 운영자 메뉴 목록을 자동 나열 (카테고리별로 묶어서)
3. **카테고리 섹션 표지** — 시스템관리 / 마스터 / 권한 등 (선택)
4. **메뉴 섹션 표지** — 메뉴마다 1장 (메뉴명 [메뉴코드])
5. **메뉴 화면 슬라이드** — 메뉴마다 캡처된 시나리오 수만큼 (보통 3~5장)

#### 색상 매핑 (TT_541 과 동일, 변경 없음)

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

#### 설명 패널 작성 원칙 (BLOCKING — Vue 소스 기반)

**우측 설명 패널은 일반 디폴트 문구가 아니라 실제 Vue 소스 코드에서 추출한 정보로 작성한다.**

이를 위해 스킬은 `scripts/parse_vue_source.py` 를 동봉한다.
이 파서는 `{FE경로}/src/views/**/{메뉴코드}/*.vue` 파일을 정규식 기반으로 분석해 다음을 추출한다:

| 추출 항목 | 출처 |
|---|---|
| `has_search`, `search_fields` | `<SearchSection>` + 그 내부의 `<ZCell :title="$t('message.XXX')">` |
| `grid_columns` | 모든 `headerText: 'XXX'` (visible:false 제외) |
| `toolbar_buttons` | `<ZBtn*>` 컴포넌트 (`ZBtnRowAdd`/`ZBtnRowDel`/`ZBtnRowSave`/`ZBtnProc` 등) + 슬롯 텍스트 |
| `has_popup_edit` | 같은 폴더에 `*Edt.vue` 또는 `*Popup.vue` 존재 여부 |
| `apis` | `axios.{get,post,put,delete}('/path', ...)` 의 URL |

`03_make_pptx.py` 의 `synth_regions_desc()` 는 이 정보를 사용해 다음 규칙으로 설명을 작성한다:

1. **검색 영역이 없는 메뉴** (`has_search=False` 이거나 `search_fields=[]`): 
   - 라벨에 "검색 조건" 을 표시하지 않는다.
   - 대신 "그리드 영역" / "기능 버튼" 으로 라벨링.
   - 본문에 "본 메뉴는 별도 검색 조건이 없으며, 진입 시 전체 목록이 자동 조회됩니다." 명시.
2. **검색 영역이 있는 메뉴**: `search_fields` 를 그대로 본문에 나열.
3. **그리드 컬럼**: `grid_columns` 를 3개씩 묶어 콤마로 표시 (가독성).
4. **기능 버튼**: `toolbar_buttons` 에서 PC매뉴얼/검색/초기화 등 메타 버튼은 자동 제외.
5. **편집 방식**: `has_popup_edit=True` 면 "팝업 편집" 안내, `False` 면 "인라인 편집" 안내.

**운영자 매뉴얼이므로 운영자 관점의 시나리오로 기술한다.** 예시:
  - 사용자관리: "신규 사용자 등록", "권한 변경", "사용자 비활성화"
  - 메뉴관리: "메뉴 추가 / 순서 변경 / 사용 권한 부여"
  - 공통코드: "코드 그룹 추가 / 상세 코드 등록"

코드 변수명·DB 컬럼명·API 경로는 본문에 직접 노출하지 않는다 (API 경로는 디버깅용으로만 사용).

> ⚠ `dist/{메뉴코드}/ui.md` 는 더 이상 사용하지 않는다. Vue 소스가 진실의 원본이며, ui.md 는 화면설계서 출력용일 뿐 운영자 매뉴얼과 동기화되지 않는다.

---

### 5단계 — 임시 파일 정리

PPTX 생성 성공 후, 비밀번호가 포함된 `capture_config.json` 을 보호하기 위해 `tmp_542\` 폴더를 삭제할지 사용자에게 묻는다.

```powershell
# 사용자가 'Yes' 선택 시
Remove-Item -Recurse -Force "C:\zinide\workspace\cloud-wms-doc\output\05 이행(TT)\tmp_542"
```

- 실패한 경우(연결 실패·캡처 실패 등)에는 디버깅을 위해 `tmp_542\` 를 그대로 두고, 사용자에게 원인을 보고한다.
- 삭제 결과(성공/실패)를 사용자에게 한 줄로 보고한다.

---

### 6단계 — 완료 보고

```
✓ 운영자매뉴얼 PPTX 생성 완료 [TT_542_WIN]

고객사       : {고객사명}
FE 경로      : {FE 프로젝트 경로}
BE 경로      : {BE 프로젝트 경로}
BASE_URL     : {BASE_URL}
실행 환경    : Windows PowerShell {PSVersion} / Node {버전} / Python {버전}
뷰포트       : {width}x{height}, locale=ko-KR

출력 파일    : output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx
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

## 메뉴별 단독 실행 (기능별 추가 생성)

이미 만든 PPTX 에 메뉴를 한두 개만 추가/교체할 때는 같은 스킬을 다시 실행하고
2단계에서 해당 메뉴만 선택하면 된다. `tmp_542\screens\{메뉴코드}\` 는 메뉴별로 분리되므로
다른 메뉴의 캡처는 보존된다.

PPTX 는 매번 `OUT_FILE` 경로에 **전체 다시** 작성된다 (부분 슬라이드 패치는 지원하지 않음).
이전 산출물을 보존해야 하면 실행 전에 파일을 백업하거나, `tmp_542\capture_config.json` 의 `menus[]` 에 모든 메뉴를 명시한다.

---

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| 운영자 메뉴 자동 식별이 누락됨 | 라우트가 `/sm/...` 가 아닌 비표준 경로(`/admin-user`) 사용 | 1단계 결과를 사용자에게 보여주고 직접 입력으로 보강 |
| 한글 메뉴명이 영어로 캡처됨 | 브라우저 `Accept-Language` 가 영어로 전송됨 | 2단계 `02_capture_screens.js` 가 `--lang=ko-KR` + `locale='ko-KR'` + `Accept-Language: ko-KR` 모두 적용 |
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` 또는 `display:none` 토글 팝업 | `02_capture_screens.js` 가 `getPopupBBox()` 에서 visible layer-wrapper 중 가장 큰 것을 채택 |
| 로그인 실패 "아이디를 입력해주세요" | 테스트 서버 3-필드 폼에서 origin 필드 처리 누락 | `capture_config.json` 의 `login.originField` 값이 있으면 첫 번째 input 에 해당 값 자동 입력 |
| PPT 양식이 TT_541 과 미세하게 다름 | `03_make_pptx.py` 가 별도로 유지되어 동기화 안 됨 | 본 스킬의 `03_make_pptx.py` 는 TT_541 의 로직을 그대로 복제. 양식 변경이 필요하면 TT_541 / TT_542_WIN 양쪽을 함께 수정한다. |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 시 예제 슬라이드가 결과에도 포함 | `remove_all_slides()` 로 sldIdLst 와 _Relationships 를 직접 비움 |
| 라벨이 본문 글자를 가림 | 배지를 이미지 위에 그림 | 배지는 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존" 에만 배치 |
| dev 서버 미기동 | `npm run dev` 가 실행 안 됨 | 사용자에게 별도 터미널에서 dev 서버를 띄우라고 안내. 자동 기동은 기본 미사용 (BLOCKING) |
| 운영자 계정 권한 부족으로 메뉴 진입 불가 | 일반 사용자 계정으로 로그인 | 2단계에서 `login.id` 는 반드시 관리자 권한 계정을 사용. 일반 계정으로는 운영자 메뉴 라우트 진입 시 403 또는 리다이렉트 발생 |

---

## 주의사항 (Windows 특화)

- **PowerShell 실행 정책:** 시스템 정책이 `Restricted` 면 스크립트 실행이 막힐 수 있다. Bash 도구로 `powershell.exe` 호출 시 `-ExecutionPolicy Bypass` 를 함께 지정한다.
- **`python` vs `py`:** Windows 에서는 `python` 또는 `py -3` 중 하나로 호출해야 한다. 우선 `python --version` 으로 확인하고, 실패하면 `py -3 --version` 으로 재시도한다.
- **한글 콘솔 출력 깨짐:** PowerShell 콘솔이 cp949 면 한글이 깨질 수 있다. 실행 전에 한 번 다음 명령으로 UTF-8 모드로 전환한다.
  ```powershell
  $env:PYTHONUTF8 = "1"
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  chcp 65001 | Out-Null
  ```
- **경로 공백·한글 처리:** `output\05 이행(TT)` 처럼 공백·한글이 포함된 경로는 반드시 큰따옴표로 감싼다. Python 에서는 `pathlib.Path` 가 자동 처리한다.
- **Windows·WSL 경로 자동 변환:** Node·Python 스크립트가 `/mnt/c/...` ↔ `C:\...` 를 자동 정규화한다.
- **출력 폴더가 이미 존재하면** 동일 파일을 덮어쓴다(매번 전체 재생성). 백업이 필요하면 실행 전에 파일을 별도 복사한다.
- **비밀번호 노출 방지:** 5단계에서 `tmp_542\capture_config.json` 안에 평문으로 저장된 비밀번호를 보호하기 위해 폴더 삭제 여부를 묻는다. 비정상 종료 시 폴더가 남아 있으면 즉시 수동 삭제한다.
- **함께 보면 좋은 스킬:**
  - 사용자 매뉴얼 PPTX → `/TT_541`
  - 프로그램 목록 엑셀 → `/PI_412`
  - DB 이관 데이터 dump SQL → `/TT_551_WIN`
  - 공통코드정의서 엑셀 → `/SD_332`

---

## 완료 체크리스트

- [ ] 입력(FE 경로 / BE 경로 / 고객사명) 확정
- [ ] `node --version`, `python --version` 으로 런타임 설치 확인
- [ ] Playwright `chromium` 브라우저 설치 확인 (`npx playwright install chromium`)
- [ ] `python-pptx`, `Pillow` import 가능 확인 (없으면 `pip install --user`)
- [ ] `tmp_542\admin_menu_candidates.json` 생성 — 운영자 메뉴 후보 1건 이상
- [ ] 사용자가 운영자 메뉴 다중 선택 + 로그인 정보(관리자 계정) 입력
- [ ] `tmp_542\capture_config.json` 저장 (`locale: ko-KR`)
- [ ] 메뉴별 `tmp_542\screens\{메뉴코드}\*.png` 생성 (최소 1장 이상)
- [ ] `output\05 이행(TT)\TT_542_운영자매뉴얼_{고객사명}.pptx` 생성 성공
- [ ] PowerPoint 에서 열어 도형(라벨/배지/커넥터/설명 패널) 편집 가능 여부 확인
- [ ] `tmp_542\` 삭제 또는 보존 여부 사용자에게 확인
