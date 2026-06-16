# wms_st_tran (WMS_재고실사_처리)

## 1. 개요
**재고실사 결과(실사 수량)**를 기록하는 테이블.
실사자가 실제로 확인한 재고 수량을 입력하고, 실사 완료 처리의 근거가 된다.

### 1.1 재고실사 처리 흐름
```
실사 대상 지정 → 실사 진행 → wms_st_tran 저장 → 고정 재고(wms_st_inven)와 비교 → 재고조정
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_tran_seq | bigint | N | nextval('wms_st_tran_seq') | 재고실사 처리 SEQ |
| PK/FK | st_sch_seq | integer | N | | 재고실사 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | wh_seq | integer | N | | 창고 SEQ |
| | loc_seq | bigint | N | | 위치 SEQ |
| | st_qty | decimal(10,2) | N | 0 | 재고실사 수량 |
| | st_ymd | varchar(8) | N | | 재고실사 연월일 |
| | st_hms | varchar(6) | N | | 재고실사 시분초 |
| | st_user_id | varchar(20) | N | | 재고실사자 ID |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

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
| wms_st_tran_PK | st_tran_seq, st_sch_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_tran_seq | wms_st_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_tran |

---

## 6. 업무 규칙

### 6.1 실사 결과 기록
- 실사자가 실제 재고를 확인한 결과를 입력
- 동일 실사 일정 내에서 중복 실사 가능 (재실사)

### 6.2 실사 단위
- 품목, SKU, 창고, 위치 단위로 실사 결과 기록
- 위치별로 존재하는 모든 품목을 실사 대상으로 함

### 6.3 실사 시점
- `st_ymd`, `st_hms`: 실사 수행 일시
- 실사 완료 시점 기록

### 6.4 실사자 정보
- `st_user_id`: 실제 실사 수행자 ID
- 실사 책임 추적

### 6.5 수량 비교
- 실사 결과(`st_qty`)와 고정 재고(`wms_st_inven.inven_qty`) 비교
- 차이 발생 시 재고조정(`wms_inven_ad`) 생성

### 6.6 실사 방법
- 전체 실사: 모든 재고 항목 실사
- 샘플 실사: 일부 항목만 실사
- 순환 실사: 주기적으로 일부 항목 실사

### 6.7 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'`로 논리삭제
- 잘못된 실사 결과는 삭제보다 수정 권장

---

## 7. 주요 조회 예시

