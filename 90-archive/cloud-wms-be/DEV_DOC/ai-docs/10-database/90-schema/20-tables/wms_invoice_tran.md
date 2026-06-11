# wms_invoice_tran (WMS_송장처리)

## 1. 개요
송장 처리 시 **실제 처리된 내역을 저장하는 처리 이력(Transaction) 테이블**.
송장출하(OB03) 유형에서 송장 확정, 출력, 재발행 등의 이력을 관리한다.

### 1.1 송장처리 데이터 흐름
```
wms_invoice (송장 헤더)
└─ wms_invoice_prod (송장 품목)
        └─ wms_invoice_tran (송장 처리 이력) ← **현재 테이블**
              ↑
        wms_outbiz_tran (출하 처리 이력) - 송장 연동 시 참조
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | invoice_tran_seq | bigint | N | nextval('wms_invoice_tran_seq') | 송장처리 SEQ |
| FK | invoice_prod_seq | bigint | N | | 송장품목 SEQ → wms_invoice_prod |
| FK | invoice_seq | integer | N | | 송장 SEQ → wms_invoice |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1 | varchar(100) | N | | SKU1 (처리된 재고단위1) |
| | sku2 | varchar(100) | N | | SKU2 (처리된 재고단위2) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | fr_wh_seq | integer | Y | | 출고 창고 SEQ → mdm_wh |
| | fr_loc_seq | bigint | Y | | 출고 위치 SEQ → mdm_loc |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | to_wh_seq | integer | Y | | 이동 창고 SEQ (송장시는 NULL) |
| | to_loc_seq | bigint | Y | | 이동 위치 SEQ (송장시는 NULL) |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | outbiz_tran_seq | bigint | Y | | 출하처리 SEQ → wms_outbiz_tran |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

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
| wms_invoice_tran_PK | invoice_tran_seq, invoice_prod_seq, invoice_seq | Y | Y |
| IX_wms_invoice_tran_sku | sku1, sku2 | N | |
| IX_wms_invoice_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_invoice_tran_outbiz | outbiz_tran_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| invoice_tran_seq | wms_invoice_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| invoice_prod_seq, invoice_seq | wms_invoice_prod | invoice_prod_seq, invoice_seq | wms_invoice_prod_TO_wms_invoice_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_invoice_tran |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_invoice_tran |
| fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_invoice_tran |
| outbiz_tran_seq | wms_outbiz_tran | outbiz_tran_seq | wms_outbiz_tran_TO_wms_invoice_tran |

---

## 6. 업무 규칙

### 6.1 송장처리 생성 조건
- 송장출하(OB03)에서 출하 처리 시 생성
- `wms_outbiz_tran` 생성 시 연동되어 자동 생성
- 또는 송장 확정/출력 시 별도 이력 생성

### 6.2 송장처리 시 데이터 설정
- `invoice_seq`, `invoice_prod_seq` : 상위 송장 정보 참조
- `sku1`, `sku2` : 처리된 재고의 SKU 정보
- `exp_ymd`, `lot_no`, `mng_ymd` : 출고된 재고의 유통기한/LOT/제조일자 정보
- `fr_wh_seq`, `fr_loc_seq` : 출고된 창고/위치 정보
- `proc_qty` : 실제 처리 수량
- `outbiz_tran_seq` : 연동된 출하처리 SEQ (송장출하 시)

### 6.3 송장처리 유형

#### 6.3.1 송장출하 연동 처리
- `wms_outbiz_tran` 생성 시 `invoice_seq` 정보 포함
- `wms_outbiz_tran` → `wms_invoice_tran` 자동 생성
- `outbiz_tran_seq`에 출하처리 SEQ 저장

#### 6.3.2 송장 확정 처리
- 송장 확정(`invoice_sts_cd` = '77') 시 처리 이력 생성
- 재고 변동 없이 송장 상태 변경 이력만 기록

#### 6.3.3 송장 출력/재출력
- 송장 출력 시마다 이력 생성 가능
- `re_print_cnt` 증가와 연동

### 6.4 송장처리 후 연동 처리

#### 6.4.1 송장 상태 갱신
1. **`wms_invoice_prod` 처리수량 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
2. **`wms_invoice` 헤더 상태 갱신**
- 해당 송장의 모든 품목 처리 완료 시 `invoice_sts_cd` = '77'(확정)

#### 6.4.2 재고 영향
- 송장처리 자체는 재고에 직접 영향 없음
- 출하처리(`wms_outbiz_tran`)를 통해 재고 차감됨
- 송장처리는 출하처리와 연동되어 이력 관리

### 6.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 송장 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.6 취소/삭제
- 송장 확정(`'77'`) 후에는 취소(`'99'`)만 가능
- 송장 취소 시 연동된 송장처리 이력도 함께 취소 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 송장처리 이력 조회
SELECT t.invoice_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       iv.invoice_no, p.prod_nm
FROM wms_invoice_tran t
    JOIN wms_invoice iv ON t.invoice_seq = iv.invoice_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 송장의 처리 상세 내역
SELECT t.invoice_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       t.outbiz_tran_seq,
       ip.req_qty, ip.ex_qty
FROM wms_invoice_tran t
    JOIN wms_invoice_prod ip ON t.invoice_prod_seq = ip.invoice_prod_seq
WHERE t.invoice_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 출하처리와 송장처리 연동 조회
SELECT ot.outbiz_tran_seq, ot.sku1 AS outbiz_sku1, ot.proc_qty AS outbiz_qty,
       it.invoice_tran_seq, it.sku1 AS invoice_sku1, it.proc_qty AS invoice_qty,
       ob.outbiz_no, iv.invoice_no
FROM wms_outbiz_tran ot
    JOIN wms_invoice_tran it ON ot.outbiz_tran_seq = it.outbiz_tran_seq
    JOIN wms_outbiz ob ON ot.outbiz_seq = ob.outbiz_seq
    JOIN wms_invoice iv ON it.invoice_seq = iv.invoice_seq
WHERE ob.biz_seq = 1
AND ot.proc_ymd = '20250226'
AND ot.del_yn = 'N'
AND it.del_yn = 'N'
ORDER BY ot.proc_ymd, ot.proc_hms;

-- 품목별 송장 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT t.invoice_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       AVG(t.proc_qty) AS avg_qty
FROM wms_invoice_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 창고별 송장 처리 현황
SELECT w.wh_nm,
       COUNT(DISTINCT t.invoice_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_invoice_tran t
    JOIN mdm_wh w ON t.fr_wh_seq = w.wh_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY total_qty DESC;

-- 송장 처리 소요 시간 분석 (출하처리 → 송장처리)
SELECT ot.outbiz_tran_seq,
       ot.proc_ymd || ot.proc_hms AS outbiz_proc_dtm,
       it.proc_ymd || it.proc_hms AS invoice_proc_dtm,
       (TO_TIMESTAMP(it.proc_ymd || it.proc_hms, 'YYYYMMDDHH24MISS') - 
        TO_TIMESTAMP(ot.proc_ymd || ot.proc_hms, 'YYYYMMDDHH24MISS')) AS elapsed_time,
       ob.outbiz_no, iv.invoice_no
FROM wms_outbiz_tran ot
    JOIN wms_invoice_tran it ON ot.outbiz_tran_seq = it.outbiz_tran_seq
    JOIN wms_outbiz ob ON ot.outbiz_seq = ob.outbiz_seq
    JOIN wms_invoice iv ON it.invoice_seq = iv.invoice_seq
WHERE ot.biz_seq = 1
AND ot.proc_ymd = '20250226'
AND ot.del_yn = 'N'
AND it.del_yn = 'N'
ORDER BY elapsed_time;

-- IF 송신 대기 건 조회
SELECT t.invoice_tran_seq, iv.invoice_no, p.prod_nm,
       t.sku1, t.sku2, t.proc_qty,
       t.proc_ymd, t.proc_hms
FROM wms_invoice_tran t
    JOIN wms_invoice iv ON t.invoice_seq = iv.invoice_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;
```