# mdm_user_biz (MDM_권한사업장)

## 1. 개요
사용자가 접근 가능한 사업장을 매핑하는 권한 테이블.
사용자는 복수의 사업장에 대한 권한을 가질 수 있다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| FK | user_id | varchar(20) | N | | 사용자 ID → mdm_user.user_id |
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| UK_mdm_user_biz | biz_seq, user_id | Y | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| user_id | mdm_user | user_id | mdm_user_TO_mdm_user_biz |
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_user_biz |

## 5. 업무 규칙
- 동일 `(user_id, biz_seq)` 조합 중복 불가 (UNIQUE)
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- `admin_yn = 'Y'` 사용자는 이 테이블 매핑 없이도 전체 사업장 접근 가능 (애플리케이션 레벨 처리)
- 로그인 후 접근 가능 사업장 목록 표시 시 이 테이블 기준으로 필터링

## 6. 주요 조회 예시

```sql
-- 특정 사용자의 권한 사업장 목록
SELECT ub.biz_seq, b.biz_nm
FROM mdm_user_biz ub
    INNER JOIN mdm_biz b ON ub.biz_seq = b.biz_seq
WHERE ub.user_id = 'admin01'
AND ub.use_yn = 'Y'
AND b.use_yn = 'Y';

-- 특정 사업장에 권한이 있는 사용자 목록
SELECT ub.user_id, u.user_nm, u.auth_type_cd
FROM mdm_user_biz ub
    INNER JOIN mdm_user u ON ub.user_id = u.user_id
WHERE ub.biz_seq = 1
AND ub.use_yn = 'Y'
AND u.use_yn = 'Y';
```
