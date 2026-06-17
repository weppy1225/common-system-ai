---
title: 재고관리 테이블 정의서
description: WMS 재고조정(wms_inven_ad_*), 예외출고(wms_inven_etc_*), 재고이동(wms_inven_mv_*), 품목전환(wms_inven_rp_*), 세트작업(wms_inven_st_*) 테이블 목록을 확인할 때 읽는다
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - inventory-management
  - adjustment
  - transfer
  - schema
---

# 재고관리 테이블 정의서 (Inventory Management Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `wms_inven_ad_` (재고조정), `wms_inven_etc_` (예외출고), `wms_inven_mv_` (재고이동), `wms_inven_rp_` (품목전환), `wms_inven_st_` (세트작업)
> - 공통 규칙: 삭제는 `del_yn = 'Y'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| **재고조정** | |
| wms_inven_ad | WMS_재고조정 |
| wms_inven_ad_prod | WMS_재고조정_품목 |
| wms_inven_ad_tran | WMS_재고조정_처리 |
| **예외출고** | |
| wms_inven_etc | WMS_예외출고 |
| wms_inven_etc_prod | WMS_예외출고_품목 |
| wms_inven_etc_tran | WMS_예외출고_처리 |
| **재고이동** | |
| wms_inven_mv | WMS_재고이동 |
| wms_inven_mv_prod | WMS_재고이동_품목 |
| wms_inven_mv_tran | WMS_재고이동_처리 |
| **품목전환** | |
| wms_inven_rp | WMS_품목전환 |
| wms_inven_rp_prod | WMS_품목전환_품목 |
| wms_inven_rp_tran | WMS_품목전환_처리 |
| **세트작업** | |
| wms_inven_st | WMS_세트작업 |
| wms_inven_st_prod | WMS_세트작업_품목 |
| wms_inven_st_tran | WMS_세트작업_처리 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| del_yn | char(1) | N | 'N' | 삭제 여부 ('Y'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
