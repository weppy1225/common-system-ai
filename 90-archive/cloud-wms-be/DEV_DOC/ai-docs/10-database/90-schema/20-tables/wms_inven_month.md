# wms_inven_month (WMS_재고_월마감)

## 1. 개요
**월말 재고 마감 데이터**를 관리하는 테이블.
매월 말일 기준으로 재고 수량을 확정하고, 해당 월의 입고/출하/반품/예외출고 실적을 집계하여 회계 및 재고 평가의 기초 자료로 활용한다.

### 1.1 월마감 처리 흐름
```
월말 도래 → 재고 실사/확정 → wms_inven_month 저장 → 회계 전표 생성 → 익월 재고 이월
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inven_month_seq | bigint | N | nextval('wms_inven_month_seq') | 재고마감 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | center_seq | integer | N | | 센터 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | wh_seq | integer | N | | 창고 SEQ |
| | yyyymm | varchar(6) | N | | 년월 (마감 기준) |
| | inven_qty | decimal(10,2) | N | 0 | 재고 수량 |
| | inwh_qty | decimal(10,2) | N | 0 | 입고 수량 |
| | outbiz_qty | decimal(10,2) | N | 0 | 출하 수량 |
| | return_qty | decimal(10,2) | N | 0 | 반품 수량 |
| | etc_qty | decimal(10,2) | N | 0 | 예외출고 수량 |
| | mng_ymd | varchar(8) | Y | | 입고/제조일자 |
| | exp_ymd | varchar(8) | Y | | 유통기한 |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inven_month_PK | inven_month_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inven_month_seq | wms_inven_month_seq |

---

## 5. 업무 규칙

### 5.1 월마감 대상
- 매월 말일 기준으로 재고 데이터 확정
- 사업장, 센터, 품목, 창고별로 집계

### 5.2 집계 항목

| 항목 | 설명 | 데이터 소스 |
|------|------|------------|
| inven_qty | 기준일 현재 재고 수량 | wms_inven |
| inwh_qty | 해당 월 입고 총량 | wms_inwh_tran |
| outbiz_qty | 해당 월 출하 총량 | wms_outbiz_tran |
| return_qty | 해당 월 반품 총량 | wms_return_tran |
| etc_qty | 해당 월 예외출고 총량 | wms_inven_etc_tran |

### 5.3 재고 평가
- 월마감 데이터는 재고 평가의 기준
- 평균법, 선입선출법 등 원가 계산에 활용
- 회계 장부와 재고 장부 일치 여부 확인

### 5.4 마감 절차

#### 5.4.1 재고 실사
- 실사 결과와 장부 재고 비교
- 차이 발생 시 재고조정(AD) 처리

#### 5.4.2 데이터 집계
- 해당 월의 모든 수불 내역 집계
- 입고/출하/반품/예외출고 실적 산출

#### 5.4.3 마감 확정
- 집계된 데이터 검증
- 월마감 데이터 저장
- 이후 해당 월 데이터 수정 불가 (Lock)

#### 5.4.4 이월 처리
- 다음 월 초 재고로 이월
- 익월 재고 수량의 기준점

### 5.5 보존 기간
- 월마감 데이터는 영구 보존 (회계 감사)
- 필요 시 분기/반기/연간 마감으로 재가공

### 5.6 재고 정확성
- 월마감 데이터는 재고 정확성 검증의 기준
- 실사와 장부의 차이를 최소화하는 것이 목표

---

## 6. 주요 조회 예시

```sql
-- 특정 월의 마감 현황
SELECT yyyymm,
       COUNT(DISTINCT prod_seq) AS prod_cnt,
       SUM(inven_qty) AS total_inven_qty,
       SUM(inwh_qty) AS total_inwh_qty,
       SUM(outbiz_qty) AS total_outbiz_qty,
       SUM(return_qty) AS total_return_qty,
       SUM(etc_qty) AS total_etc_qty
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm = '202502'
GROUP BY yyyymm;

-- 품목별 월별 재고 추이
SELECT prod_seq, p.prod_nm,
       yyyymm,
       inven_qty,
       inwh_qty, outbiz_qty, return_qty, etc_qty
FROM wms_inven_month m
    JOIN mdm_prod p ON m.prod_seq = p.prod_seq
WHERE m.biz_seq = 1
AND m.prod_seq = 1001
AND m.yyyymm BETWEEN '202501' AND '202506'
ORDER BY m.yyyymm;

-- 창고별 월말 재고 현황
SELECT m.wh_seq, w.wh_nm,
       m.yyyymm,
       SUM(m.inven_qty) AS total_inven_qty,
       COUNT(DISTINCT m.prod_seq) AS prod_cnt
FROM wms_inven_month m
    JOIN mdm_wh w ON m.wh_seq = w.wh_seq
WHERE m.biz_seq = 1
AND m.yyyymm = '202502'
GROUP BY m.wh_seq, w.wh_nm, m.yyyymm
ORDER BY m.wh_seq;

