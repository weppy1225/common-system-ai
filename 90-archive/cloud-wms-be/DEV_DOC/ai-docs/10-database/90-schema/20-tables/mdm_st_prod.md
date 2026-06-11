# mdm_st_prod (MDM_세트구성)

## 1. 개요
세트 작업에서 사용되는 품목 구조를 관리하는 마스터.
세트 품목(완성품)과 구성품(원재료) 간의 관계를 트리 구조로 정의한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_prod_seq | integer | N | nextval('mdm_st_prod_seq') | 세트구성 SEQ |
| FK | biz_seq | integer | N | | 사업장 SEQ |
| | st_yn | char(1) | N | 'N' | 세트품목 여부 ('Y':세트완성품, 'N':구성품) |
| FK | ref_st_prod_seq | integer | Y | | 상위 세트구성 SEQ (자기 참조) |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod.prod_seq |
| | qty | numeric(10,2) | N | 1.00 | 수량 |
| | note | varchar(1000) | Y | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_st_prod_PK | st_prod_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| ref_st_prod_seq | mdm_st_prod | st_prod_seq | mdm_st_prod_TO_mdm_st_prod (자기참조) |

## 5. 업무 규칙
- `st_yn = 'Y'` + `ref_st_prod_seq IS NULL` : 최상위 세트 완성품
- `st_yn = 'N'` + `ref_st_prod_seq 있음` : 세트를 구성하는 하위 구성품
- `del_yn = 'Y'` : 논리삭제 (use_yn 대신 del_yn 사용)
- `mdm_st_config`의 `st_prod_seq`에서 이 테이블을 참조

## 6. 주요 조회 예시

```sql
-- 세트 완성품 목록
SELECT sp.st_prod_seq, p.prod_no, p.prod_nm, sp.qty
FROM mdm_st_prod sp
    INNER JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
WHERE sp.biz_seq = 1
AND sp.st_yn = 'Y'
AND sp.del_yn = 'N';
```
