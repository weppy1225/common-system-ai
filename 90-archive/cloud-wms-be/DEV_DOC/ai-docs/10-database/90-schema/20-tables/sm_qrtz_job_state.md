# sm_qrtz_job_state (시스템_쿼츠_작업_현황)

## 1. 개요
**쿼츠(Quartz) 스케줄러 작업의 현재 상태**를 관리하는 테이블.
각 작업의 마지막 실행 상태, 실행 시간 등을 저장하여 실시간 작업 모니터링 및 장애 감지에 활용한다.

### 1.1 쿼츠 작업 현황 흐름
```
쿼츠 작업 실행 → 작업 시작 시 상태 'RUNNING'으로 변경 → 작업 완료 시 'SUCCESS' 또는 'ERROR'로 변경
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | job_cls_nm | varchar(100) | N | | 작업 클래스명 |
| | job_nm | varchar(100) | Y | | 작업명 |
| | job_status_cd | varchar(100) | Y | | 작업 상태 코드 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 |
| | proc_hms | varchar(6) | Y | | 처리 시분초 |

> **job_status_cd** (`JOB_STATUS_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | RUNNING | 실행중 | 작업 현재 실행 중 |
> | SUCCESS | 성공 | 마지막 실행 성공 |
> | ERROR | 실패 | 마지막 실행 실패 |
> | STOPPED | 중지됨 | 작업이 중단됨 |
> | WAITING | 대기중 | 실행 대기 상태 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_qrtz_job_state_PK | job_cls_nm | Y | Y |

---

## 4. 업무 규칙

### 4.1 작업 상태 관리
- 각 작업의 현재 상태를 최신으로 유지
- 작업 실행 시 상태를 'RUNNING'으로 변경
- 작업 완료 시 'SUCCESS' 또는 'ERROR'로 변경
- 작업 중단 시 'STOPPED'로 변경

### 4.2 마지막 실행 시간
- `proc_ymd`, `proc_hms`: 마지막 실행 시간
- 작업 모니터링에 활용 (장시간 미실행 감지)

### 4.3 작업 식별
- `job_cls_nm`: Spring Bean 이름 또는 전체 클래스명 (PK)
- `job_nm`: 사용자 친화적 작업명 (표시용)

### 4.4 상태 모니터링
- `RUNNING` 상태가 장시간 지속되면 Hang 상태 의심
- `ERROR` 상태 반복 시 장애 알람 발생
- `STOPPED` 상태는 관리자 확인 필요

### 4.5 장애 감지
```sql
-- 1시간 이상 RUNNING 상태인 작업 감지
SELECT job_nm, job_cls_nm, proc_ymd, proc_hms
FROM sm_qrtz_job_state
WHERE job_status_cd = 'RUNNING'
AND TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '1 hour';
```

### 4.6 복구 로직
- 작업 실패 시 자동 재시작 정책 적용 가능
- 일정 횟수 이상 실패 시 관리자 알람

### 4.7 이력과의 관계
- `sm_qrtz_exec_log`: 상세 실행 이력
- `sm_qrtz_job_state`: 최신 상태만 관리

---

## 5. 주요 조회 예시

