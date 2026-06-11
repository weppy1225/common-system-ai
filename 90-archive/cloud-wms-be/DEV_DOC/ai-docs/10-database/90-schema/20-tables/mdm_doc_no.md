# mdm_doc_no (MDM_문서번호)

## 1. 개요
입출하/입출고 등 업무별 문서번호 채번을 관리하는 테이블.
사업장 + 수불유형 + 기준일자 조합으로 순번을 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK, FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| PK | inout_type_cd | varchar(50) | N | | 수불 유형 코드 |
| PK | base_ymd | varchar(8) | N | | 기준 일자 (YYYYMMDD) |
| | next_seq | integer | N | 1 | 다음 순번 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_doc_no_PK | biz_seq, inout_type_cd, base_ymd | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_doc_no |

## 5. 업무 규칙
- `inout_type_cd` 값은 2자리 수불유형 코드 (예: `IW`, `OW`, `OB`, `RT`, `AD`, `EX`, `IM`, `RP`, `ST` 등)
- 문서번호 형식: `{inout_type_cd(2자리)}` + `YYMMDD` + `{next_seq(4자리 zero-pad)}` (예: `IW2602250001`)
  - `base_ymd`(YYYYMMDD)에서 연도 2자리를 추출하여 YYMMDD 형식으로 조합
- `next_seq` : 해당 일자 최초 채번 시 1, 이후 +1씩 증가
- 채번은 반드시 `DocNoGenerator.getDocNo()` 공통 모듈 경유 — 직접 SELECT/UPDATE 금지
- 공통 컬럼(use_yn, reg_id 등) 없음 — 순수 채번 관리 테이블

## 6. 내부 처리 흐름 (DocNoGenerator 참고용)

> ❌ 아래 SQL을 직접 실행하지 말 것 — 반드시 `DocNoGenerator.getDocNo(bizSeq, inoutTypeCd, baseYmd)` 경유

```sql
-- 내부 채번 흐름 (참고용)
BEGIN;
SELECT next_seq FROM mdm_doc_no
WHERE biz_seq = 1 AND inout_type_cd = 'IW' AND base_ymd = '20260309'
FOR UPDATE;

-- next_seq가 없으면 INSERT, 있으면 UPDATE
INSERT INTO mdm_doc_no (biz_seq, inout_type_cd, base_ymd, next_seq)
VALUES (1, 'IW', '20260309', 2)
ON CONFLICT (biz_seq, inout_type_cd, base_ymd)
DO UPDATE SET next_seq = mdm_doc_no.next_seq + 1;
COMMIT;
-- 결과: 'IW' + '260309' + '0001' = 'IW2603090001'
```
