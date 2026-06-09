---
title: MDBZ01 FE 구현 흐름 (화면 처리)
description: mdbz01 사업장·물류센터·물류위탁(3PL) 관리의 프론트엔드 구현 흐름. 파일 구성, 컴포넌트별 함수 흐름, 구현 상세 포인트, 화면 레이아웃을 기술. 기술스택은 공통 문서 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/_common/tech-stack.md"
  - "70-knowledgebase/mdbz01/mdbz01-02-screen.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
related:
  - "70-knowledgebase/_common/tech-stack.md"
  - "70-knowledgebase/mdbz01/mdbz01-02-screen.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
tags:
  - detail-design
  - frontend
  - vue
  - 3pl
---

# MDBZ01 FE 구현 흐름 — 「사업장」

> 화면에서 각 업무를 **어떤 컴포넌트·함수 흐름으로 처리**하는지 기술한다.
> 기술 스택: [`_common/tech-stack.md`](../_common/tech-stack.md) · 화면 구조: [`mdbz01-02-screen.md`](mdbz01-02-screen.md) · API 명세: [`mdbz01-05-api.md`](mdbz01-05-api.md)
> 경로: `src/views/be/md8000/mdbz01/`

## 1. 파일 구성

| 업무 | 구현 파일 | 화면 형태 |
|---|---|---|
| 사업장 정보 + 물류센터 관리 | `mdbz01.vue` | 메인 화면 (좌 폼 35% / 우 그리드 65%) |
| 위탁센터 정보수정(`tpl_yn` 등록) | `mdbz01Set.vue` | LayerPopup `MDBZ01P01` |
| 위탁 요청(검색·요청) | `mdbz01Sch.vue` | LayerPopup `MDBZ01P02` |

**상태관리:** `loginStore`, `bizCenterStore`

## 2. 주요 함수 (구현 흐름)

### mdbz01.vue
| 함수 | 역할 |
|---|---|
| `onMounted → lfn_getBizList()` | 진입 시 사업장 콤보 조회 후 첫 건 상세 세팅 |
| `watch(bizObj.value.bizSeq)` | 콤보 변경 감지 → `vfn_setBizDetail` 재호출 |
| `vfn_setBizDetail(bizSeq)` | 사업장 폼 세팅, `bizDivCd==TPL` 판별, 이미지 표시, 센터 조회 |
| `vfn_searchCenter()` | 센터 그리드 세팅, 거절 위탁센터 `disableStyle` 적용 |
| `vfn_updateBiz()` | 검증 → FormData 구성 → 저장 → 헤더 사업장명 동기화 |
| `lfn_insertValidCheck()` | vuelidate `bizNm` 필수 검증 |
| `vfn_saveCenter()` | `getEditedGridData`로 변경분 추출 → 검증 → PUT |
| `cellEditBeginHandler()` | 위탁센터(`tplCenterYn='Y'`) 행 편집 차단 |
| `vfn_getAddress()` | 주소 팝업 호출 (폼/그리드 행 공용) |

### mdbz01Sch.vue (위탁 요청)
| 함수 | 역할 |
|---|---|
| `vfn_searchTpl()` | 위탁 가능 업체 검색 (POST) |
| `vfn_inserttplReq()` | 체크 목록 + 요청내용 위탁 요청 (PUT), 부모 `vfn_searchCenter` emit |

### mdbz01Set.vue (위탁센터 정보수정 — `tpl_yn` 등록, **수락/거절 아님**)
| 함수 | 역할 |
|---|---|
| `vfn_searchAgencyCenter()` | 자기 센터(`biz_seq=reg_biz_seq`) 조회 (GET `/tpl`) |
| `vfn_updatetplCenter()` | `tpl_yn`·주소·연락처 저장 (PATCH `/tpl` → `update3plCenter`) |
| `lfn_validUpdateTpl()` | `tplYn='Y'`(대행 등록) 시 주소·주소상세·전화번호 필수 검증 |

## 3. 구현 상세 포인트

1. **이미지 업로드**: `FileReader`로 미리보기, `FormData`에 `file` 첨부, `multipart/form-data` 헤더로 POST. `fileShow`/`isNewFile` 플래그로 기존/신규/없음 이미지 표시 분기.
2. **그리드 편집 제어**: `zAuiGridEditablePros` + `softRemoveRowMode`(삭제 마킹), `getEditedGridData`로 insert/update/delete 일괄 추출.
3. **위탁센터 시각 구분**: `tplCenterYn='Y' && cfmYn='Y' && useYn='N'` → `gridTxt-disabledStyle` (styleFunction).
4. **상수 사용**: 상태 리터럴 대신 `wmsConstant.BIZ_DIV_OWN/TPL` 사용 (하드코딩 금지 규칙 준수).
5. **팝업↔메인 연동**: 팝업 저장 성공 시 `emit('vfn_searchCenter')`로 부모 그리드 재조회.
6. **로그인 동기화**: 사업장명 변경 시 `loginStore.userInfo.bizNm` 즉시 갱신 → 헤더 반영.

## 4. 화면 레이아웃 (요약)

```
content-header : 타이틀 + [센터 저장] + [PC매뉴얼]
content-body
 ├─ header-grid (35%) : <form> 사업장 폼 + [저장]
 └─ detail-grid (65%) : ZAuiGrid (편집형 센터 그리드)
```

> **화면 영역·폼 항목·그리드 컬럼·팝업 상세 구성은 [`mdbz01-02-screen.md`](mdbz01-02-screen.md) 참조.**
