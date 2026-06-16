# wms_inven_mv_prod (WMS_재고이동품목)

## 1. 개요
`wms_inven_mv`(재고이동)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
재고이동 대상 품목별로 이동 수량, 상태, 예상 정보 등을 저장하며, 실제 재고이동 처리(`wms_inven_mv_tran`)와 연결된다.

### 1.1 재고이동품목 처리 흐름
```
wms_inven_mv (재고이동 헤더)
└─ wms_inven_mv_prod (재고이동 품목) ← **현재 테이블**
        └─ wms_inven_mv_tran (재고이동 처리 이력)
              ↓
        재고모듈
        ├─ wms_inven 재고 위치 변경 (FROM → TO)
        ├─ wms_inven_sku 이력 등록
        └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | mv_prod_seq | bigint | N | nextval('wms_inven_mv_prod_seq') | 재고이동품목 SEQ |
| FK | mv_seq | integer | N | | 재고이동 SEQ → wms_inven_mv |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | mv_prod_sts_cd | varchar(50) | N | | 재고이동품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 (이동 수량) |
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

> **mv_prod_sts_cd** (`MV_PROD_STS_CD`)
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
| wms_inven_mv_prod_PK | mv_prod_seq, mv_seq | Y | Y |
| IX_wms_inven_mv_prod_prod | prod_seq | N | |
| IX_wms_inven_mv_prod_sts | mv_prod_sts_cd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| mv_prod_seq | wms_inven_mv_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| mv_seq | wms_inven_mv | mv_seq | wms_inven_mv_TO_wms_inven_mv_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_mv_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_mv_tran | mv_prod_seq, mv_seq | wms_inven_mv_prod_TO_wms_inven_mv_tran |

---

## 7. 업무 규칙

### 7.1 재고이동품목 생성
- 재고이동 헤더 등록 시 품목별로 생성
- `mv_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 이동 요청 수량 (항상 양수)

### 7.2 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 이동 요청 등록 |
| 지정 | 33 | 이동할 재고 위치(SKU) 지정 완료 |
| 처리중 | 55 | 일부 이동 처리됨 |
| 확정 | 77 | 이동 완료 (전량 처리) |

### 7.3 재고 지정 단계
- `mv_prod_sts_cd = '33'` : 실제 이동할 재고 위치 지정
- `wms_inven_mv_tran` 생성 전에 어떤 SKU를 이동할지 결정
- 복수의 SKU에서 분할 이동 가능

### 7.4 수량 관리
- `req_qty` : 이동 요청 수량
- `ex_qty` : 실제 이동 처리된 누적 수량
- 모든 수량이 처리되면(`ex_qty = req_qty`) 상태는 `'77'(확정)` 으로 변경

### 7.5 예상 정보
- `est_mng_ymd`, `est_exp_ymd`, `est_lot_no`, `est_cn` : 이동할 재고의 예상 정보
- 실제 이동 시 이 정보와 일치하지 않을 수 있음
- `wms_inven_mv_tran`에서 실제 정보 기록

### 7.6 이동 처리 단계

#### 7.6.1 이동 예정
- 이동 대상 품목 및 수량 등록
- `mv_prod_sts_cd = '11'`

#### 7.6.2 재고 지정
- 이동할 구체적인 SKU 지정
- `mv_prod_sts_cd = '33'`

#### 7.6.3 이동 처리
- `wms_inven_mv_tran` 생성
- `ex_qty` 증가
- `mv_prod_sts_cd` 갱신

#### 7.6.4 이동 확정
- `ex_qty = req_qty` 시 `mv_prod_sts_cd = '77'`
- 상위 헤더 상태 갱신 트리거

### 7.7 분할 이동
- 하나의 이동품목에 대해 여러 번에 나누어 처리 가능
- 각 처리 건마다 다른 SKU에서 이동 가능
- `ex_qty` 누적 관리로 잔여 수량 추적

### 7.8 IF 송신
- `if_send_yn` : 외부 시스템(ERP/WMS)으로 이동 정보 송신 여부 관리
- `if_idx` : 외부 시스템에서의 순번 정보

