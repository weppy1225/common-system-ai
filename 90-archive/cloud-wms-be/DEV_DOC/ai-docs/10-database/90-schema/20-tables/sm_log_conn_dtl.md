
# sm_log_conn_dtl (시스템_로그_접근_상세)

## 1. 개요
접근 로그(`sm_log_conn`)의 **상세 정보**를 저장하는 테이블.
대용량 텍스트 데이터(요청 파라미터, 세션 정보 등)를 별도로 관리한다.

### 1.1 접근 로그 상세 흐름
```
접근 로그 저장 → 필요한 경우 상세 정보 sm_log_conn_dtl에 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | log_conn_seq | bigint | N | | 접근 로그 SEQ |
| | log_conn_dtl_text | text | Y | | 접근 로그 상세 내역 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_log_conn_dtl_PK | log_conn_seq | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| log_conn_seq | sm_log_conn | log_conn_seq | sm_log_conn_TO_sm_log_conn_dtl |

---

## 5. 업무 규칙

### 5.1 상세 정보 저장
- 접근 로그의 본문, 파라미터 등 대용량 텍스트 저장
- 로그 주 테이블의 부하를 줄이기 위한 별도 관리

### 5.2 저장 시점
- 접근 로그 저장 시 필요한 경우 함께 저장
- 또는 별도 배치로 상세 정보 수집

### 5.3 조회
- 기본 접근 로그 조회 시 상세 정보는 제외
- 필요 시 조인하여 상세 정보 확인

---

## 6. 주요 조회 예시

```sql
-- 특정 접근 로그의 상세 정보 조회
SELECT l.user_id, l.conn_type_cd, l.conn_dt,
       d.log_conn_dtl_text
FROM sm_log_conn l
    LEFT JOIN sm_log_conn_dtl d ON l.log_conn_seq = d.log_conn_seq
WHERE l.log_conn_seq = 1001;

-- 상세 정보가 있는 로그만 조회
SELECT l.log_conn_seq, l.user_id, l.conn_dt
FROM sm_log_conn l
    JOIN sm_log_conn_dtl d ON l.log_conn_seq = d.log_conn_seq
WHERE d.log_conn_dtl_text IS NOT NULL
ORDER BY l.conn_dt DESC;
```

---
