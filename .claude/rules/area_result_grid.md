---
description: 검색 결과 데이터 그리드(Data Grid) 영역 HTML 작성 시 적용. 헤더·셀·컬럼 너비·정렬·페이징·스크롤·다중 패널 높이 제어 규칙을 정의한다.
paths:
  - "**/*.html"
---

# 결과 그리드 영역 규칙

---

## 1. 헤더(Header) 및 컬럼 규칙

- 헤더 1행 배경색은 `#f3f4f6`, 헤더 2행 배경색은 `#eef0f4`를 사용하여 데이터 영역과 명확히 구분한다.
- 헤더 텍스트는 **중앙 정렬**, `font-weight: 600`, `font-size: 12px`, `color: #374151`으로 처리한다.
- 헤더 th 공통: `border: 1px solid #e5e7eb; padding: 3px 4px; white-space: nowrap`.
- 정렬 가능한 컬럼은 헤더 텍스트 옆에 소형 SVG 정렬 아이콘을 표시할 수 있다.
- 관련 컬럼은 `colspan` 그룹 헤더로 묶어 2행 thead 구조로 표현한다. 그룹 헤더는 배경색 `#e0e7f0`, 텍스트 색상 `#304a6e`, `font-weight: 700`을 사용한다.
- 헤더는 `position: sticky; top: 0; z-index: 10`으로 고정하여 스크롤 시에도 항상 표시한다. 2행 thead의 경우 2번째 행은 `top: 25px; z-index: 9`로 설정한다.
- 그리드 상단에 그리드에 대한 설명 텍스트를 추가하지 않는다.
- **그리드 영역(툴바 포함)에 그리드 제목 텍스트(예: "프로모션 목록", "대상품목", "주문건" 등)를 표시하지 않는다.** 툴바에는 기능 버튼만 배치한다.
- 컬럼 너비는 데이터 특성에 따라 최적화한다. (예: No./단위 → 좁게, 품목명/규격 → 넓게)
- 컬럼이 많아 화면을 벗어날 경우 가로 스크롤바를 제공하며, 컬럼을 숨기지 않는다.
- 그리드 테이블은 `width: max-content; min-width: 100%`로 설정하여 컬럼 수에 따라 자연스럽게 가로 확장되도록 한다.
- 반드시 헤더의 첫번째에는 No. 컬럼이 온다.
- 반드시 헤더의 체크박스가 있으면 순서는 No. 다음에 체크박스를 배치한다.
- 데이터를 선택시 연계된 그리드의 결과가 변경되도록 한다.
- 헤더의 높이는 기본 30px로 한다.

### 컬럼 너비 기준표 (컬럼명으로 유추) — **BLOCKING**

> ❌ 헤더 텍스트가 잘리는 너비를 절대 사용하지 않는다.
> ✅ 컬럼 너비는 **헤더 텍스트 길이**를 우선 기준으로 삼고, 데이터 길이를 함께 고려하여 결정한다.
> ✅ `white-space: nowrap`이 th에 적용되어 있으므로, `<col>` 너비가 헤더 텍스트 렌더링 폭보다 좁으면 텍스트가 반드시 잘린다.
> ✅ 아래 **최소 보장 너비 기준표**를 참조하여 `<colgroup>`의 각 `<col style="width:Xpx">`를 설정한다.

#### 컬럼명 → 최소 보장 너비 기준표

한글 1자 ≈ 13px, 영문/숫자 1자 ≈ 7px (font-size: 12px, 패딩 8px 기준)으로 계산한다.
아래 표의 너비는 **헤더 텍스트 기준 최솟값**이며, 데이터가 더 넓으면 그에 맞게 늘린다.

| 컬럼명 예시 | 헤더 글자 수 | 최소 너비 | 비고 |
|---|---|---|---|
| No. | — | 30px | 순번 |
| checkbox | — | 26px | 체크박스 전용 |
| 사인 | 2자 | 40px | 체크핀 여부 표시 |
| 상태 | 2자 | 44px | |
| 단위 | 2자 | 44px | |
| 구분 | 2자 | 44px | |
| 비고 | 2자 | 100px+ | 내용이 가변이므로 flexible |
| 인수증 | 3자 | 52px | 체크핀 여부 표시 |
| 품목수 | 3자 | 52px | 숫자, 우측 정렬 |
| 수량 | 2자 | 52px | |
| 중량 | 2자 | 60px | 데이터 포함 여유 |
| 단가 | 2자 | 60px | |
| 진행상태 | 4자 | 64px | |
| 출하유형 | 4자 | 64px | |
| 사용여부 | 4자 | 64px | |
| 운전자명 | 4자 | 70px | |
| 담당자명 | 4자 | 70px | |
| 전화번호 | 4자 | 100px | 데이터: 010-XXXX-XXXX ≈ 100px |
| 배송번호 | 4자 | 104px | 데이터: CR + 숫자 ≈ 90px |
| 출하번호 | 4자 | 104px | |
| 차량번호 | 4자 | 100px | |
| 배송예정일 | 5자 | 86px | 데이터: YYYY-MM-DD ≈ 82px |
| 출하예정일 | 5자 | 86px | |
| 등록일 | 3자 | 86px | 데이터: YYYY-MM-DD |
| 거래처구분 | 5자 | 72px | 코드성 데이터 |
| 주문번호 | 4자 | 130px | 데이터가 길다 |
| 거래처번호 | 5자 | 120px | |
| 거래처명 | 4자 | 120px+ | flexible |
| 납품처명 | 4자 | 120px+ | flexible, 콤마 구분 시 더 넓게 |
| 납품처 | 3자 | 100px+ | flexible |
| 품목명 | 3자 | 120px+ | flexible |
| 규격 | 2자 | 100px+ | flexible |
| 기사님 비고 | 6자 | 100px+ | flexible |

