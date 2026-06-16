# wms_st_sch (WMS_재고실사_일정)

## 1. 개요
**재고실사(Stock Taking) 일정**을 관리하는 테이블.
년도별, 센터별 실사 계획을 수립하고, 실사 대상, 상태, 일정 등을 관리한다.

### 1.1 재고실사 일정 흐름
```
실사 계획 수립 → wms_st_sch 등록 → 실사 대상 지정(wms_st_target) → 실사 진행 → 실사 완료
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_sch_seq | integer | N | nextval('wms_st_sch_seq') | 재고실사 SEQ |
| | yyyy | varchar(4) | N | | 년도 |
| | biz_seq | integer | N | | 사업장 SEQ |
| | center_seq | integer | N | | 센터 SEQ |
| | st_idx | smallint | N | 0 | 재고실사 차수 |
| | st_target_cd | varchar(50) | N | | 재고실사 대상 코드 |
| | st_sch_sts_cd | varchar(50) | N | | 재고실사 상태 코드 |
| | st_exp_ymd | varchar(8) | Y | | 재고실사 예정 연월일 |
| | st_end_ymd | varchar(8) | Y | | 재고실사 종료 연월일 |
| | inven_fix_ymd | varchar(8) | Y | | 재고 고정 연월일 |
| | inven_fix_hms | varchar(6) | Y | | 재고 고정 시분초 |
| | note | varchar(1000) | Y | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **st_target_cd** (`ST_TARGET_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | CT | 센터별 | 센터 전체 실사 |
> | WH | 창고별 | 특정 창고만 실사 |

