
# sm_comm_d (시스템_공통코드_상세)

## 1. 개요
공통코드 헤더(`sm_comm_h`)에 속하는 **상세 코드 정보**를 관리하는 테이블.
각 코드별로 코드값, 코드명, 참조 관계, 표시 순서 등을 정의한다.

### 1.1 공통코드 상세 흐름
```
공통코드 헤더 등록 → sm_comm_d 상세 코드 등록 → 시스템 전반에서 코드 사용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | comm_h_cd | varchar(50) | N | | 상위 코드 |
| PK | comm_d_cd | varchar(50) | N | | 하위 코드 |
| | comm_d_nm | varchar(100) | N | | 하위 코드명 |
| | ref_h_cd | varchar(50) | Y | | 참조 상위 코드 |
| | ref_d_cd | varchar(50) | Y | | 참조 하위 코드 |
| | disp_no | smallint | N | 1 | 표시 순서 |
| | disp_yn | char(1) | N | 'Y' | 표시 여부 |
| | fr_val | varchar(100) | Y | | 시작 값 |
| | to_val | varchar(100) | Y | | 종료 값 |
| | note1 | varchar(100) | Y | | 비고 1 |
| | note2 | varchar(100) | Y | | 비고 2 |
| | note3 | varchar(100) | Y | | 비고 3 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **disp_yn**, **use_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사용/표시 |
> | N | 미사용/미표시 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_comm_d_PK | biz_seq, comm_h_cd, comm_d_cd | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq, comm_h_cd | sm_comm_h | biz_seq, comm_h_cd | sm_comm_h_TO_sm_comm_d |

---

## 5. 업무 규칙

### 5.1 상세 코드 등록
- 동일 헤더 코드 내에서 중복 코드 불가
- `disp_no`로 표시 순서 지정

### 5.2 코드 참조
- `ref_h_cd`, `ref_d_cd`로 다른 코드 참조 가능
- 계층적 코드 구조 구현 가능

### 5.3 표시 여부
- `disp_yn = 'N'`인 코드는 UI에 표시되지 않음
- 내부적으로만 사용되는 코드 관리

### 5.4 사용 여부
- `use_yn = 'N'`인 코드는 사용 불가
- 코드 폐기 시 사용 여부 변경

### 5.5 범위 코드
- `fr_val` ~ `to_val`로 범위를 가지는 코드 정의 가능
- 예: 할인율 구간, 점수 구간 등

### 5.6 비고 필드
- `note1`, `note2`, `note3`으로 추가 정보 저장
- 코드별 특성 저장에 활용

---

## 6. 주요 조회 예시

```sql
-- 특정 헤더 코드의 상세 코드 목록
SELECT comm_d_cd, comm_d_nm, disp_no, note1, note2, note3
FROM sm_comm_d
WHERE biz_seq = 1
AND comm_h_cd = 'INOUT_TYPE_CD'
AND use_yn = 'Y'
ORDER BY disp_no;

-- 코드명으로 코드 조회
SELECT comm_d_cd
FROM sm_comm_d
WHERE biz_seq = 1
AND comm_h_cd = 'OUTBIZ_TYPE_CD'
AND comm_d_nm LIKE '%일반출하%'
AND use_yn = 'Y';

-- 참조 관계를 가진 코드 조회
SELECT d.comm_d_cd, d.comm_d_nm,
       d.ref_h_cd, d.ref_d_cd,
       ref.comm_d_nm AS ref_nm
FROM sm_comm_d d
    LEFT JOIN sm_comm_d ref ON d.biz_seq = ref.biz_seq 
        AND d.ref_h_cd = ref.comm_h_cd 
        AND d.ref_d_cd = ref.comm_d_cd
WHERE d.biz_seq = 1
AND d.comm_h_cd = 'RETURN_TYPE_CD'
AND d.ref_h_cd IS NOT NULL;

-- 범위 코드 조회
SELECT comm_d_cd, comm_d_nm, fr_val, to_val
FROM sm_comm_d
WHERE biz_seq = 1
AND comm_h_cd = 'DISCOUNT_RATE'
AND fr_val IS NOT NULL
ORDER BY fr_val;
```

---
