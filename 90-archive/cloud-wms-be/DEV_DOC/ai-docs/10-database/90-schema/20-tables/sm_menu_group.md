# sm_menu_group (시스템_메뉴_그룹)

## 1. 개요
**메뉴와 그룹 간의 권한 관계**를 정의하는 테이블.
특정 그룹이 어떤 메뉴에 접근할 수 있는지, 어떤 권한(조회/등록/알람)을 가지는지 설정한다.

### 1.1 메뉴 그룹 권한 흐름
```
메뉴 등록 → 그룹 등록 → sm_menu_group으로 권한 부여 → 사용자 그룹 기준 메뉴 접근 제어
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | menu_cd | varchar(50) | N | | 메뉴 코드 |
| PK | group_seq | integer | N | | 그룹 SEQ |
| | ui_type_cd | varchar(50) | N | | UI 유형 코드 |
| | read_auth_yn | char(1) | N | 'Y' | 조회 권한 여부 |
| | create_auth_yn | char(1) | N | 'Y' | 등록 권한 여부 |
| | alarm_auth_yn | char(1) | N | 'N' | 알람 권한 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **ui_type_cd** (`UI_TYPE_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | P | 웹 | PC 웹 화면 |
> | M | 모바일 | 모바일/PDA 화면 |

> **read_auth_yn**, **create_auth_yn**, **alarm_auth_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 권한 있음 |
> | N | 권한 없음 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_menu_group_PK | menu_cd, group_seq | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| menu_cd | sm_menu | menu_cd | sm_menu_TO_sm_menu_group |
| group_seq | sm_group | group_seq | sm_group_TO_sm_menu_group |

---

## 5. 업무 규칙

### 5.1 권한 설정
- 메뉴별로 그룹에 권한 부여
- 권한은 조회(`read`), 등록(`create`), 알람(`alarm`)으로 구분

#### 5.1.1 권한 유형 설명

| 권한 | 코드 | 설명 |
|------|------|------|
| 조회권한 | read_auth_yn | 메뉴 조회/접근 권한 |
| 등록권한 | create_auth_yn | 데이터 등록/수정/삭제 권한 |
| 알람권한 | alarm_auth_yn | 메뉴 관련 알람 수신 권한 |

### 5.2 UI 유형별 권한
- `ui_type_cd`로 PC/모바일 구분하여 권한 별도 설정 가능
- 동일 메뉴라도 PC와 모바일 권한을 다르게 설정
- 예: 모바일에서는 조회만 가능, PC에서는 등록까지 가능

### 5.3 권한 상속
- 상위 메뉴(그룹) 권한이 하위 메뉴에 **상속되지 않음**
- 각 메뉴별로 명시적 권한 설정 필요
- 단, 그룹 메뉴(MG) 자체에 대한 접근 권한은 별도 관리

### 5.4 사업장 관리자
- `sm_group.biz_admin_yn = 'Y'`인 그룹은 모든 메뉴 권한 보유
- 별도 `sm_menu_group` 설정 불필요 (예외 처리)

### 5.5 권한 검증 로직
```sql
-- 특정 사용자의 메뉴 접근 권한 확인
SELECT
    CASE 
        WHEN g.biz_admin_yn = 'Y' THEN 'ALL'
        ELSE COALESCE(mg.read_auth_yn, 'N')
    END AS read_auth,
    CASE 
        WHEN g.biz_admin_yn = 'Y' THEN 'Y'
        ELSE COALESCE(mg.create_auth_yn, 'N')
    END AS create_auth
FROM mdm_user u
    JOIN sm_group g ON u.group_seq = g.group_seq
    LEFT JOIN sm_menu_group mg ON g.group_seq = mg.group_seq 
        AND mg.menu_cd = 'MENU001'
        AND mg.ui_type_cd = 'P'  -- PC UI
WHERE u.user_id = 'user01';
```

### 5.6 기본 권한
- 별도 권한 설정이 없는 메뉴는 접근 불가
- `read_auth_yn` 기본값 'Y'는 권한 설정 시에만 적용

### 5.7 삭제 처리
- 물리삭제 가능 (권한 변경 시)
- 그룹 삭제 시 관련 권한도 함께 삭제 처리 필요

---

## 6. 주요 조회 예시

