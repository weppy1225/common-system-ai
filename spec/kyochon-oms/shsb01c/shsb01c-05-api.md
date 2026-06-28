---
title: shsb01c 부자재구매 — API 명세서 (전체)
description: 부자재 상품목록 조회·상세 조회·장바구니 CRUD·주문 등록·배송조회·주문취소 전체 API 명세
status: draft
version: 2.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: spec
tags:
  - shsb01c
  - shpp01c
  - api-spec
  - kyochon-oms
related:
  - spec/kyochon-oms/shsb01c/shsb01c-03-data-model.md
---

# shsb01c 부자재구매 API 명세서

> 작성일: 2026-06-24 | 작성자: binaryarc | 상태: 초안 (v2.0 — 전체 API 추가)

---

## 1. 기본 정보

| 항목 | 내용 |
|---|---|
| 메뉴코드 | `shsb01c` |
| 메뉴명 | 부자재구매 (쇼핑몰 가맹점용) |
| 메뉴그룹 | `sh7000c` |
| 패키지 | `be.sh7000.shsb01/` |
| URL prefix | `/{bizSeq}/shsb01` |
| 화면 타입 | 쇼핑몰(`/bc`) — AUIGrid 미사용 |
| 공유 화면 | `shppCart.vue`, `shppOrderForm.vue` (`shpp01c` 폴더 — 판촉물과 공유) |

> `bizSeq` = 가맹점 SEQ. axios가 로그인 사용자의 가맹점 SEQ를 path에 자동 삽입한다.

> 장바구니·주문 관련 신규 테이블(`SHOP_CART`, `SHOP_CART_PROD`)은 DB 설계(`shsb01c-03-data-model.md`) 업데이트 필요. 현재 **미확인:** 테이블 존재 여부.

---

## 2. 기능 개요

가맹점이 부자재 상품을 조회하고 구매하는 전체 흐름:

```
상품목록(shsb01c.vue)
  → 상품상세(shsb01cDtl.vue): 장바구니 추가 / 바로구매
  → 장바구니(shppCart.vue): 수량 수정, 삭제, 주문하기
  → 주문폼(shppOrderForm.vue): 배송지 입력, 주문완료
  → 배송조회(shsb01cDelivery.vue): 주문목록, 취소
```

---

## 3. API 목록

| # | Interface ID | Method | URL | 설명 |
|---|---|---|---|---|
| 1 | SHSB01C_POST_PRODUCTS | POST | `/{bizSeq}/shsb01/products` | 부자재 상품 목록 조회 (카테고리 포함) |
| 2 | SHSB01C_GET_PRODUCT_DTL | GET | `/{bizSeq}/shsb01/products/{shopProdSeq}` | 부자재 상품 상세 조회 |
| 3 | SHSB01C_POST_CART_LIST | POST | `/{bizSeq}/shsb01/cart/list` | 장바구니 목록 조회 |
| 4 | SHSB01C_POST_CART_ADD | POST | `/{bizSeq}/shsb01/cart` | 장바구니 상품 추가 |
| 5 | SHSB01C_POST_CART_UPDATE | POST | `/{bizSeq}/shsb01/cart/update` | 장바구니 수량 수정 |
| 6 | SHSB01C_POST_CART_DELETE | POST | `/{bizSeq}/shsb01/cart/delete` | 장바구니 상품 삭제 |
| 7 | SHSB01C_POST_ORDER | POST | `/{bizSeq}/shsb01/orders` | 주문 등록 |
| 8 | SHSB01C_POST_LIST | POST | `/{bizSeq}/shsb01/list` | 배송조회 — 내 부자재 주문목록 |
| 9 | SHSB01C_POST_CANCEL | POST | `/{bizSeq}/shsb01/cancel/{shopOrderSeq}` | 주문취소 (`STS_01` 상태만) |

---

## 4. API 상세

### 4-1. 부자재 상품 목록 조회

