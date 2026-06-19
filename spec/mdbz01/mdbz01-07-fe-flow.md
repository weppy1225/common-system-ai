---
title: MDBZ01 FE 구현 흐름 (화면 처리)
description: mdbz01 사업장의 프론트엔드 업무별 함수 호출 시퀀스 다이어그램, 구현 포인트. Vue 파일 목록은 02-ui.md 참조.
status: active
version: 2.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "spec/mdbz01/mdbz01-02-ui.md"
  - "spec/mdbz01/mdbz01-05-api.md"
tags:
  - detail-design
  - frontend
  - vue
  - master
---

# MDBZ01 FE 구현 흐름 (화면 처리)

> Vue 파일 목록(mdbz01.vue / mdbz01Set.vue / mdbz01Sch.vue) → [02-ui.md §1 화면 목록](./mdbz01-02-ui.md)

---

## 1. 업무별 시퀀스 다이어그램

### 1-1. 화면 초기 진입 — 사업장 목록 조회 및 기본 데이터 세팅

```mermaid
sequenceDiagram
    participant V as mdbz01.vue
    participant A as API

    V->>A: GET /mdbz01/bizs/editable/bizs/{regBizSeq}
    A-->>V: bizList
    V->>V: 셀렉트박스 세팅, bizList[0].bizSeq 선택
    V->>A: GET /mdbz01/bizs/{bizSeq}
    A-->>V: biz 객체
    V->>V: bizObj 폼 세팅
    opt logoFileSeq 있으면
        V->>V: 파일명·이미지 표시 처리
    end
    V->>A: GET /mdbz01/bizs/{bizSeq}/centers
    A-->>V: bizCenter 목록
    V->>V: centerGrid 렌더링
    Note over V: tplCenterYn=Y && cfmYn=Y && useYn=N → disableStyle 적용
```

### 1-2. 사업장 셀렉트박스 변경 — 재조회

```mermaid
sequenceDiagram
    participant V as mdbz01.vue
    participant A as API

    V->>V: watch(bizObj.bizSeq) 감지
    alt bizSeq 비어있으면
        V->>V: return
    end
    V->>A: GET /mdbz01/bizs/{bizSeq}
    A-->>V: biz 객체
    V->>V: bizObj 폼 갱신
    V->>V: logoFileSeq 유무 → 이미지 표시 상태 전환
    V->>A: GET /mdbz01/bizs/{bizSeq}/centers
    A-->>V: bizCenter 목록
    V->>V: centerGrid 렌더링
```

### 1-3. 사업장 정보 저장

```mermaid
sequenceDiagram
    participant V as mdbz01.vue
    participant A as API

    V->>V: [저장 버튼 클릭] → vfn_updateBiz()
    V->>V: lfn_insertValidCheck() [vuelidate — bizNm 필수]
    alt 검증 실패
        V->>V: swal 경고, return
    end
    V->>V: FormData 조립 (bizObj 전 필드 + input-file)
    V->>A: POST /mdbz01/bizs (multipart/form-data)
    A-->>V: procCnt
    alt procCnt > 0
        V->>A: GET /mdbz01/bizs/{bizSeq} [폼 갱신]
        V->>V: successSwal()
        opt bizNm 있으면
            V->>V: loginStore.userInfo.bizNm 갱신 (헤더 즉시 반영)
        end
    end
```

### 1-4. 물류센터 그리드 인라인 편집 저장

```mermaid
sequenceDiagram
    participant V as mdbz01.vue
    participant A as API

    V->>V: [저장 버튼 클릭] → vfn_saveCenter()
    V->>V: getEditedGridData(grid) → insert/update/delete 목록 추출
    alt 변경 건수 0
        V->>V: return
    end
    V->>V: lfn_saveCenterValidCheck(insertList) [센터명 필수]
    V->>V: lfn_saveCenterValidCheck(updateList) [센터명 필수]
    alt 검증 실패
        V->>V: swal 경고, return
    end
    V->>A: PUT /mdbz01/bizs/centers
    A-->>V: succeed
    alt succeed = true
        V->>V: successSwal()
        V->>A: GET /mdbz01/bizs/{bizSeq}/centers [그리드 재조회]
        A-->>V: bizCenter 목록
        V->>V: centerGrid 렌더링
    end
```

### 1-5. 주소 검색 (사업장 폼 / 센터 그리드 셀)

```mermaid
sequenceDiagram
    participant V as mdbz01.vue
    participant K as 카카오 주소 API

    V->>V: [우편번호 🔍 클릭 / 센터 postNo 셀 클릭] → vfn_getAddress(event)
    V->>K: getAddressData() [useAddress 훅 → 카카오 주소 팝업]
    K-->>V: addressData
    alt event.rowIndex 있으면 (센터 그리드)
        V->>V: centerGrid.updateRow({ postNo, addr, addrDtl }, rowIndex)
    else (사업장 폼)
        V->>V: bizObj.postNo / bizObj.addr 직접 세팅
    end
```

### 1-6. 센터정보수정 팝업 열기 및 저장 (mdbz01Set.vue)

