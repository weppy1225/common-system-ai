---
name: SD_312
description: 【모바일 PDA 화면 프로토타입 HTML 생성】 dist/{메뉴코드}/ui.md를 읽고 PDA 모바일 wireframe HTML + data.js를 생성하고 menu.html에 자동 등록한다. /SD_312 {메뉴코드} 형식으로 실행한다. WMS PDA 모바일 화면 프로토타입 생성, PDA 와이어프레임, 모바일 화면 생성, 모바일 화면 만들어줘, SD_312 실행해줘 요청 시 반드시 이 스킬을 사용한다.
allowed-tools: Bash, Read, Write, Edit
---

# 모바일 PDA 화면 프로토타입 생성 [SD_312]

메뉴코드: **$ARGUMENTS**

`dist/$ARGUMENTS/ui.md` 를 읽고, **mobile.css + PDA 타입별 스켈레톤 템플릿**을 조합해 모바일 PDA 프로토타입 HTML과 테스트 데이터 JS 파일을 생성한다.

---

## 생성 전략 (중요)

| 파일 | 용도 |
|---|---|
| `dist-mobile/mobile.css` | 모든 PDA 화면이 공유하는 레이아웃·컴포넌트 CSS |
| `dist-mobile/common/_template/typeA.html` | PDA Type A: 목록형 스켈레톤 |
| `dist-mobile/common/_template/typeB.html` | PDA Type B: 처리형 스켈레톤 |
| `dist-mobile/common/_template/typeC.html` | PDA Type C: 탭형 스켈레톤 |
| `dist-mobile/common/_template/typeF.html` | PDA Type F: 설정형 스켈레톤 |

생성 HTML에는 반드시 다음이 포함된다.

```html
<link rel="stylesheet" href="../mobile.css">
<script src="./{메뉴코드대문자}-data.js"></script>
```

**mobile.css에 이미 정의된 클래스 속성을 HTML `<style>` 블록에서 재정의하지 않는다.** 화면 고유 스타일(특수 카드 레이아웃, 특정 색상)만 최소로 추가한다.

---

## 실행 절차

### 1단계 — 사전 파일 읽기

1. `dist/$ARGUMENTS/ui.md` — 화면요건정리 (메인 입력)
2. `dist-mobile/ui-standard.html` — PDA 레이아웃 유형 참조
3. 요건 문서의 목적/UI유형에 맞는 `dist-mobile/common/_template/type{X}.html` 1개

### 2단계 — 요건 분석

ui.md에서 다음 항목을 추출한다.

- **메뉴그룹명 / 메뉴그룹코드 / 메뉴명 / 메뉴코드** (파일 배치에 사용)
- **PDA 레이아웃 유형** → 아래 [PDA 레이아웃 유형 결정 규칙] 참조
- **그룹코드** → 메뉴그룹코드 소문자 + `m` (예: `IV3000` → `iv3000m`)
- 검색 조건 (목록형 필터 시트 구성)
- 표시 필드 (카드 바디 구성)
- 처리 항목 (처리형 품목 카드 구성)
- 화면 내 탭 목록 (탭형)
- 하단 액션 버튼 (처리형 CTA)
- 탭바 활성 탭 → 아래 [탭바 활성 탭 기준표] 참조

### 3단계 — 테스트 데이터 JS 생성

파일: `dist-mobile/{그룹코드}/{메뉴코드대문자}-data.js`

- 첫 줄 주석: `/* {메뉴코드소문자} 테스트 데이터 */`
- 변수명: 메뉴코드 대문자 + `_DATA` (예: `IVMV01_DATA`)
- 목록형(Type A): 카드 데이터 **10건 이상**
- 처리형(Type B): 상위(master) 2건 이상 + 하위(items) 각 3건 이상
- `fetch()` / `.json` 사용 금지

```js
/* ivmv01 테스트 데이터 */
const IVMV01_DATA = {
  list: [
    { no: 'IV26051300001', custNm: '반다이남코 코리아', tags: ['국내입고'], date: '2026-05-13', cnt: 4, sts: '55' },
    ...  // 10건 이상
  ]
};
```

