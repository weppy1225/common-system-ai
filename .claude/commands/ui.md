# 화면 생성 명령어

메뉴코드: **$ARGUMENTS**

`dist/$ARGUMENTS/$ARGUMENTS.md` 를 읽고, **공통 CSS·JS + 스켈레톤 템플릿**을 조합해 프로토타입 HTML과 테스트 데이터 JS 파일을 생성한다.

---

## 생성 전략 (중요)

공통으로 반복되던 CSS·JS는 아래 파일로 분리되어 있다. **매번 재정의하지 않는다.**

| 파일 | 용도 |
|---|---|
| `dist/common/wms-ui.css`      | 모든 화면이 공유하는 레이아웃·컴포넌트 CSS |
| `dist/common/wms-common.js`   | 공통 팝업(openCpPopup/openPdPopup), 모달 드래그/중앙정렬, 페이지네이션, initHScroll/syncHScroll, esc, fmt |
| `dist/common/_template/base.html`        | 전체 베이스 스켈레톤 |
| `dist/common/_template/grid1.html`       | UI유형: 그리드 1개 |
| `dist/common/_template/grid2-tb.html`    | UI유형: 그리드 2개 (상·하) |
| `dist/common/_template/grid2-lr.html`    | UI유형: 그리드 2개 (좌·우) |
| `dist/common/_template/grid3-lrt.html`   | UI유형: 그리드 3개 (좌측 + 우측 상·하) |
| `dist/common/_template/grid3-tlb.html`   | UI유형: 그리드 3개 (상단 + 하단 좌·우) |

→ 생성 HTML에는 반드시 다음 2줄이 포함된다.

```html
<link rel="stylesheet" href="../common/wms-ui.css">
<script src="../common/wms-common.js"></script>
```

**wms-ui.css 에 이미 정의된 클래스의 속성을 HTML `<style>` 블록에서 재정의하지 않는다.** 화면 고유 스타일(예: 특정 배지 색, 특수 폼 레이아웃)만 최소로 추가한다.

---

## 실행 절차

### 1단계 — 사전 파일 읽기

1. `dist/$ARGUMENTS/$ARGUMENTS.md` — 화면요건정리 (메인 입력)
2. `dist/common/icon-preview.html` — 사용 가능한 아이콘 목록 (**이 파일에 없는 아이콘은 절대 사용 금지**)
3. `dist/common/_template/base.html` — 베이스 스켈레톤
4. 요건 문서의 **UI유형**에 해당하는 `_template/gridX-*.html` 1개 — 메인 영역 스켈레톤

### 2단계 — 요건 분석

- **메뉴그룹명 / 메뉴그룹코드 / 메뉴명 / 메뉴코드 / UI유형 / 목적** (업무규칙 모달에 기입)
- UI유형 → 사용할 템플릿 1개 결정
- 검색 영역 항목 (행·순번·컴포넌트)
- 그리드별 툴바 버튼, 컬럼 목록 (컬럼명·정렬·너비)
- 팝업 목록 (등록/수정·전용)
- 공통 업무규칙 (모달 `<ol>` 에 그대로 옮김)
- 거래처·품목 팝업 연동 필드 여부

### 3단계 — 테스트 데이터 JS 생성

파일: `dist/$ARGUMENTS/$ARGUMENTS-data.js`

- 첫 줄 주석: `/* $ARGUMENTS 테스트 데이터 */`
- 변수명: 메뉴코드 대문자 + `_DATA` (예: `MDFG01_DATA`)
- 메인 그리드 **10건 이상**, 디테일 **5건 이상**
- `fetch()` / `.json` 사용 금지

```js
/* mdfg01 테스트 데이터 */
const MDFG01_DATA = {
  main: [ { ... }, ... ],   // 10건 이상
  d1:   [ { ... }, ... ],   // 5건 이상 (디테일 있으면)
  d2:   [ { ... }, ... ]
};
```

### 4단계 — HTML 생성

1. `base.html` 을 복사한다.
2. UI유형에 맞는 `gridX-*.html` 내용을 `{{MAIN_AREA}}` 자리에 삽입한다.
3. 아래 플레이스홀더를 치환한다.

