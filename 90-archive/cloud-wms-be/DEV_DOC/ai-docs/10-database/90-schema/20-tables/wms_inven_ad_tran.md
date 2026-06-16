# wms_inven_ad_tran (WMS_재고조정처리)

## 1. 개요
재고조정 처리 시 **실제 재고가 증감된 내역을 저장하는 처리 이력(Transaction) 테이블**.
재고조정 확정 시 생성되며, 재고 변동의 직접적인 근거가 된다.

### 1.1 재고조정처리 데이터 흐름
```
wms_inven_ad (재고조정 헤더)
└─ wms_inven_ad_prod (재고조정 품목)
        └─ wms_inven_ad_tran (재고조정 처리 이력) ← **현재 테이블**
              ↓
        재고모듈
        ├─ wms_inven 재고 증감 (증가/감소)
        ├─ wms_inven_sku 이력 등록
        └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | ad_tran_seq | bigint | N | nextval('wms_inven_ad_tran_seq') | 재고조정처리 SEQ |
| FK | ad_prod_seq | bigint | N | | 재고조정품목 SEQ → wms_inven_ad_prod |
| FK | ad_seq | integer | N | | 재고조정 SEQ → wms_inven_ad |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | wh_seq | integer | N | | 창고 SEQ → mdm_wh |
| | loc_seq | bigint | N | | 위치 SEQ → mdm_loc |
| | sku1 | varchar(100) | N | | SKU1 (조정된 재고단위1) |
| | sku2 | varchar(100) | N | | SKU2 (조정된 재고단위2) |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 (증가: 양수, 감소: 음수) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 (누적) |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | cn | integer | Y | | C/N (일련번호) |
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
| wms_inven_ad_tran_PK | ad_tran_seq, ad_prod_seq, ad_seq | Y | Y |
| IX_wms_inven_ad_tran_sku | sku1, sku2 | N | |
| IX_wms_inven_ad_tran_proc | proc_ymd, proc_user_id | N | |
| IX_wms_inven_ad_tran_loc | wh_seq, loc_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| ad_tran_seq | wms_inven_ad_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| ad_prod_seq, ad_seq | wms_inven_ad_prod | ad_prod_seq, ad_seq | wms_inven_ad_prod_TO_wms_inven_ad_tran |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_ad_tran |
| wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_ad_tran |
| loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_inven_ad_tran |

---

## 6. 업무 규칙

### 6.1 재고조정처리 생성 조건
- 재고조정 확정 시 생성
- `wms_inven_ad_prod`의 요청 수량(`req_qty`) 범위 내에서 처리
- 부분 조정 가능 (여러 번에 나누어 처리)

### 6.2 재고조정처리 시 데이터 설정
- `ad_seq`, `ad_prod_seq` : 상위 재고조정 정보 참조
- `wh_seq`, `loc_seq` : 조정된 재고의 창고/위치 정보
- `sku1`, `sku2` : 조정된 재고의 SKU 정보
- `proc_qty` : 실제 처리 수량
- **양수(+)**: 재고 증가
- **음수(-)**: 재고 감소
- `mng_ymd`, `exp_ymd`, `lot_no`, `cn` : 조정된 재고의 상세 정보
- `proc_bundle_no` : 동시에 여러 품목 처리 시 묶음 번호

### 6.3 재고조정 유형별 처리

#### 6.3.1 증가 조정 (proc_qty > 0)
- 신규 재고 생성 또는 기존 재고 수량 증가
- `new_inven_yn = 'Y'`인 경우 신규 SKU 생성
- 재고 위치, LOT 정보 등 신규 입력

#### 6.3.2 감소 조정 (proc_qty < 0)
- 기존 재고 수량 감소
- 기존 SKU 정보 활용
- 재고 부족 시 오류 처리

### 6.4 재고조정처리 후 연동 처리

#### 6.4.1 재고모듈 (자동 연동)
- **`wms_inven` 재고 증감**
- 증가: 신규 등록 또는 `inven_qty` 증가
- 감소: `inven_qty` 차감 (0 이하 불가)
- **`wms_inven_sku` 이력 등록**
- SKU 단위 조정 이력 저장
- **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `AD`로 조정 처리 이력 저장

#### 6.4.2 재고조정 상태 갱신
- **`wms_inven_ad_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `ad_prod_sts_cd` = '77'(확정)
- **`wms_inven_ad` 헤더 상태 갱신**
- 해당 조정의 모든 품목이 확정('77')되면 `ad_sts_cd` = '77'(확정)

### 6.5 부분 조정
- 하나의 조정품목에 대해 여러 번에 나누어 처리 가능
- 각 처리 건마다 `ad_tran_seq` 별도 생성
- `ex_qty` 누적 관리로 잔여 수량 추적

### 6.6 IF 송신
- `if_send_yn` : 외부 시스템(ERP/회계)으로 조정 처리 결과 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 6.7 취소/삭제
- 조정 처리 확정 후에는 취소 불가 (재고 변동 발생)
- 오류 시 별도의 역조정 프로세스로 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 7. 주요 조회 예시

