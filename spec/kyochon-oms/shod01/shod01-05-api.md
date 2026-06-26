---
title: shod01 쇼핑몰 구매 API 명세서
description: shod01 쇼핑몰 구매 주문 등록·조회·취소 API 명세. PI_be_all 코드 생성 전 참조.
status: draft
version: 0.1.0
repo_role: ai-hub
agent_usage: spec
project: kyochon-oms
domain: shop
tags:
  - shod01
  - shop
  - order
  - api
last_verified: 2026-06-23
---

# shod01 쇼핑몰 구매 API 명세서
> 작성일: 2026-06-23 | 상태: 초안

---

## 1. 기본 정보

| 항목 | 내용 |
|---|---|
| 메뉴코드 | `shod01` |
| 메뉴명 | 쇼핑몰 구매 |
| 메뉴그룹 | sh7000 (쇼핑몰) |
| 패키지 | `be.sh7000.shod01` |
| URL prefix | `/{bizSeq}/shod01` |
| 관련 테이블 | `shop_order`, `shop_order_prod`, `shop_prod`, `mdm_cont` |

> `bizSeq` = 가맹점(MDM_CONT.cont_seq). URL PathVariable로 전달되며 `BaseParam`이 자동 바인딩.

---

## 2. 기능 개요

가맹점주(B2B)가 쇼핑몰 상품(판촉물·부자재·의탁자·막걸리)을 주문하는 API다.
주문 1건(`SHOP_ORDER`) + 상품 라인(1~N건, `SHOP_ORDER_PROD`)을 트랜잭션으로 저장하고, 최초 상태는 `ORDER_COMPLETE`(주문완료)로 설정한다.
주문 조회는 가맹점주 본인 주문만 반환한다(`cont_seq = bizSeq`).

---

## 3. API 목록

| Interface ID | HTTP Method | URL | 설명 |
|---|---|---|---|
| SHOD01_POST_ORDERS | POST | `/{bizSeq}/shod01/orders` | 구매 주문 목록 조회 |
| SHOD01_GET_ORDER | GET | `/{bizSeq}/shod01/orders/{shopOrderSeq}` | 구매 주문 단건 조회 |
| SHOD01_PUT_ORDER | PUT | `/{bizSeq}/shod01/orders` | 구매 주문 등록 |
| SHOD01_PATCH_CANCEL | PATCH | `/{bizSeq}/shod01/orders/{shopOrderSeq}/cancel` | 구매 주문 취소 |

---

## 4. 사용 테이블

| 테이블명 | 용도 | 주요 컬럼 |
|---|---|---|
| `shop_order` | 주문 헤더 | `shop_order_seq`, `shop_order_no`, `shop_order_dt`, `cont_seq`, `recvr_nm` |
| `shop_order_prod` | 주문 상품 라인 | `shop_order_seq`, `shop_prod_seq`, `shop_order_qty`, `prod_total_amt`, `prod_sts_cd` |
| `shop_prod` | 상품 정보 조회 | `shop_prod_seq`, `shop_prod_nm`, `shop_prod_type_cd`, `sale_price`, `use_yn` |
| `mdm_cont` | 가맹점 정보 조회 | `cont_seq`, `cont_nm`, `use_yn` |

> `shop_order`, `shop_order_prod` 전체 컬럼은 실 DB `\d shop_order` 확인 필요 (미확인 컬럼 있을 수 있음).

---

## 5. API 상세

### 5-1. 구매 주문 목록 조회

```
POST /{bizSeq}/shod01/orders
```

**Request Body — SHOD01Search**

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `bizSeq` | Integer | Y | 가맹점 SEQ (URL PathVariable → BaseParam 자동 바인딩) |
| `orderDtFrom` | String | N | 주문일 시작 (yyyyMMdd) |
| `orderDtTo` | String | N | 주문일 종료 (yyyyMMdd) |
| `shopProdTypeCd` | String | N | 상품유형코드 (`PROMO`·`SUB`·`FURN`·`MAKK`) |
| `prodStscd` | String | N | 주문상태코드 (`SHOP_ORDER_STS` 공통코드) |

**Response Body — SHOD01Response**

```json
{
  "orderList": [
    {
      "shopOrderSeq": 1,
      "orderNo": "ORD20260623001",
      "orderDt": "20260623",
      "prodTypeCd": "PROMO",
      "prodDiv": "판촉물",
      "prodNm": "A4 전단지",
      "qty": 100,
      "totalAmt": 50000,
      "statusCd": "ORDER_COMPLETE",
      "statusNm": "주문완료"
    }
  ]
}
```

**SQL 기준** — `SHST01Mapper.searchOrders` 와 동일 조인 구조에 `cont_seq = #{bizSeq}` 조건 추가.

---

### 5-2. 구매 주문 단건 조회

```
GET /{bizSeq}/shod01/orders/{shopOrderSeq}
```

**Path Variable**

| 필드 | 타입 | 설명 |
|---|---|---|
| `shopOrderSeq` | Integer | 주문 SEQ |

**Response Body — SHOD01Response**

```json
{
  "order": {
    "shopOrderSeq": 1,
    "orderNo": "ORD20260623001",
    "orderDt": "20260623",
    "recvrNm": "홍길동",
    "prods": [
      {
        "shopOrderProdSeq": 1,
        "shopProdSeq": 10,
        "prodNm": "A4 전단지",
        "qty": 100,
        "unitPrice": 500,
        "totalAmt": 50000,
        "statusCd": "ORDER_COMPLETE"
      }
    ]
  }
}
```

---

### 5-3. 구매 주문 등록

```
PUT /{bizSeq}/shod01/orders
```

