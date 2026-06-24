---
title: shsb01c 부자재구매 — DB 설계 (배송조회 주문목록 컴포넌트)
description: shppDelivery 배송조회 화면에서 사용할 부자재(shsb01c) 주문목록 컴포넌트의 DB 설계 문서
status: draft
version: 1.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: spec
tags:
  - shsb01c
  - shppDelivery
  - db-design
  - kyochon-oms
---

# shsb01c 부자재구매 DB 설계 (배송조회 주문목록 컴포넌트)

> 작성일: 2026-06-24 | 상태: 초안
> 참조 소스: `kyochon-oms-be/src/main/java/be/sh7000/shod01/SHOD01Mapper.xml`
> 검토자: | 승인일자: | 승인여부: [ ] 승인대기 / [ ] 승인완료

---

## 1. 변경 요약

| 구분 | 대상 | 내용 |
|---|---|---|
| 변경없음 | — | DDL 없음. 기존 테이블(`SHOP_ORDER`, `SHOP_ORDER_PROD`, `SHOP_PROD`)로 조회 가능 |

> **부자재 주문은 `SHOP_PROD.shop_prod_type_cd = 'SUB'` 필터만 추가하면 기존 테이블로 목록 조회 가능.**
> 신규 테이블·컬럼 추가 없음.

---

## 2. 사용 테이블

| 테이블명 | 판정 | 역할 |
|---|---|---|
| `SHOP_ORDER` | 기존 | 주문 헤더 (주문번호·주문일시·주문상태·수령자 정보) |
| `SHOP_ORDER_PROD` | 기존 | 주문 상품 라인 (수량·금액·진행상태코드·취소 여부) |
| `SHOP_PROD` | 기존 | 상품 마스터 — `shop_prod_type_cd = 'SUB'`(부자재)로 필터 |
| `SM_COMM_D` | 기존 | 공통코드 명칭 변환 (`SHOP_PROD_STS_CD` 코드그룹) |

---

## 3. 신규 테이블 명세

> 신규 테이블 없음 — 이 섹션 생략.

---

## 4. 기존 테이블 컬럼 추가

> 컬럼 추가 없음 — 이 섹션 생략.

---

## 5. 공통코드

### 5-1. 기존 코드그룹 사용 확인 (`SHOP_PROD_STS_CD`)

**근거**: `SHOD01Mapper.xml` — `SM_COMM_D.comm_h_cd = 'SHOP_PROD_STS_CD'` 조인 확인됨.
**DB 직접 조회 확인** (dev DB, 2026-06-24):

| comm_d_cd | comm_d_nm | disp_no | 부자재 사용 여부 |
|---|---|---|---|
| `STS_01` | 주문접수 | 1 | 사용 |
| `STS_02` | 주문확인 | 2 | 사용 |
| `STS_03` | 시안진행 | 3 | 미사용 (판촉물 전용) |
| `STS_04` | 시안결정 | 4 | 미사용 (판촉물 전용) |
| `STS_05` | 견적진행 | 5 | 미사용 (판촉물 전용) |
| `STS_06` | 제작진행 | 6 | 사용 |
| `STS_07` | 제작/배송 | 7 | 사용 |
| `STS_08` | 배송진행 | 8 | 사용 |
| `STS_09` | 거래완료 | 9 | 사용 |
| `STS_10` | 주문취소 | 10 | 사용 |
| `STS_11` | 주문거절 | 11 | 사용 |

**부자재 주문 상태 흐름**: `STS_01` → `STS_02` → `STS_06` → `STS_07` → `STS_08` → `STS_09` (취소: `STS_10`, 거절: `STS_11`)
- 시안 관련 상태(`STS_03` 시안진행, `STS_04` 시안결정, `STS_05` 견적진행)는 판촉물 전용 흐름이므로 부자재 화면에서 표시 불필요.

---

## 6. DDL SQL

> DDL 없음 — 기존 테이블 그대로 사용.

---

