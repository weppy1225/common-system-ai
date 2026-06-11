# mdm_biz (MDM_사업장)

## 1. 개요
WMS 운영 단위의 최상위 기준정보. 사업자등록증 기준의 사업장 단위.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | nextval('mdm_biz_seq') | 사업장 SEQ |
| | biz_nm | varchar(100) | N | | 사업장 명 |
| | biz_nm_short | varchar(100) | Y | | 사업장 명 약칭 |
| | ceo_nm | varchar(100) | Y | | 대표자 명 |
| | biz_no | varchar(20) | Y | | 사업자 번호 |
| | sub_biz_no | char(4) | Y | | 종 사업자 번호 |
| | biz_type | varchar(100) | Y | | 사업장 업태 |
| | biz_item | varchar(100) | Y | | 사업장 종목 |
| | biz_div_cd | varchar(50) | N | 'OWN' | 사업장 구분 코드 |
| | contract_ymd | varchar(8) | Y | | 계약일 (YYYYMMDD) |
| | hq_yn | char(1) | N | 'N' | 본사 여부 |
| | email | varchar(100) | Y | | 이메일 |
| | tel | varchar(500) | Y | | 전화번호 |
| | fax | varchar(500) | Y | | 팩스 |
| | post_no | varchar(10) | Y | | 우편 번호 |
| | addr | varchar(200) | Y | | 주소 |
| | addr_dtl | varchar(200) | Y | | 주소 상세 |
| | stamp_file_seq | integer | Y | | 직인 파일 SEQ |
| | logo_file_seq | integer | Y | | 로고 파일 SEQ |
| | if_biz_id | varchar(50) | Y | | IF 사업장 ID (외부 연동용) |
| | biz_color | varchar(50) | Y | '#00afec' | 사업장 색 |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_biz_PK | biz_seq | Y | Y |

## 4. 업무 규칙
- `hq_yn = 'Y'` 인 사업장은 전체 시스템 관리 권한 보유
- `biz_div_cd`: 'OWN'(자사), 'PARTNER'(파트너사) 등
- `biz_no + sub_biz_no` 조합 unique 관리 (운영 규칙)
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 5. 관계

| 구분 | 테이블 | 컬럼 |
|---|---|---|
| 참조됨 | mdm_biz_biz | biz_seq, ref_biz_seq |
| 참조됨 | mdm_biz_center | biz_seq, reg_biz_seq |
| 참조됨 | mdm_biz_cont | biz_seq |
| 참조됨 | mdm_biz_prod | biz_seq |
| 참조됨 | mdm_biz_wh | biz_seq |
| 참조됨 | mdm_car | biz_seq |
| 참조됨 | mdm_cont_prod | biz_seq |
| 참조됨 | mdm_doc_no | biz_seq |
| 참조됨 | mdm_rp_prod | biz_seq |
| 참조됨 | mdm_st_config | biz_seq |
| 참조됨 | mdm_st_prod | biz_seq |
| 참조됨 | mdm_user_biz | biz_seq |

## 6. 주요 조회 예시

```sql
-- 사용중인 사업장 목록
SELECT biz_seq, biz_nm, biz_no, hq_yn
FROM mdm_biz
WHERE use_yn = 'Y'
ORDER BY biz_nm;

-- 본사 조회
SELECT * FROM mdm_biz WHERE hq_yn = 'Y' AND use_yn = 'Y';
```
