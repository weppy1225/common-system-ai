
# sm_biz_config (시스템_사업장_설정)

## 1. 개요
사업장별 **시스템 환경 설정**을 관리하는 테이블.
메일 서버 설정, 비밀번호 정책, 세션 타임아웃, API KEY 등 사업장별로 다르게 적용되는 설정을 저장한다.

### 1.1 사업장 설정 흐름
```
사업장 생성 → sm_biz_config 기본 설정 등록 → 필요 시 설정 변경
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| | mail_host | varchar(512) | Y | | 메일 호스트 |
| | mail_port | char(5) | Y | | 메일 포트 |
| | mail_user | varchar(20) | Y | | 메일 사용자 |
| | mail_pass | bytea | Y | | 메일 패스워드 (암호화) |
| | mail_sender | varchar(20) | Y | | 메일 발신자 |
| | system_lock_cnt | smallint | N | 5 | 로그인 실패 허용 횟수 |
| | system_dormancy_cycle | smallint | N | 30 | 휴면 계정 전환 주기(일) |
| | system_pwd_cycle | smallint | N | 90 | 비밀번호 변경 주기(일) |
| | pwd_caps | char(1) | N | 'N' | 비밀번호 대문자 포함 |
| | pwd_small | char(1) | N | 'N' | 비밀번호 소문자 포함 |
| | pwd_num | char(1) | N | 'Y' | 비밀번호 숫자 포함 |
| | pwd_special | char(1) | N | 'N' | 비밀번호 특수문자 포함 |
| | pwd_min_len | smallint | N | 4 | 비밀번호 최소 길이 |
| | pwd_init | varchar(20) | N | '1111' | 초기 비밀번호 |
| | pwd_reuse_lmt | smallint | N | 3 | 비밀번호 재사용 제한 횟수 |
| | api_key | varchar(500) | Y | | API KEY |
| | api_key_exp_ymd | varchar(8) | Y | | API KEY 만료일 |
| | session_timeout_yn | char(1) | N | 'N' | 세션 타임아웃 사용 여부 |
| | session_timeout_minutes | smallint | Y | 0 | 세션 타임아웃 시간(분) |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **session_timeout_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 사용 |
> | N | 미사용 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_biz_config_PK | biz_seq | Y | Y |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_sm_biz_config |

---

## 5. 업무 규칙

### 5.1 메일 설정
- `mail_host`, `mail_port`: SMTP 서버 정보
- `mail_user`, `mail_pass`: 메일 서버 인증 정보
- `mail_sender`: 기본 발신자 주소
- `mail_pass`는 암호화하여 저장

### 5.2 비밀번호 정책

| 설정 | 설명 | 기본값 |
|------|------|--------|
| pwd_caps | 대문자 포함 여부 | N |
| pwd_small | 소문자 포함 여부 | N |
| pwd_num | 숫자 포함 여부 | Y |
| pwd_special | 특수문자 포함 여부 | N |
| pwd_min_len | 최소 길이 | 4 |
| pwd_reuse_lmt | 재사용 제한 횟수 | 3 |
| system_pwd_cycle | 변경 주기(일) | 90 |

### 5.3 계정 잠금 정책
- `system_lock_cnt`: 로그인 실패 시 계정 잠금 횟수
- 초과 시 `mdm_user.lock_yn = 'Y'`로 변경

### 5.4 휴면 계정 정책
- `system_dormancy_cycle`: 마지막 로그인 후 경과 시 휴면 전환
- 휴면 계정은 로그인 제한, 관리자 승인 필요

### 5.5 세션 타임아웃
- `session_timeout_yn = 'Y'`인 경우 `session_timeout_minutes` 적용
- 미사용 시 시스템 기본값 사용

### 5.6 API KEY 관리
- 외부 시스템 연동용 API KEY 발급
- `api_key_exp_ymd`로 만료일 관리
- 만료 전 갱신 필요

---

## 6. 주요 조회 예시

```sql
-- 특정 사업장 설정 조회
SELECT *
FROM sm_biz_config
WHERE biz_seq = 1;

-- 메일 설정 조회
SELECT mail_host, mail_port, mail_user, mail_sender
FROM sm_biz_config
WHERE biz_seq = 1;

-- 비밀번호 정책 조회
SELECT pwd_caps, pwd_small, pwd_num, pwd_special,
       pwd_min_len, pwd_reuse_lmt, system_pwd_cycle
FROM sm_biz_config
WHERE biz_seq = 1;

-- 세션 타임아웃 설정 조회
SELECT session_timeout_yn, session_timeout_minutes
FROM sm_biz_config
WHERE biz_seq = 1;

-- API KEY 정보 조회 (만료일 포함)
SELECT api_key, api_key_exp_ymd
FROM sm_biz_config
WHERE biz_seq = 1;
```

---
