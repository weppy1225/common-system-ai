---
title: 공통코드(Common Code) — 왜 쓰나 + 어떻게 쓰나 (시스템 횡단)
description: WMS·OMS·WCS 등 여러 시스템 개발 시 공통코드를 왜 사용하고 어떻게 사용하는지(코드마스터 DB → BE 상수 → FE commCdStore 캐시)를 시스템 무관 관점으로 파악할 때 읽는다. 시스템별 구현 차이는 각 도메인 문서로 라우팅한다.
status: active
version: 1.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: instruction
domain: common
tags:
  - common-code
  - commcdstore
  - code-master
  - multi-system
related:
  - patterns/40-frontend/40-store/01-commCdStore.md
  - spec/common-system/_knowledge/db-schema/90-common-code.md
  - spec/kyochon-oms/_knowledge/patterns/fe/02-common-code-commCdStore.md
---

# 공통코드(Common Code) — 왜 쓰나 + 어떻게 쓰나

> 적용 범위: WMS·OMS·WCS 등 **이 허브에서 개발하는 모든 시스템 공통**. 시스템별 차이는 §5 에서 각 문서로 라우팅한다.
> 용어 통일: 코드 그룹 = **공통코드 헤더(commHCd)**, 그 하위 값 = **코드값(commDCd)**, 표시 명칭 = **코드명(commDNm)**.

## 1. 공통코드 정의

공통코드는 **"코드값 ↔ 한글 명칭" 매핑을 소스가 아니라 DB(코드마스터)에서 관리**하는 메커니즘이다.
구조: **헤더(commHCd) 1개 : 코드값(commDCd) N개**. 예) `USE_YN` 헤더 아래 `Y=사용`, `N=미사용`.

| 구성요소 | 의미 | 예시 |
|---|---|---|
| commHCd | 코드 그룹(헤더) | `USE_YN`, `CONT_DIV_CD`, `OUTWH_STS_CD` |
| commDCd | 그룹 내 코드값(디테일) | `Y`, `N`, `11`, `77` |
| commDNm | 코드값의 표시 명칭 | `사용`, `미사용`, `예정`, `확정` |

## 2. 왜 공통코드를 쓰나 (WHY)

MUST: 코드성 값(상태·구분·유형·여부)은 공통코드로 관리한다. 소스에 리터럴로 박지 않는다.

| 이유 | 공통코드 없을 때(문제) | 공통코드 쓸 때(효과) |
|---|---|---|
| 하드코딩 제거 | `if (sts === '77')`, `'확정'` 문자열이 BE/FE 곳곳에 흩어짐 → 값 추가 시 전 소스 수정 | 코드값·명칭 추가·변경을 **DB만 수정**, 배포 불필요 |
| 단일 출처(SSoT) | 같은 코드명을 화면마다 다르게 표기(`확정`/`완료`) | BE·FE·여러 메뉴가 **같은 출처**에서 같은 명칭 사용 |
| 다국어(i18n) | 명칭이 소스에 박혀 언어 전환 불가 | 코드명을 언어/환경별로 DB·메시지로 관리 |
| 사업장별 분기 | 사업장마다 다른 코드 세트를 분기 불가 | `bizSeq` 기준으로 사업장별 코드 세트 제공(§5) |
| 성능 | 코드 조회가 화면마다 중복 호출 | **서버 1회 배치 캐싱** 후 메모리 재사용(§3.3) |
| 다시스템 재사용 | 시스템마다 코드 관리 방식이 달라 학습비용↑ | WMS·OMS·WCS가 **동일 메커니즘** 재사용 → 학습 1회 |

## 3. 어떻게 동작하나 (HOW) — 3계층

코드마스터(DB) → 서버(BE) → 화면(FE) 3계층을 거친다. 어느 시스템이든 이 골격은 같다.

### 3.1 코드마스터 (DB) — 정본

- 헤더/디테일 2테이블에 commHCd·commDCd·commDNm·표시순서·use_yn 등을 저장한다.
- 실제 테이블명·코드값은 **프로젝트별 스키마 문서가 정본**이다(추정 금지).
  - WMS 실 코드값 카탈로그: `spec/common-system/_knowledge/db-schema/90-common-code.md`
  - OMS 실 코드값 카탈로그: `spec/kyochon-oms/_knowledge/db-schema/` (작성 시 `/SD_332` 산출물로 채움)

### 3.2 백엔드(BE) — 코드값 상수화

