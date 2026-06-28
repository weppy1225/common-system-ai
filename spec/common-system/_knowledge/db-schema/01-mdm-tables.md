---
title: 기준정보(MDM) 테이블 정의서
description: WMS 기준정보(mdm_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - mdm
  - master-data
  - schema
---

# 기준정보(MDM) 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `mdm_`
> - 공통 규칙: 삭제 여부 및 소프트삭제 플래그 적용 방식은 테이블별 실제 스키마를 우선 확인한다.
> - 삭제 컬럼(`use_yn`, `del_yn` 등) 존재 여부가 불명확하거나 예외 가능성이 있으면 문서를 단정하지 말고 먼저 사용자에게 확인한다.
> - 등록/수정 이력 컬럼은 공통 포함을 원칙으로 하되, 최종 판단은 실스키마 기준으로 한다.

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| mdm_biz | 사업장 마스터 |
| mdm_biz_biz | 사업장 간 상위-하위 계층 관계 |
| mdm_biz_center | 사업장-센터 계약/승인 관계 |
| mdm_biz_cont | 사업장별 사용 가능한 거래처 |
| mdm_biz_prod | 사업장별 사용 가능한 품목 |
| mdm_biz_wh | 사업장별 사용 가능한 창고 |
| mdm_car | 차량 마스터 |
| mdm_center | 물류센터 마스터 |
| mdm_cont | 거래처 마스터 |
| mdm_cont_prod | 거래처별 품목 매핑 |
| mdm_doc_no | 문서번호 채번 관리 |
| mdm_label_paper | 라벨 용지 마스터 |
| mdm_loc | 위치(로케이션) 마스터 |
| mdm_prod | 품목 마스터 |
| mdm_rp_prod | 전환품목 마스터 |
| mdm_st_config | 세트 구성 헤더 |
| mdm_st_config_dtl | 세트 구성 상세 |
| mdm_st_prod | 세트구성 품목 마스터 |
| mdm_wh | 창고 마스터 |
| mdm_user | 사용자 마스터 |
| mdm_user_biz | 사용자 권한 사업장 매핑 |
| mdm_user_center | 사용자 권한 센터 매핑 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| use_yn | char(1) | N | 'Y' | 사용 여부 ('N'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
