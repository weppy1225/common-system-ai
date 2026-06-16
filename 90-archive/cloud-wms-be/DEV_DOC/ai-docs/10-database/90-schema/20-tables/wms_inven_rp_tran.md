# wms_inven_rp_tran (WMS_품목전환_처리)

## 1. 개요
품목전환 작업의 **실제 처리 이력**을 관리하는 테이블.
기준품목의 재고 감소와 대상품목의 재고 증가를 동시에 기록하며, 재고(`wms_inven`) 변동의 근거가 된다.

### 1.1 품목전환 처리 이력 흐름
```
wms_inven_rp (품목전환 헤더) → wms_inven_rp_prod (품목전환 품목)
                                ├─ 기준품목(st_yn = 'Y')
                                └─ 대상품목(st_yn = 'N')
                                      └─ wms_inven_rp_tran (품목전환 처리 이력)
                                            ├─ 기준품목 처리: 재고 감소
                                            └─ 대상품목 처리: 재고 증가
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | rp_tran_seq | bigint | N | nextval('wms_inven_rp_tran_seq') | 품목전환 처리 SEQ |
| PK/FK | rp_prod_seq | bigint | N | | 품목전환 품목 SEQ → wms_inven_rp_prod |
| PK/FK | rp_seq | integer | N | | 품목전환 SEQ → wms_inven_rp |
| | st_yn | char(1) | N | 'N' | 기준품목 여부 |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | wh_seq | integer | N | | 창고 SEQ → mdm_wh |
| | loc_seq | bigint | N | | 위치 SEQ → mdm_loc |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | N | | 처리 연월일 (YYYYMMDD) |
| | proc_hms | varchar(6) | N | | 처리 시분초 (HHMMSS) |
| | proc_user_id | varchar(20) | N | | 처리자 ID |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **st_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 기준품목 (재고 감소) |
> | N | 대상품목 (재고 증가) |

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
| wms_inven_rp_tran_PK | rp_tran_seq, rp_prod_seq, rp_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| rp_tran_seq | wms_inven_rp_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| rp_prod_seq, rp_seq | wms_inven_rp_prod | rp_prod_seq, rp_seq | wms_inven_rp_prod_TO_wms_inven_rp_tran |

---

## 6. 업무 규칙

### 6.1 품목전환 처리 등록
- 품목전환 품목(`wms_inven_rp_prod`)에 대한 실제 전환 작업 시 생성
- 하나의 품목전환 건에 대해 기준품목과 대상품목 각각 처리 이력 생성
- `proc_qty` : 이번 처리에서 전환하는 수량

### 6.2 기준품목과 대상품목 처리

| 구분 | st_yn | 재고 영향 | 처리 내용 |
|------|-------|----------|----------|
| 기준품목 | 'Y' | 감소 | 출고 처리, 재고 차감 |
| 대상품목 | 'N' | 증가 | 입고 처리, 재고 증가 |

### 6.3 수량 일관성
- 기준품목의 `proc_qty` : 전환된 기준품목 수량
- 대상품목들의 `proc_qty` 합계 = 기준품목 `proc_qty` × 전환 비율 총합
- 전환 비율은 `mdm_rp_prod` 마스터 데이터에 정의

### 6.4 재고 위치 정보

#### 6.4.1 기준품목 (st_yn = 'Y')
- `wh_seq`, `loc_seq` : 출고 창고/위치 (FROM)
- `sku1`, `sku2` : 출고되는 재고의 SKU
- `lot_no` : 출고되는 재고의 LOT 번호

#### 6.4.2 대상품목 (st_yn = 'N')
- `wh_seq`, `loc_seq` : 입고 창고/위치 (TO)
- `sku1`, `sku2` : 새로 생성되는 재고의 SKU
- `lot_no` : 새로 생성되는 재고의 LOT 번호 (신규 발행 또는 기준품목에서 계승)

### 6.5 재고 변동 처리

#### 6.5.1 기준품목 재고 감소
- 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고에서 `proc_qty`만큼 차감
- 재고 부족 시 전환 처리 불가

#### 6.5.2 대상품목 재고 증가
- 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고에 `proc_qty`만큼 증가
- 존재하지 않으면 신규 재고 레코드 생성

### 6.6 처리 정보
- `proc_ymd`, `proc_hms` : 처리 일시 (보통 현재 일시)
- `proc_user_id` : 처리 작업자 ID
- `proc_bundle_no` : 일괄 처리 시 묶음 번호 (여러 품목전환 동시 처리 시 사용)

### 6.7 상태 갱신
- `wms_inven_rp_prod.rp_prod_sts_cd`를 '77'(처리)로 변경
- 모든 품목의 처리 완료 시 `wms_inven_rp.rp_sts_cd`를 '77'(완료)로 변경

### 6.8 SKU/LOT 처리

#### 6.8.1 기준품목
- 기존 재고의 SKU/LOT 정보 그대로 사용
- 전환 후 해당 SKU/LOT의 재고 감소

#### 6.8.2 대상품목
- 새로운 SKU 생성 규칙에 따라 SKU 생성 가능
- LOT 번호는 신규 발행 또는 기준품목 LOT 번호 계승
- 유통기한은 기준품목의 유통기한을 기준으로 계산하거나 별도 지정

### 6.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 품목전환 처리 내역 송신 여부
- 처리 이력 단위로 송신 관리
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.10 취소/삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 해당 처리 수량만큼 재고 복원 필요
- 기준품목 재고 증가 (원복)
- 대상품목 재고 감소 (원복)
- 이미 완료된 품목전환의 처리 이력은 삭제 불가 (취소는 별도 조정 처리)

### 6.11 트랜잭션 처리
- 기준품목 처리와 대상품목 처리는 반드시 동시에 성공하거나 실패해야 함
- 하나의 전환 건에 대한 모든 처리 이력은 동일한 `proc_bundle_no` 사용 권장

### 6.12 유효성 검증
- 기준품목과 대상품목의 전환 관계가 `mdm_rp_prod`에 정의되어 있는지 확인
- 전환 비율에 맞는 수량인지 확인
- 기준품목 재고 충분한지 확인

---

## 7. 주요 조회 예시

```sql
-- 품목전환별 처리 이력 조회
SELECT rt.rp_tran_seq, r.rp_no,
       rt.st_yn,
       CASE WHEN rt.st_yn = 'Y' THEN '기준품목' ELSE '대상품목' END AS prod_type,
       rt.prod_seq, p.prod_nm,
       rt.proc_qty,
       rt.wh_seq, w.wh_nm,
       rt.loc_seq, l.loc_nm,
       rt.sku1, rt.sku2, rt.lot_no,
       rt.proc_ymd, rt.proc_hms, rt.proc_user_id
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON rt.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON rt.loc_seq = l.loc_seq
WHERE r.biz_seq = 1
AND r.rp_no = 'RP2502260001'
AND rt.del_yn = 'N'
ORDER BY rt.st_yn DESC, rt.proc_ymd, rt.proc_hms;

