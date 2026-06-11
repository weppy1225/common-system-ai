# wms_return_tran (WMS_반품_처리)

## 1. 개요
반품 품목의 **실제 입고 처리 이력**을 관리하는 테이블.
반품 검수 후 창고에 실제로 입고되는 내역을 기록하며, 재고(`wms_inven`) 증가의 근거가 된다.

### 1.1 반품 처리 이력 흐름
```
wms_return (반품 헤더) → wms_return_prod (반품 품목)
                          └─ wms_return_tran (반품 처리 이력) → wms_inven 증가
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | return_tran_seq | bigint | N | nextval('wms_return_tran_seq') | 반품 처리 SEQ |
| PK/FK | return_prod_seq | bigint | N | | 반품 품목 SEQ → wms_return_prod |
| PK/FK | return_seq | integer | N | | 반품 SEQ → wms_return |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | mng_ymd | varchar(8) | Y | | 입고/제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량(반품) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량(반품) |
| | to_wh_seq | integer | N | | TO 창고 SEQ → mdm_wh |
| | to_loc_seq | bigint | N | | TO 위치 SEQ → mdm_loc |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시분초 (HHMMSS) |
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
| wms_return_tran_PK | return_tran_seq, return_prod_seq, return_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| return_tran_seq | wms_return_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| return_prod_seq, return_seq | wms_return_prod | return_prod_seq, return_seq | wms_return_prod_TO_wms_return_tran |

---

## 6. 업무 규칙

### 6.1 반품 처리 등록
- 반품 품목(`wms_return_prod`)에 대한 실제 입고 처리 시 생성
- 하나의 반품 품목에 대해 여러 번 처리 가능 (부분 입고)
- `proc_qty` : 이번 처리에서 입고하는 수량

### 6.2 수량 관리
- `proc_qty` : 실제 입고 처리 수량
- `ex_qty` : 해당 품목의 누적 처리 수량
- `wms_return_prod.ex_qty`와 동기화 필요
- `wms_return_prod.ex_qty` = 동일 `return_prod_seq`의 `proc_qty` 합계
- `proc_qty` + 기존 `ex_qty` ≤ `wms_return_prod.req_qty`

### 6.3 SKU 정보
- `sku1`, `sku2` : 실제 입고된 재고의 SKU 값
- `wms_inven` 테이블의 SKU와 동일한 값 사용
- SKU 생성 규칙에 따라 자동 생성 또는 수동 입력

### 6.4 유통기한/LOT 정보
- `mng_ymd` : 제조일자 또는 입고일자
- `exp_ymd` : 유통기한 (품목의 유통기한 관리 여부에 따라 필수)
- `lot_no` : LOT 번호 (품목의 LOT 관리 여부에 따라 필수)
- 실제 검수 시 확인된 값으로 입력

### 6.5 입고 위치
- `to_wh_seq` : 입고 창고
- `to_loc_seq` : 입고 위치
- 창고/WMS 정책에 따라 자동 지정 또는 수동 선택
- 위치는 해당 창고에 유효한 위치여야 함

### 6.6 처리 정보
- `proc_ymd`, `proc_hms` : 처리 일시 (보통 현재 일시)
- `proc_user_id` : 처리 작업자 ID
- `proc_bundle_no` : 일괄 처리 시 묶음 번호 (여러 건 동시 처리 시 사용)

### 6.7 재고 증가 처리
- `wms_return_tran` 생성 시 실제 재고(`wms_inven`) 증가 처리 필요
- 증가 조건: 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합
- 존재하면 `inven_qty` 증가, 없으면 신규 생성

### 6.8 상태 갱신
- `wms_return_prod.ex_qty` 갱신
- `wms_return_prod.ex_qty` = `wms_return_prod.req_qty`인 경우 `return_prod_sts_cd`를 '77'(확정)로 변경
- 모든 품목이 확정되면 `wms_return.return_sts_cd`를 '77'(확정)로 변경

### 6.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 반품 처리 내역 송신 여부
- 처리 이력 단위로 송신 관리
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.10 취소/삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 해당 처리 수량만큼 재고 차감 필요
- 이미 확정된 반품의 처리 이력은 삭제 불가 (취소는 별도 조정 처리)

### 6.11 중복 처리 방지
- 동일 `return_prod_seq`에 대해 중복 처리 시 수량 합계가 `req_qty` 초과하지 않도록 제어
- `proc_bundle_no`로 일괄 처리 건 구분 가능

---

## 7. 주요 조회 예시

```sql
-- 반품별 처리 이력 조회
SELECT rt.return_tran_seq, rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd, rt.proc_hms, rt.proc_user_id,
       rt.sku1, rt.sku2,
       rt.mng_ymd, rt.exp_ymd, rt.lot_no,
       rt.to_wh_seq, w.wh_nm AS to_wh_nm,
       rt.to_loc_seq, l.loc_nm AS to_loc_nm
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON rt.to_wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON rt.to_loc_seq = l.loc_seq
WHERE r.return_no = 'RT2502250001'
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd, rt.proc_hms;

