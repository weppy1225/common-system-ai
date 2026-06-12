---
name: SD_312
description: ui.md → PDA 모바일 프로토타입 HTML 생성 + 메뉴 자동 등록. /SD_312 {메뉴코드}
when_to_use: "PDA 화면 만들어줘", "PDA 프로토타입 생성해줘", "모바일 화면 생성해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
allowed-tools: Bash, Read, Write, Edit
---

# 모바일 PDA 화면 프로토타입 HTML 생성 [SD_312]

메뉴코드: **$ARGUMENTS**

`30-domain/30-wms-business/$ARGUMENTS/$ARGUMENTS-02-ui.md` 를 읽어, **mobile.css + PDA 전용 레이아웃 템플릿 파일**을 의거해 모바일 PDA 프로토타입 HTML과 목업 데이터 JS 파일을 생성한다.

---

## 생성 원칙 (중요)

| 파일 | 역할 |
|---|---|
| `50-prototype/20-mobile/mobile.css` | 모든 PDA 화면에 공통 적용되는 레이아웃·컴포넌트 CSS |
| `50-prototype/20-mobile/common/_template/typeA.html` | PDA Type A: 목록형 템플릿 |
| `50-prototype/20-mobile/common/_template/typeB.html` | PDA Type B: 처리형 템플릿 |
| `50-prototype/20-mobile/common/_template/typeC.html` | PDA Type C: 탭형 템플릿 |
| `50-prototype/20-mobile/common/_template/typeF.html` | PDA Type F: 설정형 템플릿 |

생성하는 HTML에는 반드시 아래가 포함되어야 한다.

```html
<link rel="stylesheet" href="../mobile.css">
<script src="./{메뉴코드대문자}-data.js"></script>
```

**mobile.css에 이미 정의된 공통 스타일은 HTML `<style>` 블록에서 재정의하지 않는다.** 화면 고유 스타일(추가 색상 이동 레이아웃, 특수 상태)만 최소로 추가한다.

---

## 실행 순서

### 1단계 — 전체 파일 읽기

1. `30-domain/30-wms-business/$ARGUMENTS/$ARGUMENTS-02-ui.md` 화면요건정리 (핵심 입력)
2. `50-prototype/20-mobile/ui-standard.html` 에서 PDA 레이아웃 기준 파악
3. 요건 문서의 목적/UI유형에 맞는 `50-prototype/20-mobile/common/_template/type{X}.html` 1개

### 2단계 — 요건 파악

ui.md에서 아래 항목을 추출한다.

- **메뉴그룹명 / 메뉴그룹코드 / 메뉴명 / 메뉴코드** (파일 주석 생성에 사용)
- **PDA 레이아웃 유형** → 아래 [PDA 레이아웃 유형 결정 기준] 참고
- **그룹코드** → 메뉴그룹코드 소문자 + `m` (예: `IV3000` → `iv3000m`)
- 검색 조건 (목록형 필터 영역 구성)
- 표시 필드 (표시용 이동 레이아웃 구성)
- 처리 항목 (처리형 입력 이동 레이아웃 구성)
- 화면 탭 목록 (탭형)
- 하단 탭 버튼 (처리형 CTA)
- 탭바 구성 → 아래 [탭바 구성 및 탭바 항목 기준] 참고

### 3단계 — 목업 데이터 JS 생성

파일: `50-prototype/20-mobile/{그룹코드}/{메뉴코드대문자}-data.js`

- 첫 줄 주석: `/* {메뉴코드 소문자} 목업 데이터 */`
- 변수명: 메뉴코드 대문자 + `_DATA` (예: `IVMV01_DATA`)
- 목록형(Type A): 이동 데이터 **10건 이상**
- 처리형(Type B): 헤더(master) 2건 이상 + 항목(items) 각 3건 이상
- `fetch()` / `.json` 방식 사용 금지

