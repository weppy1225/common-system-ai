---
name: TT_541
description: 【사용자매뉴얼 PPTX 생성】 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스)로 접속하여 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 사용자매뉴얼 PPTX를 자동 생성합니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_541 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_541_사용자매뉴얼_{고객사명}.pptx 단일 파일로 떨어집니다. 사용자 매뉴얼 작성, 운영자가 아닌 사용자용 매뉴얼, 화면 캡처 PPT, WMS 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "사용자매뉴얼 만들어줘", "사용자 매뉴얼 PPT 뽑아줘", "TT_541 실행해줘", "화면 캡쳐해서 PPT 만들어줘", "사용자 매뉴얼 산출물 만들어줘" 라고 말해도 이 스킬을 사용합니다. 단, 운영자 매뉴얼이 필요한 경우는 별도의 운영자 매뉴얼 스킬을 사용합니다.
type: skill
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 사용자 매뉴얼 PPTX 자동 생성 스킬 [TT_541]

대상 FE 프로젝트: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리(또는 사용자가 추가로 입력하는 BASE_URL)에서 dev 서버를 식별하고, **Playwright 헤드리스 모드**로 메뉴별 화면을 캡처한 뒤, **사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx**로 사용자매뉴얼 PPTX를
`output/05 이행(TT)/TT_541_사용자매뉴얼_{고객사명}.pptx` 파일로 생성한다.

> **템플릿 (BLOCKING)**
> PPTX 는 반드시 `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` 를 열어 base 로 사용한다.
> 템플릿의 슬라이드 마스터 / 테마 / 레이아웃은 그대로 보존하고, 템플릿 안에 들어있던 예제 슬라이드 6장은 모두 제거한 뒤 새 슬라이드를 추가한다.
> 템플릿이 없으면 스킬 실행을 중단하고 사용자에게 알린다.

> **운영자 매뉴얼은 본 스킬의 범위가 아니다.** 운영자 매뉴얼은 별도의 스킬에서 처리한다.

> **PPT 내 편집 가능 원칙 (BLOCKING)**
> 라벨 박스·테두리·배지·커넥터·설명 패널은 모두 python-pptx `add_shape` / `add_textbox` / `add_connector` 도형으로 PPT 안에 직접 그린다.
> 이미지 위에 라벨을 합성(Pillow 등)하지 않으며, 결과 PPTX를 PowerPoint에서 열어 도형을 드래그·텍스트 수정·색상 변경할 수 있어야 한다.

> **클라이언트 도구**: 캡처는 Node.js + Playwright, PPTX 생성은 Python3 + python-pptx + Pillow.
> Node 의존성은 스킬 내부 `node_modules`에서 자동 설치, Python 패키지는 `pip install --user python-pptx Pillow`로 자동 설치한다.

---

## 사전 준비

### 인자 확정 (AskUserQuestion 활용)

다음 정보를 순서대로 확인한다. 인자(`$ARGUMENTS`)에 일부 값이 들어있으면 우선 사용하고, 없는 값만 사용자에게 묻는다.

| 입력 | 설명 | 예시 |
|---|---|---|
| **FE 프로젝트 경로** | dev 서버를 띄울 프론트엔드 소스 루트. router 자동 스캔에 사용 | `C:\zinide\workspace_cloud\cloud-wms-fe` |
| **BASE_URL** | 이미 떠 있는 dev/스테이징 서버가 있으면 직접 입력. 없으면 `프로젝트 경로 + npm run dev`로 띄울지 확인 | `http://localhost:5173` |
| **고객사명** | 출력 파일명 `TT_541_사용자매뉴얼_{고객사명}.pptx`의 `{고객사명}`. 윈도우 파일명 금지문자(`\ / : * ? " < > \|`)는 자동 `_` 치환 | `반다이남코` |
| **로그인 필요 여부** | Y면 `로그인 URL 추가 input`, `ID`, `PW`, `Origin/API URL(선택)`을 물어본다 | Y/N |
| **메뉴 목록 선택** | 1단계 자동 스캔으로 추출된 메뉴 후보 중 매뉴얼에 포함할 메뉴를 사용자가 선택 | `mdpr01, mdct01, stdc01` |
| **뷰포트** | 데스크탑(1440×900) / PDA(390×844) 중 선택. 메뉴별로 다르면 1단계에서 자동 분기 | `1440x900` |

