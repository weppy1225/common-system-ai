---
description: 모든 WMS 와이어프레임 HTML에 예외 없이 적용되는 공통 규칙. 페이지 래퍼, 헤더, 모달, 그리드, 버튼, 공통 팝업(거래처/품목), 테스트 데이터, 테스트 항목을 다룬다.
globs: ["**/*.html"]
alwaysApply: false
---

# 공통 UI 규칙

모든 화면에 예외 없이 적용되는 공통 규칙이다. 페이지별 콘텐츠 작업 전에 반드시 숙지한다.
UI유형은 아래와 같다

- 그리드 1개
- 그리드 2개 상하단
- 그리드 2개 좌우측
- 그리드 3개 좌측 우측상단 우측하단
- 그리드 3개 상단 하단좌측 하단우측

업무규칙 팝업에 화면구성 섹션에 아래 항목을 반드시 기입한다.
-메뉴그룹명,메뉴그룹코드,메뉴명,메뉴코드,UI유형,목적

---

## 1. 공통 컴포넌트 규칙

- 공통 컴포넌트는 어떤 페이지를 만들더라도 구조 / 스타일 / 동작을 변경하지 않는다.
- 공통 영역의 HTML 구조, CSS 클래스명, 이벤트 핸들러를 임의로 수정하지 않는다.
- 페이지별 콘텐츠는 반드시 `<main class="main-content">` 안에서만 작업한다.
- 변경이 필요하면 사용자에게 먼저 확인을 요청한다.
- **HTML 요소에 인라인 `style` 속성으로 `overflow`, `width`, `height` 등 레이아웃 관련 스타일을 직접 지정하지 않는다.** 인라인 스타일은 CSS 클래스보다 우선순위가 높아서, CSS를 수정해도 적용되지 않는 문제가 반복된다. 모든 스타일은 CSS 클래스로 관리한다. 모달 너비 등 개별 설정이 필요한 경우에만 인라인 `style`을 사용하되, `overflow` 관련 속성은 반드시 CSS 클래스에서 제어한다.

---

## 2. 원본 재현 규칙

- 원본에 없는 요소(버튼, 텍스트, 장식 등)를 추가하지 않는다.
- 원본에 있는 요소를 빠뜨리지 않는다. 이미지의 모든 요소가 결과물에 포함되어야 한다.
- 색상은 명세서의 HEX 값을 정확히 사용한다. "비슷한 색"을 사용하지 않는다.
- 간격과 크기는 명세서의 px 값을 사용한다. 임의로 조정하지 않는다.
- 레이아웃 구조를 변경하지 않는다. 원본이 2단이면 2단, 3단이면 3단.
- 자체 디자인 개선을 하지 않는다. 원본이 답이며, 더 좋아 보여도 변경하지 않는다.
- 빈 영역도 그대로 유지한다. 여백이 넓으면 넓은 대로 재현한다.
- 화면에 대한 설명 텍스트를 추가하지 않는다.
- **입력 필드에 placeholder 텍스트를 임의로 추가하지 않는다.** 명세서에 명시된 경우에만 표시한다.

---

## 3. 화면 구성 규칙

### 공통
- CRUD 버튼(추가/수정/삭제/복사)은 아이콘 버튼(`btn-icon`)으로 표시한다. 텍스트 없이 SVG 아이콘만 사용한다. (상세 규칙: area_btn.md 참조)
- 화면이 비어 보이지 않도록 사이즈를 100%로 채운다.
- 페이지 배경색은 흰색(`#ffffff`), 기본 폰트는 `'Malgun Gothic', '맑은 고딕', sans-serif`, 기본 폰트 크기는 `12px`, 기본 텍스트 색상은 `#333`을 사용한다.
- 페이지 높이는 `100vh`로 설정하여 iframe 및 독립 뷰 모두에서 화면에 맞게 적응한다. body에 `overflow: hidden`을 함께 적용하여 페이지 자체 스크롤을 차단한다.
- 프라이머리 컬러는 `#304a6e`을 사용한다. (모달 헤더, 그룹 헤더 텍스트, 강조 버튼 등)
- CSS 리셋: `* { box-sizing: border-box; margin: 0; padding: 0; }`을 전역 적용한다.
- 페이지 최상위 래퍼는 `class="page-wrap"`으로 선언하며, `padding: 6px 8px 4px 8px; display: flex; flex-direction: column; gap: 4px; height: 100vh; overflow: hidden`으로 설정한다.

