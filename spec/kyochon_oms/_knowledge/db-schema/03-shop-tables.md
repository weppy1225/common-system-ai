---
title: kyochon_oms 쇼핑몰 테이블 정의서
description: kyochon_oms 쇼핑몰(shop_*) 테이블 목록과 공통 컬럼 규칙을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon_oms
domain: database
tags:
  - database
  - table
  - shop
  - schema
last_verified: 2026-06-23
---

# kyochon_oms 쇼핑몰 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `shop_`
> - 출처: 실 OMS dev DB `pg_class` 조회 (2026-06-23). 설명은 DB comment 원본.

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| shop_prod | 쇼핑몰_상품 |
| shop_prod_opt | 쇼핑몰_상품_옵션 |
| shop_prod_price_hist | 쇼핑몰_상품_단가_이력 |
| shop_cart | 쇼핑몰_장바구니 |
| shop_cart_opt | 쇼핑몰_장바구니_옵션 |
| shop_order | 쇼핑몰_주문 |
| shop_order_prod | 쇼핑몰_주문_상품 |
| shop_order_prod_opt | 쇼핑몰_주문_상품_옵션 |
| shop_order_prod_sts_hist | 쇼핑몰_주문_상품_상태_이력 |
| shop_cont | 쇼핑몰_제작업체 |
| shop_draft | 쇼핑몰_시안 |
| shop_draft_file | 쇼핑몰_시안_파일 |
| shop_agree | 쇼핑몰_동의서 |

---

## 2. 공통 컬럼 (감사 컬럼)

> soft-delete 플래그(`use_yn`/`del_yn`)는 테이블마다 존재 여부가 다르다. 컬럼 단위 상세는 실 스키마(`\d shop_*`)를 우선 확인한다.

| 컬럼명 | 타입 | NULL | 설명 |
|---|---|---|---|
| reg_id | varchar(20) | N | 등록 ID |
| reg_dt | timestamp | N | 등록 일시 |
| mod_id | varchar(20) | Y | 수정 ID |
| mod_dt | timestamp | Y | 수정 일시 |