-- 품목별 처리 이력 요약
SELECT rp.return_prod_seq, p.prod_nm,
       rp.req_qty,
       COUNT(rt.return_tran_seq) AS tran_count,
       SUM(rt.proc_qty) AS total_proc_qty,
       MIN(rt.proc_ymd) AS first_proc_ymd,
       MAX(rt.proc_ymd) AS last_proc_ymd
FROM wms_return_prod rp
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    LEFT JOIN wms_return_tran rt ON rp.return_prod_seq = rt.return_prod_seq
        AND rt.del_yn = 'N'
WHERE rp.return_seq = 1001
AND rp.del_yn = 'N'
GROUP BY rp.return_prod_seq, p.prod_nm, rp.req_qty
ORDER BY rp.return_prod_seq;

-- 특정 위치로 입고된 반품 처리 이력
SELECT rt.return_tran_seq, r.return_no,
       rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd,
       rt.sku1, rt.sku2, rt.lot_no
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
WHERE rt.to_wh_seq = 10
AND rt.to_loc_seq = 1001
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd DESC;

-- 작업자별 처리 현황
SELECT rt.proc_user_id,
       COUNT(*) AS tran_count,
       SUM(rt.proc_qty) AS total_proc_qty,
       MIN(rt.proc_ymd) AS first_proc_ymd,
       MAX(rt.proc_ymd) AS last_proc_ymd
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
WHERE r.biz_seq = 1
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.proc_user_id
ORDER BY total_proc_qty DESC;

-- 일자별 반품 처리 현황
SELECT rt.proc_ymd,
       COUNT(DISTINCT rt.return_seq) AS return_cnt,
       COUNT(*) AS tran_cnt,
       SUM(rt.proc_qty) AS total_qty
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
WHERE r.biz_seq = 1
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.proc_ymd
ORDER BY rt.proc_ymd;

-- IF 송신 대기 처리 이력
SELECT rt.return_tran_seq, r.return_no,
       rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rt.if_send_yn = 'N'
AND rt.del_yn = 'N'
ORDER BY rt.reg_dt;

-- 처리 묶음 번호별 조회
SELECT rt.proc_bundle_no,
       COUNT(*) AS tran_cnt,
       SUM(rt.proc_qty) AS total_qty,
       MIN(rt.proc_ymd) AS min_proc_ymd,
       MAX(rt.proc_ymd) AS max_proc_ymd
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
WHERE r.biz_seq = 1
AND rt.proc_bundle_no IS NOT NULL
AND rt.proc_ymd = '20250226'
AND rt.del_yn = 'N'
GROUP BY rt.proc_bundle_no
ORDER BY rt.proc_bundle_no;

-- 유통기한별 처리 현황
SELECT rt.exp_ymd,
       COUNT(*) AS tran_cnt,
       SUM(rt.proc_qty) AS total_qty
FROM wms_return_tran rt
    JOIN wms_return r ON rt.return_seq = r.return_seq
WHERE r.biz_seq = 1
AND rt.exp_ymd IS NOT NULL
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.exp_ymd
ORDER BY rt.exp_ymd;
```