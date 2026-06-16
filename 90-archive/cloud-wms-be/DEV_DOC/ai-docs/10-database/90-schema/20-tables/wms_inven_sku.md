# wms_inven_sku (WMS_재고_SKU이력)

## 1. 개요
**SKU(Stock Keeping Unit)의 생성 및 관리 이력**을 저장하는 테이블.
입고 시 생성된 SKU의 상세 정보(일련번호, 제조일자, 유통기한, LOT번호 등)를 관리하며, 재고 추적의 기본 단위가 된다.

### 1.1 SKU 이력 처리 흐름
```
입고 처리 → SKU 생성 → wms_inven_sku 저장 → 재고 이동/출고 시 SKU 기준으로 관리
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | prod_seq | integer | N | | 품목 SEQ |
| PK | sku1 | varchar(100) | N | | SKU1 |
| PK | sku2 | varchar(100) | N | | SKU2 |
| | center_seq | integer | N | | 센터 SEQ |
| | sku1_seq | integer | Y | | SKU1 일련번호 |
| | sku2_seq | integer | Y | | SKU2 일련번호 |
| | load_qty | decimal(10,2) | N | 0 | 적재 수량 (SKU 생성 개수) |
| | create_ymd | varchar(8) | N | | 생성 연월일 |
| | create_hms | varchar(6) | N | | 생성 시분초 |
| | create_user_id | varchar(20) | N | | 생성자 ID |
| | mng_ymd | varchar(8) | Y | | 입고/제조일자 |
| | exp_ymd | varchar(8) | Y | | 유통기한 |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | bl_no | varchar(30) | Y | | BL 번호 (선하증권) |
| | inout_type_cd | varchar(50) | N | | 수불 유형 코드 |
| | inout_dtl_cd | varchar(50) | N | | 수불 상세 코드 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inout_type_cd** (`INOUT_TYPE_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | IW | 입고 |
> | RT | 반품 |
> | OW | 출고 |
> | OB | 출하 |
> | IM | 재고이동 |
> | AD | 재고조정 |
> | EX | 예외출고 |
> | RP | 품목전환 |
> | ST | 세트작업 |
> | DV | SKU분할 |
> | MR | SKU병합 |
> | SC | SKU변경 |

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
| wms_inven_sku_PK | biz_seq, prod_seq, sku1, sku2 | Y | Y |

---

## 4. 업무 규칙

### 4.1 SKU 생성
- 입고, 반품, 세트작업 등 재고가 증가하는 모든 작업에서 SKU 생성
- `sku1`, `sku2`는 품목의 SKU 관리 정책에 따라 생성
- `N`: 사용안함 - 빈 값 또는 'NONE'
- `B`: 유통표준코드 기반
- `C`: 자사물류코드 기반

### 4.2 SKU 구성

#### 4.2.1 SKU1 (자)
- 개별 단위 식별자
- 예: 품목번호 + 일련번호

#### 4.2.2 SKU2 (모)
- 상위 단위(파렛트, 박스 등) 식별자
- 파렛트 관리 시 사용

### 4.3 일련번호
- `sku1_seq`: SKU1의 순차 번호
- `sku2_seq`: SKU2의 순차 번호
- 동일한 조건에서 자동 증가

### 4.4 생성 정보
- `create_ymd`, `create_hms`: SKU 생성 일시
- `create_user_id`: SKU 생성 작업자
- 최초 입고 시점의 정보 저장

### 4.5 품목 속성 정보

| 필드 | 설명 | 관리 여부 |
|------|------|----------|
| mng_ymd | 제조일자/입고일자 | `mdm_prod.mng_ymd_mng_yn` |
| exp_ymd | 유통기한 | `mdm_prod.eff_mng_yn` |
| lot_no | LOT 번호 | `mdm_prod.lot_no_mng_yn` |
| bl_no | BL 번호 | 수입품의 경우 |

### 4.6 수불 유형
- `inout_type_cd`: 최초 생성된 작업 유형
- `inout_dtl_cd`: 상세 작업 유형
- SKU의 출처(입고, 반품, 조정 등) 추적

### 4.7 적재 수량
- `load_qty`: 해당 SKU로 생성된 수량
- 일반적으로 1이지만, 단위에 따라 다를 수 있음
- 예: 파렛트 SKU의 경우 적재 박스 수

### 4.8 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 재고가 소진된 SKU는 삭제 처리

### 4.9 재고 테이블과의 관계
- `wms_inven`은 `sku1`, `sku2`로 재고 집계
- `wms_inven_sku`는 SKU의 상세 정보(메타데이터) 제공

---

## 5. 주요 조회 예시

