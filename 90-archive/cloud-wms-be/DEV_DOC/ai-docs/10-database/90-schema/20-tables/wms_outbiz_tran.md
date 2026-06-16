# wms_outbiz_tran (WMS_출하처리)

## 1. 개요
출하 처리 시 **실제 출고된 내역을 저장하는 처리 이력(Transaction) 테이블**.
피킹 및 출고 확정을 통해 재고가 차감될 때마다 생성되며, 재고 감소의 직접적인 근거가 된다.

### 1.1 출하처리 데이터 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_tran (출하 처리 이력) ← **현재 테이블**
              ├─ 재고모듈
              │    ├─ wms_inven 재고 차감
              │    ├─ wms_inven_sku 이력 등록
              │    └─ wms_inven_inout 수불이력 등록
              │
              └─ 연계 테이블
                   ├─ wms_outbiz_invoice (송장출하)
                   ├─ wms_outbiz_load (상차출하)
                   └─ wms_outbiz_outwh (출고지시)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outbiz_tran_seq | bigint | N | nextval('wms_outbiz_tran_seq') | 출하처리 SEQ |
| FK | outbiz_prod_seq | bigint | N | | 출하품목 SEQ → wms_outbiz_prod |
| FK | outbiz_seq | integer | N | | 출하 SEQ → wms_outbiz |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1 | varchar(100) | N | | SKU1 (출고된 재고단위1) |
| | sku2 | varchar(100) | N | | SKU2 (출고된 재고단위2) |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | fr_wh_seq | integer | Y | | 출고 창고 SEQ → mdm_wh |
| | fr_loc_seq | bigint | Y | | 출고 위치 SEQ → mdm_loc |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | to_wh_seq | integer | Y | | 이동 창고 SEQ (출하시는 NULL) |
| | to_loc_seq | bigint | Y | | 이동 위치 SEQ (출하시는 NULL) |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | group_outwh_no | varchar(30) | Y | | 그룹 출고 번호 |
| | invoice_seq | integer | Y | | 송장 SEQ (송장출하 시) |
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
| wms_outbiz_tran_PK | outbiz_tran_seq, outbiz_prod_seq, outbiz_seq | Y | Y |
| UIX_wms_outbiz_tran | outbiz_tran_seq | Y | |
| IX_wms_outbiz_tran_sku | sku1, sku2 | N | |
| IX_wms_outbiz_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_outbiz_tran_group | group_outwh_no | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outbiz_tran_seq | wms_outbiz_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outbiz_prod_seq, outbiz_seq | wms_outbiz_prod | outbiz_prod_seq, outbiz_seq | wms_outbiz_prod_TO_wms_outbiz_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outbiz_tran |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_outbiz_tran |
| fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_outbiz_tran |
| invoice_seq | wms_invoice | invoice_seq | wms_invoice_TO_wms_outbiz_tran |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 비고 |
|---|---|---|
| wms_load_tran | outbiz_tran_seq | 상차처리 연결 |
| wms_invoice_tran | outbiz_tran_seq | 송장처리 연결 |

---

## 7. 업무 규칙

### 7.1 출하처리 생성 조건
- 피킹 완료 및 출고 확정 시 생성
- `wms_outbiz_prod`의 요청 수량(`req_qty`) 범위 내에서 처리

### 7.2 출하처리 시 데이터 설정
- `outbiz_seq`, `outbiz_prod_seq` : 상위 출하 정보 참조
- `sku1`, `sku2` : 출고된 재고의 SKU 정보
- `mng_ymd`, `exp_ymd`, `lot_no` : 출고된 재고의 제조일자/유통기한/LOT 정보
- `fr_wh_seq`, `fr_loc_seq` : 출고된 창고/위치 정보
- `proc_qty` : 실제 처리 수량
- `group_outwh_no` : 동시 출고 그룹 번호 (여러 출하를 묶어 처리 시)
- `invoice_seq` : 송장출하(OB03)의 경우 연결된 송장 정보
- `proc_ymd`, `proc_hms`, `proc_user_id` : 처리 시점 정보