-- 기준품목별 대상품목 처리 이력
SELECT
    base.rp_tran_seq AS base_tran_seq,
    base.prod_seq AS base_prod_seq,
    base_p.prod_nm AS base_prod_nm,
    base.proc_qty AS base_qty,
    base.wh_seq AS base_wh, base.loc_seq AS base_loc,
    base.sku1 AS base_sku1, base.sku2 AS base_sku2,
    target.rp_tran_seq AS target_tran_seq,
    target.prod_seq AS target_prod_seq,
    target_p.prod_nm AS target_prod_nm,
    target.proc_qty AS target_qty,
    target.wh_seq AS target_wh, target.loc_seq AS target_loc,
    target.sku1 AS target_sku1, target.sku2 AS target_sku2
FROM wms_inven_rp_tran base
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
    JOIN wms_inven_rp r ON base.rp_seq = r.rp_seq
    JOIN wms_inven_rp_tran target ON base.rp_seq = target.rp_seq
    JOIN mdm_prod target_p ON target.prod_seq = target_p.prod_seq
WHERE r.rp_no = 'RP2502260001'
AND base.st_yn = 'Y'
AND target.st_yn = 'N'
AND base.del_yn = 'N'
AND target.del_yn = 'N'
ORDER BY target.rp_tran_seq;

-- 작업자별 처리 현황
SELECT rt.proc_user_id,
       COUNT(*) AS tran_count,
       SUM(CASE WHEN rt.st_yn = 'Y' THEN rt.proc_qty ELSE 0 END) AS total_base_qty,
       SUM(CASE WHEN rt.st_yn = 'N' THEN rt.proc_qty ELSE 0 END) AS total_target_qty,
       MIN(rt.proc_ymd) AS first_proc_ymd,
       MAX(rt.proc_ymd) AS last_proc_ymd
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.proc_user_id
ORDER BY total_base_qty DESC;

