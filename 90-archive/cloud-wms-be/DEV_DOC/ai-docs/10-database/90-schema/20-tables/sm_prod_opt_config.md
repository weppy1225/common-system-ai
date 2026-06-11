# sm_prod_opt_config (시스템_품목_옵션_설정)

## 1. 개요
**품목 분류별 옵션 설정**을 관리하는 테이블.
품목 분류 코드(`prod_div_cd`)별로 SKU 관리 방식, 유통기한 관리 여부, 라벨용지 등을 정의하여 품목 마스터 등록 시 기본값으로 활용한다.

### 1.1 품목 옵션 설정 흐름
```
품목 분류별 옵션 정의 → sm_prod_opt_config 등록 → 품목 등록 시 옵션 기본값 적용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| PK | prod_div_cd | varchar(50) | N | | 품목 분류 코드 |
| | prod_sku_mng_cd | varchar(50) | N | 'N' | SKU 관리 유형 코드 |
| | prod_mng_ymd_yn | char(1) | N | 'N' | 제조일자 관리 여부 |
| | prod_eff_mng_yn | char(1) | N | 'N' | 유통기한 관리 여부 |
| | prod_lot_no_yn | char(1) | N | 'N' | LOT 번호 관리 여부 |
| | prod_cn_mng_yn | char(1) | N | 'N' | C/N 관리 여부 |
| | prod_sku2_mng_yn | char(1) | N | 'N' | 파렛트 관리 여부 |
| | label_paper_seq | integer | N | | 라벨용지 SEQ |
| | parent_label_paper_seq | integer | Y | | 상위 라벨용지 SEQ |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **prod_div_cd** (`PROD_DIV_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | 0 | 원자재 | 생산 원자재 |
> | 1 | 상품 | 판매 상품 |
> | 2 | 제품 | 완제품 |
> | 3 | 부자재 | 포장재, 라벨 등 |
> | 4 | 반제품 | 생산 중간품 |
> | 5 | 세트 | 세트 구성품 |

