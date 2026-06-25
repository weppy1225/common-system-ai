---
description: BE·FE에서 공통코드(상태·구분·유형·여부 코드값)를 다룰 때 적용하는 시스템 무관(WMS·OMS·WCS) 규칙. 코드값 상수화·FE commCdStore 경유·명칭변환·하드코딩 금지. .vue/스토어js/상수파일/Comp/TxComp/Mapper.xml 을 다룰 때 로딩한다.
paths:
  - "**/*.vue"
  - "**/stores/**/*.js"
  - "**/*Constant*.js"
  - "**/*Comp.java"
  - "**/*TxComp.java"
  - "**/*Mapper.xml"
  - "**/constant/**/*.java"
---

# 공통코드 사용 규칙 (BE·FE 공통, 시스템 무관)

> 왜 쓰나 + 3계층 HOW(코드마스터→BE 상수→FE commCdStore) 상세 → `patterns/_common-arch/common-code.md`
> 시스템별 차이(`bizSeq` 규약·상수 출처) → 같은 문서 §5
> 전제: 코드성 값 = 상태(`*StsCd`)·구분(`*DivCd`)·유형(`*TypeCd`)·여부(`*Yn`) 등 commHCd 로 정의된 값.

## 1. 핵심 규칙 (MUST / NEVER)

| 강도 | 규칙 | 이유 |
|---|---|---|
| MUST | FE 공통코드 조회·변환은 **`commCdStore` 또는 `ZCodeSelect`/`ZCodeMulti` 경유** | 배치 캐싱(서버 1회 호출)·중복호출 방지 |
| MUST | 분기에 쓰는 코드값은 **상수 참조** (BE `*Pool.java`, FE `zConstant.js` 등) | 오탈자 방지·의미 가독성 |
| MUST | 그리드·화면 표시는 코드값(commDCd) 아닌 **명칭(commDNm)** | 사용자 가독성 (`convertCommDNms` 사용) |
| MUST | 코드 그룹(commHCd)·코드값은 **프로젝트 코드값 카탈로그에서 확인**, 추정 금지 | 잘못된 코드값 방지 |
| NEVER | 화면에서 `axios.get/post('/code/commcds')` **직접 호출** | 캐시 우회 |
| NEVER | 코드값·코드명을 소스에 **리터럴 하드코딩** (`if(sts==='77')`, `'확정'`) | 값 변경 시 전 소스 수정 발생 |

```js
// ❌ if (row.odStsCd === '33')
// ✅ if (row.odStsCd === zConstant.OD_STS_CD_COMPLETION)
```

## 2. 트리거 시 행동 (이 규칙이 로딩되면)

1. 코드성 값을 다루면 먼저 `patterns/_common-arch/common-code.md` 의 §3(HOW)·§5(시스템별 차이)를 확인한다.
2. 현재 작업 시스템의 `bizSeq` 규약·상수 출처·코드값 카탈로그를 §5 표에서 찾아 적용한다.
3. 시스템별 상세 규칙이 있으면 함께 따른다 (충돌 시 시스템별 규칙 우선).

## 3. 시스템별 상세 규칙 (해당 시스템 작업 시 함께 적용)

| 시스템 | FE 상세 | BE/DB 상세 |
|---|---|---|
| OMS (`kyochon-oms`) | `.claude/rules/oms-frontend-convention.md` §2 · `spec/{$PROJECT}/_knowledge/patterns/fe/02-common-code-commCdStore.md` | `.claude/rules/oms-db-convention.md` |
| WMS (`common-system`) | `patterns/40-frontend/40-store/01-commCdStore.md` | `spec/common-system/_knowledge/db-schema/90-common-code.md` |

> 우선순위: 시스템별 규칙 > 이 공통 규칙 > `patterns/_common-arch/common-code.md`(개념). 시스템별 규칙은 "실제값", 이 규칙은 "기본값"이다.
