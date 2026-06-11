---
title: 재고 테이블 정의서
description: WMS 재고(wms_inven_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - inventory
  - wms_inven
  - schema
---

# 재고 테이블 정의서 (Inventory Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `wms_inven_`
> - 공통 규칙: 삭제는 `del_yn = 'Y'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함
> - **wms_inven 직접 DML 금지**: 재고 증감은 반드시 InvenManager 경유

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| wms_inven_sku | WMS_재고_SKU이력 |
| wms_inven_inout | WMS_재고_수불 |
| wms_inven | WMS_재고 |
| wms_inven_holding | WMS_재고_예약 |
| wms_inven_month | WMS_재고_월마감 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| del_yn | char(1) | N | 'N' | 삭제 여부 ('Y'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
