# sm_qrtz_change_log (시스템_쿼츠_변경_이력)

## 1. 개요
**쿼츠(Quartz) 스케줄러 작업의 변경 이력**을 관리하는 테이블.
작업 추가, 일시중지, 재개, 삭제, 수정 등의 변경 내역을 기록하여 스케줄러 작업 변경 사항을 추적하고 감사(Audit)할 수 있다.

### 1.1 쿼츠 변경 이력 흐름
```
쿼츠 작업 변경 발생 (추가/수정/삭제/일시중지/재개) → sm_qrtz_change_log 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | qrtz_change_log_seq | bigint | N | nextval('sm_qrtz_change_log_seq') | 쿼츠 변경이력 SEQ |
| | job_nm | varchar(100) | Y | | 작업명 |
| | job_cls_nm | varchar(100) | Y | | 작업 클래스명 |
| | job_data | text | Y | | 작업 데이터 |
| | description | varchar(1000) | Y | | 설명 |
| | qrtz_type_cd | varchar(100) | Y | | 변경 유형 코드 |
| | cron | varchar(100) | Y | | 크론 표현식 |
| | trigger_nm | varchar(100) | Y | | 트리거명 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 |
| | proc_hms | varchar(6) | Y | | 처리 시분초 |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |

> **qrtz_type_cd** (`QRTZ_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | ADD | 작업 추가 | 새 작업 등록 |
> | REMOVE | 작업 삭제 | 작업 제거 |
> | PAUSE | 작업 일시중지 | 작업 일시 중단 |
> | RESUME | 작업 재개 | 중단된 작업 재시작 |
> | UPDATE | 작업 수정 | 스케줄/설정 변경 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_qrtz_change_log_PK | qrtz_change_log_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| qrtz_change_log_seq | sm_qrtz_change_log_seq |

---

## 5. 업무 규칙

### 5.1 변경 이력 기록
- 쿼츠 작업이 변경될 때마다 자동으로 이력 기록
- 수동 변경, 시스템에 의한 변경 모두 기록

### 5.2 변경 유형

| 유형 | 설명 | 적용场景 |
|------|------|---------|
| ADD | 작업 추가 | 새 배치 작업 등록 |
| REMOVE | 작업 삭제 | 작업 완전 제거 |
| PAUSE | 작업 일시중지 | 일시적으로 작업 중단 |
| RESUME | 작업 재개 | 중단된 작업 재시작 |
| UPDATE | 작업 수정 | 스케줄, 설정 변경 |

### 5.3 작업 정보

| 필드 | 설명 | 예시 |
|------|------|------|
| job_nm | 작업명 | '재고마감 배치작업' |
| job_cls_nm | 작업 클래스명 | 'com.wms.batch.InvenClosingJob' |
| cron | 크론 표현식 | '0 0 2 * * ?' (매일 새벽 2시) |
| trigger_nm | 트리거명 | 'invenClosingTrigger' |
| job_data | 작업 데이터 | JSON 형태의 파라미터 |

### 5.4 설명
- `description`: 변경 사유, 상세 설명 등
- 변경 내역에 대한 부가 정보 저장

### 5.5 처리 정보
- `proc_ymd`, `proc_hms`: 변경 처리 일시
- `proc_user_id`: 변경 수행자 ID

### 5.6 감사 추적
- 누가, 언제, 어떤 작업을 어떻게 변경했는지 추적
- 잘못된 변경 시 롤백 정보로 활용
- 보안 감사 및 컴플라이언스 대응

### 5.7 보존 기간
- 변경 이력은 장기 보관 (감사 목적)
- 필요시 별도 백업 후 삭제 가능

---

## 6. 주요 조회 예시