**배분 원칙**
- ① 고정 너비 컬럼(No., 체크박스, 날짜, 번호 등) 합산 후 패널 예상 너비와 비교한다.
- ② 합산이 패널 너비 이하이면 나머지 공간을 명칭·설명 컬럼에 자동 배분(`<col>` 미지정)한다.
- ③ 명칭 컬럼이 2개 이상이면 상대적으로 중요한 컬럼을 더 넓게 잡는다.
- ④ 합산 최소 너비가 패널 너비를 초과하는 경우에만 가로 스크롤을 허용한다.
- ⑤ **어떤 경우에도 헤더 텍스트가 잘려서는 안 된다.** 패널이 좁으면 가로 스크롤을 추가하는 것이 헤더를 잘리게 두는 것보다 낫다.

```html
<!-- ✅ 올바른 예: 컬럼명 기반으로 최소 너비 보장 -->
<colgroup>
  <col style="width:30px">   <!-- No. -->
  <col style="width:26px">   <!-- checkbox -->
  <col style="width:86px">   <!-- 배송예정일 -->
  <col style="width:104px">  <!-- 배송번호 -->
  <col>                      <!-- 납품처명: 나머지 공간 자동 배분 -->
  <col style="width:80px">   <!-- 비고 -->
  <col style="width:52px">   <!-- 인수증 -->
</colgroup>

<!-- ❌ 잘못된 예: 헤더 텍스트보다 좁은 너비 -->
<colgroup>
  <col style="width:30px">   <!-- No. -->
  <col style="width:26px">   <!-- checkbox -->
  <col style="width:60px">   <!-- 배송예정일 ← 86px 미만이므로 헤더 잘림 -->
</colgroup>
```

---

## 2. 데이터 셀 규칙

- 데이터 셀 높이는 `26px`, 패딩은 `1px 4px`, `font-size: 12px`, 텍스트 색상 `color: #111827`, 테두리 `border: 1px solid #e5e7eb`으로 설정한다.
- 텍스트가 셀 너비를 초과하면 `white-space: nowrap; overflow: hidden; text-overflow: ellipsis`로 처리한다.
- 사용여부 컬럼은 badge로 표시한다: 사용 → 초록색(`background: #d4efdf; color: #1e8449`), 미사용 → 빨간색(`background: #fde8e8; color: #c0392b`).
- badge 공통 스타일: `display: inline-block; padding: 0 6px; border-radius: 10px; font-size: 10px; font-weight: bold; line-height: 16px`.

---

## 3. 데이터 정렬 규칙 (Alignment)

데이터의 성격에 따라 정렬을 구분한다. 정렬 유틸리티 클래스: `.tc`(중앙), `.tr`(우측), `.tl`(좌측).

| 정렬 | 클래스 | 적용 대상 |
|---|---|---|
| 중앙 정렬 | `.tc` | 일련번호(No.), 체크박스, 단위, 분류코드, 사용여부 등 길이가 짧거나 고정된 코드성 데이터 |
| 좌측 정렬 | `.tl` | 품목명, 규격 등 텍스트 길이가 가변적인 설명성 데이터 |
| 우측 정렬 | `.tr` | 수량, 중량, 금액 등 숫자(수치) 데이터 |

---

## 4. 체크박스 및 선택 규칙

- 전체 선택 체크박스는 No. 컬럼 바로 옆(두 번째)에 배치한다. No.이 항상 첫 번째 컬럼이다.
- 행별 체크박스도 동일하게 No. 다음에 배치하여 개별 선택을 지원한다.
- 체크박스 크기는 `width: 12px; height: 12px`으로 설정한다.
- 그리드 td 내 input/select 스타일 선언 시 체크박스를 반드시 제외한다: `input:not([type="checkbox"])`. 제외하지 않으면 인라인 입력 스타일(`height: 22px; width: 100%` 등)이 체크박스까지 덮어써서 크기가 깨진다.

---

## 5. 가로 스크롤 바

