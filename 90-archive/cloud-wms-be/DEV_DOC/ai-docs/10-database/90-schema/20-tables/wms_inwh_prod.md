# wms_inwh_prod (WMS_입고품목)

## 1. 개요
`wms_inwh`(입고)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
입고 요청 품목별로 수량, 상태, 예상 유통기한/LOT 등을 저장하며, 실제 입고 처리(`wms_inwh_tran`)와 연결된다.

### 1.1 입고품목 처리 흐름
```
wms_inwh (입고 헤더)
└─ wms_inwh_prod (입고 품목)
        └─ wms_inwh_tran (입고 처리 이력) → wms_inven 증가
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inwh_prod_seq | bigint | N | nextval('wms_inwh_prod_seq') | 입고품목 SEQ |
| FK | inwh_seq | integer | N | | 입고 SEQ → wms_inwh |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | inwh_prod_sts_cd | varchar(50) | N | | 입고품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_mng_ymd | varchar(8) | Y | | 예상 제조일자 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | pub_sku1_yn | char(1) | N | 'N' | SKU1 발행 여부 |
| | pub_sku2_yn | char(1) | N | 'N' | SKU2 발행 여부 |
| | pltzing_yn | char(1) | N | 'N' | 파렛타이징 여부 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_idx | varchar(20) | Y | | IF 내부순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inwh_prod_sts_cd** (`INWH_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |

> **pub_sku1_yn, pub_sku2_yn, pltzing_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미사용/미발행 |
> | Y | 사용/발행 |

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
| wms_inwh_prod_PK | inwh_prod_seq, inwh_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inwh_prod_seq | wms_inwh_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| inwh_seq | wms_inwh | inwh_seq | wms_inwh_TO_wms_inwh_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inwh_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inwh_tran | inwh_prod_seq, inwh_seq | wms_inwh_prod_TO_wms_inwh_tran |
| wms_inbiz_inwh | inwh_prod_seq | wms_inwh_prod_TO_wms_inbiz_inwh |

---

## 7. 업무 규칙
- 입고 품목 등록 시 `inwh_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 입고 요청 수량
- `ex_qty` : 실제 입고 처리(`wms_inwh_tran`)가 발생한 누적 수량
- 모든 수량이 처리되면(`req_qty = ex_qty`) 상태는 `'77'(확정)` 으로 자동 변경
- `est_exp_ymd`, `est_mng_ymd`, `est_lot_no` : 입고 단계에서 예상 정보 입력
- `pub_sku1_yn`, `pub_sku2_yn` : SKU 라벨 발행 여부 (파렛트/박스 단위)
- `pltzing_yn` : 파렛타이징 필요 여부
- 입고 확정 시 실제 재고(`wms_inven`)의 SKU 정보는 `wms_inwh_tran`의 처리 정보 기준으로 생성
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 입고별 품목 현황
SELECT i.inwh_no, p.prod_nm, ip.req_qty, ip.ex_qty,
       ip.inwh_prod_sts_cd, ip.est_lot_no, ip.est_exp_ymd
FROM wms_inwh_prod ip
    JOIN wms_inwh i ON ip.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND i.req_ymd = '20250225'
ORDER BY i.inwh_no, p.prod_nm;

-- 미완료 입고 품목 (처리중)
SELECT ip.inwh_prod_seq, i.inwh_no, p.prod_nm,
       ip.req_qty, ip.ex_qty,
       (ip.req_qty - ip.ex_qty) AS remain_qty,
       ip.est_exp_ymd, ip.est_lot_no
FROM wms_inwh_prod ip
    JOIN wms_inwh i ON ip.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND ip.inwh_prod_sts_cd = '55'
AND ip.del_yn = 'N'
ORDER BY i.req_ymd, i.inwh_no;

-- 유통기한 임박 품목 조회
SELECT i.inwh_no, p.prod_nm, ip.req_qty, ip.ex_qty,
       ip.est_exp_ymd
FROM wms_inwh_prod ip
    JOIN wms_inwh i ON ip.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND ip.est_exp_ymd BETWEEN '20250301' AND '20250331'
AND ip.del_yn = 'N'
ORDER BY ip.est_exp_ymd;
```