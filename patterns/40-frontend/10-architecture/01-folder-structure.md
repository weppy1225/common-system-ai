---
title: FE 폴더 구조
description: FE 소스 디렉토리 구조, views/be 패턴, components 책임 분리, api/router 구조를 설명한다. FE 파일 생성 위치 결정 시 필수 참조.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: frontend
tags:
  - folder-structure
  - vue3
  - components
  - router
---

# 폴더 구조

## 1. 최상위

```
common-system-fe/
├─ src/                  소스 코드
├─ public/               정적 파일
├─ e2e/                  Playwright E2E
├─ vitest/               단위 테스트 루트
├─ DEV_DOC/              문서 (ai-docs 포함)
├─ vite.config.js
└─ package.json
```

## 2. src 내부

```
src/
├─ App.vue
├─ main.js
├─ api/              ⚠️ mockoon mock 데이터만. 실제 호출 아님
├─ assets/
│   ├─ constant/     zConstant.js (REP_CO_NONE 등)
│   ├─ js/
│   │   ├─ common.js          ← 거의 모든 gfn_*, *Tool 이 여기
│   │   ├─ zAxios.js          ← axios 인터셉터 (토큰/regBizSeq/baseURL)
│   │   ├─ customSwal.js      ← errorSwal/successSwal/confirmSwal
│   │   ├─ globalFunction.js
│   │   ├─ zPrototype.js      ← Array/Object 프로토타입 확장 (deepCopy 등)
│   │   ├─ sessionTimeout.js
│   │   ├─ socket.js / sse/   ← 실시간
│   │   └─ event/ exception/
│   ├─ json/ fonts/ images/ audio/ styles/ plugin/
│   ├─ pinia.js
│   └─ zAuiGrid_common.js     ← 그리드 기본 props, gfn_exportTo 등
├─ components/
│   ├─ be/           PC 전용 Z* 컴포넌트
│   ├─ bm/           모바일 전용
│   └─ comm/         공용 (barcode/search/section)
├─ layout/           전역 레이아웃 (Header/Menu/Footer)
├─ router/
│   ├─ index.js
│   └─ modules/      be/ bm/ error.js guide.js 로 분리
├─ stores/           Pinia 스토어 (*Store.js)
└─ views/
    ├─ be/           PC 메뉴 — 업무군/메뉴코드 폴더
    ├─ bm/           모바일 메뉴
    ├─ login/ guide/ error/
```

## 3. views/be 내부 패턴

```
views/be/{업무군코드}/{메뉴코드}/
├─ {메뉴코드}.vue        리스트(메인) 화면
├─ {메뉴코드}Edt.vue     등록/수정 팝업
├─ {메뉴코드}Lbs.vue     라벨출력 팝업 (선택)
├─ {메뉴코드}Dtl.vue     상세보기 팝업 (선택)
└─ ...추가 탭/서브팝업은 같은 폴더에
```

실제 예 — `views/be/md8000/mdct01/`:
```
mdct01.vue      거래처 리스트
mdct01Edt.vue   거래처 등록/수정
mdct01Lbs.vue   거래처 라벨
```

## 4. components 책임 분리

| 폴더 | 용도 | 허용 | 금지 |
| --- | --- | --- | --- |
| `components/be` | PC UI 전용 | PC 화면에서 사용 | 모바일 화면에서 import |
| `components/bm` | 모바일 UI 전용 | 모바일 화면에서 사용 | PC 화면에서 import |
| `components/comm` | 양쪽 공용 | 양쪽 모두 | PC/모바일 분기 |

`components/be/{카테고리}/` 하위에는 보통 `xxx.js` 배럴(파일) 이 있어 한 번에 import:

```js
import { ZText, ZSelect, ZCodeSelect } from '@/components/be/searchItem/schItems.js';
import { ZBtn, ZBtnMod } from '@/components/be/btnFuc/btnFuc.js';
import { ZCell, ZCellBox } from '@/components/comm/section/section.js';
```

## 5. api/ 폴더

- **Mockoon 테스트용 mock 데이터만** 저장 (`mockoon.json` 등).
- 실제 API 호출은 각 .vue 에서 `axios.post('/mdct01/conts', ...)` 처럼 **직접** 한다.
- 서비스/레포지토리 레이어는 없다.

## 6. router

- `router/modules/be/`, `router/modules/bm/` 에 업무군별로 분리
- 각 라우트 `meta.menuCd` 필수 — `searchOption`, `gfn_openManual` 등이 이 값을 읽음
- 동적 탭 구조: `router/index.js` 에 뒤로가기/탭유지 로직
