---
title: kyochon_oms OMS 업무 테이블 정의서
description: kyochon_oms 업무(oms_*) 테이블 목록과 도메인별 그룹·공통 컬럼을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon_oms
domain: database
tags:
  - database
  - table
  - oms
  - order
  - price
  - schema
last_verified: 2026-06-23
---

# kyochon_oms OMS 업무 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `oms_`
> - 출처: 실 OMS dev DB `pg_class` 조회 (2026-06-23). 설명은 DB comment 원본.
> - `*_temp`/`*_tmp`/`*_bak` 작업/임시/백업 테이블은 본 정의서에서 제외(→ `00-tables-overview.md` §8).

---

## 1. 주문·반품 테이블

| 테이블명 | 설명 |
|---|---|
| oms_order | OMS_주문 |
| oms_order_prod | OMS_주문_품목 |
| oms_order_prod_hist | OMS_주문_품목_이력 |
| oms_order_return | OMS_반품 |

## 2. 단가 테이블

| 테이블명 | 설명 |
|---|---|
| oms_price_base | OMS_단가_기준 |
| oms_price_prod | OMS_단가_품목 |
| oms_price_history | OMS_단가_이력 |

## 3. 배정 테이블

| 테이블명 | 설명 |
|---|---|
| oms_allocate_area | OMS_배정_권역 |
| oms_allocate_center | OMS_배정_센터 |
| oms_allocate_cont_avg | OMS_배정_가맹점_평균 |

## 4. 배송요일·리드타임 테이블

| 테이블명 | 설명 |
|---|---|
| oms_delivery_area | OMS_배송요일_권역 |
| oms_delivery_area_period | OMS_배송요일_권역_기간 |
| oms_delivery_cont | OMS_배송요일_거래처 |
| oms_leadtime | OMS_리드타임 |
| oms_leadtime_area | OMS_리드타임_권역별 |
| oms_leadtime_cont | OMS_리드타임_거래처 |

## 5. 가맹점 거래·여신·마감 테이블

| 테이블명 | 설명 |
|---|---|
| oms_cont_credit | OMS_가맹점_여신 |
| oms_cont_day_tran | OMS_가맹점_거래내역 |
| oms_cont_month_tran | OMS_가맹점_월간_거래내역 |
| oms_cont_holiday | OMS_가맹점_휴일 |
| oms_manual_tran | OMS_수기_거래내역 |
| oms_manual_tran_history | OMS_수기_거래내역_이력 |
| oms_deadline_edit | OMS_마감일시_변경 |
| oms_deadline_edit_cont | OMS_마감일시_변경_거래처 |

## 6. 세트·대체·즐겨찾기·광고정산 테이블

| 테이블명 | 설명 |
|---|---|
| oms_st_prod | OMS_세트_품목 |
| oms_st_prod_dtl | OMS_세트_품목_상세 |
| oms_replace_prod | OMS_대체_품목 |
| oms_replace_prod_cont | (DB comment 미설정) |
| oms_favorite | OMS_즐겨찾기 |
| oms_favorite_prod | OMS_즐겨찾기_품목 |
| oms_ad_price_settle | OMS_광고_비용_정산 |
| oms_ad_price_settle_cont | OMS_광고_비용_정산_거래처 |

---

## 7. 공통 컬럼 (감사 컬럼)

> OMS 표준 감사 컬럼. soft-delete 플래그(`use_yn`/`del_yn`)는 테이블마다 존재 여부가 다르다. 컬럼 단위 상세는 실 스키마(`\d oms_*`)를 우선 확인한다.

| 컬럼명 | 타입 | NULL | 설명 |
|---|---|---|---|
| reg_id | varchar(20) | N | 등록 ID |
| reg_dt | timestamp | N | 등록 일시 |
| mod_id | varchar(20) | Y | 수정 ID |
| mod_dt | timestamp | Y | 수정 일시 |