MUST: 조건 분기에 쓰는 코드값은 **리터럴 금지, 상수로 참조**한다. 이유: 오탈자 방지 + 의미 가독성.

```js
// FE 예 (OMS)
// ❌ if (row.odStsCd === '33')
// ✅ if (row.odStsCd === zConstant.OD_STS_CD_COMPLETION)
```

- OMS BE 상수: `fw/constant/OMSPool.java` (근거: `.claude/rules/oms-db-convention.md`)
- OMS FE 상수: `zConstant.js` (근거: `spec/kyochon-oms/_knowledge/patterns/fe/02-common-code-commCdStore.md`)

### 3.3 프론트엔드(FE) — commCdStore 경유 (배치 캐싱)

MUST: FE 공통코드는 **`commCdStore`(Pinia)를 통해서만** 사용한다. `/code/commcds` 직접 호출 금지.
이유: 같은 bizSeq 요청을 모아 **서버 1회만 호출**(배치 캐싱)하고 메모리 재사용한다. 우회하면 중복 호출·캐시 불일치가 생긴다.

| API | 용도 |
|---|---|
| `convertCommDNms(commCdList, rows)` | 그리드 코드값 필드 → 명칭 필드 변환(가장 많이 씀) |
| `getCommHCd(commHCd, bizSeq)` | 코드 그룹 전체 리스트 조회(ZCodeSelect 내부 사용) |

상세 API·컴포넌트(ZCodeSelect/ZCodeMulti)·캐싱 동작 → `patterns/40-frontend/40-store/01-commCdStore.md`.

## 4. 시스템 공통 규칙 (MUST / NEVER)

| 강도 | 규칙 | 이유 |
|---|---|---|
| MUST | 코드성 값은 공통코드 헤더(commHCd)로 정의한다 | 하드코딩 제거·SSoT |
| MUST | FE는 `commCdStore` 경유로만 코드 조회 | 배치 캐싱·중복호출 방지 |
| MUST | 분기 코드값은 상수(`OMSPool`/`zConstant` 등)로 참조 | 오탈자 방지·가독성 |
| MUST | 그리드 표시는 코드값(commDCd) 아닌 명칭(commDNm)으로 | 사용자 가독성 |
| NEVER | `axios.get('/code/commcds')` 직접 호출 | 캐시 우회 |
| NEVER | 코드값·코드명을 소스에 리터럴(`'77'`, `'확정'`)로 박기 | 변경 시 전 소스 수정 |

## 5. 시스템별 구현 차이 (라우팅)

골격(§3)은 공통이고, **차이는 주로 `bizSeq` 규약과 상수 출처**다. 각 시스템 작업 시 해당 문서를 연다.

| 항목 | WMS (`common-system`) | OMS (`kyochon-oms`) |
|---|---|---|
| `bizSeq` 규약 | 사업장별 코드 세트. 미지정 시 `regBizSeq`(로그인 기본 사업장) **fallback** | **`bizSeq=1` 교촌 고정**(단일 사업장). fallback 안 함 |
| BE 상수 출처 | 미확인: BE 상수 파일 별도 확인 필요 | `fw/constant/OMSPool.java` |
| FE 상수 출처 | 미확인 | `zConstant.js` |
| 실 코드값 카탈로그 | `spec/common-system/_knowledge/db-schema/90-common-code.md` | `spec/kyochon-oms/_knowledge/db-schema/`(`/SD_332`로 채움) |
| FE 사용 상세 | `patterns/40-frontend/40-store/01-commCdStore.md` | `spec/kyochon-oms/_knowledge/patterns/fe/02-common-code-commCdStore.md` |

> 새 시스템(예: WCS) 추가 시: §3 골격을 그대로 따르고, 위 표에 자기 행(특히 `bizSeq` 규약·상수 출처·코드값 카탈로그)을 추가한다.

## 6. 관련 문서 (어떤 걸 먼저 여나)

| 목적 | 문서 |
|---|---|
| FE에서 공통코드 쓰는 법(코어) | `patterns/40-frontend/40-store/01-commCdStore.md` |
| WMS 실제 코드값·코드명 확인 | `spec/common-system/_knowledge/db-schema/90-common-code.md` |
| OMS 공통코드 고유 차이 | `spec/kyochon-oms/_knowledge/patterns/fe/02-common-code-commCdStore.md` |
| 공통코드정의서(엑셀) 산출 | `/SD_332` 스킬 |
| OMS DB 코드값 컨벤션 | `.claude/rules/oms-db-convention.md` |