### 경로 정의

```
BASE       = /mnt/c/zinide/workspace/cloud-wms-doc
TEMPLATE   = template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx     ← 필수
OUTPUT_DIR = output/05 이행(TT)
TMP_DIR    = output/05 이행(TT)/tmp
SCREEN_DIR = output/05 이행(TT)/tmp/screens/{메뉴코드}
SCRIPTS    = .claude/skills/TT_541/scripts
OUT_FILE   = output/05 이행(TT)/TT_541_사용자매뉴얼_{고객사명}.pptx
```

`OUTPUT_DIR`·`TMP_DIR`·`SCREEN_DIR`·`SCRIPTS/node_modules`가 없으면 자동 생성한다.
`TEMPLATE` 이 없으면 즉시 중단하고 사용자에게 알린다.

### 의존성 자동 설치

```bash
# Node 측 (캡처용)
cd /mnt/c/zinide/workspace/cloud-wms-doc/.claude/skills/TT_541/scripts && \
  ([ -f package.json ] || npm init -y > /dev/null) && \
  ([ -d node_modules/playwright ] || npm install playwright > /dev/null) && \
  npx playwright install chromium > /dev/null 2>&1 || true

# Python 측 (PPTX 생성용)
python3 -c "from pptx import Presentation; from PIL import Image" 2>/dev/null || \
  pip install --user python-pptx Pillow
```

`npx playwright install chromium` 은 한 번만 실행하면 된다. 이미 설치된 경우 즉시 통과한다.

---

## 단계별 워크플로우

각 단계는 Bash로 스크립트를 실행하고, 그 결과 JSON을 다음 단계가 읽는 방식으로 진행된다. 각 단계 완료 후 산출물(`tmp/*.json` 또는 `screens/*.png`) 존재 여부를 확인한다.

---

### 1단계 — FE 프로젝트 스캔으로 메뉴 후보 추출

**스크립트**: `scripts/01_scan_project.js`