```js
/* ivmv01 목업 데이터 */
const IVMV01_DATA = {
  list: [
    { no: 'IV26051300001', custNm: '진아이드물류', tags: ['긴급출고'], date: '2026-05-13', cnt: 4, sts: '55' },
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

3. 아래 플레이스홀더를 전부 교체한다.

| 플레이스홀더 | 교체 |
|---|---|
| `{{MENU_CODE}}` | 메뉴코드 대문자 (예: `IVMV01`) |
| `{{MENU_NAME}}` | 메뉴명 (예: `재고이동`) |
| `{{CUSTOM_CSS}}` | 화면 고유 CSS — **mobile.css 중복 금지** |
| `{{SEARCH_PLACEHOLDER}}` | 검색 입력란 placeholder (예: `이동번호 또는 입력`) |
| `{{FILTER_TITLE}}` | 필터 시트 제목 (예: `이동 조건`) |
| `{{FILTER_SECTIONS}}` | 필터 시트 섹션 HTML |
| `{{PROC_HDR_ROWS}}` | 처리형 헤더 정보 `<div class="proc-row">` |
| `{{CTA_BUTTONS}}` | 처리형 하단 버튼 (확인/취소 등) |
| `{{SCR_TABS}}` | 탭형 화면 탭 `<button class="scr-tab">` |
| `{{TAB_CONTENTS}}` | 탭형 탭 콘텐츠 패널 구성 |
| `{{FOOTER}}` | 탭형 하단 (탭바 or CTA) |
| `{{SETTING_SECTIONS}}` | 설정형 섹션 HTML |
| `{{TAB_BAR}}` | 5탭 탭바 HTML (활성 탭 표시) |
| `{{DATA_VAR}}` | 데이터 변수명 대문자 (예: `IVMV01_DATA`) |
| `{{SCRIPT_BODY}}` | 화면 고유 JS |

#### 절대 금지

- `window.open()` 사용
- 인라인 `style`로 `overflow` / `height` 직접 지정 (`.pda-wrap` 준수)
- mobile.css 공통 스타일 재정의 (`.pda-header`, `.card-row`, `.pda-btn` 등)
- 빈 stub 함수 (`function doXxx() {}`)
- 화면에 PC 그리드 table 방식 사용 → 반드시 이동 레이아웃(card-row) 또는 섹션 방식으로 변환

#### 반드시 구현

- **Type A**: 목록 항목 클릭 → 상세/처리 화면 이동 (`location.href`), 검색어 입력 필터링, 필터 시트 열기/닫기, 항목 선택 처리
- **Type B**: 처리 완료 버튼 → `confirm()` + `alert()`, 수량 입력 → 숫자 키패드 열기, 전체선택 체크박스 동작
- **Type C**: 화면 탭 전환 (`switchTab()`), 검색어 입력 필터링, 결과 렌더링도
- **Type F**: 항목 항목 탭 → `alert()` or `location.href`
- 데이터 렌더링: `window.addEventListener('DOMContentLoaded', function() { ... })`

### 5단계 — 메뉴 등록

`50-prototype/20-mobile/menu.html`의 `<div class="menu-grid">` 안에 항목 추가:

```html
<div class="menu-cell" onclick="location.href='./{그룹코드}/{메뉴코드대문자}.html'">
  <div class="menu-ico"><img src="./assets/{아이콘파일명}" alt="{메뉴명}"></div>
