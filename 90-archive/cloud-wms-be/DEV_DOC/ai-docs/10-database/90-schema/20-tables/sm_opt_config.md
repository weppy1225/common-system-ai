# sm_opt_config (시스템_출력물_설정)

## 1. 개요
**출력물(라벨, 명세서 등) 관련 시스템 설정**을 관리하는 테이블.
출하라벨 사용 여부, 재고확인 여부, 출고지시 유형, 기본 바코드 타입 등을 정의하여 출력물 생성 방식과 출력 기준을 설정한다.

### 1.1 출력물 설정 흐름
```
출력물 설정 정의 → sm_opt_config 등록 → 출력물 생성 시 설정 적용
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | biz_seq | integer | N | | 사업장 SEQ |
| | outbiz_inven_check_yn | char(1) | N | 'Y' | 출하 재고확인 여부 |
| | outbiz_label_yn | char(1) | N | 'Y' | 출하라벨 사용 여부 |
| | outwh_div_cd | varchar(50) | N | '-' | 출고지시 유형 코드 |
| | strng_asgn_yn | char(1) | N | 'N' | 출고지시 지정유형 여부 |
| | def_barcode_type1 | varchar(50) | N | | 1D 바코드 기본타입 |
| | def_barcode_type2 | varchar(50) | N | | 2D 바코드 기본타입 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outbiz_inven_check_yn**, **outbiz_label_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | Y | 사용 | 기능 사용 |
> | N | 미사용 | 기능 미사용 |

> **outwh_div_cd** (`OUTWH_DIV_CD`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | - | 총괄 | 전체 피킹 일괄 지시 |
> | wh | 창고별 | 창고 단위로 피킹 지시 분할 |
> | locMng | 담당자별 | 담당자별로 피킹 지시 분할 |
> | outbizNo | 출하번호 | 출하 단위로 피킹 지시 분할 |

> **strng_asgn_yn** (`STRNG_ASGN_YN`)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | Y | 강지정 | 사용자가 직접 재고 위치 지정 |
> | N | 약지정 | 시스템이 자동으로 재고 위치 지정 |

> **def_barcode_type1**, **def_barcode_type2** (`BARCODE_TYPE_CD`)
>
> | 코드 | 코드명 | 차원 | 설명 |
> |---|---|---|---|
> | 16 | CODE_128 | 1D | 범용 1D 바코드 |
> | 32 | DATA_MATRIX | 2D | 2D Data Matrix |
> | 2048 | QR_CODE | 2D | QR 코드 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| sm_opt_config_PK | biz_seq | Y | Y |

---

## 4. 업무 규칙

### 4.1 출하 관련 설정

#### 4.1.1 출하 재고확인 여부 (`outbiz_inven_check_yn`)

| 값 | 설명 | 적용场景 |
|----|------|---------|
| Y | 재고확인 수행 | 출하 전 가용재고 확인 필수 |
| N | 재고확인 생략 | 재고확인 없이 출하 처리 |

**재고확인 로직:**
```sql
-- Y인 경우 출하 전 재고 확인
SELECT SUM(inven_qty - wt_qty) >= req_qty
FROM wms_inven
WHERE biz_seq = :biz_seq
AND prod_seq = :prod_seq
AND wh_seq = :wh_seq
AND loc_seq = :loc_seq;
```

#### 4.1.2 출하라벨 사용 여부 (`outbiz_label_yn`)

| 값 | 설명 | 적용场景 |
|----|------|---------|
| Y | 라벨 출력 | 출하 시 라벨 자동 출력 |
| N | 라벨 미출력 | 라벨 출력 생략 |

### 4.2 출고지시 관련 설정

#### 4.2.1 출고지시 유형 코드 (`outwh_div_cd`)

| 코드 | 설명 | 피킹 지시 단위 |
|------|------|---------------|
| - | 총괄 | 전체 출하 통합 지시 |
| wh | 창고별 | 창고별로 분할 지시 |
| locMng | 담당자별 | 담당자별로 분할 지시 |
| outbizNo | 출하번호 | 출하 건별 분할 지시 |

**적용 예시:**
- `-` : 소규모 창고, 전체 피킹
- `wh` : 대규모 창고, 창고별 담당자 분리
- `locMng` : 담당자별 책임 구역 운영
- `outbizNo` : 출하 건별 피킹 (B2C 등)

#### 4.2.2 출고지시 지정유형 (`strng_asgn_yn`)

| 값 | 설명 | 처리 방식 |
|----|------|----------|
| Y | 강지정 | 사용자가 위치 직접 선택 |
| N | 약지정 | 시스템이 FIFO/LIFO 등 알고리즘으로 자동 지정 |

### 4.3 바코드 기본 타입

#### 4.3.1 1D 바코드 (`def_barcode_type1`)
- CODE_128(16) 기본 사용
- 품목별 별도 설정이 없는 경우 적용

#### 4.3.2 2D 바코드 (`def_barcode_type2`)
- DATA_MATRIX(32) 또는 QR_CODE(2048) 선택
- 품목 특성에 따라 기본값 설정

### 4.4 사업장별 설정
- 사업장마다 다른 출력물 설정 가능
- 본사/지점별 운영 방식 차이 반영

### 4.5 기본값
- `outbiz_inven_check_yn`: 'Y' (재고확인 필수)
- `outbiz_label_yn`: 'Y' (라벨 출력)
- `outwh_div_cd`: '-' (총괄)
- `strng_asgn_yn`: 'N' (약지정)

---

## 5. 주요 조회 예시

```sql
-- 특정 사업장의 출력물 설정 조회
SELECT biz_seq,
       outbiz_inven_check_yn,
       CASE outbiz_inven_check_yn WHEN 'Y' THEN '재고확인함' ELSE '재고확인안함' END AS inven_check_nm,
       outbiz_label_yn,
       CASE outbiz_label_yn WHEN 'Y' THEN '라벨출력함' ELSE '라벨출력안함' END AS label_nm,
       outwh_div_cd,
       CASE outwh_div_cd
           WHEN '-' THEN '총괄'
           WHEN 'wh' THEN '창고별'
           WHEN 'locMng' THEN '담당자별'
           WHEN 'outbizNo' THEN '출하번호별'
       END AS outwh_div_nm,
       strng_asgn_yn,
       CASE strng_asgn_yn WHEN 'Y' THEN '강지정' ELSE '약지정' END AS assign_nm,
       def_barcode_type1,
       def_barcode_type2