```sql
-- 특정 그룹의 메뉴 권한 목록 (PC 웹)
SELECT mg.menu_cd, m.menu_nm, m.menu_type_cd,
       m.h_menu_cd, m.menu_idx,
       mg.read_auth_yn, mg.create_auth_yn, mg.alarm_auth_yn
FROM sm_menu_group mg
    JOIN sm_menu m ON mg.menu_cd = m.menu_cd
WHERE mg.group_seq = 1001
AND mg.ui_type_cd = 'P'
AND m.use_yn = 'Y'
ORDER BY m.h_menu_cd, m.menu_idx;

-- 특정 그룹의 메뉴 권한 목록 (모바일/PDA)
SELECT mg.menu_cd, m.menu_nm,
       mg.read_auth_yn, mg.create_auth_yn
FROM sm_menu_group mg
    JOIN sm_menu m ON mg.menu_cd = m.menu_cd
WHERE mg.group_seq = 1001
AND mg.ui_type_cd = 'M'
AND m.use_yn = 'Y'
ORDER BY m.pda_disp_no;

-- 특정 메뉴에 접근 가능한 그룹 목록
SELECT mg.group_seq, g.group_nm,
       mg.read_auth_yn, mg.create_auth_yn, mg.alarm_auth_yn,
       mg.ui_type_cd
FROM sm_menu_group mg
    JOIN sm_group g ON mg.group_seq = g.group_seq
WHERE mg.menu_cd = 'MENU001'
AND g.use_yn = 'Y'
ORDER BY g.group_seq;

-- 메뉴별 권한 설정 현황
SELECT m.menu_cd, m.menu_nm,
       COUNT(CASE WHEN mg.ui_type_cd = 'P' THEN 1 END) AS pc_group_cnt,
       COUNT(CASE WHEN mg.ui_type_cd = 'M' THEN 1 END) AS mobile_group_cnt,
       SUM(CASE WHEN mg.read_auth_yn = 'Y' THEN 1 ELSE 0 END) AS read_granted_cnt,
       SUM(CASE WHEN mg.create_auth_yn = 'Y' THEN 1 ELSE 0 END) AS create_granted_cnt
FROM sm_menu m
    LEFT JOIN sm_menu_group mg ON m.menu_cd = mg.menu_cd
WHERE m.use_yn = 'Y'
GROUP BY m.menu_cd, m.menu_nm
ORDER BY m.menu_cd;

-- PC와 모바일 권한이 다른 메뉴 조회
SELECT mg_p.menu_cd, m.menu_nm,
       mg_p.read_auth_yn AS pc_read,
       mg_m.read_auth_yn AS mobile_read,
       mg_p.create_auth_yn AS pc_create,
       mg_m.create_auth_yn AS mobile_create
FROM sm_menu_group mg_p
    JOIN sm_menu_group mg_m ON mg_p.menu_cd = mg_m.menu_cd 
        AND mg_p.group_seq = mg_m.group_seq
    JOIN sm_menu m ON mg_p.menu_cd = m.menu_cd
WHERE mg_p.ui_type_cd = 'P'
AND mg_m.ui_type_cd = 'M'
AND (mg_p.read_auth_yn != mg_m.read_auth_yn
       OR mg_p.create_auth_yn != mg_m.create_auth_yn);

-- 특정 사용자가 접근 가능한 메뉴 목록
SELECT DISTINCT m.menu_cd, m.menu_nm, m.menu_type_cd,
                m.h_menu_cd, m.menu_url,
                mg.ui_type_cd,
                mg.read_auth_yn, mg.create_auth_yn
FROM mdm_user u
    JOIN sm_group g ON u.group_seq = g.group_seq
    LEFT JOIN sm_menu_group mg ON g.group_seq = mg.group_seq
    JOIN sm_menu m ON mg.menu_cd = m.menu_cd
WHERE u.user_id = 'user01'
AND mg.ui_type_cd = 'P' -- PC UI
AND mg.read_auth_yn = 'Y'
AND m.use_yn = 'Y'

UNION ALL

-- 사업장 관리자는 모든 메뉴 접근 가능
SELECT m.menu_cd, m.menu_nm, m.menu_type_cd,
       m.h_menu_cd, m.menu_url,
       'P' AS ui_type_cd,
       'Y' AS read_auth_yn,
       'Y' AS create_auth_yn
FROM mdm_user u
    JOIN sm_group g ON u.group_seq = g.group_seq
    JOIN sm_menu m ON m.use_yn = 'Y'
WHERE u.user_id = 'user01'
AND g.biz_admin_yn = 'Y'
AND m.menu_type_cd = 'MN' -- 실행 메뉴만
ORDER BY h_menu_cd, menu_idx;

-- 그룹별 권한 부여 현황 (통계)
SELECT g.group_seq, g.group_nm,
       COUNT(DISTINCT mg.menu_cd) AS menu_cnt,
       SUM(CASE WHEN mg.read_auth_yn = 'Y' THEN 1 ELSE 0 END) AS read_cnt,
       SUM(CASE WHEN mg.create_auth_yn = 'Y' THEN 1 ELSE 0 END) AS create_cnt,
       SUM(CASE WHEN mg.alarm_auth_yn = 'Y' THEN 1 ELSE 0 END) AS alarm_cnt
FROM sm_group g
    LEFT JOIN sm_menu_group mg ON g.group_seq = mg.group_seq
WHERE g.use_yn = 'Y'
GROUP BY g.group_seq, g.group_nm
ORDER BY g.group_seq;

-- 권한이 없는 그룹/메뉴 조회 (설정 누락)
SELECT g.group_seq, g.group_nm, m.menu_cd, m.menu_nm
FROM sm_group g
    CROSS JOIN sm_menu m
    LEFT JOIN sm_menu_group mg ON g.group_seq = mg.group_seq 
        AND m.menu_cd = mg.menu_cd
WHERE g.use_yn = 'Y'
AND m.use_yn = 'Y'
AND m.menu_type_cd = 'MN' -- 실행 메뉴만
AND mg.menu_cd IS NULL
AND g.biz_admin_yn = 'N' -- 사업장 관리자 제외
ORDER BY g.group_seq, m.menu_cd;

-- 최근 권한 변경 이력
SELECT mg.mod_dt, mg.mod_id,
       g.group_nm, m.menu_nm,
       mg.read_auth_yn, mg.create_auth_yn, mg.alarm_auth_yn
FROM sm_menu_group mg
    JOIN sm_group g ON mg.group_seq = g.group_seq
    JOIN sm_menu m ON mg.menu_cd = m.menu_cd
WHERE mg.mod_dt >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY mg.mod_dt DESC;
```