```sql
-- 특정 실사 일정의 실사 결과
SELECT t.st_tran_seq, t.prod_seq, p.prod_nm,
       t.sku1, t.sku2,
       t.wh_seq, w.wh_nm,
       t.loc_seq, l.loc_nm,
       t.st_qty, t.st_ymd, t.st_hms, t.st_user_id
FROM wms_st_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
    JOIN mdm_wh w ON t.wh_seq = w.wh_seq
    JOIN mdm_loc l ON t.loc_seq = l.loc_seq
WHERE t.st_sch_seq = 1001
AND t.del_yn = 'N'
ORDER BY t.wh_seq, t.loc_seq, t.prod_seq;

-- 실사 결과와 고정 재고 비교
SELECT i.st_inven_seq, i.prod_seq, p.prod_nm,
       i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.sku1, i.sku2,
       i.inven_qty AS fixed_qty,
       COALESCE(t.st_qty, 0) AS actual_qty,
       i.inven_qty - COALESCE(t.st_qty, 0) AS diff_qty,
       CASE 
           WHEN i.inven_qty = COALESCE(t.st_qty, 0) THEN '일치'
           WHEN i.inven_qty > COALESCE(t.st_qty, 0) THEN '과다'
           ELSE '부족'
       END AS diff_status
FROM wms_st_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
    LEFT JOIN wms_st_tran t ON i.st_sch_seq = t.st_sch_seq 
        AND i.prod_seq = t.prod_seq 
        AND i.sku1 = t.sku1 
        AND i.sku2 = t.sku2 
        AND i.wh_seq = t.wh_seq 
        AND i.loc_seq = t.loc_seq
        AND t.del_yn = 'N'
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
ORDER BY ABS(i.inven_qty - COALESCE(t.st_qty, 0)) DESC;

-- 실사자별 처리 현황
SELECT st_user_id,
       COUNT(*) AS tran_cnt,
       SUM(st_qty) AS total_qty,
       MIN(st_ymd) AS first_work,
       MAX(st_ymd) AS last_work
FROM wms_st_tran
WHERE st_sch_seq = 1001
AND del_yn = 'N'
GROUP BY st_user_id
ORDER BY total_qty DESC;

-- 일자별 실사 현황
SELECT st_ymd,
       COUNT(*) AS tran_cnt,
       SUM(st_qty) AS total_qty,
       COUNT(DISTINCT st_user_id) AS worker_cnt
FROM wms_st_tran
WHERE st_sch_seq = 1001
AND del_yn = 'N'
GROUP BY st_ymd
ORDER BY st_ymd;

-- 실사 누락 항목 (고정 재고는 있으나 실사 결과 없음)
SELECT i.*, p.prod_nm, w.wh_nm, l.loc_nm
FROM wms_st_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
    LEFT JOIN wms_st_tran t ON i.st_sch_seq = t.st_sch_seq 
        AND i.prod_seq = t.prod_seq 
        AND i.sku1 = t.sku1 
        AND i.sku2 = t.sku2 
        AND i.wh_seq = t.wh_seq 
        AND i.loc_seq = t.loc_seq
        AND t.del_yn = 'N'
WHERE i.st_sch_seq = 1001
AND t.st_tran_seq IS NULL
AND i.del_yn = 'N'
ORDER BY i.wh_seq, i.loc_seq, i.prod_seq;

-- 실사 차이 분석 (차이 큰 순)
SELECT t.st_tran_seq, t.prod_seq, p.prod_nm,
       t.wh_seq, w.wh_nm,
       t.loc_seq, l.loc_nm,
       i.inven_qty AS fixed_qty,
       t.st_qty AS actual_qty,
       ABS(i.inven_qty - t.st_qty) AS diff_qty
FROM wms_st_tran t
    JOIN wms_st_inven i ON t.st_sch_seq = i.st_sch_seq 
        AND t.prod_seq = i.prod_seq 
        AND t.sku1 = i.sku1 
        AND t.sku2 = i.sku2 
        AND t.wh_seq = i.wh_seq 
        AND t.loc_seq = i.loc_seq
        AND i.del_yn = 'N'
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
    JOIN mdm_wh w ON t.wh_seq = w.wh_seq
    JOIN mdm_loc l ON t.loc_seq = l.loc_seq
WHERE t.st_sch_seq = 1001
AND t.del_yn = 'N'
ORDER BY diff_qty DESC
LIMIT 20;

-- 품목별 실사 차이 요약
SELECT t.prod_seq, p.prod_nm,
       COUNT(*) AS tran_cnt,
       SUM(i.inven_qty) AS total_fixed,
       SUM(t.st_qty) AS total_actual,
       SUM(i.inven_qty) - SUM(t.st_qty) AS total_diff
FROM wms_st_tran t
    JOIN wms_st_inven i ON t.st_sch_seq = i.st_sch_seq 
        AND t.prod_seq = i.prod_seq 
        AND t.sku1 = i.sku1 
        AND t.sku2 = i.sku2 
        AND t.wh_seq = i.wh_seq 
        AND t.loc_seq = i.loc_seq
        AND i.del_yn = 'N'
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.st_sch_seq = 1001
AND t.del_yn = 'N'
GROUP BY t.prod_seq, p.prod_nm
HAVING ABS(SUM(i.inven_qty) - SUM(t.st_qty)) > 0
ORDER BY total_diff DESC;

-- 창고별 실사 차이 현황
SELECT t.wh_seq, w.wh_nm,
       COUNT(*) AS item_cnt,
       SUM(i.inven_qty) AS total_fixed,
       SUM(t.st_qty) AS total_actual,
       SUM(i.inven_qty) - SUM(t.st_qty) AS total_diff
FROM wms_st_tran t
    JOIN wms_st_inven i ON t.st_sch_seq = i.st_sch_seq 
        AND t.prod_seq = i.prod_seq 
        AND t.sku1 = i.sku1 
        AND t.sku2 = i.sku2 
        AND t.wh_seq = i.wh_seq 
        AND t.loc_seq = i.loc_seq
        AND i.del_yn = 'N'
    JOIN mdm_wh w ON t.wh_seq = w.wh_seq
WHERE t.st_sch_seq = 1001
AND t.del_yn = 'N'
GROUP BY t.wh_seq, w.wh_nm
ORDER BY t.wh_seq;

-- 실사 진행률 (항목 기준)
SELECT
    COUNT(DISTINCT i.st_inven_seq) AS total_items,
    COUNT(DISTINCT t.st_tran_seq) AS completed_items,
    ROUND(COUNT(DISTINCT t.st_tran_seq) * 100.0 / NULLIF(COUNT(DISTINCT i.st_inven_seq), 0), 2) AS progress_rate
FROM wms_st_inven i
    LEFT JOIN wms_st_tran t ON i.st_sch_seq = t.st_sch_seq 
        AND i.prod_seq = t.prod_seq 
        AND i.sku1 = t.sku1 
        AND i.sku2 = t.sku2 
        AND i.wh_seq = t.wh_seq 
        AND i.loc_seq = t.loc_seq
        AND t.del_yn = 'N'
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N';

-- 중복 실사 내역 (동일 항목 여러번 실사)
SELECT t1.st_tran_seq, t1.st_user_id, t1.st_ymd, t1.st_hms, t1.st_qty,
       t2.st_tran_seq AS prev_tran_seq, t2.st_qty AS prev_qty,
       t1.st_qty - t2.st_qty AS qty_change
FROM wms_st_tran t1
    JOIN wms_st_tran t2 ON t1.st_sch_seq = t2.st_sch_seq 
        AND t1.prod_seq = t2.prod_seq 
        AND t1.sku1 = t2.sku1 
        AND t1.sku2 = t2.sku2 
        AND t1.wh_seq = t2.wh_seq 
        AND t1.loc_seq = t2.loc_seq
        AND t1.st_tran_seq > t2.st_tran_seq
        AND t2.del_yn = 'N'
WHERE t1.st_sch_seq = 1001
AND t1.del_yn = 'N'
ORDER BY t1.prod_seq, t1.wh_seq, t1.loc_seq, t1.st_ymd, t1.st_hms;

-- 시간대별 실사 집계
SELECT SUBSTR(st_hms, 1, 2) AS hour,
       COUNT(*) AS tran_cnt,
       SUM(st_qty) AS total_qty
FROM wms_st_tran
WHERE st_sch_seq = 1001
AND del_yn = 'N'
GROUP BY SUBSTR(st_hms, 1, 2)
ORDER BY hour;
```