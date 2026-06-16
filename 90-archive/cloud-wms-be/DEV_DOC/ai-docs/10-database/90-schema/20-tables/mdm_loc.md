# mdm_loc (MDM_위치)

## 1. 개요
창고 내 재고 보관 위치(로케이션) 마스터.
랙번호 + 단번호 + 열번호 조합으로 위치를 구분하며, 창고(mdm_wh) 소속으로 관리된다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | loc_seq | bigint | N | nextval('mdm_loc_seq') | 위치 SEQ |
| FK | wh_seq | integer | N | | 창고 SEQ → mdm_wh.wh_seq |
| | rack_no | varchar(100) | N | '-' | 랙 번호 |
| | row_no | varchar(100) | Y | | 단 번호 |
| | column_no | varchar(100) | Y | | 열 번호 |
| | loc_nm | varchar(100) | N | | 위치 명 |
| | loc_barcode | varchar(100) | Y | | 위치 바코드 |
| | def_loc_yn | char(1) | N | 'N' | 기본위치 여부 |
| | loc_mng_nm | varchar(100) | Y | | 지정 담당자 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_loc_PK | loc_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| wh_seq | mdm_wh | wh_seq | mdm_wh_TO_mdm_loc |

## 5. 업무 규칙
- `def_loc_yn = 'Y'` : 창고별 기본 위치 (입고 시 기본 배정 위치)
- `loc_barcode` : 바코드 스캐너로 위치 인식 시 사용
- `loc_nm` : 일반적으로 `{rack_no}-{row_no}-{column_no}` 형태로 구성
- PK가 bigint — 대형 센터의 경우 로케이션 수가 많아 bigint 사용
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- 재고가 있는 위치는 비활성화 불가 (애플리케이션 레벨 검증)

## 6. 주요 조회 예시

```sql
-- 특정 창고의 위치 목록
SELECT loc_seq, wh_seq, rack_no, row_no, column_no, loc_nm, loc_barcode
FROM mdm_loc
WHERE wh_seq = 1
AND use_yn = 'Y'
ORDER BY rack_no, row_no, column_no;

-- 기본 위치 조회
SELECT * FROM mdm_loc WHERE wh_seq = 1 AND def_loc_yn = 'Y' AND use_yn = 'Y';
```
