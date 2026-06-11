# wms_inven_st_tran (WMS_세트작업_처리)

## 1. 개요
세트작업의 **실제 처리 이력**을 관리하는 테이블.
조립 작업 시 구성품목의 재고 감소와 세트품목의 재고 증가를, 분해 작업 시 세트품목의 재고 감소와 구성품목의 재고 증가를 동시에 기록하며, 재고(`wms_inven`) 변동의 근거가 된다.

### 1.1 세트작업 처리 이력 흐름
```
wms_inven_st (세트작업 헤더) → wms_inven_st_prod (세트작업 품목)
                                ├─ 세트품목
                                └─ 구성품목
                                      └─ wms_inven_st_tran (세트작업 처리 이력)
                                            ├─ 조립: 구성품목 감소 + 세트품목 증가
                                            └─ 분해: 세트품목 감소 + 구성품목 증가
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_tran_seq | bigint | N | nextval('wms_inven_st_tran_seq') | 세트작업 처리 SEQ |
| PK/FK | st_prod_seq | bigint | N | | 세트작업 품목 SEQ → wms_inven_st_prod |
| PK/FK | st_seq | integer | N | | 세트작업 SEQ → wms_inven_st |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | wh_seq | integer | N | | 창고 SEQ → mdm_wh |
| | loc_seq | bigint | N | | 위치 SEQ → mdm_loc |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | disassy_qty | decimal(10,2) | N | 0 | 해체 수량 |
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
| wms_inven_st_tran_PK | st_tran_seq, st_prod_seq, st_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_tran_seq | wms_inven_st_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_prod_seq, st_seq | wms_inven_st_prod | st_prod_seq, st_seq | wms_inven_st_prod_TO_wms_inven_st_tran |

---

## 6. 업무 규칙

### 6.1 세트작업 처리 등록
- 세트작업 품목(`wms_inven_st_prod`)에 대한 실제 작업 시 생성
- 하나의 세트작업 건에 대해 여러 처리 이력 생성 가능 (부분 처리)
- `proc_qty` : 이번 처리에서 조립/분해된 수량

### 6.2 수량 필드 구분

| 필드 | 설명 | 사용처 |
|------|------|--------|
| proc_qty | 처리 수량 | 조립/분해 모두 사용 |
| disassy_qty | 해체 수량 | 분해 작업 시 구성품목 처리에 사용 |

실제로는 `proc_qty`만 사용하고 `disassy_qty`는 구분자로 활용될 수 있음.

### 6.3 작업 유형별 처리

#### 6.3.1 조립 작업 (assembly_yn = 'Y')
| 품목 구분 | 재고 영향 | 처리 내용 |
|----------|----------|----------|
| 구성품목 | 감소 | `wh_seq`, `loc_seq`: 출고 위치 (FR) |
| 세트품목 | 증가 | `wh_seq`, `loc_seq`: 입고 위치 (TO) |

#### 6.3.2 분해 작업 (assembly_yn = 'N')
| 품목 구분 | 재고 영향 | 처리 내용 |
|----------|----------|----------|
| 세트품목 | 감소 | `wh_seq`, `loc_seq`: 출고 위치 (FR) |
| 구성품목 | 증가 | `wh_seq`, `loc_seq`: 입고 위치 (TO) |

### 6.4 재고 위치 정보

#### 6.4.1 출고 위치 (재고 감소)
- `wh_seq`, `loc_seq` : 실제 재고가 존재하는 위치
- `sku1`, `sku2` : 출고되는 재고의 SKU
- 해당 위치에 충분한 재고가 있어야 함

#### 6.4.2 입고 위치 (재고 증가)
- `wh_seq`, `loc_seq` : 새로 재고가 쌓일 위치
- `sku1`, `sku2` : 새로 생성되는 재고의 SKU
- 세트품목의 SKU는 별도 규칙에 따라 생성

### 6.5 수량 일관성

#### 6.5.1 조립 작업
- 구성품목들의 `proc_qty` 합계 = 세트품목 `proc_qty` × 구성 비율 총합
- 구성 비율은 `mdm_st_prod` 마스터 데이터에 정의

#### 6.5.2 분해 작업
- 세트품목 `proc_qty` × 구성 비율 총합 = 구성품목들의 `proc_qty` 합계

### 6.6 재고 변동 처리

#### 6.6.1 재고 감소 처리
- 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고에서 `proc_qty`만큼 차감
- 재고 부족 시 작업 불가 또는 부분 처리

#### 6.6.2 재고 증가 처리
- 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고에 `proc_qty`만큼 증가
- 존재하지 않으면 신규 재고 레코드 생성

### 6.7 처리 정보
- `proc_ymd`, `proc_hms` : 처리 일시 (보통 현재 일시)
- `proc_user_id` : 처리 작업자 ID
- `proc_bundle_no` : 일괄 처리 시 묶음 번호 (여러 세트작업 동시 처리 시 사용)

### 6.8 상태 갱신
- `wms_inven_st_prod.st_prod_sts_cd`를 '77'(완료)로 변경 (전체 수량 처리 시)
- 모든 품목의 처리 완료 시 `wms_inven_st.st_sts_cd`를 '77'(완료)로 변경

### 6.9 SKU/LOT 처리

#### 6.9.1 구성품목
- 기존 재고의 SKU/LOT 정보 그대로 사용
- 조립 시 해당 SKU/LOT의 재고 감소

#### 6.9.2 세트품목
- 새로운 SKU 생성 규칙에 따라 SKU 생성 가능
- LOT 번호는 신규 발행 또는 구성품목의 LOT 번호 통합
- 유통기한은 가장 짧은 구성품목의 유통기한을 따르거나 별도 지정

### 6.10 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 세트작업 처리 내역 송신 여부
- 처리 이력 단위로 송신 관리
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.11 취소/삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 해당 처리 수량만큼 재고 복원 필요
- 조립: 구성품목 재고 증가 + 세트품목 재고 감소
- 분해: 세트품목 재고 증가 + 구성품목 재고 감소
- 이미 완료된 세트작업의 처리 이력은 삭제 불가 (취소는 별도 조정 처리)

### 6.12 트랜잭션 처리
- 동일 세트작업의 모든 품목 처리는 반드시 동시에 성공하거나 실패해야 함
- 하나의 세트작업에 대한 모든 처리 이력은 동일한 `proc_bundle_no` 사용 권장

### 6.13 유효성 검증
- 세트 구성 관계가 `mdm_st_prod`에 정의되어 있는지 확인
- 구성 비율에 맞는 수량인지 확인
- 출고 위치에 충분한 재고가 있는지 확인

---

## 7. 주요 조회 예시

```sql
-- 세트작업별 처리 이력 조회
SELECT st.st_tran_seq, s.st_no, s.assembly_yn,
       CASE 
           WHEN s.assembly_yn = 'Y' AND st.prod_seq = set_prod.prod_seq THEN '세트품목(생성)'
           WHEN s.assembly_yn = 'Y' AND st.prod_seq != set_prod.prod_seq THEN '구성품목(소멸)'
           WHEN s.assembly_yn = 'N' AND st.prod_seq = set_prod.prod_seq THEN '세트품목(소멸)'
           WHEN s.assembly_yn = 'N' AND st.prod_seq != set_prod.prod_seq THEN '구성품목(생성)'
       END AS prod_role,
       st.prod_seq, p.prod_nm,
       st.proc_qty,
       st.wh_seq, w.wh_nm,
       st.loc_seq, l.loc_nm,
       st.sku1, st.sku2,
       st.proc_ymd, st.proc_hms, st.proc_user_id
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
    JOIN mdm_prod p ON st.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_st_prod set_prod ON s.st_seq = set_prod.st_seq 
        AND set_prod.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON st.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON st.loc_seq = l.loc_seq