**입력**: FE 프로젝트 경로
**출력**: `output/05 이행(TT)/tmp/menu_candidates.json`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
node .claude/skills/TT_541/scripts/01_scan_project.js "{FE프로젝트경로}"
```

스크립트는 다음 파일을 자동 인식하여 dev 서버 포트와 라우트 목록을 추출한다.

| 패턴 | 추출 항목 |
|---|---|
| `package.json` | `scripts.dev`, `scripts.start` 의 포트 (`--port 5173`, `vite --port 3000` 등) |
| `vite.config.{js,ts}` | `server.port` |
| `next.config.{js,ts}` | (Next.js 기본 3000) |
| `webpack.config.js` / `vue.config.js` | `devServer.port` |
| `src/router/**/*.{js,ts}` 또는 `src/routes/**/*.{js,ts,tsx}` | `path: '/be/.../mdpr01'` 형태의 라우트 |
| `src/views/**/*.vue` (Vue) | 파일명 = 메뉴코드 후보 |
| `src/pages/**/*.{tsx,jsx}` (Next/React) | 파일경로 = 메뉴코드 후보 |
| `**/menu-index.md`, `**/menus.json` | 메뉴코드 ↔ 메뉴명 매핑 |

`menu_candidates.json` 포맷:

```json
{
  "fePath": "C:\\zinide\\workspace_cloud\\cloud-wms-fe",
  "framework": "vue3",
  "devPort": 5173,
  "guessedBaseUrl": "http://localhost:5173",
  "menus": [
    { "code": "mdpr01", "name": "사은품관리", "path": "/be/md8000/mdpr01", "viewportHint": "desktop" },
    { "code": "brsc01m","name": "센터입고","path": "/pda/brsc01m","viewportHint": "pda" }
  ]
}
```

추출 실패한 경우 `menus: []`로 비워두고 사용자에게 직접 메뉴 목록을 입력받는다.

---

### 2단계 — 사용자 입력으로 캡처 대상 확정

`menu_candidates.json` 을 사용자에게 보여주고, AskUserQuestion으로 다음을 확정한다.

1. **BASE_URL 확정** — `guessedBaseUrl` 기본값. 사용자가 다른 URL을 쓰면 직접 입력.
2. **dev 서버 기동 여부** — 이미 떠 있으면 그대로 사용. 안 떠 있으면 사용자에게 `npm run dev`를 실행하라고 안내(또는 사용자 동의 후 백그라운드 기동).
3. **메뉴 선택** — `menus[]` 중 매뉴얼에 포함할 메뉴 다중 선택.
4. **로그인 정보** — 필요 시 `loginUrl`, `id`, `pw`, `originField`(있는 경우만).
5. **고객사명** 확정.
6. **뷰포트** — 메뉴별 `viewportHint`가 있으면 그것을 따르고, 없으면 사용자가 일괄 지정.

확정된 값은 `output/05 이행(TT)/tmp/capture_config.json` 으로 저장한다.

```json
{
  "baseUrl": "http://168.126.28.62:8085",
  "customer": "반다이남코",
  "login": { "needed": true, "url": "/", "originField": "http://168.126.28.62:8085/api", "id": "jhlee", "pw": "1111" },
  "viewport": { "width": 1440, "height": 900 },
  "menus": [
    { "code": "mdpr01", "name": "사은품관리", "path": "/be/md8000/mdpr01", "scenarios": ["main", "search", "register", "rowSelect", "edit"] },
    { "code": "mdct01", "name": "거래처관리", "path": "/be/md8000/mdct01", "scenarios": ["main", "search", "register", "edit"] }
  ]
}
```

---

### 3단계 — Playwright 헤드리스 화면 캡처

**스크립트**: `scripts/02_capture_screens.js`

**입력**: `tmp/capture_config.json`
**출력**:
- `tmp/screens/{메뉴코드}/01-main.png`
- `tmp/screens/{메뉴코드}/02-search-result.png`
- `tmp/screens/{메뉴코드}/03-register-popup.png` (등록 시나리오 있는 경우)
- `tmp/screens/{메뉴코드}/04-row-selected.png`
- `tmp/screens/{메뉴코드}/05-edit-popup.png` (수정 시나리오 있는 경우)
- `tmp/screens/{메뉴코드}/coords.json` (각 영역 DOM bounding box)

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
node .claude/skills/TT_541/scripts/02_capture_screens.js
```

#### 표준 캡처 시나리오 (메뉴별 자동 적용)

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

#### 셀렉터 우선순위 (cloud-wms 계열 + 일반 fallback)

본 프로젝트의 wireframe.html 및 wms-bnk-fe Vue 컴포넌트를 동시에 지원한다.

| 의도 | 셀렉터 후보 (위→아래 순으로 시도) |
|---|---|
| 검색 버튼 | `button.btn-search:has-text("검색")`, `button:has-text("검색")`, `button[role="button"]:has-text("검색")` |
| 등록 버튼 | `.addImg[title="등록"]`, `button.btn-icon[title="추가"]`, `button:has-text("등록")`, `button:has-text("추가")` |
| 수정 버튼 | `.modifyImg[title="수정"]`, `button.btn-icon[title="수정"]`, `button:has-text("수정")` |
| 결과 그리드 첫 행 | `.grid-wrap tbody tr:first-child td`, `[class*="aui-grid-body"] tr:first-child td`, `table.grid tbody tr:nth-child(1)` |
| 팝업 컨테이너 | `.layer-wrapper`, `.modal[role="dialog"]`, `.modal-bg .modal` |
| 사이드바(숨김 대상) | `aside.menu-container`, `.left-menu`, `nav.sidebar` |
| 앱 메인(폭 보정) | `section.app-main`, `main.main-content`, `.content-wrap` |

#### 사이드바 숨김 (선택)

뷰포트에 사이드바가 포함되어 화면을 가리는 경우, 캡처 직전에 사이드바를 `display:none`으로 숨기고 메인 영역을 `width:100vw`로 늘린다.
사이드바 자체를 매뉴얼에 포함해야 하면 `capture_config.json`의 `viewport.hideSidebar=false`로 끈다.

