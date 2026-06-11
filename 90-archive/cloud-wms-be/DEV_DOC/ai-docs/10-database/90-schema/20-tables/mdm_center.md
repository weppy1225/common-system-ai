# mdm_center (MDM_센터)

## 1. 개요
물류센터(창고 운영 시설) 마스터. 하나의 센터는 여러 창고(mdm_wh)를 포함하며, 여러 사업장이 공동 사용 가능.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | center_seq | integer | N | nextval('mdm_center_seq') | 센터 SEQ |
| | center_nm | varchar(100) | N | | 센터 명 |
| | tel | varchar(100) | Y | | 전화번호 |
| | email | varchar(100) | Y | | 이메일 |
| | post_no | varchar(10) | Y | | 우편 번호 |
| | addr | varchar(200) | Y | | 주소 |
| | addr_dtl | varchar(200) | Y | | 주소 상세 |
| | center_file_seq | integer | Y | | 센터 사진 파일 SEQ |
| | tpl_yn | char(1) | N | 'N' | 물류대행 여부 |
| | note | varchar(1000) | Y | | 비고 |
| | use_yn | char(1) | N | 'Y' | 사용 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| mdm_center_PK | center_seq | Y | Y |

## 4. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| mdm_biz_center | center_seq | mdm_center_TO_mdm_biz_center |
| mdm_wh | center_seq | mdm_center_TO_mdm_wh |
| mdm_user_center | center_seq | mdm_center_TO_mdm_user_center |

## 5. 업무 규칙
- `tpl_yn = 'Y'` : 물류대행 센터 (3PL) — 여러 사업장이 공동 사용
- `tpl_yn = 'N'` : 자가 운영 센터 — 특정 사업장 전용
- 물리삭제 금지, `use_yn = 'N'`으로 논리삭제 처리
- 센터 삭제 전 소속 창고(mdm_wh) 비활성화 선행 필요

## 6. 주요 조회 예시

```sql
-- 사용 중인 물류센터 목록
SELECT center_seq, center_nm, tpl_yn, addr
FROM mdm_center
WHERE use_yn = 'Y'
ORDER BY center_nm;

-- 물류대행 센터만 조회
SELECT * FROM mdm_center WHERE tpl_yn = 'Y' AND use_yn = 'Y';
```
