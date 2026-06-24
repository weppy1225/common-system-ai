---
title: kyochon-oms 기준정보(MDM) 테이블 정의서
description: kyochon-oms 기준정보(mdm_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon-oms
domain: database
tags:
  - database
  - table
  - mdm
  - master-data
  - schema
last_verified: 2026-06-23
---

# kyochon-oms 기준정보(MDM) 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `mdm_`
> - 출처: 실 OMS dev DB `pg_class` 조회 (2026-06-23). 설명은 DB comment 원본.
> - 멀티테넌트: 다수 테이블에 `biz_seq`(사업장_SEQ) 포함. 컬럼 단위 상세는 실 스키마(`\d mdm_*`)를 우선 확인한다.

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| mdm_biz | MDM_사업장 |
| mdm_biz_biz | MDM_사업장_사업장 |
| mdm_biz_center | MDM_사업장_센터 |
| mdm_biz_cont | MDM_사업장_거래처 |
| mdm_biz_prod | MDM_사업장_품목 |
| mdm_biz_wh | MDM_사업장_창고 |
| mdm_center | MDM_센터 |
| mdm_cont | MDM_거래처 |
| mdm_cont_account | MDM_거래처_가상계좌 |
| mdm_cont_logi | MDM_거래처_물류 |
| mdm_cont_prod | MDM_거래처_품목 |
| mdm_area_prod | MDM_권역_품목(비노출) |
| mdm_prod | MDM_품목 |
| mdm_wh | MDM_창고 |
| mdm_loc | MDM_위치 |
| mdm_doc_no | MDM_문서번호 |
| mdm_user | MDM_사용자 |
| mdm_user_biz | MDM_권한사업장 |
| mdm_user_center | MDM_권한센터 |

---

## 2. 공통 컬럼 (감사 컬럼)

> OMS 표준 감사 컬럼. soft-delete 플래그(`use_yn`/`del_yn`)는 **테이블마다 존재 여부가 다르다**(전체 126개 중 `use_yn`=30, `del_yn`=13). 단정 전 실 스키마를 확인한다.

| 컬럼명 | 타입 | NULL | 설명 |
|---|---|---|---|
| reg_id | varchar(20) | N | 등록 ID |
| reg_dt | timestamp | N | 등록 일시 |
| mod_id | varchar(20) | Y | 수정 ID |
| mod_dt | timestamp | Y | 수정 일시 |
| use_yn | char(1) | - | 사용 여부 ('N'이면 삭제) — 해당 컬럼 보유 테이블에 한함 |
