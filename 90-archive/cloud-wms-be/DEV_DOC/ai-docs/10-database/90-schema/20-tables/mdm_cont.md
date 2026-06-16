# mdm_cont (MDM_거래처)

## 1. 개요
거래처(납품처, 공급처, 화주 등) 마스터. 입출하 업무에서 참조하는 거래처 기준정보.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | cont_seq | integer | N | nextval('mdm_cont_seq') | 거래처 SEQ |
| | if_cont_id | varchar(50) | Y | | IF 거래처 ID (외부 연동용) |
| | cont_no | varchar(30) | N | | 거래처 번호 |
| | cont_nm | varchar(100) | N | | 거래처 명 |
| | cont_nm_short | varchar(100) | Y | | 거래처 명 약칭 |
| | cont_div_cd | varchar(50) | Y | '3' | 거래처 구분 코드 |
| | ceo_nm | varchar(100) | Y | | 대표자 명 |
| | biz_no | varchar(20) | Y | | 사업자 번호 |
| | sub_biz_no | char(4) | Y | | 종 사업자 번호 |
| | cont_type | varchar(100) | Y | | 거래처 업태 |
| | cont_item | varchar(100) | Y | | 거래처 종목 |
| | email | varchar(100) | Y | | 이메일 |
| | tel | varchar(500) | Y | | 전화번호 |
| | fax | varchar(500) | Y | | 팩스 |
| | post_no | varchar(10) | Y | | 우편 번호 |
| | addr | varchar(200) | Y | | 주소 |
| | addr_dtl | varchar(200) | Y | | 주소 상세 |
| | manager_nm | varchar(100) | Y | | 담당자 |
| | rep_cont_seq | integer | Y | | 대표업체 SEQ (자기 참조) |
| | label_paper_seq | integer | Y | | 라벨용지 SEQ |
| | barcode_type_cd1 | varchar(50) | N | '16' | 1D 바코드 유형 코드 |
| | barcode_type_cd2 | varchar(50) | N | '32' | 2D 바코드 유형 코드 |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_cont_PK | cont_seq | Y | Y |

## 4. 업무 규칙
- `cont_div_cd` : 거래처 구분 (납품처, 공급처, 반품처 등) — 코드 테이블(sm_comm_d) 참조
- `rep_cont_seq` : 지점/지사 거래처의 경우 본사 거래처 SEQ를 참조하는 자기 참조
- `if_cont_id` : ERP 등 외부 시스템과 연동 시 외부 거래처 코드
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 |
|---|---|
| mdm_biz_cont | cont_seq |
| mdm_cont_prod | cont_seq |

## 6. 주요 조회 예시

```sql
-- 거래처 목록 조회
SELECT cont_seq, cont_no, cont_nm, cont_div_cd, biz_no
FROM mdm_cont
WHERE use_yn = 'Y'
ORDER BY cont_nm;

-- 특정 사업장에서 사용 가능한 거래처
SELECT c.cont_seq, c.cont_no, c.cont_nm
FROM mdm_biz_cont bc
    INNER JOIN mdm_cont c ON bc.cont_seq = c.cont_seq
WHERE bc.biz_seq = 1
AND bc.use_yn = 'Y'
AND c.use_yn = 'Y';
```
