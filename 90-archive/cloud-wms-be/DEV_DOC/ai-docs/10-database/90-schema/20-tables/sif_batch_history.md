# sif_batch_history (SIF_배치_이력)

## 1. 개요
외부 시스템(ERP, WES 등)과의 **배치 연동 이력**을 관리하는 테이블.
IF_ID별 요청/응답 데이터, 처리 상태, 에러 정보 등을 저장하여 연동 모니터링 및 장애 추적에 활용한다.

### 1.1 배치 이력 흐름
```
외부 연동 요청 발생 → sif_batch_history 저장 (요청 정보) → 외부 시스템 처리 → sif_batch_history 업데이트 (응답 정보)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | if_seq | integer | N | nextval('sif_batch_history_seq'::regclass) | IF SEQ |
| | biz_seq | integer | Y | | 사업장 SEQ |
| | if_id | varchar(50) | N | | IF ID |
| | if_nm | varchar(100) | N | | IF명 |
| | if_system_cd | varchar(50) | N | 'WMS' | IF 시스템 코드 |
| | if_type_cd | varchar(50) | N | 'N' | 배치 유형 코드 |
| | if_status_cd | varchar(50) | N | | 배치 상태 코드 |
| | req_ymd | varchar(8) | Y | | 요청 연월일 |
| | req_hms | varchar(6) | Y | | 요청 시분초 |
| | req_json_data | text | Y | | 요청 데이터 |
| | res_ymd | varchar(8) | Y | | 수신 연월일 |
| | res_hms | varchar(6) | Y | | 수신 시분초 |
| | res_json_data | text | Y | | 수신 데이터 |
| | res_cnt | integer | Y | 0 | 수신 카운터 |
| | sif_cnt | integer | Y | 0 | CIF 카운터 |
| | wms_cnt | integer | Y | 0 | WMS 카운터 |
| | err_key | text | Y | | 에러 키(수신시) |
| | err_msg | text | Y | | 에러 메시지 |
| | end_ymd | varchar(8) | Y | | 종료 연월일 |
| | end_hms | varchar(6) | Y | | 종료 시분초 |
| | re_send_yn | char(1) | N | 'N' | 재전송 유무 |
| | org_if_seq | integer | Y | | 원본 IF SEQ |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **if_system_cd** (`IF_SYSTEM_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | WMS | WMS 시스템 |
> | ERP | ERP 시스템 |
> | WES | WES 시스템 |
> | CIF | CIF 시스템 |

