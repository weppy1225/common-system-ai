---
title: MDBZ01 FE 구현 흐름 (화면 처리)
description: mdbz01 사업장의 API별 FE 함수 호출 시퀀스 다이어그램과 메뉴 고유 구현 포인트를 기술.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/_common/fe-architecture.md"
  - "70-knowledgebase/mdbz01/mdbz01-02-screen.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
tags: [detail-design, frontend, vue, master]
---

# MDBZ01 FE 구현 흐름 (화면 처리)

## 1. 파일 구성

| Vue 파일명 | 화면 형태 | 역할 |
|---|---|---|
| mdbz01.vue | 메인 화면 (좌우 2분할) | 사업장 기본정보 폼(좌) + 물류센터 그리드(우) 관리 |
| mdbz01Set.vue | 팝업 (MDBZ01P01) | 자사 센터의 물류대행 여부 및 주소 정보 수정 |
| mdbz01Sch.vue | 팝업 (MDBZ01P02) | 물류대행업체 검색 및 위탁 의뢰 신청 |

---

## 2. API별 시퀀스 다이어그램

---

### GET /mdbz01/bizs/editable/bizs/{regBizSeq} — 수정 가능 사업장 목록 조회

```
mdbz01.vue
     │
     │ onMounted()
     │─ lfn_getBizList()
     │  │─ GET /mdbz01/bizs/editable/bizs/{regBizSeq} ──────────────>│ API
     │  │<────────────────────────────────────────────────────────────│ bizList 반환
     │  │─ bizList.value = res.data.bizList (드롭다운 목록 설정)
     │  │─ vfn_setBizDetail(bizList[0].bizSeq) (첫 번째 사업장 자동 선택)
```

---

### GET /mdbz01/bizs/{selectedBizSeq} — 사업장 단건 조회

```
mdbz01.vue
     │
     │ watch(bizObj.value.bizSeq) — 사업장 드롭다운 변경 시
     │  또는 lfn_getBizList 진입 시 자동 호출
     │─ vfn_setBizDetail(bizSeq)
     │  │─ GET /mdbz01/bizs/{bizSeq} ─────────────────────────────>│ API
     │  │<─────────────────────────────────────────────────────────│ biz 반환
     │  │─ bizObj.value = resultBiz (사업장 폼 데이터 세팅)
     │  │─ [로고 파일 있으면] uploadFileName, fileShow 세팅
     │  │─ vfn_searchCenter() (센터 그리드 자동 갱신)
```

---

### GET /mdbz01/bizs/{selectedBizSeq}/centers — 사업장 센터 목록 조회

```
mdbz01.vue
     │
     │ vfn_searchCenter() — vfn_setBizDetail 내부에서 호출
     │  │─ GET /mdbz01/bizs/{bizSeq}/centers ─────────────────────>│ API
     │  │<─────────────────────────────────────────────────────────│ bizCenter 목록 반환
     │  │─ [tplCenterYn=Y, cfmYn=Y, useYn=N 인 경우] 행 스타일 설정 (거절된 위탁 시각적 구분)
     │  │─ centerGrid.grid.setGridData(centerList)
     │  │─ centerGrid.grid.setSelectionByIndex(selectedCenterGridRowIdx)
```

---

### POST /mdbz01/bizs — 사업장 기본정보 수정

```
mdbz01.vue
     │
     │ [저장] 버튼 클릭 → vfn_updateBiz()
     │  │─ lfn_insertValidCheck() — 사업장명 필수 검증
     │  │  [실패] → 경고 팝업 표시 후 종료
     │  │
     │  │─ FormData 생성 (bizObj 필드 + 이미지 파일)
     │  │─ POST /mdbz01/bizs ──────────────────────────────────────>│ API
     │  │  Content-Type: multipart/form-data
     │  │<─────────────────────────────────────────────────────────│ procCnt 반환
     │  │  [성공]
     │  │─ vfn_setBizDetail(bizSeq) (사업장 정보 재조회)
     │  │─ successSwal(res.data)
     │  │─ loginStore.userInfo.bizNm 업데이트 (헤더 사업장명 즉시 반영)
```

---

### PUT /mdbz01/bizs/centers — 물류센터 저장

```
mdbz01.vue
     │
     │ [저장] 버튼 클릭 → vfn_saveCenter()
     │  │─ getEditedGridData(grid) — 그리드 변경 데이터 추출 (insertList, updateList, deleteList)
     │  │  [변경 없으면] → 종료
     │  │
     │  │─ lfn_saveCenterValidCheck(insertList) — 센터명 공백 체크
     │  │─ lfn_saveCenterValidCheck(updateList) — 센터명 공백 체크
     │  │  [실패] → 경고 팝업 표시 후 종료
     │  │
     │  │─ PUT /mdbz01/bizs/centers ──────────────────────────────>│ API
     │  │  요청 body: {insertList, updateList, deleteList}
     │  │<─────────────────────────────────────────────────────────│ succeed 반환
     │  │  [성공]
     │  │─ successSwal(res.data)
     │  │─ vfn_searchCenter() (센터 그리드 재조회)
```

---

### GET /mdbz01/bizs/tpl — 자사 위탁 센터 목록 조회 (MDBZ01P01)

```
mdbz01Set.vue
     │
     │ lfn_openPopup() — 팝업 열기 요청 시
     │  │─ vfn_searchAgencyCenter()
     │  │  │─ GET /mdbz01/bizs/tpl ──────────────────────────────>│ API
     │  │  │<────────────────────────────────────────────────────-│ bizCenter 목록 반환
     │  │  │─ agencyCenterGrid.grid.setGridData(centerList)
     │  │─ agencyReqCenterPopup.openPopup() (팝업 표시)
```

