---
title: MDWH01 FE 구현 흐름 (화면 처리)
description: mdwh01 창고의 API별 FE 함수 호출 시퀀스 다이어그램과 메뉴 고유 구현 포인트를 기술.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdwh01
domain: master
depends_on:
  - "70-knowledgebase/_common/fe-architecture.md"
  - "70-knowledgebase/mdwh01/mdwh01-02-screen.md"
  - "70-knowledgebase/mdwh01/mdwh01-05-api.md"
tags: [detail-design, frontend, vue, master]
---

# MDWH01 FE 구현 흐름 (화면 처리)

## 1. 파일 구성

| Vue 파일명 | 화면 형태 | 역할 |
|---|---|---|
| mdwh01.vue | 메인 화면 | 창고 검색 조건 입력, 목록 그리드, 추가·수정·삭제 버튼 처리 |
| mdwh01Edt.vue | 팝업 | 창고 등록(MDWH01P01) 및 수정(MDWH01P02) 폼. isUpdate 상태로 모드 전환 |
| mdwh01Com.js | 공통 유틸 | 창고그룹별 처리기능 자동 설정(lfn_setGroupWh), 처리기능 수정 가능 여부 제어(lfn_disabledHandler), 처리기능 선택 검증(lfn_checkYn) |

## 2. API별 시퀀스 다이어그램

### POST /mdwh01/whs — 창고 목록 조회

```
메인화면(mdwh01.vue)            API
        │                        │
        │─ vfn_searchWh()        │
        │─ axios.post('/mdwh01/whs', searchWhObj.value)
        │──────────────────────────>│
        │<──────────────────────────│ (postWhs 목록 반환)
        │─ commCdStore.convertCommDNms() [코드 → 명칭 변환: 창고그룹/사용여부/온도구분/가용재고]
        │─ whGrid.setGridData(postWhs)
        │─ [조회 결과 첫 행의 regBizSeq 확인]
        │  ├─ regBizSeq !== 현재 사업장 → 추가/수정/삭제 버튼 숨김 (isRegWh/isUpdateWh/isDeleteWh = false)
        │  └─ regBizSeq === 현재 사업장 → 버튼 표시 (= true)
```

---

### PUT /mdwh01/whs — 창고 등록

```
메인화면(mdwh01.vue)    팝업(mdwh01Edt.vue)          API
        │                      │                       │
        │─ vfn_openInsertPopup()
        │─────────────────────>│
        │              lfn_openPopupHandler(undefined)
        │              isUpdate = false
        │              editWhObj.centerSeq = 검색 조건 선택 센터
        │              lfn_disabledHandler() [초기 처리기능 제어]
        │              lfn_openPopup() → 팝업 표시
        │                      │
        │              [사용자 입력]
        │              vfn_changeGroupCd() [창고그룹 변경 시]
        │              → lfn_setGroupWh() [처리기능 자동 설정]
        │              → lfn_disabledHandler() [수정 가능 항목 재계산]
        │                      │
        │              vfn_editHandler() → lfn_insertWh()
        │              validCheck('insert') [창고그룹·창고명 필수 검증]
        │              lfn_checkYn() [처리기능 최소 1개 검증]
        │              axios.put('/mdwh01/whs', editWhObj.value)
        │──────────────────────────────────────────────>│
        │<──────────────────────────────────────────────│ (procCnt 반환)
        │              successSwal()
        │              lfn_closePopup()
        │                │ emit('vfn_searchWh')
        │<────────────────
        │─ vfn_searchWh() [목록 자동 갱신]
```

---

### GET /mdwh01/whs/{whSeq} — 창고 수정 팝업 열기 (단건 조회)

```
메인화면(mdwh01.vue)    팝업(mdwh01Edt.vue)          API
        │                      │                       │
        │─ vfn_openUpdatePopup()
        │  체크된 행 수 확인
        │  [0건] → noSelectSwal()
        │  [2건+] → oneSelectSwal()
        │  [1건] → editPopup.value.openPopup(checkItems[0].whSeq, checkItems[0].tplCenterYn)
        │─────────────────────>│
        │              lfn_openPopupHandler(whSeq, tplCenterYn)
        │              isUpdate = true
        │              isTqlCentersWh = (tplCenterYn === 'Y')
        │              lfn_searchUpdateData(whSeq)
        │              axios.get('/mdwh01/whs/${whSeq}')
        │──────────────────────────────────────────────>│
        │<──────────────────────────────────────────────│ (wh 단건 반환)
        │              editWhObj = res.data.wh
        │              editWhObj.bizSeq = 현재 사업장
        │              lfn_disabledHandler() [창고그룹에 따라 수정 가능 항목 재계산]
        │              lfn_openPopup() → 팝업 표시
```

