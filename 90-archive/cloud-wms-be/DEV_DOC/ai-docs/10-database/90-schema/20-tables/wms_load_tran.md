# wms_load_tran (WMS_상차처리)

## 1. 개요
상차 작업 시 **실제 상차된 내역을 저장하는 처리 이력(Transaction) 테이블**.
상차 확정 시 생성되며, 출하처리(`wms_outbiz_tran`)와 연동되어 출하 완료 처리를 트리거한다.

### 1.1 상차처리 데이터 흐름
```
wms_load (상차 헤더)
└─ wms_load_prod (상차 품목)
        └─ wms_load_tran (상차 처리 이력) ← **현재 테이블**
              ↓
        wms_outbiz_tran (출하 처리 이력) 생성
              ↓
        재고 차감 및 출하 완료 처리
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | load_tran_seq | bigint | N | nextval('wms_load_tran_seq') | 상차처리 SEQ |
| FK | load_prod_seq | bigint | N | | 상차품목 SEQ → wms_load_prod |
| FK | load_seq | integer | N | | 상차 SEQ → wms_load |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1 | varchar(100) | N | | SKU1 (상차된 재고단위1) |
| | sku2 | varchar(100) | N | | SKU2 (상차된 재고단위2) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | fr_wh_seq | integer | Y | | 출고 창고 SEQ → mdm_wh |
| | fr_loc_seq | bigint | Y | | 출고 위치 SEQ → mdm_loc |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | to_wh_seq | integer | Y | | 이동 창고 SEQ (상차시는 NULL) |
| | to_loc_seq | bigint | Y | | 이동 위치 SEQ (상차시는 NULL) |
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
| wms_load_tran_PK | load_tran_seq, load_prod_seq, load_seq | Y | Y |
| IX_wms_load_tran_sku | sku1, sku2 | N | |
| IX_wms_load_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_load_tran_outbiz | outbiz_tran_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| load_tran_seq | wms_load_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| load_prod_seq, load_seq | wms_load_prod | load_prod_seq, load_seq | wms_load_prod_TO_wms_load_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_load_tran |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_load_tran |
| fr_loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_load_tran |
| outbiz_tran_seq | wms_outbiz_tran | outbiz_tran_seq | wms_outbiz_tran_TO_wms_load_tran |

---

## 6. 업무 규칙

### 6.1 상차처리 생성 조건
- 상차 작업 완료(확정) 시 생성
- `wms_load_prod`의 요청 수량(`req_qty`) 범위 내에서 처리
- 상차 확정(`load_sts_cd` = '77') 시 자동 생성

### 6.2 상차처리 시 데이터 설정
- `load_seq`, `load_prod_seq` : 상위 상차 정보 참조
- `sku1`, `sku2` : 상차된 재고의 SKU 정보
- `lot_no`, `mng_ymd`, `exp_ymd` : 상차된 재고의 LOT/제조일자/유통기한 정보
- `fr_wh_seq`, `fr_loc_seq` : 출고된 창고/위치 정보
- `proc_qty` : 실제 상차 처리 수량
- `proc_bundle_no` : 동시에 여러 품목 상차 시 묶음 번호

### 6.3 상차처리 후 연동 처리

#### 6.3.1 출하처리 생성
- `wms_outbiz_tran` 자동 생성
- 생성된 출하처리 SEQ를 `outbiz_tran_seq`에 저장
- 출하처리를 통해 재고 차감 및 출하 완료 처리

#### 6.3.2 상차 상태 갱신
- **`wms_load_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `load_prod_sts_cd` = '77'(확정)
- **`wms_load` 헤더 상태 갱신**
- 해당 상차의 모든 품목이 확정('77')되면 `load_sts_cd` = '77'(확정)

#### 6.3.3 출하 상태 갱신 (간접)
- 생성된 `wms_outbiz_tran`을 통해 출하 상태 갱신
- `wms_outbiz_prod.ex_qty` 증가 및 상태 변경
- `wms_outbiz` 헤더 상태 변경

### 6.4 재고 영향
- 상차처리 자체는 재고에 직접 영향 없음
- 연동된 출하처리(`wms_outbiz_tran`)를 통해 재고 차감됨

### 6.5 IF 송신
- `if_send_yn` : 외부 시스템(ERP/WES)으로 상차 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.6 취소/삭제
- 상차 확정(`'77'`) 후에는 취소 불가 (출하처리 이미 생성)
- 오류 시 별도의 재고조정(`wms_inven_ad`) 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 상차처리 이력 조회
SELECT t.load_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       ld.load_no, p.prod_nm,
       t.outbiz_tran_seq