### 7.9 취소/삭제
- 확정(`'77'`)된 품목은 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 재고이동별 품목 현황
SELECT mv.mv_no, mv.mv_type_cd,
       mp.mv_prod_seq, p.prod_nm,
       mp.req_qty, mp.ex_qty,
       mp.mv_prod_sts_cd
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mv.center_seq = 1
AND mv.req_ymd = '20250226'
AND mp.del_yn = 'N'
ORDER BY mv.mv_no, mp.mv_prod_seq;

-- 특정 재고이동의 품목 상세
SELECT mp.mv_prod_seq, p.prod_no, p.prod_nm,
       mp.req_qty, mp.ex_qty,
       mp.mv_prod_sts_cd,
       mp.est_mng_ymd, mp.est_exp_ymd,
       mp.est_lot_no, mp.est_cn
FROM wms_inven_mv_prod mp
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mp.mv_seq = 100
AND mp.del_yn = 'N'
ORDER BY mp.mv_prod_seq;

-- 미완료 이동품목 목록 (예정/지정/처리중)
SELECT mp.mv_prod_seq, mv.mv_no,
       p.prod_nm, mp.req_qty, mp.ex_qty,
       (mp.req_qty - mp.ex_qty) AS remain_qty,
       mp.mv_prod_sts_cd
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mp.mv_prod_sts_cd IN ('11', '33', '55')
AND mp.del_yn = 'N'
ORDER BY mv.req_ymd, mv.mv_no;

-- 상태별 이동품목 현황
SELECT
    mp.mv_prod_sts_cd,
    COUNT(*) AS prod_cnt,
    SUM(mp.req_qty) AS total_qty,
    SUM(mp.ex_qty) AS processed_qty
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
WHERE mv.biz_seq = 1
AND mv.req_ymd = '20250226'
AND mp.del_yn = 'N'
GROUP BY mp.mv_prod_sts_cd
ORDER BY mp.mv_prod_sts_cd;

-- 품목별 재고이동 현황
SELECT p.prod_nm,
       COUNT(DISTINCT mp.mv_prod_seq) AS mv_prod_cnt,
       COUNT(DISTINCT mp.mv_seq) AS mv_cnt,
       SUM(mp.req_qty) AS total_req_qty,
       SUM(mp.ex_qty) AS total_ex_qty,
       ROUND(SUM(mp.ex_qty) * 100.0 / NULLIF(SUM(mp.req_qty), 0), 2) AS completion_rate
FROM wms_inven_mv_prod mp
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mp.biz_seq = 1
AND mp.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND mp.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_req_qty DESC;

-- 이동 유형별 품목 통계
SELECT mv.mv_type_cd,
       COUNT(DISTINCT mp.mv_prod_seq) AS prod_cnt,
       SUM(mp.req_qty) AS total_qty,
       AVG(mp.req_qty) AS avg_qty
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
WHERE mv.biz_seq = 1
AND mp.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND mp.del_yn = 'N'
GROUP BY mv.mv_type_cd
ORDER BY mv.mv_type_cd;

-- IF 송신 대기 건 조회
SELECT mp.mv_prod_seq, mv.mv_no, p.prod_nm,
       mp.req_qty, mp.ex_qty,
       mp.mv_prod_sts_cd, mp.if_idx
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mp.if_send_yn = 'N'
AND mp.del_yn = 'N'
ORDER BY mp.reg_dt;

-- 지정 단계(33)에 있는 이동품목
SELECT mp.mv_prod_seq, mv.mv_no,
       p.prod_nm, mp.req_qty,
       mv.fr_wh_seq, mv.to_wh_seq
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mp.mv_prod_sts_cd = '33'
AND mp.del_yn = 'N'
ORDER BY mv.req_ymd;

-- 대량 이동 품목 (수량 기준)
SELECT mp.mv_prod_seq, mv.mv_no,
       p.prod_nm, mp.req_qty,
       mp.mv_prod_sts_cd
FROM wms_inven_mv_prod mp
    JOIN wms_inven_mv mv ON mp.mv_seq = mv.mv_seq
    JOIN mdm_prod p ON mp.prod_seq = p.prod_seq
WHERE mv.biz_seq = 1
AND mp.req_qty > 1000
AND mp.del_yn = 'N'
ORDER BY mp.req_qty DESC;
```