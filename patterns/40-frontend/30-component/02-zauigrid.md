---
title: ZAuiGrid 사용 가이드
description: AUI Grid 래퍼 컴포넌트 ZAuiGrid의 기본 선언, 자주 쓰는 메서드, 컬럼 레이아웃, 이벤트, 엑셀 내보내기, 편집 그리드 변경 감지 패턴. FE 그리드 구현 시 필수 참조.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - zauigrid
  - aui-grid
  - grid
  - excel-export
---

# ZAuiGrid 사용 가이드

`AUI Grid` 래퍼. 거의 모든 리스트 화면에서 사용.

## 1. 기본 선언

```js
import ZAuiGrid from "@/components/be/grid/ZAuiGrid.vue";
import { zAuiGridReadonlyPros, gfn_exportTo, gfn_setSelectedRow } from '@/assets/zAuiGrid_common';

const ctGrid = ref();

const ctGridProps = {
    ...zAuiGridReadonlyPros,     // 읽기전용 기본값 (편집 그리드면 zAuiGridEditablePros 사용)
    enableFilter: true,           // 헤더 필터
    showRowCheckColumn: true,     // 체크박스 컬럼
    softRemoveRowMode: false,     // 삭제 시 바로 제거
    showStateColumn: false,       // +, - 상태 컬럼
};

const ctGridColumnLayout = [ /* 아래 3 참조 */ ];

const ctGridProperties = { gridProps: ctGridProps, columnLayout: ctGridColumnLayout, gridKey: '{메뉴코드}CtGrid' };
const ctGridEvent = { /* 이벤트 바인딩 */ };
```

템플릿:
```vue
<ZAuiGrid ref="ctGrid" v-bind="ctGridProperties" v-on="ctGridEvent"></ZAuiGrid>
```

## 2. 자주 쓰는 메서드 (`ctGrid.value.grid.xxx`)

| 메서드 | 용도 |
| --- | --- |
| `setGridData(rows)` | 데이터 세팅 |
| `clearGridData()` | 데이터 비우기 |
| `getCheckedRowItemsAll()` | 체크된 row 전체 |
| `getGridData()` | 현재 그리드 전체 |
| `addRow(row, 'last')` | 행 추가 |
| `removeRow(rowIndex)` | 행 삭제 |
| `getAddedRowItems()` / `getEditedRowItems()` / `getRemovedItems()` | 변경 추적 (편집 그리드) |
| `setSelectionBlock(ri, ci, ri2, ci2)` | 셀 선택 |

## 3. 컬럼 레이아웃

```js
const ctGridColumnLayout = [
    {
        dataField: 'bizNm',            // 응답 객체 필드
        headerText: '사업장',          // 헤더 표시
        width: '6%',                   // % 또는 px
        minWidth: 60,
        style: 'gridTxt-l',            // gridTxt-l/c/r (좌/중앙/우)
        filter: { showIcon: true },    // 헤더 필터 아이콘
    },
    {
        dataField: 'contDivNm',
        headerText: '거래처구분',
        width: '8%',
        style: 'gridTxt-c',
        filter: { showIcon: true },
    },
    {
        dataField: 'useYnNm',
        headerText: '사용여부',
        width: '6%',
        style: 'gridTxt-c',
        labelFunction: (rowIndex, columnIndex, value, headerText, item) => {
            return value === '사용' ? `<span style="color:#00f">${value}</span>` : value;
        },
    },
    // 그룹 헤더
    {
        headerText: '거래처정보',
        children: [
            { dataField: 'contNo', headerText: '번호', width: '8%' },
            { dataField: 'contNm', headerText: '명',   width: '15%' },
        ],
    },
];
```

**style 클래스** (`assets/styles/` 에 정의)
- `gridTxt-l` / `gridTxt-c` / `gridTxt-r` — 정렬
- `gridTxt-red` / `gridTxt-blue` — 색상
- 숫자는 기본 우측 정렬

## 4. 이벤트

```js
const ctGridEvent = {
    cellClick(e) { /* ... */ },
    cellDoubleClick(e) {
        editPopup.value.openPopup(e.item.bizSeq, e.item.contSeq);
    },
    cellEditEnd(e) { /* 편집 그리드 */ },
};
```

## 5. 엑셀 내보내기

```js
import { gfn_exportTo } from '@/assets/zAuiGrid_common';

// 시그니처: gfn_exportTo(type, options, target)
//   type    : 'xlsx' 등 export 유형
//   options : { fileName, ... } AUI export 옵션
//   target  : grid 인스턴스 (ctGrid.value.grid)
function vfn_exportExcel() {
    const excelOptions = { fileName: '거래처_' + new Date().yyyymmdd('-') };
    gfn_exportTo('xlsx', excelOptions, ctGrid.value.grid);
}
```

