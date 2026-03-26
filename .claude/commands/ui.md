# 화면 생성 명령어

메뉴코드: **$ARGUMENTS**

`dist/$ARGUMENTS/$ARGUMENTS.md` 화면요건정리 문서를 읽고, 아래 절차대로 프로토타입 HTML과 테스트 데이터 JS 파일을 생성한다.

---

## 실행 절차

### 1단계 — 사전 파일 읽기 (반드시 모두 읽을 것)

아래 파일을 순서대로 읽는다. 모든 규칙을 완전히 숙지한 뒤 생성 작업을 시작한다.

1. `dist/$ARGUMENTS/$ARGUMENTS.md` — 화면요건정리 (메인 입력)
2. `dist/common/icon-preview.html` — 사용 가능한 아이콘 목록 (이 파일에 없는 아이콘은 절대 사용 금지)
3. `dist/mdfg01/mdfg01.html` — 기존 HTML 패턴 참조 (CSS 구조, 공통 컴포넌트, JS 패턴)

### 2단계 — 요건 분석

화면요건정리 문서에서 다음 항목을 정확히 파악한다.

- **메뉴그룹명 / 메뉴그룹코드 / 메뉴명 / 메뉴코드 / UI유형 / 목적** (업무규칙 팝업에 기입할 항목)
- **UI유형** (그리드 1개 / 상하 2개 / 좌우 2개 / 3개 좌측+우측상하 / 3개 상단+하단좌우)에 따라 `main-area` 레이아웃 결정
- **검색 영역** 항목 목록 (행·순번·컴포넌트·비고)
- **그리드별** 툴바 버튼, 컬럼 목록 (컬럼명·정렬·비고)
- **팝업** 목록 (등록/수정 팝업, 차량선택 등 전용 팝업)
- **공통 업무규칙** (업무규칙 팝업 `<ol>` 에 그대로 옮길 내용)
- **거래처 / 품목 팝업 연동 여부** (해당 필드가 있으면 반드시 연동)

### 3단계 — 테스트 데이터 JS 생성

파일명: `dist/$ARGUMENTS/$ARGUMENTS-data.js`

- 파일 상단 주석에 메뉴코드 명시: `/* $ARGUMENTS 테스트 데이터 */`
- 변수명: 메뉴코드를 대문자로 변환 + `_DATA` (예: `mdfg01` → `MDFG01_DATA`)
- 메인(헤더) 그리드 데이터: **10건 이상**
- 하위(디테일) 그리드 데이터: **5건 이상**
- 팝업 전용 데이터(조회용 목록 등)도 별도 키로 포함
- `fetch()` / `.json` 방식 사용 금지 (`file://` CORS 오류 방지)

```js
/* $ARGUMENTS 테스트 데이터 */
const XXXX_DATA = {
  main: [ { ... }, ... ],   // 10건 이상
  d1:   [ { ... }, ... ],   // 5건 이상 (디테일 있는 경우)
  d2:   [ { ... }, ... ]    // 5건 이상 (디테일2 있는 경우)
};
```

### 4단계 — HTML 파일 생성

파일명: `dist/$ARGUMENTS/$ARGUMENTS.html`

아래 모든 규칙을 **예외 없이** 적용한다.

#### 공통 UI 규칙 (CLAUDE.md rules/common_ui.md)

- `<title>`: `{메뉴명} [{메뉴코드}]`
- `body`: `font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; font-size: 12px; overflow: hidden;`
- `.page-wrap`: `padding: 6px 8px 4px 8px; display: flex; flex-direction: column; gap: 4px; height: 100vh; overflow: hidden;`
- **헤더**: 좌측에 `{메뉴명} [{메뉴코드}] ∨` + 검색/초기화 버튼, 우측에 업무규칙 버튼
- **페이지 배경색**: `#ffffff`, **프라이머리 컬러**: `#304a6e`
- HTML 요소에 `overflow`, `width`, `height` 레이아웃 속성을 인라인 `style`로 직접 지정하지 않는다. CSS 클래스로 관리한다. (단, 모달 너비 같은 개별 설정은 예외)

#### 검색 영역 규칙 (rules/area_search.md)

