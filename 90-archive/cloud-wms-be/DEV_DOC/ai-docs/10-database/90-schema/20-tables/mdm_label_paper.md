# mdm_label_paper (MDM_라벨_용지)

## 1. 개요
라벨 프린터 출력에 사용되는 용지(라벨지) 마스터.
품목별, 거래처별 라벨 출력 양식과 연결된다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | label_paper_seq | integer | N | nextval('mdm_label_paper_seq') | 라벨용지 SEQ |
| | label_paper_nm | varchar(100) | N | | 라벨용지 명 |
| | label_paper_div_cd | varchar(50) | N | | 용지 구분 코드 |
| | label_paper_type_cd | varchar(50) | N | | 용지 유형 코드 |
| | barcode_dim_cd | varchar(50) | Y | | 바코드 차원 코드 (1D/2D) |
| | manufacturer_nm | varchar(100) | Y | | 제조사 명칭 |
| | product_code | varchar(100) | Y | | 제품 코드 |
| | product_nm | varchar(100) | Y | | 제품 명칭 |
| | paper_type | varchar(100) | Y | | 용지 종류 |
| | name_tag_cnt | varchar(100) | Y | | 이름표 개수 (1면 기준 라벨 수) |
| | name_tag_size | varchar(100) | Y | | 이름표 크기 |
| | file_seq | integer | N | | 출력 양식 파일 SEQ (sm_file) |
| | def_label_yn | char(1) | N | 'N' | 기본 라벨 유무 |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_label_paper_PK | label_paper_seq | Y | Y |

## 4. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| mdm_prod | label_paper_seq | mdm_label_paper_TO_mdm_prod |
| mdm_prod | parent_label_paper_seq | mdm_label_paper_TO_mdm_prod2 |

## 5. 업무 규칙
- `def_label_yn = 'Y'` : 시스템 기본 라벨용지 (품목/거래처 미설정 시 fallback)
- `file_seq` : 실제 출력 양식 파일(jasper, xlsx 등)의 sm_file SEQ
- `label_paper_div_cd` : 입고라벨/출하라벨/재고라벨 등 구분
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 6. 주요 조회 예시

```sql
-- 사용 중인 라벨용지 목록
SELECT label_paper_seq, label_paper_nm, label_paper_div_cd, def_label_yn
FROM mdm_label_paper
WHERE use_yn = 'Y'
ORDER BY label_paper_nm;
```
