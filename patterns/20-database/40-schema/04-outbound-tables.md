---
title: 출하/출고/송장/상차 테이블 정의서
description: WMS 출하(wms_outbiz_*), 출고(wms_outwh_*), 송장(wms_invoice_*), 상차(wms_load_*) 테이블 목록을 확인할 때 읽는다
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - outbound
  - wms_outbiz
  - wms_outwh
  - wms_invoice
  - wms_load
  - schema
---

# 출하/출고/송장/상차 테이블 정의서 (Outbound/Shipping/Invoice/Loading Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `wms_outbiz_` (출하), `wms_outwh_` (출고), `wms_invoice_` (송장), `wms_load_` (상차)
> - 공통 규칙: 삭제는 `del_yn = 'Y'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| wms_outbiz | WMS_출하 |
| wms_outbiz_prod | WMS_출하_품목 |
| wms_outbiz_tran | WMS_출하_처리 |
| wms_outwh_assign | WMS_출고지시 |
| wms_outbiz_outwh | WMS_출하_출고 |
| wms_outwh | WMS_출고 |
| wms_outwh_prod | WMS_출고_품목 |
| wms_outwh_tran | WMS_출고_처리 |
| wms_outbiz_invoice | WMS_출하_송장 |
| wms_invoice | WMS_송장 |
| wms_invoice_prod | WMS_송장_품목 |
| wms_invoice_tran | WMS_송장_처리 |
| wms_outbiz_load | WMS_출하_상차 |
| wms_load | WMS_상차 |
| wms_load_prod | WMS_상차_품목 |
| wms_load_tran | WMS_상차_처리 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| del_yn | char(1) | N | 'N' | 삭제 여부 ('Y'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
