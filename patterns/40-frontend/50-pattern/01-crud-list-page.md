---
title: CRUD 리스트 페이지 패턴
description: 검색→그리드→등록/수정/삭제 팝업 플로우의 전체 구현 패턴. searchRef 검색영역, 조회 함수, 수정 팝업 호출, 삭제, 등록/수정 HTTP 메서드(PUT/PATCH) 규약 포함. FE CRUD 메뉴 개발 시 기준 레시피.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: frontend
tags:
  - crud
  - list-page
  - searchref
  - pattern
  - recipe
depends_on:
  - patterns/40-frontend/20-convention/01-naming.md
  - patterns/40-frontend/30-component/01-search-section.md
  - patterns/40-frontend/30-component/02-zauigrid.md
  - patterns/40-frontend/40-store/01-commCdStore.md
---

# 패턴: CRUD 리스트 페이지

가장 많이 쓰이는 패턴. 검색 → 그리드 → 등록/수정/삭제 팝업 플로우. 기준 예제는 `mdct01.vue` (거래처).

## 1. 전체 플로우

```
[사용자 입력]
    ↓ searchRef 로 반응형 바인딩
[검색 버튼] → axios.post('/mdct01/conts', searchCtObj.value)
    ↓
[응답 후처리]
  - commCdStore.convertCommDNms(commCdList, rows)   공통코드 → 명칭
  - bizCenterStore.convertBizCenterNms(rows)        bizSeq → bizNm
  - Promise.all 로 병렬
    ↓
[grid.setGridData(rows)]
    ↓
[수정 버튼] → getCheckedRowItemsAll() 검증 → editPopup.openPopup(bizSeq, seq)
    ↓
[팝업 저장 성공] → emit('vfn_searchXx') → 부모 재조회
```

## 2. 검색 영역

```js
const initSearchCtObj = {
    bizSeq: searchOption.bizSeq,   // searchOption 캐시가 있으면 이어받음
    contNm: null,
    useYn: 'Y',                     // 일반적으로 '사용'만 기본
};

const searchCtObj = searchRef({ ...initSearchCtObj.deepCopy() });
```

- `searchRef` (`assets/js/common.js`): 뒤로가기/탭전환시 값 유지해주는 커스텀 ref
- `OptionTool.getSearchOption(menuCd)` 로 마지막 사용 bizSeq 복원

## 3. 조회 함수

```js
async function vfn_searchCt() {
    try {
        const res = await axios.post(`/mdct01/conts`, searchCtObj.value);
        const postConts = res.data.postConts;

        const commCdList = [
            { commHCd: 'CONT_DIV_CD', commDCd: 'contDivCd', commDNm: 'contDivNm' },
            { commHCd: 'USE_YN',      commDCd: 'useYn',     commDNm: 'useYnNm'   },
        ];
        await Promise.all([
            commCdStore.convertCommDNms(commCdList, postConts),
            bizCenterStore.convertBizCenterNms(postConts),
        ]);

        ctGrid.value.grid.setGridData(postConts);
    } catch (error) {
        ctGrid.value.grid.clearGridData();
        errorSwal(error);
    }
}
```

**반드시 지킬 것**
- `try/catch` 로 감싸고 catch 에서 `clearGridData()` + `errorSwal(error)`
- 응답 변수는 `post{리소스명복수}` (BE 네이밍과 일치)
- 공통코드 변환은 `commCdList` 배열 선언 후 `convertCommDNms` 1회 호출

## 4. 수정 팝업 호출

```js
function vfn_openUpdatePopup() {
    const checkItems = ctGrid.value.grid.getCheckedRowItemsAll();
    if (checkItems.length === 0) { noSelectSwal(); return; }
    if (checkItems.length > 1)   { oneSelectSwal(); return; }

    const { bizSeq, contSeq } = checkItems[0];
    editPopup.value.openPopup(bizSeq, contSeq);
}
```

- **복합키**를 잊지 말 것. BE는 거의 모두 `bizSeq + {리소스}Seq` 조합.
- 등록 버튼이 있으면 `editPopup.value.openPopup()` (인자 없음) 호출.

## 5. 삭제

```js
async function vfn_deleteCts() {
    const checkedItems = ctGrid.value.grid.getCheckedRowItemsAll();
    if (checkedItems.length === 0) { noSelectSwal(); return; }

    const isConfirmed = await confirmSwal(t('message.삭제'));
    if (!isConfirmed) return;

    try {
        // 패턴 A — body 전달 (axios 규약: { data })
        const keys = checkedItems.map(({ bizSeq, contSeq }) => ({ bizSeq, contSeq }));
        const res = await axios.delete(`/mdct01/conts`, { data: keys });

        // 패턴 B — 쿼리스트링 (단일키 리소스: mdwh01 등)
        // const res = await axios.delete(`/mdwh01/whs?whSeqs=${checkedItems.map(it => it.whSeq)}`);

        successSwal(res.data);
        vfn_searchCt();
    } catch (error) {
        errorSwal(error);
    }
}
```

- DELETE 는 리소스에 따라 body(`{ data: [...] }`) 또는 쿼리스트링을 쓴다. 기존 코드 확인 후 맞추기.
- 성공 시 `successSwal(res.data)` → 서버 메시지 그대로 노출
- 성공 후 재조회

## 5-1. 등록 / 수정 메서드 — FE 표준

- **등록** = `axios.put(url, payload)`
- **수정** = `axios.patch(url, payload)`
- **리스트 조회** = `axios.post(url, searchObj)` (POST 가 리스트 조회에 점유됨)
- **단건 조회** = `axios.get(url).data.{resource}` (예: `res.data.cont`, `res.data.wh`)

일반 REST 관례와 다르므로 신규 메뉴도 이 규약을 **그대로** 따른다 (`mdct01Edt.vue`, `mdwh01Edt.vue` 참조).

## 6. 팝업 → 부모 재조회

팝업 측:
```js
const emit = defineEmits(['vfn_searchCt']);
// 저장 성공 후
emit('vfn_searchCt');
editPopup.value.closePopup();
```

부모 측:
```vue
<Mdct01Edt ref="editPopup" @vfn_searchCt="vfn_searchCt" :selectedBizSeq="searchCtObj.bizSeq" />
```

emit 이름은 부모의 검색함수명과 **동일하게** 맞춘다 → 템플릿에서 그대로 연결.

## 7. 자주 하는 실수

| 실수 | 해결 |
| --- | --- |
| `axios.post` 의 body 를 `{ ...searchCtObj.value }` 스프레드 | 그냥 `searchCtObj.value` 전달 (searchRef 는 일반 ref) |
| 공통코드 변환 누락 → 그리드에 코드값 그대로 | `commCdList` 에 항목 추가 + 그리드 dataField 를 `Nm` 필드로 |
| 삭제 후 재조회 안 함 | 성공 swal 직후 `vfn_searchXx()` 호출 |
| 체크 검증 누락 | `noSelectSwal` / `oneSelectSwal` 사용 |
| `regBizSeq` 를 URL 에 직접 포함 | 금지. `zAxios` 가 자동 prepend |
