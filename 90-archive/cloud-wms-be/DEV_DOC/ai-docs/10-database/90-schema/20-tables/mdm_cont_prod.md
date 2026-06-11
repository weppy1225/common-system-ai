# mdm_cont_prod (MDM_거래처_품목)

## 1. 개요
거래처별 품목 매핑 테이블. 거래처마다 품목에 대한 라벨명, 바코드, 거래처 품목코드 등 별도 정보를 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | cont_prod_seq | integer | N | nextval('mdm_cont_prod_seq') | 거래처 품목 SEQ |
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| FK | cont_seq | integer | N | | 거래처 SEQ → mdm_cont.cont_seq |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod.prod_seq |
| | label_prod_nm | varchar(100) | N | | 라벨 품목 명 (거래처 표시용) |
| | disp_prod_barcode | varchar(100) | Y | | 표시 상품 바코드 |
| | cont_prod_code | varchar(100) | Y | | 거래처 품목 코드 |
| | in_qty | smallint | N | 1 | 입수 (박스당 EA수) |
| | exp_date_disp_yn | char(1) | N | 'Y' | 유통기한 표시 여부 |
| | print_cnt | smallint | N | 1 | 출력 매수 |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_cont_prod_PK | cont_prod_seq | Y | Y |
| UK_mdm_cont_prod | cont_seq, prod_seq | Y | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_cont_prod |
| cont_seq | mdm_cont | cont_seq | mdm_cont_TO_mdm_cont_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_cont_prod |

## 5. 업무 규칙
- `(cont_seq, prod_seq)` 조합 UNIQUE — 동일 거래처-품목 중복 등록 불가
- `label_prod_nm` : 라벨 출력 시 거래처가 원하는 품목명 표기
- `cont_prod_code` : 거래처 자체 품목코드 (ERP 연동 등)
- `in_qty` : 박스 단위의 낱개 수량 — 라벨 출력 및 수량 계산에 활용
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 6. 주요 조회 예시

```sql
-- 특정 거래처의 품목 매핑 목록
SELECT cp.cont_prod_seq, c.cont_nm, p.prod_nm, cp.label_prod_nm,
       cp.cont_prod_code, cp.in_qty
FROM mdm_cont_prod cp
    INNER JOIN mdm_cont c ON cp.cont_seq = c.cont_seq
    INNER JOIN mdm_prod p ON cp.prod_seq = p.prod_seq
WHERE cp.cont_seq = 10
AND cp.use_yn = 'Y';
```