```sql
-- 재고조정처리 이력 조회
SELECT t.ad_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.wh_seq, t.loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       ad.ad_no, p.prod_nm
FROM wms_inven_ad_tran t
    JOIN wms_inven_ad ad ON t.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ad.center_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 특정 재고조정의 처리 상세 내역
SELECT t.ad_tran_seq, t.sku1, t.sku2,
       t.proc_qty, t.wh_seq, t.loc_seq,
       t.proc_ymd, t.proc_hms, t.proc_user_id,
       t.mng_ymd, t.exp_ymd, t.lot_no, t.cn,
       ap.req_qty, ap.ex_qty, ap.ad_prod_sts_cd
FROM wms_inven_ad_tran t
    JOIN wms_inven_ad_prod ap ON t.ad_prod_seq = ap.ad_prod_seq
WHERE t.ad_seq = 100
AND t.del_yn = 'N'
ORDER BY t.proc_ymd, t.proc_hms;

-- 증감 유형별 처리 현황
SELECT
    CASE WHEN t.proc_qty > 0 THEN '증가' ELSE '감소' END AS adjust_type,
    COUNT(*) AS tran_cnt,
    SUM(ABS(t.proc_qty)) AS total_abs_qty,
    COUNT(DISTINCT t.prod_seq) AS prod_cnt
FROM wms_inven_ad_tran t
    JOIN wms_inven_ad ad ON t.ad_seq = ad.ad_seq
WHERE ad.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY CASE WHEN t.proc_qty > 0 THEN '증가' ELSE '감소' END;

-- 품목별 재고조정 처리 현황
SELECT p.prod_nm,
       COUNT(DISTINCT t.ad_tran_seq) AS tran_cnt,
       SUM(CASE WHEN t.proc_qty > 0 THEN t.proc_qty ELSE 0 END) AS increase_qty,
       SUM(CASE WHEN t.proc_qty < 0 THEN t.proc_qty ELSE 0 END) AS decrease_qty,
       AVG(ABS(t.proc_qty)) AS avg_abs_qty
FROM wms_inven_ad_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY tran_cnt DESC;

-- 창고별 재고조정 처리 현황
SELECT w.wh_nm,
       COUNT(DISTINCT t.ad_tran_seq) AS tran_cnt,
       SUM(CASE WHEN t.proc_qty > 0 THEN t.proc_qty ELSE 0 END) AS increase_qty,
       SUM(CASE WHEN t.proc_qty < 0 THEN t.proc_qty ELSE 0 END) AS decrease_qty
FROM wms_inven_ad_tran t
    JOIN mdm_wh w ON t.wh_seq = w.wh_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm
ORDER BY tran_cnt DESC;

-- 위치별 재고조정 처리 현황
SELECT w.wh_nm, l.loc_nm,
       COUNT(t.ad_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS net_qty,
       SUM(ABS(t.proc_qty)) AS total_abs_qty
FROM wms_inven_ad_tran t
    JOIN mdm_wh w ON t.wh_seq = w.wh_seq
    JOIN mdm_loc l ON t.loc_seq = l.loc_seq
WHERE t.biz_seq = 1
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY w.wh_nm, l.loc_nm
ORDER BY total_abs_qty DESC;

-- LOT별 재고조정 현황
SELECT t.lot_no,
       p.prod_nm,
       COUNT(t.ad_tran_seq) AS tran_cnt,
       SUM(t.proc_qty) AS total_qty,
       MIN(t.exp_ymd) AS earliest_exp
FROM wms_inven_ad_tran t
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE t.biz_seq = 1
AND t.lot_no IS NOT NULL
AND t.proc_ymd >= '20250201'
AND t.del_yn = 'N'
GROUP BY t.lot_no, p.prod_nm
ORDER BY earliest_exp;

-- 묶음 번호별 처리 현황
SELECT t.proc_bundle_no,
       COUNT(DISTINCT t.ad_tran_seq) AS tran_cnt,
       COUNT(DISTINCT t.ad_seq) AS ad_cnt,
       SUM(t.proc_qty) AS net_qty,
       MIN(t.proc_ymd || t.proc_hms) AS start_time,
       MAX(t.proc_ymd || t.proc_hms) AS end_time
FROM wms_inven_ad_tran t
WHERE t.biz_seq = 1
AND t.proc_bundle_no IS NOT NULL
AND t.proc_ymd = '20250226'
AND t.del_yn = 'N'
GROUP BY t.proc_bundle_no
ORDER BY t.proc_bundle_no;

-- IF 송신 대기 건 조회
SELECT t.ad_tran_seq, ad.ad_no, p.prod_nm,
       t.sku1, t.sku2, t.proc_qty,
       t.proc_ymd, t.proc_hms
FROM wms_inven_ad_tran t
    JOIN wms_inven_ad ad ON t.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON t.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND t.if_send_yn = 'N'
AND t.del_yn = 'N'
ORDER BY t.reg_dt;

-- 일자별 재고조정 처리 추이
SELECT t.proc_ymd,
       COUNT(*) AS tran_cnt,
       SUM(CASE WHEN t.proc_qty > 0 THEN t.proc_qty ELSE 0 END) AS increase_qty,
       SUM(CASE WHEN t.proc_qty < 0 THEN t.proc_qty ELSE 0 END) AS decrease_qty,
       COUNT(DISTINCT t.prod_seq) AS prod_cnt
FROM wms_inven_ad_tran t
WHERE t.biz_seq = 1
AND t.proc_ymd BETWEEN '20250201' AND '20250228'
AND t.del_yn = 'N'
GROUP BY t.proc_ymd
ORDER BY t.proc_ymd;
```