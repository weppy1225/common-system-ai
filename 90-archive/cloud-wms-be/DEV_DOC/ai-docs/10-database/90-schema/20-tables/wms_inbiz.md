# wms_inbiz (WMS_입하)

## 1. 개요
WMS에서 관리하는 입하(구매발주) 정보.
외부 시스템(ERP 등)에서 전송된 구매발주 정보를 기반으로 입고 요청을 생성하기 전 단계의 데이터를 관리한다.

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inbiz_seq | int4 | N | nextval('wms_inbiz_seq') | 입하 SEQ |
| | biz_seq | int4 | N | | 사업장 SEQ |
| | inbiz_no | varchar(30) | N | | 입하 번호 |
| | center_seq | int4 | N | | 센터 SEQ |
| | inbiz_type_cd | varchar(50) | N | | 입하 유형 코드 |
| | inbiz_sts_cd | varchar(50) | Y | | 입하 상태 코드 |
| | po_no | varchar(100) | N | | 구매발주 번호 |
| | po_ymd | varchar(8) | Y | | 발주 년월일 |
| | po_user_nm | varchar(100) | Y | | 발주 담당자 명 |
| | bl_no | varchar(100) | Y | | B/L 번호 |
| | cc_no | varchar(100) | Y | | 수입통관 번호 |
| | req_ymd | varchar(8) | N | | 예정 연월일(입하) |
| | req_hms | varchar(6) | Y | | 예정 시분초(입하) |
| | req_user_nm | varchar(100) | Y | | 요청 사용자 명(입하) |
| FK | cont_seq | int4 | Y | | 거래처 SEQ |
| | cfm_ymd | varchar(8) | Y | | 확정 연월일(입하) |
| | cfm_hms | varchar(6) | Y | | 확정 시분초(입하) |
| | cfm_user_id | varchar(20) | Y | | 확정 자 ID(입하) |
| | note | varchar(1000) | Y | | 비고 |
| | req_no | varchar(30) | Y | | 문서 번호(타시스템) |
| | erp_wh_cd | varchar(50) | Y | | 입고처 CODE(타시스템) |
| | if_key | varchar(50) | Y | | IF KEY |
| | if_err_seq | int4 | Y | | IF 에러 일련번호 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inbiz_PK | inbiz_seq | Y | Y |

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| cont_seq | mdm_cont | cont_seq | (선언된 FK 없음 — 암묵적 참조) |

## 5. 업무 규칙
- `inbiz_type_cd` : 입하 유형 코드

| 코드 | 코드명 | 비고 |
|---|---|---|
| IW01 | 구매입고 | 일반 구매 발주 |
| IW71 | 외주입고 | 외주 가공 발주 |
| IW91 | 기타입고 | 기타 입하 |

- `inbiz_sts_cd` : 입하 상태 코드

| 코드 | 코드명 | 비고 |
|---|---|---|
| 11 | 예정 | 입하 요청 등록 |
| 55 | 처리중 | 입고 처리 중 |
| 77 | 확정 | 입고 완료 |
| 78 | 강제확정 | 강제 입고 완료 |
| 99 | 취소 | 입하 취소 |

- `if_send_yn` : IF 송신 여부

| 코드 | 코드명 | 비고 |
|---|---|---|
| N | 대기 | 송신 대기 |
| Y | 성공 | 송신 성공 |
| E | 실패 | 송신 실패 |

- `del_yn` : 삭제 여부

| 코드 | 코드명 | 비고 |
|---|---|---|
| N | 미삭제 | 정상 데이터 |
| Y | 삭제 | 논리 삭제 |

- `po_no` : 외부 시스템(ERP)에서 전송된 구매발주 번호
- `req_ymd` : 입하 예정일자
- `cfm_ymd`, `cfm_hms`, `cfm_user_id` : 입하 확정 시점에 업데이트
- 물리삭제 금지, `del_yn = 'Y'`로 논리삭제 처리

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 |
|---|---|
| wms_inbiz_prod | inbiz_seq |
| wms_inbiz_inwh | inbiz_seq, inbiz_prod_seq |

## 7. 주요 조회 예시

```sql
-- 입하 목록 조회
SELECT inbiz_seq, inbiz_no, po_no, req_ymd, inbiz_sts_cd
FROM wms_inbiz
WHERE del_yn = 'N'
ORDER BY req_ymd DESC;

-- 특정 거래처의 입하 내역 조회
SELECT i.*, c.cont_nm
FROM wms_inbiz i
LEFT JOIN mdm_cont c ON i.cont_seq = c.cont_seq
WHERE i.cont_seq = 100 AND i.del_yn = 'N';

-- 미확정 입하 내역 조회
SELECT * FROM wms_inbiz
WHERE inbiz_sts_cd = '11' -- '11'은 '예정' 상태
AND del_yn = 'N'
ORDER BY req_ymd;
```