### 헤더
- 화면 좌측 상단에 **메뉴명 [메뉴코드] ∨ / 검색 / 초기화** 를 항상 고정으로 좌측 정렬한다.
- **헤더에 메뉴그룹 경로(예: "기준정보 ▸")를 표시하지 않는다.** 메뉴명 [메뉴코드]만 표시한다.
- 메뉴명은 `font-size: 15px; font-weight: 700; color: #111827`으로 표시하며, 우측에 작은 ∨ 화살표(`font-size: 11px; color: #6b7280; font-weight: 400`)를 붙인다.
- 화면 우측 상단에 **업무규칙** 버튼을 배치한다(`margin-left: auto`).
- 헤더 하단 구분선(border-bottom)은 사용하지 않는다.
- 헤더 컨테이너(`.page-header`) 패딩: `padding: 4px 2px 6px 2px`, 버튼 간격 `gap: 6px`.
- 메뉴명(`.page-title`) 내부 아이콘 간격 `gap: 4px`, 우측 버튼과의 간격 `margin-right: 4px`.

### 모달 (업무규칙 팝업)
- 업무규칙 버튼 클릭 시 모달 팝업을 표시한다. 구성: 화면구성 테이블 + 업무규칙 번호 목록.
- 모달 크기: `width: 520px`, `max-height: 90vh`, `border-radius: 6px`, 테두리 `border: 1px solid #999`.
- 모달 헤더: 배경색 `#304a6e` (프라이머리 컬러), 텍스트 흰색, `padding: 8px 14px`, `font-size: 13px`, `border-radius: 6px 6px 0 0`.
- 모달 바디: `padding: 16px 18px`, `overflow-y: auto`.
- 모달 푸터(버튼 영역): `padding: 8px 12px`, `border-top: 1px solid #ddd`, 버튼 가운데 정렬, `gap: 8px`.
- 오버레이(`.modal-bg`) `z-index: 1000`, 배경: `rgba(0,0,0,0.45)`, 모달 그림자: `box-shadow: 0 8px 32px rgba(0,0,0,0.25)`.
- 닫기 버튼은 모달 헤더 우측에 ✕(`font-size: 20px`)로 배치한다.

### 그리드
- 그리드 위에 목록 텍스트(제목)를 추가하지 않는다.
- 그리드 결과는 항상 10건 이상의 샘플 데이터를 표시한다. 하위(디테일) 그리드는 5건 이상을 표시한다.
- 그리드는 스크롤이 생기지 않도록 패널 높이를 화면 내에서 적절히 배분한다. `flex` 비율을 조정하여 모든 그리드가 가시 영역 안에 맞게 표시되어야 한다.
- 그리드 하위에 페이징 컨트롤(페이지 번호, 페이지 크기 셀렉터, 건수 표시)을 추가한다. (상세 규칙: area_result_grid.md 참조)
- 그리드는 `.panel` 컨테이너로 감싼다: `background: #fff; border: 1px solid #e5e7eb; border-radius: 6px; display: flex; flex-direction: column; flex: 1; overflow: hidden; min-height: 0`.
- 그리드 스크롤 래퍼(`.grid-wrap`): `overflow-y: auto; overflow-x: hidden; flex: 1`.
- 세로 스크롤바: `width: 8px; height: 0px`(가로 스크롤바 네이티브 숨김), 트랙 `#f1f5f9`, 썸 `#cbd5e1` (`border-radius: 4px`), 호버 시 `#94a3b8`, 코너 `#f1f5f9`.
- **사용여부 컬럼에 색상 badge(초록/빨강 등)를 사용하지 않는다.** 색상이 시선을 사로잡아 다른 데이터의 가독성을 떨어뜨리므로, 사용여부는 "사용" / "미사용" 텍스트만 표시한다.

