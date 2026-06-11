# wms_st_target (WMS_재고실사_대상)

## 1. 개요
**재고실사 대상(창고, 위치 등)**을 관리하는 테이블.
실사 일정(`wms_st_sch`)에 따라 실제 실사가 필요한 대상을 지정한다.

### 1.1 재고실사 대상 흐름
```
실사 계획 수립 → 실사 대상 지정(wms_st_target) → 실사 진행 → 실사 결과 기록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_target_seq | integer | N | nextval('wms_st_target_seq') | 재고실사 대상 SEQ |
| PK/FK | st_sch_seq | integer | N | | 재고실사 SEQ |
| | target_seq | integer | N | | 대상 SEQ |
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
| wms_st_target_PK | st_target_seq, st_sch_seq | Y | Y |
| IX_wms_st_target | st_sch_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_target_seq | wms_st_target_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_sch_seq | wms_st_sch | st_sch_seq | wms_st_sch_TO_wms_st_target |

---

## 6. 업무 규칙

### 6.1 대상 구분
`target_seq`의 의미는 실사 대상 코드(`st_target_cd`)에 따라 달라짐:

| st_target_cd | target_seq 의미 | 참조 테이블 |
|--------------|----------------|------------|
| CT (센터별) | 사용하지 않음 (전체) | - |
| WH (창고별) | 창고 SEQ | mdm_wh |

### 6.2 대상 지정 방식

#### 6.2.1 센터별 실사 (CT)
- `st_target_cd = 'CT'`인 경우 별도 대상 지정 없이 센터 전체 실사
- `wms_st_target`에 레코드 없음 또는 특별 코드 사용

#### 6.2.2 창고별 실사 (WH)
- `st_target_cd = 'WH'`인 경우 실사할 창고를 개별 지정
- 하나의 실사 일정에 여러 창고 지정 가능

### 6.3 실사 범위
- 창고가 지정되면 해당 창고의 모든 위치(`mdm_loc`)가 실사 대상
- 특정 위치만 실사해야 하는 경우 별도 처리 필요

### 6.4 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'`로 논리삭제
- 실사 완료 후 대상 정보는 이력으로 보존

---

## 7. 주요 조회 예시

```sql
-- 특정 실사 일정의 대상 목록
SELECT t.st_target_seq, t.target_seq,
       w.wh_nm AS target_name
FROM wms_st_target t
    LEFT JOIN mdm_wh w ON t.target_seq = w.wh_seq
WHERE t.st_sch_seq = 1001
AND t.del_yn = 'N'
ORDER BY t.target_seq;

-- 실사 일정별 대상 수
SELECT s.st_sch_seq, s.yyyy, s.st_idx,
       s.st_target_cd,
       COUNT(t.st_target_seq) AS target_cnt
FROM wms_st_sch s
    LEFT JOIN wms_st_target t ON s.st_sch_seq = t.st_sch_seq 
        AND t.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.del_yn = 'N'
GROUP BY s.st_sch_seq, s.yyyy, s.st_idx, s.st_target_cd
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 창고별 실사 이력
SELECT t.target_seq AS wh_seq, w.wh_nm,
       COUNT(t.st_target_seq) AS sch_cnt,
       MIN(s.st_exp_ymd) AS first_sch,
       MAX(s.st_exp_ymd) AS last_sch
FROM wms_st_target t
    JOIN wms_st_sch s ON t.st_sch_seq = s.st_sch_seq
    JOIN mdm_wh w ON t.target_seq = w.wh_seq
WHERE s.biz_seq = 1
AND t.del_yn = 'N'
AND s.del_yn = 'N'
GROUP BY t.target_seq, w.wh_nm
ORDER BY w.wh_nm;

-- 특정 창고의 실사 일정 조회
SELECT s.st_sch_seq, s.yyyy, s.st_idx,
       s.st_sch_sts_cd, s.st_exp_ymd, s.st_end_ymd
FROM wms_st_target t
    JOIN wms_st_sch s ON t.st_sch_seq = s.st_sch_seq
WHERE t.target_seq = 10 -- 창고 SEQ
AND t.del_yn = 'N'
AND s.del_yn = 'N'
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 실사 대상이 없는 일정 조회 (센터별 실사 제외)
SELECT s.*
FROM wms_st_sch s
    LEFT JOIN wms_st_target t ON s.st_sch_seq = t.st_sch_seq AND t.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.st_target_cd = 'WH'
AND t.st_target_seq IS NULL
AND s.del_yn = 'N'
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 실사 진행률 (대상별 완료 여부)
SELECT s.st_sch_seq, s.yyyy, s.st_idx,
       COUNT(t.st_target_seq) AS total_target,
       SUM(CASE WHEN i.st_inven_seq IS NOT NULL THEN 1 ELSE 0 END) AS completed_target
FROM wms_st_sch s
    LEFT JOIN wms_st_target t ON s.st_sch_seq = t.st_sch_seq AND t.del_yn = 'N'
    LEFT JOIN wms_st_inven i ON s.st_sch_seq = i.st_sch_seq 
        AND t.target_seq = i.wh_seq 
        AND i.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.del_yn = 'N'
GROUP BY s.st_sch_seq, s.yyyy, s.st_idx
ORDER BY s.yyyy DESC, s.st_idx DESC;

-- 최근 실사 대상 창고 Top N
SELECT t.target_seq, w.wh_nm,
       COUNT(*) AS sch_cnt
FROM wms_st_target t
    JOIN mdm_wh w ON t.target_seq = w.wh_seq
    JOIN wms_st_sch s ON t.st_sch_seq = s.st_sch_seq
WHERE s.biz_seq = 1
AND s.yyyy = TO_CHAR(CURRENT_DATE, 'YYYY')
AND t.del_yn = 'N'
AND s.del_yn = 'N'
GROUP BY t.target_seq, w.wh_nm
ORDER BY sch_cnt DESC
LIMIT 10;
```