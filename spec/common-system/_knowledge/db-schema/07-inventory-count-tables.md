---
title: 재고실사 테이블 정의서
description: WMS 재고실사(wms_st_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - table
  - inventory-count
  - wms_st
  - schema
---

# 재고실사 테이블 정의서 (Inventory Count Table Definition)

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `wms_st_`
> - 공통 규칙: 삭제는 `del_yn = 'Y'` 처리 (물리삭제 없음), 등록/수정 이력 컬럼 모든 테이블 공통 포함

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| wms_st_sch | WMS_재고실사_일정 |
| wms_st_target | WMS_재고실사_대상 |
| wms_st_inven | WMS_재고실사_재고 |
| wms_st_tran | WMS_재고실사_처리 |

---

## 2. 공통 컬럼 (모든 테이블 포함)

| 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|
| del_yn | char(1) | N | 'N' | 삭제 여부 ('Y'이면 삭제된 데이터) |
| reg_id | varchar(20) | N | | 등록 ID |
| reg_dt | timestamp | N | now() | 등록 일시 |
| mod_id | varchar(20) | Y | | 수정 ID |
| mod_dt | timestamp | Y | | 수정 일시 |
