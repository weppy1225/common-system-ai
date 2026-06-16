# mdm_st_config (MDM_세트_구성)

## 1. 개요
세트 작업의 구성 헤더 테이블.
어떤 세트 품목을 어떤 구성품으로 조립할지를 정의하는 세트 구성의 상위 단위.
상세 구성품은 `mdm_st_config_dtl`에서 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_config_seq | integer | N | nextval('mdm_st_config_seq') | 세트 구성 SEQ |
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| FK | st_prod_seq | integer | N | | 세트 품목 SEQ → mdm_st_prod.st_prod_seq |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록자 |
| | reg_dt | timestamp | N | now() | 등록일 |
| | mod_id | varchar(20) | Y | | 수정자 |
| | mod_dt | timestamp | Y | | 수정일 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| PK_mdm_st_config | st_config_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 |
|---|---|---|
| biz_seq | mdm_biz | biz_seq |
| st_prod_seq | mdm_st_prod | st_prod_seq |

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| mdm_st_config_dtl | st_config_seq | FK_mdm_st_config_dtl_st_config_seq |

## 6. 업무 규칙
- 하나의 세트 품목(`st_prod_seq`)에 대해 여러 구성 버전 관리 가능
- 실제 조립 구성품은 `mdm_st_config_dtl`에 상세 등록
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리

## 7. 주요 조회 예시

```sql
-- 세트 구성 헤더 + 상세 조회
SELECT sc.st_config_seq, sp.prod_seq AS st_prod_seq,
       p.prod_nm AS st_prod_nm,
       d.prod_seq AS comp_prod_seq, cp.prod_nm AS comp_prod_nm,
       d.config_qty
FROM mdm_st_config sc
    INNER JOIN mdm_st_prod sp ON sc.st_prod_seq = sp.st_prod_seq
    INNER JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
    INNER JOIN mdm_st_config_dtl d ON sc.st_config_seq = d.st_config_seq
    INNER JOIN mdm_prod cp ON d.prod_seq = cp.prod_seq
WHERE sc.biz_seq = 1
AND sc.use_yn = 'Y';
```