- `table-layout: fixed`, 5컬럼 구조 (lbl col 너비 `82px`)
- 레이블: `background: #f3f4f6; text-align: right; font-weight: 600; font-size: 13px; width: 82px`
- 입력 컴포넌트: `height: 26px; font-size: 13px; border: 1px solid #d1d5db; border-radius: 4px`
- 빈 셀: 레이블 위치 `#f3f4f6`, 입력 위치 `#ffffff`
- 검색 조건 Select에 "전체" 옵션을 **임의로 추가하지 않는다** (명세에 명시된 옵션만)

#### 기능 버튼 영역 규칙 (rules/area_btn.md)

- CRUD 버튼(추가/수정/삭제/복사/저장): `btn-icon` 클래스, 아이콘만 표시 (텍스트 없음)
- 사용 아이콘은 반드시 `dist/common/icon-preview.html`에 있는 것만 사용
- 없는 기능의 버튼은 텍스트 버튼(`btn-text`)으로 처리
- 버튼 순서: 추가 → 수정 → 삭제 → 복사 → 저장 (좌측 정렬)
- 툴바: `background: #f9fafb; border-bottom: 1px solid #e5e7eb; min-height: 32px; padding: 4px 6px`

#### 결과 그리드 규칙 (rules/area_result_grid.md)

- **No. 컬럼이 항상 첫 번째**, 체크박스가 있으면 No. 바로 다음
- 헤더 높이 `30px`, 헤더 배경 `#f3f4f6`, 헤더 텍스트 `font-weight: 600; font-size: 12px; color: #374151`
- 데이터 셀: `height: 26px; padding: 1px 4px; font-size: 12px;`
- 체크박스: `width: 12px; height: 12px`
- `input:not([type="checkbox"])` 로 체크박스 스타일 제외
- **컬럼 너비**: 헤더 텍스트가 절대 잘리지 않도록 rules/area_result_grid.md 기준표 참조
- `white-space: nowrap` 필수 적용
- 그리드에 설명 텍스트/제목 추가 금지
- 사용여부 컬럼: 색상 badge 사용 금지, "사용"/"미사용" 텍스트만 표시
- 헤더 `position: sticky; top: 0; z-index: 10`
- 가로 스크롤: `.h-scroll-wrap` + `.h-scroll-inner` + JS 동기화 패턴 사용
- 페이징 footer: 높이 `40px`, 페이지 번호(중앙) + 페이지 크기 셀렉터(50/100/200) + 조회 건수(우측 절대 위치)

#### 다중 입력 그리드 규칙 (rules/area_multi_input_grid.md)

- 인라인 입력 그리드인 경우 적용
- 그리드 제목 텍스트 표시 금지

#### 패널/레이아웃 높이 체인 규칙 (rules/area_result_grid.md 섹션 8)

모든 중간 컨테이너에 반드시 적용:
```css
.panel { display: flex; flex-direction: column; overflow: hidden; min-height: 0; }
.grid-wrap { flex: 1; min-height: 0; overflow-y: auto; overflow-x: hidden; }
.toolbar, .h-scroll-wrap, .grid-footer { flex-shrink: 0; }
```

#### 업무규칙 팝업 (rules/popup_biz.md)

- 헤더 드래그 이동 가능 (`cursor: move; user-select: none`)
- 화면구성 테이블 4행 필수 기입 (메뉴그룹명/코드, 메뉴명/코드, UI유형, 목적)
- 업무규칙 `<ol>` 내용은 요건 문서의 "공통 업무규칙" 섹션에서 **그대로** 옮긴다 (임의 작성 금지)

#### 등록/수정 팝업 (rules/popup_reg.md)

- 팝업 코드 자동 채번: `{메뉴코드}P{순번2자리}` (예: `MDFG01P01`)
- 헤더에 반드시 `팝업명 [팝업코드]` 형식으로 표시
- 헤더 드래그 이동 가능
- `table-layout: fixed`, 한 행에 최대 3컬럼 세트
- 레이블 너비: 가장 긴 레이블 텍스트 기준으로 설정
- 팝업 너비: 단순 폼 `440~500px`, 표준 폼 `680~800px`, 그리드 포함 `950~1050px`

#### 공통 팝업 연동 (rules/common_ui.md)

- 거래처 필드 → `CPCT01_popup.html` 연동 (postMessage 방식)
- 품목 필드 → `CPPD01_popup.html` 연동 (postMessage 방식)
- `window.open()` 절대 사용 금지
- 공통 팝업 함수는 데이터 파일 로드 **이전** 독립 `<script>` 블록에 선언

