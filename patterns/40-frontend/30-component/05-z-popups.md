---
title: Z* 검색 팝업 (comPopup) 카탈로그
description: ZContPopup/ZProdPopup/ZLocPopup 등 공통 검색 팝업 컴포넌트 목록, callback 방식 규약, 라벨 인쇄 팝업 패턴. 기준정보 선택 UI 구현 시 새로 만들기 전 반드시 확인.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - popup
  - com-popup
  - search-popup
  - callback
  - label-print
related:
  - patterns/40-frontend/30-component/01-search-section.md
  - patterns/40-frontend/30-component/04-z-buttons.md
  - patterns/40-frontend/50-pattern/01-crud-list-page.md
---

# Z* 검색 팝업 (comPopup)

`components/be/comPopup/comPopup.js` 에서 일괄 import 가능한 **공통 검색 팝업** 카탈로그.
신규 기준정보 선택 UI 가 필요하면 이 문서 먼저 확인 — 새로 만들지 말 것.

```js
import {
    ZContPopup, ZProdPopup, ZLocPopup, ZWhPopup,
    ZBizPopup, ZCenterPopup, ZUserPopup, ZDeptPopup,
    ZRepContPopup, ZLabelPrint, ZLabelPrintList,
    ZIfErrorPopup, ZIfErrorListPopup, ZIfDtlPopup,
} from '@/components/be/comPopup/comPopup.js';
```

## 1. 공통 규약

- 대부분 **입력 인풋 + 검색 아이콘** 형태. 인풋 수정 또는 아이콘 클릭 시 팝업 오픈.
- 선택 방식:
  - **callback 방식 (표준)**: `:callback="lfn_xxxCallback"` prop 으로 함수 전달 → 선택 시 자동 호출
  - **emit 방식 아님** — `@select` 등 이벤트 리스너 쓰지 말 것
- 팝업 내부 그리드 더블클릭 → 팝업 닫힘 → callback 실행
- `v-model` 은 **표시용 텍스트** (예: `contNm`) 에 바인딩. seq 값은 callback 으로 받음.
- 상위 스코프 필터는 `defaultBizSeq`, `defaultCenterSeq`, `defaultWhSeq` 등으로 전달.

## 2. 팝업 카탈로그

| 컴포넌트 | 용도 | 주요 prop | callback 인자 | 선택 방식 |
| --- | --- | --- | --- | --- |
| `ZContPopup` | 거래처 | `defaultBizSeq` | `{ contSeq, contNo, contNm, addr, ... }` | 단건 |
| `ZRepContPopup` | 대표업체 | `defaultBizSeq`, `contSeq` | `{ contSeq, contNo, contNm, ... }` | 단건 |
| `ZProdPopup` | 상품 | `defaultBizSeq` | `{ prodSeq, prodNo, prodNm, unitCd, ... }` | 단건 |
| `ZLocPopup` | 로케이션 | `defaultBizSeq`, `defaultCenterSeq` | `{ locSeq, locNm, locBarcode, rackNo, rowNo, columnNo, whSeq, whNm }` | 단건 |
| `ZWhPopup` | 창고 | `defaultCenterSeq` | `{ whSeq, whNm, whGroupNm, centerSeq }` | 단건 |
| `ZBizPopup` | 사업장 | — | `{ bizSeq, bizNo, bizNm, tel, addr, ... }` | 단건 |
| `ZCenterPopup` | 센터 | `defaultBizSeq` | `[ { centerSeq, centerNm, addr }, ... ]` | **다건 (배열)** |
| `ZUserPopup` | 사용자 | `defaultBizSeq` | `{ userId, userNm, ... }` | 단건 |
| `ZDeptPopup` | 부서 | — | `{ dvsnDtlCode, reqDeptNm }` | 단건 |

### 공통 prop (모든 검색 팝업)

| prop | 타입 | 설명 |
| --- | --- | --- |
| `v-model` | String | 표시 텍스트 (선택된 명칭) |
| `callback` | Function | 선택 확정 시 호출됨 |
| `readonly` | Boolean | 인풋 읽기전용 (아이콘은 활성) |
| `disabled` | Boolean | 완전 비활성 |
| `hideInput` | Boolean | 인풋 숨김 — 버튼만 노출 |
| `disabledTypes` | Array | 비활성 조건 배열 (컴포넌트별) |

## 3. 라벨/인쇄 팝업

| 컴포넌트 | 시그니처 | 용도 |
| --- | --- | --- |
| `ZLabelPrint` | `openPopup(items)` | SKU 라벨 인쇄. 체크한 행 배열 전달 |
| `ZLabelPrintList` | `openPopup(items)` | 리스트형 라벨 인쇄 (여러 양식) |

라벨 인쇄는 **callback 방식이 아니라 `openPopup(배열)` 호출식**. 부모에서 ref 로 직접 open.

```js
const labelPrintPopup = ref();
function vfn_printLabels() {
    const checked = ctGrid.value.grid.getCheckedRowItemsAll();
    if (!checked.length) { noSelectSwal(); return; }
    labelPrintPopup.value.openPopup(checked);
}
```

주요 prop:
- `prodInfo` — 상품 정보 객체 (선택)
- `printType` — `'lpa'` (LPA 프린터) / `'browser'` (브라우저 인쇄)
- `defaultValue` — 초기값

## 4. 인터페이스 에러 팝업

| 컴포넌트 | 용도 |
| --- | --- |
| `ZIfErrorPopup` | 개별 IF 에러 상세 |
| `ZIfErrorListPopup` | IF 에러 리스트 |
| `ZIfDtlPopup` | IF 전송 상세 |

`ifSendYn === 'E'` 행에서 호출. 그리드 스타일 `aui-grid-erp-error` 와 짝.

## 5. 사용 패턴

### 패턴 A — 검색조건 입력창

```vue
<ZCell cols="5" :title="$t('message.거래처')">
    <ZContPopup
        v-model="searchObj.contNm"
        :defaultBizSeq="searchObj.bizSeq"
        :callback="lfn_contCallback"
    />
</ZCell>
```

```js
function lfn_contCallback(item) {
    searchObj.value.contSeq = item.contSeq;
    searchObj.value.contNm  = item.contNm;
}
```

### 패턴 B — 편집 팝업 내부 필드

```vue
<ZProdPopup
    v-model="editObj.prodNm"
    :defaultBizSeq="editObj.bizSeq"
    :callback="lfn_prodCallback"
    :disabled="isUpdate"
/>
```

### 패턴 C — 라벨 인쇄

```vue
<ZBtn skyblue @click="vfn_printLabels">{{ $t('message.라벨출력') }}</ZBtn>
<ZLabelPrint ref="labelPrintPopup" printType="lpa" />
```

## 6. 주의

- **callback 을 async 로 선언하지 말 것** — 팝업은 sync 처리 가정.
- `defaultBizSeq` 를 안 넘기면 전체 사업장 대상 검색됨. 대부분 사업장 필터가 맞는지 확인.
- 값 초기화 시 `v-model` 만 비우면 seq 가 남음 → **명시적으로 seq 도 null 로 리셋**.
- 새 검색 팝업이 필요하다고 느끼면 먼저 이 카탈로그 재확인. 그래도 없으면 기존 `ZContPopup.vue` 구조를 복제.

## 7. 관련

- `patterns/40-frontend/30-component/01-search-section.md` — SearchSection 내부 배치
- `patterns/40-frontend/30-component/04-z-buttons.md` — 편집 팝업 (LayerPopup) 규약
- `patterns/40-frontend/50-pattern/01-crud-list-page.md` — 검색 필드에 팝업 삽입 패턴