### 4단계 — HTML 생성

1. 요건에 맞는 `type{X}.html` 템플릿을 복사한다.
2. 파일 최상단 주석을 삽입한다.

```html
<!--
  wireframe-only | {메뉴코드대문자} | {메뉴명} | Type {X} ({유형명}) | {그룹코드}
-->
```

3. 아래 플레이스홀더를 치환한다.

| 토큰 | 치환 |
|---|---|
| `{{MENU_CODE}}` | 메뉴코드 대문자 (예: `IVMV01`) |
| `{{MENU_NAME}}` | 메뉴명 (예: `입고예정`) |
| `{{CUSTOM_CSS}}` | 화면 고유 CSS — **mobile.css 중복 금지** |
| `{{SEARCH_PLACEHOLDER}}` | 검색 입력창 placeholder (예: `입고번호 스캔 및 입력`) |
| `{{FILTER_TITLE}}` | 필터 시트 제목 (예: `입고 검색`) |
| `{{FILTER_SECTIONS}}` | 필터 시트 섹션 HTML |
| `{{PROC_HDR_ROWS}}` | 처리형 헤더 정보 `<div class="proc-row">` |
| `{{CTA_BUTTONS}}` | 처리형 하단 버튼 (취소/확정 등) |
| `{{SCR_TABS}}` | 탭형 화면 내 탭 `<button class="scr-tab">` |
| `{{TAB_CONTENTS}}` | 탭형 탭별 콘텐츠 영역 |
| `{{FOOTER}}` | 탭형 하단 (탭바 or CTA) |
| `{{SETTING_SECTIONS}}` | 설정형 섹션 HTML |
| `{{TAB_BAR}}` | 5탭 탭바 HTML (활성 탭 반영) |
| `{{DATA_VAR}}` | 데이터 변수명 대문자 (예: `IVMV01_DATA`) |
| `{{SCRIPT_BODY}}` | 화면 고유 JS |

#### 절대 금지

- `window.open()` 사용
- 인라인 `style`로 `overflow` / `height` 지정 (`.pda-wrap` 제외)
- mobile.css 공통 클래스 CSS 재정의 (`.pda-header`, `.card-row`, `.pda-btn` 등)
- 빈 stub 함수 (`function doXxx() {}`)
- 화면에 PC 그리드(table 데이터 그리드) 사용 → 반드시 카드 또는 섹션 리스트로 변환

#### 반드시 구현

- **Type A**: 카드 클릭 → 상세화면 이동 (`location.href`), 검색 입력 필터링, 필터 시트 오픈/닫기, 칩 선택 토글
- **Type B**: 처리 완료 버튼 → `confirm()` + `alert()`, 수량 입력 → 숫자 키패드 오픈, 전체선택 체크박스 동작
- **Type C**: 화면 내 탭 전환 (`switchTab()`), 검색 입력 필터링, 결과 렌더링
- **Type F**: 항목 클릭 → `alert()` or `location.href`
- 데이터 로드: `window.addEventListener('DOMContentLoaded', function() { ... })`

### 5단계 — 메뉴 등록

`dist-mobile/menu.html`의 `<div class="menu-grid">` 안에 항목 추가:

```html
<div class="menu-cell" onclick="location.href='./{그룹코드}/{메뉴코드대문자}.html'">
  <div class="menu-ico"><img src="./assets/{아이콘파일명}" alt="{메뉴명}"></div>
</div>
```

이미 등록된 메뉴코드면 건너뛴다.

---

## PDA 레이아웃 유형 결정 규칙

ui.md의 **화면 목적**과 **UI유형**을 함께 참조하여 결정한다.