```html
<script>
var _cpTargetId = null;
function openCpPopup(targetId) {
  _cpTargetId = targetId;
  window.parent.postMessage({ type: 'OPEN_CP_LAYER' }, '*');
}
var _pdTargetId = null;
function openPdPopup(targetId) {
  _pdTargetId = targetId;
  window.parent.postMessage({ type: 'OPEN_PD_LAYER' }, '*');
}
window.addEventListener('message', function(e) {
  if (e.data && e.data.type === 'CP_SELECTED' && _cpTargetId) {
    var el = document.getElementById(_cpTargetId);
    if (el) el.value = e.data.cpctNm || '';
    _cpTargetId = null;
  }
  if (e.data && e.data.type === 'PD_SELECTED' && _pdTargetId) {
    var el = document.getElementById(_pdTargetId);
    if (el) el.value = e.data.prodNm || '';
    _pdTargetId = null;
  }
});
</script>
```

#### 테스트 데이터 로드 패턴

```html
<!-- </body> 직전, 공통 팝업 함수 선언 이후 -->
<script src="./$ARGUMENTS-data.js"></script>
<script>
window.addEventListener('DOMContentLoaded', function() {
  // 원본 보존을 위해 깊은 복사
  mainAll = JSON.parse(JSON.stringify(XXXX_DATA.main));
  renderMainGrid(mainAll);
});
</script>
```

#### 모든 기능 버튼 동작 구현

- 빈 stub `function doXxx() {}` 금지
- 추가/수정 → 팝업 오픈
- 삭제 → confirm 후 데이터 배열에서 제거 후 재렌더링
- 저장 → alert('저장되었습니다.')
- 그리드 행 클릭 → 하위 그리드 데이터 연동 (다중 패널인 경우)

#### 그리드 샘플 데이터

- 메인 그리드: **10건** 이상 렌더링
- 디테일 그리드: **5건** 이상 렌더링 (첫 번째 행 선택 상태로 초기화)

---

### 5단계 — index.html / common/left-menu.html 메뉴 등록

화면요건정리에서 파악한 **메뉴그룹명**과 **메뉴명**을 이용해 두 파일에 메뉴 항목을 추가한다.

1. `dist/index.html`을 읽는다
2. 해당 메뉴그룹에 맞는 `<ul class="submenu-list collapsed">` 블록을 찾는다
3. 이미 같은 메뉴코드가 등록되어 있으면 건너뛴다
4. 없으면 적절한 위치에 추가:
   ```html
   <li class="submenu-item" onclick="loadContent('$ARGUMENTS/$ARGUMENTS.html', '{메뉴명}')">{메뉴명}</li>
   ```
5. `dist/common/left-menu.html`에도 동일하게 추가 (경로 prefix `../` 사용):
   ```html
   <li class="submenu-item" onclick="loadContent('../$ARGUMENTS/$ARGUMENTS.html', '{메뉴명}')">{메뉴명}</li>
   ```

---

### 6단계 — 완료 체크리스트

생성 후 아래 항목을 코드 레벨에서 직접 확인한다.

- [ ] `$ARGUMENTS-data.js` 생성 완료, 데이터 건수 충족
- [ ] `$ARGUMENTS.html` 생성 완료
- [ ] 메뉴명 [메뉴코드] 헤더에 정확히 표시
- [ ] 검색 영역 컬럼 수 및 컴포넌트 타입이 요건과 일치
- [ ] 그리드 No. 컬럼이 첫 번째에 위치
- [ ] 헤더 텍스트가 잘리는 컬럼 없음 (colgroup width 기준표 준수)
- [ ] CRUD 버튼이 모두 동작 (stub 없음)
- [ ] 업무규칙 팝업 — 화면구성 4행 기입, 업무규칙 `<ol>` 내용 요건 문서에서 그대로 복사
- [ ] 등록/수정 팝업 코드 채번 (`{메뉴코드}P01`, `{메뉴코드}P02` …)
- [ ] 거래처/품목 필드 있으면 postMessage 팝업 연동
- [ ] `window.open()` 미사용
- [ ] index.html / left-menu.html 메뉴 등록 완료
- [ ] placeholder 임의 추가 없음
- [ ] 엑셀 버튼 임의 추가 없음 (명세에 없으면)