- 행 더블클릭으로도 동일하게 동작 (`lfn_whGridDoubleClickHandler`)
- 위탁 사업장 창고인 경우 더블클릭 시 팝업 열기를 무시함

---

### PATCH /mdwh01/whs — 창고 수정

```
메인화면(mdwh01.vue)    팝업(mdwh01Edt.vue)          API
        │                      │                       │
        │              [사용자 수정 입력]               │
        │              vfn_editHandler() → lfn_updateWh()
        │              validCheck('update') [창고그룹·창고명 필수 검증]
        │              lfn_checkYn() [처리기능 최소 1개 검증]
        │              axios.patch('/mdwh01/whs', editWhObj.value)
        │──────────────────────────────────────────────>│
        │<──────────────────────────────────────────────│ (procCnt 반환)
        │              successSwal()
        │              lfn_closePopup()
        │                │ emit('vfn_searchWh')
        │<────────────────
        │─ vfn_searchWh() [목록 자동 갱신]
```

---

### DELETE /mdwh01/whs — 창고 삭제

```
메인화면(mdwh01.vue)                               API
        │                                           │
        │─ vfn_deleteWh()
        │  체크된 행 수 확인
        │  [0건] → noSelectSwal()
        │  [기본창고 포함] → 삭제 불가 경고 후 종료
        │  confirmSwal('삭제') [삭제 확인 다이얼로그]
        │  [취소] → 종료
        │  axios.delete('/mdwh01/whs?whSeqs=${checkItems.map(it => it.whSeq)}')
        │──────────────────────────────────────────>│
        │<──────────────────────────────────────────│ (procCnt 반환)
        │  successSwal()
        │─ vfn_searchWh() [목록 자동 갱신]
```

---

### 🟠 미호출 API 주의

없음. Controller의 5개 엔드포인트 모두 FE에서 호출됨.

단, `mdwh01Edt.vue`의 `lfn_searchMenuGroup(userId)` 함수가 `onMounted`에서 `userId` 인수 없이 호출되어 `/mdus01/users/groups/undefined` 요청이 발생할 수 있다. 자세한 내용은 99-issues 참조.

## 3. 메뉴 고유 구현 포인트

### 3-1. 버튼 표시/숨김 동적 제어

- 조회 결과의 첫 번째 행 기준으로 `regBizSeq`가 현재 사업장과 다른 경우, 추가·수정·삭제 버튼을 모두 숨긴다.
- 이 로직은 그리드 셀 수준이 아닌 버튼 수준에서 `v-show`로 제어된다.
- 위탁 창고 여부(`tplCenterYn`)는 팝업 내 전체 항목 비활성화 제어에도 사용된다.

### 3-2. 창고그룹 변경에 따른 처리기능 자동 설정

- `mdwh01Com.js`의 `lfn_setGroupWh()`가 창고그룹 코드에 따라 처리기능 초기값을 자동 설정한다.
- `lfn_disabledHandler()`가 수정 불가 처리기능 항목을 비활성(disabled) 상태로 제어한다.
- 수정 모드에서도 창고그룹 변경 불가이므로, 초기 로딩 시 현재 창고그룹 기준으로 비활성 항목이 결정된다.

### 3-3. onActivated에서 센터 변경 감지

- `onActivated` 훅에서 라우터 메타의 `searchOption`과 현재 검색 조건의 `centerSeq`를 비교한다.
- 센터가 변경된 경우 검색 조건을 초기화하고 그리드 데이터를 비운다.
- `keep-alive` 환경에서 탭 전환 시 이전 센터 검색 결과가 잔류하는 것을 방지하기 위한 처리다.

### 3-4. FE 단 처리기능 검증

- FE에서 `lfn_checkYn()`으로 처리기능 최소 1개 선택 여부를 BE 호출 전에 먼저 검증한다.
- BE에서도 동일 규칙을 검증하므로 이중 검증 구조다. FE 검증은 불필요한 API 호출 방지 목적이다.
