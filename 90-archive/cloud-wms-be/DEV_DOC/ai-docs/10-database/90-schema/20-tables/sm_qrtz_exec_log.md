# sm_qrtz_exec_log (시스템_쿼츠_실행_이력)

## 1. 개요
**쿼츠(Quartz) 스케줄러 작업의 실행 이력**을 관리하는 테이블.
작업 실행 시작/종료 시간, 실행 상태, 에러 메시지, 실행 인스턴스 정보 등을 기록하여 배치 작업 모니터링 및 장애 추적에 활용한다.

### 1.1 쿼츠 실행 이력 흐름
```
쿼츠 작업 실행 시작 → sm_qrtz_exec_log 저장 (시작 정보) → 작업 완료 → sm_qrtz_exec_log 업데이트 (종료 정보, 상태)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | qrtz_exec_log_seq | bigint | N | nextval('sm_qrtz_exec_log_seq') | 쿼츠 실행이력 SEQ |
| | instance_id | varchar(100) | Y | | 인스턴스 ID |
| | qrtz_status_cd | varchar(100) | Y | | 쿼츠 상태 코드 |
| | err_msg | text | Y | | 에러 메시지 |
| | job_nm | varchar(100) | Y | | 작업명 |
| | job_cls_nm | varchar(100) | Y | | 작업 클래스명 |
| | job_data | text | Y | | 작업 데이터 |
| | description | varchar(1000) | Y | | 설명 |
| | cron | varchar(100) | Y | | 크론 표현식 |
| | trigger_nm | varchar(100) | Y | | 트리거명 |
| | start_ymd | varchar(8) | Y | | 시작 연월일 |
| | start_hms | varchar(6) | Y | | 시작 시분초 |
| | end_ymd | varchar(8) | Y | | 종료 연월일 |
| | end_hms | varchar(6) | Y | | 종료 시분초 |

> **qrtz_status_cd** (`QRTZ_STATUS_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | SUCCESS | 성공 | 작업 정상 완료 |
> | ERROR | 실패 | 작업 오류 발생 |
> | RUNNING | 실행중 | 작업 진행 중 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_qrtz_exec_log_PK | qrtz_exec_log_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| qrtz_exec_log_seq | sm_qrtz_exec_log_seq |

---

## 5. 업무 규칙

### 5.1 실행 이력 기록
- 쿼츠 작업 실행 시 시작 정보 저장
- 작업 완료 시 종료 정보 및 상태 업데이트
- 실패 시 에러 메시지 상세 기록

### 5.2 실행 상태

| 상태 | 설명 | 비고 |
|------|------|------|
| RUNNING | 실행중 | 작업 시작 후 종료 전 |
| SUCCESS | 성공 | 작업 정상 완료 |
| ERROR | 실패 | 오류 발생 |

### 5.3 실행 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| instance_id | 실행 인스턴스 ID | 클러스터 환경에서 식별자 |
| job_nm | 작업명 | 사용자 정의 작업명 |
| job_cls_nm | 작업 클래스명 | 실제 실행 클래스 |
| trigger_nm | 트리거명 | 작업을 실행한 트리거 |
| cron | 크론 표현식 | 스케줄 정보 |

### 5.4 실행 시간
- `start_ymd`, `start_hms`: 작업 시작 시간
- `end_ymd`, `end_hms`: 작업 종료 시간
- 실행 시간 = `end` - `start`로 성능 모니터링

### 5.5 작업 데이터
- `job_data`: 작업 실행 시 전달된 파라미터 (JSON 형식)
- 동적 파라미터 확인 가능

### 5.6 설명
- `description`: 작업에 대한 부가 설명
- 로그 메시지 등 저장

### 5.7 에러 정보
- `err_msg`: 상세 에러 메시지 (Stack Trace 포함 가능)
- 장애 원인 분석에 활용

### 5.8 분산 환경
- `instance_id`로 여러 서버에서 실행되는 작업 구분
- 클러스터 환경에서 실행 위치 식별

---

## 6. 주요 조회 예시

