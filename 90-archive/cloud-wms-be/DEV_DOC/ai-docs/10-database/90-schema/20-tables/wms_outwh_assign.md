# wms_outwh_assign (WMS_출고지시)

## 1. 개요
출고 처리 시 **어떤 재고(SKU)를 어떤 위치에서 출고할지 지정하는 지시(Assignment) 정보**를 관리하는 테이블.
피킹 작업을 위한 재고 위치를 할당하며, 출고 품목별로 실제 출고될 재고를 지정한다.

### 1.1 출고지시 처리 흐름
```
wms_outbiz (출하)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outwh (출고 헤더)
              └─ wms_outwh_prod (출고 품목)
                    └─ wms_outwh_assign (출고 지시) ← **현재 테이블**
                          └─ wms_outwh_tran (출고 처리 이력) → 재고 차감
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outwh_assign_seq | bigint | N | nextval('wms_outwh_assign_seq') | 출고지시 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | req_seq | integer | N | | 요청 SEQ (출고 SEQ) |
| | req_prod_seq | bigint | N | | 요청 품목 SEQ (출고품목 SEQ) |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | wh_seq | integer | Y | | 창고 SEQ → mdm_wh |
| | loc_seq | bigint | Y | | 위치 SEQ → mdm_loc |
| | sku1 | varchar(100) | Y | | SKU1 (지정된 재고단위1) |
| | sku2 | varchar(100) | Y | | SKU2 (지정된 재고단위2) |
| | req_qty | decimal(10,2) | Y | 0 | 요청 수량 |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | req_no | varchar(30) | N | | 업무 번호 (출하번호 등) |
| | strng_asgn_yn | char(1) | N | 'N' | 출고 강지정 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **strng_asgn_yn** (`STRNG_ASGN_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 약지정 (시스템 자동 할당) |
> | Y | 강지정 (사용자 직접 지정) |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_outwh_assign_PK | outwh_assign_seq | Y | Y |
| IX_wms_outwh_assign | biz_seq, center_seq, prod_seq | N | |
| IX_wms_outwh_assign2 | req_seq, req_prod_seq | N | |
| IX_wms_outwh_assign_loc | wh_seq, loc_seq | N | |
| IX_wms_outwh_assign_sku | sku1, sku2 | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outwh_assign_seq | wms_outwh_assign_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outwh_assign |
| wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_outwh_assign |
| loc_seq | mdm_loc | loc_seq | mdm_loc_TO_wms_outwh_assign |

---

## 6. 업무 규칙

### 6.1 출고지시 생성 조건
- 출고 등록 시 자동 생성 (약지정)
- 또는 사용자가 직접 재고 위치 지정 (강지정)
- 출고품목(`wms_outwh_prod`)별로 하나 이상의 출고지시 생성 가능

### 6.2 지정 방식

#### 6.2.1 약지정 (N)
- 시스템이 재고 알고리즘에 따라 자동으로 출고할 재고 위치 지정
- FIFO(선입선출), FEFO(선유통기한선출) 등 정책 적용
- `wh_seq`, `loc_seq`, `sku1`, `sku2` 자동 할당

#### 6.2.2 강지정 (Y)
- 사용자가 직접 출고할 재고 위치 지정
- 특정 LOT, 유통기한, 위치 등을 수동 선택
- 재고 확인 후 할당

### 6.3 지정 정보
- `wh_seq`, `loc_seq` : 출고할 재고의 창고/위치
- `sku1`, `sku2` : 출고할 재고의 SKU (재고단위)
- `mng_ymd`, `exp_ymd`, `lot_no` : 출고할 재고의 제조일자/유통기한/LOT

### 6.4 수량 관리
- `req_qty` : 해당 위치에서 출고할 수량
- 하나의 출고품목에 여러 출고지시가 있을 수 있음 (여러 위치에서 분할 출고)
- 출고품목의 `req_qty` = 연결된 모든 출고지시의 `req_qty` 합계

### 6.5 재고 확인
- 출고지시 생성 시 해당 재고(`wms_inven`)의 가용 재고 확인
- `inven_qty` >= `req_qty` 인 경우에만 할당 가능
- 할당된 수량만큼 재고 예약 처리

### 6.6 출고 처리 연동
- 출고 처리(`wms_outwh_tran`) 시 해당 출고지시 정보 활용
- 처리된 수량만큼 출고지시 이행 완료
- 출고 완료 후 출고지시 정보는 이력으로 보존

### 6.7 취소/삭제
- 출고 확정 전에는 출고지시 수정/삭제 가능
- 출고 확정 후에는 변경 불가
- 물리삭제 금지 — 별도 `del_yn` 컬럼 없음 (이력 보존)

---

## 7. 주요 조회 예시

