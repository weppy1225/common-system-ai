
# sm_group (시스템_그룹)

## 1. 개요
사용자 **권한 그룹**을 관리하는 테이블.
메뉴 접근 권한, 알람 수신 권한 등을 그룹 단위로 부여할 수 있다.

### 1.1 그룹 관리 흐름
```
그룹 생성 → sm_group 등록 → 메뉴 권한 부여(sm_menu_group) → 사용자 그룹 지정(mdm_user.group_seq)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | group_seq | integer | N | nextval('sm_group_seq') | 그룹 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | group_nm | varchar(100) | N | | 그룹명 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | biz_admin_yn | char(1) | N | 'N' | 사업장 관리자 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **biz_admin_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사업장 관리자 |
> | N | 일반 그룹 |

> **use_yn** (`USE_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사용 |
> | N | 미사용 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_group_PK | group_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| group_seq | sm_group_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_group |

---

## 6. 업무 규칙

### 6.1 그룹 생성
- 사업장별로 그룹 생성 가능
- 동일 사업장 내 그룹명 중복 가능 (식별은 group_seq)

### 6.2 사업장 관리자 그룹
- `biz_admin_yn = 'Y'`인 그룹은 사업장 관리자 권한
- 해당 사업장의 모든 메뉴에 접근 권한 보유
- 사업장 설정 변경 권한 보유

### 6.3 그룹 권한
- 메뉴 권한은 `sm_menu_group`에서 별도 관리
- 알람 권한은 `sm_alarm_unrcv` 등에서 활용

### 6.4 사용자 그룹 지정
- `mdm_user.group_seq`로 사용자의 그룹 지정
- 한 사용자는 하나의 그룹에만 속함

### 6.5 사용 여부
- `use_yn = 'N'`인 그룹은 신규 지정 불가
- 기존 사용자는 유지되나 권한 변경 없음

---

## 7. 주요 조회 예시

```sql
-- 사업장별 그룹 목록
SELECT group_seq, group_nm, biz_admin_yn, use_yn
FROM sm_group
WHERE biz_seq = 1
ORDER BY group_seq;

-- 사업장 관리자 그룹 조회
SELECT group_seq, group_nm
FROM sm_group
WHERE biz_seq = 1
AND biz_admin_yn = 'Y'
AND use_yn = 'Y';

-- 그룹별 사용자 수
SELECT g.group_seq, g.group_nm,
       COUNT(u.user_id) AS user_cnt
FROM sm_group g
    LEFT JOIN mdm_user u ON g.group_seq = u.group_seq
WHERE g.biz_seq = 1
GROUP BY g.group_seq, g.group_nm
ORDER BY g.group_seq;

-- 사용자 없는 그룹 조회
SELECT g.*
FROM sm_group g
    LEFT JOIN mdm_user u ON g.group_seq = u.group_seq
WHERE g.biz_seq = 1
AND u.user_id IS NULL;
```

---