> **prod_sku_mng_cd** (`SKU_MNG_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | N | 사용안함 | SKU 미사용 |
> | B | 유통표준코드 | GTIN-13, GTIN-14 등 |
> | C | 자사물류코드 | 자체 생성 코드 |

> **관리 여부 필드** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 관리함 |
> | N | 관리안함 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_prod_opt_config_PK | biz_seq, prod_div_cd | Y | Y |

---

## 4. 업무 규칙

### 4.1 품목 분류별 옵션
- 품목 대분류/중분류/소분류별로 다른 옵션 적용 가능
- 신규 품목 등록 시 해당 분류의 옵션을 기본값으로 사용
- 개별 품목에서 옵션 변경 가능 (Override)

### 4.2 SKU 관리 방식

| 코드 | 관리 방식 | 설명 |
|------|----------|------|
| N | 사용안함 | SKU 생성하지 않음 (단순 재고 관리) |
| B | 유통표준코드 | GTIN-13, GTIN-14 등 표준 바코드 사용 |
| C | 자사물류코드 | 회사 내부 코드로 SKU 생성 |

**SKU 생성 규칙:**
- B: 품목번호 + (선택적) 속성코드
- C: 품목번호 + 일련번호 + (선택적) 속성코드

### 4.3 속성 관리 여부

| 필드 | 코드 | 설명 | 적용 품목 |
|------|------|------|----------|
| 제조일자 | prod_mng_ymd_yn | 제조일자 관리 필요 여부 | 식품, 화장품 등 |
| 유통기한 | prod_eff_mng_yn | 유통기한 관리 필요 여부 | 식품, 의약품 등 |
| LOT 번호 | prod_lot_no_yn | LOT 번호 관리 필요 여부 | 이력 추적 필요 품목 |
| C/N | prod_cn_mng_yn | Container Number 관리 여부 | 수입품, 대형 자재 |
| 파렛트 | prod_sku2_mng_yn | 파렛트 단위 관리 여부 | 파렛트 단위 입출고 품목 |

### 4.4 라벨용지 설정

| 필드 | 설명 | 참조 |
|------|------|------|
| label_paper_seq | 기본 라벨용지 | mdm_label_paper |
| parent_label_paper_seq | 상위 단위(파렛트 등) 라벨용지 | mdm_label_paper |

**라벨용지 구분:**
- SL: SKU 라벨
- PL: 파렛트 라벨
- OL: 출하 라벨
- IL: 품목 라벨

### 4.5 사업장별 설정
- 사업장마다 다른 품목 옵션 설정 가능
- 본사/지점별 품목 관리 정책 차이 반영

### 4.6 기본값
| 필드 | 기본값 | 설명 |
|------|--------|------|
| prod_sku_mng_cd | 'N' | SKU 관리 안함 |
| prod_mng_ymd_yn | 'N' | 제조일자 관리 안함 |
| prod_eff_mng_yn | 'N' | 유통기한 관리 안함 |
| prod_lot_no_yn | 'N' | LOT 관리 안함 |
| prod_cn_mng_yn | 'N' | C/N 관리 안함 |
| prod_sku2_mng_yn | 'N' | 파렛트 관리 안함 |

---

## 5. 주요 조회 예시

```sql
-- 특정 사업장의 품목 분류별 옵션
SELECT po.prod_div_cd,
       cd.comm_d_nm AS prod_div_nm,
       po.prod_sku_mng_cd,
       CASE po.prod_sku_mng_cd
           WHEN 'N' THEN '사용안함'
           WHEN 'B' THEN '유통표준코드'
           WHEN 'C' THEN '자사물류코드'
       END AS sku_mng_nm,
       po.prod_eff_mng_yn,
       po.prod_lot_no_yn,
       po.prod_sku2_mng_yn,
       po.label_paper_seq,
       lp.label_paper_nm,
       po.parent_label_paper_seq,
       plp.label_paper_nm AS parent_label_nm
FROM sm_prod_opt_config po
    JOIN sm_comm_d cd ON po.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
        AND cd.biz_seq = 0  -- 공통코드
    LEFT JOIN mdm_label_paper lp ON po.label_paper_seq = lp.label_paper_seq
    LEFT JOIN mdm_label_paper plp ON po.parent_label_paper_seq = plp.label_paper_seq
WHERE po.biz_seq = 1
ORDER BY cd.disp_no;

-- 유통기한 관리 필수 분류 조회
SELECT po.prod_div_cd, cd.comm_d_nm
FROM sm_prod_opt_config po
    JOIN sm_comm_d cd ON po.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
WHERE po.biz_seq = 1
AND po.prod_eff_mng_yn = 'Y'
ORDER BY cd.disp_no;

-- LOT 관리 필수 분류 조회
SELECT po.prod_div_cd, cd.comm_d_nm
FROM sm_prod_opt_config po
    JOIN sm_comm_d cd ON po.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
WHERE po.biz_seq = 1
AND po.prod_lot_no_yn = 'Y'
ORDER BY cd.disp_no;

-- 파렛트 관리 분류 조회
SELECT po.prod_div_cd, cd.comm_d_nm,
       po.parent_label_paper_seq,
       lp.label_paper_nm
FROM sm_prod_opt_config po
    JOIN sm_comm_d cd ON po.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
    LEFT JOIN mdm_label_paper lp ON po.parent_label_paper_seq = lp.label_paper_seq
WHERE po.biz_seq = 1
AND po.prod_sku2_mng_yn = 'Y'
ORDER BY cd.disp_no;

-- SKU 관리 방식별 분류 현황
SELECT po.prod_sku_mng_cd,
       COUNT(*) AS div_cnt,
       LISTAGG(po.prod_div_cd, ', ') WITHIN GROUP (ORDER BY po.prod_div_cd) AS div_list
FROM sm_prod_opt_config po
WHERE po.biz_seq = 1
GROUP BY po.prod_sku_mng_cd
ORDER BY po.prod_sku_mng_cd;

-- 속성 관리 개수별 분류 현황
SELECT
    (CASE WHEN prod_mng_ymd_yn = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN prod_eff_mng_yn = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN prod_lot_no_yn = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN prod_cn_mng_yn = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN prod_sku2_mng_yn = 'Y' THEN 1 ELSE 0 END) AS attr_cnt,
    COUNT(*) AS div_cnt
FROM sm_prod_opt_config
WHERE biz_seq = 1
GROUP BY attr_cnt
ORDER BY attr_cnt;

-- 특정 분류의 상세 옵션 조회
SELECT *
FROM sm_prod_opt_config
WHERE biz_seq = 1
AND prod_div_cd = '1'; -- 상품 분류

-- 라벨용지 설정 현황
SELECT lp.label_paper_seq, lp.label_paper_nm,
       COUNT(po.prod_div_cd) AS used_cnt,
       LISTAGG(po.prod_div_cd, ', ') WITHIN GROUP (ORDER BY po.prod_div_cd) AS div_list
FROM mdm_label_paper lp
    LEFT JOIN sm_prod_opt_config po ON lp.label_paper_seq = po.label_paper_seq
        AND po.biz_seq = 1
WHERE lp.use_yn = 'Y'
GROUP BY lp.label_paper_seq, lp.label_paper_nm
ORDER BY lp.label_paper_seq;

-- 기본값과 다른 설정을 가진 분류
SELECT prod_div_cd,
       prod_sku_mng_cd,
       prod_eff_mng_yn,
       prod_lot_no_yn
FROM sm_prod_opt_config
WHERE biz_seq = 1
AND (prod_sku_mng_cd != 'N'
       OR prod_eff_mng_yn != 'N'
       OR prod_lot_no_yn != 'N'
       OR prod_sku2_mng_yn != 'N')
ORDER BY prod_div_cd;

-- 사업장별 품목 분류 옵션 비교
SELECT o1.prod_div_cd, cd.comm_d_nm,
       o1.prod_sku_mng_cd AS biz1_sku,
       o2.prod_sku_mng_cd AS biz2_sku,
       o1.prod_eff_mng_yn AS biz1_eff,
       o2.prod_eff_mng_yn AS biz2_eff,
       o1.prod_lot_no_yn AS biz1_lot,
       o2.prod_lot_no_yn AS biz2_lot
FROM sm_prod_opt_config o1
    JOIN sm_prod_opt_config o2 ON o1.prod_div_cd = o2.prod_div_cd
    JOIN sm_comm_d cd ON o1.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
WHERE o1.biz_seq = 1
AND o2.biz_seq = 2
ORDER BY cd.disp_no;

-- 최근 수정된 설정 내역
SELECT po.mod_dt, po.mod_id,
       cd.comm_d_nm AS prod_div_nm,
       po.prod_sku_mng_cd,
       po.prod_eff_mng_yn,
       po.prod_lot_no_yn
FROM sm_prod_opt_config po
    JOIN sm_comm_d cd ON po.prod_div_cd = cd.comm_d_cd 
        AND cd.comm_h_cd = 'PROD_DIV_CD'
WHERE po.biz_seq = 1
AND po.mod_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY po.mod_dt DESC;

-- 설정이 없는 품목 분류 체크
SELECT cd.comm_d_cd AS prod_div_cd, cd.comm_d_nm
FROM sm_comm_d cd
    LEFT JOIN sm_prod_opt_config po ON cd.comm_d_cd = po.prod_div_cd 
        AND po.biz_seq = 1
WHERE cd.comm_h_cd = 'PROD_DIV_CD'
AND cd.use_yn = 'Y'
AND po.prod_div_cd IS NULL
ORDER BY cd.disp_no;
```