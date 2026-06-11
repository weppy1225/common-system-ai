# wms_inven_mv_tran (WMS_재고이동처리)

## 1. 개요
재고이동 처리 시 **실제 재고가 이동된 내역을 저장하는 처리 이력(Transaction) 테이블**.
재고이동 확정 시 생성되며, 재고 위치 변경의 직접적인 근거가 된다.

### 1.1 재고이동처리 데이터 흐름
```
wms_inven_mv (재고이동 헤더)
└─ wms_inven_mv_prod (재고이동 품목)
        └─ wms_inven_mv_tran (재고이동 처리 이력) ← **현재 테이블**
              ↓
        재고모듈
        ├─ wms_inven 재고 위치 변경 (FROM 위치 차감, TO 위치 증가)
        ├─ wms_inven_sku 이력 등록
        └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | mv_tran_seq | bigint | N | nextval('wms_inven_mv_tran_seq') | 재고이동처리 SEQ |
| FK | mv_prod_seq | bigint | N | | 재고이동품목 SEQ → wms_inven_mv_prod |
| FK | mv_seq | integer | N | | 재고이동 SEQ → wms_inven_mv |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | fr_wh_seq | integer | N | | 이동전 창고 SEQ (FROM) → mdm_wh |
| | fr_loc_seq | bigint | N | | 이동전 위치 SEQ (FROM) → mdm_loc |
| | fr_sku1 | varchar(100) | N | | 이동전 SKU1 (FROM) |
| | fr_sku2 | varchar(100) | N | | 이동전 SKU2 (FROM) |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | to_wh_seq | integer | N | | 이동후 창고 SEQ (TO) → mdm_wh |
| | to_loc_seq | bigint | N | | 이동후 위치 SEQ (TO) → mdm_loc |
| | to_sku2 | varchar(100) | Y | | 이동후 SKU2 (TO) |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
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
| wms_inven_mv_tran_PK | mv_tran_seq, mv_prod_seq, mv_seq | Y | Y |
| IX_wms_inven_mv_tran_fr | fr_wh_seq, fr_loc_seq, fr_sku1, fr_sku2 | N | |
| IX_wms_inven_mv_tran_to | to_wh_seq, to_loc_seq, to_sku2 | N | |
| IX_wms_inven_mv_tran_proc | proc_ymd, proc_user_id | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| mv_tran_seq | wms_inven_mv_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| mv_prod_seq, mv_seq | wms_inven_mv_prod | mv_prod_seq, mv_seq | wms_inven_mv_prod_TO_wms_inven_mv_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_mv_tran |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_tran_fr |
| fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_mv_tran_fr |
| to_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_tran_to |
| to_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_mv_tran_to |

---

## 6. 업무 규칙

### 6.1 재고이동처리 생성 조건
- 재고이동 확정 시 생성
- `wms_inven_mv_prod`의 요청 수량(`req_qty`) 범위 내에서 처리
- 부분 이동 가능 (여러 번에 나누어 처리)

### 6.2 재고이동처리 시 데이터 설정
- `mv_seq`, `mv_prod_seq` : 상위 재고이동 정보 참조
- **FROM 정보** : 이동 전 재고 위치/SKU
- `fr_wh_seq`, `fr_loc_seq`, `fr_sku1`, `fr_sku2`
- **TO 정보** : 이동 후 재고 위치/SKU
- `to_wh_seq`, `to_loc_seq`, `to_sku2`
- `proc_qty` : 실제 처리 수량 (항상 양수)
- `mng_ymd`, `exp_ymd`, `lot_no` : 이동된 재고의 제조일자/유통기한/LOT 정보
- `proc_bundle_no` : 동시에 여러 품목 처리 시 묶음 번호

### 6.3 SKU 변경
- `to_sku2` : 이동 후 SKU2가 변경될 수 있음 (파렛트 변경 등)
- SKU1은 일반적으로 동일하게 유지
- SKU2 변경 시 새 파렛트 라벨 발행 필요

### 6.4 재고이동처리 후 연동 처리

#### 6.4.1 재고모듈 (자동 연동)
- **FROM 위치 재고 차감**
- `fr_wh_seq`, `fr_loc_seq`, `fr_sku1`, `fr_sku2` 기준 재고 차감
- `inven_qty`에서 `proc_qty`만큼 차감
- **TO 위치 재고 증가**
- `to_wh_seq`, `to_loc_seq`, `fr_sku1`, `to_sku2` 기준 재고 확인
- 존재하지 않으면 신규 등록, 존재하면 `inven_qty` 증가
- **`wms_inven_sku` 이력 등록**
- FROM SKU 출고 이력, TO SKU 입고 이력 각각 등록
- **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `IM`으로 이동 처리 이력 저장

#### 6.4.2 재고이동 상태 갱신
- **`wms_inven_mv_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `mv_prod_sts_cd` = '77'(확정)
- **`wms_inven_mv` 헤더 상태 갱신**
- 해당 이동의 모든 품목이 확정('77')되면 `mv_sts_cd` = '77'(확정)