WHERE s.biz_seq = 1
AND s.st_no = 'ST2502260001'
AND st.del_yn = 'N'
ORDER BY prod_role, st.st_tran_seq;

-- 세트품목 기준 구성품목 처리 이력 (조립 작업)
SELECT
    set_tran.st_tran_seq AS set_tran_seq,
    set_tran.prod_seq AS set_prod_seq,
    set_p.prod_nm AS set_prod_nm,
    set_tran.proc_qty AS set_qty,
    comp_tran.st_tran_seq AS comp_tran_seq,
    comp_tran.prod_seq AS comp_prod_seq,
    comp_p.prod_nm AS comp_prod_nm,
    comp_tran.proc_qty AS comp_qty,
    ROUND(comp_tran.proc_qty / NULLIF(set_tran.proc_qty, 0), 2) AS comp_rate
FROM wms_inven_st_tran set_tran
    JOIN wms_inven_st s ON set_tran.st_seq = s.st_seq
    JOIN mdm_prod set_p ON set_tran.prod_seq = set_p.prod_seq
    JOIN wms_inven_st_tran comp_tran ON set_tran.st_seq = comp_tran.st_seq
    JOIN mdm_prod comp_p ON comp_tran.prod_seq = comp_p.prod_seq
WHERE s.st_no = 'ST2502260001'
AND s.assembly_yn = 'Y'
AND set_tran.prod_seq = 1001 -- 세트품목 PROD_SEQ
AND comp_tran.prod_seq != 1001 -- 구성품목
AND set_tran.del_yn = 'N'
AND comp_tran.del_yn = 'N'
ORDER BY comp_tran.st_tran_seq;

