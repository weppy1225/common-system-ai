# sm_push_unrcv (시스템_푸시_미수신)

## 1. 개요
사용자가 **푸시 알림 수신을 거부**한 유형을 관리하는 테이블.
사용자별로 특정 푸시 유형의 알림을 받지 않도록 설정할 수 있다.

### 1.1 푸시 미수신 설정 흐름
```
사용자 푸시 수신 거부 설정 → sm_push_unrcv 등록 → 푸시 발송 시 제외
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | user_id | varchar(20) | N | | 사용자 ID |
| PK | push_type_cd | varchar(50) | N | | 푸시 유형 코드 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |

> **push_type_cd** (`PUSH_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | 1 | 알람 | 일반 알람 푸시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_push_unrcv_PK | user_id, push_type_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 미수신 설정 등록
- 사용자가 특정 유형의 푸시 알림을 받지 않도록 설정
- 설정된 유형의 푸시는 해당 사용자에게 발송되지 않음
- 사용자별 복수 유형 설정 가능

### 4.2 미수신 설정 해제
- 해당 레코드 삭제로 미수신 설정 해제
- 삭제 후부터 푸시 수신 재개

### 4.3 푸시 발송 로직
```sql
-- 특정 푸시 유형 발송 시 미수신 설정자 제외
SELECT u.user_id, u.mobile_token, u.user_nm
FROM mdm_user u
WHERE u.user_id IN (
    SELECT DISTINCT user_id
    FROM mdm_user_center uc
    WHERE uc.center_seq IN (1, 2, 3)  -- 대상 센터
)
AND u.user_id NOT IN (
    SELECT user_id 
    FROM sm_push_unrcv 
    WHERE push_type_cd = '1'  -- 알람 유형
)
AND u.mobile_token IS NOT NULL;
```

### 4.4 그룹/센터 필터링과의 관계
- 미수신 설정은 개인 사용자 단위
- 그룹/센터 단위 필터링 이후 개인 미수신 설정 적용

### 4.5 기본값
- 기본적으로 모든 사용자는 모든 푸시 수신
- 사용자가 직접 미수신 설정 필요

### 4.6 감사 추적
- `reg_id`, `reg_dt`로 설정자 및 설정 시간 추적
- 누가, 언제 미수신 설정했는지 확인 가능

---

## 5. 주요 조회 예시

```sql
-- 사용자별 푸시 미수신 설정 조회
SELECT u.user_id, u.user_nm,
       pu.push_type_cd,
       CASE pu.push_type_cd
           WHEN '1' THEN '알람'
           ELSE pu.push_type_cd
       END AS push_type_nm,
       pu.reg_id AS setting_user,
       pu.reg_dt AS setting_dt
FROM sm_push_unrcv pu
    JOIN mdm_user u ON pu.user_id = u.user_id
ORDER BY u.user_id, pu.push_type_cd;

-- 특정 푸시 유형의 미수신 설정자 수
SELECT push_type_cd,
       COUNT(*) AS user_cnt
FROM sm_push_unrcv
GROUP BY push_type_cd
ORDER BY push_type_cd;

-- 특정 사용자의 미수신 설정 조회
SELECT pu.push_type_cd,
       CASE pu.push_type_cd
           WHEN '1' THEN '알람'
           ELSE pu.push_type_cd
       END AS push_type_nm,
       pu.reg_dt
FROM sm_push_unrcv pu
WHERE pu.user_id = 'user01'
ORDER BY pu.push_type_cd;

-- 푸시 미수신 설정이 많은 사용자 Top N
SELECT user_id, COUNT(*) AS setting_cnt
FROM sm_push_unrcv
GROUP BY user_id
ORDER BY setting_cnt DESC
LIMIT 10;

-- 특정 그룹의 미수신 설정 현황
SELECT u.user_id, u.user_nm,
       pu.push_type_cd,
       pu.reg_dt
FROM mdm_user u
    JOIN sm_push_unrcv pu ON u.user_id = pu.user_id
WHERE u.group_seq = 10
ORDER BY u.user_id, pu.push_type_cd;

-- 특정 센터의 미수신 설정 현황
SELECT u.user_id, u.user_nm,
       uc.center_seq, c.center_nm,
       pu.push_type_cd,
       pu.reg_dt
FROM mdm_user u
    JOIN mdm_user_center uc ON u.user_id = uc.user_id
    JOIN mdm_center c ON uc.center_seq = c.center_seq
    JOIN sm_push_unrcv pu ON u.user_id = pu.user_id
WHERE uc.center_seq = 1
ORDER BY u.user_id, pu.push_type_cd;

-- 최근 등록된 미수신 설정
SELECT pu.user_id, u.user_nm,
       pu.push_type_cd,
       pu.reg_id, pu.reg_dt
FROM sm_push_unrcv pu
    JOIN mdm_user u ON pu.user_id = u.user_id
WHERE pu.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY pu.reg_dt DESC;

-- 미수신 설정자 비율 계산
SELECT
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT pu.user_id) AS unrcv_users,
    ROUND(COUNT(DISTINCT pu.user_id) * 100.0 / NULLIF(COUNT(DISTINCT u.user_id), 0), 2) AS unrcv_rate
FROM mdm_user u
    LEFT JOIN sm_push_unrcv pu ON u.user_id = pu.user_id
WHERE u.use_yn = 'Y';

-- 푸시 유형별 미수신 설정자 비율
SELECT
    cd.comm_d_cd AS push_type_cd,
    cd.comm_d_nm AS push_type_nm,
    COUNT(DISTINCT pu.user_id) AS unrcv_cnt
FROM sm_comm_d cd
    LEFT JOIN sm_push_unrcv pu ON cd.comm_d_cd = pu.push_type_cd
WHERE cd.comm_h_cd = 'PUSH_TYPE_CD'
AND cd.use_yn = 'Y'
GROUP BY cd.comm_d_cd, cd.comm_d_nm, cd.disp_no
ORDER BY cd.disp_no;

-- 미수신 설정이 없는 사용자 (모든 푸시 수신)
SELECT u.user_id, u.user_nm, u.group_seq
FROM mdm_user u
WHERE u.use_yn = 'Y'
AND u.user_id NOT IN (
      SELECT DISTINCT user_id
      FROM sm_push_unrcv
)
ORDER BY u.user_id;

-- 특정 사용자가 특정 푸시 유형을 미수신 설정했는지 확인
SELECT CASE
           WHEN COUNT(*) > 0 THEN '미수신'
           ELSE '수신'
       END AS push_status
FROM sm_push_unrcv
WHERE user_id = 'user01'
AND push_type_cd = '1';

-- 등록자별 미수신 설정 현황 (관리자 분석)
SELECT reg_id,
       COUNT(*) AS setting_cnt,
       COUNT(DISTINCT user_id) AS user_cnt,
       MIN(reg_dt) AS first_setting,
       MAX(reg_dt) AS last_setting
FROM sm_push_unrcv
GROUP BY reg_id
ORDER BY setting_cnt DESC;
```