---
title: shft01c 의탁자 구매 DB 설계
description: shft01c(의탁자 구매) 화면의 DB 변경사항 및 사용 테이블 명세. SD_db_apply 및 PI_be_all 코드 생성 전 참조.
status: active
version: 1.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: spec
project: kyochon-oms
domain: shop
tags:
  - shft01c
  - shop
  - cart
  - order
  - data-model
---

# shft01c 의탁자 구매 DB 설계

> 작성일: 2026-06-26 | 상태: 초안
> 참조 화면설계: shft01c-02-ui.md (미작성)
> 검토자: __________ | 승인일자: __________ | 승인여부: [ ] 승인대기

---

## 1. 변경 요약

| 구분 | 대상 | 내용 |
|------|------|------|
| 변경없음 | 기존 테이블 그대로 사용 | DDL 없음 |

> **신규 테이블 없음. 컬럼 추가 없음.**
> 실 DB(dev) 직접 조회(2026-06-26) 결과 — `shop_cart`, `shop_order`, `shop_order_prod`, `shop_prod` 모두 기존 컬럼으로 shft01c 기능을 지원한다.

---

## 2. 사용 테이블

| 테이블명 | 판정 | 역할 |
|----------|------|------|
| `shop_prod` | 기존 | 상품 목록·상세 조회 |
| `shop_cart` | 기존 | 장바구니 담기·수정·삭제·조회 |
| `shop_order` | 기존 | 주문 헤더 (주문 등록·조회·취소) |
| `shop_order_prod` | 기존 | 주문 상품 라인 (상품별 진행상태 포함) |
| `shop_order_prod_sts_hist` | 기존 | 주문 상품 상태 변경 이력 |
| `shop_cont` | 기존 | 제작업체 정보 조회 (shop_order_prod.shop_cont_seq 참조) |
| `mdm_cont` | 기존 | 가맹점 정보 조회 (cont_seq = bizSeq) |

---

## 3. 신규 테이블 명세

> 신규 테이블 없음. 생략.

---

## 4. 기존 테이블 컬럼 상세 (실 DB 조회 결과)

> 컬럼 추가 없음. 설계 참조용으로 주요 테이블 실 스키마를 기록한다.

### shop_prod (쇼핑몰_상품)

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `shop_prod_seq` | int4 | NOT NULL | nextval('shop_prod_seq') | PK |
| `shop_prod_no` | varchar(40) | NOT NULL | | 상품번호 |
| `shop_cont_seq` | int4 | NOT NULL | | 제작업체 SEQ (FK → shop_cont) |
| `shop_prod_type_cd` | varchar(50) | NOT NULL | | 상품유형코드 → `SHOP_PROD_TYPE_CD` |
| `shop_prod_category_cd` | varchar(50) | NULL | | 상품카테고리코드 |
| `item_type_cd` | varchar(50) | NULL | | 아이템유형코드 |
| `shop_prod_nm` | varchar(100) | NOT NULL | | 상품명 |
| `shop_prod_description` | varchar(1000) | NULL | | 상품 설명 |
| `note` | varchar(1000) | NULL | | 노트 |
| `shop_prod_size` | varchar(100) | NULL | | 상품 규격 |
| `shop_prod_min_buy_qty` | numeric | NULL | 1 | 최소 구매수량 |
| `sale_price` | numeric | NOT NULL | | 판매가 |
| `buy_price` | numeric | NULL | | 매입가 |
| `rep_img1_file_seq` | int4 | NULL | | 대표이미지1 파일 SEQ |
| `rep_img2_file_seq` | int4 | NULL | | 대표이미지2 파일 SEQ |
| `detail_file_seq` | int4 | NULL | | 상세이미지 파일 SEQ |
| `disp_no` | smallint | NULL | 0 | 전시 순서 |
| `acct_no` | varchar(20) | NULL | | 계좌번호 |
| `bank_nm` | varchar(100) | NULL | | 은행명 |
| `cs_tel` | varchar(500) | NULL | | CS 전화번호 |
| `hot_yn` | char(1) | NOT NULL | 'N' | HOT 뱃지 여부 |
| `new_yn` | char(1) | NOT NULL | 'N' | NEW 뱃지 여부 |
| `hide_yn` | char(1) | NOT NULL | 'N' | 숨김 여부 |
| `use_yn` | char(1) | NOT NULL | 'Y' | 사용여부 |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `reg_id` | varchar(20) | NOT NULL | | 등록자 |
| `mod_dt` | timestamp | NULL | | 수정일시 |
| `mod_id` | varchar(20) | NULL | | 수정자 |