| PDA Type | 선택 기준 |
|---|---|
| **A (목록형)** | 데이터를 검색하고 목록으로 조회하는 화면. 상세/처리 화면으로 이동하는 진입점. 예: 예정 목록, 요청 목록, 조회 목록 |
| **B (처리형)** | 선택된 문서/항목을 실제 처리하는 화면. 수량 입력, 확정/처리 CTA 필요. 예: 입고처리, 출고처리, 반품처리 |
| **C (탭형)** | 화면 내 탭으로 뷰를 전환하는 화면. 동일 기능의 다른 관점 제공. 예: 재고이동(품목이동/위치스캔), 재고조회(품목/위치) |
| **F (설정형)** | 설정/프로필 항목 나열 화면. 네비게이션 목록 위주. 예: 설정, 개인정보, 알람 설정 |

**복합 유형**: A+B 흐름(목록→처리)에서 목록 화면은 A, 처리 화면은 B로 각각 별도 생성한다. 같은 메뉴코드로 하나의 HTML에 합치지 않는다.

---

## 탭바 활성 탭 기준표

| 활성 탭 | 적용 화면 도메인 |
|---|---|
| 0번 (메인화면) | 대시보드, 메인 |
| 1번 (입고) | 입고 관련: iv*, iw*, rt* |
| 2번 (피킹) | 출고/피킹: ow*, ld* |
| 3번 (재고이동) | 재고이동/조회: strg*, brsc*, flsc*, ivmvrq*, spmv* |
| 4번 (메뉴) | 기준정보, 설정, 그 외 |

탭 아이콘 파일:
- 0번: `icon-footerLogo.png`
- 1번: `icon-footer02.png`
- 2번: `icon-footer01.png`
- 3번: `icon-footer03.png`
- 4번: `icon-mobileMenu.png`

---

## 메뉴 아이콘 선택 기준

`dist-mobile/assets/` 폴더의 아이콘을 선택한다.

| 아이콘 파일명 | 적합 화면 |
|---|---|
| `icon-iwrq.png` | 입고예정, 입고처리, 반품 |
| `icon-ivad.png` | 입고상세, 보충이동확인 |
| `icon-ivmv.png` | 재고이동, 이동 관련 |
| `icon-ivmv-rq.png` | 재고이동요청 |
| `icon-owrq.png` | 피킹목록, 출고처리 |
| `icon-owld.png` | 검수목록 |
| `icon-obrq.png` | 출고요청, 배송요청 |
| `icon-obdi.png` | 출고지시 |
| `icon-brsc.png` | 재고조회 |
| `icon-mdlc.png` | 고정위치조회, 위치조회 |
| `icon-return.png` | 반품 |
| `icon-skmg.png` | SKU/재고 관리 |
| `icon-sksp.png` | SKU 스캔/분류 |
| `icon-smal.png` | 소분/할당 |
| `icon-stsc.png` | 재고실사 |
| `icon-mdlc.png` | 품목 기준정보 |
| `icon-menuSetting.png` | 설정 |

명확히 맞는 아이콘이 없으면 가장 유사한 도메인 아이콘을 사용한다.

---

## 완료 체크리스트

- [ ] `{메뉴코드대문자}-data.js` 생성 (목록 10건 이상 또는 처리형 master 2건·items 3건 이상)
- [ ] `{메뉴코드대문자}.html` 에 `<link rel="stylesheet" href="../mobile.css">` 포함
- [ ] `{메뉴코드대문자}.html` 에 `<script src="./{메뉴코드대문자}-data.js"></script>` 포함
- [ ] mobile.css 공통 클래스 CSS를 화면 `<style>`에서 재정의하지 않음
- [ ] `<title>`에 `{메뉴명} [{메뉴코드대문자}]` 정확히 표시
- [ ] 파일 최상단 주석에 wireframe-only, 메뉴코드, 메뉴명, Type, 그룹코드 기재
- [ ] 선택된 PDA 레이아웃 유형이 화면 목적과 일치
- [ ] 모든 기능 버튼 실제 동작 (stub 없음)
- [ ] 탭바 활성 탭 정확히 지정
- [ ] `dist-mobile/menu.html` 에 메뉴 셀 중복 없이 등록
- [ ] 뷰포트 `<meta name="viewport" content="width=device-width, initial-scale=1.0">` 포함
- [ ] `DOMContentLoaded` 이벤트로 데이터 초기 렌더링