---

### 4단계 — PPTX 생성 (템플릿 base + 라벨·테두리·배지를 PPT 도형으로 그림)

**스크립트**: `scripts/03_make_pptx.py` (python-pptx)

**입력**:
- 템플릿: `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx` (필수)
- `tmp/capture_config.json`
- `tmp/screens/{메뉴코드}/*.png`
- `tmp/screens/{메뉴코드}/coords.json`

**출력**: `output/05 이행(TT)/TT_541_사용자매뉴얼_{고객사명}.pptx`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 .claude/skills/TT_541/scripts/03_make_pptx.py
```

#### 템플릿 처리 방식 (BLOCKING)

1. `Presentation(TEMPLATE)` 으로 템플릿 PPTX 를 연다.
2. 템플릿 안의 예제 슬라이드(6장)는 `remove_all_slides()` 로 모두 제거한다.
   슬라이드 마스터 / 레이아웃 / 테마 / 폰트 / 색상은 그대로 보존된다.
3. 표지 → 목차 → (메뉴섹션 → 화면들) × N 순서로 새 슬라이드를 추가한다.
   슬라이드 좌표·색상·폰트는 템플릿(13.33×7.5 / #2D4B73 / 맑은 고딕 / 이미지 0~10in)과 동일.
4. 페이지 번호는 모든 슬라이드 작성 완료 후 `i / total` 로 일괄 부여한다.

#### 슬라이드 구성

1. **표지 슬라이드** — 제목 "사용자 매뉴얼", 부제 "{고객사명} WMS", 작성일자
2. **목차 슬라이드** — 메뉴 목록을 자동 나열
3. **메뉴 섹션 표지** — 메뉴마다 1장 (메뉴명 [메뉴코드])
4. **메뉴 화면 슬라이드** — 메뉴마다 캡처된 시나리오 수만큼 (보통 3~5장)

#### 화면 슬라이드 레이아웃 (16:9 와이드)

```
┌──────────────────────────────────────────────────────────┐
│ ① 사은품관리 메인 화면 (MDPR01)                            │  ← 제목 바 (#2D4B73, 흰 16pt)
├────────────────────────────┬─────────────────────────────┤
│                            │ ■ ① 검색 입력               │
│  [화면 캡처 이미지]         │ · 사업장 / 물류센터 ...     │
│                            │                             │
│  ┌──────┐ ─── ① 검색 입력  │ ■ ② 결과 그리드             │
│  │ ......│                 │ · 컬럼: 코드, 이름 ...      │
│  └──────┘                  │                             │
│  ┌────────────┐ ─ ② 그리드 │ ■ 사용 방법                 │
│  │            │            │ 1. 조건 입력 후 검색 클릭  │
│  └────────────┘            │ 2. 결과 행 클릭 → 디테일    │
│                            │                             │
└────────────────────────────┴─────────────────────────────┘
                                                  1 / 24
```

- **이미지 영역**: 데스크탑 = 0~10in (템플릿과 동일) / PDA 세로 = 0~5.6in
- **설명 패널**: 데스크탑 = 10~13.33in / PDA = 5.6~13.33in
- **라벨 박스**: 이미지 위에 투명 fill + 색상 테두리 (python-pptx `add_shape` 도형)
- **배지**: 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존"에만 배치
- **커넥터**: 배지 ↔ 영역 중심점 연결선 (`add_connector`)
- **페이지 번호**: 우하단 9pt #888888

좌표 / 색상 / 라벨 함수는 `scripts/03_make_pptx.py` 상단 `# ── 색상 상수 ──` 와 `Geom`, `add_region_labels` 에 모아두었으며, 메뉴별 시나리오 데이터는 `capture_config.json`의 `menus[].scenarios` 와 `coords.json` 에서 자동 합성한다.

#### 색상 매핑 (regions color = desc 헤딩 color)

| 목적 | HEX |
|---|---|
| 검색 조건 / 첫 번째 탭·그리드 | `DC1E1E` (빨강) |
| 두 번째 탭·그리드 | `C86E00` (주황) |
| 세 번째 탭·그리드 | `1E64C8` (파랑) |
| 빈 영역·초기 상태 | `6E6E6E` (회색) |
| 데이터 있는 결과 그리드 | `148C3C` (녹색) |
| 중립 헤딩(팝업·요약) | `1A3A5C` (남색) |
| 일반 본문 | `333333` |
| 경고 (⚠) | `CC2222` |

#### 설명 패널 작성 원칙

- 본 프로젝트 dist 의 `dist/{메뉴코드}/ui.md` 가 존재하면 그 내용을 우선 활용 (메뉴명, 검색조건, 그리드 컬럼, 업무규칙).
- ui.md 가 없는 경우 캡처된 DOM에서 추출한 라벨/플레이스홀더로 대체.
- **사용자 매뉴얼이므로 코드 변수명·API 경로·DB 컬럼명을 직접 드러내지 않는다.** 사용자가 화면에서 볼 수 있는 한글 라벨 기준으로 작성한다.

---

### 5단계 — 완료 보고

```
✓ 사용자매뉴얼 PPTX 생성 완료

고객사    : {고객사명}
FE 경로   : {FE 프로젝트 경로}
BASE_URL  : {BASE_URL}
뷰포트    : {width}x{height}

출력 파일 : output/05 이행(TT)/TT_541_사용자매뉴얼_{고객사명}.pptx
슬라이드  : 표지 1 + 목차 1 + 메뉴섹션 N + 화면 M = 총 K장

캡처 메뉴 ({N}개):
  - mdpr01  사은품관리   (5장: 메인/검색/등록/행선택/수정)
  - mdct01  거래처관리   (4장: 메인/검색/등록/수정)
  - ...

PPT 안에서 라벨·테두리·배지·설명 패널은 도형으로 직접 편집 가능합니다.
```

---

## 메뉴별 단독 실행 (기능별 추가 생성)

이미 만든 PPTX에 메뉴를 한두 개만 추가/교체할 때는 같은 스킬을 다시 실행하고
2단계에서 해당 메뉴만 선택하면 된다. `tmp/screens/{메뉴코드}/`는 메뉴별로 분리되므로
다른 메뉴의 캡처는 보존된다.

PPTX는 매번 `OUT_FILE` 경로에 **전체 다시** 작성된다 (부분 슬라이드 패치는 지원하지 않음).
이전 산출물을 보존해야 하면 실행 전에 파일을 백업하거나, `tmp/capture_config.json`의 `menus[]`에 모든 메뉴를 명시한다.

---

## 알려진 이슈 & 해결책

| 이슈 | 원인 | 해결책 |
|------|------|--------|
| 팝업 `getBoundingClientRect()` 가 0 반환 | Vue `v-show="false"` 또는 `display:none` 토글 팝업 | `02_capture_screens.js` 내 `findPopupBboxByPixel()` 함수가 팝업 헤더 색상을 픽셀 스캔하여 좌표 보정 (manual-maker §2 패턴 이식) |
| 로그인 실패 "아이디를 입력해주세요" | 테스트 서버 3-필드 폼에서 origin 필드 처리 누락 | `capture_config.json` 의 `login.originField` 값이 있으면 첫 번째 input에 해당 값 자동 입력 |
| 이미지 왜곡 | width/height 비율을 종횡비와 다르게 지정 시 발생 | `03_make_pptx.py` `Geom` 클래스가 `min(IMG_COL_W/PX_W, IMG_AREA_H/PX_H)` 으로 종횡비 보존 |
| 템플릿 슬라이드가 그대로 남음 | `Presentation(TEMPLATE)` 만 사용 시 예제 6장이 결과에도 포함 | `remove_all_slides()` 로 sldIdLst 와 _Relationships._rels 를 직접 비움 |
| 라벨이 본문 글자를 가림 | 배지를 이미지 위에 그림 | 배지는 이미지 우측 끝(IMG_R) ~ 설명 패널 사이 "배지 존"에만 배치 |
| dev 서버 미기동 | `npm run dev` 가 실행 안됨 | 사용자에게 별도 터미널에서 dev 서버를 띄우라고 안내. 자동 기동은 기본 미사용 (BLOCKING) |