### shop_cart (쇼핑몰_장바구니)

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `shop_cart_seq` | int4 | NOT NULL | nextval('shop_cart_seq') | PK |
| `cont_seq` | int4 | NOT NULL | | 가맹점 SEQ (FK → mdm_cont) |
| `shop_prod_seq` | int4 | NOT NULL | | 상품 SEQ (FK → shop_prod) |
| `shop_order_qty` | numeric | NULL | 1 | 주문수량 |
| `sale_price` | numeric | NULL | | 판매가 (담을 시점 스냅샷) |
| `prod_total_amt` | numeric | NULL | | 상품 총금액 |
| `promo_store_nm` | varchar(100) | NULL | | 판촉물 매장명 (상품유형=PROMO 시 사용) |
| `promo_tel1` | varchar(500) | NULL | | 판촉물 전화1 |
| `promo_tel2` | varchar(500) | NULL | | 판촉물 전화2 |
| `sticker_cfm_no` | varchar(40) | NULL | | 스티커 확인번호 |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `reg_id` | varchar(20) | NOT NULL | | 등록자 |
| `mod_dt` | timestamp | NULL | | 수정일시 |
| `mod_id` | varchar(20) | NULL | | 수정자 |

> **설계 결정**: `shop_cart.req_note` 컬럼은 존재하지 않으며, **의도적으로 추가하지 않는다.** 이유: 요청사항은 최종 주문 단계에서 입력하는 것이 업무 흐름에 맞으며, `shop_order.req_note`·`shop_order_prod.req_note`로 충분히 처리된다.

### shop_order (쇼핑몰_주문)

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `shop_order_seq` | int4 | NOT NULL | nextval('shop_order_seq') | PK |
| `cont_seq` | int4 | NOT NULL | | 가맹점 SEQ |
| `shop_order_no` | varchar(40) | NOT NULL | | 주문번호 |
| `shop_order_dt` | timestamp | NOT NULL | | 주문일시 |
| `shop_order_sts_cd` | varchar(50) | NOT NULL | | 주문상태코드 → `SHOP_OD_STS_CD` |
| `total_amt` | numeric | NOT NULL | | 총 금액 |
| `req_note` | varchar(1000) | NULL | | 요청사항 |
| `recvr_nm` | varchar(100) | NULL | | 수령자명 |
| `recvr_mobile` | varchar(500) | NULL | | 수령자 휴대폰 |
| `recvr_tel` | varchar(500) | NULL | | 수령자 전화 |
| `recvr_email` | varchar(100) | NULL | | 수령자 이메일 |
| `recv_post_no` | varchar(10) | NOT NULL | | 배송지 우편번호 |
| `recv_addr` | varchar(200) | NOT NULL | | 배송지 주소 |
| `recv_addr_dtl` | varchar(200) | NOT NULL | | 배송지 상세주소 |
| `biz_reg_type_cd` | varchar(50) | NOT NULL | | 사업자등록 유형코드 |
| `biz_reg_fax` | varchar(40) | NULL | | 사업자 팩스 |
| `biz_reg_email` | varchar(100) | NULL | | 사업자 이메일 |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `reg_id` | varchar(20) | NOT NULL | | 등록자 |
| `mod_dt` | timestamp | NULL | | 수정일시 |
| `mod_id` | varchar(20) | NULL | | 수정자 |

### shop_order_prod (쇼핑몰_주문_상품)

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `shop_order_prod_seq` | int4 | NOT NULL | nextval('shop_order_prod_seq') | PK |
| `shop_order_seq` | int4 | NOT NULL | | 주문 SEQ (FK → shop_order) |
| `shop_prod_seq` | int4 | NOT NULL | | 상품 SEQ (FK → shop_prod) |
| `shop_cont_seq` | int4 | NOT NULL | | 제작업체 SEQ (FK → shop_cont) |
| `shop_order_qty` | numeric | NULL | 1 | 주문수량 |
| `sale_price` | numeric | NULL | | 단가 (주문 시점 스냅샷) |
| `prod_total_amt` | numeric | NULL | | 상품 총금액 |
| `delivery_amt` | numeric | NULL | | 배송비 |
| `prod_sts_cd` | varchar(50) | NULL | | 상품 진행상태 → `SHOP_PROD_STS_CD` |
| `promo_store_nm` | varchar(100) | NULL | | 판촉물 매장명 |
| `promo_tel1` | varchar(500) | NULL | | 판촉물 전화1 |
| `promo_tel2` | varchar(500) | NULL | | 판촉물 전화2 |
| `sticker_cfm_no` | varchar(40) | NULL | | 스티커 확인번호 |
| `delivery_cd` | varchar(50) | NULL | | 배송 코드 |
| `invoice_no` | varchar(30) | NULL | | 송장번호 |
| `req_note` | varchar(1000) | NULL | | 상품별 요청사항 |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `reg_id` | varchar(20) | NOT NULL | | 등록자 |
| `mod_dt` | timestamp | NULL | | 수정일시 |
| `mod_id` | varchar(20) | NULL | | 수정자 |

