# mdm_wh (MDM_창고)

## 1. 개요
물류센터(mdm_center) 소속 창고 마스터.
입고/출고/세트/전환/예외출고 등 각 업무 처리 가능 여부를 플래그로 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | wh_seq | integer | N | nextval('mdm_wh_seq') | 창고 SEQ |
| FK | center_seq | integer | N | | 센터 SEQ → mdm_center.center_seq |
| | wh_nm | varchar(100) | N | | 창고 명 |
| | wh_group_cd | varchar(50) | N | | 창고 그룹 코드 |
| | in_yn | char(1) | N | 'N' | 입고처리 여부 |
| | return_yn | char(1) | N | 'N' | 반품처리 여부 |
| | pick_yn | char(1) | N | 'N' | 출고(피킹)처리 여부 |
| | st_yn | char(1) | N | 'N' | 세트작업 여부 |
| | rp_yn | char(1) | N | 'N' | 전환처리 여부 |
| | out_yn | char(1) | N | 'N' | 출하처리 여부 |
| | etc_yn | char(1) | N | 'N' | 예외출고 여부 |
| | def_wh_yn | char(1) | N | 'N' | 기본창고 여부 |
| | available_inven_yn | char(1) | N | 'N' | 가용재고 유무 |
| | cfd_cd | varchar(50) | N | 'D' | 냉장냉동상온 코드 (D:상온, C:냉장, F:냉동) |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_wh_PK | wh_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| center_seq | mdm_center | center_seq | mdm_center_TO_mdm_wh |

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| mdm_biz_wh | wh_seq | mdm_wh_TO_mdm_biz_wh |
| mdm_loc | wh_seq | mdm_wh_TO_mdm_loc |

## 6. 업무 규칙
- 업무별 가능 여부 플래그(`in_yn`, `pick_yn` 등)로 창고 용도 제어
- `def_wh_yn = 'Y'` : 센터 내 기본 창고 (입고 시 기본 배정)
- `available_inven_yn = 'Y'` : 가용 재고로 집계 포함 여부
- `cfd_cd`: 'D'(상온), 'C'(냉장), 'F'(냉동) — 품목의 보관 조건과 매칭
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- 재고가 있는 창고 비활성화 불가 (애플리케이션 레벨 검증)

## 7. 주요 조회 예시

```sql
-- 특정 센터의 입고 가능 창고
SELECT wh_seq, wh_nm, wh_group_cd, cfd_cd
FROM mdm_wh
WHERE center_seq = 1
AND in_yn = 'Y'
AND use_yn = 'Y';

-- 출고(피킹) 가능 창고
SELECT wh_seq, wh_nm, available_inven_yn
FROM mdm_wh
WHERE center_seq = 1
AND pick_yn = 'Y'
AND use_yn = 'Y';
```