-- 일자별 품목전환 처리 현황
SELECT rt.proc_ymd,
       COUNT(DISTINCT rt.rp_seq) AS rp_cnt,
       COUNT(*) AS tran_cnt,
       SUM(CASE WHEN rt.st_yn = 'Y' THEN rt.proc_qty ELSE 0 END) AS total_base_qty,
       SUM(CASE WHEN rt.st_yn = 'N' THEN rt.proc_qty ELSE 0 END) AS total_target_qty
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.proc_ymd
ORDER BY rt.proc_ymd;

-- 특정 위치에서 처리된 품목전환 이력
SELECT rt.rp_tran_seq, r.rp_no,
       rt.st_yn, rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd,
       rt.sku1, rt.sku2, rt.lot_no
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
WHERE rt.wh_seq = 10
AND rt.loc_seq = 1001
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd DESC;

-- IF 송신 대기 처리 이력
SELECT rt.rp_tran_seq, r.rp_no,
       rt.st_yn, rt.prod_seq, p.prod_nm,
       rt.proc_qty, rt.proc_ymd
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rt.if_send_yn = 'N'
AND rt.del_yn = 'N'
ORDER BY rt.reg_dt;

-- 처리 묶음 번호별 조회
SELECT rt.proc_bundle_no,
       COUNT(*) AS tran_cnt,
       COUNT(DISTINCT rt.rp_seq) AS rp_cnt,
       SUM(CASE WHEN rt.st_yn = 'Y' THEN rt.proc_qty ELSE 0 END) AS total_base_qty,
       SUM(CASE WHEN rt.st_yn = 'N' THEN rt.proc_qty ELSE 0 END) AS total_target_qty,
       MIN(rt.proc_ymd) AS min_proc_ymd,
       MAX(rt.proc_ymd) AS max_proc_ymd
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND rt.proc_bundle_no IS NOT NULL
AND rt.proc_ymd = '20250226'
AND rt.del_yn = 'N'
GROUP BY rt.proc_bundle_no
ORDER BY rt.proc_bundle_no;

-- 창고별 품목전환 처리 현황
SELECT rt.wh_seq, w.wh_nm,
       rt.st_yn,
       COUNT(*) AS tran_cnt,
       SUM(rt.proc_qty) AS total_qty,
       COUNT(DISTINCT rt.prod_seq) AS prod_cnt
FROM wms_inven_rp_tran rt
    JOIN mdm_wh w ON rt.wh_seq = w.wh_seq
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.wh_seq, w.wh_nm, rt.st_yn
ORDER BY rt.wh_seq, rt.st_yn;

-- 품목별 전환 처리 이력 (기준품목 관점)
SELECT rt.rp_tran_seq, r.rp_no,
       '기준품목' AS role,
       rt.proc_qty,
       rt.wh_seq, rt.loc_seq,
       rt.sku1, rt.sku2, rt.lot_no,
       rt.proc_ymd, rt.proc_user_id
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE rt.prod_seq = 1001
AND rt.st_yn = 'Y'
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd DESC;

-- 품목별 전환 처리 이력 (대상품목 관점)
SELECT rt.rp_tran_seq, r.rp_no,
       '대상품목' AS role,
       base.prod_seq AS base_prod_seq,
       base_p.prod_nm AS base_prod_nm,
       rt.proc_qty,
       rt.wh_seq, rt.loc_seq,
       rt.sku1, rt.sku2, rt.lot_no,
       rt.proc_ymd, rt.proc_user_id
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
    JOIN wms_inven_rp_tran base ON rt.rp_seq = base.rp_seq 
        AND base.st_yn = 'Y'
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
WHERE rt.prod_seq = 2002
AND rt.st_yn = 'N'
AND rt.del_yn = 'N'
ORDER BY rt.proc_ymd DESC;

-- LOT 번호별 처리 현황
SELECT rt.lot_no,
       COUNT(*) AS tran_cnt,
       SUM(CASE WHEN rt.st_yn = 'Y' THEN rt.proc_qty ELSE 0 END) AS base_out_qty,
       SUM(CASE WHEN rt.st_yn = 'N' THEN rt.proc_qty ELSE 0 END) AS target_in_qty,
       MIN(rt.proc_ymd) AS first_proc_ymd,
       MAX(rt.proc_ymd) AS last_proc_ymd
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND rt.lot_no IS NOT NULL
AND rt.proc_ymd BETWEEN '20250201' AND '20250228'
AND rt.del_yn = 'N'
GROUP BY rt.lot_no
ORDER BY rt.lot_no;
```