```sql
-- 특정 품목의 SKU 목록 조회
SELECT sku1, sku2, center_seq,
       sku1_seq, sku2_seq,
       load_qty, create_ymd,
       mng_ymd, exp_ymd, lot_no, bl_no,
       inout_type_cd, inout_dtl_cd
FROM wms_inven_sku
WHERE biz_seq = 1
AND prod_seq = 1001
AND del_yn = 'N'
ORDER BY create_ymd DESC, create_hms DESC;

-- 유통기한이 임박한 SKU 조회
SELECT sku1, sku2, prod_seq, p.prod_nm,
       exp_ymd, lot_no,
       CURRENT_DATE - TO_DATE(exp_ymd, 'YYYYMMDD') AS exp_d_day
FROM wms_inven_sku
    JOIN mdm_prod p ON wms_inven_sku.prod_seq = p.prod_seq
WHERE biz_seq = 1
AND exp_ymd IS NOT NULL
AND TO_DATE(exp_ymd, 'YYYYMMDD') <= CURRENT_DATE + INTERVAL '30 days'
AND del_yn = 'N'
ORDER BY exp_ymd;

-- 특정 위치의 재고 SKU 상세 정보
SELECT i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       s.prod_seq, p.prod_nm,
       s.sku1, s.sku2,
       i.inven_qty,
       s.mng_ymd, s.exp_ymd, s.lot_no, s.bl_no
FROM wms_inven i
    JOIN wms_inven_sku s ON i.biz_seq = s.biz_seq 
        AND i.prod_seq = s.prod_seq 
        AND i.sku1 = s.sku1 
        AND i.sku2 = s.sku2
    JOIN mdm_prod p ON i.prod_seq = p.prod_seq
    JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE i.biz_seq = 1
AND i.wh_seq = 10
AND i.loc_seq = 1001
AND i.inven_qty > 0
AND s.del_yn = 'N'
ORDER BY s.exp_ymd;

-- LOT 번호별 재고 현황
SELECT lot_no, prod_seq,
       COUNT(DISTINCT sku1 || sku2) AS sku_cnt,
       SUM(load_qty) AS total_qty,
       MIN(exp_ymd) AS min_exp_ymd,
       MAX(exp_ymd) AS max_exp_ymd
FROM wms_inven_sku
WHERE biz_seq = 1
AND lot_no IS NOT NULL
AND del_yn = 'N'
GROUP BY lot_no, prod_seq
ORDER BY lot_no;

-- 일자별 SKU 생성 현황
SELECT create_ymd,
       COUNT(*) AS sku_created_cnt,
       COUNT(DISTINCT prod_seq) AS prod_cnt,
       SUM(load_qty) AS total_load_qty
FROM wms_inven_sku
WHERE biz_seq = 1
AND create_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY create_ymd
ORDER BY create_ymd;

-- 수입품 BL 번호별 SKU 현황
SELECT bl_no,
       COUNT(*) AS sku_cnt,
       COUNT(DISTINCT prod_seq) AS prod_cnt,
       MIN(create_ymd) AS first_create,
       MAX(create_ymd) AS last_create
FROM wms_inven_sku
WHERE biz_seq = 1
AND bl_no IS NOT NULL
AND del_yn = 'N'
GROUP BY bl_no
ORDER BY bl_no;

-- 특정 SKU의 전체 이력 (재고 이동 추적)
SELECT s.sku1, s.sku2, s.prod_seq, p.prod_nm,
       s.create_ymd, s.create_user_id,
       s.mng_ymd, s.exp_ymd, s.lot_no, s.bl_no,
       i.wh_seq, w.wh_nm,
       i.loc_seq, l.loc_nm,
       i.inven_qty,
       i.mod_dt AS last_movement
FROM wms_inven_sku s
    JOIN mdm_prod p ON s.prod_seq = p.prod_seq
    LEFT JOIN wms_inven i ON s.biz_seq = i.biz_seq 
        AND s.prod_seq = i.prod_seq 
        AND s.sku1 = i.sku1 
        AND s.sku2 = i.sku2
    LEFT JOIN mdm_wh w ON i.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON i.loc_seq = l.loc_seq
WHERE s.biz_seq = 1
AND s.sku1 = 'SKU20250226-001'
AND s.sku2 = 'PLT001'
AND s.del_yn = 'N';

-- 수불 유형별 SKU 생성 통계
SELECT inout_type_cd, inout_dtl_cd,
       COUNT(*) AS sku_cnt,
       SUM(load_qty) AS total_qty
FROM wms_inven_sku
WHERE biz_seq = 1
AND create_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY inout_type_cd, inout_dtl_cd
ORDER BY inout_type_cd, inout_dtl_cd;

-- 삭제된 SKU 이력 조회 (오류 추적)
SELECT sku1, sku2, prod_seq,
       del_yn, mod_id, mod_dt
FROM wms_inven_sku
WHERE biz_seq = 1
AND del_yn = 'Y'
AND mod_dt >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY mod_dt DESC;
```