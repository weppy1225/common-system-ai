# wms_inven_holding (WMS_재고_예약)

## 1. 개요
**출하 등을 위해 예약(할당)된 재고 정보**를 관리하는 테이블.
실제 재고는 `wms_inven`에 존재하지만, 특정 출하/주문을 위해 할당된 수량을 별도로 관리하여 이중 할당을 방지한다.

### 1.1 재고 예약 흐름
```
출하등록/출고지시 → 재고 예약(wms_inven_holding) → 출고확정 → 예약 해제 및 재고 차감
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inven_holding_seq | bigint | N | nextval('wms_inven_holding_seq') | 이력 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | center_seq | integer | N | | 센터 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | mng_ymd | varchar(8) | Y | | 입고/제조일자 |
| | exp_ymd | varchar(8) | Y | | 유통기한 |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | sku1 | varchar(100) | Y | | SKU1 |
| | req_qty | decimal(10,2) | Y | 0 | 요청 수량 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 |
| | proc_hmsms | varchar(9) | Y | | 처리 시분초밀리초 |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | proc_yn | char(1) | N | 'N' | 처리 여부 |
| | inout_type_cd | varchar(50) | N | | 수불 유형 코드 |
| | inout_dtl_cd | varchar(50) | Y | | 수불 상세 코드 |
| | req_seq | integer | Y | | 요청 SEQ |
| | req_prod_seq | bigint | Y | | 요청 품목 SEQ |
| | req_no | varchar(30) | Y | | 업무 번호 |

> **proc_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 처리 완료 (출고 확정) |
> | N | 미처리 (예약 중) |

> **inout_type_cd** (`INOUT_TYPE_CD` - 공통코드)
>
> | 코드 | 코드명 |
> |---|---|
> | OB | 출하 |
> | OW | 출고 |
> | EX | 예외출고 |
> | IM | 재고이동 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inven_holding_PK | inven_holding_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inven_holding_seq | wms_inven_holding_seq |

---

## 5. 업무 규칙

### 5.1 재고 예약 목적
- 동일 재고에 대한 중복 할당 방지
- 출고 가능 재고의 정확한 파악
- 선입선출(FIFO)을 위한 재고 지정

### 5.2 예약 생성 시점
- 출하지시 생성 시 재고 예약
- 피킹 지시 생성 시 재고 지정
- 출고 예정 수량만큼 예약

### 5.3 예약 해제 시점
- 출고 확정 시 예약 해제 및 재고 차감
- 출하 취소 시 예약 해제 (재고 복원)
- 부분 출고 시 잔여 수량 예약 유지

### 5.4 수량 관리
- `req_qty`: 요청된 예약 수량
- `proc_qty`: 실제 처리된 수량 (출고 확정 시)
- 미처리 예약: `req_qty` - `proc_qty` > 0

### 5.5 예약 단위
- 품목, SKU, LOT, 유통기한 단위로 예약 가능
- 정밀한 재고 관리를 위해 상세 조건 지정

### 5.6 관련 업무 정보
- `req_seq`, `req_prod_seq`: 예약을 발생시킨 업무의 SEQ
- `req_no`: 업무 번호 (출하번호, 출고번호 등)
- 예약과 실제 업무의 연결고리

### 5.7 처리 상태
- `proc_yn = 'N'`: 활성 예약 (출고 대기)
- `proc_yn = 'Y'`: 처리 완료 (출고 확정)
- 완료된 예약은 이력으로 보관

### 5.8 재고와의 관계
- 예약된 재고는 `wms_inven.wt_qty`(대기재고)로 표시
- 실제 가용 재고 = `inven_qty` - SUM(미처리 예약 수량)

### 5.9 선입선출(FIFO)
- 유통기한이 빠른 순으로 재고 예약
- `exp_ymd` 기준 정렬하여 출고 지시

---

## 6. 주요 조회 예시

```sql
-- 특정 출하의 재고 예약 현황
SELECT h.*, p.prod_nm
FROM wms_inven_holding h
    JOIN mdm_prod p ON h.prod_seq = p.prod_seq
WHERE h.biz_seq = 1
AND h.req_no = 'OB2502260001'
AND h.proc_yn = 'N'
ORDER BY h.exp_ymd, h.inven_holding_seq;

-- 품목별 활성 예약 현황
SELECT h.prod_seq, p.prod_nm,
       COUNT(*) AS holding_cnt,
       SUM(h.req_qty - h.proc_qty) AS total_holding_qty,
       MIN(h.exp_ymd) AS earliest_exp
FROM wms_inven_holding h
    JOIN mdm_prod p ON h.prod_seq = p.prod_seq
WHERE h.biz_seq = 1
AND h.center_seq = 1
AND h.proc_yn = 'N'
GROUP BY h.prod_seq, p.prod_nm
ORDER BY total_holding_qty DESC;

-- 유통기한이 임박한 예약 재고 조회
SELECT h.*, p.prod_nm,
       CURRENT_DATE - TO_DATE(h.exp_ymd, 'YYYYMMDD') AS exp_d_day
FROM wms_inven_holding h
    JOIN mdm_prod p ON h.prod_seq = p.prod_seq
