---
title: MDBZ01 화면 구조 (UI 명세)
description: mdbz01 사업장·물류센터·물류위탁(3PL) 관리의 화면 구조 명세. 메인 화면 영역 구성, 사업장 폼 항목, 센터 그리드 컬럼, 팝업 2종(검색·요청 / 센터정보수정)의 검색조건·그리드 컬럼·버튼을 vue 소스 기준으로 정확히 기술.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-01-basic-design.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
  - "70-knowledgebase/mdbz01/mdbz01-07-fe-flow.md"
tags:
  - detail-design
  - screen
  - ui
  - 3pl
---

# MDBZ01 화면 구조 — 「사업장」

> 화면이 **어떤 영역·항목·컬럼으로 구성**되는지 vue 소스 기준으로 정확히 기술한다.
> 구현 흐름(함수)은 [`mdbz01-07-fe-flow.md`](mdbz01-07-fe-flow.md), API는 [`mdbz01-05-api.md`](mdbz01-05-api.md) 참조.
> 소스: `cloud-wms-fe` → `src/views/be/md8000/mdbz01/` (`mdbz01.vue`, `mdbz01Sch.vue`, `mdbz01Set.vue`)

## 1. 화면 목록

| 화면 | 코드 | 파일 | 형태 |
|---|---|---|---|
| 사업장 (메인) | MDBZ01 | `mdbz01.vue` | 좌측 폼(35%) + 우측 센터 그리드(65%) |
| 물류대행업체검색 (위탁 요청) | MDBZ01P02 | `mdbz01Sch.vue` | LayerPopup (검색 + 그리드 + 요청자정보) |
| 센터정보수정 (위탁센터 등록·수정) | MDBZ01P01 | `mdbz01Set.vue` | LayerPopup (편집 그리드, width 50%) |

> **UI 유형:** 좌측 입력 폼 + 우측 단일 편집 그리드 (좌우 2분할). 메인 화면에는 별도 검색조건 영역이 없고, 상단 사업장 콤보(ZSelect)로 대상을 전환한다.

## 2. 메인 화면 (mdbz01.vue)

### 2-1. 영역 구성

```
content-header
 ├─ (좌 35%) "사업장 [MDBZ01]" 타이틀
 └─ (우 65%) "물류센터" 타이틀 + [저장] · ……… [PC매뉴얼]
content-body
 ├─ header-grid (35%) : <form> 사업장 항목 세로 나열 + 하단 [저장]
 └─ detail-grid (65%) : 센터 편집 그리드 (ZAuiGrid)
```

### 2-2. 사업장 폼 항목 (좌측 35%)

| 순번 | 항목 | 컴포넌트 | 필드 | 비고 |
|---|---|---|---|---|
| 1 | 사업장 | ZSelect (콤보) | `bizSeq` | text=`bizNm`, val=`bizSeq`. 권한 사업장 목록 |
| 2 | 사업장명 | ZText | `bizNm` | **필수(required)** |
| 3 | 대표자 | ZText | `ceoNm` | |
| 4 | 사업자등록번호 | ZText | `bizNo` | |
| 5 | 업태 | ZText | `bizType` | |
| 6 | 업종 | ZText | `bizItem` | |
| 7 | 우편번호 | ZText (readonly) + 🔍 | `postNo` | 클릭 시 다음 주소팝업(`vfn_getAddress`) |
| 8 | 주소 | ZText (readonly) | `addr` | 주소팝업으로 채움 |
| 9 | 주소상세 | ZText | `addrDtl` | |
| 10 | 전화번호 | ZText | `tel` | |
| 11 | 이메일 | ZText | `email` | |
| 12 | 사업장구분 | 텍스트 표시 | `bizDivCd` | 자사물류(`OWN`)/물류대행. **변경 불가**(고객문의 안내 ? 아이콘) |
| 13 | 사용여부 | 텍스트 표시 | `useYn` | 사용/미사용. **변경 불가** |
| 14 | 사업장이미지 | 파일 업로드 | `logoFileSeq` | [추가]/[삭제], 미리보기. **149×40 규격** |
| 15 | 사업장테마색 | color input | `bizColor` | 기본값 `#00afec` |

- 폼 하단 중앙: **[저장]** (`vfn_updateBiz`) — `multipart/form-data`로 이미지 포함 전송.

### 2-3. 센터 그리드 컬럼 (우측 65%) — 편집형

> 옵션: `zAuiGridEditablePros`, `showRowCheckColumn: false`, `softRemoveRowMode: true` (체크박스 없음, 삭제 마킹 방식)

| 순번 | 컬럼 | 필드 | 정렬/렌더 | 편집 | minWidth | 비고 |
|---|---|---|---|---|---|---|
| 1 | 물류센터명 | `centerNm` | 좌측 | ✅ | 150 | 거절 위탁센터=회색(`disableStyle`), 신규행=입력가능 스타일 |
| 2 | 우편번호 | `postNo` | 🔍 IconRenderer | ✕ | 60 | 위탁센터(`tplCenterYn='Y'`)면 아이콘 숨김. 클릭 시 주소팝업 |
| 3 | 주소 | `addr` | 좌측 | ✕ | 150 | 주소팝업으로 채움 |
| 4 | 주소상세 | `addrDtl` | 좌측 | ✅ | 100 | |
| 5 | 전화번호 | `tel` | 기본 | ✅ | 90 | |
| 6 | 비고 | `note` | 좌측 | ✅ | 100 | |
| 7 | 사용여부 | `useYn` | 라벨 | ✕ | 60 | 사용/미사용 라벨 변환 |
| – | (centerSeq) | `centerSeq` | hidden | – | – | PK, 비표시 |