```mermaid
sequenceDiagram
    participant P as mdbz01.vue (부모)
    participant S as mdbz01Set.vue (팝업)
    participant A as API

    P->>S: (ref).openPopup()
    S->>A: GET /mdbz01/bizs/tpl
    A-->>S: bizCenter 목록
    S->>S: agencyCenterGrid 렌더링
    S->>S: agencyReqCenterPopup.openPopup()

    S->>S: [저장 버튼 클릭] → vfn_updatetplCenter()
    S->>S: getEditedGridData(grid)
    alt 변경 없으면
        S->>S: swal 경고, return
    end
    S->>S: lfn_validUpdateTpl() [`tplYn='Y'` && `addr`/`addrDtl`/`tel` 비어있으면 false]
    S->>A: PATCH /mdbz01/bizs/tpl
    A-->>S: result
    S->>S: successSwal()
    S->>A: GET /mdbz01/bizs/tpl [팝업 그리드 재조회]
    S->>S: agencyReqCenterPopup.closePopup()
    S->>P: emit('vfn_searchCenter')
    P->>A: GET /mdbz01/bizs/{bizSeq}/centers
    A-->>P: bizCenter 목록
    P->>P: centerGrid 재렌더링
```

### 1-7. 물류대행업체 검색 및 위탁 요청 팝업 (mdbz01Sch.vue)

```mermaid
sequenceDiagram
    participant P as mdbz01.vue (부모)
    participant Sch as mdbz01Sch.vue (팝업)
    participant A as API

    P->>Sch: (ref).openPopup()
    Sch->>Sch: searchTplPopUp.openPopup() [빈 그리드]

    Sch->>Sch: [검색 버튼 클릭 / Enter] → vfn_searchTpl()
    Sch->>A: POST /mdbz01/bizs/tpl
    A-->>Sch: bizCenter 목록
    Sch->>Sch: tplGrid 렌더링

    Sch->>Sch: [초기화] → vfn_resetSeachTpl()
    Sch->>Sch: searchTplObj 초기값으로 리셋

    Sch->>Sch: [위탁 요청 클릭] → vfn_inserttplReq()
    Sch->>Sch: tplGrid.getCheckedRowItemsAll()
    alt 체크 0건
        Sch->>Sch: swal 경고, return
    end
    Sch->>A: PUT /mdbz01/bizs/tpl
    A-->>Sch: procCnt
    alt procCnt > 0
        Sch->>Sch: swal 성공 메시지
        Sch->>Sch: searchTplPopUp.closePopup()
        Sch->>Sch: tplGrid.clearGridData()
        Sch->>P: emit('vfn_searchCenter')
        P->>A: GET /mdbz01/bizs/{bizSeq}/centers
        A-->>P: bizCenter 목록
        P->>P: centerGrid 재렌더링
    end

    Note over Sch: 팝업 닫힐 때(closeCallback) → insertTplReqObj 초기화
```

---

## 2. 구현 포인트

1. **사업장 셀렉트박스 watch 연동**: `bizObj.bizSeq`를 `watch`로 감시하여 선택 변경 시 `vfn_setBizDetail` → `vfn_searchCenter` 연쇄 호출. `onMounted`도 동일 경로로 초기 데이터 세팅.

2. **사업장 저장 — multipart/form-data**: 이미지 파일 업로드를 포함하므로 `bizObj` 전 필드를 `FormData`로 조립 후 `Content-Type: multipart/form-data`로 POST. 저장 성공 시 `loginStore.userInfo.bizNm` 즉시 갱신.

3. **사업장 이미지 3가지 상태 분기**: `fileShow`(기존 서버 이미지), `isNewFile`(로컬 파일 선택 미리보기), 둘 다 false(no-image 아이콘). `lfn_readInputFile`로 FileReader base64 미리보기 제공.

4. **센터 그리드 인라인 편집 제약**: `cellEditBeginHandler`에서 기존 행 + 위탁센터(`tplCenterYn=Y`)이면 수정 차단(`return false`). 신규 추가 행에만 `inputPossibleStyle` 적용.

5. **센터 그리드 우편번호 셀 클릭 → 카카오 주소 팝업**: `postNo` 컬럼에 `IconRenderer` 사용. `onClick`에서 `vfn_getAddress(event)` 호출 → `event.rowIndex` 기준으로 해당 행 업데이트.

6. **팝업 `defineExpose` 패턴**: `mdbz01Set`, `mdbz01Sch` 모두 `openPopup`만 외부 노출. 부모는 ref로 `openPopup()` 호출.

7. **팝업 → 부모 콜백**: 두 팝업 모두 저장/요청 성공 후 `emit('vfn_searchCenter')`로 부모 센터 그리드 재조회 트리거.

8. **mdbz01Sch `closeCallback`**: `LayerPopup`의 `:closeCallback`에 `lfn_insertpopupCloseCallback` 연결 → 팝업 닫힐 때 `insertTplReqObj` 초기화.

9. **위탁센터 `disableStyle`**: 실제 Vue 구현 기준으로 `tplCenterYn='Y' && cfmYn='Y' && useYn='N'` 행의 `disableStyle` 값에 `gridTxt-disabledStyle`을 지정한다.

10. **`getEditedGridData` 공통 유틸**: `insertList / updateList / deleteList` 분리 추출. 변경 건수 합산 0이면 API 미호출.
