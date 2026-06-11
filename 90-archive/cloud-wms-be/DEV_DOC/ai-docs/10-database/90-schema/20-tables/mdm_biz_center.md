# mdm_biz_center (MDM_사업장_센터)

## 1. 개요
사업장과 물류센터 간의 계약/승인 관계를 관리하는 매핑 테이블.
사업장이 특정 물류센터를 사용할 수 있는 권한 부여 및 승인 상태 관리.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| FK | biz_seq | integer | N | | 사업장 SEQ → mdm_biz.biz_seq |
| FK | center_seq | integer | N | | 센터 SEQ → mdm_center.center_seq |
| FK | reg_biz_seq | integer | N | | 가입 신청 사업장 SEQ → mdm_biz.biz_seq |
| | note | varchar(1000) | Y | | 요청 내용 / 승인 메모 |
| | cfm_yn | char(1) | N | 'Y' | 승인 여부 ('Y':승인, 'N':미승인) |
| | use_yn | char(1) | N | 'N' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| UK_mdm_biz_center | biz_seq, center_seq | Y | N |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_center |
| center_seq | mdm_center | center_seq | mdm_center_TO_mdm_biz_center |
| reg_biz_seq | mdm_biz | biz_seq | mdm_biz_TO_mdm_biz_center_reg |

## 5. 업무 규칙
- **신청**: 사업장이 센터 사용 신청 (`reg_biz_seq` = 신청 사업장)
- **승인**: `cfm_yn = 'Y'` 승인완료 / `cfm_yn = 'N'` 승인대기
- **거절/해지**: `use_yn = 'N'` 논리삭제로 처리
- `biz_seq = reg_biz_seq` : 자기 자신이 직접 신청하는 일반 케이스
- `biz_seq ≠ reg_biz_seq` : 본사가 지사 대신 대리 신청하는 케이스
- 여러 사업장이 동일 센터 공동 사용 가능 (물류대행 센터)

## 6. 주요 조회 예시

```sql
-- 특정 센터에 승인된 사업장 목록
SELECT bc.biz_seq, b.biz_nm, bc.cfm_yn
FROM mdm_biz_center bc
    INNER JOIN mdm_biz b ON bc.biz_seq = b.biz_seq
WHERE bc.center_seq = 1
AND bc.use_yn = 'Y'
AND bc.cfm_yn = 'Y';
```
