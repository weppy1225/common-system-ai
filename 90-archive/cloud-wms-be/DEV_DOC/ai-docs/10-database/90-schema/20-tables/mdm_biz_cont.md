# mdm_biz_cont (MDM_사업장_거래처)

## 1. 개요
사업장과 거래처 간의 연결 관계를 관리하는 매핑 테이블.
하나의 거래처는 여러 사업장에서 사용 가능하며, 사업장별 거래처 사용 여부를 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK, FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| PK, FK | cont_seq | integer | N | | 거래처 SEQ → mdm_cont.cont_seq |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_biz_cont_PK | biz_seq, cont_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_cont |
| cont_seq | mdm_cont | cont_seq | mdm_cont_TO_mdm_biz_cont |

## 5. 업무 규칙
- 동일 `(biz_seq, cont_seq)` 조합 중복 불가 (복합 PK)
- 물리삭제 금지, `use_yn = 'N'`으로 연결 관계 해제 처리
- 거래처는 최소 1개 이상의 사업장과 연결되어야 함

## 6. 주요 조회 예시

```sql
-- 특정 사업장에 연결된 거래처 목록
SELECT bc.biz_seq, b.biz_nm, bc.cont_seq, c.cont_nm, c.cont_no
FROM mdm_biz_cont bc
    INNER JOIN mdm_biz b ON bc.biz_seq = b.biz_seq
    INNER JOIN mdm_cont c ON bc.cont_seq = c.cont_seq
WHERE bc.biz_seq = 1
AND bc.use_yn = 'Y'
ORDER BY c.cont_nm;
```