-- 작업자별 처리 현황
SELECT st.proc_user_id,
       COUNT(*) AS tran_count,
       SUM(st.proc_qty) AS total_proc_qty,
       MIN(st.proc_ymd) AS first_proc_ymd,
       MAX(st.proc_ymd) AS last_proc_ymd
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
WHERE s.biz_seq = 1
AND st.proc_ymd BETWEEN '20250201' AND '20250228'
AND st.del_yn = 'N'
GROUP BY st.proc_user_id
ORDER BY total_proc_qty DESC;

-- 일자별 세트작업 처리 현황
SELECT st.proc_ymd,
       COUNT(DISTINCT st.st_seq) AS st_cnt,
       COUNT(*) AS tran_cnt,
       SUM(st.proc_qty) AS total_qty,
       COUNT(DISTINCT st.prod_seq) AS prod_cnt
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
WHERE s.biz_seq = 1
AND st.proc_ymd BETWEEN '20250201' AND '20250228'
AND st.del_yn = 'N'
GROUP BY st.proc_ymd
ORDER BY st.proc_ymd;

-- 특정 위치에서 처리된 세트작업 이력
SELECT st.st_tran_seq, s.st_no, s.assembly_yn,
       st.prod_seq, p.prod_nm,
       st.proc_qty, st.proc_ymd,
       st.sku1, st.sku2
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
    JOIN mdm_prod p ON st.prod_seq = p.prod_seq
WHERE st.wh_seq = 10
AND st.loc_seq = 1001
AND st.del_yn = 'N'
ORDER BY st.proc_ymd DESC;

-- IF 송신 대기 처리 이력
SELECT st.st_tran_seq, s.st_no,
       st.prod_seq, p.prod_nm,
       st.proc_qty, st.proc_ymd
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
    JOIN mdm_prod p ON st.prod_seq = p.prod_seq
WHERE s.biz_seq = 1
AND st.if_send_yn = 'N'
AND st.del_yn = 'N'
ORDER BY st.reg_dt;

