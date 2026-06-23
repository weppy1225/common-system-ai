---
title: kyochon_oms FE axios 설정 및 URL 구조
description: FE axios interceptor가 URL에 /{bizSeq}/ prefix를 자동 삽입하는 구조. FE URL → 실제 BE URL 매핑 규칙. API 설계 시 반드시 확인.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon_oms
domain: frontend
tags:
  - axios
  - url
  - bizSeq
  - interceptor
last_verified: 2026-06-23
---

# kyochon_oms FE axios 설정 및 URL 구조

> 출처: `kyochon-oms-fe/src/assets/js/zAxios.js` (2026-06-23 확인)

---

## 핵심 규칙 — bizSeq 자동 삽입

FE의 axios request interceptor가 **모든 API 호출 URL 앞에 `/{regBizSeq}/`를 자동 삽입**한다.

```js
// zAxios.js lfn_setRegBizSeq
const regBizSeq = bizCenterStore.regBizSeq;
const url = config.url.replace(/^\//, '');
config.url = `/${regBizSeq}/${url}`;
```

| FE에서 호출 | 실제 BE 수신 URL |
|---|---|
| `axios.post('/shst01/list', ...)` | `POST /{regBizSeq}/shst01/list` |
| `axios.post('/shod01/list', ...)` | `POST /{regBizSeq}/shod01/list` |
| `axios.post('/shod01/insert', ...)` | `POST /{regBizSeq}/shod01/insert` |
| `axios.post('/shod01/admin/cancel/1', ...)` | `POST /{regBizSeq}/shod01/admin/cancel/1` |

**결론: FE 코드에서 URL 앞에 `/{bizSeq}/`를 직접 붙이지 않는다.** interceptor가 자동 처리한다.

---

## bizSeq 삽입 예외 목록

아래 URL은 `/{regBizSeq}/` 삽입을 건너뛴다 (`regBizSeqIgnoreList`).

```
/check-user
/ideatec/mfa/*
/login
/logout/*
/signup/*
/updatePwd
/send-message
```

외부 URL(`http`로 시작)도 삽입 건너뜀.

---

## regBizSeq 출처

`bizCenterStore.regBizSeq` — 로그인한 사용자의 사업장(가맹점) SEQ.

| 사용자 유형 | regBizSeq 값 |
|---|---|
| 관리자 (BE 화면) | 현재 선택된 사업장 SEQ |
| 가맹점주 (BC 화면) | 본인 가맹점 cont_seq |

BE Controller의 `@RequestMapping("/{bizSeq}/...")` PathVariable이 이 값과 대응된다.

---

## 화면별 API 매핑 (sh7000 도메인)

| 화면 | 파일 경로 | FE URL | BE Controller |
|---|---|---|---|
| 관리자 주문현황 조회 | `be/sh7000/shst01/shst01.vue` | `/shst01/list` | `SHST01Controller /list` |
| 관리자 대리 구매 등록 | `be/sh7000/shst01/shst01Reg.vue` | `/shod01/insert` | `SHOD01Controller /insert` |
| 관리자 주문 취소 | `be/sh7000/shst01/shst01.vue` | `/shod01/admin/cancel/{shopOrderSeq}` | `SHOD01Controller /admin/cancel/{shopOrderSeq}` |
| 가맹점주 구매현황 조회 | `bc/sh7000c/shst01c/shst01c.vue` | `/shod01/list` | `SHOD01Controller /list` |

---

## 검색 파라미터 필드명 매핑 (shod01)

### 가맹점주 목록 조회 (shst01c.vue → SHOD01Search)

| FE 필드명 | BE 필드명 | 설명 |
|---|---|---|
| `search.orderDtFrom` | `orderDtFrom` | 주문일 시작 |
| `search.orderDtTo` | `orderDtTo` | 주문일 종료 |
| `search.shopProdTypeCd` | `shopProdTypeCd` | 상품유형코드 |
| `search.orderNo` | `orderNo` | 주문번호 |
| `search.prodStscd` | `prodStscd` | 주문상태코드 |

### 목록 응답 필드명 매핑 (SHOD01Search → shst01c.vue)

| BE 필드명 | FE 바인딩 | 설명 |
|---|---|---|
| `shopOrderSeq` | `row.shopOrderSeq` | 주문 SEQ |
| `orderNo` | `row.orderNo` | 주문번호 |
| `prodNm` | `row.prodNm` | 상품명 |
| `qty` | `row.qty` | 주문수량 |
| `totalAmt` | `row.totalAmt` | 상품총금액 |
| `statusCd` | `row.statusCd` | 주문상태코드 (공통코드 SHOP_PROD_STS_CD) |
| `statusNm` | `row.statusNm` | 주문상태명 (commCdStore 변환 후) |
| `invoiceNo` | `row.invoiceNo` | 송장번호 |
| `recvrNm` | `row.recvrNm` | 수령자명 |
| `orderDt` | `row.orderDt` | 주문일 |

---

## 구매 등록 Request Body (shst01Reg.vue → SHOD01Order)

```js
// FE → BE 필드 매핑
{
    recvPostNo:   editObj.recvPostNo,    // shop_order.recv_post_no (NOT NULL)
    recvAddr:     editObj.recvAddr,      // shop_order.recv_addr (NOT NULL)
    recvAddrDtl:  editObj.recvAddrDtl,  // shop_order.recv_addr_dtl (NOT NULL)
    bizRegTypeCd: editObj.bizRegTypeCd, // shop_order.biz_reg_type_cd (NOT NULL, 기본 '01')
    prods: [{
        shopProdSeq:  editObj.shopProdSeq,     // shop_prod.shop_prod_seq (NOT NULL)
        shopOrderQty: editObj.qty,             // shop_order_prod.shop_order_qty
        prodTotalAmt: qty * salePrice,         // FE 계산
        promoStoreNm: editObj.storeName,       // shop_order_prod.promo_store_nm (PROMO 전용)
        promoTel1:    editObj.tel1,            // shop_order_prod.promo_tel1
        promoTel2:    editObj.tel2,            // shop_order_prod.promo_tel2
        stickerCfmNo: editObj.stickerCheckNo,  // shop_order_prod.sticker_cfm_no (SUB 전용)
        reqNote:      editObj.etc,             // shop_order_prod.req_note
    }]
}
```

---

## 주의사항

**ZProdPopup 한계**

`ZProdPopup`은 `/mdpdp01/prods`를 호출하는 **일반 품목(MDM) 팝업**이다.
쇼핑몰 상품(`shop_prod`)의 `shop_prod_seq`·`sale_price`·이미지 URL을 직접 반환하지 않는다.

현재 `shst01Reg.vue`는 ZProdPopup 콜백 후 `/shpd01/list`를 추가 조회해 shop_prod 정보를 매핑한다.
근본 해결은 쇼핑몰 상품 전용 팝업 컴포넌트(ZShopProdPopup) 신규 개발이다.

**관리자 취소 endpoint 권한 제어**

`/shod01/admin/cancel/{shopOrderSeq}`는 Spring Security 설정에서 관리자 역할(`ROLE_ADMIN` 등)로 접근 제한이 필요하다. 현재는 URL 경로만 분리된 상태다.