## 7. 조회 쿼리 설계 (Mapper 신규 메서드 기준)

**배치 위치**: `SHSB01Mapper.xml` (신규) 또는 기존 SHOD01·SHST01 Mapper 확장 중 선택.

권장 위치: `be/sh7000/shsb01/SHSB01Mapper.xml` (신규) — 부자재 전용 컴포넌트이므로 별도 Mapper 신설.

### 7-1. 부자재 주문 목록 조회 (`searchSubOrders`)

```sql
/* SHSB01Mapper.searchSubOrders 부자재 주문목록 조회 (shppDelivery 컴포넌트용) */
SELECT SO.shop_order_seq                                      AS shopOrderSeq
     , SO.shop_order_no                                       AS shopOrderNo
     , ${@fw.config.DBConfig@DB_PREFIX}FN_GET_YYYYMMDD(SO.shop_order_dt) AS shopOrderDt
     , SP.shop_prod_nm                                        AS prodNm
     , SOP.shop_order_qty                                     AS shopOrderQty
     , SOP.prod_total_amt                                     AS prodTotalAmt
     , SOP.prod_sts_cd                                        AS prodStsCd
     , SCD_STS.comm_d_nm                                      AS statusNm
     , SO.shop_order_sts_cd                                   AS shopOrderStsCd
  FROM SHOP_ORDER SO
  JOIN SHOP_ORDER_PROD SOP ON SOP.shop_order_seq = SO.shop_order_seq
  JOIN SHOP_PROD       SP  ON SP.shop_prod_seq   = SOP.shop_prod_seq
                          AND SP.use_yn          = 'Y'
                          AND SP.shop_prod_type_cd = 'SUB'
 LEFT JOIN SM_COMM_D SCD_STS ON SCD_STS.comm_h_cd = 'SHOP_PROD_STS_CD'
                            AND SCD_STS.comm_d_cd  = SOP.prod_sts_cd
                            AND SCD_STS.use_yn     = 'Y'
 WHERE SO.cont_seq = #{contSeq,jdbcType=INTEGER}
 ORDER BY SO.shop_order_seq DESC
```

**조회 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `contSeq` | int | 필수 | 가맹점 SEQ (`bizSeq` — 로그인 사용자 소속 가맹점) |

**반환 필드**:

| 필드명(camelCase) | 컬럼 | 설명 |
|---|---|---|
| `shopOrderSeq` | `SHOP_ORDER.shop_order_seq` | 주문 SEQ |
| `shopOrderNo` | `SHOP_ORDER.shop_order_no` | 주문번호 |
| `shopOrderDt` | `SHOP_ORDER.shop_order_dt` | 주문일시 (YYYYMMDD 변환) |
| `prodNm` | `SHOP_PROD.shop_prod_nm` | 상품명 |
| `shopOrderQty` | `SHOP_ORDER_PROD.shop_order_qty` | 주문수량 |
| `prodTotalAmt` | `SHOP_ORDER_PROD.prod_total_amt` | 상품총금액 |
| `prodStsCd` | `SHOP_ORDER_PROD.prod_sts_cd` | 상품진행상태코드 |
| `statusNm` | `SM_COMM_D.comm_d_nm` | 진행상태명 |
| `shopOrderStsCd` | `SHOP_ORDER.shop_order_sts_cd` | 주문취소 여부 (`CANCEL` 여부 판단용) |

---

## 8. 체크리스트

- [x] `SHOP_PROD_STS_CD` 코드그룹 전체 코드값 DB 직접 확인 완료 (dev DB, 2026-06-24)
- [x] 부자재 주문 상태 흐름 코드값 확정 (`STS_01`→`STS_02`→`STS_06`→`STS_07`→`STS_08`→`STS_09`)
- [ ] `SHSB01Mapper.xml` 신설 vs 기존 Mapper 확장 결정
- [ ] `/SD_api`로 API 명세(`shsb01c-05-api.md`) 작성 진행