-- 처리 묶음 번호별 조회
SELECT st.proc_bundle_no,
       COUNT(*) AS tran_cnt,
       COUNT(DISTINCT st.st_seq) AS st_cnt,
       SUM(st.proc_qty) AS total_qty,
       MIN(st.proc_ymd) AS min_proc_ymd,
       MAX(st.proc_ymd) AS max_proc_ymd
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
WHERE s.biz_seq = 1
AND st.proc_bundle_no IS NOT NULL
AND st.proc_ymd = '20250226'
AND st.del_yn = 'N'
GROUP BY st.proc_bundle_no
ORDER BY st.proc_bundle_no;

-- 창고별 세트작업 처리 현황
SELECT st.wh_seq, w.wh_nm,
       COUNT(*) AS tran_cnt,
       SUM(st.proc_qty) AS total_qty,
       COUNT(DISTINCT st.prod_seq) AS prod_cnt
FROM wms_inven_st_tran st
    JOIN mdm_wh w ON st.wh_seq = w.wh_seq
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
WHERE s.biz_seq = 1
AND st.proc_ymd BETWEEN '20250201' AND '20250228'
AND st.del_yn = 'N'
GROUP BY st.wh_seq, w.wh_nm
ORDER BY total_qty DESC;

-- 품목별 세트작업 처리 이력 (해당 품목이 세트품목으로 처리된 경우)
SELECT st.st_tran_seq, s.st_no, s.req_ymd,
       CASE 
           WHEN s.assembly_yn = 'Y' THEN '조립으로 생성'
           WHEN s.assembly_yn = 'N' THEN '분해로 소멸'
       END AS role,
       st.proc_qty,
       st.wh_seq, st.loc_seq,
       st.sku1, st.sku2,
       st.proc_ymd, st.proc_user_id
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
WHERE st.prod_seq = 1001
AND ((s.assembly_yn = 'Y' AND st.prod_seq = (SELECT prod_seq FROM wms_inven_st_prod WHERE st_seq = s.st_seq AND st_prod_seq = st.st_prod_seq))
       OR (s.assembly_yn = 'N' AND st.prod_seq = (SELECT prod_seq FROM wms_inven_st_prod WHERE st_seq = s.st_seq AND st_prod_seq = st.st_prod_seq)))
AND st.del_yn = 'N'
ORDER BY st.proc_ymd DESC;

-- 품목별 세트작업 처리 이력 (해당 품목이 구성품목으로 처리된 경우)
SELECT st.st_tran_seq, s.st_no, s.req_ymd, s.assembly_yn,
       set_tran.prod_seq AS set_prod_seq,
       set_p.prod_nm AS set_prod_nm,
       CASE 
           WHEN s.assembly_yn = 'Y' THEN '조립에 사용'
           WHEN s.assembly_yn = 'N' THEN '분해로 생성'
       END AS role,
       st.proc_qty,
       st.wh_seq, st.loc_seq,
       st.sku1, st.sku2,
       st.proc_ymd, st.proc_user_id
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
    JOIN wms_inven_st_tran set_tran ON s.st_seq = set_tran.st_seq 
        AND set_tran.prod_seq != st.prod_seq
    JOIN mdm_prod set_p ON set_tran.prod_seq = set_p.prod_seq
WHERE st.prod_seq = 2002
AND st.del_yn = 'N'
AND set_tran.del_yn = 'N'
ORDER BY st.proc_ymd DESC;

-- 부분 처리된 세트작업 현황
SELECT s.st_no, s.req_ymd, s.assembly_yn,
       COUNT(DISTINCT st.st_tran_seq) AS tran_cnt,
       SUM(st.proc_qty) AS total_processed,
       sp.req_qty AS total_required
FROM wms_inven_st_tran st
    JOIN wms_inven_st s ON st.st_seq = s.st_seq
    JOIN wms_inven_st_prod sp ON st.st_prod_seq = sp.st_prod_seq
WHERE s.biz_seq = 1
AND s.st_sts_cd = '55' -- 처리중
AND st.del_yn = 'N'
GROUP BY s.st_no, s.req_ymd, s.assembly_yn, sp.req_qty
HAVING SUM(st.proc_qty) < sp.req_qty
ORDER BY s.req_ymd;
```