- **편집 차단 규칙(`cellEditBeginHandler`)**: 추가된 행이 아니고 `tplCenterYn='Y'`(위탁센터)면 편집 불가.
- 그리드 저장: 상단 [저장] (`vfn_saveCenter`) → 변경분(insert/update/delete) 일괄 PUT. **센터명 필수** 검증.

## 3. 팝업 MDBZ01P02 — 물류대행업체검색 / 위탁 요청 (mdbz01Sch.vue)

### 3-1. 검색조건 (상단, 3컬럼)

| 항목 | 컴포넌트 | 필드 |
|---|---|---|
| 사업장 | ZText | `bizNm` |
| 물류센터 | ZText | `centerNm` |
| 주소 | ZText | `addr` |

- 버튼(가운데): **[검색]**(`vfn_searchTpl`, POST) · **[초기화]**(`vfn_resetSeachTpl`)

### 3-2. 결과 그리드 (체크박스 선택, 읽기전용)

> 옵션: `zAuiGridReadonlyPros`, `enableFilter: true`, `showRowCheckColumn: true`, `enableCellMerge: true`

| 순번 | 컬럼 | 필드 | 정렬/렌더 | minWidth | 비고 |
|---|---|---|---|---|---|
| 1 | 요청상태 | `reqSts` | 라벨 | 60 | 다국어 라벨 변환 |
| 2 | 사업장명 | `bizNm` | 좌측 | 100 | 셀 병합(cellMerge) |
| 3 | 센터명 | `centerNm` | 좌측 | 100 | |
| 4 | 주소 | `addr` | 좌측/Template | 200 | `addr + addrDtl` 합쳐 표시 |
| 5 | 전화번호 | `tel` | 기본 | 90 | |
| 6 | 이메일 | `email` | 기본 | 90 | |
| – | (bizSeq / centerSeq) | – | hidden | – | 비표시 |

> 비고 컬럼은 소스상 주석 처리(미사용).

### 3-3. 요청자 정보 + 요청내용 (하단, 3컬럼)

| 항목 | 표시 | 필드 |
|---|---|---|
| 사업장 | 로그인 사용자 | `userInfo.bizNm` |
| 담당자 | 로그인 사용자 | `userInfo.userNm` |
| 전화번호 | 로그인 사용자 | `userInfo.tel` |
| 요청내용 | textarea (전체폭) | `insertTplReqObj.note` |

- 버튼(가운데): **[위탁 요청]** (`vfn_inserttplReq`, PUT). 체크된 업체 목록 + 요청내용 전송. 성공 시 부모 `vfn_searchCenter` emit.

## 4. 팝업 MDBZ01P01 — 센터정보수정 / 위탁센터 등록·수정 (mdbz01Set.vue)

> ⚠️ **이 팝업은 "위탁 의뢰 수락/거절"이 아니다.** 대행사가 **자기 센터를 물류대행용으로 등록·수정**(`tpl_yn`+주소/연락처)하는 화면이다. 저장은 `MDM_CENTER.tpl_yn` 등을 갱신하며 `cfm_yn/use_yn` 상태머신은 건드리지 않는다. (근거: [`mdbz01-04-be-mapper-sql.md`](mdbz01-04-be-mapper-sql.md) §5)
> 너비 width=50%. 단일 편집 그리드 + [저장]. 진입 즉시 자기 센터(`biz_seq=reg_biz_seq`) 조회(GET `/tpl`).
> 옵션: `zAuiGridReadonlyPros` 기반, `enableFilter: true`, `showStateColumn: true`, `showRowCheckColumn: false`, `editable: true`

| 순번 | 컬럼 | 필드 | 렌더/정렬 | 편집 | minWidth | 비고 |
|---|---|---|---|---|---|---|
| 1 | 물류대행여부 | `tplYn` | DropDown(사용/미사용) | ✅ | 80 | 이 센터를 물류대행으로 제공할지(사용/미사용) |
| 2 | 사업장명 | `bizNm` | 좌측 | ✕ | 100 | |
| 3 | 센터명 | `centerNm` | 좌측 | ✕ | 80 | |
| 4 | 우편번호 | `postNo` | 기본 | ✕ | 60 | |
| 5 | 주소 | `addr` | 좌측 | ✕ | 150 | 셀 클릭 시 주소팝업 |
| 6 | 주소상세 | `addrDtl` | 좌측 | ✅ | 100 | |
| 7 | 전화번호 | `tel` | 기본 | ✅ | 90 | |
| 8 | 이메일 | `email` | 기본 | ✅ | 90 | |
| 9 | 비고 | `note` | 기본 | ✅ | 100 | |
| – | (bizSeq / centerSeq) | – | hidden | – | – | 비표시 |

- 버튼(가운데): **[저장]** (`vfn_updatetplCenter`, PATCH `/tpl` → `update3plCenter`). 변경분만 전송. `MDM_CENTER`의 `tpl_yn`·주소·연락처 갱신.
- **검증(`lfn_validUpdateTpl`)**: `tplYn='Y'`(대행 등록) 시 **주소·주소상세·전화번호 필수**.

## 5. 화면 간 연동 요약

```
P02(물류대행업체검색) ──위탁 의뢰 신청(PUT /tpl)──┐
P01(센터정보수정)     ──tpl_yn·주소 저장(PATCH /tpl)┤
                                                  └→ emit('vfn_searchCenter') → 메인 센터그리드 재조회
```

> ⚠️ **진입점 미확인:** 현재 `mdbz01.vue`(메인) 소스는 `mdbz01Sch`/`mdbz01Set` 컴포넌트를 import하거나 여는 버튼이 **없다**(`searchTplPopUp` ref만 선언·미사용). 위 연동은 두 팝업이 부모에 결과를 `emit`하는 **설계상 흐름**이며, 메인에서 팝업을 여는 실제 트리거는 추후 확인·연결 필요.