**Request Body — SHOD01Order**

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `recvrNm` | String | Y | 수령자명 (`shop_order.recvr_nm`) |
| `prods` | List | Y | 주문 상품 목록 (1건 이상) |
| `prods[].shopProdSeq` | Integer | Y | 상품 SEQ |
| `prods[].qty` | BigDecimal | Y | 주문수량 |
| `prods[].totalAmt` | BigDecimal | Y | 상품총금액 (FE에서 qty × salePrice 계산 후 전달) |

**처리 흐름**

```
1. shop_order INSERT → shop_order_seq 채번
2. prods 목록 반복 → shop_order_prod INSERT (prod_sts_cd = 'ORDER_COMPLETE')
3. 트랜잭션 커밋
```

**비즈니스 규칙**
- `prods` 가 비어 있으면 등록 거부 (`CompWarnException`)
- 각 `shopProdSeq` 의 `use_yn = 'Y'` 검증 (미사용 상품 주문 거부)
- `totalAmt` 는 FE 계산값을 저장. 서버 측 재계산은 미구현(추후 정책 확정 후 추가).

---

### 5-4. 구매 주문 취소

```
PATCH /{bizSeq}/shod01/orders/{shopOrderSeq}/cancel
```

**Path Variable**

| 필드 | 타입 | 설명 |
|---|---|---|
| `shopOrderSeq` | Integer | 취소할 주문 SEQ |

**처리 흐름**

```
1. shop_order 존재 + cont_seq = bizSeq 검증
2. shop_order_prod.prod_sts_cd 가 'ORDER_COMPLETE' 인지 확인 (이미 진행된 주문 취소 거부)
3. shop_order_prod.prod_sts_cd = 'CANCEL' 업데이트
```

**비즈니스 규칙**
- 본인 주문(`cont_seq = bizSeq`)만 취소 가능
- `prod_sts_cd = 'ORDER_COMPLETE'` 상태만 취소 가능. 이외 상태는 `CompWarnException`

---

## 6. Bean 설계

### SHOD01Response
```java
extends ResponseData
- List<SHOD01Search> orderList  // 목록 조회 결과
- SHOD01Order       order       // 단건 조회 결과
```

### SHOD01Search (검색조건 + 목록 결과)
```java
extends BaseParam
// 검색조건
- String  orderDtFrom    // 주문일 시작
- String  orderDtTo      // 주문일 종료
- String  shopProdTypeCd // 상품유형코드
- String  prodStscd      // 주문상태코드

// 목록 결과
- Integer    shopOrderSeq // 주문 SEQ
- String     orderNo      // 주문번호
- String     orderDt      // 주문일
- String     prodTypeCd   // 상품유형코드
- String     prodDiv      // 상품유형명
- String     prodNm       // 상품명
- BigDecimal qty          // 주문수량
- BigDecimal totalAmt     // 상품총금액
- String     statusCd     // 주문상태코드
- String     statusNm     // 주문상태명
```

### SHOD01Order (등록·단건조회 DTO)
```java
implements Serializable
- Integer          shopOrderSeq  // 주문 SEQ (단건조회 응답용)
- String           orderNo       // 주문번호
- String           orderDt       // 주문일
- String           recvrNm       // 수령자명
- List<SHOD01OrderProd> prods   // 주문 상품 목록
```

### SHOD01OrderProd (주문 상품 라인)
```java
implements Serializable
- Integer    shopOrderProdSeq // 주문상품 SEQ
- Integer    shopProdSeq      // 상품 SEQ
- String     prodNm           // 상품명 (조회용)
- BigDecimal qty              // 주문수량
- BigDecimal unitPrice        // 단가 (조회용)
- BigDecimal totalAmt         // 상품총금액
- String     statusCd         // 주문상태코드
```

---

## 7. 공통코드 참조

| 공통코드 헤더 | 설명 | 사용 필드 |
|---|---|---|
| `SHOP_ORDER_STS` | 쇼핑몰 주문상태 | `prod_sts_cd` |
| `SHOP_PROD_TYPE` | 쇼핑몰 상품유형 | `shop_prod_type_cd` |

**SHOP_ORDER_STS 값**

| 코드 | 코드명 |
|---|---|
| `ORDER_COMPLETE` | 주문완료 (초기값) |
| `DESIGN` | 시안진행 |
| `PRODUCTION` | 제작진행 |
| `SHIPPING` | 배송진행 |
| `DONE` | 거래완료 |
| `CANCEL` | 주문취소 |

---

## 8. 미확인 사항

| 항목 | 내용 | 해결 방법 |
|---|---|---|
| `shop_order` 전체 컬럼 | recvr_nm 외 배송지·연락처 등 컬럼 존재 여부 | `\d shop_order` 실행 후 확인 |
| `shop_order_prod` 전체 컬럼 | 추가 필드 여부 | `\d shop_order_prod` 실행 후 확인 |
| `shop_order_no` 채번 규칙 | 자동 SEQUENCE인지 별도 채번 로직인지 | DB SEQUENCE 또는 기존 채번 패턴 확인 |
| `totalAmt` 서버 재계산 여부 | FE 전달값 신뢰 vs 서버 재계산 | 정책 결정 필요 |

---

## 9. 관련 문서

- 주문 현황(관리자): `be.sh7000.shst01` — `SHST01Mapper.xml`
- 상품 관리: `be.sh7000.shpd01` — INSERT 패턴 참조
- 공통코드: `spec/kyochon-oms/_knowledge/db-schema/90-common-code.md`
- 쇼핑몰 테이블: `spec/kyochon-oms/_knowledge/db-schema/03-shop-tables.md`
