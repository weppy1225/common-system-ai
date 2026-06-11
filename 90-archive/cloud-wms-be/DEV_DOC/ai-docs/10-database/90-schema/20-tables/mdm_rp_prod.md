# mdm_rp_prod (MDM_전환품목)

## 1. 개요
품목 전환(리패킹) 관계를 관리하는 마스터.
하나의 품목을 다른 품목으로 전환하거나, 묶음 단위를 낱개로 분리하는 등의 전환 규칙을 정의한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | rp_prod_seq | integer | N | nextval('mdm_rp_prod_seq') | 전환품목 SEQ |
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| | st_yn | char(1) | N | 'N' | 기준품목 여부 ('Y':기준, 'N':전환 대상) |
| FK | ref_rp_prod_seq | integer | Y | | 상위 전환품목 SEQ (자기 참조) |
| FK | prod_seq | integer | Y | | 품목 SEQ → mdm_prod.prod_seq |
| | qty | numeric(10,2) | N | 1.00 | 수량 |
| | note | varchar(1000) | N | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_rp_prod_PK | rp_prod_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_mdm_rp_prod |
| ref_rp_prod_seq | mdm_rp_prod | rp_prod_seq | mdm_rp_prod_TO_mdm_rp_prod (자기참조) |

## 5. 업무 규칙
- `st_yn = 'Y'` : 전환의 기준이 되는 품목 (Root)
- `st_yn = 'N'` + `ref_rp_prod_seq` 있음 : 상위 품목으로 전환되는 하위 품목
- `qty` : 전환 비율 (예: A 품목 1개 = B 품목 2개)
- `del_yn = 'Y'` : 논리삭제 (use_yn 대신 del_yn 사용)
- 트리 구조이므로 조회 시 계층적 접근 필요

## 6. 주요 조회 예시

```sql
-- 특정 사업장의 전환품목 구조 조회
SELECT r.rp_prod_seq, r.ref_rp_prod_seq, r.st_yn,
       p.prod_nm, r.qty
FROM mdm_rp_prod r
    LEFT JOIN mdm_prod p ON r.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND r.del_yn = 'N'
ORDER BY r.ref_rp_prod_seq NULLS FIRST, r.rp_prod_seq;
```
