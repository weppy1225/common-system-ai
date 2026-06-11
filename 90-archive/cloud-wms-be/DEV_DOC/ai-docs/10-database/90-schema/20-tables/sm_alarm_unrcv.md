
# sm_alarm_unrcv (시스템_알람_미수신)

## 1. 개요
사용자가 **알람 수신을 거부**한 메뉴 정보를 관리하는 테이블.
사용자별로 특정 메뉴의 알람을 받지 않도록 설정할 수 있다.

### 1.1 알람 미수신 설정 흐름
```
사용자 알람 수신 거부 설정 → sm_alarm_unrcv 등록 → 알람 발송 시 제외
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | user_id | varchar(20) | N | | 사용자 ID |
| PK | menu_cd | varchar(50) | N | | 메뉴 코드 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_alarm_unrcv_PK | user_id, menu_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 미수신 설정 등록
- 사용자가 특정 메뉴의 알람을 받지 않도록 설정
- 설정된 메뉴의 알람은 해당 사용자에게 발송되지 않음

### 4.2 미수신 설정 해제
- 해당 레코드 삭제로 미수신 설정 해제
- 삭제 후부터 알람 수신 재개

### 4.3 알람 발송 로직
```sql
-- 알람 발송 대상자 조회 시 미수신 설정자 제외
SELECT u.user_id
FROM mdm_user u
WHERE u.user_id NOT IN (
    SELECT user_id 
    FROM sm_alarm_unrcv 
    WHERE menu_cd = 'MENU001'
)
```

### 4.4 초기 설정
- 기본적으로 모든 사용자는 모든 알람 수신
- 사용자가 직접 미수신 메뉴 설정

---

## 5. 주요 조회 예시

```sql
-- 사용자별 미수신 설정 메뉴 조회
SELECT u.user_id, u.user_nm,
       au.menu_cd, m.menu_nm,
       au.reg_dt
FROM sm_alarm_unrcv au
    JOIN mdm_user u ON au.user_id = u.user_id
    JOIN sm_menu m ON au.menu_cd = m.menu_cd
ORDER BY u.user_id, au.menu_cd;

-- 특정 메뉴의 미수신 설정자 조회
SELECT u.user_id, u.user_nm, u.email
FROM sm_alarm_unrcv au
    JOIN mdm_user u ON au.user_id = u.user_id
WHERE au.menu_cd = 'MENU001';

-- 미수신 설정이 많은 메뉴 Top N
SELECT menu_cd, COUNT(*) AS unrcv_cnt
FROM sm_alarm_unrcv
GROUP BY menu_cd
ORDER BY unrcv_cnt DESC
LIMIT 10;
```

---
