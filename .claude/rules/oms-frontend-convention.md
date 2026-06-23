---
description: oms-fe(Vue 3 + Vite + Pinia) 화면 코드 작성·수정 시 적용하는 상수 하드코딩 금지·공통코드·스토어 사용 판단 기준. .vue 또는 stores js를 다룰 때 로딩한다.
paths:
  - "**/*.vue"
  - "**/stores/**/*.js"
  - "**/views/**/*.js"
---

# OMS 프론트엔드 개발 규칙 — 판단 기준 & 금지 패턴

> 출처: `wms-bnk-fe/.claude/rules/frontend-convention.md` 의 전이 가능 원칙만 OMS 기준으로 적응 이식.
> 디렉토리 구조·라우팅·axios·Pinia·인증·쇼핑몰 모듈 등 상세 패턴은 → `oms-ai/03-프론트엔드-패턴.md` 참조.
> 상세 작성 가이드: 라우터·메뉴 등록 → `knowledgebase/domains/oms/patterns/fe/oms-01-router-menu-register.md`, 공통코드 → `knowledgebase/domains/oms/patterns/fe/oms-02-common-code-commCdStore.md`, 커스텀 컴포넌트(ZCodeSelect/ZSelect/ZAuiGrid 등) → `knowledgebase/domains/oms/patterns/fe/oms-03-custom-component.md`.
> 도메인 코드값은 → `oms-ai/04-도메인-코드값.md` 참조.

전제(숨은 전제 명시): oms-fe 는 한 코드베이스로 **UI 패러다임이 다른 두 시스템**을 빌드한다 — **쇼핑몰(가맹점) 모드**(`VITE_OMS_YN=Y`, `/bc`, 실제 인터넷 쇼핑사이트 스타일, AUIGrid 미사용)와 **Admin 관리자 모드**(`VITE_OMS_YN=N`, `/be`, WMS식 AUIGrid 관리자 화면)다. 모바일(`/bm`)은 PDA 별도 모드. 두 시스템 구분·UI 스타일 차이 상세 → `knowledgebase/domains/oms/install-guide/oms-01-startup-guide.md` §3.0.

MUST: 신규 화면이 어느 모드(`bc` 쇼핑몰 / `be` 관리자 / `bm` 모바일)에 속하는지 먼저 정하고, **같은 모드의 기존 화면 패턴**을 따른다. `/bc`(쇼핑몰)는 AUIGrid를 쓰지 않고 쇼핑 UI(상품·장바구니·주문폼)로, `/be`(관리자)는 검색조건 + `ZAuiGrid` 목록 + 팝업으로 작성한다. 두 시스템 스타일을 혼용하지 않는다.

---

## 1. 상수 하드코딩 금지 — zConstant.js 사용

MUST: 도메인 상태코드·구분코드를 문자열/숫자 리터럴로 직접 쓰지 않는다. 상수를 `zConstant.js` 에서 import 해 사용한다.
근거(실제 존재 확인): `oms-fe/src/assets/constant/zConstant.js`.

```js
// 방법 A — 네임스페이스(상수 많을 때)
import * as zConstant from '@/assets/constant/zConstant.js';
// 방법 B — named import(1~3개)
import { OD_STS_CD_COMPLETION } from '@/assets/constant/zConstant.js';
```

NEVER: `if (item.odStsCd === '33')` 처럼 상태코드 리터럴 비교. → 상수 사용.
SHOULD: `zConstant.js` 에 해당 상수가 없으면 **추가 후** 사용한다. 임의 리터럴 금지.

> 코드값의 의미(`'33'`=주문완료 등)는 → `04-도메인-코드값.md` 및 BE `fw/constant/OMSPool.java` 와 동일 체계.

---

## 2. 공통코드·사업장명 변환 — 스토어 경유

MUST: 공통코드 조회·변환은 `commCdStore` 또는 `ZCodeSelect`/`ZCodeMulti` 컴포넌트를 경유한다. `axios.post('/code/commcds', ...)` 를 화면에서 직접 호출하지 않는다.
근거(실제 시그니처 확인 `commCdStore.js`): `getCommHCd(commHCd, bizSeq)`(드롭다운 목록), `convertCommDNms(commCdList, convertTarget)`(그리드 코드→명칭 변환), `getCommDNm(commHCd, commDCd, bizSeq)`. OMS(교촌)는 `bizSeq = 1` 고정.

- 화면 드롭다운: `<ZCodeSelect commCd="USE_YN" v-model="..." :optionNm="..." />` (commCdStore 캐시 자동 사용).
- 그리드 코드명: `setGridData` 전에 `commCdStore.convertCommDNms(commCdList, rows)` 호출.
- 상세 → `knowledgebase/domains/oms/patterns/fe/oms-02-common-code-commCdStore.md`.

주요 Pinia 스토어(근거: `03 §4`, `oms-fe/CLAUDE.md`): `loginStore`, `menuStore`, `loadingStore`, `bizCenterStore`, `commCdStore`, `popupStore`.

---

## 3. 신규 화면·메뉴 작성 규칙

MUST: 뷰 파일·라우터는 메뉴코드(영문 4자 + 숫자 2자, 예 `ODRG01C`)를 사용한다. 라우터 `path`/`name`=소문자, `meta.menuCd`/`meta.authMenuCd`=대문자, 뷰=`@/views/{prefix}/{모듈}/{메뉴}/{메뉴}.vue`.
라우터 등록 3단계(모듈 작성 → index.js import → `/bc`·`/be` children 추가)는 → `knowledgebase/domains/oms/patterns/fe/oms-01-router-menu-register.md`.

MUST: 신규 화면은 같은 모드(`bc`/`be`/`bm`) 기존 메뉴 화면을 먼저 읽고 동일 패턴을 따른다. 검색/그리드/팝업은 OMS 커스텀 컴포넌트(`ZCodeSelect`/`ZAuiGrid`/`Zxxx Popup` 등)를 사용 → `knowledgebase/domains/oms/patterns/fe/oms-03-custom-component.md`.

MUST: 그리드는 `zAuiGrid_common.js` 프리셋(`zAuiGridReadonlyPros`/`zAuiGridEditablePros`)을 spread 후 override 한다.
> 참고: WMS 의 `ZAuiGrid gridKey` 필수 규칙은 OMS 에 적용하지 않는다(`grep gridKey oms-fe/src/views` 0건 — OMS 미사용).

---

## 4. 에러 처리

MUST: 조회/요청 실패 시 OMS 공통 에러 알림을 사용한다.
근거(실제 존재 확인): `errorSwal` — `oms-fe/src/assets/js/common.js`(+ `customSwal.js`, `globalFunction.js`).

```js
try {
    const res = await axios.post(`/{모듈}/{리소스}`, searchObj.value);
    // ... setGridData
} catch (error) {
    errorSwal(error);
}
```

---

## 5. 작업 히스토리 규칙 (oms-fe 고유)

MUST: 작업 완료 후 `oms-fe/ui-design/history/yyyyMMddHHmmss.md` 에 작업 내용을 기록한다.
근거: `oms-fe/CLAUDE.md`.

---

## 6. 금지 패턴 요약

- 도메인 상태/구분 코드 리터럴 하드코딩 → `zConstant.js` 상수 (§1)
- 화면에서 `axios.post('/code/commcds')` 직접 호출 → `commCdStore` 경유 (§2)
- store 메서드명·그리드 패턴 추정 → 실제 store/기존 `.vue` 확인 (§2, §3)