```sql
-- 최근 실행 이력 조회
SELECT qrtz_exec_log_seq, job_nm, job_cls_nm,
       qrtz_status_cd, instance_id,
       start_ymd, start_hms, end_ymd, end_hms,
       err_msg
FROM sm_qrtz_exec_log
ORDER BY start_ymd DESC, start_hms DESC
LIMIT 100;

-- 실패한 작업 이력 조회
SELECT qrtz_exec_log_seq, job_nm,
       start_ymd, start_hms, end_ymd, end_hms,
       err_msg
FROM sm_qrtz_exec_log
WHERE qrtz_status_cd = 'ERROR'
AND start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
ORDER BY start_ymd DESC, start_hms DESC;

-- 특정 작업의 실행 이력
SELECT qrtz_exec_log_seq, qrtz_status_cd,
       start_ymd, start_hms, end_ymd, end_hms,
       EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) AS exec_sec,
       err_msg
FROM sm_qrtz_exec_log
WHERE job_nm = '재고마감 배치작업'
OR job_cls_nm LIKE '%InvenClosingJob%'
ORDER BY start_ymd DESC, start_hms DESC;

-- 일자별 작업 실행 통계
SELECT start_ymd,
       COUNT(*) AS exec_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'ERROR' THEN 1 ELSE 0 END) AS error_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'RUNNING' THEN 1 ELSE 0 END) AS running_cnt
FROM sm_qrtz_exec_log
WHERE start_ymd BETWEEN '20250201' AND '20250228'
GROUP BY start_ymd
ORDER BY start_ymd DESC;

-- 작업별 평균 실행 시간
SELECT job_nm,
       COUNT(*) AS exec_cnt,
       AVG(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) AS avg_exec_sec,
       MIN(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) AS min_exec_sec,
       MAX(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) AS max_exec_sec
FROM sm_qrtz_exec_log
WHERE qrtz_status_cd = 'SUCCESS'
AND start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
GROUP BY job_nm
ORDER BY avg_exec_sec DESC;

-- 인스턴스별 실행 현황
SELECT instance_id,
       COUNT(*) AS exec_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'ERROR' THEN 1 ELSE 0 END) AS error_cnt
FROM sm_qrtz_exec_log
WHERE start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
GROUP BY instance_id
ORDER BY exec_cnt DESC;

-- 시간대별 실행 집계
SELECT SUBSTR(start_hms, 1, 2) AS hour,
       COUNT(*) AS exec_cnt
FROM sm_qrtz_exec_log
WHERE start_ymd = TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
GROUP BY SUBSTR(start_hms, 1, 2)
ORDER BY hour;

-- 오래 실행 중인 작업 (30분 이상)
SELECT qrtz_exec_log_seq, job_nm, instance_id,
       start_ymd, start_hms,
       EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - 
           TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) / 60 AS running_min
FROM sm_qrtz_exec_log
WHERE qrtz_status_cd = 'RUNNING'
AND TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '30 minutes'
ORDER BY running_min DESC;

-- 성공률 분석
SELECT job_nm,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN qrtz_status_cd = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt,
       ROUND(SUM(CASE WHEN qrtz_status_cd = 'SUCCESS' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM sm_qrtz_exec_log
WHERE start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
GROUP BY job_nm
HAVING COUNT(*) > 5
ORDER BY success_rate;

-- 특정 트리거의 실행 이력
SELECT qrtz_exec_log_seq, job_nm,
       qrtz_status_cd, start_ymd, start_hms,
       end_ymd, end_hms
FROM sm_qrtz_exec_log
WHERE trigger_nm = 'dailyInvenClosingTrigger'
ORDER BY start_ymd DESC, start_hms DESC;

-- 작업 데이터 확인
SELECT qrtz_exec_log_seq, job_nm,
       job_data,
       start_ymd, start_hms
FROM sm_qrtz_exec_log
WHERE job_data IS NOT NULL
AND start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '3 days', 'YYYYMMDD')
ORDER BY start_ymd DESC, start_hms DESC;

-- 에러 메시지 검색
SELECT qrtz_exec_log_seq, job_nm,
       start_ymd, start_hms,
       SUBSTR(err_msg, 1, 500) AS err_msg_preview
FROM sm_qrtz_exec_log
WHERE err_msg LIKE '%NullPointerException%'
OR err_msg LIKE '%SQLException%'
OR err_msg LIKE '%Timeout%'
ORDER BY start_ymd DESC, start_hms DESC;

-- 동시 실행 현황 (같은 시간대 실행된 작업)
SELECT start_ymd, start_hms,
       COUNT(*) AS concurrent_cnt,
       LISTAGG(job_nm, ', ') WITHIN GROUP (ORDER BY job_nm) AS job_list
FROM sm_qrtz_exec_log
WHERE start_ymd = TO_CHAR(CURRENT_DATE, 'YYYYMMDD')
GROUP BY start_ymd, start_hms
HAVING COUNT(*) > 3
ORDER BY start_hms;

-- 주간 실행 추이
SELECT TO_CHAR(TO_DATE(start_ymd, 'YYYYMMDD'), 'WW') AS week,
       COUNT(*) AS exec_cnt,
       AVG(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(start_ymd || start_hms, 'YYYYMMDDHH24MISS'))) AS avg_exec_sec
FROM sm_qrtz_exec_log
WHERE start_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '90 days', 'YYYYMMDD')
GROUP BY TO_CHAR(TO_DATE(start_ymd, 'YYYYMMDD'), 'WW')
ORDER BY week;
```