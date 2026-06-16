# wms_inwh_tran (WMS_입고처리)

## 1. 개요
입고 처리 시 **실제 입고된 내역을 저장하는 처리 이력(Transaction) 테이블**.
라벨 스캔을 통해 실물 입고가 완료될 때마다 생성되며, 재고 증가의 직접적인 근거가 된다.

### 1.1 입고처리 데이터 흐름
```
wms_inwh (입고 헤더)
└─ wms_inwh_prod (입고 품목)
        └─ wms_inwh_label (입고 라벨) - 선발행 라벨
              └─ wms_inwh_tran (입고 처리 이력) ← **현재 테이블**
                    ↓
              재고모듈
              ├─ wms_inven 재고 등록/증가
              ├─ wms_inven_sku 이력 등록
              └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inwh_tran_seq | bigint | N | nextval('wms_inwh_tran_seq') | 입고처리 SEQ |
| FK | inwh_prod_seq | bigint | N | | 입고품목 SEQ → wms_inwh_prod |
| FK | inwh_seq | integer | N | | 입고 SEQ → wms_inwh |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1 | varchar(100) | N | | SKU1 (입고된 재고단위1) |
| | sku2 | varchar(100) | N | | SKU2 (입고된 재고단위2) |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | to_wh_seq | integer | N | | 입고 창고 SEQ → mdm_wh |
| | to_loc_seq | bigint | N | | 입고 위치 SEQ → mdm_loc |
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
| wms_inwh_tran_PK | inwh_tran_seq, inwh_prod_seq, inwh_seq | Y | Y |
| IX_wms_inwh_tran_sku | sku1, sku2 | N | |
| IX_wms_inwh_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_inwh_tran_loc | to_wh_seq, to_loc_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inwh_tran_seq | wms_inwh_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| inwh_prod_seq, inwh_seq | wms_inwh_prod | inwh_prod_seq, inwh_seq | wms_inwh_prod_TO_wms_inwh_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inwh_tran |
| to_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inwh_tran |
| to_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inwh_tran |

---

## 6. 업무 규칙

### 6.1 입고처리 생성 조건
- 라벨이 부착된 Box/Pallet 스캔 시 생성
- `wms_inwh_label`에서 `proc_yn = 'N'`인 라벨 조회 후 처리
- `wms_inwh_prod`의 요청 수량(`req_qty`) 범위 내에서 처리

### 6.2 입고처리 시 데이터 설정
- `inwh_seq`, `inwh_prod_seq` : 상위 입고 정보 참조
- `sku1`, `sku2` : 스캔된 라벨의 SKU 정보
- `mng_ymd`, `exp_ymd`, `lot_no` : 라벨의 제조일자/유통기한/LOT 정보
- `proc_qty` : 실제 처리 수량 (일반적으로 `wms_inwh_label.load_qty`와 동일)
- `to_wh_seq`, `to_loc_seq` : 입고될 창고/위치 정보
- `proc_bundle_no` : 동시에 여러 라벨 처리 시 묶음 번호

### 6.3 입고처리 후 연동 처리

#### 6.3.1 재고모듈 (자동 연동)
- **`wms_inven` 재고 등록/증가**
- `sku1`, `sku2`, `to_wh_seq`, `to_loc_seq` 기준으로 재고 존재 여부 확인
- 존재하지 않으면 신규 등록, 존재하면 `inven_qty` 증가
- **`wms_inven_sku` 이력 등록**
- SKU 단위 재고 이력 저장 (생성 이력)
- **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `IW`로 입고 처리 이력 저장

#### 6.3.2 입고 상태 갱신
- **`wms_inwh_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `inwh_prod_sts_cd` = '77'(확정)
- **`wms_inwh` 헤더 상태 갱신**
- 해당 입고의 모든 품목이 확정('77')되면 `inwh_sts_cd` = '77'(확정)
- **`wms_inwh_label` 처리 완료 갱신**
- `proc_yn` = 'Y'
- `proc_ymd`, `proc_hms`, `proc_user_id` 저장

### 6.4 분할 입고 처리
- 하나의 입고품목에 대해 여러 번에 나누어 입고 처리 가능
- 각 처리 건마다 `inwh_tran_seq` 별도 생성
- `ex_qty` 누적 관리로 잔여 수량 추적

