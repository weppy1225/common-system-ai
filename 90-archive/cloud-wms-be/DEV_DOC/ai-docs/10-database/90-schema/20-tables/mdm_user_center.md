# mdm_user_center (MDM_권한센터)

## 1. 개요
사용자가 접근 가능한 물류센터를 매핑하는 권한 테이블.
사용자는 복수의 센터에 대한 권한을 가질 수 있다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| FK | user_id | varchar(20) | N | | 사용자 ID → mdm_user.user_id |
| FK | center_seq | integer | N | | 센터 SEQ → mdm_center.center_seq |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| UK_mdm_user_center | center_seq, user_id | Y | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| user_id | mdm_user | user_id | mdm_user_TO_mdm_user_center |
| center_seq | mdm_center | center_seq | mdm_center_TO_mdm_user_center |

## 5. 업무 규칙
- 동일 `(user_id, center_seq)` 조합 중복 불가 (UNIQUE)
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- 센터 기반 업무(입고/출고 등)에서 접근 가능 센터 필터링에 사용
- `mdm_user_biz`(사업장 권한)와 함께 이중 권한 체계 구성

## 6. 주요 조회 예시

```sql
-- 특정 사용자의 권한 센터 목록
SELECT uc.center_seq, c.center_nm, c.addr
FROM mdm_user_center uc
    INNER JOIN mdm_center c ON uc.center_seq = c.center_seq
WHERE uc.user_id = 'user01'
AND uc.use_yn = 'Y'
AND c.use_yn = 'Y';

-- 특정 센터에 권한 있는 사용자 목록
SELECT uc.user_id, u.user_nm, u.dvsn_nm
FROM mdm_user_center uc
    INNER JOIN mdm_user u ON uc.user_id = u.user_id
WHERE uc.center_seq = 1
AND uc.use_yn = 'Y'
AND u.use_yn = 'Y';
```