---

### PATCH /mdbz01/bizs/tpl — 위탁 센터 정보 수정 (MDBZ01P01)

```
mdbz01Set.vue
     │
     │ [저장] 버튼 클릭 → vfn_updatetplCenter()
     │  │─ getEditedGridData(grid) — 변경 데이터 추출
     │  │  [변경 없으면] → 경고 팝업 후 종료
     │  │
     │  │─ lfn_validUpdateTpl(saveList) — 물류대행=Y인데 주소·전화번호 없으면 false
     │  │  [실패] → 오류 팝업 후 종료
     │  │
     │  │─ PATCH /mdbz01/bizs/tpl ────────────────────────────────>│ API
     │  │  요청 body: {updateList}
     │  │<─────────────────────────────────────────────────────────│ 처리 결과 반환
     │  │  [성공]
     │  │─ successSwal(res.data)
     │  │─ vfn_searchAgencyCenter() (그리드 재조회)
     │  │─ agencyReqCenterPopup.closePopup() (팝업 닫기)
     │  └─ emit('vfn_searchCenter') → mdbz01.vue의 센터 그리드 재조회
```

---

### POST /mdbz01/bizs/tpl — 물류대행업체 검색 (MDBZ01P02)

```
mdbz01Sch.vue
     │
     │ [검색] 버튼 클릭 → vfn_searchTpl()
     │  │─ POST /mdbz01/bizs/tpl ────────────────────────────────>│ API
     │  │  요청 body: {bizNm, centerNm, addr}
     │  │<────────────────────────────────────────────────────────│ bizCenter 목록 반환 (reqSts 포함)
     │  │─ tplGrid.grid.setGridData(bizList)
     │
     │ [초기화] 버튼 클릭 → vfn_resetSeachTpl()
     │  │─ searchTplObj = {...initSearchTplObj} (검색 조건 초기화)
```

---

### PUT /mdbz01/bizs/tpl — 위탁 의뢰 신청 (MDBZ01P02)

```
mdbz01Sch.vue
     │
     │ [위탁 요청] 버튼 클릭 → vfn_inserttplReq()
     │  │─ tplGrid.grid.getCheckedRowItemsAll() — 체크된 센터 목록 조회
     │  │  [선택 없으면] → 경고 팝업 후 종료
     │  │
     │  │─ PUT /mdbz01/bizs/tpl ─────────────────────────────────>│ API
     │  │  요청 body: {bizSeq, note, checkedList}
     │  │<─────────────────────────────────────────────────────────│ procCnt 반환
     │  │  [성공]
     │  │─ swal(성공 메시지)
     │  │─ searchTplPopUp.closePopup() (팝업 닫기)
     │  │─ emit('vfn_searchCenter') → mdbz01.vue의 센터 그리드 재조회
     │  └─ tplGrid.grid.clearGridData() (그리드 초기화)
```

---

## 3. 메뉴 고유 구현 포인트

### 3-1. 사업장 기본정보 수정 API가 multipart/form-data 전송

사업장 저장 시 로고 이미지 파일을 함께 전송하기 위해 FormData 방식을 사용한다. 일반적인 JSON 전송 패턴과 달리 `Content-Type: multipart/form-data`를 명시해야 한다. bizObj의 모든 필드를 FormData에 추가하되, 값이 비어 있는 필드는 제외하고, 파일 input 요소에서 직접 파일 객체를 append한다.

### 3-2. 로그인 스토어 즉시 업데이트

사업장 기본정보 저장 성공 시 화면 재조회와 별도로 `loginStore.userInfo.bizNm`을 즉시 업데이트한다. 이는 시스템 헤더에 표시되는 사업장명이 저장 즉시 갱신되도록 하기 위한 처리다.

### 3-3. 위탁 센터 행 편집 제한

센터 그리드에서 위탁 센터(tplCenterYn=Y)에 해당하는 행은 편집이 불가능하도록 `cellEditBegin` 이벤트에서 false를 반환한다. 신규 추가된 행(isAddedByRowIndex=true)은 위탁 여부와 무관하게 편집 가능하다.

### 3-4. 팝업과 메인 화면 간 이벤트 연동

MDBZ01P01(mdbz01Set.vue)과 MDBZ01P02(mdbz01Sch.vue)는 저장/요청 성공 후 `emit('vfn_searchCenter')`를 발행하여 메인 화면(mdbz01.vue)의 센터 그리드를 자동으로 갱신한다.

### 3-5. 팝업 파일의 `defineExpose` 패턴

mdbz01Set.vue와 mdbz01Sch.vue는 모두 `defineExpose({ openPopup: lfn_openPopup })`를 사용하여 부모가 ref를 통해 팝업을 열 수 있도록 인터페이스를 노출한다. ⚠️ 그러나 mdbz01.vue에서 이 팝업들을 import하거나 ref로 연결하는 코드가 확인되지 않음 (99-issues 참조).

### 3-6. 거절된 위탁 센터 시각적 구분

센터 그리드 로드 시 tplCenterYn=Y, cfmYn=Y, useYn=N(거절 상태)인 행에 `disableStyle` 클래스를 적용하여 시각적으로 구분한다. 이 스타일은 그리드 컬럼의 `styleFunction`에서 처리된다.
