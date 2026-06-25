---
description: OMS 도메인 프론트엔드(Vue 3 + Vite + Pinia) 화면 코드 작성·수정 시 상수 하드코딩 금지·공통코드·스토어 사용 등 OMS 고유 판단 기준·금지만 적용. 고객사가 달라도 OMS 도메인이면 동일 규칙 적용. .vue 또는 stores js를 다룰 때 로딩한다.
paths:
  - "**/*.vue"
  - "**/stores/**/*.js"
  - "**/views/**/*.js"
---

# OMS 프론트엔드 개발 규칙 — OMS 고유 판단 기준

> 이 문서는 **판단 기준·금지만** 담는다. 상세 작성 패턴은 아래 patterns·소스를 본다.
> 전제: OMS FE 한 코드베이스가 **UI 패러다임이 다른 두 시스템**을 빌드한다 — 쇼핑몰(가맹점, `/bc`, `VITE_OMS_YN=Y`, AUIGrid 미사용)·관리자(`/be`, `N`, AUIGrid)·모바일(`/bm`). 구분 상세 → `spec/{$PROJECT}/_knowledge/install-guide/01-startup-guide.md §3.0`.
> 고객사별 프로젝트 경로(`$PROJECT`, `$FE_DIR`) 도출 → `.claude/rules/repo-paths.md`.

## 상세는 어디에 (라우팅)

| 필요한 것 | 위치 |
|---|---|
| 라우터·메뉴 등록 3단계 | `spec/{$PROJECT}/_knowledge/patterns/fe/01-router-menu-register.md` |
| 공통코드(commCdStore) 사용 | `spec/{$PROJECT}/_knowledge/patterns/fe/02-common-code-commCdStore.md` |
| 커스텀 컴포넌트(ZCodeSelect/ZAuiGrid/Zxxx Popup 등) | `{$FE_DIR}/src/components/be/` |
| 상수·도메인 코드값 | `{$FE_DIR}/src/assets/constant/zConstant.js` · `spec/{$PROJECT}/_knowledge/db-schema/90-common-code.md` |

## OMS 고유 판단 기준 (MUST / NEVER)

1. **모드 우선** — 신규 화면이 어느 모드(`bc` 쇼핑몰 / `be` 관리자 / `bm` 모바일)인지 먼저 정하고 같은 모드 기존 화면 패턴을 따른다. `/bc`=쇼핑 UI(상품·장바구니·주문폼, AUIGrid 미사용), `/be`=검색조건 + `ZAuiGrid` + 팝업. 두 스타일 혼용 금지.

2. **상수 하드코딩 금지** — NEVER 도메인 상태/구분 코드 리터럴 비교(`item.odStsCd === '33'`). MUST `zConstant.js`(`@/assets/constant/zConstant.js`) 에서 import. 없으면 추가 후 사용(임의 리터럴 금지).

3. **공통코드·사업장명 변환 — 스토어 경유** — NEVER 화면에서 `axios.post('/code/commcds')` 직접 호출. MUST `commCdStore`(`getCommHCd`/`convertCommDNms`/`getCommDNm`) 또는 `ZCodeSelect`/`ZCodeMulti` 경유. `bizSeq` 초기값은 **프로젝트별 상이** — `spec/{$PROJECT}/_knowledge/` 또는 기존 화면 소스에서 확인 후 사용(추정 금지).

4. **신규 화면·메뉴** — 메뉴코드 영문4+숫자2(예 `ODRG01C`). 라우터 `path`/`name`=소문자, `meta.menuCd`/`meta.authMenuCd`=대문자, 뷰=`@/views/{prefix}/{모듈}/{메뉴}/{메뉴}.vue`. 그리드는 `zAuiGrid_common.js` 프리셋(`zAuiGridReadonlyPros`/`zAuiGridEditablePros`) spread 후 override. ※ WMS 의 `gridKey` 필수 규칙은 OMS 무관(미사용).

5. **에러 처리** — 조회/요청 실패 시 `errorSwal(error)`(`oms-fe/src/assets/js/common.js`) 사용.

6. **작업 히스토리** — 작업 완료 후 `{$FE_DIR}/ui-design/history/yyyyMMddHHmmss.md` 에 기록(근거 FE 레포 `CLAUDE.md`).

> 추정 금지: store 메서드명·그리드 패턴·컴포넌트명은 실제 store/기존 `.vue`/소스를 확인 후 사용한다.