-- 센터별 월말 재고 현황
SELECT m.center_seq, c.center_nm,
       m.yyyymm,
       SUM(m.inven_qty) AS total_inven_qty,
       SUM(m.inwh_qty) AS total_inwh_qty,
       SUM(m.outbiz_qty) AS total_outbiz_qty
FROM wms_inven_month m
    JOIN mdm_center c ON m.center_seq = c.center_seq
WHERE m.biz_seq = 1
AND m.yyyymm = '202502'
GROUP BY m.center_seq, c.center_nm, m.yyyymm
ORDER BY m.center_seq;

-- 월별 재고 회전율 분석
SELECT yyyymm,
       SUM(inven_qty) AS avg_inven_qty,
       SUM(outbiz_qty) AS total_out_qty,
       CASE WHEN SUM(inven_qty) > 0 
            THEN ROUND(SUM(outbiz_qty) * 100.0 / SUM(inven_qty), 2) 
            ELSE 0 END AS turnover_rate
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm BETWEEN '202501' AND '202506'
GROUP BY yyyymm
ORDER BY yyyymm;

-- 유통기한별 월말 재고 현황
SELECT exp_ymd,
       SUM(inven_qty) AS total_qty,
       COUNT(DISTINCT prod_seq) AS prod_cnt
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm = '202502'
AND exp_ymd IS NOT NULL
GROUP BY exp_ymd
ORDER BY exp_ymd;

-- LOT 번호별 월말 재고 현황
SELECT lot_no, prod_seq,
       inven_qty, mng_ymd, exp_ymd
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm = '202502'
AND lot_no IS NOT NULL
ORDER BY lot_no, prod_seq;

-- 전월 대비 재고 변동 분석
SELECT curr.prod_seq, p.prod_nm,
       prev.inven_qty AS prev_qty,
       curr.inven_qty AS curr_qty,
       curr.inven_qty - prev.inven_qty AS qty_change,
       CASE WHEN prev.inven_qty > 0 
            THEN ROUND((curr.inven_qty - prev.inven_qty) * 100.0 / prev.inven_qty, 2)
            ELSE 0 END AS change_rate
FROM wms_inven_month curr
    JOIN wms_inven_month prev ON curr.biz_seq = prev.biz_seq 
        AND curr.center_seq = prev.center_seq 
        AND curr.prod_seq = prev.prod_seq 
        AND curr.wh_seq = prev.wh_seq
        AND prev.yyyymm = TO_CHAR(TO_DATE(curr.yyyymm || '01', 'YYYYMMDD') - INTERVAL '1 month', 'YYYYMM')
    JOIN mdm_prod p ON curr.prod_seq = p.prod_seq
WHERE curr.biz_seq = 1
AND curr.yyyymm = '202502'
ORDER BY qty_change DESC;

-- 품목별 수불 실적 요약 (당월)
SELECT prod_seq,
       SUM(inwh_qty) AS total_in,
       SUM(outbiz_qty) AS total_out,
       SUM(return_qty) AS total_return,
       SUM(etc_qty) AS total_etc
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm = '202502'
GROUP BY prod_seq
ORDER BY prod_seq;

-- 재고 금액 평가 (평균 단가 연동 가정)
SELECT m.prod_seq, p.prod_nm,
       m.inven_qty,
       p.avg_cost AS unit_cost,
       m.inven_qty * p.avg_cost AS inven_amount
FROM wms_inven_month m
    JOIN mdm_prod p ON m.prod_seq = p.prod_seq
WHERE m.biz_seq = 1
AND m.yyyymm = '202502'
AND m.inven_qty > 0
ORDER BY inven_amount DESC;

-- 마감 누락 품목 체크 (당월 재고는 있으나 마감 데이터 없는 품목)
SELECT i.prod_seq, p.prod_nm,
       SUM(i.inven_qty) AS current_qty
FROM wms_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_month m ON i.biz_seq = m.biz_seq 
        AND i.center_seq = m.center_seq 
        AND i.prod_seq = m.prod_seq 
        AND i.wh_seq = m.wh_seq
        AND m.yyyymm = '202502'
WHERE i.biz_seq = 1
AND m.inven_month_seq IS NULL
AND i.inven_qty > 0
GROUP BY i.prod_seq, p.prod_nm
ORDER BY i.prod_seq;

-- 분기별 재고 추이
SELECT CONCAT(SUBSTR(yyyymm, 1, 4), 'Q', CEIL(SUBSTR(yyyymm, 5, 2) / 3.0)) AS quarter,
       SUM(inven_qty) AS avg_inven_qty,
       SUM(inwh_qty) AS total_inwh_qty,
       SUM(outbiz_qty) AS total_outbiz_qty
FROM wms_inven_month
WHERE biz_seq = 1
AND yyyymm BETWEEN '202501' AND '202512'
GROUP BY CONCAT(SUBSTR(yyyymm, 1, 4), 'Q', CEIL(SUBSTR(yyyymm, 5, 2) / 3.0))
ORDER BY quarter;
```