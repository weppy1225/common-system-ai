# wms_inven_st_prod (WMS_세트작업_품목)

## 1. 개요
세트작업 요청의 **품목 상세 정보**를 관리하는 테이블.
세트작업 헤더(`wms_inven_st`)에 속한 각 품목별로 세트품목 여부, 요청 수량, 예상 속성(유통기한, LOT번호 등)을 저장한다.

### 1.1 세트작업 품목 처리 흐름
```
wms_inven_st (세트작업 헤더)
└─ wms_inven_st_prod (세트작업 품목)
        ├─ 세트품목 : 조립/분해의 대상이 되는 세트 품목 (assembly_yn=Y 시 증가, N 시 감소)
        └─ 구성품목 : 세트를 구성하는 개별 품목 (assembly_yn=Y 시 감소, N 시 증가)
              └─ wms_inven_st_tran (세트작업 처리 이력 → 재고 변동)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_prod_seq | bigint | N | nextval('wms_inven_st_prod_seq') | 세트작업 품목 SEQ |
| PK/FK | st_seq | integer | N | | 세트작업 SEQ → wms_inven_st |
| | st_prod_sts_cd | varchar(50) | N | | 세트작업 품목 상태 코드 |
| | mdm_st_prod_seq | integer | Y | | 세트구성 SEQ → mdm_st_prod |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량(세트작업) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_mng_ymd | varchar(8) | Y | | 예상 입고/제조일자 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | mv_seq | integer | Y | | 재고이동 SEQ |
| | if_idx | varchar(20) | Y | | IF 내부 순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **st_prod_sts_cd** (`ST_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 완료 |

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
| wms_inven_st_prod_PK | st_prod_seq, st_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_prod_seq | wms_inven_st_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| st_seq | wms_inven_st | st_seq | wms_inven_st_TO_wms_inven_st_prod |
| mdm_st_prod_seq | mdm_st_prod | st_prod_seq | mdm_st_prod_TO_wms_inven_st_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_st_tran | st_prod_seq, st_seq | wms_inven_st_prod_TO_wms_inven_st_tran |

---

## 7. 업무 규칙

### 7.1 세트작업 품목 등록
- 세트작업 헤더(`wms_inven_st`) 등록 시 함께 생성
- 하나의 세트작업 헤더에 여러 품목 등록 가능
- 반드시 하나의 세트품목(`mdm_st_prod_seq`로 마스터 구성 정보와 연결)과 하나 이상의 구성품목이 존재해야 함
- `mdm_st_prod_seq`로 마스터 세트 구성 정보 연결 가능

### 7.2 세트품목과 구성품목 구분
실제 테이블에는 `st_yn` 컬럼이 없지만, 세트작업 헤더의 `assembly_yn`과 품목의 역할에 따라 구분:

| 구분 | assembly_yn | 품목 역할 | 재고 영향 |
|------|-------------|----------|----------|
| 세트품목 | Y (조립) | 생성되는 품목 | 증가 |
| 세트품목 | N (분해) | 소멸되는 품목 | 감소 |
| 구성품목 | Y (조립) | 소멸되는 품목 | 감소 |
| 구성품목 | N (분해) | 생성되는 품목 | 증가 |

### 7.3 마스터 세트 구성 정보
- `mdm_st_prod_seq` : MDM 세트구성 마스터 테이블 참조
- 마스터 정보에는 세트 구성 비율(`qty`)이 정의됨
- 세트작업 시 이 비율에 따라 수량 계산

### 7.4 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 55 | 처리중 | 작업 진행 중 (일부 처리됨) |
| 77 | 완료 | 전체 수량 처리 완료 |

### 7.5 예상 속성 정보
- 세트작업 접수 단계에서 예상 정보 입력 가능
- `est_exp_ymd` : 예상 유통기한
- `est_mng_ymd` : 예상 제조일자/입고일자
- `est_lot_no` : 예상 LOT 번호
- 실제 처리 시(`wms_inven_st_tran`)에는 확정된 값으로 대체

### 7.6 수량 관리

#### 7.6.1 조립 작업 (assembly_yn = 'Y')
- 구성품목 `req_qty` : 조립에 사용될 구성품목 수량
- 세트품목 `req_qty` : 생성될 세트 수량
- 구성품목 수량 = 세트품목 수량 × 구성 비율

#### 7.6.2 분해 작업 (assembly_yn = 'N')
- 세트품목 `req_qty` : 분해할 세트 수량
- 구성품목 `req_qty` : 분해 후 생성될 구성품목 수량
- 구성품목 수량 = 세트품목 수량 × 구성 비율

### 7.7 재고 위치 정보
- `mv_seq` : 재고이동 SEQ 연결 가능
- 세트작업과 재고이동이 연계된 경우 참조

### 7.8 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 세트작업 품목 정보 송신 여부
- 품목별 송신 상태 관리 (헤더와 별도)
- `if_idx` : 외부 시스템에서의 순번/인덱스
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 7.9 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 헤더 삭제 시 하위 품목도 일괄 논리삭제 처리 필요
- 삭제된 품목은 처리 이력에서 제외

