# wms_inven (WMS_재고)

## 1. 개요
**현재 재고(Inventory)의 실시간 수량**을 관리하는 테이블.
사업장, 센터, 품목, SKU, 창고, 위치별로 재고 수량을 집계하여 보관한다. 모든 재고 변동(입고, 출고, 이동, 조정 등)의 최종 결과가 반영되는 핵심 테이블이다.

### 1.1 재고 관리 흐름
```
재고 변동 발생 (입고/출고/이동/조정) → wms_inven_inout (수불 이력) → wms_inven 증감
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | center_seq | integer | N | | 센터 SEQ |
| PK | prod_seq | integer | N | | 품목 SEQ |
| PK | sku1 | varchar(100) | N | | SKU1 |
| PK | sku2 | varchar(100) | N | | SKU2 |
| PK | wh_seq | integer | N | | 창고 SEQ |
| PK | loc_seq | bigint | N | | 위치 SEQ |
| | inven_qty | decimal(10,2) | N | 0 | 재고 수량 |
| | wt_qty | decimal(10,2) | N | 0 | 대기재고 수량 |
| | qc_yn | char(1) | N | 'N' | 검사 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **qc_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 검수 필요/검수중 |
> | N | 검수 완료/불필요 |

> **del_yn** (`DEL_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미삭제 |
> | Y | 삭제 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inven_PK | biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq | Y | Y |
| UK_wms_inven | 동일 | Y | |

---

## 4. 업무 규칙

### 4.1 재고 식별 키
- 재고는 **7가지 키**로 고유하게 식별:
- `biz_seq`: 사업장
- `center_seq`: 센터
- `prod_seq`: 품목
- `sku1`, `sku2`: SKU
- `wh_seq`: 창고
- `loc_seq`: 위치
- 동일한 조건의 재고는 하나의 레코드로 집계

### 4.2 재고 수량
- `inven_qty`: 실제 사용 가능한 재고 수량
- `wt_qty`: 대기 재고 (예약, 검수 중 등)
- 가용 재고 = `inven_qty` - `wt_qty`

### 4.3 검수 여부
- `qc_yn = 'Y'`: 검수가 필요한 재고 (입고 직후, 반품 등)
- 검수 완료 후 `qc_yn = 'N'`으로 변경
- 검수 중인 재고는 출고 불가

### 4.4 재고 변동 처리
재고 변동 시 다음과 같이 처리:

| 작업 유형 | inven_qty 영향 | wt_qty 영향 | 비고 |
|----------|---------------|------------|------|
| 입고 | + | - | 입고 확정 시 wt_qty 감소, inven_qty 증가 |
| 출고 | - | - | 출고 확정 시 차감 |
| 출하지시 | - | + | 재고 예약 (wt_qty 증가) |
| 출고취소 | + | - | 예약 해제 |
| 재고이동 | +/- | - | 위치 변경 |
| 재고조정 | +/- | - | 실사 결과 반영 |

### 4.5 대기재고
- `wt_qty`는 다음과 같은 상황에서 발생:
- 출하지시로 예약된 재고
- 검수 대기 중인 재고
- 이동 지시된 재고
- 기타 처리 대기 상태

### 4.6 재고 생성
- 최초 재고는 입고 처리 시 생성
- 존재하지 않는 재고 키 조합으로 입고 시 신규 레코드 생성

### 4.7 재고 소멸
- 재고 수량이 0이 되어도 레코드는 유지 (이력 보존)
- `del_yn = 'Y'`로 논리삭제하여 더 이상 사용하지 않는 재고 표시

### 4.8 무재고 처리
- 재고 수량이 음수가 될 수 없음 (비즈니스 규칙)
- 출고/이동 시 재고 부족 체크 필수

### 4.9 적치 전략
- 입고 시 자동 적치 위치 추천 가능
- 위치별 재고 현황을 기반으로 적치 전략 수립