```sql
-- 출고별 지시 현황
SELECT ow.outwh_no, ow.outwh_sts_cd,
       oa.outwh_assign_seq, oa.prod_seq,
       p.prod_nm, oa.req_qty,
       oa.wh_seq, oa.loc_seq,
       oa.sku1, oa.sku2,
       oa.mng_ymd, oa.exp_ymd, oa.lot_no,
       oa.strng_asgn_yn
FROM wms_outwh_assign oa
    JOIN wms_outwh_prod op ON oa.req_prod_seq = op.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON oa.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND ow.center_seq = 1
AND ow.outwh_no = 'OW2502260001'
AND oa.del_yn = 'N'
ORDER BY oa.outwh_assign_seq;

-- 특정 품목의 출고지시 현황
SELECT oa.outwh_assign_seq, ow.outwh_no,
       oa.req_qty, oa.wh_seq, oa.loc_seq,
       oa.sku1, oa.sku2,
       oa.mng_ymd, oa.exp_ymd, oa.lot_no,
       oa.strng_asgn_yn
FROM wms_outwh_assign oa
    JOIN wms_outwh_prod op ON oa.req_prod_seq = op.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
WHERE oa.biz_seq = 1
AND oa.prod_seq = 100
AND ow.outwh_sts_cd != '77' -- 미확정 출고만
ORDER BY ow.req_ymd, ow.outwh_no;

-- 위치별 출고지시 현황
SELECT w.wh_nm, l.loc_nm,
       COUNT(oa.outwh_assign_seq) AS assign_cnt,
       SUM(oa.req_qty) AS total_qty
FROM wms_outwh_assign oa
    JOIN mdm_wh w ON oa.wh_seq = w.wh_seq
    JOIN mdm_loc l ON oa.loc_seq = l.loc_seq
WHERE oa.biz_seq = 1
AND oa.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY w.wh_nm, l.loc_nm
ORDER BY total_qty DESC;

-- 강지정 vs 약지정 현황
SELECT
    oa.strng_asgn_yn,
    COUNT(*) AS assign_cnt,
    SUM(oa.req_qty) AS total_qty,
    COUNT(DISTINCT oa.prod_seq) AS prod_cnt
FROM wms_outwh_assign oa
WHERE oa.biz_seq = 1
AND oa.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY oa.strng_asgn_yn;

-- 출고품목별 분할 지시 현황
SELECT
    op.outwh_prod_seq, ow.outwh_no,
    op.req_qty AS outwh_prod_qty,
    COUNT(oa.outwh_assign_seq) AS assign_cnt,
    SUM(oa.req_qty) AS total_assign_qty
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    LEFT JOIN wms_outwh_assign oa ON op.outwh_prod_seq = oa.req_prod_seq
WHERE ow.biz_seq = 1
AND ow.req_ymd = '20250226'
AND op.del_yn = 'N'
GROUP BY op.outwh_prod_seq, ow.outwh_no, op.req_qty
HAVING op.req_qty != COALESCE(SUM(oa.req_qty), 0);

-- LOT별 출고지시 현황
SELECT
    oa.lot_no,
    p.prod_nm,
    COUNT(oa.outwh_assign_seq) AS assign_cnt,
    SUM(oa.req_qty) AS total_qty,
    MIN(oa.exp_ymd) AS earliest_exp
FROM wms_outwh_assign oa
    JOIN mdm_prod p ON oa.prod_seq = p.prod_seq
WHERE oa.biz_seq = 1
AND oa.lot_no IS NOT NULL
AND oa.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY oa.lot_no, p.prod_nm
ORDER BY earliest_exp;

-- 유통기한 임박 순 출고지시
SELECT
    oa.outwh_assign_seq, oa.exp_ymd,
    p.prod_nm, oa.req_qty,
    oa.wh_seq, oa.loc_seq, oa.lot_no
FROM wms_outwh_assign oa
    JOIN mdm_prod p ON oa.prod_seq = p.prod_seq
WHERE oa.biz_seq = 1
AND oa.exp_ymd BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
AND oa.req_qty > 0
ORDER BY oa.exp_ymd;

-- 미처리 출고지시 (출고 미완료)
SELECT oa.outwh_assign_seq, ow.outwh_no,
       p.prod_nm, oa.req_qty,
       oa.wh_seq, oa.loc_seq, oa.sku1
FROM wms_outwh_assign oa
    JOIN wms_outwh_prod op ON oa.req_prod_seq = op.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON oa.prod_seq = p.prod_seq
    LEFT JOIN wms_outwh_tran ot ON oa.outwh_assign_seq = ot.outwh_assign_seq
WHERE ow.biz_seq = 1
AND ow.outwh_sts_cd != '77'
AND ot.outwh_tran_seq IS NULL -- 처리 이력 없음
ORDER BY ow.req_ymd, ow.outwh_no;
```