- 내부에서 AUI `exportAsXlsx` 호출
- 옵션 상세 변경이 필요하면 `src/assets/zAuiGrid_common.js` 의 `gfn_exportTo` 구현을 읽을 것

## 6. 편집 그리드 변경 감지

```js
const added   = grid.getAddedRowItems();
const edited  = grid.getEditedRowItems();
const removed = grid.getRemovedItems();

const payload = { adds: added, edits: edited, dels: removed };
await axios.put(`/mdct01/conts`, payload);
```

## 7. 주의

- `ctGrid.value.grid` 로 접근 (한 단계 더 들어감) — `ctGrid.value` 아님
- 그리드 DOM 이 아직 없을 때 메서드 호출하면 오류 → `onMounted` 내에서 호출 또는 `setTimeout(0)` 필요한 경우 있음
- 컬럼 동적 추가는 `grid.changeColumnLayout(newLayout)` 사용

---

## 셀 체크 (행 선택) 상세

### 체크박스 컬럼 활성화

```js
const gridProps = {
    showRowCheckColumn: true,     // 체크박스 컬럼 표시
    useCheckHandling: true,       // cellClick 시 자동 체크 토글
}
```

### 체크 관련 메서드

```js
const grid = ctGrid.value.grid   // ZAuiGrid 내부 grid 인스턴스

// 체크된 행 조회
grid.getCheckedRowItems()        // 체크된 행 배열 (필터 적용 상태 기준)
grid.getCheckedRowItemsAll()     // 체크된 행 전체 (필터 무시)

// 체크 설정
grid.setCheckedRowsByIds(ids)    // ID 배열로 체크 설정 (기존 체크 초기화)
grid.addCheckedRowsByIds(ids)    // ID 배열 추가 체크
grid.addUncheckedRowsByIds(ids)  // ID 배열 체크 해제
grid.setAllCheckedRows(true)     // 전체 체크
grid.setAllCheckedRows(false)    // 전체 체크 해제

// 상태 확인
grid.isCheckedRowById(id)        // 특정 ID 체크 여부 (Boolean)
grid.isRemovedById(id)           // 소프트 삭제된 행 여부 (Boolean)
```

### 체크 이벤트 처리

```vue
<ZAuiGrid
  ref="ctGrid"
  :gridProps="gridProps"
  :columnLayout="columnLayout"
  @cellClick="vfn_cellClick"
  @rowAllChkClick="vfn_rowAllChkClick"
  @rowCheckClick="vfn_rowCheckClick"
/>
```

```js
// 셀 클릭 (useCheckHandling=true면 체크 자동 처리됨)
function vfn_cellClick(e) {
    if (e.dataField === '__rowCheckColumn') return  // 체크박스 컬럼은 skip
    // 비즈니스 로직
}

// 전체 체크박스 클릭
function vfn_rowAllChkClick(e) {
    // e.checked: true/false
}

// 개별 행 체크박스 클릭
function vfn_rowCheckClick(e) {
    // e.item: 체크된 행 데이터
    // e.checked: 체크 상태
}
```

### Shift / Ctrl 다중 선택

`useCheckHandling: true` 설정 시 자동 지원.

| 키 조합 | 동작 |
|---|---|
| 일반 클릭 | 해당 행만 체크, 나머지 해제 |
| Shift + 클릭 | 이전 클릭 행 ~ 현재 행 범위 체크 |
| Ctrl + 클릭 | 해당 행 체크 토글 (다른 행 유지) |

Merge된 셀(병합 행)이 있을 경우 병합 범위 내 모든 행이 함께 체크/해제된다.

### 체크 해제 자동화

필터링 이벤트 시 필터링된 행의 체크가 자동 해제된다:

```vue
<ZAuiGrid @filtering="vfn_filtering" />
```

```js
function vfn_filtering(e) {
    // 필터된 행 자동 체크 해제됨 (ZAuiGrid 내부 처리)
}
```

### 삭제 버튼 패턴 (체크 → 삭제)

```js
async function vfn_delItem() {
    const checked = ctGrid.value.grid.getCheckedRowItemsAll()
    if (!checked.length) { noSelectSwal(); return }

    const ok = await confirmSwal()
    if (!ok) return

    const seqs = checked.map(r => r.item.ctSeq)
    const res = await axios.delete(`/${bizSeq}/mdct01/conts`, { data: { contSeqList: seqs } })
    if (res.data.succeed) {
        successSwal()
        vfn_searchCt()
    }
}
```