```sql
-- 최근 변경 이력 조회
SELECT qrtz_change_log_seq, job_nm, job_cls_nm,
       qrtz_type_cd, cron, trigger_nm,
       proc_ymd, proc_hms, proc_user_id,
       description
FROM sm_qrtz_change_log
ORDER BY proc_ymd DESC, proc_hms DESC
LIMIT 100;

-- 특정 작업의 변경 이력
SELECT qrtz_change_log_seq, qrtz_type_cd,
       cron, trigger_nm,
       proc_ymd, proc_hms, proc_user_id,
       description
FROM sm_qrtz_change_log
WHERE job_nm = '재고마감 배치작업'
OR job_cls_nm LIKE '%InvenClosingJob%'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 변경 유형별 통계
SELECT qrtz_type_cd,
       COUNT(*) AS change_cnt,
       MIN(proc_ymd) AS first_change,
       MAX(proc_ymd) AS last_change,
       COUNT(DISTINCT job_nm) AS job_cnt
FROM sm_qrtz_change_log
WHERE proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '90 days', 'YYYYMMDD')
GROUP BY qrtz_type_cd
ORDER BY qrtz_type_cd;

-- 특정 사용자의 변경 이력
SELECT qrtz_change_log_seq, job_nm,
       qrtz_type_cd, cron,
       proc_ymd, proc_hms,
       description
FROM sm_qrtz_change_log
WHERE proc_user_id = 'admin'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 일자별 변경 현황
SELECT proc_ymd,
       COUNT(*) AS change_cnt,
       COUNT(DISTINCT job_nm) AS job_cnt,
       COUNT(DISTINCT proc_user_id) AS user_cnt
FROM sm_qrtz_change_log
WHERE proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
GROUP BY proc_ymd
ORDER BY proc_ymd DESC;

-- 크론 표현식 변경 이력 추적
SELECT qrtz_change_log_seq, job_nm,
       qrtz_type_cd, cron,
       proc_ymd, proc_hms, proc_user_id
FROM sm_qrtz_change_log
WHERE cron IS NOT NULL
AND proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 작업별 최근 변경 내역
SELECT DISTINCT ON (job_nm)
       job_nm, job_cls_nm,
       qrtz_type_cd, cron,
       proc_ymd, proc_hms, proc_user_id,
       description
FROM sm_qrtz_change_log
WHERE job_nm IS NOT NULL
ORDER BY job_nm, proc_ymd DESC, proc_hms DESC;

-- 시간대별 변경 집계
SELECT SUBSTR(proc_hms, 1, 2) AS hour,
       COUNT(*) AS change_cnt
FROM sm_qrtz_change_log
WHERE proc_ymd = TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
GROUP BY SUBSTR(proc_hms, 1, 2)
ORDER BY hour;

-- 특정 기간의 상세 변경 내역
SELECT qrtz_change_log_seq, job_nm,
       qrtz_type_cd,
       CASE qrtz_type_cd
           WHEN 'ADD' THEN '작업 추가'
           WHEN 'REMOVE' THEN '작업 삭제'
           WHEN 'PAUSE' THEN '일시중지'
           WHEN 'RESUME' THEN '재개'
           WHEN 'UPDATE' THEN '수정'
           ELSE qrtz_type_cd
       END AS type_nm,
       cron, trigger_nm,
       proc_ymd, proc_hms, proc_user_id,
       description
FROM sm_qrtz_change_log
WHERE proc_ymd BETWEEN '20250201' AND '20250228'
ORDER BY proc_ymd, proc_hms;

-- 작업 데이터가 포함된 변경 이력
SELECT qrtz_change_log_seq, job_nm,
       qrtz_type_cd, proc_user_id,
       SUBSTR(job_data, 1, 200) AS job_data_preview
FROM sm_qrtz_change_log
WHERE job_data IS NOT NULL
AND proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 작업별 변경 횟수 순위
SELECT job_nm,
       COUNT(*) AS change_cnt,
       MAX(proc_ymd) AS last_change
FROM sm_qrtz_change_log
WHERE job_nm IS NOT NULL
GROUP BY job_nm
ORDER BY change_cnt DESC
LIMIT 20;

-- 변경 사유(설명) 검색
SELECT qrtz_change_log_seq, job_nm,
       qrtz_type_cd, proc_ymd, proc_hms,
       description
FROM sm_qrtz_change_log
WHERE description LIKE '%장애%'
OR description LIKE '%긴급%'
OR description LIKE '%배포%'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 동일 작업의 변경 패턴 분석
SELECT job_nm,
       qrtz_type_cd,
       COUNT(*) AS cnt,
       MIN(proc_ymd) AS first_occur,
       MAX(proc_ymd) AS last_occur
FROM sm_qrtz_change_log
GROUP BY job_nm, qrtz_type_cd
HAVING COUNT(*) > 1
ORDER BY job_nm, qrtz_type_cd;
```