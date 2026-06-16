
# sm_log_error (시스템_로그_에러)

## 1. 개요
시스템에서 발생한 **에러 로그**를 기록하는 테이블.
예외(Exception) 정보, 에러 메시지, HTTP 상태 코드 등을 저장하여 장애 분석에 활용한다.

### 1.1 에러 로그 흐름
```
에러 발생 → sm_log_error 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | log_error_seq | bigint | N | nextval('sm_log_conn_dtl_seq') | 에러 로그 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | user_id | varchar(20) | N | | 사용자 ID |
| | req_url | varchar(512) | N | | 요청 URL |
| | req_dt | timestamp | N | now() | 에러 발생 일시 |
| | err_type | varchar(100) | Y | | 에러 유형 (SwalType) |
| | err_title | varchar(100) | Y | | 에러 제목 (SwalTitle) |
| | err_text | text | Y | | 에러 내용 (SwalText) |
| | ex_nm | varchar(100) | Y | | 예외 클래스명 |
| | sts_cd | varchar(50) | Y | | HTTP 상태 코드 |
| | sts_nm | varchar(100) | Y | | HTTP 상태명 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_log_error_PK | log_error_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| log_error_seq | sm_log_error_seq |

---

## 5. 업무 규칙

### 5.1 에러 로그 기록
- 시스템 예외 발생 시 자동 저장
- 사용자 정의 에러(Validation 등)도 저장 가능

### 5.2 에러 정보
- `ex_nm`: Java Exception 클래스명 등
- `err_type`, `err_title`, `err_text`: 사용자 친화적 에러 메시지
- `sts_cd`, `sts_nm`: HTTP 응답 코드 (400, 500 등)

### 5.3 로그 분석
- 자주 발생하는 에러 패턴 분석
- 특정 사용자/URL에서 발생하는 에러 추적
- 장애 원인 분석 자료

---

## 6. 주요 조회 예시

```sql
-- 최근 에러 로그
SELECT log_error_seq, user_id, req_url, err_title, sts_cd, req_dt
FROM sm_log_error
ORDER BY req_dt DESC
LIMIT 100;

-- 에러 유형별 통계
SELECT ex_nm, sts_cd,
       COUNT(*) AS error_cnt,
       MIN(req_dt) AS first_error,
       MAX(req_dt) AS last_error
FROM sm_log_error
WHERE req_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ex_nm, sts_cd
ORDER BY error_cnt DESC;

-- 특정 사용자의 에러 이력
SELECT log_error_seq, req_url, err_text, req_dt
FROM sm_log_error
WHERE user_id = 'user01'
ORDER BY req_dt DESC;

-- 특정 URL에서 발생한 에러
SELECT log_error_seq, user_id, err_title, ex_nm, req_dt
FROM sm_log_error
WHERE req_url LIKE '%/api/orders%'
ORDER BY req_dt DESC;

-- HTTP 500 에러 집중 분석
SELECT DATE(req_dt) AS error_date,
       COUNT(*) AS error_cnt,
       COUNT(DISTINCT user_id) AS user_cnt
FROM sm_log_error
WHERE sts_cd = '500'
AND req_dt >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(req_dt)
ORDER BY error_date DESC;
```

---
