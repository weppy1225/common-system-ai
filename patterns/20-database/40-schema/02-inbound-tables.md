---
title: 입하/입고 테이블 정의서
description: WMS 입하(wms_inbiz_*) 및 입고(wms_inwh_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - inbound
  - wms_inwh
  - wms_inbiz
  - schema
---

# 입하/입고 테이블 정의서 (Inbound/Receiving Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `wms_inbiz_` (입하), `wms_inwh_` (입고)
> - 공통 규칙: 삭제는 `del_yn = 'Y'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| wms_inbiz | WMS_입하 |
| wms_inbiz_prod | WMS_입하_품목 |
| wms_inbiz_inwh | WMS_입하_입고 |
| wms_inwh | WMS_입고 |
| wms_inwh_prod | WMS_입고_품목 |
| wms_inwh_tran | WMS_입고_처리 |
| wms_inwh_label | WMS_입고_라벨 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| del_yn | char(1) | N | 'N' | 삭제 여부 ('Y'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
