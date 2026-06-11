# mdm_car (MDM_차량)

## 1. 개요
출하/배송에 사용되는 차량 마스터. 사업장 단위로 차량을 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | car_seq | integer | N | nextval('mdm_car_seq') | 차량 SEQ |
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| | car_no | varchar(100) | N | | 차량 번호 |
| | car_div_cd | varchar(50) | N | 'DIRECT' | 차량 구분 코드 |
| | car_type_cd | varchar(50) | N | 'BOX' | 차량 유형 코드 |
| | driver_nm | varchar(100) | Y | | 운전자 명 |
| | driver_tel | varchar(500) | Y | | 운전자 전화번호 |
| | cfd_cd | varchar(50) | N | 'D' | 냉장냉동상온 코드 (D:상온, C:냉장, F:냉동) |
| | cbm | numeric(10,2) | Y | 0 | CBM (용적) |
| | length | numeric(10,2) | Y | 0 | 가로 |
| | width | numeric(10,2) | Y | 0 | 세로 |
| | height | numeric(10,2) | Y | 0 | 높이 |
| | wgt | numeric(10,2) | Y | 0 | 중량 |
| | self_yn | char(1) | N | 'N' | 자차 여부 |
| | use_yn | char(1) | N | 'Y' | 운행 가능 여부 |
| | note | varchar(1000) | Y | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_car_PK | car_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_car |

## 5. 업무 규칙
- `del_yn = 'Y'` : 완전 삭제 처리 (use_yn과 별도로 del_yn으로 삭제 관리)
- `use_yn = 'N'` : 운행 불가 상태 (수리/점검 등 임시 비활성)
- `self_yn`: 'Y'=자차, 'N'=용차(외부 차량)
- `car_div_cd`: 'DIRECT'(직접배송), 'DELIVERY'(택배) 등
- `cfd_cd`: 'D'(상온), 'C'(냉장), 'F'(냉동)

## 6. 주요 조회 예시

```sql
-- 특정 사업장의 운행 가능 차량 목록
SELECT car_seq, car_no, car_div_cd, car_type_cd, driver_nm, self_yn
FROM mdm_car
WHERE biz_seq = 1
AND use_yn = 'Y'
AND del_yn = 'N'
ORDER BY car_no;
```