> **st_sch_sts_cd** (`ST_SCH_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 진행중 |
> | 77 | 완료 |

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
| wms_st_sch_PK | st_sch_seq | Y | Y |
| UK_wms_st_sch | yyyy, biz_seq, center_seq, st_idx | Y | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_sch_seq | wms_st_sch_seq |

---

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_st_target | st_sch_seq | wms_st_sch_TO_wms_st_target |
| wms_st_inven | st_sch_seq | wms_st_sch_TO_wms_st_inven |
| wms_st_tran | st_sch_seq | wms_st_sch_TO_wms_st_tran |

---

## 6. 업무 규칙

### 6.1 실사 계획 수립
- 년도별, 센터별 실사 계획 수립
- 동일 센터 내에서 년도별 차수(`st_idx`)로 구분
- 1년에 여러 번 실사 가능 (분기별, 반기별 등)

### 6.2 실사 대상 코드

| 코드 | 설명 | 실사 범위 |
|------|------|----------|
| CT | 센터별 | 해당 센터의 모든 창고/위치 |
| WH | 창고별 | 특정 창고만 실사 (wms_st_target에서 지정) |

### 6.3 실사 상태

| 상태 | 설명 |
|------|------|
| 11 | 예정 (실사 계획만 수립) |
| 55 | 진행중 (실사 작업 중) |
| 77 | 완료 (실사 종료, 조정 반영 완료) |

### 6.4 실사 일정
- `st_exp_ymd`: 실사 예정일
- `st_end_ymd`: 실사 실제 종료일
- `inven_fix_ymd`, `inven_fix_hms`: 재고 고정 시점
- 실사 시작 시점의 재고를 고정하여 실사 기준으로 사용

### 6.5 재고 고정
- 실사 시작 시 해당 시점의 재고를 고정
- 고정 이후의 재고 변동은 실사 결과와 별도로 관리
- 실사 중에도 입출고는 계속되나, 실사 기준 재고는 고정 시점 기준

### 6.6 실사 절차

#### 6.6.1 실사 계획 수립 (상태: 11)
- 실사 대상, 일정 결정
- 필요시 실사 대상 상세 지정 (wms_st_target)

#### 6.6.2 재고 고정
- 실사 시작 시점의 재고 스냅샷 생성
- `inven_fix_ymd`, `inven_fix_hms` 기록

#### 6.6.3 실사 진행 (상태: 55)
- 실제 재고 조사 수행
- wms_st_tran에 실사 결과 기록
- wms_st_inven에 고정 재고 정보 저장

#### 6.6.4 실사 완료 (상태: 77)
- 실사 결과와 장부 재고 비교
- 차이 발생 시 재고조정(AD) 처리
- 실사 종료일 기록

### 6.7 차수 관리
- 동일 년도, 동일 센터에서 여러 번 실사 시 차수로 구분
- 예: 1차(상반기), 2차(하반기), 3차(특별실사)

### 6.8 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'`로 논리삭제
- 완료된 실사 일정은 삭제 불가 (이력 보존)

---

## 7. 주요 조회 예시

```sql
-- 년도별 실사 계획 현황
SELECT yyyy,
       COUNT(*) AS total_plan,
       SUM(CASE WHEN st_sch_sts_cd = '11' THEN 1 ELSE 0 END) AS planned,
       SUM(CASE WHEN st_sch_sts_cd = '55' THEN 1 ELSE 0 END) AS in_progress,
       SUM(CASE WHEN st_sch_sts_cd = '77' THEN 1 ELSE 0 END) AS completed
FROM wms_st_sch
WHERE biz_seq = 1
AND del_yn = 'N'
GROUP BY yyyy
ORDER BY yyyy DESC;

-- 특정 센터의 실사 일정
SELECT st_sch_seq, yyyy, st_idx,
       st_target_cd, st_sch_sts_cd,
       st_exp_ymd, st_end_ymd,
       inven_fix_ymd, inven_fix_hms,
       note
FROM wms_st_sch
WHERE biz_seq = 1
AND center_seq = 1
AND del_yn = 'N'
ORDER BY yyyy DESC, st_idx DESC;

-- 진행중인 실사 일정
SELECT s.*, c.center_nm
FROM wms_st_sch s
    JOIN mdm_center c ON s.center_seq = c.center_seq
WHERE s.biz_seq = 1
AND s.st_sch_sts_cd = '55'
AND s.del_yn = 'N'
ORDER BY s.st_exp_ymd;

-- 실사 대상별 현황
SELECT st_target_cd,
       COUNT(*) AS plan_cnt,
       MIN(st_exp_ymd) AS earliest_exp,
       MAX(st_exp_ymd) AS latest_exp
FROM wms_st_sch
WHERE biz_seq = 1
AND del_yn = 'N'
GROUP BY st_target_cd
ORDER BY st_target_cd;

-- 특정 년월의 실사 계획
SELECT s.*, c.center_nm
FROM wms_st_sch s
    JOIN mdm_center c ON s.center_seq = c.center_seq
WHERE s.biz_seq = 1
AND s.st_exp_ymd LIKE '202502%'
AND s.del_yn = 'N'
ORDER BY s.st_exp_ymd;

-- 실사 완료 현황 (월별)
SELECT SUBSTR(st_end_ymd, 1, 6) AS end_yyyymm,
       COUNT(*) AS completed_cnt,
       AVG(TO_DATE(st_end_ymd, 'YYYYMMDD') - TO_DATE(st_exp_ymd, 'YYYYMMDD')) AS avg_duration_days
FROM wms_st_sch
WHERE biz_seq = 1
AND st_sch_sts_cd = '77'
AND del_yn = 'N'
GROUP BY SUBSTR(st_end_ymd, 1, 6)
ORDER BY end_yyyymm DESC;

-- 실사 지연 현황 (예정일 초과)
SELECT s.*, c.center_nm,
       CURRENT_DATE - TO_DATE(s.st_exp_ymd, 'YYYYMMDD') AS delay_days
FROM wms_st_sch s
    JOIN mdm_center c ON s.center_seq = c.center_seq
WHERE s.biz_seq = 1
AND s.st_sch_sts_cd IN ('11', '55')
AND s.st_exp_ymd < TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
AND s.del_yn = 'N'
ORDER BY s.st_exp_ymd;

-- 실사별 상세 정보 (대상 수 포함)
SELECT s.st_sch_seq, s.yyyy, s.st_idx,
       s.st_target_cd, s.st_sch_sts_cd,
       s.st_exp_ymd, s.st_end_ymd,
       COUNT(DISTINCT t.target_seq) AS target_cnt,
       COUNT(DISTINCT i.st_inven_seq) AS inven_cnt,
       COUNT(DISTINCT r.st_tran_seq) AS tran_cnt
FROM wms_st_sch s
    LEFT JOIN wms_st_target t ON s.st_sch_seq = t.st_sch_seq AND t.del_yn = 'N'
    LEFT JOIN wms_st_inven i ON s.st_sch_seq = i.st_sch_seq AND i.del_yn = 'N'
    LEFT JOIN wms_st_tran r ON s.st_sch_seq = r.st_sch_seq AND r.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.del_yn = 'N'
GROUP BY s.st_sch_seq, s.yyyy, s.st_idx, s.st_target_cd,
         s.st_sch_sts_cd, s.st_exp_ymd, s.st_end_ymd
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 최근 1년간 실사 추이
SELECT TO_CHAR(TO_DATE(st_end_ymd, 'YYYYMMDD'), 'YYYY-MM') AS month,
       COUNT(*) AS completed_cnt
FROM wms_st_sch
WHERE biz_seq = 1
AND st_sch_sts_cd = '77'
AND st_end_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '1 year', 'YYYYMMDD')
AND del_yn = 'N'
GROUP BY TO_CHAR(TO_DATE(st_end_ymd, 'YYYYMMDD'), 'YYYY-MM')
ORDER BY month;

-- 미실사 센터 체크 (당해연도 실사 이력 없는 센터)
SELECT c.center_seq, c.center_nm
FROM mdm_center c
    LEFT JOIN wms_st_sch s ON c.center_seq = s.center_seq 
        AND s.yyyy = TO_CHAR(CURRENT_DATE, 'YYYY')
        AND s.del_yn = 'N'
WHERE c.biz_seq = 1
AND c.use_yn = 'Y'
AND s.st_sch_seq IS NULL
ORDER BY c.center_seq;

-- 실사 소요 시간 분석
SELECT st_target_cd,
       AVG(TO_DATE(st_end_ymd, 'YYYYMMDD') - TO_DATE(st_exp_ymd, 'YYYYMMDD')) AS avg_duration,
       MIN(TO_DATE(st_end_ymd, 'YYYYMMDD') - TO_DATE(st_exp_ymd, 'YYYYMMDD')) AS min_duration,
       MAX(TO_DATE(st_end_ymd, 'YYYYMMDD') - TO_DATE(st_exp_ymd, 'YYYYMMDD')) AS max_duration
FROM wms_st_sch
WHERE biz_seq = 1
AND st_sch_sts_cd = '77'
AND st_end_ymd IS NOT NULL
AND del_yn = 'N'
GROUP BY st_target_cd;
```