> **if_type_cd** (`IF_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 기타 |
> | REG | 등록 |
> | PROC | 처리 |
> | SCH | 조회 |

> **if_status_cd** (`IF_STATUS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | RUN | 진행중 |
> | OK | 성공 |
> | NG | 에러 |

> **re_send_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 재전송 |
> | N | 최초전송 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sif_batch_history_PK | if_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| if_seq | sif_batch_history_seq |

---

## 5. 업무 규칙

### 5.1 배치 이력 기록
- 외부 시스템 연동 시 요청/응답 정보 저장
- 배치 유형별(등록/처리/조회) 구분하여 관리

### 5.2 상태 코드

| 상태 | 설명 |
|------|------|
| RUN | 배치 처리 진행중 |
| OK | 배치 처리 성공 |
| NG | 배치 처리 실패 (에러 발생) |

### 5.3 요청/응답 데이터
- `req_json_data`: 외부 시스템으로 전송한 요청 데이터 (JSON 형식)
- `res_json_data`: 외부 시스템으로부터 수신한 응답 데이터 (JSON 형식)
- 대용량 데이터인 경우 텍스트 필드에 저장

### 5.4 카운터 정보

| 카운터 | 설명 |
|--------|------|
| res_cnt | 응답 건수 |
| sif_cnt | CIF 시스템 처리 건수 |
| wms_cnt | WMS 시스템 처리 건수 |

### 5.5 에러 정보
- `err_key`: 에러 발생 시 관련 키 값
- `err_msg`: 상세 에러 메시지
- 장애 분석 및 디버깅에 활용

### 5.6 재전송
- `re_send_yn = 'Y'`: 재전송된 배치 이력
- `org_if_seq`: 원본 배치 이력 SEQ (재전송 시 참조)
- 실패한 배치의 재처리 추적

### 5.7 처리 시간
- `req_ymd`, `req_hms`: 요청 시작 시간
- `res_ymd`, `res_hms`: 응답 수신 시간
- `end_ymd`, `end_hms`: 배치 종료 시간
- 처리 시간 = `end` - `req`로 성능 모니터링

### 5.8 보존 기간
- 배치 이력은 일정 기간 보관 (로그 정책에 따라)
- 오래된 이력은 별도 백업 후 삭제 가능

---

## 6. 주요 조회 예시

```sql
-- 최근 배치 이력 조회
SELECT if_seq, biz_seq, if_id, if_nm,
       if_system_cd, if_type_cd, if_status_cd,
       req_ymd, req_hms, res_ymd, res_hms,
       err_msg
FROM sif_batch_history
ORDER BY reg_dt DESC
LIMIT 100;

-- 특정 IF_ID의 배치 이력
SELECT if_seq, if_status_cd,
       req_ymd, req_hms, res_ymd, res_hms,
       res_cnt, sif_cnt, wms_cnt,
       err_msg
FROM sif_batch_history
WHERE if_id = 'IF001'
ORDER BY req_ymd DESC, req_hms DESC;

-- 실패한 배치 이력 조회
SELECT if_seq, biz_seq, if_id, if_nm,
       req_ymd, req_hms, err_key, err_msg,
       re_send_yn, org_if_seq
FROM sif_batch_history
WHERE if_status_cd = 'NG'
AND req_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
ORDER BY req_ymd DESC, req_hms DESC;

-- 일자별 배치 처리 현황
SELECT req_ymd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN if_status_cd = 'OK' THEN 1 ELSE 0 END) AS success_cnt,
       SUM(CASE WHEN if_status_cd = 'NG' THEN 1 ELSE 0 END) AS fail_cnt,
       SUM(CASE WHEN if_status_cd = 'RUN' THEN 1 ELSE 0 END) AS running_cnt
FROM sif_batch_history
WHERE req_ymd BETWEEN '20250201' AND '20250228'
GROUP BY req_ymd
ORDER BY req_ymd;

-- IF 시스템별 배치 현황
SELECT if_system_cd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN if_status_cd = 'OK' THEN 1 ELSE 0 END) AS success_cnt,
       ROUND(SUM(CASE WHEN if_status_cd = 'OK' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM sif_batch_history
WHERE req_ymd BETWEEN '20250201' AND '20250228'
GROUP BY if_system_cd
ORDER BY if_system_cd;

-- 배치 유형별 현황
SELECT if_type_cd,
       COUNT(*) AS total_cnt,
       AVG(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(end_ymd || end_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(req_ymd || req_hms, 'YYYYMMDDHH24MISS'))) AS avg_proc_time_sec
FROM sif_batch_history
WHERE if_status_cd = 'OK'
AND req_ymd BETWEEN '20250201' AND '20250228'
GROUP BY if_type_cd
ORDER BY if_type_cd;

-- 재전송 배치 이력 조회
SELECT org.if_seq AS org_if_seq, org.if_id, org.if_status_cd AS org_status,
       re.if_seq AS re_if_seq, re.if_status_cd AS re_status,
       re.req_ymd, re.res_ymd
FROM sif_batch_history re
    JOIN sif_batch_history org ON re.org_if_seq = org.if_seq
WHERE re.re_send_yn = 'Y'
ORDER BY re.req_ymd DESC;

-- 특정 사업장의 배치 현황
SELECT biz_seq,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN if_status_cd = 'OK' THEN 1 ELSE 0 END) AS success_cnt
FROM sif_batch_history
WHERE req_ymd = '20250226'
GROUP BY biz_seq
ORDER BY biz_seq;

-- 에러 유형별 통계
SELECT err_key,
       COUNT(*) AS err_cnt,
       MIN(req_ymd) AS first_err,
       MAX(req_ymd) AS last_err
FROM sif_batch_history
WHERE if_status_cd = 'NG'
AND err_key IS NOT NULL
GROUP BY err_key
ORDER BY err_cnt DESC;

-- 배치 응답 시간 분석
SELECT if_id, if_nm,
       COUNT(*) AS exec_cnt,
       AVG(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(res_ymd || res_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(req_ymd || req_hms, 'YYYYMMDDHH24MISS'))) AS avg_response_sec,
       MIN(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(res_ymd || res_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(req_ymd || req_hms, 'YYYYMMDDHH24MISS'))) AS min_response_sec,
       MAX(EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(res_ymd || res_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(req_ymd || req_hms, 'YYYYMMDDHH24MISS'))) AS max_response_sec
FROM sif_batch_history
WHERE if_status_cd = 'OK'
AND req_ymd BETWEEN '20250201' AND '20250228'
GROUP BY if_id, if_nm
ORDER BY avg_response_sec DESC;

-- 요청 데이터가 큰 배치 조회
SELECT if_seq, if_id,
       LENGTH(req_json_data) AS req_size,
       LENGTH(res_json_data) AS res_size,
       req_ymd, req_hms
FROM sif_batch_history
WHERE LENGTH(req_json_data) > 10000
OR LENGTH(res_json_data) > 10000
ORDER BY req_size DESC;

-- 시간대별 배치 실행 현황
SELECT SUBSTR(req_hms, 1, 2) AS hour,
       COUNT(*) AS exec_cnt
FROM sif_batch_history
WHERE req_ymd = '20250226'
GROUP BY SUBSTR(req_hms, 1, 2)
ORDER BY hour;
```