FROM sm_opt_config
WHERE biz_seq = 1;

-- 출하라벨 미사용 사업장 목록
SELECT b.biz_seq, b.biz_nm
FROM sm_opt_config o
    JOIN mdm_biz b ON o.biz_seq = b.biz_seq
WHERE o.outbiz_label_yn = 'N'
ORDER BY b.biz_seq;

-- 재고확인 생략 사업장 목록
SELECT b.biz_seq, b.biz_nm
FROM sm_opt_config o
    JOIN mdm_biz b ON o.biz_seq = b.biz_seq
WHERE o.outbiz_inven_check_yn = 'N'
ORDER BY b.biz_seq;

-- 출고지시 유형별 설정 현황
SELECT outwh_div_cd,
       COUNT(*) AS config_cnt,
       SUM(CASE WHEN strng_asgn_yn = 'Y' THEN 1 ELSE 0 END) AS strong_assign_cnt
FROM sm_opt_config
GROUP BY outwh_div_cd
ORDER BY outwh_div_cd;

-- 강지정 사용 사업장 목록
SELECT b.biz_seq, b.biz_nm,
       o.outwh_div_cd,
       o.def_barcode_type1, o.def_barcode_type2
FROM sm_opt_config o
    JOIN mdm_biz b ON o.biz_seq = b.biz_seq
WHERE o.strng_asgn_yn = 'Y'
ORDER BY b.biz_seq;

-- 바코드 타입별 설정 현황
SELECT
    def_barcode_type1,
    CASE def_barcode_type1
        WHEN '16' THEN 'CODE_128'
        ELSE '기타'
    END AS barcode_type1_nm,
    COUNT(*) AS type1_cnt,
    def_barcode_type2,
    CASE def_barcode_type2
        WHEN '32' THEN 'DATA_MATRIX'
        WHEN '2048' THEN 'QR_CODE'
        ELSE '기타'
    END AS barcode_type2_nm,
    COUNT(*) AS type2_cnt
FROM sm_opt_config
GROUP BY def_barcode_type1, def_barcode_type2
ORDER BY def_barcode_type1, def_barcode_type2;

-- 기본값과 다른 설정을 가진 사업장
SELECT biz_seq,
       outbiz_inven_check_yn,
       outbiz_label_yn,
       outwh_div_cd,
       strng_asgn_yn
FROM sm_opt_config
WHERE outbiz_inven_check_yn != 'Y'
OR outbiz_label_yn != 'Y'
OR outwh_div_cd != '-'
OR strng_asgn_yn != 'N'
ORDER BY biz_seq;

-- 사업장별 출력물 설정 비교
SELECT o1.biz_seq AS biz_seq_1, b1.biz_nm AS biz_nm_1,
       o2.biz_seq AS biz_seq_2, b2.biz_nm AS biz_nm_2,
       o1.outwh_div_cd, o2.outwh_div_cd,
       o1.strng_asgn_yn, o2.strng_asgn_yn
FROM sm_opt_config o1
    JOIN sm_opt_config o2 ON o1.biz_seq < o2.biz_seq
    JOIN mdm_biz b1 ON o1.biz_seq = b1.biz_seq
    JOIN mdm_biz b2 ON o2.biz_seq = b2.biz_seq
WHERE o1.outwh_div_cd != o2.outwh_div_cd
OR o1.strng_asgn_yn != o2.strng_asgn_yn
ORDER BY o1.biz_seq, o2.biz_seq;

-- 최근 수정된 설정 내역
SELECT o.mod_dt, o.mod_id,
       b.biz_nm,
       o.outbiz_inven_check_yn,
       o.outbiz_label_yn,
       o.outwh_div_cd,
       o.strng_asgn_yn
FROM sm_opt_config o
    JOIN mdm_biz b ON o.biz_seq = b.biz_seq
WHERE o.mod_dt >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.mod_dt DESC;

-- 설정이 없는 사업장 체크 (신규 사업장)
SELECT b.biz_seq, b.biz_nm
FROM mdm_biz b
    LEFT JOIN sm_opt_config o ON b.biz_seq = o.biz_seq
WHERE b.use_yn = 'Y'
AND o.biz_seq IS NULL
ORDER BY b.biz_seq;
```