### 버튼
- 기능 버튼은 그리드 좌측 상단에 좌측 정렬한다.
- 명시적으로 요청하지 않은 버튼(엑셀등록, 엑셀다운로드 등)을 임의로 추가하지 않는다.
- **모든 기능 버튼은 반드시 동작하도록 구현한다.** 빈 stub(`function doXxx() {}`)으로 남겨두지 않는다. 구현 후 동작 여부를 직접 확인한다.
- **아이콘 버튼은 반드시 `dist/common/icon-preview.html`에 정의된 아이콘만 사용한다.** icon-preview.html에 없는 아이콘은 임의로 만들거나 추가하지 않으며, 해당하는 아이콘이 없는 기능 버튼은 텍스트 버튼으로 처리한다.

### 공통 팝업 (검색 팝업)
- **거래처명 / 거래처번호** 입력 필드에는 반드시 `CPCT01_popup.html` 공통 팝업을 연결한다.
- **품목명 / 품목번호** 입력 필드에는 반드시 `CPPD01_popup.html` 공통 팝업을 연결한다.
- 팝업 연결 방식: 입력 필드 우측에 돋보기(🔍) 버튼을 배치하고, 클릭 시 `postMessage`로 부모(left-menu.html)에 레이어 오픈을 요청한다. **`window.open()`은 사용하지 않는다.** 품목과 거래처 팝업 모두 동일한 postMessage 방식을 사용해야 한다.
- 팝업에서 선택 시 부모가 `postMessage`로 결과를 전달하고, 자식 화면에서 해당 필드에 값을 채운다.
- 검색 조건 영역과 입력 폼(모달) 양쪽 모두에 적용한다.

| 필드 유형 | 연결 팝업 파일 | 오픈 요청 메시지 | 결과 수신 메시지 |
|---|---|---|---|
| 거래처명, 거래처번호 | `CPCT01_popup.html` | `{ type: 'OPEN_CP_LAYER' }` | `{ type: 'CP_SELECTED', cpctNo, cpctNm }` |
| 품목명, 품목번호 | `CPPD01_popup.html` | `{ type: 'OPEN_PD_LAYER' }` | `{ type: 'PD_SELECTED', prodNo, prodNm }` |

---

## 4. 테스트 데이터 규칙

- 테스트 데이터는 HTML 소스 안에 하드코딩하지 않는다.
- 테스트 데이터는 별도의 **JS 데이터 파일** (`{메뉴코드}-data.js`)로 분리하고, HTML에서 `<script src>`로 로드한다.
  - `fetch()` + `.json` 방식은 `file://` 프로토콜에서 CORS 오류가 발생하므로 사용하지 않는다.
- 메인(헤더) 그리드 테스트 데이터는 **10건** 이상 작성한다.
- 하위(디테일) 그리드 테스트 데이터는 **5건** 이상 작성한다.
- 데이터 파일명: `{메뉴코드}-data.js`, HTML과 같은 폴더에 위치시킨다. (예: `mdfg01.html` → `mdfg01-data.js`)
- JS 데이터 파일 구조:

```js
/* {메뉴코드} 테스트 데이터 */
const MDFG01_DATA = {
  promo: [ { id: 'PROMO-001', ... }, ... ],
  d1:    [ { promoId: 'PROMO-001', ... }, ... ],
  d2:    [ { promoId: 'PROMO-001', ... }, ... ]
};
```

- HTML에서 로드 및 초기화 패턴:

```html
<!-- </body> 직전에 데이터 파일 먼저 로드 -->
<script src="./mdfg01-data.js"></script>
<script>
  window.addEventListener('DOMContentLoaded', () => {
    // 원본 보존을 위해 깊은 복사
    promoAll  = JSON.parse(JSON.stringify(MDFG01_DATA.promo));
    d1All     = JSON.parse(JSON.stringify(MDFG01_DATA.d1));
    d2All     = JSON.parse(JSON.stringify(MDFG01_DATA.d2));
    renderPromoGrid();
    renderD1Grid();
    renderD2Grid();
  });
</script>
```

---

## 5. 테스트 규칙

HTML 파일 생성 후 아래 항목을 반드시 직접 확인하고 모두 통과해야 완료로 간주한다.