```sql
-- 전체 작업 상태 조회
SELECT job_cls_nm, job_nm, job_status_cd,
       proc_ymd, proc_hms,
       TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') AS last_exec_time
FROM sm_qrtz_job_state
ORDER BY job_cls_nm;

-- 실행중인 작업 조회
SELECT job_cls_nm, job_nm, proc_ymd, proc_hms,
       EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - 
           TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS'))) / 60 AS running_min
FROM sm_qrtz_job_state
WHERE job_status_cd = 'RUNNING'
ORDER BY running_min DESC;

-- 오류 발생 작업 조회
SELECT job_cls_nm, job_nm, proc_ymd, proc_hms
FROM sm_qrtz_job_state
WHERE job_status_cd = 'ERROR'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 중지된 작업 조회
SELECT job_cls_nm, job_nm, proc_ymd, proc_hms
FROM sm_qrtz_job_state
WHERE job_status_cd = 'STOPPED'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 장시간 미실행 작업 감지 (24시간 이상)
SELECT job_cls_nm, job_nm, job_status_cd,
       proc_ymd, proc_hms,
       EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - 
           TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS'))) / 3600 AS hours_ago
FROM sm_qrtz_job_state
WHERE TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '24 hours'
AND job_status_cd != 'STOPPED'
ORDER BY hours_ago DESC;

-- 상태별 작업 통계
SELECT job_status_cd,
       COUNT(*) AS job_cnt,
       MIN(proc_ymd) AS oldest_exec,
       MAX(proc_ymd) AS latest_exec
FROM sm_qrtz_job_state
GROUP BY job_status_cd
ORDER BY job_status_cd;

-- 특정 작업의 상세 상태
SELECT job_cls_nm, job_nm, job_status_cd,
       proc_ymd, proc_hms,
       CASE 
           WHEN job_status_cd = 'RUNNING' AND 
                TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '30 minutes' 
           THEN 'HANG_위험'
           WHEN job_status_cd = 'ERROR' THEN '오류발생'
           WHEN job_status_cd = 'SUCCESS' AND 
                TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') < CURRENT_DATE - INTERVAL '1 day'
           THEN '장시간미실행'
           ELSE '정상'
       END AS status_alert
FROM sm_qrtz_job_state
WHERE job_nm = '재고마감 배치작업'
OR job_cls_nm LIKE '%InvenClosingJob%';

-- 최근 상태 변경 내역 (시간순)
SELECT job_cls_nm, job_nm, job_status_cd,
       proc_ymd, proc_hms
FROM sm_qrtz_job_state
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 실패율이 높은 작업 분석
SELECT job_cls_nm, job_nm,
       COUNT(CASE WHEN job_status_cd = 'ERROR' THEN 1 END) AS error_count,
       COUNT(CASE WHEN job_status_cd = 'SUCCESS' THEN 1 END) AS success_count
FROM sm_qrtz_job_state
GROUP BY job_cls_nm, job_nm
HAVING COUNT(CASE WHEN job_status_cd = 'ERROR' THEN 1 END) > 0
ORDER BY error_count DESC;

-- 작업 유형별 상태 현황
SELECT
    CASE 
        WHEN job_cls_nm LIKE '%Inven%' THEN '재고관련'
        WHEN job_cls_nm LIKE '%Order%' THEN '주문관련'
        WHEN job_cls_nm LIKE '%Batch%' THEN '배치작업'
        ELSE '기타'
    END AS job_category,
    job_status_cd,
    COUNT(*) AS job_cnt
FROM sm_qrtz_job_state
GROUP BY
    CASE 
        WHEN job_cls_nm LIKE '%Inven%' THEN '재고관련'
        WHEN job_cls_nm LIKE '%Order%' THEN '주문관련'
        WHEN job_cls_nm LIKE '%Batch%' THEN '배치작업'
        ELSE '기타'
    END,
    job_status_cd
ORDER BY job_category, job_status_cd;

-- 정상 상태 작업 조회 (SUCCESS, 24시간 이내 실행)
SELECT job_cls_nm, job_nm, proc_ymd, proc_hms
FROM sm_qrtz_job_state
WHERE job_status_cd = 'SUCCESS'
AND TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 작업 복구 필요 목록 (ERROR 상태)
SELECT job_cls_nm, job_nm, proc_ymd, proc_hms,
       '수동 복구 필요' AS action_required
FROM sm_qrtz_job_state
WHERE job_status_cd = 'ERROR'
OR (job_status_cd = 'RUNNING' AND
       TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS') < CURRENT_TIMESTAMP - INTERVAL '2 hours')
ORDER BY proc_ymd DESC;
```