---
description: oms-fe 공통코드(commCdStore) 사용의 OMS 고유 차이만. 핵심은 bizSeq=1 교촌 고정(common 의 regBizSeq fallback 과 상반). 공통코드 드롭다운/코드명 표시 시 적용.
---

# OMS 공통코드(commCdStore) 사용 방법 — OMS 고유 차이

> 공통 골격은 [common 문서](../../40-frontend/40-store/01-commCdStore.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 전제: Vue3+Vite+Pinia, 한 코드베이스 → 가맹점(/bc)·Admin(/be)·모바일(/bm) 모드분기.
> 출처: OMS 실제 코드 직접 확인 — `oms-fe/src/stores/commCdStore.js`, `components/be/searchItem/ZCodeSelect.vue`.

---

## 1. bizSeq 규약 — OMS 는 1 교촌 고정 (common 과 상반) ★핵심

MUST: OMS(교촌)는 공통코드를 **`bizSeq = 1` 로 고정 조회**한다.
근거: `commCdStore.convertCommDNms` 내 `const bizSeq = 1`.
이유: 교촌 단일 사업장 운영이라 사업장별 코드 분기가 없다.

| 항목 | common 문서 | OMS 고유 |
|---|---|---|
| `bizSeq` 미지정(`null`/`undefined`/`-1`) | `bizCenterStore.regBizSeq`(로그인 기본 사업장)로 **fallback** | **`bizSeq = 1` 고정** — fallback 안 함 |
| `bizSeq` prop 전달 | 검색영역 `bizSeq` 를 그대로 전달(사업장별 코드) | 대부분 생략 → 1 고정 적용 |

NEVER: OMS 화면에서 `commCdStore` 호출 시 `bizCenterStore.regBizSeq` fallback 을 기대하지 않는다. 코드값은 항상 `bizSeq=1` 기준이다.

---

## 2. commHCd 출처 — OMS 고유

| 항목 | common 문서 | OMS 고유 |
|---|---|---|
| `commHCd` 정의 출처 | DB `sm_code` 테이블의 `comm_h_cd` | OMS 공통코드 헤더(`commHCd`)·코드값(`commDCd`)·코드명(`commDNm`) 구조 |
| 코드값 비교 상수 | (별도 명시 없음) | 조건 분기 코드값은 리터럴 대신 **`zConstant.js` 상수** 사용 (예: `zConstant.OD_STS_CD_COMPLETION`) |

```js
// ❌ if (row.odStsCd === '33')
// ✅ if (row.odStsCd === zConstant.OD_STS_CD_COMPLETION)
```

---

## 3. commCdStore 추가 API (common 에 없는 항목)

근거(실제 정의 확인): `commCdStore.js` return 문.

| 함수 | 시그니처 | 용도 |
|---|---|---|
| `getCommDNm` | `(commHCd, commDCd, bizSeq)` | 단건 코드명 조회 |
| `setCommDNms` | `(targetList, dataList)` | 목록에 코드명 세팅 |
| `getRefDCd` | `(commHCd, commDCd, bizSeq)` | 연결(참조) 코드 조회 |
| `searchCommCdAll` | `()` | 전체 공통코드 로드 |
| `commHCds` | (ref) | 캐시 저장소 `commHCds[bizSeq][commHCd]` |

> `convertCommDNms(commCdList, rows)`·`getCommHCd(commHCd, bizSeq)` 시그니처·배치 캐싱 동작은 common 과 동일.

---

## 4. OMS 컴포넌트 명칭

OMS 공통코드 드롭다운/다중선택 컴포넌트는 → `knowledgebase/domains/oms/patterns/fe/oms-03-custom-component.md`.
연결 코드(대분류→중분류 필터링)는 `linkTarget` prop 사용:

```vue
<ZCodeSelect commCd="LARGE_CD"  v-model="searchObj.largeCd"  :optionNm="$t('message.선택')" />
<ZCodeSelect commCd="MIDDLE_CD" v-model="searchObj.middleCd" :linkTarget="searchObj.largeCd" :optionNm="$t('message.선택')" />
```