| 토큰 | 치환 |
|---|---|
| `{{MENU_CODE}}`    | 메뉴코드 소문자 |
| `{{MENU_CODE_UP}}` | 메뉴코드 대문자 |
| `{{MENU_NAME}}`    | 메뉴명 |
| `{{CUSTOM_CSS}}`   | 화면 고유 CSS (없으면 공백) — **wms-ui.css 중복 금지** |
| `{{SEARCH_ROWS}}`  | 검색 영역 `<tr>...</tr>` |
| `{{GRID_MAIN_TOOLBAR}}` · `{{GRID_MAIN_COLGROUP}}` · `{{GRID_MAIN_THEAD}}` | 메인 그리드 구성 |
| `{{GRID_D1_*}}` · `{{GRID_D2_*}}` | 디테일 그리드 구성 (해당 UI유형만) |
| `{{REG_POPUPS}}`   | 등록/수정·전용 팝업 HTML (각 모달은 `id="xxxModal"` + 헤더 `id="xxxHeader"` 구조 유지) |
| `{{RULE_TABLE}}`   | 업무규칙 모달 화면구성 `<table class="rule-table">` 4행 |
| `{{RULE_LIST}}`    | 업무규칙 `<li>` 항목 (명세 원문 그대로) |
| `{{SCRIPT_BODY}}`  | 화면 고유 JS (doSearch, doReset, renderMainGrid, 페이지 이동, CRUD 등) |

#### 절대 금지

- `window.open()` 사용 → 공통 팝업은 `openCpPopup(targetId)` / `openPdPopup(targetId)` 호출 (이미 `wms-common.js` 에 정의됨)
- 인라인 `style`로 `overflow` / `width` / `height` 지정 (모달 너비 제외)
- 그리드 위·툴바에 제목 텍스트
- 사용여부 컬럼 badge 색상 (텍스트만)
- 명세에 없는 버튼(엑셀 등) 임의 추가
- 임의 placeholder 텍스트
- 빈 stub 함수 (`function doXxx() {}`)
- **wms-ui.css 의 공통 클래스 CSS 재정의** — `.panel`, `.grid-wrap`, `.toolbar`, `.modal`, `.btn` 등

#### 반드시 구현

- 버튼 동작: 추가/수정 → 팝업 오픈, 삭제 → `confirm()` + 재렌더, 저장 → `alert()`, 그리드 행 클릭 → 하위 그리드 연동
- 모달 드래그: 각 모달마다 `initModalDrag('xxxModal', 'xxxHeader')` 호출 (업무규칙은 base.html 이 자동 호출)
- 페이지네이션: `renderPagination('mainPaging', total, size, current, 'goMainPage')` 로 렌더
- 조회 건수: `renderRowCount('mainRowCount', total, size, current)`
- 가로 스크롤: `initHScroll('xxxWrap', 'xxxHScroll', 'xxxHInner', 'xxxTable')` + 렌더 후 `syncHScroll('xxxHInner', 'xxxTable')`
- 데이터 로드: `window.addEventListener('DOMContentLoaded', function() { mainAll = JSON.parse(JSON.stringify(MDFG01_DATA.main)); renderMainGrid(); })`

### 5단계 — 메뉴 등록

1. `dist/index.html` 에서 해당 메뉴그룹 `<ul class="submenu-list collapsed">` 블록을 찾아 항목 추가:
   ```html
   <li class="submenu-item" onclick="loadContent('$ARGUMENTS/$ARGUMENTS.html', '{메뉴명}')">{메뉴명}</li>
   ```
2. `dist/common/left-menu.html` 에도 동일하게 추가 (경로 prefix `../`):
   ```html
   <li class="submenu-item" onclick="loadContent('../$ARGUMENTS/$ARGUMENTS.html', '{메뉴명}')">{메뉴명}</li>
   ```
3. 이미 등록된 메뉴코드면 건너뛴다.

---

### 6단계 — 완료 체크리스트

- [ ] `$ARGUMENTS-data.js` 생성 (메인 10건·디테일 5건 이상)
- [ ] `$ARGUMENTS.html` 에 `<link rel="stylesheet" href="../common/wms-ui.css">` 포함
- [ ] `$ARGUMENTS.html` 에 `<script src="../common/wms-common.js"></script>` 포함
- [ ] 공통 클래스 CSS를 화면 `<style>` 에서 재정의하지 않음
- [ ] `<title>` 및 헤더에 `{메뉴명} [{메뉴코드}]` 정확히 표시
- [ ] 검색 영역 컬럼/컴포넌트가 요건과 일치
- [ ] 그리드 No. → 체크박스 순서, 첫 컬럼 No.
- [ ] `<colgroup>` 각 `<col width>` 가 `area_result_grid.md` 최솟값 이상 (헤더 잘림 없음)
- [ ] CRUD 버튼 모두 실제 동작 (stub 없음)
- [ ] 업무규칙 모달 화면구성 4행 + `<ol>` 원문 일치
- [ ] 등록/수정 팝업 코드 채번 (`{메뉴코드}P01`, `P02` …)
- [ ] 거래처·품목 필드 → `openCpPopup('id')` / `openPdPopup('id')` 사용, `window.open()` 없음
- [ ] 각 모달에 `initModalDrag('xxxModal', 'xxxHeader')` 호출
- [ ] `index.html` / `left-menu.html` 메뉴 중복 없이 등록
