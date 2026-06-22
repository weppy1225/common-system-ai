---
name: SD_311
description: ui.md → 프로토타입 HTML(wireframe.html + mock-data.js) 생성 + 메뉴 자동 등록. /SD_311 {메뉴코드}
when_to_use: "화면 만들어줘", "프로토타입 생성해줘", "wireframe 만들어줘", "화면 뽑아줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
allowed-tools: Bash, Read, Write, Edit
---

# 화면설계 프로토타입 HTML 생성 규칙 [SD_311]

메뉴코드: **$ARGUMENTS**

`spec/$PROJECT/$ARGUMENTS/$ARGUMENTS-02-ui.md` 를 읽어, **공통 CSS·JS + 정해진 템플릿 파일**을 의거해 프로토타입 HTML과 목업 데이터 JS 파일을 생성한다.

> **STEP 0 — 프로젝트 층 도출** (→ `.claude/rules/repo-paths.md`): 허브 `spec/`·`prototype/` 는 프로젝트별 네임스페이스 아래에 있다. CWD(허브)에서 워크스페이스 폴더명으로 프로젝트명을 구한다.
> ```bash
> PROJECT=$(basename "$(dirname "$(git rev-parse --show-toplevel)")"); PROJECT=${PROJECT#workspace-}
> ```
> 이후 모든 `spec/$PROJECT/...`·`prototype/$PROJECT/...` 경로에 이 값을 쓴다. (생성되는 HTML 내부의 `../_common/` 상대경로는 트리 구조가 보존되므로 그대로 둔다.)

---

## 생성 원칙 (중요)

공통으로 제공되는 CSS·JS는 아래 파일로 분리되어 있다. **절대 수정하지 않는다.**

| 파일 | 역할 |
|---|---|
| `prototype/$PROJECT/_common/common.css`      | 모든 화면에 공통 적용되는 레이아웃·컴포넌트 CSS |
| `prototype/$PROJECT/_common/common.js`   | 공통 팝업(openCpPopup/openPdPopup), 페이징 유틸, 수평 스크롤 initHScroll/syncHScroll, esc, fmt |
| `prototype/$PROJECT/_common/_template/base.html`        | 전체 레이아웃 기본 뼈대 |
| `prototype/$PROJECT/_common/_template/grid1.html`       | UI유형: 그리드 1개 |
| `prototype/$PROJECT/_common/_template/grid2-tb.html`    | UI유형: 그리드 2개 (상하) |
| `prototype/$PROJECT/_common/_template/grid2-lr.html`    | UI유형: 그리드 2개 (좌우) |
| `prototype/$PROJECT/_common/_template/grid3-lrt.html`   | UI유형: 그리드 3개 (좌측 + 우측 상하) |
| `prototype/$PROJECT/_common/_template/grid3-tlb.html`   | UI유형: 그리드 3개 (상단 + 하단 좌우) |

생성하는 HTML에는 반드시 아래 2줄이 포함되어야 한다.

```html
<link rel="stylesheet" href="../_common/common.css">
<script src="../_common/common.js"></script>
```

**common.css 에 이미 정의된 공통 스타일은 HTML `<style>` 블록에서 재정의하지 않는다.** 화면 고유 스타일(특정 색상, 특수 레이아웃, 추가 컴포넌트)만 최소로 추가한다.

---

## 실행 순서

### 1단계 — 전체 파일 읽기

1. `spec/$PROJECT/$ARGUMENTS/$ARGUMENTS-02-ui.md` 화면요건정리 (핵심 입력)
2. `prototype/$PROJECT/_common/icon-preview.html` 에서 사용 가능한 아이콘 목록 확인 (**이 파일에 없는 아이콘은 절대 사용 금지**)
3. `prototype/$PROJECT/_common/_template/base.html` 에서 레이아웃 기본 뼈대 파악
4. 요건 문서의 **UI유형**에 해당하는 `_template/gridX-*.html` 1개를 메인 영역 템플릿으로 읽기

