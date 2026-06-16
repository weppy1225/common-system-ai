# mdm_biz_biz (MDM_사업장_사업장)

## 1. 개요
사업장 간 상위-하위 계층 관계(본사-지사 등)를 관리하는 매핑 테이블.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK, FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| PK, FK | ref_biz_seq | integer | N | | 상위 사업장 SEQ → mdm_biz.biz_seq |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| (복합 PK) | biz_seq, ref_biz_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_biz |
| ref_biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_biz2 |

## 5. 업무 규칙
- 동일 `(biz_seq, ref_biz_seq)` 조합 중복 불가 (복합 PK)
- `biz_seq`: 하위 사업장, `ref_biz_seq`: 상위 사업장
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- 순환 참조 방지 로직 애플리케이션에서 관리 필요

## 6. 주요 조회 예시

```sql
-- 특정 사업장의 상위 사업장 조회
SELECT b.biz_seq, b.biz_nm AS sub_biz_nm,
       r.biz_seq AS ref_biz_seq, r.biz_nm AS ref_biz_nm
FROM mdm_biz_biz bb
    INNER JOIN mdm_biz b ON bb.biz_seq = b.biz_seq
    INNER JOIN mdm_biz r ON bb.ref_biz_seq = r.biz_seq
WHERE bb.biz_seq = 2
AND bb.use_yn = 'Y';
```