### 6.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 입고 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.6 취소/삭제
- 입고 처리 확정 후에는 취소 불가 (재고 변동 발생)
- 오류 시 별도의 재고조정(`wms_inven_ad`) 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 입고처리 이력 조회
SELECT t.inwh_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.to_wh_seq, t.to_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       i.inwh_no, p.prod_nm
FROM wms_inwh_tran t
    JOIN wms_inwh i ON t.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 입고건의 처리 상세 내역
SELECT t.inwh_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.to_wh_seq, t.to_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       ip.req_qty, ip.ex_qty, ip.inwh_prod_sts_cd,
       l.mng_ymd, l.exp_ymd, l.lot_no
FROM wms_inwh_tran t
    JOIN wms_inwh_prod ip ON t.inwh_prod_seq = ip.inwh_prod_seq
    LEFT JOIN wms_inwh_label l ON t.sku1 = l.sku1 AND t.sku2 = l.sku2
WHERE t.inwh_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 라벨과 입고처리 연동 조회
SELECT l.inwh_label_seq, l.sku1, l.sku2, l.load_qty,
       t.inwh_tran_seq, t.proc_qty, t.proc_ymd,
       i.inwh_no, p.prod_nm
FROM wms_inwh_label l
    LEFT JOIN wms_inwh_tran t ON l.sku1 = t.sku1 AND l.sku2 = t.sku2
    JOIN wms_inwh i ON l.req_seq = i.inwh_seq
    JOIN mdm_prod p ON l.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.inwh_no = 'IW2502260001'
AND l.del_yn = 'N'
ORDER BY l.create_ymd, l.create_hms;

-- 품목별 입고 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT t.inwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       AVG(t.proc_qty) AS avg_qty
FROM wms_inwh_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 창고별 입고 처리 현황
SELECT w.wh_nm,
       COUNT(DISTINCT t.inwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_inwh_tran t
    JOIN mdm_wh w ON t.to_wh_seq = w.wh_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY total_qty DESC;

-- 위치별 입고 처리 현황
SELECT w.wh_nm, l.loc_nm,
       COUNT(t.inwh_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty
FROM wms_inwh_tran t
    JOIN mdm_wh w ON t.to_wh_seq = w.wh_seq
    JOIN mdm_loc l ON t.to_loc_seq = l.loc_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm, l.loc_nm
ORDER BY total_qty DESC;

-- 입고 처리 소요 시간 분석 (라벨 발행부터 처리까지)
SELECT l.inwh_label_seq,
       l.create_ymd || l.create_hms AS create_dtm,
       t.proc_ymd || t.proc_hms AS proc_dtm,
       (TO_TIMESTAMP(t.proc_ymd || t.proc_hms, 'YYYYMMDDHH24MISS') - 
        TO_TIMESTAMP(l.create_ymd || l.create_hms, 'YYYYMMDDHH24MISS')) AS elapsed_time,
       i.inwh_no, p.prod_nm, l.load_qty
FROM wms_inwh_label l
    JOIN wms_inwh_tran t ON l.sku1 = t.sku1 AND l.sku2 = t.sku2
    JOIN wms_inwh i ON t.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND t.proc_ymd = '20250226'
AND l.del_yn = 'N'
AND t.del_yn = 'N'
ORDER BY elapsed_time;

-- 묶음 번호별 처리 현황
SELECT t.proc_bundle_no,
       COUNT(DISTINCT t.inwh_tran_seq) AS tran_cnt,
       COUNT(DISTINCT t.inwh_seq) AS inwh_cnt,
       SUM(t.proc_qty) AS total_qty,
       MIN(t.proc_ymd || t.proc_hms) AS start_time,
       MAX(t.proc_ymd || t.proc_hms) AS end_time
FROM wms_inwh_tran t
WHERE t.biz_seq = 1
AND t.proc_bundle_no IS NOT NULL
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY t.proc_bundle_no
ORDER BY t.proc_bundle_no;

-- IF 송신 대기 건 조회
SELECT t.inwh_tran_seq, i.inwh_no, p.prod_nm,
       t.sku1, t.sku2, t.proc_qty,
       t.proc_ymd, t.proc_hms
FROM wms_inwh_tran t
    JOIN wms_inwh i ON t.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;
```