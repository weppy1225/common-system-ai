# mdm_biz_prod (MDM_사업장_품목)

## 1. 개요
사업장별 사용 가능한 품목을 관리하는 매핑 테이블.
품목은 전체 공통으로 등록되나, 사업장별로 사용 가능 여부를 별도로 제어한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK, FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| PK, FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod.prod_seq |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| (복합 PK) | biz_seq, prod_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_biz_prod |

## 5. 업무 규칙
- 동일 `(biz_seq, prod_seq)` 조합 중복 불가 (복합 PK)
- 물리삭제 금지, `use_yn = 'N'`으로 매핑 해제 처리
- 입출고/재고 처리 시 해당 사업장에 활성화된 품목만 사용 가능

## 6. 주요 조회 예시

```sql
-- 특정 사업장에서 사용 가능한 품목 목록
SELECT bp.prod_seq, p.prod_no, p.prod_nm, p.unit_cd
FROM mdm_biz_prod bp
    INNER JOIN mdm_prod p ON bp.prod_seq = p.prod_seq
WHERE bp.biz_seq = 1
AND bp.use_yn = 'Y'
AND p.use_yn = 'Y'
ORDER BY p.prod_nm;
```
