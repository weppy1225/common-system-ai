
# sm_dlv_config (시스템_택배_설정)

## 1. 개요
**택배사 연동 설정**을 관리하는 테이블.
택배사 코드, 송장 발급 방식, 토큰 정보, 송장 번호 대역 등을 정의한다.

### 1.1 택배 설정 흐름
```
택배사 계약 → sm_dlv_config 등록 → 출하 시 택배 설정 적용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | dlv_config_seq | integer | N | nextval('sm_dlv_config_seq') | 택배 설정 SEQ |
| | center_seq | integer | N | | 출고센터 SEQ |
| | contract_biz_seq | integer | N | | 계약 사업장 SEQ |
| | dlv_co_cd | varchar(50) | N | | 택배 업체 코드 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | cust_id | varchar(20) | Y | | 고객 ID |
| | biz_no | varchar(20) | Y | | 사업자 번호 |
| | invoice_assign_type_cd | varchar(50) | N | 'MANUAL' | 송장 발급 유형 코드 |
| | token_num | varchar(50) | Y | | 토큰 번호 |
| | token_exprtn_dtm | varchar(14) | Y | | 토큰 유효 일시 |
| | invoice_no_start | varchar(30) | Y | | 송장 번호 시작 |
| | invoice_no_end | varchar(30) | Y | | 송장 번호 종료 |
| | invoice_no_current | varchar(30) | Y | | 송장 번호 현재값 |
| | invoice_no_add | varchar(30) | Y | | 송장 번호 추가 대역 |
| | box_type_cd | varchar(50) | Y | | 박스 유형 코드 |
| | frt_dv_cd | varchar(50) | Y | | 운임 구분 코드 |
| | frt | varchar(50) | Y | | 운임 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **dlv_co_cd** (`DLV_CO_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | CJ | CJ대한통운 |
> | CP | 쿠팡택배 |
> | HJ | 한진택배 |
> | LG | 로젠택배 |
> | LT | 롯데택배 |

> **invoice_assign_type_cd** (`INVOICE_ASSIGN_TYPE`)
>
> | 코드 | 코드명 |
> |---|---|
> | MANUAL | 수기등록 |
> | API | API 발급 |
> | RANGE | 대역대 할당 |

> **box_type_cd** (`BOX_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 01 | 극소 |
> | 02 | 소 |
> | 03 | 중 |
> | 04 | 대 |
> | 05 | 특대 |

> **frt_dv_cd** (`FRT_DV_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 01 | 선불 |
> | 02 | 착불 |
> | 03 | 신용 |

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
| sm_dlv_config_PK | dlv_config_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| dlv_config_seq | sm_dlv_config_seq |

---

## 5. 업무 규칙

### 5.1 송장 발급 유형

| 유형 | 설명 |
|------|------|
| MANUAL | 사용자가 수기로 송장번호 입력 |
| API | 택배사 API로 실시간 발급 |
| RANGE | 할당된 번호 대역에서 순차 사용 |

### 5.2 송장 번호 관리 (RANGE 유형)
- `invoice_no_start` ~ `invoice_no_end`: 사용 가능한 번호 대역
- `invoice_no_current`: 현재까지 사용된 마지막 번호
- `invoice_no_add`: 추가 대역 (기존 대역 소진 시)

### 5.3 토큰 관리 (API 유형)
- `token_num`: 택배사 API 인증 토큰
- `token_exprtn_dtm`: 토큰 만료 일시
- 만료 전 자동 갱신 로직 필요

### 5.4 사용 여부
- `use_yn = 'N'`인 설정은 출하 시 선택 불가
- 계약 종료 시 사용 여부 변경

---

## 6. 주요 조회 예시

```sql
-- 센터별 사용 가능한 택배 설정
SELECT d.dlv_config_seq, d.dlv_co_cd, d.invoice_assign_type_cd,
       d.cust_id, d.biz_no,
       a.disp_no AS priority
FROM sm_dlv_config d
    JOIN sm_dlv_config_applied a ON d.dlv_config_seq = a.dlv_config_seq
WHERE d.center_seq = 1
AND d.use_yn = 'Y'
ORDER BY a.disp_no;

-- 송장 번호 대역 조회 (RANGE 유형)
SELECT invoice_no_start, invoice_no_end, invoice_no_current
FROM sm_dlv_config
WHERE dlv_config_seq = 1001
AND invoice_assign_type_cd = 'RANGE';

-- API 연동 설정 조회
SELECT dlv_co_cd, cust_id, token_num, token_exprtn_dtm
FROM sm_dlv_config
WHERE dlv_config_seq = 1001
AND invoice_assign_type_cd = 'API';

-- 택배사별 설정 현황
SELECT dlv_co_cd,
       COUNT(*) AS config_cnt,
       SUM(CASE WHEN use_yn = 'Y' THEN 1 ELSE 0 END) AS active_cnt
FROM sm_dlv_config
GROUP BY dlv_co_cd
ORDER BY dlv_co_cd;
```

---
