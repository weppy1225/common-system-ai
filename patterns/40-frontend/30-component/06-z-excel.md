---
title: 엑셀 컴포넌트 (ZXls*)
description: ZXlsUp/ZXlsAllUp/ZXlsDown/ZXlsTmpl 엑셀 업로드·다운로드 컴포넌트 사용법. 엑셀 일괄등록·다운로드 구현 시 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: frontend
tags:
  - excel
  - upload
  - download
  - ZXlsUp
  - ZXlsAllUp
---

# 엑셀 컴포넌트 (ZXls*)

```js
import { ZXlsUp, ZXlsDown, ZXlsAllUp, ZXlsTmpl, ZXlsFileSch }
    from '@/components/be/excel/excel.js'
```

---

## 1. ZXlsUp — 엑셀 업로드 (보기 전용 그리드)

파일을 선택하면 내용을 그리드에 미리보기하고, 확인 버튼으로 처리 함수를 호출한다.  
그리드 내 직접 수정은 불가 (`ZXlsAllUp` 사용).

```vue
<ZXlsUp
  :items="excelHeaders"
  :headerLength="1"
  :getExcelData="vfn_getExcelData"
  :handler="vfn_excelHandler"
  :columnLayout="columnLayout"
  :excelTmplUrl="'/templates/prod-template.xlsx'"
  title="품목 일괄등록"
  code="MDPD01_UP"
/>
```

### items — 헤더 컬럼 정의

```js
const excelHeaders = [
  { header: '품목코드', key: 'prodNo',  width: 15 },
  { header: '품목명',   key: 'prodNm',  width: 25 },
  { header: '규격',     key: 'prodSpec', width: 20 },
]
```

### getExcelData — 업로드 처리 함수

```js
// 그리드 확인 버튼 클릭 시 호출됨
// rows: 그리드에 표시된 행 데이터 배열
async function vfn_getExcelData(rows) {
    // rows 배열을 서버에 POST
    const res = await axios.put(`/${bizSeq}/mdpd01/prods/excel`, { prodList: rows })
    if (res.data.succeed) successSwal()
}
```

### handler — 데이터 변환/유효성 검사 함수

```js
// 파일 로드 직후 각 행에 대해 호출됨
// row: 파싱된 행 객체 (items의 key 기준)
// 반환: 변환된 행 객체 (null 반환 시 행 제외)
function vfn_excelHandler(row) {
    if (!row.prodNo) return null  // 유효성 실패 → 행 제외
    return {
        ...row,
        bizSeq: bizSeq.value,
    }
}
```

### 주요 props

| prop | 타입 | 설명 |
|---|---|---|
| `items` | Array | 헤더 컬럼 정의 `[{ header, key, width }]` |
| `headerLength` | Number | 엑셀 헤더 행 수 (기본 1, skip 대상) |
| `footerLength` | Number | 엑셀 하단 제거 행 수 |
| `getExcelData` | Function | 확인 버튼 클릭 시 호출 (`async` 가능) |
| `handler` | Function | 행 변환/유효성 검사 (`async` 불가) |
| `columnLayout` | Array | 그리드 컬럼 정의 (ZAuiGrid columnLayout과 동일) |
| `excelTmplUrl` | String | 템플릿 다운로드 URL |
| `title` | String | 팝업 제목 (기본: '일괄업로드') |
| `code` | String | 팝업 코드 (고유값) |
| `multiple` | Boolean | 다중 파일 선택 |

---

## 2. ZXlsAllUp — 엑셀 업로드 (수정 가능 그리드)

`ZXlsUp`과 동일하지만 그리드 내 직접 편집이 가능하고,  
셀 수정 시 해당 행이 자동으로 체크된다.

```vue
<ZXlsAllUp
  :items="excelHeaders"
  :headerLength="1"
  :getExcelData="vfn_getExcelData"
  :handler="vfn_excelHandler"
  :columnLayout="columnLayout"
  :gridProps="{ editable: true }"
  :canOpenPopup="vfn_canOpenPopup"
  confirmText="등록"
  label="엑셀등록"
/>
```

### ZXlsUp과의 차이점

| 항목 | ZXlsUp | ZXlsAllUp |
|---|---|---|
| 그리드 수정 | ❌ | ✅ |
| 셀 수정 시 자동 체크 | — | ✅ |
| 체크된 행만 등록 | — | ✅ |
| 유효성 검사 시점 | 파일 로드 시 1회 | 파일 로드 + 등록 버튼 클릭 2회 |

### canOpenPopup — 팝업 오픈 조건

```js
// 팝업 열기 전 조건 확인 함수 (동기)
// false 반환 시 팝업 열리지 않음
function vfn_canOpenPopup() {
    if (!bizSeq.value) {
        warnSwal('사업장을 먼저 선택하세요')
        return false
    }
    return true
}
```

---

## 3. ZXlsDown — 엑셀 다운로드 버튼

```vue
<ZXlsDown @click="vfn_excelDown" />
```

아이콘 버튼만 제공. 다운로드 로직은 부모에서 처리한다.

```js
async function vfn_excelDown() {
    const rows = ctGrid.value.grid.getGridData()
    // xlsx 라이브러리 또는 서버 API로 다운로드
}
```

---

## 4. ZXlsTmpl — 템플릿 다운로드 버튼

```vue
<ZXlsTmpl @click="vfn_downloadTemplate" />
```

---

## 자주 하는 실수

| 실수 | 해결 |
|---|---|
| `handler`를 `async`로 선언 | `handler`는 sync 함수만 가능. `async` 불가 |
| `items`의 `key`가 엑셀 실제 컬럼 순서와 불일치 | `key`는 순서 기반이 아닌 이름 매핑 — 엑셀 헤더 텍스트와 `header`를 일치시킨다 |
| `getExcelData`에서 응답 확인 없이 종료 | 반드시 `res.data.succeed` 또는 `res.data.procCnt` 확인 후 성공/실패 처리 |
| `ZXlsUp`에서 그리드 수정 시도 | 수정 가능한 업로드는 `ZXlsAllUp` 사용 |
