# mdm_user (MDM_사용자)

## 1. 개요
WMS 시스템 사용자 마스터(NEW 버전).
로그인, 권한, 보안, 모바일 연동 등 사용자 관련 전반의 정보를 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | user_id | varchar(20) | N | | 사용자 ID |
| | if_emp_no | varchar(50) | Y | | IF 사원번호 (외부 연동용) |
| | password | varchar(500) | N | | 패스워드 (암호화 저장) |
| | user_nm | varchar(100) | N | | 사용자 명 |
| | dvsn_nm | varchar(100) | Y | | 부서 명 |
| | email | varchar(100) | Y | | 이메일 |
| | tel | bytea | Y | | 전화번호 (암호화) |
| FK | group_seq | integer | N | | 그룹 SEQ → sm_group.group_seq |
| FK | reg_biz_seq | integer | N | | 가입 사업장 SEQ → mdm_biz.biz_seq |
| FK | reg_center_seq | integer | Y | | 가입 센터 SEQ |
| | auth_type_cd | varchar(50) | N | | 권한 유형 코드 |
| | pwd_fail_cnt | integer | N | 0 | 비밀번호 실패 횟수 |
| | lock_yn | char(1) | N | 'N' | 잠금 여부 |
| | pwd_upd_date | timestamp | N | now() | 비밀번호 수정 일시 |
| | admin_yn | char(1) | N | 'N' | ADMIN 여부 |
| | disp_qty_cd | varchar(50) | N | 'ALL' | 표시 수량 코드 |
| | lpa_port | char(5) | N | '8888' | LPA 사용 포트 |
| | auth_no | varchar(50) | Y | | 인증번호 |
| | auth_time | timestamp | Y | | 인증시간 |
| | mobile_token | varchar(1000) | Y | | 모바일 토큰 |
| | dormancy_yn | char(1) | N | 'N' | 휴면회원 여부 |
| | last_login_dt | timestamp | N | now() | 마지막 로그인 일시 |
| | user_file_seq | integer | Y | | 사용자 프로필 파일 SEQ |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_user_PK | user_id | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| group_seq | sm_group | group_seq | sm_group_TO_mdm_user |

## 5. 업무 규칙
- `password` : BCrypt 등 단방향 암호화 저장
- `tel` : `bytea` 타입 — 개인정보 보호를 위해 암호화 저장
- `lock_yn = 'Y'` : 비밀번호 실패 횟수 초과 또는 관리자 잠금 처리
- `pwd_fail_cnt` : 일정 횟수(예: 5회) 초과 시 자동 잠금
- `admin_yn = 'Y'` : 시스템 전체 관리자
- `dormancy_yn = 'Y'` : 장기 미접속 휴면 계정
- `mobile_token` : 모바일 앱 FCM/APNS 토큰
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| mdm_user_biz | user_id | mdm_user_TO_mdm_user_biz |
| mdm_user_center | user_id | mdm_user_TO_mdm_user_center |

## 7. 주요 조회 예시

```sql
-- 활성 사용자 목록
SELECT user_id, user_nm, dvsn_nm, auth_type_cd, lock_yn, last_login_dt
FROM mdm_user
WHERE use_yn = 'Y'
AND dormancy_yn = 'N'
ORDER BY user_nm;

-- 잠금 처리된 사용자
SELECT user_id, user_nm, pwd_fail_cnt
FROM mdm_user
WHERE lock_yn = 'Y' AND use_yn = 'Y';
```
