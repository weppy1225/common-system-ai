# wms_outwh_tran (WMS_출고처리)

## 1. 개요
출고 처리 시 **실제 출고된 내역을 저장하는 처리 이력(Transaction) 테이블**.
피킹 완료 및 출고 확정 시 생성되며, 재고 차감의 직접적인 근거가 된다.

### 1.1 출고처리 데이터 흐름
```
wms_outwh (출고 헤더)
└─ wms_outwh_prod (출고 품목)
        └─ wms_outwh_assign (출고 지시) - 재고 위치 지정
              └─ wms_outwh_tran (출고 처리 이력) ← **현재 테이블**
                    ↓
              재고모듈
              ├─ wms_inven 재고 차감
              ├─ wms_inven_sku 이력 등록
              └─ wms_inven_inout 수불이력 등록
                    ↓
              wms_outbiz_outwh (출하-출고 연결) → 출하 처리 연동
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outwh_tran_seq | bigint | N | nextval('wms_outwh_tran_seq') | 출고처리 SEQ |
| FK | outwh_prod_seq | bigint | N | | 출고품목 SEQ → wms_outwh_prod |
| FK | outwh_seq | integer | N | | 출고 SEQ → wms_outwh |
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
| | to_wh_seq | integer | Y | | 이동 창고 SEQ (출고시는 NULL) |
| | to_loc_seq | bigint | Y | | 이동 위치 SEQ (출고시는 NULL) |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
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
| wms_outwh_tran_PK | outwh_tran_seq, outwh_prod_seq, outwh_seq | Y | Y |
| IX_wms_outwh_tran_sku | sku1, sku2 | N | |
| IX_wms_outwh_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_outwh_tran_loc | fr_wh_seq, fr_loc_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outwh_tran_seq | wms_outwh_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outwh_prod_seq, outwh_seq | wms_outwh_prod | outwh_prod_seq, outwh_seq | wms_outwh_prod_TO_wms_outwh_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outwh_tran |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_outwh_tran |
| fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_outwh_tran |

---

## 6. 업무 규칙

### 6.1 출고처리 생성 조건
- 피킹 완료 및 출고 확정 시 생성
- `wms_outwh_prod`의 요청 수량(`req_qty`) 범위 내에서 처리
- `wms_outwh_assign`에서 지정된 재고 위치 기준으로 처리

### 6.2 출고처리 시 데이터 설정
- `outwh_seq`, `outwh_prod_seq` : 상위 출고 정보 참조
- `sku1`, `sku2` : 출고된 재고의 SKU 정보
- `mng_ymd`, `exp_ymd`, `lot_no` : 출고된 재고의 제조일자/유통기한/LOT 정보
- `fr_wh_seq`, `fr_loc_seq` : 출고된 창고/위치 정보
- `proc_qty` : 실제 처리 수량
- `proc_bundle_no` : 동시에 여러 품목 처리 시 묶음 번호

### 6.3 출고처리 후 연동 처리

#### 6.3.1 재고모듈 (자동 연동)
- **`wms_inven` 재고 차감**
- `sku1`, `sku2`, `fr_wh_seq`, `fr_loc_seq` 기준으로 재고 존재 확인
- `inven_qty`에서 `proc_qty`만큼 차감
- **`wms_inven_sku` 이력 등록**
- SKU 단위 출고 이력 저장
- **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `OW`로 출고 처리 이력 저장

#### 6.3.2 출고 상태 갱신
- **`wms_outwh_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `outwh_prod_sts_cd` = '77'(확정)
- **`wms_outwh` 헤더 상태 갱신**
- 해당 출고의 모든 품목이 확정('77')되면 `outwh_sts_cd` = '77'(확정)

#### 6.3.3 출하 연동
- `wms_outbiz_outwh`를 통해 출하 정보와 연결
- 출고 확정 시 연결된 출하의 출하처리(`wms_outbiz_tran`) 생성