**Interface ID**: `SHSB01C_POST_PRODUCTS`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/products` |
| Controller | `SHSB01Controller.searchProducts` |
| Comp | `SHSB01Comp.searchProducts` |
| Mapper | `SHSB01Mapper.searchProducts` |
| 화면 | `shsb01c.vue` — 탭별 상품 목록 (`tabProducts` 대체) |

**Request Body**

```json
{
  "shopProdTypeCd":    "SUB",
  "shopProdCategoryCd": ""
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `shopProdTypeCd` | String | 고정 `"SUB"` | 부자재 필터 — Controller에서 고정값 주입 가능 |
| `shopProdCategoryCd` | String | 선택 | 카테고리 코드 필터 (`""` = 전체) |

**Response Body**

```json
{
  "result": "S",
  "categories": [
    { "shopProdCategoryCd": "AUTOBOX", "shopProdCategoryNm": "오토박스" },
    { "shopProdCategoryCd": "SUBSUP",  "shopProdCategoryNm": "부자재"  }
  ],
  "productList": [
    {
      "shopProdSeq":         1,
      "shopProdNm":          "22년등받이_오토박스",
      "shopProdDescription": "22년등받이 오토박스",
      "salePrice":           12870,
      "shopProdCategoryCd":  "AUTOBOX",
      "shopProdCategoryNm":  "오토박스",
      "hotYn": "N",
      "newYn": "N",
      "useYn": "Y"
    }
  ]
}
```

> `categories`는 해당 `shop_prod_type_cd = 'SUB'` 상품에 등록된 카테고리만 distinct 반환한다.
> `shopProdCategoryNm`은 `SM_COMM_D` (`comm_h_cd = 'SHOP_PROD_CTGR'`)에서 JOIN해 반환한다. FE `commCdStore` 경유 변환과 이중화되지 않도록, BE에서 JOIN 후 반환한다.

| 응답 필드 | 컬럼 | 설명 |
|---|---|---|
| `categories[].shopProdCategoryCd` | `SHOP_PROD.shop_prod_category_cd` | 탭 코드값 (`SHOP_PROD_CTGR`) |
| `categories[].shopProdCategoryNm` | `SM_COMM_D.comm_d_nm` (`SHOP_PROD_CTGR`) | 탭 표시명 (예: 오토박스, 부자재) |
| `shopProdSeq` | `SHOP_PROD.shop_prod_seq` | 상품 SEQ (상세 이동 키) |
| `shopProdNm` | `SHOP_PROD.shop_prod_nm` | 상품명 |
| `shopProdDescription` | `SHOP_PROD.shop_prod_description` | 상품 설명 |
| `salePrice` | `SHOP_PROD.sale_price` | 단가 (VAT 포함) |
| `shopProdCategoryCd` | `SHOP_PROD.shop_prod_category_cd` | 카테고리 코드 (`SHOP_PROD_CTGR`) |
| `shopProdCategoryNm` | `SM_COMM_D.comm_d_nm` | 카테고리 표시명 |
| `hotYn` | `SHOP_PROD.hot_yn` | HOT 배지 (`Y`/`N`) |
| `newYn` | `SHOP_PROD.new_yn` | NEW 배지 (`Y`/`N`) |

---

### 4-2. 부자재 상품 상세 조회

**Interface ID**: `SHSB01C_GET_PRODUCT_DTL`

| 항목 | 내용 |
|---|---|
| Method | GET |
| URL | `/{bizSeq}/shsb01/products/{shopProdSeq}` |
| Controller | `SHSB01Controller.getProduct` |
| Comp | `SHSB01Comp.getProduct` |
| Mapper | `SHSB01Mapper.selectProduct` |
| 화면 | `shsb01cDtl.vue` — route query 대체, 단가·상품정보 서버 조회 |

**Path Variable**

| 파라미터 | 타입 | 설명 |
|---|---|---|
| `bizSeq` | Integer | 가맹점 SEQ |
| `shopProdSeq` | Integer | 상품 SEQ |

**Response Body**

```json
{
  "result": "S",
  "product": {
    "shopProdSeq":         1,
    "shopProdNm":          "22년등받이_오토박스",
    "shopProdDescription": "22년등받이 오토박스",
    "salePrice":           12870,
    "shopProdCategoryCd":  "AUTOBOX",
    "shopProdCategoryNm":  "오토박스",
    "shopProdTypeCd":      "SUB",
    "detailFileSeq":       101,
    "acctNo":              "76743701009655",
    "bankNm":              "국민은행",
    "csTel":               "031-332-5700"
  }
}
```

| 응답 필드 | 컬럼 | 설명 |
|---|---|---|
| `shopProdSeq` | `SHOP_PROD.shop_prod_seq` | 상품 SEQ |
| `shopProdNm` | `SHOP_PROD.shop_prod_nm` | 상품명 |
| `shopProdDescription` | `SHOP_PROD.shop_prod_description` | 상품 설명 |
| `salePrice` | `SHOP_PROD.sale_price` | 단가 (VAT 포함) |
| `shopProdCategoryCd` | `SHOP_PROD.shop_prod_category_cd` | 카테고리 코드 (`SHOP_PROD_CTGR`) |
| `shopProdCategoryNm` | `SM_COMM_D.comm_d_nm` (`SHOP_PROD_CTGR`) | 카테고리명 |
| `detailFileSeq` | `SHOP_PROD.detail_file_seq` | 상세정보 이미지 파일 SEQ (`제품상세정보` 영역) |
| `acctNo` | `SHOP_PROD.acct_no` | 업체 계좌번호 |
| `bankNm` | `SHOP_PROD.bank_nm` | 은행명 |
| `csTel` | `SHOP_PROD.cs_tel` | 고객센터 전화번호 |

**오류 케이스**

| 조건 | result | 메시지 |
|---|---|---|
| `use_yn = 'N'` 또는 미존재 | `"W"` | "존재하지 않는 상품입니다" |

---

### 4-3. 장바구니 목록 조회

**Interface ID**: `SHSB01C_POST_CART_LIST`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/cart/list` |
| Controller | `SHSB01Controller.searchCart` |
| Comp | `SHSB01Comp.searchCart` |
| Mapper | `SHSB01Mapper.searchCartItems` |
| 화면 | `shppCart.vue` — 하드코딩 items 대체 |

> **미확인:** `SHOP_CART`, `SHOP_CART_PROD` 테이블 존재 여부 확인 필요 (`shsb01c-03-data-model.md` 업데이트 선행).

**Request Body**: `{}` (빈 body — `bizSeq`는 path에서 주입)

**Response Body**

```json
{
  "result": "S",
  "cartList": [
    {
      "shopCartProdSeq": 10,
      "shopProdSeq":         1,
      "shopProdNm":          "22년등받이_오토박스",
      "shopProdCategoryCd":  "AUTOBOX",
      "shopProdCategoryNm":  "오토박스",
      "shopOrderQty":        2,
      "salePrice":           12870,
      "prodTotalAmt":        25740
    }
  ]
}
```

| 응답 필드 | 컬럼 | 설명 |
|---|---|---|
| `shopCartProdSeq` | `SHOP_CART_PROD.shop_cart_prod_seq` | 장바구니 라인 SEQ (수정/삭제 키) |
| `shopProdSeq` | `SHOP_CART_PROD.shop_prod_seq` | 상품 SEQ |
| `shopProdNm` | `SHOP_PROD.shop_prod_nm` | 상품명 |
| `shopProdCategoryCd` | `SHOP_PROD.shop_prod_category_cd` | 카테고리 코드 (`SHOP_PROD_CTGR`) |
| `shopProdCategoryNm` | `SM_COMM_D.comm_d_nm` (`SHOP_PROD_CTGR`) | 카테고리명 (spec1 표시) |
| `shopOrderQty` | `SHOP_CART_PROD.shop_order_qty` | 수량 |
| `salePrice` | `SHOP_PROD.sale_price` | 단가 |
| `prodTotalAmt` | 계산값 | 수량 × `sale_price` |

---

### 4-4. 장바구니 상품 추가

**Interface ID**: `SHSB01C_POST_CART_ADD`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/cart` |
| Controller | `SHSB01Controller.addCart` |
| TxComp | `SHSB01TxComp.addCart` |
| Mapper | `SHSB01Mapper.insertCartProd` / `SHSB01Mapper.updateCartQty` |
| 화면 | `shsb01cDtl.vue` — 장바구니 버튼, 바로구매 버튼 |

**Request Body**

```json
{
  "shopProdSeq": 1,
  "shopOrderQty": 2,
  "confirmNo": "12345",
  "extraRequest": "배송 전 연락 요망"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `shopProdSeq` | Integer | 필수 | 담을 상품 SEQ |
| `shopOrderQty` | Integer | 필수 | 수량 (1 이상) |
| `confirmNo` | String | 선택 | 스티커 삽입 전 확인번호 (`shsb01cDtl.vue` 입력 필드) |
| `extraRequest` | String | 선택 | 기타요구 입력값 |

**Response Body**

```json
{ "result": "S" }
```

**비즈니스 규칙**

- 동일 `shopProdSeq`가 이미 장바구니에 있으면 수량 합산(`UPDATE`).
- 없으면 신규 라인 추가(`INSERT`).

---

### 4-5. 장바구니 수량 수정

**Interface ID**: `SHSB01C_POST_CART_UPDATE`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/cart/update` |
| Controller | `SHSB01Controller.updateCart` |
| TxComp | `SHSB01TxComp.updateCart` |
| Mapper | `SHSB01Mapper.updateCartQty` |
| 화면 | `shppCart.vue` — 수량 +/- 버튼 |

**Request Body**

```json
{
  "shopCartProdSeq": 10,
  "shopOrderQty": 3
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `shopCartProdSeq` | Integer | 필수 | 장바구니 라인 SEQ |
| `shopOrderQty` | Integer | 필수 | 변경할 수량 (1 이상) |

**Response Body**: `{ "result": "S" }`

---

### 4-6. 장바구니 상품 삭제

**Interface ID**: `SHSB01C_POST_CART_DELETE`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/cart/delete` |
| Controller | `SHSB01Controller.deleteCart` |
| TxComp | `SHSB01TxComp.deleteCart` |
| Mapper | `SHSB01Mapper.deleteCartProds` |
| 화면 | `shppCart.vue` — ✕ 버튼(단건), 선택 삭제(다건) |

**Request Body**

```json
{
  "shopCartProdSeqs": [10, 11]
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `shopCartProdSeqs` | List\<Integer\> | 필수 | 삭제할 장바구니 라인 SEQ 목록 |

**Response Body**: `{ "result": "S" }`

---

### 4-7. 주문 등록

**Interface ID**: `SHSB01C_POST_ORDER`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/orders` |
| Controller | `SHSB01Controller.insertOrder` |
| TxComp | `SHSB01TxComp.insertOrder` |
| Mapper | `SHSB01Mapper.insertOrder` / `SHSB01Mapper.insertOrderProds` |
| 화면 | `shppOrderForm.vue` — 주문완료 버튼 (`submitOrder` 대체) |

**Request Body**

```json
{
  "rcvrNm":         "홍길동",
  "rcvrMobile":     "010-1234-5678",
  "rcvrTel":        "031-123-4567",
  "rcvrEmail":      "test@kyochon.com",
  "rcvrZipcode":    "12345",
  "rcvrAddr1":      "경기도 수원시 팔달구",
  "rcvrAddr2":      "101호",
  "bizMethodCd":    "EMAIL",
  "shopCartProdSeqs": [10, 11]
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `rcvrNm` | String | 필수 | 수령자 이름 |
| `rcvrMobile` | String | 필수 | 수령자 휴대폰 |
| `rcvrTel` | String | 선택 | 수령자 전화번호 |
| `rcvrEmail` | String | 선택 | 수령자 이메일 |
| `rcvrZipcode` | String | 필수 | 우편번호 |
| `rcvrAddr1` | String | 필수 | 기본 주소 |
| `rcvrAddr2` | String | 선택 | 상세 주소 |
| `bizMethodCd` | String | 필수 | 사업자등록증 제출방법 (`FAX` / `EMAIL`) |
| `shopCartProdSeqs` | List\<Integer\> | 필수 | 주문할 장바구니 라인 SEQ 목록 |

**Response Body**

```json
{
  "result": "S",
  "shopOrderNo": "20260624-123456"
}
```

| 응답 필드 | 설명 |
|---|---|
| `shopOrderNo` | 주문번호 — `shppOrderComplete.vue`의 `orderNo` query param으로 전달 |

**비즈니스 규칙**

1. `SHOP_ORDER` 헤더 INSERT + `SHOP_ORDER_PROD` 라인 INSERT (장바구니 라인별 1건).
2. `SHOP_ORDER.shop_order_sts_cd = 'ACTIVE'`, `SHOP_ORDER_PROD.prod_sts_cd = 'STS_01'`(주문접수) 초기값.
3. 주문번호(`shop_order_no`) = `DocNoGenerator` 또는 `YYYYMMDD-시퀀스` 규칙 — `03-numbering-module.md` 확인.
4. 주문 완료 후 해당 `SHOP_CART_PROD` 라인 삭제 (장바구니 자동 비우기).
5. `SHOP_PROD.use_yn = 'Y'` 아닌 상품이 포함되면 `"W"` 응답.

---

### 4-8. 배송조회 — 내 부자재 주문목록

**Interface ID**: `SHSB01C_POST_LIST`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/list` |
| 화면 | `shsb01cDelivery.vue` — `axios.post('/shsb01/list', {})` |

**Request Body**: `{}` (빈 body)

**Response Body**

```json
{
  "result": "S",
  "orderList": [
    {
      "shopOrderSeq":  1,
      "shopOrderDt":   "20260513",
      "prodNm":        "치킨박스_소",
      "shopOrderQty":  3,
      "prodTotalAmt":  54000,
      "prodStsCd":     "STS_01"
    }
  ]
}
```

> 쿼리 설계: `shsb01c-03-data-model.md §7-1 searchSubOrders` 참조.

---

### 4-9. 주문취소

**Interface ID**: `SHSB01C_POST_CANCEL`

| 항목 | 내용 |
|---|---|
| Method | POST |
| URL | `/{bizSeq}/shsb01/cancel/{shopOrderSeq}` |
| 화면 | `shsb01cDelivery.vue` — 주문취소 버튼 |

**취소 가능 조건**: `prod_sts_cd = 'STS_01'` (주문접수) 상태만

**Response Body**

```json
{ "result": "S" }
```

| 상태 | result | 설명 |
|---|---|---|
| 성공 | `"S"` | `shop_order_sts_cd = 'CANCEL'`, `prod_sts_cd = 'STS_10'` 업데이트 |
| 상태불일치 | `"W"` + warn 메시지 | "주문접수 상태의 주문만 취소할 수 있습니다" |
| 소유권불일치 | `"W"` + warn 메시지 | "본인의 주문만 취소할 수 있습니다" |

---

## 5. 사용 테이블

| 테이블명 | 용도 | 확인 상태 |
|---|---|---|
| `SHOP_PROD` | 상품 마스터 | 확인 (`shop_prod_type_cd = 'SUB'` 필터) |
| `SHOP_ORDER` | 주문 헤더 | 확인 |
| `SHOP_ORDER_PROD` | 주문 상품 라인 | 확인 |
| `SM_COMM_D` | 공통코드 변환 | 확인 — `SHOP_PROD_STS_CD`(상태명), `SHOP_PROD_CTGR`(카테고리명) |
| `SHOP_CART` | 장바구니 헤더 | **미확인 — `shsb01c-03-data-model.md` 업데이트 필요** |
| `SHOP_CART_PROD` | 장바구니 상품 라인 | **미확인 — `shsb01c-03-data-model.md` 업데이트 필요** |

---

## 6. Bean 설계

### SHSB01Response

```java
// extends ResponseData
- List<String>       categories   // 탭 목록 (4-1)
- List<SHSB01Prod>   productList  // 상품 목록 (4-1)
- SHSB01ProdDtl      product      // 상품 상세 (4-2)
- List<SHSB01Cart>   cartList     // 장바구니 목록 (4-3)
- List<SHSB01Search> orderList    // 주문목록 (4-8)
- String             shopOrderNo  // 주문번호 (4-7)
```

### SHSB01Prod (상품 목록 결과)

```java
implements Serializable
- Integer    shopProdSeq
- String     shopProdNm
- String     shopProdDescription   // SHOP_PROD.shop_prod_description
- BigDecimal salePrice             // SHOP_PROD.sale_price
- String     shopProdCategoryCd   // SHOP_PROD.shop_prod_category_cd (SHOP_PROD_CTGR)
- String     shopProdCategoryNm   // SM_COMM_D.comm_d_nm (SHOP_PROD_CTGR JOIN)
- String     hotYn
- String     newYn
```

### SHSB01ProdDtl (상품 상세 결과)

```java
implements Serializable
- Integer    shopProdSeq
- String     shopProdNm
- String     shopProdDescription   // SHOP_PROD.shop_prod_description
- BigDecimal salePrice             // SHOP_PROD.sale_price
- String     shopProdCategoryCd   // SHOP_PROD.shop_prod_category_cd (SHOP_PROD_CTGR)
- String     shopProdCategoryNm   // SM_COMM_D.comm_d_nm (SHOP_PROD_CTGR JOIN)
- Integer    detailFileSeq         // SHOP_PROD.detail_file_seq (상세이미지 파일 SEQ)
- String     acctNo                // SHOP_PROD.acct_no
- String     bankNm                // SHOP_PROD.bank_nm
- String     csTel                 // SHOP_PROD.cs_tel
```

### SHSB01Cart (장바구니 항목)

```java
implements Serializable
- Integer    shopCartProdSeq
- Integer    shopProdSeq
- String     shopProdNm
- String     shopProdCategoryCd   // SHOP_PROD.shop_prod_category_cd (SHOP_PROD_CTGR)
- String     shopProdCategoryNm   // SM_COMM_D.comm_d_nm (SHOP_PROD_CTGR JOIN)
- Integer    shopOrderQty
- BigDecimal salePrice             // SHOP_PROD.sale_price
- BigDecimal prodTotalAmt          // 수량 × sale_price
```

### SHSB01CartParam (장바구니 파라미터)

```java
extends BaseParam
- Integer        bizSeq
- Integer        shopProdSeq
- Integer        shopCartProdSeq
- List<Integer>  shopCartProdSeqs
- Integer        shopOrderQty
- String         confirmNo
- String         extraRequest
```

### SHSB01OrderParam (주문 등록 파라미터)

```java
extends BaseParam
- Integer        bizSeq
- String         rcvrNm
- String         rcvrMobile
- String         rcvrTel
- String         rcvrEmail
- String         rcvrZipcode
- String         rcvrAddr1
- String         rcvrAddr2
- String         bizMethodCd
- List<Integer>  shopCartProdSeqs
```

### SHSB01Search (배송조회 파라미터 + 결과)

```java
extends BaseParam
- Integer    bizSeq
// 결과
- Integer    shopOrderSeq
- String     shopOrderDt
- String     prodNm
- Integer    shopOrderQty
- BigDecimal prodTotalAmt
- String     prodStsCd
```

---

## 7. 비즈니스 규칙

1. **부자재 필터**: 상품 관련 API는 항상 `SHOP_PROD.shop_prod_type_cd = 'SUB'` 조건 포함.
2. **소유권 검증**: 장바구니·주문 조회/수정/삭제는 `cont_seq = bizSeq` 확인.
3. **취소 가능 조건**: `prod_sts_cd = 'STS_01'`(주문접수)만.
4. **부자재 상태 흐름**: `STS_01` → `STS_02` → `STS_06` → `STS_07` → `STS_08` → `STS_09` (취소: `STS_10`, 거절: `STS_11`).
5. **시안 관련 상태 미노출**: `STS_03`·`STS_04`·`STS_05` — 판촉물 전용, 부자재 화면 표시 불필요.
6. **장바구니 중복 처리**: 동일 `shopProdSeq` 추가 시 수량 합산.
7. **주문 후 장바구니 자동 삭제**: `insertOrder` 트랜잭션 안에서 `SHOP_CART_PROD` 라인 삭제.

---

## 8. 유효성 검증

| 검증 항목 | 방법 | 오류 메시지 |
|---|---|---|
| 상품 유효성 | `SHOP_PROD.use_yn = 'Y'` 확인 | "존재하지 않는 상품입니다" |
| 장바구니 소유권 | `SHOP_CART.cont_seq = bizSeq` | "접근 권한이 없습니다" |
| 주문 소유권 | `SHOP_ORDER.cont_seq = bizSeq` | "본인의 주문만 취소할 수 있습니다" |
| 취소 가능 상태 | `prod_sts_cd = 'STS_01'` | "주문접수 상태의 주문만 취소할 수 있습니다" |
| 주문 필수값 | `rcvrNm`, `rcvrMobile`, `rcvrZipcode`, `rcvrAddr1` | "필수 항목을 입력해 주세요" |
| 수량 범위 | `shopOrderQty >= 1` | "수량은 1 이상이어야 합니다" |

---

## 9. 관련 문서

- DB 설계: `spec/kyochon-oms/shsb01c/shsb01c-03-data-model.md` (장바구니 테이블 추가 필요)
- FE 상품목록: `kyochon-oms-fe/src/views/bc/sh7000c/shsb01c/shsb01c.vue`
- FE 상품상세: `kyochon-oms-fe/src/views/bc/sh7000c/shsb01c/shsb01cDtl.vue`
- FE 장바구니: `kyochon-oms-fe/src/views/bc/sh7000c/shpp01c/shppCart.vue`
- FE 주문폼: `kyochon-oms-fe/src/views/bc/sh7000c/shpp01c/shppOrderForm.vue`
- FE 배송조회: `kyochon-oms-fe/src/views/bc/sh7000c/shsb01c/shsb01cDelivery.vue`
- FE 장바구니 스토어: `kyochon-oms-fe/src/stores/shppCartStore.js`
- 참조 패턴: `kyochon-oms-be/src/main/java/be/sh7000/shod01/SHOD01Mapper.xml`