### 7.10 처리 이력 연동
- `wms_inven_st_tran`에서 실제 처리 내역 관리
- `proc_qty`와 `disassy_qty`로 처리 수량 관리
- 처리 완료 시 `st_prod_sts_cd`를 '77'로 변경

### 7.11 유효성 검증
- 세트 구성 관계가 `mdm_st_prod`에 정의되어 있는지 확인
- 구성 비율에 맞는 수량인지 확인
- 조립 작업 시 구성품목 재고 충분한지 확인
- 분해 작업 시 세트품목 재고 충분한지 확인

---

## 8. 주요 조회 예시

```sql
-- 세트작업별 품목 목록 조회
SELECT sp.st_prod_seq, sp.prod_seq, p.prod_nm, p.prod_no,
       s.assembly_yn,
       CASE 
           WHEN (s.assembly_yn = 'Y' AND sp.prod_seq = set_prod.prod_seq) THEN '세트품목(생성)'
           WHEN (s.assembly_yn = 'Y' AND sp.prod_seq != set_prod.prod_seq) THEN '구성품목(소멸)'
           WHEN (s.assembly_yn = 'N' AND sp.prod_seq = set_prod.prod_seq) THEN '세트품목(소멸)'
           WHEN (s.assembly_yn = 'N' AND sp.prod_seq != set_prod.prod_seq) THEN '구성품목(생성)'
       END AS prod_role,
       sp.req_qty,
       sp.st_prod_sts_cd,
       sp.est_exp_ymd, sp.est_lot_no,
       sp.mdm_st_prod_seq
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_st_prod set_prod ON s.st_seq = set_prod.st_seq 
        AND ((s.assembly_yn = 'Y' AND set_prod.prod_seq = sp.prod_seq) OR 1=1)
WHERE s.st_seq = 1001
AND sp.del_yn = 'N'
ORDER BY prod_role, sp.prod_seq;

-- 세트품목 기준 구성품목 목록 조회
SELECT
    set_prod.st_prod_seq AS set_st_prod_seq,
    set_prod.prod_seq AS set_prod_seq,
    set_p.prod_nm AS set_prod_nm,
    set_prod.req_qty AS set_qty,
    comp.st_prod_seq AS comp_st_prod_seq,
    comp.prod_seq AS comp_prod_seq,
    comp_p.prod_nm AS comp_prod_nm,
    comp.req_qty AS comp_qty,
    ROUND(comp.req_qty / NULLIF(set_prod.req_qty, 0), 2) AS comp_rate
FROM wms_inven_st_prod set_prod
    JOIN wms_inven_st s ON set_prod.st_seq = s.st_seq
    JOIN mdm_prod set_p ON set_prod.prod_seq = set_p.prod_seq
    JOIN wms_inven_st_prod comp ON set_prod.st_seq = comp.st_seq
    JOIN mdm_prod comp_p ON comp.prod_seq = comp_p.prod_seq
WHERE s.st_no = 'ST2502260001'
AND set_prod.prod_seq = 1001 -- 세트품목 PROD_SEQ
AND set_prod.del_yn = 'N'
AND comp.del_yn = 'N'
ORDER BY comp.st_prod_seq;

-- 미처리 세트작업 품목 조회 (예정/처리중)
SELECT s.st_no, s.req_ymd, s.assembly_yn,
       sp.prod_seq, p.prod_nm,
       sp.req_qty,
       sp.st_prod_sts_cd,
       sp.est_exp_ymd, sp.est_lot_no
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
WHERE s.biz_seq = 1
AND sp.st_prod_sts_cd IN ('11', '55')
AND sp.del_yn = 'N'
AND s.del_yn = 'N'
ORDER BY s.req_ymd, s.st_no;

-- 품목별 세트작업 이력 (해당 품목이 세트품목으로 사용된 경우)
SELECT s.st_no, s.req_ymd, s.assembly_yn,
       CASE 
           WHEN s.assembly_yn = 'Y' THEN '조립으로 생성'
           WHEN s.assembly_yn = 'N' THEN '분해로 소멸'
       END AS role,
       sp.req_qty,
       sp.st_prod_sts_cd
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
WHERE sp.prod_seq = 1001
AND ((s.assembly_yn = 'Y' AND sp.prod_seq = (SELECT prod_seq FROM wms_inven_st_prod WHERE st_seq = s.st_seq AND st_prod_seq = sp.st_prod_seq))
       OR (s.assembly_yn = 'N' AND sp.prod_seq = (SELECT prod_seq FROM wms_inven_st_prod WHERE st_seq = s.st_seq AND st_prod_seq = sp.st_prod_seq)))
AND sp.del_yn = 'N'
ORDER BY s.req_ymd DESC;

-- 품목별 세트작업 이력 (해당 품목이 구성품목으로 사용된 경우)
SELECT s.st_no, s.req_ymd, s.assembly_yn,
       set_prod.prod_seq AS set_prod_seq,
       set_p.prod_nm AS set_prod_nm,
       CASE 
           WHEN s.assembly_yn = 'Y' THEN '조립에 사용'
           WHEN s.assembly_yn = 'N' THEN '분해로 생성'
       END AS role,
       sp.req_qty,
       sp.st_prod_sts_cd
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN wms_inven_st_prod set_prod ON s.st_seq = set_prod.st_seq 
        AND set_prod.prod_seq != sp.prod_seq
    JOIN mdm_prod set_p ON set_prod.prod_seq = set_p.prod_seq
WHERE sp.prod_seq = 2002
AND sp.del_yn = 'N'
AND set_prod.del_yn = 'N'
ORDER BY s.req_ymd DESC;

-- IF 송신 대기 품목 조회
SELECT s.st_no, s.req_ymd,
       sp.prod_seq, p.prod_nm,
       sp.req_qty, sp.if_idx
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
WHERE s.biz_seq = 1
AND sp.if_send_yn = 'N'
AND sp.del_yn = 'N'
AND s.del_yn = 'N'
ORDER BY sp.reg_dt;

-- 예상 유통기한 정보가 있는 품목 조회
SELECT s.st_no, s.req_ymd, s.assembly_yn,
       sp.prod_seq, p.prod_nm,
       sp.req_qty,
       sp.est_exp_ymd, sp.est_mng_ymd, sp.est_lot_no
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
WHERE s.biz_seq = 1
AND (sp.est_exp_ymd IS NOT NULL OR sp.est_mng_ymd IS NOT NULL OR sp.est_lot_no IS NOT NULL)
AND sp.del_yn = 'N'
AND s.del_yn = 'N'
ORDER BY s.req_ymd;

-- 세트작업별 품목 수량 통계
SELECT s.st_no, s.assembly_yn,
       COUNT(sp.st_prod_seq) AS total_prod_cnt,
       SUM(CASE WHEN (s.assembly_yn = 'Y' AND sp.prod_seq = set_prod.prod_seq) THEN 1 ELSE 0 END) AS set_prod_cnt,
       SUM(CASE WHEN (s.assembly_yn = 'Y' AND sp.prod_seq != set_prod.prod_seq) THEN 1 ELSE 0 END) AS comp_prod_cnt,
       SUM(CASE WHEN (s.assembly_yn = 'Y' AND sp.prod_seq = set_prod.prod_seq) THEN sp.req_qty ELSE 0 END) AS total_set_qty,
       SUM(CASE WHEN (s.assembly_yn = 'Y' AND sp.prod_seq != set_prod.prod_seq) THEN sp.req_qty ELSE 0 END) AS total_comp_qty
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    LEFT JOIN wms_inven_st_prod set_prod ON s.st_seq = set_prod.st_seq 
        AND set_prod.prod_seq = sp.prod_seq
WHERE s.biz_seq = 1
AND s.req_ymd = '20250226'
AND sp.del_yn = 'N'
GROUP BY s.st_no, s.assembly_yn
ORDER BY s.st_no;

-- 처리 이력이 없는 미완료 품목
SELECT s.st_no, s.req_ymd,
       sp.prod_seq, p.prod_nm,
       sp.req_qty,
       sp.st_prod_sts_cd
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_st_tran st ON sp.st_prod_seq = st.st_prod_seq
        AND st.del_yn = 'N'
WHERE s.biz_seq = 1
AND sp.st_prod_sts_cd != '77'
AND st.st_tran_seq IS NULL
AND sp.del_yn = 'N'
AND s.del_yn = 'N'
ORDER BY s.req_ymd;

-- 마스터 세트 구성 정보와 연결된 품목 조회
SELECT sp.st_prod_seq, sp.prod_seq, p.prod_nm,
       sp.mdm_st_prod_seq,
       msp.prod_seq AS master_prod_seq,
       mp.prod_nm AS master_prod_nm,
       msp.qty AS master_qty,
       sp.req_qty
FROM wms_inven_st_prod sp
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
    LEFT JOIN mdm_st_prod msp ON sp.mdm_st_prod_seq = msp.st_prod_seq
    LEFT JOIN mdm_prod mp ON msp.prod_seq = mp.prod_seq
WHERE sp.st_seq = 1001
AND sp.mdm_st_prod_seq IS NOT NULL
AND sp.del_yn = 'N'
ORDER BY sp.st_prod_seq;

-- 재고이동과 연결된 세트작업 품목
SELECT sp.st_prod_seq, s.st_no,
       sp.prod_seq, p.prod_nm,
       sp.mv_seq, mv.mv_no
FROM wms_inven_st_prod sp
    JOIN wms_inven_st s ON sp.st_seq = s.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_mv mv ON sp.mv_seq = mv.mv_seq
WHERE s.biz_seq = 1
AND sp.mv_seq IS NOT NULL
AND sp.del_yn = 'N'
ORDER BY s.req_ymd;
```