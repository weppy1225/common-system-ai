# wms_outbiz_prod (WMS_출하품목)

## 1. 개요
`wms_outbiz`(출하)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
출하 요청 품목별로 수량, 상태, 예상 LOT 정보 등을 저장하며, 실제 출하 처리와 연결된다.

### 1.1 출하품목 처리 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        ├─ wms_outbiz_tran   : 일반/즉시출하 처리 이력
        ├─ wms_outbiz_invoice: 송장출하 연결 (→ wms_invoice_prod)
        ├─ wms_outbiz_load   : 상차출하 연결 (→ wms_load_prod)
        └─ wms_outbiz_outwh  : 출고지시 연결 (→ wms_outwh_prod)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outbiz_prod_seq | bigint | N | nextval('wms_outbiz_prod_seq') | 출하품목 SEQ |
| FK | outbiz_seq | integer | N | | 출하 SEQ → wms_outbiz |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | outbiz_prod_sts_cd | varchar(50) | N | | 출하품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | est_mng_ymd | varchar(8) | Y | | 예상 제조일자 (YYYYMMDD) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | est_cn | varchar(1000) | Y | | 예상 일련번호(CN) |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_idx | varchar(20) | Y | | IF 내부순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outbiz_prod_sts_cd** (`OUTBIZ_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 33 | 지정 |
> | 55 | 처리중 |
> | 77 | 확정 |

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
| wms_outbiz_prod_PK | outbiz_prod_seq, outbiz_seq | Y | Y |
| IX_wms_outbiz_prod_prod | prod_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outbiz_prod_seq | wms_outbiz_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outbiz_seq | wms_outbiz | outbiz_seq | wms_outbiz_TO_wms_outbiz_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outbiz_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_outbiz_tran | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_tran |
| wms_outbiz_invoice | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_invoice |
| wms_outbiz_load | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_load |
| wms_outbiz_outwh | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_outwh |

---

## 7. 업무 규칙

### 7.1 출하품목 등록
- 출하 등록 시 품목별로 `outbiz_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 출하 요청 수량
- `est_mng_ymd`, `est_exp_ymd`, `est_lot_no`, `est_cn` : 출하 단계에서 예상 정보 입력

### 7.2 재고 지정 단계
- 피킹 등 재고 할당 시 상태 `'33'(지정)` 으로 변경
- `wms_outwh_assign` 테이블에서 실제 재고 위치 지정

### 7.3 출하 처리 단계
- 실제 출고 처리(`wms_outwh_tran`) 발생 시 처리 수량 누적
- `ex_qty` = 기존 `ex_qty` + 처리 수량
- `ex_qty` = `req_qty` 이면 `outbiz_prod_sts_cd` = '77'(확정)

### 7.4 출하 유형별 연결

#### 7.4.1 OB01 (일반출하)
- `wms_outbiz_tran` 직접 연결
- 출고 처리 시 바로 출하처리 이력 생성

#### 7.4.2 OB03 (송장출하)
- `wms_outbiz_invoice` → `wms_invoice_prod` 연결
- 송장 발행 후 출하 처리

#### 7.4.3 OB05 (상차출하)
- `wms_outbiz_load` → `wms_load_prod` 연결
- 상차 작업 후 출하 처리

#### 7.4.4 OB07 (즉시출하)
- 일반출하와 동일하게 `wms_outbiz_tran` 직접 연결
- `req_qty` = `ex_qty` 로 즉시 확정 가능

### 7.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 출하품목 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'
- `if_idx` : 외부 시스템에서의 순번 정보

### 7.6 취소/삭제
- 출하 확정(`'77'`) 후에는 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 출하별 품목 현황
SELECT ob.outbiz_no, p.prod_nm, op.req_qty, op.ex_qty,
       op.outbiz_prod_sts_cd, op.est_lot_no, op.est_exp_ymd
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND ob.center_seq = 1
AND ob.req_ymd = '20250225'
AND op.del_yn = 'N'
ORDER BY ob.outbiz_no, p.prod_nm;

-- 미완료 출하 품목 (처리중)
SELECT op.outbiz_prod_seq, ob.outbiz_no, p.prod_nm,
       op.req_qty, op.ex_qty,
       (op.req_qty - op.ex_qty) AS remain_qty,
       op.est_exp_ymd, op.est_lot_no,
       op.outbiz_prod_sts_cd
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND op.outbiz_prod_sts_cd IN ('11', '33', '55')
AND op.del_yn = 'N'
ORDER BY ob.req_ymd, ob.outbiz_no;

-- 출하 유형별 품목 현황
SELECT ob.outbiz_type_cd,
       COUNT(DISTINCT op.outbiz_prod_seq) AS prod_cnt,
       SUM(op.req_qty) AS total_req_qty,
       SUM(op.ex_qty) AS total_ex_qty
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.req_ymd BETWEEN '20250201' AND '20250228'
AND op.del_yn = 'N'
GROUP BY ob.outbiz_type_cd
ORDER BY ob.outbiz_type_cd;

-- 특정 품목의 출하 현황
SELECT ob.outbiz_no, ob.req_ymd, ob.rcv_nm,
       op.req_qty, op.ex_qty, op.outbiz_prod_sts_cd,
       op.est_exp_ymd, op.est_lot_no
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
WHERE op.biz_seq = 1
AND op.prod_seq = 100
AND op.del_yn = 'N'
ORDER BY ob.req_ymd DESC;

-- IF 송신 대기 건 조회
SELECT op.outbiz_prod_seq, ob.outbiz_no, p.prod_nm,
       op.req_qty, op.if_idx
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND op.if_send_yn = 'N'
AND op.del_yn = 'N'
ORDER BY op.reg_dt;
```