</div>
```

이미 등록된 메뉴코드면 중복 추가하지 않는다.

---

## PDA 레이아웃 유형 결정 기준

ui.md의 **화면 목적**과 **UI유형**을 함께 참조하여 결정한다.

| PDA Type | 선택 기준 |
|---|---|
| **A (목록형)** | 데이터를 조회하고 목록으로 보여주는 화면. 상세/처리 화면으로 이동하는 진입점. 예: 이동 목록, 출고 목록, 조회 목록 |
| **B (처리형)** | 선택한 문서/항목을 실제로 처리하는 화면. 수량 입력, 확인/처리 CTA 필요. 예: 입고처리, 출고처리, 재고처리 |
| **C (탭형)** | 화면 내용을 탭으로 구분하여 전환하는 화면. 동일 화면에서 여러 관점 제공. 예: 재고이동(이동/조회), 재고조회(이동/조회) |
| **F (설정형)** | 설정/프로필 항목 목록 화면. 항목별 텍스트 없이 항목 목록. 예: 설정, 내정보, 알람 설정 |

**복합 유형**: A+B 조합(목록에서 목록 화면은 A, 처리 화면은 B로 분리하여 별도 생성). 단일 메뉴코드로 HTML을 합치지 않는다.

---

## 탭바 구성 및 탭바 항목 기준

| 탭 번호 (기본값) | 탭 아이콘 예시 | 적용 화면 기준 |
|---|---|---|
| 0탭 (메인화면) | 로고 메인 | 최상위 메인 |
| 1탭 (입고) | 입고 아이콘 | 입고 관련: iv*, iw*, rt* |
| 2탭 (출고) | 출고/피킹 아이콘 | 출고/피킹: ow*, ld* |
| 3탭 (재고이동) | 재고이동/조회 아이콘 | 재고이동/조회: strg*, brsc*, flsc*, ivmvrq*, spmv* |
| 4탭 (메뉴) | 기준정보, 설정, 공통 | 기준정보/메뉴/설정 |

탭바 아이콘 파일:
- 0탭: `icon-footerLogo.png`
- 1탭: `icon-footer02.png`
- 2탭: `icon-footer01.png`
- 3탭: `icon-footer03.png`
- 4탭: `icon-mobileMenu.png`

---

## 메뉴 아이콘 선택 기준

`50-prototype/20-mobile/assets/` 에서 아이콘을 선택한다.

| 아이콘 파일명 | 사용 화면 |
|---|---|
| `icon-iwrq.png` | 입고예정, 입고처리, 반품 |
| `icon-ivad.png` | 재고조정, 재고재배치 확인 |
| `icon-ivmv.png` | 재고이동, 이동 조회 |
| `icon-ivmv-rq.png` | 재고이동요청 |
| `icon-owrq.png` | 출고목록, 출고처리 |
| `icon-owld.png` | 상차처리 |
| `icon-obrq.png` | 출하예정, 출하처리 |
| `icon-obdi.png` | 출하지시 |
| `icon-brsc.png` | 재고조회 |
| `icon-mdlc.png` | 위치정보조회, 위치조회 |
| `icon-return.png` | 반품 |
| `icon-skmg.png` | SKU/재고 관리 |
| `icon-sksp.png` | SKU 분할/합치기 |
| `icon-smal.png` | 알림/알람 |
| `icon-stsc.png` | 재고실사 |
| `icon-menuSetting.png` | 설정 |

위 목록에 없는 아이콘이 필요하면 가장 유사한 것을 사용한다.

---

## 완료 체크리스트

- [ ] `{메뉴코드대문자}-data.js` 생성 (목록 10건 이상 또는 처리형 master 2건+items 3건 이상)
- [ ] `{메뉴코드대문자}.html` 에 `<link rel="stylesheet" href="../mobile.css">` 포함
- [ ] `{메뉴코드대문자}.html` 에 `<script src="./{메뉴코드대문자}-data.js"></script>` 포함
- [ ] mobile.css 공통 스타일을 화면 `<style>`에서 재정의하지 않음
- [ ] `<title>`에 `{메뉴명} [{메뉴코드대문자}]` 정확히 표시
- [ ] 파일 최상단 주석에 wireframe-only, 메뉴코드, 메뉴명, Type, 그룹코드 기재
- [ ] 선택한 PDA 레이아웃 유형이 화면 목적과 일치
- [ ] 모든 기능 버튼 실제 동작 (stub 없음)
- [ ] 탭바 구성 → 활성 탭 정확히 표시
- [ ] `50-prototype/20-mobile/menu.html` 에 메뉴 중복 없이 등록
- [ ] 모바일 `<meta name="viewport" content="width=device-width, initial-scale=1.0">` 포함
- [ ] `DOMContentLoaded` 이벤트로 데이터 초기 렌더링