### 6.4 분할 출고 처리
- 하나의 출고품목에 대해 여러 번에 나누어 출고 처리 가능
- 각 처리 건마다 `outwh_tran_seq` 별도 생성
- `ex_qty` 누적 관리로 잔여 수량 추적

### 6.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 출고 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.6 취소/삭제
- 출고 처리 확정 후에는 취소 불가 (재고 변동 발생)
- 오류 시 별도의 재고조정(`wms_inven_ad`) 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 출고처리 이력 조회
SELECT t.outwh_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       ow.outwh_no, p.prod_nm
FROM wms_outwh_tran t
    JOIN wms_outwh ow ON t.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND ow.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 출고의 처리 상세 내역
SELECT t.outwh_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       op.req_qty, op.ex_qty, op.outwh_prod_sts_cd
FROM wms_outwh_tran t
    JOIN wms_outwh_prod op ON t.outwh_prod_seq = op.outwh_prod_seq
WHERE t.outwh_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 출고지시와 출고처리 연동 조회
SELECT oa.outwh_assign_seq, oa.sku1 AS assign_sku1, oa.req_qty AS assign_qty,
       t.outwh_tran_seq, t.sku1 AS tran_sku1, t.proc_qty AS tran_qty,
       ow.outwh_no, p.prod_nm
FROM wms_outwh_assign oa
    LEFT JOIN wms_outwh_tran t ON oa.outwh_assign_seq = t.outwh_assign_seq
    JOIN wms_outwh_prod op ON oa.req_prod_seq = op.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON oa.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND ow.outwh_no = 'OW2502260001'
AND oa.del_yn = 'N'
ORDER BY oa.outwh_assign_seq;

-- 품목별 출고 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT t.outwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       AVG(t.proc_qty) AS avg_qty
FROM wms_outwh_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 창고별 출고 처리 현황
SELECT w.wh_nm,
       COUNT(DISTINCT t.outwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_outwh_tran t
    JOIN mdm_wh w ON t.fr_wh_seq = w.wh_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY total_qty DESC;

-- 위치별 출고 처리 현황
SELECT w.wh_nm, l.loc_nm,
       COUNT(t.outwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_outwh_tran t
    JOIN mdm_wh w ON t.fr_wh_seq = w.wh_seq
    JOIN mdm_loc l ON t.fr_loc_seq = l.loc_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm, l.loc_nm
ORDER BY total_qty DESC;

-- 출고 처리 소요 시간 분석 (출고예정 → 출고처리)
SELECT op.outwh_prod_seq,
       op.reg_dt AS plan_dt,
       t.proc_ymd || t.proc_hms AS proc_dtm,
       (TO_TIMESTAMP(t.proc_ymd || t.proc_hms, 'YYYYMMDDHH24MISS') - 
        op.reg_dt) AS elapsed_time,
       ow.outwh_no, p.prod_nm, op.req_qty
FROM wms_outwh_prod op
    JOIN wms_outwh_tran t ON op.outwh_prod_seq = t.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND t.proc_ymd = '20250226'
AND op.del_yn = 'N'
AND t.del_yn = 'N'
ORDER BY elapsed_time;

-- 묶음 번호별 처리 현황
SELECT t.proc_bundle_no,
       COUNT(DISTINCT t.outwh_tran_seq) AS tran_cnt,
       COUNT(DISTINCT t.outwh_seq) AS outwh_cnt,
       SUM(t.proc_qty) AS total_qty,
       MIN(t.proc_ymd || t.proc_hms) AS start_time,
       MAX(t.proc_ymd || t.proc_hms) AS end_time
FROM wms_outwh_tran t
WHERE t.biz_seq = 1
AND t.proc_bundle_no IS NOT NULL
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY t.proc_bundle_no
ORDER BY t.proc_bundle_no;

-- IF 송신 대기 건 조회
SELECT t.outwh_tran_seq, ow.outwh_no, p.prod_nm,
       t.sku1, t.sku2, t.proc_qty,
       t.proc_ymd, t.proc_hms
FROM wms_outwh_tran t
    JOIN wms_outwh ow ON t.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;
```