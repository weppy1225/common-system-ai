# mdm_prod (MDM_품목)

## 1. 개요
WMS에서 관리하는 품목(상품) 마스터.
SKU 관리 방식(유통기한/LOT/일련번호 등), 단위, 분류, 라벨 설정 등 품목의 핵심 기준정보를 포함한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | prod_seq | integer | N | nextval('mdm_prod_seq') | 품목 SEQ |
| | if_prod_id | varchar(50) | Y | | IF 품목 ID (외부 연동용) |
| | prod_no | varchar(30) | N | | 품목 번호 |
| | prod_nm | varchar(100) | N | | 품목 명 |
| | prod_nm_short | varchar(100) | Y | | 품목 명 약칭 |
| | prod_size | varchar(100) | Y | | 품목 규격 |
| | prod_div_cd | varchar(50) | Y | | 품목 분류 코드 |
| | large_cd | varchar(50) | Y | | 대분류 코드 |
| | middle_cd | varchar(50) | Y | | 중분류 코드 |
| | small_cd | varchar(50) | Y | | 소분류 코드 |
| | sku_mng_cd | varchar(50) | N | 'N' | SKU 관리 유형 코드 |
| | mng_ymd_mng_yn | char(1) | N | 'N' | 제조일자 관리 여부 |
| | eff_mng_yn | char(1) | N | 'Y' | 유통기한 관리 여부 |
| | eff_base | smallint | Y | 60 | 유효 기준 (숫자) |
| | eff_base_unit_cd | varchar(50) | Y | 'DAYS' | 유효기준 단위 코드 (DAYS/MONTHS 등) |
| | lot_no_mng_yn | char(1) | N | 'N' | LOT번호 관리 여부 |
| | cn_mng_yn | char(1) | N | 'N' | CN(일련번호) 관리 여부 |
| | sku2_mng_yn | char(1) | N | 'N' | 파렛트 관리 여부 |
| | unit_cd | varchar(50) | N | 'EA' | 단위 코드 |
| | parent_unit_nm | varchar(100) | Y | | 상위 단위 명 (박스 단위 명) |
| | in_qty | smallint | N | 1 | 입수량 (박스당 EA 수) |
| | imm_days | smallint | N | 90 | 임박일수 |
| | prod_barcode | varchar(100) | Y | | 품목 바코드 |
| | parent_barcode | varchar(100) | Y | | 상위(박스) 바코드 |
| | pallet_stack_qty | smallint | N | 1 | 팔레트 적재수량 |
| | pallet_bottom_qty | smallint | N | 1 | 팔레트 하단수량 |
| FK | file_seq | integer | Y | | 파일 SEQ → sm_file.file_seq |
| | label_paper_seq | integer | Y | | 라벨용지 SEQ → mdm_label_paper.label_paper_seq |
| | parent_label_paper_seq | integer | Y | | 상위(박스) 라벨용지 SEQ → mdm_label_paper.label_paper_seq |
| | qc_yn | char(1) | Y | 'N' | QC 여부 |
| | cfd_cd | varchar(50) | Y | 'D' | 통관 코드 |
| | hs_code | varchar(50) | Y | | HS 코드 |
| | abc_cd | varchar(50) | Y | 'D' | ABC 분류 코드 |
| | net_weight | numeric(10,2) | Y | 0 | 순중량 (kg) |
| | unit_pack_qty | smallint | Y | 1 | 단위 팩 수량 |
| | origin_cd | varchar(50) | Y | | 원산지 코드 |
| | inqty_pack | smallint | Y | 0 | 팩당 입수량 |
| | brand_cd | varchar(50) | Y | | 브랜드 코드 |
| | len_x | numeric(10,2) | Y | 1 | 가로 길이 (cm) |
| | len_y | numeric(10,2) | Y | 1 | 세로 길이 (cm) |
| | len_z | numeric(10,2) | Y | 1 | 높이 (cm) |
| | wes_if_send_yn | char(1) | N | 'N' | WES IF 전송 여부 |
| | wes_if_err_seq | integer | Y | | WES IF 오류 SEQ |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |
| | barcode_type_cd | varchar(50) | Y | | 바코드 유형 코드 |
| | parent_barcode_type_cd | varchar(50) | Y | | 상위(박스) 바코드 유형 코드 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_prod_PK | prod_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| label_paper_seq | mdm_label_paper | label_paper_seq | mdm_label_paper_TO_mdm_prod |
| parent_label_paper_seq | mdm_label_paper | label_paper_seq | mdm_label_paper_TO_mdm_prod2 |

## 5. 업무 규칙
- `sku_mng_cd` : SKU 관리 유형 — 유통기한/LOT/일련번호 중 어떤 방식으로 재고를 식별할지 결정
- `eff_mng_yn = 'Y'` : 유통기한 필수 입력, 유효기준(`eff_base + eff_base_unit_cd`)으로 임박 알림 활용
- `lot_no_mng_yn = 'Y'` : 입고 시 LOT번호 필수
- `cn_mng_yn = 'Y'` : 일련번호(Serial Number) 단위 관리
- `sku2_mng_yn = 'Y'` : 파렛트 단위 관리
- `in_qty` : 박스(parent) → EA(unit) 변환 기준
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 |
|---|---|
| mdm_biz_prod | prod_seq |
| mdm_cont_prod | prod_seq |
| mdm_rp_prod | prod_seq |
| mdm_st_config_dtl | prod_seq |
| mdm_st_prod | prod_seq |

## 7. 주요 조회 예시

```sql
-- 품목 목록
SELECT prod_seq, prod_no, prod_nm, unit_cd, eff_mng_yn, lot_no_mng_yn
FROM mdm_prod
WHERE use_yn = 'Y'
ORDER BY prod_nm;

-- 유통기한 관리 품목
SELECT * FROM mdm_prod WHERE eff_mng_yn = 'Y' AND use_yn = 'Y';
```
