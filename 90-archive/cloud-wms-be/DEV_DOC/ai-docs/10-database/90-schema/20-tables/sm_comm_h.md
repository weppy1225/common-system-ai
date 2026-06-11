
# sm_comm_h (시스템_공통코드)

## 1. 개요
시스템에서 사용하는 **공통코드의 헤더(그룹)** 정보를 관리하는 테이블.
각 코드 그룹의 특성(사용자 정의 가능 여부, 수정 가능 여부 등)을 정의한다.

### 1.1 공통코드 헤더 흐름
```
공통코드 그룹 정의 → sm_comm_h 등록 → sm_comm_d 상세 코드 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | comm_h_cd | varchar(50) | N | | 상위 코드 |
| | comm_h_nm | varchar(100) | N | | 상위 코드명 |
| | user_cd_yn | char(1) | N | 'N' | 사용자 코드 여부 |
| | user_edit_yn | char(1) | N | 'N' | 사용자 수정 여부 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | inout_cd | varchar(50) | Y | | 수불 유형 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **user_cd_yn**, **user_edit_yn**, **use_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 예 |
> | N | 아니오 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_comm_h_PK | biz_seq, comm_h_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 코드 헤더 등록
- 사업장별로 코드 그룹 정의
- 동일 사업장 내에서 코드 그룹 중복 불가

### 4.2 사용자 코드 여부 (`user_cd_yn`)
- `Y`: 사용자가 코드값을 추가/정의 가능
- `N`: 시스템에서 미리 정의한 코드만 사용

### 4.3 사용자 수정 여부 (`user_edit_yn`)
- `Y`: 사용자가 코드명 등을 수정 가능
- `N`: 시스템 관리자만 수정 가능

### 4.4 수불 유형 연동
- `inout_cd`: 해당 코드가 수불 유형과 연관된 경우
- 재고 수불 이력과의 연관성 정의

### 4.5 사용 여부
- `use_yn = 'N'`인 코드 그룹은 사용 불가
- 하위 상세 코드도 함께 사용 중지

---

## 5. 주요 조회 예시

```sql
-- 사업장별 공통코드 헤더 목록
SELECT comm_h_cd, comm_h_nm, user_cd_yn, user_edit_yn, use_yn
FROM sm_comm_h
WHERE biz_seq = 1
AND use_yn = 'Y'
ORDER BY comm_h_cd;

-- 사용자 정의 가능한 코드 헤더 조회
SELECT comm_h_cd, comm_h_nm
FROM sm_comm_h
WHERE biz_seq = 1
AND user_cd_yn = 'Y'
AND use_yn = 'Y'
ORDER BY comm_h_cd;

-- 수불 유형과 연관된 코드 헤더 조회
SELECT comm_h_cd, comm_h_nm, inout_cd
FROM sm_comm_h
WHERE biz_seq = 1
AND inout_cd IS NOT NULL
AND use_yn = 'Y'
ORDER BY comm_h_cd;

-- 특정 코드 헤더 상세 정보
SELECT *
FROM sm_comm_h
WHERE biz_seq = 1
AND comm_h_cd = 'OUTBIZ_TYPE_CD';
```

---
