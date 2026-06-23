---
description: oms-fe 신규 화면(메뉴)의 라우터 모듈 등록 방법과 메뉴코드 네이밍 — OMS 고유 차이만. 신규 메뉴/화면 추가 시 적용. 공통 3단계 골격은 common 문서 참조.
---

# OMS 신규 메뉴·라우터 등록 방법 — OMS 고유 차이

> 공통 골격은 [common 문서](../../../../../patterns/40-frontend/10-architecture/03-menu-registration.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 전제: Vue3+Vite+Pinia, 한 코드베이스 → **두 UI 시스템** 쇼핑몰(가맹점 `/bc`, e-commerce 스타일·AUIGrid 미사용)·관리자(Admin `/be`, WMS식 AUIGrid)·모바일(`/bm`) 모드분기. 두 시스템 차이 → `knowledgebase/domains/oms/install-guide/oms-01-startup-guide.md` §3.0.
> 출처: OMS 실제 코드 직접 확인 — `oms-fe/src/router/index.js`, `oms-fe/src/router/modules/bc/od3000c.js`.

---

## 1. OMS 고유 차이 (vs common)

| 항목 | common 문서 | OMS 고유 |
|---|---|---|
| 앱 모드 | `/be`(Admin) 단일 | **3모드 분기** — 가맹점 `/bc`(`VITE_OMS_YN=Y`)·Admin `/be`(`VITE_OMS_YN=N`)·모바일 `/bm` |
| 라우터 export | 단일 routes | `router/index.js` 가 `isOms` 로 `omsRouter`(`/bc`)/`adminRouter`(`/be`) 중 하나를 export |
| 라우터 모듈 경로 | `src/router/modules/be/{업무군}.js` | `src/router/modules/{bc\|be\|bm}/{모듈코드}.js` (모드별 디렉토리 분리) |
| 모듈코드 예 | `iv3000`, `iw1000`, `md8000` | `od3000c`(주문) 등 — 가맹점 모듈은 접미 `c` 포함 |
| 메뉴코드 접미 | 없음(`IVNW01`) | 모드 접미 **`C`** 포함 — `ODRG01C`(주문등록), `ODST01C`(주문현황) |
| 등록 children 분기 | `/be` children 만 | 가맹점=`omsRouter`(`/bc`) children, 관리자=`adminRouter`(`/be`) children, 모바일=`/bm` children |
| DB 메뉴 등록 절차 | `sm_menu` INSERT + `sm_menu_group` 권한 부여 SQL 절차 명시 | **미확인:** OMS 메뉴 권한 등록은 시스템관리 메뉴/DB 작업이며 운영 절차 확인 필요 (common 의 sm_menu/sm_menu_group SQL 절차는 OMS 에 그대로 적용된다고 단정하지 않는다) |

---

## 2. OMS 라우터 모듈 구조 (모드 디렉토리 분리)

근거: `oms-fe/src/router/modules/bc/od3000c.js`

```js
export default {
    path: 'od3000c',                         // 모듈(그룹) 경로 (가맹점 모듈은 접미 c)
    meta: { title: '주문', img: 'icon-mdm.png' },
    children: [
        {
            path: 'odrg01c',                 // 소문자 메뉴코드 (접미 c)
            name: 'odrg01c',
            component: () => import('@/views/bc/od3000c/odrg01c/odrg01c.vue').catch(() => routerErrorHandler()),
            meta: { title: '주문등록', img: 'icon_guide.png', menuCd: 'ODRG01C', authMenuCd: 'ODRG01C' }
        },
        // 서브 화면도 같은 menuCd 공유 (suffix 추가)
        {
            path: 'odrg01cCompleted',
            name: 'odrg01cCompleted',
            component: () => import('@/views/bc/od3000c/odrg01c/odrg01cCompleted.vue').catch(() => routerErrorHandler()),
            meta: { title: '주문등록', img: 'icon_guide.png', menuCd: 'ODRG01C', authMenuCd: 'ODRG01C' }
        }
    ]
}
```

MUST: 뷰 파일 경로 = `@/views/{prefix}/{모듈코드}/{메뉴코드}/{메뉴코드}.vue` (prefix = `bc`/`be`/`bm`).
MUST: 같은 메뉴의 서브 화면은 메뉴코드에 suffix 추가 — `odrg01cCompleted.vue`, `odst01cDetail.vue`, `odst01cUpdate.vue`. 서브 화면도 동일 `menuCd` 공유.

---

## 3. OMS 신규 메뉴 등록 절차 (3모드 분기)

근거: `oms-fe/src/router/index.js`

1. `src/router/modules/{bc|be|bm}/{모듈코드}.js` 에 라우터 모듈 작성(§2 구조).
2. `src/router/index.js` 상단에 import 추가.
   ```js
   import orderRouter from './modules/bc/od3000c.js';   // 기존 예
   ```
3. 모드에 맞는 라우터 children 배열에 추가.
   ```js
   // omsRouter: path '/bc' → children (가맹점)
   children: [ omsMainRouter, orderRouter, returnRouter, ... ]
   // adminRouter: path '/be' → children (관리자)
   children: [ md8000Router, ..., odRouter, sh7000Router, errorRouter ]
   ```

MUST: 가맹점 화면은 `omsRouter`(`/bc`) children, 관리자 화면은 `adminRouter`(`/be`) children, 모바일은 `/bm` children 에 등록한다(모드별 분리).

> 쇼핑몰(`/bc/sh7000c`) 메뉴는 라우터 가드 `omsCheckRouter` 에서 개인정보 동의(`consentStore.checkAndShowIfNeeded()`) 를 체크한다.

---

## 4. OMS BE 신규 메뉴 패키지 생성 (라우터 아님)

OMS BE 는 라우터가 아니라 **패키지 + 클래스 세트**로 메뉴를 추가한다.
근거: `oms-be` 패키지 구조(`@MapperScan basePackages={"bc","be","bm","fw","sif"}`).

MUST:
1. 모드에 맞는 패키지에 메뉴 디렉토리 생성: 가맹점 `bc/{모듈코드}/{메뉴코드}/`, 관리자 `be/{모듈코드}/{메뉴코드}/`.
2. 모듈코드 접두 클래스 세트 작성: `Controller`/`Comp`/`CompUtil`/`TxComp`/`Dao`/`Mapper`(`.java`+`.xml`).
3. `@RequestMapping` 첫 경로 변수는 `{bizSeq}`.

NEVER: 임의 신규 패키지 생성(기존 `bc`/`be`/`bm`/`fw`/`sif` 패키지 구조 사용).