### 2단계 — 요건 파악

- **메뉴그룹명 / 메뉴그룹코드 / 메뉴명 / 메뉴코드 / UI유형 / 목적** (업무규칙 팝업 섹션에 기입)
- UI유형 → 사용할 템플릿 1개 결정
- 검색 영역 항목 수 (그룹별 묶음)
- 그리드별 툴바 버튼, 컬럼 목록 (컬럼명·정렬·편집여부)
- 팝업 목록 (등록/수정·조회)
- 공통 업무규칙 (각 `<li>` 항목으로 작성)
- 거래처·품목 팝업 연동 필드 목록

### 3단계 — 목업 데이터 JS 생성

파일: `prototype/$PROJECT/$ARGUMENTS/$ARGUMENTS-mock-data.js`

- 첫 줄 주석: `/* $ARGUMENTS 목업 데이터 */`
- 변수명: 메뉴코드 대문자 + `_DATA` (예: `MDFG01_DATA`)
- 메인 그리드 **10건 이상**, 서브 그리드 **5건 이상**
- `fetch()` / `.json` 방식 사용 금지

```js
/* mdfg01 목업 데이터 */
const MDFG01_DATA = {
  main: [ { ... }, ... ],   // 10건 이상
  d1:   [ { ... }, ... ],   // 5건 이상 (서브 그리드 있으면)
  d2:   [ { ... }, ... ]
};
```

### 4단계 — HTML 생성

생성 위치: `prototype/$PROJECT/$ARGUMENTS/$ARGUMENTS-wireframe.html`

1. `base.html` 을 복사한다.
2. UI유형에 맞는 `gridX-*.html` 내용을 `{{MAIN_AREA}}` 위치에 삽입한다.
3. 파일 **최상단** (`<!DOCTYPE html>` 바로 위에 빈 줄 없이) 주석을 삽입한다.

```html
<!--
  purpose: wireframe-only
  menuCode: {메뉴코드 소문자}
  menuName: {메뉴명}
  sourceOfTruth:
    ui: $ARGUMENTS-02-ui.md
  rules:
    - This file is a static HTML wireframe for layout/UX review only.
    - Do not copy raw HTML/CSS into production Vue components.
    - Use project design-system components and AUIGrid in production.
-->
```

4. 아래 플레이스홀더를 전부 교체한다.

| 플레이스홀더 | 교체 |
|---|---|
| `{{MENU_CODE}}`    | 메뉴코드 소문자 |
| `{{MENU_CODE_UP}}` | 메뉴코드 대문자 |
| `{{MENU_NAME}}`    | 메뉴명 |
| `{{CUSTOM_CSS}}`   | 화면 고유 CSS (없으면 공란) — **common.css 중복 금지** |
| `{{SEARCH_ROWS}}`  | 검색 영역 `<tr>...</tr>` |
| `{{GRID_MAIN_TOOLBAR}}` · `{{GRID_MAIN_COLGROUP}}` · `{{GRID_MAIN_THEAD}}` | 메인 그리드 구성 |
| `{{GRID_D1_*}}` · `{{GRID_D2_*}}` | 서브 그리드 구성 (해당 UI유형만) |
| `{{REG_POPUPS}}`   | 등록/수정·조회 팝업 HTML (각 팝업에 `id="xxxModal"` + 헤더 `id="xxxHeader"` 반드시 지정) |
| `{{RULE_TABLE}}`   | 업무규칙 팝업 화면구성 `<table class="rule-table">` 4행 |
| `{{RULE_LIST}}`    | 업무규칙 `<li>` 항목 (ui.md 원문 그대로) |
| `{{SCRIPT_BODY}}`  | 화면 고유 JS (doSearch, doReset, renderMainGrid, 페이지 이동, CRUD 등) |

#### 절대 금지

