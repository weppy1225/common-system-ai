
# sm_api_config (시스템_API_설정)

## 1. 개요
외부 시스템과의 **API 연동 설정**을 관리하는 테이블.
IF_ID별로 API URL, 메소드, 요청 데이터 샘플 등을 정의한다.

### 1.1 API 설정 흐름
```
API 연동 필요 → sm_api_config 등록 → 외부 시스템 호출 시 설정 참조
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | if_id | varchar(50) | N | | IF ID |
| | if_nm | varchar(100) | N | | IF명 |
| | api_url_dev | varchar(512) | N | | API URL (개발) |
| | api_url_test | varchar(512) | N | | API URL (테스트) |
| | api_url | varchar(512) | N | | API URL (운영) |
| | api_method_cd | varchar(50) | N | | API 메소드 코드 |
| | if_type_cd | varchar(50) | N | 'N' | IF 유형 코드 |
| | if_proc_type_cd | varchar(50) | N | 'N' | IF 처리 유형 코드 |
| | req_json_data | text | Y | | 요청 데이터 샘플 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **api_method_cd** (`API_METHOD_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | GET | GET |
> | POST | POST |
> | PUT | PUT |
> | DELETE | DELETE |

> **if_type_cd** (`IF_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 기타 |
> | PROC | 처리 |
> | REG | 등록 |
> | SCH | 조회 |

> **if_proc_type_cd** (`IF_PROC_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 기타 |
> | SYNC | 동기 |
> | ASYNC | 비동기 |

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
| sm_api_config_PK | biz_seq, if_id | Y | Y |

---

## 4. 업무 규칙

### 4.1 API 설정 등록
- 외부 시스템과 연동이 필요한 API는 사전에 등록
- 개발/테스트/운영 환경별 URL 분리 관리

### 4.2 API 호출
- 연동 시 `biz_seq`와 `if_id`로 설정 조회
- 환경에 따라 적절한 URL 사용 (개발/테스트/운영)
- `api_method_cd`에 따라 HTTP 메소드 결정

### 4.3 IF 유형
- `REG`: 등록 API (데이터 생성)
- `PROC`: 처리 API (데이터 처리/변경)
- `SCH`: 조회 API (데이터 조회)
- `N`: 기타

### 4.4 요청 데이터 샘플
- `req_json_data`에 JSON 형식의 요청 샘플 저장
- API 개발 및 테스트 시 참조 자료로 활용

### 4.5 사용 여부
- `use_yn = 'N'`인 API는 호출 불가
- API 교체/폐기 시 사용 여부 변경

---

## 5. 주요 조회 예시

```sql
-- 특정 사업장의 API 설정 조회
SELECT if_id, if_nm, api_url, api_method_cd,
       if_type_cd, if_proc_type_cd, use_yn
FROM sm_api_config
WHERE biz_seq = 1
AND use_yn = 'Y'
ORDER BY if_id;

-- 환경별 URL 조회
SELECT if_id, if_nm,
       api_url_dev AS dev_url,
       api_url_test AS test_url,
       api_url AS prod_url
FROM sm_api_config
WHERE biz_seq = 1;

-- IF 유형별 설정 현황
SELECT if_type_cd,
       COUNT(*) AS config_cnt,
       SUM(CASE WHEN use_yn = 'Y' THEN 1 ELSE 0 END) AS active_cnt
FROM sm_api_config
WHERE biz_seq = 1
GROUP BY if_type_cd
ORDER BY if_type_cd;

-- 특정 IF_ID 설정 조회
SELECT *
FROM sm_api_config
WHERE biz_seq = 1
AND if_id = 'IF001';
```

---