### shop_order_prod_sts_hist (쇼핑몰_주문_상품_상태_이력)

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `shop_order_prod_sts_hist_seq` | int4 | NOT NULL | nextval('shop_order_prod_sts_hist_seq') | PK |
| `shop_order_prod_seq` | int4 | NOT NULL | | 주문상품 SEQ (FK → shop_order_prod) |
| `prod_sts_cd` | varchar(50) | NOT NULL | | 상품 진행상태 → `SHOP_PROD_STS_CD` |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `reg_id` | varchar(20) | NOT NULL | | 등록자 |

---

## 5. 공통코드

> 공통코드 변경 없음 (신규 코드그룹 추가 없음).

### 참조 공통코드 (실 DB 확인값 — 2026-06-26)

**SHOP_PROD_TYPE_CD** — 상품 카테고리 (`shop_prod.shop_prod_type_cd`)

| comm_d_cd | comm_d_nm | use_yn |
|-----------|-----------|--------|
| `PROMO` | 판촉물 | Y |
| `FURN` | 인테리어 | Y |
| `SUB` | 부자재 | Y |
| `MAKK` | 막걸리 | Y |

**SHOP_OD_STS_CD** — 쇼핑몰 주문상태 (`shop_order.shop_order_sts_cd`)

| comm_d_cd | comm_d_nm | use_yn |
|-----------|-----------|--------|
| `11` | 주문접수 | Y |
| `22` | 주문확인 | Y |
| `33` | 시안진행 | Y |
| `44` | 시안결정 | Y |
| `55` | 제작진행 | Y |
| `66` | 배송진행 | Y |
| `77` | 거래완료 | Y |
| `99` | 주문취소 | Y |

**SHOP_PROD_STS_CD** — 쇼핑몰 상품 진행상태 (`shop_order_prod.prod_sts_cd`)

| comm_d_cd | comm_d_nm | use_yn |
|-----------|-----------|--------|
| `STS_01` | 주문접수 | Y |
| `STS_02` | 주문확인 | Y |
| `STS_03` | 시안진행 | Y |
| `STS_04` | 시안결정 | Y |
| `STS_05` | 견적진행 | Y |
| `STS_06` | 제작진행 | Y |
| `STS_07` | 제작/배송 | Y |
| `STS_08` | 배송진행 | Y |
| `STS_09` | 거래완료 | Y |
| `STS_10` | 주문취소 | Y |
| `STS_11` | 주문거절 | Y |

**SHOP_DISP_YN** — 상품 전시 여부 (`shop_prod` 관련, FE 필터용)

| comm_d_cd | comm_d_nm |
|-----------|-----------|
| `Y` | 전시 |
| `N` | 비전시 |

---

## 6. DDL SQL

> **DDL 없음** — 기존 테이블 그대로 사용. DB 반영 작업 불필요.

---

## 7. 이슈 사항

| # | 이슈 | 발견 위치 | 조치 필요 |
|---|------|-----------|-----------|
| 1 | `shop_prod_type_cd` 코드값 불일치 — FE 어딘가에서 `'FURNITURE'` 사용 시 DB 실값 `'FURN'`과 매칭 안 됨 | 이전 세션 분석 | FE 코드에서 `'FURNITURE'` → `'FURN'` 수정 필요 |
| 2 | shft01c Vue 파일 미구현 — BC 앱(`kyochon-oms-fe/src/views/bc/`) 내 shft01c 디렉토리·Vue 파일 없음 | 현재 FE 코드베이스 | FE 개발 필요 (화면설계 선행 후 `/PI_fe_all` 실행) |

---

## 8. 체크리스트

- [ ] 검토자 확인 및 서명 (검토자: __________ / 일자: __________)
- [x] DDL 없음 확인 (기존 테이블 그대로 사용)
- [x] 실 DB(dev) 스키마 직접 조회 완료 (2026-06-26)
- [ ] FE 이슈 #1 수정 완료 (`'FURNITURE'` → `'FURN'`)
- [ ] shft01c Vue 파일 구현 완료
- [ ] `/SD_api` 로 API 명세서 작성 완료
