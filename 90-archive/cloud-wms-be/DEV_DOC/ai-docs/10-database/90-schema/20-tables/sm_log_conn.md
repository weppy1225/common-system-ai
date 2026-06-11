
# sm_log_conn (시스템_로그_접근)

## 1. 개요
사용자의 **시스템 접근 로그**를 기록하는 테이블.
로그인/로그아웃, 로그인 실패, 계정 잠금 등 접근 관련 이벤트를 저장한다.

### 1.1 접근 로그 흐름
```
사용자 접근 이벤트 발생 → sm_log_conn 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | log_conn_seq | bigint | N | nextval('sm_log_conn_seq') | 접근 로그 SEQ |
| | user_id | varchar(20) | N | | 사용자 ID |
| | conn_dt | timestamp | N | | 접근 일시 |
| | conn_type_cd | varchar(50) | N | | 접근 유형 코드 |
| | ip_addr | varchar(40) | N | | IP 주소 |
| | user_agent | varchar(200) | N | | 사용자 기기 정보 |
| | device_type | varchar(100) | N | | 기기 유형 |
| | os_type | varchar(100) | N | | 운영체제 |
| | browser_type | varchar(100) | N | | 브라우저 |
| | proc_user_id | varchar(20) | Y | '-' | 처리자 ID |

> **conn_type_cd** (`LOG_CONN_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | LOGIN | 로그인 성공 |
> | LOGOUT | 로그아웃 |
> | LOGIN_NG_NO_ACCOUNT | 계정 없음 |
> | LOGIN_NG_PWD_DISMATCH | 비밀번호 불일치 |
> | LOGIN_NG_DORMANCY | 휴면 계정 |
> | LOGIN_NG_LOCK | 잠긴 계정 |
> | LOGIN_NG_UNUSE | 미사용 계정 |
> | ACCOUNT_LOCKED | 계정 잠금 |
> | ACCOUNT_DORMANT | 계정 휴면 |
> | RESET_PWD | 비밀번호 초기화 |
> | CHANGE_ACCOUNT_AUTH | 권한 변경 |
> | ADD_NEW_ACCOUNT | 계정 신규 추가 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_log_conn_PK | log_conn_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| log_conn_seq | sm_log_conn_seq |

---

## 5. 업무 규칙

### 5.1 접근 로그 기록
- 모든 접근 이벤트(성공/실패) 기록
- 로그인/로그아웃은 기본 기록
- 보안 정책에 따라 상세 로깅

### 5.2 IP 정보
- IPv4/IPv6 모두 저장 가능
- 프록시 서버 사용 시 실제 클라이언트 IP 확인 필요

### 5.3 기기 정보 파싱
- `user_agent`에서 `device_type`, `os_type`, `browser_type` 추출
- 모바일/데스크톱 구분, 브라우저 종류 등 분석

### 5.4 처리자 ID
- 관리자에 의한 강제 작업(계정 잠금 해제 등) 시 `proc_user_id`에 관리자 ID 저장

### 5.5 보안 분석
- 반복된 로그인 실패 추적
- 의심스러운 IP 차단 근거 자료
- 사용자 접근 패턴 분석

---

## 6. 주요 조회 예시

```sql
-- 사용자별 최근 접근 이력
SELECT log_conn_seq, conn_type_cd, conn_dt, ip_addr, device_type
FROM sm_log_conn
WHERE user_id = 'user01'
ORDER BY conn_dt DESC
LIMIT 50;

-- 로그인 실패 이력 조회
SELECT user_id, conn_dt, ip_addr, conn_type_cd
FROM sm_log_conn
WHERE conn_type_cd LIKE 'LOGIN_NG%'
ORDER BY conn_dt DESC;

-- 특정 IP의 접근 이력
SELECT user_id, conn_type_cd, conn_dt, device_type
FROM sm_log_conn
WHERE ip_addr = '192.168.1.1'
ORDER BY conn_dt DESC;

-- 일자별 접근 통계
SELECT DATE(conn_dt) AS conn_date,
       COUNT(*) AS total_conn,
       SUM(CASE WHEN conn_type_cd = 'LOGIN' THEN 1 ELSE 0 END) AS login_success,
       SUM(CASE WHEN conn_type_cd LIKE 'LOGIN_NG%' THEN 1 ELSE 0 END) AS login_fail
FROM sm_log_conn
WHERE conn_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(conn_dt)
ORDER BY conn_date DESC;

-- 기기별 접근 통계
SELECT device_type, os_type, browser_type,
       COUNT(*) AS conn_cnt
FROM sm_log_conn
GROUP BY device_type, os_type, browser_type
ORDER BY conn_cnt DESC;
```

---
