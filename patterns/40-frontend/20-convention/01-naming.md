---
title: FE 네이밍 규칙
description: vfn_/gfn_/sfn_/lfn_ 함수 접두사, Z* 컴포넌트 명명, 메뉴코드 형식, 변수 관례, 공통코드 네이밍 규칙. FE 코드 작성 시 반드시 준수해야 하는 규칙.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: rule
domain: frontend
tags:
  - naming
  - convention
  - function-prefix
  - menu-code
---

# 네이밍 규칙

## 1. 함수 접두사

| 접두사 | 의미 | 위치 | 예 |
| --- | --- | --- | --- |
| `vfn_` | View function — 해당 .vue 내부 로컬 함수 | `views/**/*.vue` | `vfn_searchCt`, `vfn_openUpdatePopup` |
| `gfn_` | Global function — 전역 유틸 | `assets/js/common.js`, `zAuiGrid_common.js` | `gfn_getBizCenter`, `gfn_exportTo`, `gfn_openManual` |
| `sfn_` | Store function — Pinia 스토어 use 훅 | `stores/*.js` | `sfn_useLoginStore`, `sfn_useCommCdStore` |
| `lfn_` | Local function — 모듈 내부 전용 | `assets/js/zAxios.js` 등 | `lfn_setToken`, `lfn_setBaseUrl` |

> 이 접두사는 **IDE 자동완성과 검색을 위한 관례**다. 새 함수 작성 시 반드시 지킨다.

## 2. Z\* 컴포넌트

모든 자체 UI 컴포넌트는 `Z` 로 시작한다. (Zin 사내 접두사)

| 카테고리 | 예 |
| --- | --- |
| 입력 | `ZText`, `ZSelect`, `ZRadio`, `ZCheckbox`, `ZCalendar`, `ZCalendarRange`, `ZCodeSelect`, `ZCodeMulti` |
| 버튼 | `ZBtn`, `ZBtnReg`, `ZBtnMod`, `ZBtnDel`, `ZBtnDoc`, `ZBtnCopy`, `ZBtnProc`, `ZBtnJob`, `ZBtnRowAdd`, `ZBtnRowDel`, `ZBtnRowSave`, `ZBtnRowCopy` |
| 레이아웃 | `ZCellBox`, `ZCell`, `SearchSection`, `ContentSection`, `LayerPopup` |
| 그리드 | `ZAuiGrid` |
| 엑셀 | `ZXlsAllUp`, `ZXlsDown` |

신규 Z\* 컴포넌트 생성은 **원칙적으로 금지**. 필요 시 사용자에게 먼저 확인.

## 3. 메뉴 코드

- **형식**: 메뉴코드는 **영문소문자 4자 + 숫자 2자** 고정 — 정규식: `^[a-z]{4}\d{2}$`
- **예**: `md8000` 업무군 > `mdct01` 거래처 메뉴
- **폴더**: `views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue`
- **팝업 파일명**: `{메뉴코드}Edt.vue`, `{메뉴코드}Lbs.vue`, `{메뉴코드}Dtl.vue` (Edit/Label/Detail)
- **라우트 meta**: `route.meta.menuCd = 'MDCT01'` (대문자)

## 4. 변수 관례

| 관례 | 의미 | 예 |
| --- | --- | --- |
| `initXxxObj` | 검색/편집 초기 데이터 템플릿 | `initSearchCtObj`, `initEditCtObj` |
| `searchXxxObj` | `searchRef` 로 감싼 현재 검색 상태 | `searchCtObj` |
| `editXxxObj` | 편집 중인 단일 레코드 | `editCtObj` |
| `xxxGrid` | ZAuiGrid ref | `ctGrid` |
| `xxxGridProps` / `xxxGridProperties` | 그리드 props 묶음 | `ctGridProperties` |
| `xxxGridEvent` | 그리드 이벤트 묶음 | `ctGridEvent` |
| `xxxList` | 서버 응답 리스트 | `searchBizList`, `postConts` |
| `editPopup` / `detailPopup` | 팝업 컴포넌트 ref | - |

## 5. 공통코드

- `commHCd` (헤더코드, 대문자 스네이크) — 예: `CONT_DIV_CD`, `REP_CONT_CD`, `USE_YN`
- `commDCd` (데이터코드, 응답 필드명) — 예: `contDivCd`
- `commDNm` (변환 후 명칭 필드명) — 예: `contDivNm`
- **규칙**: DB는 snake_case (`cont_div_cd`), FE 는 camelCase (`contDivCd`).

## 6. API 경로

- `/{메뉴코드}/{리소스}` 형식 — 예: `/mdct01/conts`
- `regBizSeq` 는 `zAxios` 인터셉터가 자동 prepend → 코드에서 포함 금지
- `params` 로 검색조건 보내지 말고 `axios.post(url, searchObj.value)` 사용 (GET은 단순 조회만)
