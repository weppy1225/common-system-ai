# wms_st_inven (WMS_재고실사_재고)

## 1. 개요
**재고실사 시점의 고정 재고 정보**를 관리하는 테이블.
실사 시작 시점의 재고를 스냅샷으로 저장하여 실사 결과와 비교하는 기준 데이터로 활용한다.

### 1.1 재고실사 재고 흐름
```
실사 시작 → 재고 고정 → wms_st_inven 저장 → 실사 진행(wms_st_tran) → 실사 결과 비교 → 재고조정
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_inven_seq | bigint | N | nextval('wms_st_inven_seq') | 재고실사 재고 SEQ |
| PK/FK | st_sch_seq | integer | N | | 재고실사 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | wh_seq | integer | N | | 창고 SEQ |
| | loc_seq | bigint | N | | 위치 SEQ |
| | inven_qty | decimal(10,2) | N | 0 | 재고 수량 (고정 시점) |
| | cfm_yn | char(1) | N | 'N' | 확정 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **cfm_yn** (`CFM_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 확정 (실사 완료) |
> | N | 미확정 (실사 진행중) |

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
| wms_st_inven_PK | st_inven_seq, st_sch_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_inven_seq | wms_st_inven_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_inven |

---

## 6. 업무 규칙

### 6.1 재고 고정 시점
- 실사 시작 시점(`inven_fix_ymd`, `inven_fix_hms`)의 재고를 기준으로 생성
- 고정 이후 발생한 재고 변동은 실사 결과와 무관

### 6.2 저장 대상
- 실사 대상(창고/위치)에 존재하는 모든 재고 레코드 저장
- 재고 수량이 0인 경우도 저장 가능 (실사 누락 방지)

### 6.3 확정 여부
- `cfm_yn = 'N'`: 실사 진행 중 (미확정)
- `cfm_yn = 'Y'`: 실사 완료, 결과 확정

### 6.4 실사 결과와 비교
- `wms_st_tran`의 실사 수량(`st_qty`)과 비교
- 차이 발생 시 재고조정(`wms_inven_ad`) 생성

### 6.5 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'`로 논리삭제
- 실사 완료 후 이력 보존

---

## 7. 주요 조회 예시

```sql
-- 특정 실사 일정의 고정 재고 목록
SELECT i.st_inven_seq, i.prod_seq, p.prod_nm,
       i.sku1, i.sku2,
       i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.inven_qty, i.cfm_yn
FROM wms_st_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
ORDER BY i.wh_seq, i.loc_seq, i.prod_seq;

-- 실사 일정별 재고 항목 수
SELECT s.st_sch_seq, s.yyyy, s.st_idx,
       COUNT(i.st_inven_seq) AS inven_cnt,
       SUM(i.inven_qty) AS total_qty
FROM wms_st_sch s
    LEFT JOIN wms_st_inven i ON s.st_sch_seq = i.st_sch_seq AND i.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.del_yn = 'N'
GROUP BY s.st_sch_seq, s.yyyy, s.st_idx
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 고정 재고와 실사 결과 비교
SELECT i.st_inven_seq, i.prod_seq, p.prod_nm,
       i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.sku1, i.sku2,
       i.inven_qty AS fixed_qty,
       COALESCE(t.st_qty, 0) AS actual_qty,
       i.inven_qty - COALESCE(t.st_qty, 0) AS diff_qty
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

-- 미실사 재고 항목 (고정 재고는 있으나 실사 결과 없음)
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

-- 품목별 고정 재고 현황
SELECT i.prod_seq, p.prod_nm,
       COUNT(*) AS location_cnt,
       SUM(i.inven_qty) AS total_fixed_qty
FROM wms_st_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
GROUP BY i.prod_seq, p.prod_nm
ORDER BY total_fixed_qty DESC;

-- 창고별 고정 재고 현황
SELECT i.wh_seq, w.wh_nm,
       COUNT(*) AS item_cnt,
       SUM(i.inven_qty) AS total_qty
FROM wms_st_inven i
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
GROUP BY i.wh_seq, w.wh_nm
ORDER BY i.wh_seq;

-- SKU별 고정 재고 현황
SELECT i.sku1, i.sku2,
       COUNT(*) AS location_cnt,
       SUM(i.inven_qty) AS total_qty
FROM wms_st_inven i
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
GROUP BY i.sku1, i.sku2
ORDER BY i.sku1, i.sku2;

-- 확정된 실사 재고 조회 (실사 완료)
SELECT i.*, p.prod_nm, w.wh_nm, l.loc_nm
FROM wms_st_inven i
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE i.st_sch_seq = 1001
AND i.cfm_yn = 'Y'
AND i.del_yn = 'N'
ORDER BY i.wh_seq, i.loc_seq, i.prod_seq;

-- 고정 재고와 실사 결과 차이가 큰 항목 Top N
SELECT i.st_inven_seq, i.prod_seq, p.prod_nm,
       i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.sku1, i.sku2,
       i.inven_qty AS fixed_qty,
       t.st_qty AS actual_qty,
       ABS(i.inven_qty - t.st_qty) AS diff_qty
FROM wms_st_inven i
    JOIN wms_st_tran t ON i.st_sch_seq = t.st_sch_seq 
        AND i.prod_seq = t.prod_seq 
        AND i.sku1 = t.sku1 
        AND i.sku2 = t.sku2 
        AND i.wh_seq = t.wh_seq 
        AND i.loc_seq = t.loc_seq
        AND t.del_yn = 'N'
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE i.st_sch_seq = 1001
AND i.del_yn = 'N'
ORDER BY diff_qty DESC
LIMIT 20;

-- 실사 진행률 (항목 기준)
SELECT
    COUNT(*) AS total_items,
    SUM(CASE WHEN cfm_yn = 'Y' THEN 1 ELSE 0 END) AS confirmed_items,
    ROUND(SUM(CASE WHEN cfm_yn = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS confirm_rate
FROM wms_st_inven
WHERE st_sch_seq = 1001
AND del_yn = 'N';

-- 실사 진행률 (수량 기준)
SELECT
    SUM(inven_qty) AS total_qty,
    SUM(CASE WHEN cfm_yn = 'Y' THEN inven_qty ELSE 0 END) AS confirmed_qty,
    ROUND(SUM(CASE WHEN cfm_yn = 'Y' THEN inven_qty ELSE 0 END) * 100.0 / SUM(inven_qty), 2) AS confirm_rate
FROM wms_st_inven
WHERE st_sch_seq = 1001
AND del_yn = 'N';
```