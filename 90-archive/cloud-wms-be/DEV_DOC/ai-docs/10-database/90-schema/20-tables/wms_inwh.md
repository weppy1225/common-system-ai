# wms_inwh (WMS_입고)

## 1. 개요
실제 창고에 물품을 **입고(入庫) 처리**하는 요청 헤더 테이블.
입하(`wms_inbiz`) 정보를 기반으로 생성되며, 입고 확정을 통해 실재고(`wms_inven`)가 증가한다.

### 1.1 입고 처리 흐름
```
wms_inbiz (입하) → wms_inwh (입고 헤더)
                    └─ wms_inwh_prod (입고 품목)
                          └─ wms_inwh_tran (입고 처리 이력) → wms_inven 증가
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inwh_seq | integer | N | nextval('wms_inwh_seq') | 입고 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | cont_seq | integer | Y | | 거래처 SEQ → mdm_cont |
| | inwh_no | varchar(30) | N | | 입고 번호 (문서번호) |
| | inwh_type_cd | varchar(50) | N | | 입고 유형 코드 |
| | inwh_sts_cd | varchar(50) | N | '11' | 입고 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | cfm_ymd | varchar(8) | Y | | 확정 일자 (YYYYMMDD) |
| | cfm_hms | varchar(6) | Y | | 확정 시간 (HHMMSS) |
| | cfm_user_id | varchar(20) | Y | | 확정자 ID |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| | erp_wh_cd | varchar(50) | Y | | ERP 창고 코드 |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inwh_type_cd** (`INWH_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | IW01 | 구매입고 | 구매 발주 기반 입고 |
> | IW71 | 외주입고 | 외주 가공품 입고 |
> | IW91 | 기타입고 | 기타 입고 |

> **inwh_sts_cd** (`INWH_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |
> | 78 | 강제확정 |
> | 99 | 취소 |

> **if_send_yn** (`IF_SEND_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 대기 |
> | Y | 성공 |
> | E | 실패 |

> **del_yn** (`DEL_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미삭제 |
> | Y | 삭제 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inwh_PK | inwh_seq | Y | Y |
| UK_wms_inwh | biz_seq, inwh_no | Y | |
| IX_wms_inwh2 | biz_seq, center_seq, req_ymd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inwh_seq | wms_inwh_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| cont_seq | mdm_cont | cont_seq | (명시적 FK 필요 시) |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inwh_prod | inwh_seq | wms_inwh_TO_wms_inwh_prod |
| wms_inbiz_inwh | inwh_seq | wms_inbiz_inwh |

---

## 7. 업무 규칙
- `inwh_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `IW`)
- 입고 등록 시 `inwh_sts_cd = '11'(예정)` 으로 시작
- 입하(`wms_inbiz`) 연동 시 `wms_inbiz_inwh` 매핑 테이블을 통해 연결
- 입고 처리(`wms_inwh_tran`) 발생 시 상태는 `'55'` → `'77'`로 변경
- 입고 확정(`'77'`) 시 실재고(`wms_inven`) 증가
- 강제확정(`'78'`)은 재고 실사 등 예외 상황에서 사용
- 확정 후에는 취소(`'99'`)만 가능 (수정 불가)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 입고 유형별 현황
SELECT inwh_type_cd, inwh_sts_cd, COUNT(*) AS cnt
FROM wms_inwh
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250225'
GROUP BY inwh_type_cd, inwh_sts_cd
ORDER BY inwh_type_cd, inwh_sts_cd;

-- 미확정 입고 목록
SELECT inwh_no, req_ymd, inwh_type_cd, inwh_sts_cd
FROM wms_inwh
WHERE biz_seq = 1
AND center_seq = 1
AND inwh_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY req_ymd, inwh_no;

-- 입하 연계 입고 조회
SELECT i.inwh_no, i.req_ymd, ib.inbiz_no, ib.po_no
FROM wms_inwh i
    JOIN wms_inbiz_inwh ii ON i.inwh_seq = ii.inwh_seq
    JOIN wms_inbiz ib ON ii.inbiz_seq = ib.inbiz_seq
WHERE i.biz_seq = 1
AND i.inwh_sts_cd = '77';
```