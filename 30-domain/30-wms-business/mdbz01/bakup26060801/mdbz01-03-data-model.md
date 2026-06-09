---
title: MDBZ01 데이터 모델 (테이블·관계·상태값)
description: mdbz01 사업장·물류센터·물류위탁(3PL) 업무의 물리 테이블 매핑, 테이블 간 관계 의미, 상태값/코드 규칙을 설계 해석 수준으로 기술. 컬럼 타입의 Source of Truth는 운영/dev DB이며 information_schema 직접 조회로 확인(공용 규칙 §3).
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "70-knowledgebase/mdbz01/mdbz01-01-basic-design.md"
  - "70-knowledgebase/_common/tech-stack.md"
related:
  - "70-knowledgebase/mdbz01/mdbz01-04-be-mapper-sql.md"
  - "70-knowledgebase/mdbz01/mdbz01-05-api.md"
  - "70-knowledgebase/mdbz01/mdbz01-06-be-flow.md"
source_of_truth: true
validation:
  - "컬럼 타입은 운영/dev DB(information_schema) 직접 조회로 검증 — 공용 _common/tech-stack.md §3"
tags:
  - detail-design
  - data-model
  - 3pl
---

# MDBZ01 데이터 모델 — 「사업장」

> 업무 개념이 **어떤 테이블·관계·상태값으로 구현**되었는지 설계 해석 수준으로 기술한다.
> ⚠️ 컬럼 단위 상세(타입·길이·NN·default)는 이 문서가 아니라 아래 **§ 컬럼 타입 — Source of Truth**로 확인한다. 여기서는 **업무-테이블 매핑 + 관계 + 상태값 의미**만 다룬다.

### 컬럼 타입 — Source of Truth (운영/dev DB 직접 조회)

> 컬럼 타입·길이·NN·default의 **정답은 살아있는 DB**이다. 조회 방법·접속 정보 위치는 **공용 규칙 [`_common/tech-stack.md`](../_common/tech-stack.md) §3** 에 정의되어 있다.

**본 메뉴 테이블 한정 조회** (공용 §3의 ① SQL에 아래 목록 적용):
```sql
... AND table_name IN ('mdm_biz','mdm_biz_biz','mdm_center','mdm_biz_center',
                       'mdm_wh','mdm_loc','mdm_biz_wh','mdm_user','mdm_user_biz',
                       'mdm_user_center','sm_file','mdm_doc_no')
```

> 파생 필드(`editableYn`·`reqSts`·`authCnt`·`tplCenterYn` 등)는 테이블 컬럼이 아니라 **SQL에서 산출**되므로, 타입은 [`mdbz01-04-be-mapper-sql.md`](mdbz01-04-be-mapper-sql.md) §4의 `CASE`/`COUNT` 식에서 확인한다.

## 1. 물리 테이블 목록

| 업무 개념 | 물리 테이블 | 비고 |
|---|---|---|
| 회사(사업장) | `MDM_BIZ` | `biz_div_cd`: TPL(대행)/OWN(자사)/SHIPPER(화주) |
| 회사 간 거래관계 | `MDM_BIZ_BIZ` | 위탁 거래 관계 |
| 센터 | `MDM_CENTER` | |
| 회사↔센터 관계 | `MDM_BIZ_CENTER` | ★상태머신 핵심 |
| 창고/로케이션 | `MDM_WH` / `MDM_LOC` / `MDM_BIZ_WH` | |
| 권한 | `MDM_USER` / `MDM_USER_BIZ` / `MDM_USER_CENTER` | |
| 파일 | `SM_FILE` | 로고 이미지 |

## 2. 테이블 관계 (FK 의미)

| 테이블 | 컬럼 | 의미 |
|---|---|---|
| `MDM_BIZ_BIZ` | `ref_biz_seq` | 의뢰 **받는** 쪽 (대행사) |
| `MDM_BIZ_BIZ` | `biz_seq` | 의뢰 **하는** 쪽 (의뢰자) |
| `MDM_BIZ_CENTER` | `biz_seq` vs `reg_biz_seq` | 같으면 자기 센터, 다르면 위탁 센터 (`tplCenterYn`, `mineYn`) |

## 3. 상태값 / 코드 규칙 — `MDM_BIZ_CENTER`

거래 상태(신청중/승인/거절)는 `cfm_yn` + `use_yn` **두 컬럼 조합**으로 구현된다.

| cfm_yn | use_yn | 상태(업무) | 코드값(`checkExistBizCenter`) |
|:---:|:---:|---|---|
| `N` | `N` | 신청중 | `REQUEST` |
| `Y` | `Y` | 승인 | `ACCEPT` |
| `Y` | `N` | 거절 | `DENIED` |

- 소유 구분: `biz_seq == reg_biz_seq` → 자기 센터, 다르면 위탁 센터.

### 3-1. `biz_div_cd` (회사 구분)

| 코드 | 의미 |
|---|---|
| `TPL` | 대행 (물류 위탁을 수행하는 대행사) |
| `OWN` | 자사 |
| `SHIPPER` | 화주 |