FROM wms_load_tran t
    JOIN wms_load ld ON t.load_seq = ld.load_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND ld.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 상차의 처리 상세 내역
SELECT t.load_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.fr_wh_seq, t.fr_loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       t.outbiz_tran_seq,
       lp.req_qty, lp.ex_qty, lp.load_prod_sts_cd
FROM wms_load_tran t
    JOIN wms_load_prod lp ON t.load_prod_seq = lp.load_prod_seq
WHERE t.load_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 상차처리와 출하처리 연동 조회
SELECT lt.load_tran_seq, lt.sku1 AS load_sku1, lt.proc_qty AS load_qty,
       ot.outbiz_tran_seq, ot.sku1 AS outbiz_sku1, ot.proc_qty AS outbiz_qty,
       ld.load_no, ob.outbiz_no
FROM wms_load_tran lt
    JOIN wms_outbiz_tran ot ON lt.outbiz_tran_seq = ot.outbiz_tran_seq
    JOIN wms_load ld ON lt.load_seq = ld.load_seq
    JOIN wms_outbiz ob ON ot.outbiz_seq = ob.outbiz_seq
WHERE ld.biz_seq = 1
AND lt.proc_ymd = '20250226'
AND lt.del_yn = 'N'
AND ot.del_yn = 'N'
ORDER BY lt.proc_ymd, lt.proc_hms;

-- 품목별 상차 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT lt.load_tran_seq) AS tran_cnt,
       SUM(lt.proc_qty) AS total_qty,
       AVG(lt.proc_qty) AS avg_qty
FROM wms_load_tran lt
    JOIN mdm_prod p ON lt.prod_seq = p.prod_seq
WHERE lt.biz_seq = 1
AND lt.proc_ymd BETWEEN '20250201' AND '20250228'
AND lt.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 창고별 상차 처리 현황
SELECT w.wh_nm,
       COUNT(DISTINCT lt.load_tran_seq) AS tran_cnt,
       SUM(lt.proc_qty) AS total_qty
FROM wms_load_tran lt
    JOIN mdm_wh w ON lt.fr_wh_seq = w.wh_seq
WHERE lt.biz_seq = 1
AND lt.proc_ymd = '20250226'
AND lt.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY total_qty DESC;

-- 상차 처리 소요 시간 분석 (상차예정 → 상차처리)
SELECT lp.load_prod_seq,
       lp.reg_dt AS plan_dt,
       lt.proc_ymd || lt.proc_hms AS proc_dtm,
       (TO_TIMESTAMP(lt.proc_ymd || lt.proc_hms, 'YYYYMMDDHH24MISS') - 
        lp.reg_dt) AS elapsed_time,
       ld.load_no, p.prod_nm, lp.req_qty
FROM wms_load_prod lp
    JOIN wms_load_tran lt ON lp.load_prod_seq = lt.load_prod_seq
    JOIN wms_load ld ON lp.load_seq = ld.load_seq
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND lt.proc_ymd = '20250226'
AND lp.del_yn = 'N'
AND lt.del_yn = 'N'
ORDER BY elapsed_time;

-- 묶음 번호별 처리 현황
SELECT lt.proc_bundle_no,
       COUNT(DISTINCT lt.load_tran_seq) AS tran_cnt,
       COUNT(DISTINCT lt.load_seq) AS load_cnt,
       SUM(lt.proc_qty) AS total_qty,
       MIN(lt.proc_ymd || lt.proc_hms) AS start_time,
       MAX(lt.proc_ymd || lt.proc_hms) AS end_time
FROM wms_load_tran lt
WHERE lt.biz_seq = 1
AND lt.proc_bundle_no IS NOT NULL
AND lt.proc_ymd = '20250226'
AND lt.del_yn = 'N'
GROUP BY lt.proc_bundle_no
ORDER BY lt.proc_bundle_no;

-- IF 송신 대기 건 조회
SELECT lt.load_tran_seq, ld.load_no, p.prod_nm,
       lt.sku1, lt.sku2, lt.proc_qty,
       lt.proc_ymd, lt.proc_hms,
       lt.outbiz_tran_seq
FROM wms_load_tran lt
    JOIN wms_load ld ON lt.load_seq = ld.load_seq
    JOIN mdm_prod p ON lt.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND lt.if_send_yn = 'N'
AND lt.del_yn = 'N'
ORDER BY lt.reg_dt;
```