### 4.10 선입선출(FIFO)
- `exp_ymd` 기준 선출을 위해 `wms_inven_sku`와 연동
- 유통기한 관리 품목은 exp_ymd 순으로 출고 지시

---

## 5. 주요 조회 예시

```sql
-- 특정 품목의 전체 재고 현황
SELECT prod_seq, p.prod_nm,
       SUM(inven_qty) AS total_inven,
       SUM(wt_qty) AS total_wt
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.prod_seq = 1001
AND i.del_yn = 'N'
GROUP BY prod_seq, p.prod_nm;

-- 창고별/위치별 재고 현황
SELECT i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.prod_seq, p.prod_nm,
       i.sku1, i.sku2,
       i.inven_qty, i.wt_qty,
       i.qc_yn
FROM wms_inven i
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.inven_qty > 0
ORDER BY i.wh_seq, i.loc_seq, i.prod_seq;

-- 가용 재고 조회 (inven_qty - wt_qty)
SELECT prod_seq, p.prod_nm,
       wh_seq, loc_seq,
       sku1, sku2,
       inven_qty - wt_qty AS available_qty,
       inven_qty, wt_qty
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND (inven_qty - wt_qty) > 0
AND i.del_yn = 'N'
ORDER BY available_qty DESC;

-- 검수 필요 재고 조회
SELECT i.*, p.prod_nm, w.wh_nm, l.loc_nm
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.qc_yn = 'Y'
AND i.inven_qty > 0
AND i.del_yn = 'N'
ORDER BY i.reg_dt;

-- 품목별 재고 요약
SELECT i.prod_seq, p.prod_nm,
       COUNT(DISTINCT i.wh_seq || '-' || i.loc_seq) AS location_cnt,
       SUM(i.inven_qty) AS total_qty,
       SUM(i.wt_qty) AS total_wt_qty,
       MIN(i.reg_dt) AS first_reg,
       MAX(i.mod_dt) AS last_update
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.del_yn = 'N'
GROUP BY i.prod_seq, p.prod_nm
ORDER BY total_qty DESC;

-- 특정 위치의 재고 현황
SELECT i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.prod_seq, p.prod_nm,
       i.sku1, i.sku2,
       i.inven_qty, i.wt_qty,
       i.qc_yn
FROM wms_inven i
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.wh_seq = 10
AND i.loc_seq = 1001
AND i.del_yn = 'N'
ORDER BY i.prod_seq;

-- 센터별 재고 현황
SELECT center_seq,
       COUNT(DISTINCT prod_seq) AS prod_cnt,
       SUM(inven_qty) AS total_qty,
       SUM(wt_qty) AS total_wt_qty,
       COUNT(DISTINCT wh_seq || '-' || loc_seq) AS location_cnt
FROM wms_inven
WHERE biz_seq = 1
AND del_yn = 'N'
GROUP BY center_seq
ORDER BY center_seq;

-- SKU별 재고 현황 (wms_inven_sku와 연동)
SELECT i.sku1, i.sku2,
       i.prod_seq, p.prod_nm,
       i.inven_qty,
       s.mng_ymd, s.exp_ymd, s.lot_no, s.bl_no
FROM wms_inven i
    JOIN wms_inven_sku s ON i.biz_seq = s.biz_seq 
        AND i.prod_seq = s.prod_seq 
        AND i.sku1 = s.sku1 
        AND i.sku2 = s.sku2
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.inven_qty > 0
AND s.del_yn = 'N'
ORDER BY s.exp_ymd;

-- 일자별 재고 변동 추이 (전일 대비)
SELECT DATE(i.mod_dt) AS change_date,
       COUNT(*) AS change_cnt,
       SUM(CASE WHEN i.inven_qty > 0 THEN 1 ELSE 0 END) AS positive_stock_cnt,
       SUM(i.inven_qty) AS total_qty
FROM wms_inven i
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.mod_dt >= CURRENT_DATE - INTERVAL '30 days'
AND i.del_yn = 'N'
GROUP BY DATE(i.mod_dt)
ORDER BY change_date DESC;
```