
# sm_log_api (시스템_로그_API)

## 1. 개요
API 호출에 대한 **로그**를 기록하는 테이블.
요청/응답 내용, 호출 시간, 사용자 정보 등을 저장하여 API 모니터링 및 디버깅에 활용한다.

### 1.1 API 로그 흐름
```
API 요청 발생 → sm_log_api 저장 (요청 정보) → API 처리 완료 → sm_log_api 업데이트 (응답 정보)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | log_api_seq | bigint | N | nextval('sm_log_api_seq') | API 로그 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | user_id | varchar(20) | N | | 사용자 ID |
| | methods | varchar(50) | N | | HTTP 메소드 |
| | menu_url | varchar(512) | N | | 메뉴 URL |
| | req_dt | timestamp | N | now() | 요청 일시 |
| | request_body | text | Y | | 요청 내용 |
| | query_param | text | Y | | 쿼리 파라미터 |
| | path_param | text | Y | | 패스 파라미터 |
| | res_dt | timestamp | Y | now() | 응답 일시 |
| | response_body | text | Y | | 응답 내용 |

> **methods** (`HTTP_METHOD`)
>
> | 코드 | 코드명 |
> |---|---|
> | GET | GET |
> | POST | POST |
> | PUT | PUT |
> | DELETE | DELETE |
> | PATCH | PATCH |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_log_api_PK | log_api_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| log_api_seq | sm_log_api_seq |

---

## 5. 업무 규칙

### 5.1 로그 저장
- API 요청 시점에 요청 정보 저장
- API 응답 완료 시 응답 정보 업데이트
- 대용량 로그는 별도 파티셔닝 고려

### 5.2 로그 수준
- 전체 API 로깅 또는 중요 API만 선택적 로깅 가능
- 요청/응답 본문은 크기 제한 고려

### 5.3 보안 고려사항
- 개인정보가 포함된 경우 마스킹 처리
- 비밀번호 등 민감 정보는 로깅 제외

### 5.4 로그 활용
- API 성능 모니터링 (응답 시간)
- 오류 분석 (5xx 에러)
- 사용자 행동 분석

---

## 6. 주요 조회 예시

```sql
-- 사용자별 API 호출 이력
SELECT log_api_seq, methods, menu_url, req_dt, res_dt
FROM sm_log_api
WHERE user_id = 'user01'
ORDER BY req_dt DESC
LIMIT 100;

-- 특정 기간 내 API 호출 현황
SELECT DATE(req_dt) AS call_date,
       methods,
       COUNT(*) AS call_cnt,
       AVG(EXTRACT(EPOCH FROM (res_dt - req_dt))) AS avg_response_sec
FROM sm_log_api
WHERE req_dt >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(req_dt), methods
ORDER BY call_date DESC, methods;

-- 에러 발생 API 조회 (응답 본문에 에러 포함)
SELECT log_api_seq, user_id, methods, menu_url, req_dt
FROM sm_log_api
WHERE response_body LIKE '%error%'
OR response_body LIKE '%exception%'
ORDER BY req_dt DESC;

-- 특정 URL 호출 이력
SELECT *
FROM sm_log_api
WHERE menu_url LIKE '%/api/orders%'
ORDER BY req_dt DESC;
```

---