- 컬럼이 많아 화면 너비를 초과할 경우 가로 스크롤 바를 그리드 데이터 바로 아래, 페이징 footer 바로 위에 별도 제공한다.
- 그리드 래퍼(`.grid-wrap`)는 `overflow-x: hidden`으로 설정하여 내부 네이티브 가로 스크롤바를 숨기고, 하단 전용 스크롤 바와 연동하여 동기화한다.
- 가로 스크롤 래퍼(`.h-scroll-wrap`) 높이는 `12px`, 상단 구분선 `border-top: 1px solid #e5e7eb`, flex 속성 `overflow-x: auto; overflow-y: hidden; flex-shrink: 0`.
- `.h-scroll-wrap` 내부에 스크롤 폭을 결정하는 `.h-scroll-inner { height: 1px }` 요소를 배치하고, JS로 그리드 테이블 너비와 동기화한다.
- 스크롤바 높이 `height: 8px`, 트랙 배경색 `#f1f5f9`, 썸 배경색 `#cbd5e1` (`border-radius: 4px`), 호버 시 `#94a3b8`.

---

## 6. 하단 페이징 및 상태 바

- 그리드 하단에 **페이징 컨트롤**을 제공한다. 구성: 페이지 번호 버튼(중앙), 페이지 크기 셀렉터(중앙 우측), 조회 건수(절대 우측).
- footer 높이는 `40px`, 배경색 `#fafafa`, 상단 구분선 `border-top: 1px solid #e5e7eb`, 내부 패딩 `5px 10px`. `position: relative`를 설정하여 조회 건수(`.row-count`)의 절대 위치 기준이 된다.
- 페이지 번호 버튼: 크기 `30px × 30px`, `border-radius: 50%`, `font-size: 13px`, 기본 색상 `color: #374151; font-weight: 600`, 현재 페이지 활성 배경 `#4b5563` / 텍스트 `#fff`, 비활성 호버 배경 `#f1f5f9`. 버튼 간격(`.pagination`) `gap: 4px`.
- 페이지 크기 셀렉터는 50 / 100 / 200 옵션을 기본 제공한다. 높이 `28px`, 최소 너비 `64px`, `padding: 0 20px 0 8px; border: 1px solid #d1d5db; border-radius: 4px`. 셀렉터 영역(`.page-size-wrap`) 좌측 여백 `margin-left: 10px`.
- 조회 건수는 `position: absolute; right: 12px`, `font-size: 11px; color: #6b7280`으로 표시한다. (예: 1 ~ 17 of 17 rows)

---

## 7. 행 상태 표시

- 행에 마우스 호버 시 배경색을 연한 파란색(`#eff6ff`)으로 변경한다.
- 선택된 행의 배경색은 파란색(`#dbeafe`)으로 표시한다.

---

## 8. 다중 패널 레이아웃에서 그리드 높이 제어 (필수)

그리드가 화면을 벗어나는 문제를 방지하기 위해 아래 규칙을 **반드시** 준수한다.

### 8-1. 패널 컨테이너 필수 CSS

그리드를 감싸는 모든 패널(`.panel`)은 아래 3가지 속성을 반드시 포함해야 한다.

```css
.panel {
  display: flex;
  flex-direction: column;
  overflow: hidden;   /* ← 필수: 자식 콘텐츠가 패널 높이를 초과해도 클리핑 */
  min-height: 0;      /* ← 필수: flex 자식이 콘텐츠 크기만큼 무한 팽창하는 것을 방지 */
}
```

### 8-2. 중간 flex 컨테이너(패널 묶음 래퍼)에도 동일 규칙 적용

3-패널 레이아웃(좌·우상·우하 또는 상·하좌·하우) 등에서 패널을 묶는 **래퍼 div**도 반드시 동일 속성을 가져야 한다.

```css
/* ❌ 잘못된 예 — overflow: hidden 누락 */
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-height: 0;
  /* overflow: hidden 없음 → 자식 패널이 아래로 넘침 */
}

/* ✅ 올바른 예 */
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-height: 0;
  overflow: hidden;   /* ← 반드시 추가 */
}
```

### 8-3. 높이 체인 규칙

flex 중첩이 깊어질수록 모든 중간 컨테이너에 `overflow: hidden`과 `min-height: 0`이 있어야 한다.

```
page-wrap (height: 100vh, overflow: hidden)
└── main-area (flex: 1, min-height: 0, overflow: hidden)        ← 필수
    ├── left-panel (flex: 0 0 X%, overflow: hidden, min-height: 0)   ← 필수
    └── right-column (flex: 1, overflow: hidden, min-height: 0)      ← 필수
        ├── d1-panel (flex: 1, overflow: hidden, min-height: 0)      ← 필수
        └── d2-panel (flex: 1, overflow: hidden, min-height: 0)      ← 필수
```

### 8-4. 그리드 래퍼(`.grid-wrap`) 규칙

```css
.grid-wrap {
  flex: 1;
  min-height: 0;      /* ← 필수 */
  overflow-y: auto;
  overflow-x: hidden;
}
```

### 8-5. 고정 높이 자식(툴바·footer·h-scroll)에 flex-shrink: 0 명시

```css
.toolbar       { flex-shrink: 0; min-height: 32px; }
.h-scroll-wrap { flex-shrink: 0; height: 12px; }
.grid-footer   { flex-shrink: 0; height: 40px; }
```
---

## 상세 패턴 문서

WEB 화면 영역별 패턴 인덱스 (결과 그리드 영역 포함):
→ `10-src-pattern/10-screen-design/10-web/00-overview.md`
