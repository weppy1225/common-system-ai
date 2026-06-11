# sm_user_pwd_history (시스템_비밀번호_변경_이력)

## 1. 개요
사용자 **비밀번호 변경 이력**을 관리하는 테이블.
비밀번호 재사용 제한 정책 적용을 위해 이전 비밀번호를 저장하며, 비밀번호 변경 내역 추적 및 보안 감사(Audit)에 활용한다.

### 1.1 비밀번호 변경 이력 흐름
```
비밀번호 변경 요청 → 이전 비밀번호 sm_user_pwd_history 저장 → 새 비밀번호 mdm_user에 저장
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | user_pwd_history_seq | integer | N | nextval('sm_user_pwd_history_seq') | 비밀번호 변경 이력 SEQ |
| | user_id | varchar(20) | N | | 사용자 ID |
| | password | varchar(500) | N | | 패스워드 (암호화) |
| | pwd_upd_date | timestamp | N | | 비밀번호 수정 일시 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_user_pwd_history_PK | user_pwd_history_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| user_pwd_history_seq | sm_user_pwd_history_seq |

---

## 5. 업무 규칙

### 5.1 이력 저장
- 사용자가 비밀번호를 변경할 때마다 **이전 비밀번호** 저장
- 최초 비밀번호 설정 시에도 이력 저장 (이전 비밀번호는 없음)
- 현재 사용 중인 비밀번호는 `mdm_user.password`에 저장

### 5.2 비밀번호 재사용 제한
- `sm_biz_config.pwd_reuse_lmt` 횟수만큼 이전 비밀번호와 비교
- 동일한 비밀번호 사용 불가 (설정된 횟수 이내)
- 예: `pwd_reuse_lmt = 3`이면 최근 3개 비밀번호와 중복 체크

```sql
-- 비밀번호 재사용 검증 로직 예시
SELECT COUNT(*)
FROM sm_user_pwd_history
WHERE user_id = 'user01'
AND password = :new_password
ORDER BY pwd_upd_date DESC
LIMIT :pwd_reuse_lmt;
```

### 5.3 이력 보관 기간
- 설정된 횟수만큼만 보관 (오래된 이력은 자동 삭제 또는 관리)
- 일반적으로 최근 N개 (기본 3개) 이력 유지
- 보안 정책에 따라 보관 기간 별도 설정 가능

### 5.4 암호화
- `password`는 반드시 **암호화(해시)**하여 저장
- 평문 비밀번호 저장 금지
- 동일한 암호화 알고리즘 사용 (mdm_user와 동일)

### 5.5 감사 추적
- 누가, 언제 비밀번호를 변경했는지 추적
- `reg_id`: 변경을 수행한 주체 (본인 또는 관리자)
- `pwd_upd_date`: 비밀번호 변경 시간

### 5.6 비밀번호 찾기/초기화
- 관리자에 의한 초기화 시에도 이력 저장
- 초기화된 비밀번호는 이후 변경 시 재사용 제한에 포함

### 5.7 보안 정책
- 비밀번호 이력은 무단 접근으로부터 보호 필요
- 암호화된 상태로 저장되므로 이력 조회만으로는 비밀번호 확인 불가

---

## 6. 주요 조회 예시

```sql
-- 특정 사용자의 비밀번호 변경 이력
SELECT user_pwd_history_seq, pwd_upd_date,
       reg_id, reg_dt
FROM sm_user_pwd_history
WHERE user_id = 'user01'
ORDER BY pwd_upd_date DESC;

-- 최근 비밀번호 이력 조회 (재사용 검증용)
SELECT password
FROM sm_user_pwd_history
WHERE user_id = 'user01'
ORDER BY pwd_upd_date DESC
LIMIT 3;

-- 특정 기간 내 변경 이력
SELECT user_id, pwd_upd_date, reg_id
FROM sm_user_pwd_history
WHERE pwd_upd_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY pwd_upd_date DESC;

-- 사용자별 비밀번호 변경 횟수
SELECT user_id, COUNT(*) AS change_cnt,
       MIN(pwd_upd_date) AS first_change,
       MAX(pwd_upd_date) AS last_change
FROM sm_user_pwd_history
GROUP BY user_id
ORDER BY change_cnt DESC;

-- 최근 변경자 목록
SELECT u.user_id, u.user_nm,
       h.pwd_upd_date,
       h.reg_id AS changed_by
FROM sm_user_pwd_history h
    JOIN mdm_user u ON h.user_id = u.user_id
WHERE h.pwd_upd_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY h.pwd_upd_date DESC;

-- 관리자에 의한 비밀번호 변경 이력 (reg_id != user_id)
SELECT h.user_pwd_history_seq,
       u.user_id, u.user_nm,
       h.pwd_upd_date,
       h.reg_id AS admin_id,
       a.user_nm AS admin_nm
FROM sm_user_pwd_history h
    JOIN mdm_user u ON h.user_id = u.user_id
    JOIN mdm_user a ON h.reg_id = a.user_id
WHERE h.reg_id != h.user_id
ORDER BY h.pwd_upd_date DESC;

-- 비밀번호 변경 많은 사용자 Top N
SELECT user_id, COUNT(*) AS change_cnt
FROM sm_user_pwd_history
GROUP BY user_id
ORDER BY change_cnt DESC
LIMIT 10;

-- 일자별 비밀번호 변경 현황
SELECT DATE(pwd_upd_date) AS change_date,
       COUNT(*) AS change_cnt
FROM sm_user_pwd_history
WHERE pwd_upd_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(pwd_upd_date)
ORDER BY change_date DESC;

-- 특정 사용자의 비밀번호 변경 패턴 분석
SELECT
    EXTRACT(HOUR FROM pwd_upd_date) AS change_hour,
    COUNT(*) AS change_cnt
FROM sm_user_pwd_history
WHERE user_id = 'user01'
GROUP BY EXTRACT(HOUR FROM pwd_upd_date)
ORDER BY change_hour;

-- 현재 비밀번호와 이전 비밀번호 동일 여부 체크 (보안 감사)
SELECT u.user_id, u.user_nm,
       u.pwd_upd_date AS current_pwd_date,
       h.pwd_upd_date AS old_pwd_date
FROM mdm_user u
    JOIN sm_user_pwd_history h ON u.user_id = h.user_id
WHERE u.password = h.password -- 암호화된 값 비교
AND u.pwd_upd_date > h.pwd_upd_date
ORDER BY u.user_id, h.pwd_upd_date DESC;

-- 미사용 계정의 비밀번호 이력 (계정 잠금/휴면)
SELECT h.user_id, u.user_nm,
       MAX(h.pwd_upd_date) AS last_pwd_change,
       u.lock_yn, u.dormancy_yn
FROM sm_user_pwd_history h
    JOIN mdm_user u ON h.user_id = u.user_id
WHERE u.use_yn = 'N' OR u.lock_yn = 'Y' OR u.dormancy_yn = 'Y'
GROUP BY h.user_id, u.user_nm, u.lock_yn, u.dormancy_yn
ORDER BY last_pwd_change DESC;

-- 전체 비밀번호 변경 통계
SELECT
    COUNT(DISTINCT user_id) AS total_users_changed,
    COUNT(*) AS total_changes,
    AVG(change_cnt.per_user) AS avg_changes_per_user
FROM (
    SELECT user_id, COUNT(*) AS per_user
    FROM sm_user_pwd_history
    GROUP BY user_id
) change_cnt;
```