### 7.3 출하처리 후 연동 처리

#### 7.3.1 재고모듈 (자동 연동)
1. **`wms_inven` 재고 차감**
- `sku1`, `sku2`, `fr_wh_seq`, `fr_loc_seq` 기준으로 재고 존재 확인
- `inven_qty`에서 `proc_qty`만큼 차감
2. **`wms_inven_sku` 이력 등록**
- SKU 단위 출고 이력 저장
3. **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `OB`로 출고 처리 이력 저장

#### 7.3.2 출하 상태 갱신 (직접 update)
1. **`wms_outbiz_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `outbiz_prod_sts_cd` = '77'(확정)
2. **`wms_outbiz` 헤더 상태 갱신**
- 해당 출하의 모든 품목이 확정('77')되면 `outbiz_sts_cd` = '77'(확정)

### 7.4 출하 유형별 특이사항

#### 7.4.1 OB01 (일반출하)
- 기본적인 출하처리 흐름

#### 7.4.2 OB03 (송장출하)
- `invoice_seq`에 송장 정보 저장
- `wms_invoice_tran`과 연동되어 송장 처리

#### 7.4.3 OB05 (상차출하)
- `wms_load_tran`에서 `outbiz_tran_seq` 참조
- 상차 완료 후 출하처리 연동

#### 7.4.4 OB07 (즉시출하)
- 출하등록과 동시에 처리 가능
- `proc_qty` = `req_qty` 로 한 번에 처리

### 7.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 출하 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 7.6 취소/삭제
- 출하 처리 확정 후에는 취소 불가 (재고 변동 발생)
- 오류 시 별도의 재고조정(`wms_inven_ad`) 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 출하처리 이력 조회
SELECT t.outbiz_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       ob.outbiz_no, p.prod_nm
FROM wms_outbiz_tran t
    JOIN wms_outbiz ob ON t.outbiz_seq = ob.outbiz_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND ob.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 출하건의 처리 상세 내역
SELECT t.outbiz_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       op.req_qty, op.ex_qty, op.outbiz_prod_sts_cd
FROM wms_outbiz_tran t
    JOIN wms_outbiz_prod op ON t.outbiz_prod_seq = op.outbiz_prod_seq
WHERE t.outbiz_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 품목별 출하 처리 현황
SELECT p.prod_nm,
       COUNT(*) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       AVG(t.proc_qty) AS avg_qty
FROM wms_outbiz_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 창고별 출하 처리 현황
SELECT w.wh_nm,
       COUNT(*) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_outbiz_tran t
    JOIN mdm_wh w ON t.fr_wh_seq = w.wh_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY total_qty DESC;

-- 그룹 출고 번호별 처리 현황
SELECT t.group_outwh_no,
       COUNT(DISTINCT t.outbiz_seq) AS outbiz_cnt,
       COUNT(*) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_outbiz_tran t
WHERE t.biz_seq = 1
AND t.group_outwh_no IS NOT NULL
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY t.group_outwh_no
ORDER BY t.group_outwh_no;

-- 출하 유형별 처리 현황
SELECT ob.outbiz_type_cd,
       COUNT(DISTINCT t.outbiz_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_outbiz_tran t
    JOIN wms_outbiz ob ON t.outbiz_seq = ob.outbiz_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY ob.outbiz_type_cd
ORDER BY ob.outbiz_type_cd;

-- IF 송신 대기 건 조회
SELECT t.outbiz_tran_seq, ob.outbiz_no, p.prod_nm,
       t.sku1, t.sku2, t.proc_qty,
       t.proc_ymd, t.proc_hms
FROM wms_outbiz_tran t
    JOIN wms_outbiz ob ON t.outbiz_seq = ob.outbiz_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;
```