- `window.open()` 사용 → 공통 팝업은 `openCpPopup(targetId)` / `openPdPopup(targetId)` 사용 (common.js에 정의됨)
- 인라인 `style`로 `overflow` / `width` / `height` 직접 지정 (공통 클래스 사용)
- 그리드 셀 내에 텍스트 넘침 처리 없이 방치
- 사용여부 컬럼에 badge 색상 (텍스트만)
- ui.md에 없는 버튼(엑셀등록, 엑셀다운로드 등) 임의 추가
- 입력 필드에 placeholder 임의 추가
- 빈 stub 함수 (`function doXxx() {}`)
- **common.css 에 있는 공통 CSS 재정의** — `.panel`, `.grid-wrap`, `.toolbar`, `.modal`, `.btn` 등

#### 반드시 구현

- 버튼 동작: 추가/수정 → 팝업 열기, 삭제 → `confirm()` + 그리드 행 제거, 검색 → `alert()`, 그리드 행 선택 → 서브 그리드 갱신
- 각 팝업에 `initModalDrag('xxxModal', 'xxxHeader')` 호출 (업무규칙 팝업은 base.html에서 자동 호출)
- 페이징 렌더링: `renderPagination('mainPaging', total, size, current, 'goMainPage')` 형식
- 조회 건수: `renderRowCount('mainRowCount', total, size, current)`
- 수평 스크롤: `initHScroll('xxxWrap', 'xxxHScroll', 'xxxHInner', 'xxxTable')` + 이벤트 연동 `syncHScroll('xxxHInner', 'xxxTable')`
- 데이터 렌더링: `window.addEventListener('DOMContentLoaded', function() { mainAll = JSON.parse(JSON.stringify(MDFG01_DATA.main)); renderMainGrid(); })`

### 5단계 — 메뉴 등록

1. `prototype/$PROJECT/index.html` 에서 해당 메뉴그룹 `<ul class="submenu-list collapsed">` 블록을 찾아 항목 추가:
   ```html
   <li class="submenu-item" onclick="loadContent('$ARGUMENTS/$ARGUMENTS-wireframe.html', '{메뉴명}')">{메뉴명}</li>
   ```
2. `prototype/$PROJECT/_common/left-menu.html` 에도 동일하게 추가 (경로 prefix `../`):
   ```html
   <li class="submenu-item" onclick="loadContent('../$ARGUMENTS/$ARGUMENTS-wireframe.html', '{메뉴명}')">{메뉴명}</li>
   ```
3. 이미 등록된 메뉴코드면 중복 추가하지 않는다.

---

### 6단계 — 완료 체크리스트
- [ ] `$ARGUMENTS-mock-data.js` 생성 (메인 10건 이상·서브 5건 이상)
- [ ] `$ARGUMENTS-wireframe.html` 에 `<link rel="stylesheet" href="../_common/common.css">` 포함
- [ ] `$ARGUMENTS-wireframe.html` 에 `<script src="../_common/common.js"></script>` 포함
- [ ] 공통 스타일 CSS를 화면 `<style>` 에서 재정의하지 않음
- [ ] `<title>` 및 헤더에 `{메뉴명} [{메뉴코드}]` 정확히 표시
- [ ] 검색 영역 컬럼/컴포넌트가 요건과 일치
- [ ] 그리드 No. 및 체크박스 순서 준수, 첫 번째 컬럼 No.
- [ ] `<colgroup>` 각 `<col width>` 가 `area_result_grid.md` 최소 너비 이상 (헤더 잘림 없음)
- [ ] CRUD 버튼 모두 실제 동작 (stub 없음)
- [ ] 업무규칙 팝업 화면구성 4행 + `<ol>` 업무규칙 일치
- [ ] 등록/수정 팝업 코드 채번 (`{메뉴코드}P01`, `P02` 등)
- [ ] 거래처·품목 팝업 연동 → `openCpPopup('id')` / `openPdPopup('id')` 사용, `window.open()` 없음
- [ ] 각 팝업에 `initModalDrag('xxxModal', 'xxxHeader')` 호출
- [ ] `index.html` / `left-menu.html` 메뉴 중복 없이 등록