WHERE h.biz_seq = 1
AND h.exp_ymd IS NOT NULL
AND TO_DATE(h.exp_ymd, 'YYYYMMDD') <= CURRENT_DATE + INTERVAL '7 days'
AND h.proc_yn = 'N'
ORDER BY h.exp_ymd;

-- 특정 위치의 재고 예약 현황 (wms_inven과 연동)
SELECT i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.prod_seq, p.prod_nm,
       i.sku1, i.sku2,
       i.inven_qty,
       COALESCE(SUM(h.req_qty - h.proc_qty), 0) AS holding_qty,
       i.inven_qty - COALESCE(SUM(h.req_qty - h.proc_qty), 0) AS available_qty
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
    LEFT JOIN wms_inven_holding h ON i.biz_seq = h.biz_seq 
        AND i.prod_seq = h.prod_seq 
        AND i.sku1 = h.sku1 
        AND i.sku2 = h.sku2
        AND h.proc_yn = 'N'
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.inven_qty > 0
GROUP BY i.wh_seq, w.wh_nm, i.loc_seq, l.loc_nm,
         i.prod_seq, p.prod_nm, i.sku1, i.sku2, i.inven_qty
ORDER BY i.wh_seq, i.loc_seq;

-- 출하 유형별 예약 현황
SELECT h.inout_type_cd, h.inout_dtl_cd,
       COUNT(*) AS holding_cnt,
       SUM(h.req_qty - h.proc_qty) AS total_holding_qty,
       COUNT(DISTINCT h.req_no) AS req_cnt
FROM wms_inven_holding h
WHERE h.biz_seq = 1
AND h.proc_yn = 'N'
GROUP BY h.inout_type_cd, h.inout_dtl_cd
ORDER BY h.inout_type_cd, h.inout_dtl_cd;

-- 작업자별 예약 처리 현황
SELECT proc_user_id,
       COUNT(*) AS proc_cnt,
       SUM(proc_qty) AS total_proc_qty,
       MIN(proc_ymd) AS first_proc,
       MAX(proc_ymd) AS last_proc
FROM wms_inven_holding
WHERE biz_seq = 1
AND proc_yn = 'Y'
AND proc_ymd BETWEEN '20250201' AND '20250228'
GROUP BY proc_user_id
ORDER BY total_proc_qty DESC;

-- 오래된 미처리 예약 조회 (3일 이상)
SELECT h.*, p.prod_nm
FROM wms_inven_holding h
    JOIN mdm_prod p ON h.prod_seq = p.prod_seq
WHERE h.biz_seq = 1
AND h.proc_yn = 'N'
AND TO_DATE(h.proc_ymd || h.proc_hmsms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '3 days'
ORDER BY h.proc_ymd, h.proc_hmsms;

-- LOT 번호별 예약 현황
SELECT lot_no, prod_seq,
       COUNT(*) AS holding_cnt,
       SUM(req_qty - proc_qty) AS total_holding_qty,
       MIN(exp_ymd) AS min_exp_ymd
FROM wms_inven_holding
WHERE biz_seq = 1
AND lot_no IS NOT NULL
AND proc_yn = 'N'
GROUP BY lot_no, prod_seq
ORDER BY lot_no;

-- 일자별 예약 추이
SELECT proc_ymd,
       COUNT(*) AS new_holding_cnt,
       SUM(req_qty) AS new_holding_qty
FROM wms_inven_holding
WHERE biz_seq = 1
AND proc_ymd BETWEEN '20250201' AND '20250228'
GROUP BY proc_ymd
ORDER BY proc_ymd;

-- 특정 품목의 상세 예약 정보 (SKU/LOT 포함)
SELECT h.sku1, h.sku2,
       h.lot_no, h.exp_ymd, h.mng_ymd,
       h.req_qty - h.proc_qty AS holding_qty,
       h.req_no, h.inout_type_cd,
       h.proc_ymd AS reserved_ymd
FROM wms_inven_holding h
WHERE h.biz_seq = 1
AND h.prod_seq = 1001
AND h.proc_yn = 'N'
ORDER BY h.exp_ymd, h.lot_no;

-- 재고 부족 위험 예약 분석 (가용재고 < 예약 필요수량)
SELECT h.req_no,
       h.prod_seq, p.prod_nm,
       SUM(h.req_qty - h.proc_qty) AS required_qty,
       COALESCE((
           SELECT SUM(i.inven_qty - i.wt_qty)
           FROM wms_inven i
           WHERE i.biz_seq = h.biz_seq
             AND i.center_seq = h.center_seq
             AND i.prod_seq = h.prod_seq
       ), 0) AS available_qty
FROM wms_inven_holding h
    JOIN mdm_prod p ON h.prod_seq = p.prod_seq
WHERE h.biz_seq = 1
AND h.proc_yn = 'N'
GROUP BY h.req_no, h.prod_seq, p.prod_nm
HAVING SUM(h.req_qty - h.proc_qty) > COALESCE((
    SELECT SUM(i.inven_qty - i.wt_qty)
    FROM wms_inven i
    WHERE i.biz_seq = h.biz_seq
      AND i.center_seq = h.center_seq
      AND i.prod_seq = h.prod_seq
), 0);
```