---

### 5-1. 공통 팝업 동작 테스트

#### 거래처 팝업 (`CPCT01_popup.html`)

| 순번 | 테스트 항목 | 확인 방법 | 기대 결과 |
|---|---|---|---|
| 1 | 거래처 입력 필드 우측에 🔍 버튼이 존재하는가 | 화면에서 육안 확인 | 🔍 버튼 표시됨 |
| 2 | 🔍 버튼 클릭 시 팝업이 열리는가 | 버튼 클릭 | `CPCT01_popup.html` 팝업 창 오픈 |
| 3 | 팝업에서 거래처 선택 시 부모 창 필드가 채워지는가 | 팝업에서 행 선택 후 확인 버튼 | 거래처번호 + 거래처명 자동 입력 |
| 4 | 검색 조건 영역의 거래처 필드에도 동일하게 적용되는가 | 검색 영역 🔍 버튼 클릭 | 동일 팝업 연동 |
| 5 | 입력 폼(모달) 내 거래처 필드에도 동일하게 적용되는가 | 모달 열고 🔍 버튼 클릭 | 동일 팝업 연동 |

#### 품목 팝업 (`CPPD01_popup.html`)

| 순번 | 테스트 항목 | 확인 방법 | 기대 결과 |
|---|---|---|---|
| 1 | 품목 입력 필드 우측에 🔍 버튼이 존재하는가 | 화면에서 육안 확인 | 🔍 버튼 표시됨 |
| 2 | 🔍 버튼 클릭 시 팝업이 열리는가 | 버튼 클릭 | `CPPD01_popup.html` 팝업 창 오픈 |
| 3 | 팝업에서 품목 선택 시 부모 창 필드가 채워지는가 | 팝업에서 행 선택 후 확인 버튼 | 품목번호 + 품목명 자동 입력 |
| 4 | 검색 조건 영역의 품목 필드에도 동일하게 적용되는가 | 검색 영역 🔍 버튼 클릭 | 동일 팝업 연동 |
| 5 | 입력 폼(모달) 내 품목 필드에도 동일하게 적용되는가 | 모달 열고 🔍 버튼 클릭 | 동일 팝업 연동 |

---

### 5-2. 공통 팝업 구현 체크리스트

HTML 작성 시 아래 항목을 코드 레벨에서 확인한다.

- [ ] 거래처/품목 입력 필드에 `readonly` 속성 적용 (직접 타이핑 방지)
- [ ] 🔍 버튼 `onclick`에 `openCpPopup()` 또는 `openPdPopup()` 함수 연결
- [ ] 팝업 오픈 함수가 `<script>` 최상단 독립 블록에 선언되어 전역 접근 가능한지 확인
  - 공통 팝업 함수는 데이터 파일(`*-data.js`) 로드 **이전** `<script>` 블록에 선언한다
  - 메인 스크립트 블록 내부에 선언하면 파싱 오류 시 함수가 등록되지 않을 수 있으므로 **분리 필수**
- [ ] **`window.open()` 사용 금지** — 반드시 `postMessage`로 부모(left-menu.html)에 레이어 오픈 요청
- [ ] `message` 이벤트 리스너로 부모로부터 선택 결과 수신 처리
- [ ] **거래처와 품목 팝업 모두 동일한 postMessage 방식 사용** (하나만 postMessage, 다른 하나는 window.open 같은 혼용 금지)

#### 공통 팝업 함수 선언 위치 패턴 (필수)

```html
<!-- ✅ 올바른 예: 데이터 파일 로드 이전 독립 <script> 블록에 선언 (postMessage 방식) -->
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

<!-- ❌ 잘못된 예: window.open 사용 -->
<script>
  function openCpPopup(targetId) {
    var pop = window.open('./CPCT01_popup.html', ...);  // ← 사용 금지
  }
</script>
```

---

## 상세 패턴 문서

화면설계 패턴 전체 인덱스:
→ `10-src-pattern/10-screen-design/00-overview.md`

WEB 화면 영역별 패턴 인덱스:
→ `10-src-pattern/10-screen-design/10-web/00-overview.md`