### 6.5 부분 이동
- 하나의 이동품목에 대해 여러 번에 나누어 처리 가능
- 각 처리 건마다 `mv_tran_seq` 별도 생성
- `ex_qty` 누적 관리로 잔여 수량 추적

### 6.6 IF 송신
- `if_send_yn` : 외부 시스템(ERP/WMS)으로 이동 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.7 취소/삭제
- 이동 처리 확정 후에는 취소 불가 (재고 변동 발생)
- 오류 시 별도의 역이동 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 재고이동처리 이력 조회
SELECT t.mv_tran_seq,
       t.fr_sku1, t.fr_sku2, t.to_sku2,
       t.proc_qty,
       t.fr_wh_seq, t.fr_loc_seq,
       t.to_wh_seq, t.to_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       mv.mv_no, p.prod_nm
FROM wms_inven_mv_tran t
    JOIN wms_inven_mv mv ON t.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mv.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 재고이동의 처리 상세 내역
SELECT t.mv_tran_seq,
       t.fr_sku1, t.fr_sku2,
       t.to_sku2,
       t.proc_qty,
       fw.wh_nm AS from_wh, fl.loc_nm AS from_loc,
       tw.wh_nm AS to_wh, tl.loc_nm AS to_loc,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       t.mng_ymd, t.exp_ymd, t.lot_no,
       mp.req_qty, mp.ex_qty, mp.mv_prod_sts_cd
FROM wms_inven_mv_tran t
    JOIN wms_inven_mv_prod mp ON t.mv_prod_seq = mp.mv_prod_seq
    JOIN mdm_wh fw ON t.fr_wh_seq = fw.wh_seq
    JOIN mdm_loc fl ON t.fr_loc_seq = fl.loc_seq
    JOIN mdm_wh tw ON t.to_wh_seq = tw.wh_seq
    JOIN mdm_loc tl ON t.to_loc_seq = tl.loc_seq
WHERE t.mv_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- SKU2 변경이 발생한 이동 처리
SELECT t.mv_tran_seq, mv.mv_no,
       t.fr_sku2 AS from_sku2,
       t.to_sku2 AS to_sku2,
       t.proc_qty,
       p.prod_nm
FROM wms_inven_mv_tran t
    JOIN wms_inven_mv mv ON t.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND t.fr_sku2 != t.to_sku2
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd;

-- 위치별 이동 현황 (FROM 기준)
SELECT fw.wh_nm, fl.loc_nm,
       COUNT(t.mv_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_inven_mv_tran t
    JOIN mdm_wh fw ON t.fr_wh_seq = fw.wh_seq
    JOIN mdm_loc fl ON t.fr_loc_seq = fl.loc_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY fw.wh_nm, fl.loc_nm
ORDER BY total_qty DESC;

-- 위치별 이동 현황 (TO 기준)
SELECT tw.wh_nm, tl.loc_nm,
       COUNT(t.mv_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_inven_mv_tran t
    JOIN mdm_wh tw ON t.to_wh_seq = tw.wh_seq
    JOIN mdm_loc tl ON t.to_loc_seq = tl.loc_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY tw.wh_nm, tl.loc_nm
ORDER BY total_qty DESC;

-- 품목별 재고이동 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT t.mv_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       AVG(t.proc_qty) AS avg_qty
FROM wms_inven_mv_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- LOT별 재고이동 현황
SELECT t.lot_no,
       p.prod_nm,
       COUNT(t.mv_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       MIN(t.exp_ymd) AS earliest_exp
FROM wms_inven_mv_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.lot_no IS NOT NULL
AND t.proc_ymd >= '20250201'
AND t.del_yn = 'N'
GROUP BY t.lot_no, p.prod_nm
ORDER BY earliest_exp;

-- 묶음 번호별 처리 현황
SELECT t.proc_bundle_no,
       COUNT(DISTINCT t.mv_tran_seq) AS tran_cnt,
       COUNT(DISTINCT t.mv_seq) AS mv_cnt,
       SUM(t.proc_qty) AS total_qty,
       MIN(t.proc_ymd || t.proc_hms) AS start_time,
       MAX(t.proc_ymd || t.proc_hms) AS end_time
FROM wms_inven_mv_tran t
WHERE t.biz_seq = 1
AND t.proc_bundle_no IS NOT NULL
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY t.proc_bundle_no
ORDER BY t.proc_bundle_no;

-- IF 송신 대기 건 조회
SELECT t.mv_tran_seq, mv.mv_no, p.prod_nm,
       t.fr_sku1, t.fr_sku2, t.to_sku2,
       t.proc_qty, t.proc_ymd, t.proc_hms
FROM wms_inven_mv_tran t
    JOIN wms_inven_mv mv ON t.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;
```