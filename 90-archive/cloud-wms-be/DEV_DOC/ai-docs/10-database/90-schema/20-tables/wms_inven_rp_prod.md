# wms_inven_rp_prod (WMS_품목전환_품목)

## 1. 개요
품목전환 요청의 **품목 상세 정보**를 관리하는 테이블.
품목전환 헤더(`wms_inven_rp`)에 속한 각 품목별로 기준품목 여부, 요청 수량, 예상 속성(유통기한, LOT번호 등)을 저장한다.

### 1.1 품목전환 품목 처리 흐름
```
wms_inven_rp (품목전환 헤더)
└─ wms_inven_rp_prod (품목전환 품목)
        ├─ 기준품목(st_yn = 'Y') : 전환의 기준이 되는 품목
        └─ 대상품목(st_yn = 'N') : 전환될 품목
              └─ wms_inven_rp_tran (품목전환 처리 이력 → 재고 변동)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | rp_prod_seq | bigint | N | nextval('wms_inven_rp_prod_seq') | 품목전환 품목 SEQ |
| PK/FK | rp_seq | integer | N | | 품목전환 SEQ → wms_inven_rp |
| | rp_prod_sts_cd | varchar(50) | N | | 품목전환 품목 상태 코드 |
| | st_yn | char(1) | N | 'N' | 기준품목 여부 |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량(품목전환) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_mng_ymd | varchar(8) | Y | | 예상 입고/제조일자 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | if_idx | varchar(20) | Y | | IF 내부 순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **rp_prod_sts_cd** (`RP_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 33 | 지정 |
> | 55 | 처리 |
> | 77 | 처리 |

> **st_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 기준품목 |
> | N | 대상품목 |

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
| wms_inven_rp_prod_PK | rp_prod_seq, rp_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| rp_prod_seq | wms_inven_rp_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| rp_seq | wms_inven_rp | rp_seq | wms_inven_rp_TO_wms_inven_rp_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_rp_tran | rp_prod_seq, rp_seq | wms_inven_rp_prod_TO_wms_inven_rp_tran |

---

## 7. 업무 규칙

### 7.1 품목전환 품목 등록
- 품목전환 헤더(`wms_inven_rp`) 등록 시 함께 생성
- 하나의 품목전환 헤더에 여러 품목 등록 가능
- 반드시 하나의 기준품목(`st_yn = 'Y'`)과 하나 이상의 대상품목(`st_yn = 'N'`)이 존재해야 함

### 7.2 기준품목과 대상품목

#### 7.2.1 기준품목 (st_yn = 'Y')
- 전환의 기준이 되는 품목
- 전환 작업 시 재고가 감소하는 품목
- 하나의 전환 건에 하나만 존재 가능

#### 7.2.2 대상품목 (st_yn = 'N')
- 전환 결과로 생성되는 품목
- 전환 작업 시 재고가 증가하는 품목
- 하나의 전환 건에 여러 개 존재 가능

### 7.3 전환 비율
- 기준품목과 대상품목 간의 전환 비율은 `mdm_rp_prod` 마스터 데이터에 정의
- `wms_inven_rp_prod.req_qty`는 실제 전환 요청 수량
- 대상품목의 요청 수량은 기준품목 수량 × 전환 비율로 자동 계산 가능

### 7.4 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 33 | 지정 | 재고 위치 지정 완료 |
| 55 | 처리 | 전환 작업 진행 중 |
| 77 | 처리 | 전환 완료 |

> 참고: `RP_PROD_STS_CD`는 55와 77이 모두 '처리'로 표기되어 있으나, 실제로는 '처리중'과 '처리완료'로 구분하여 사용

### 7.5 예상 속성 정보
- 품목전환 접수 단계에서 예상 정보 입력 가능
- `est_exp_ymd` : 예상 유통기한
- `est_mng_ymd` : 예상 제조일자/입고일자
- `est_lot_no` : 예상 LOT 번호
- 실제 처리 시(`wms_inven_rp_tran`)에는 확정된 값으로 대체

### 7.6 기준품목 속성 vs 대상품목 속성

| 항목 | 기준품목 | 대상품목 |
|------|---------|---------|
| 재고 변동 | 감소 | 증가 |
| 예상 정보 | 출고될 재고의 속성 | 입고될 재고의 속성 |
| 위치 지정 | 출고 위치(FR) 필요 | 입고 위치(TO) 필요 |
| SKU | 기존 SKU 사용 | 새 SKU 생성 또는 지정 |

### 7.7 수량 관리
- 기준품목의 `req_qty` : 전환할 기준품목 수량
- 대상품목의 `req_qty` : 전환 후 생성될 대상품목 수량
- 대상품목 `req_qty`의 합계 = 기준품목 `req_qty` × 전환 비율 총합

### 7.8 재고 지정
- 기준품목은 출고할 재고의 위치/SKU를 지정해야 함
- 대상품목은 입고될 위치/SKU를 지정해야 함
- `rp_sts_cd = '33'(지정)` 단계에서 `wms_inven_rp_tran`을 통해 실제 재고 연결

### 7.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 품목전환 품목 정보 송신 여부
- 품목별 송신 상태 관리 (헤더와 별도)
- `if_idx` : 외부 시스템에서의 순번/인덱스
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 7.10 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 헤더 삭제 시 하위 품목도 일괄 논리삭제 처리 필요
- 삭제된 품목은 처리 이력에서 제외

### 7.11 처리 이력 연동
- `wms_inven_rp_tran`에서 실제 처리 내역 관리
- 기준품목과 대상품목 각각에 대해 처리 이력 생성
- 처리 완료 시 `rp_prod_sts_cd`를 '77'로 변경

### 7.12 전환 관계 검증
- 동일 전환 건 내 기준품목 중복 불가
- 대상품목은 여러 기준품목에 속할 수 없음
- 전환 비율이 정의되지 않은 품목 조합은 전환 불가

---

## 8. 주요 조회 예시

```sql
-- 품목전환별 품목 목록 조회
SELECT rp.rp_prod_seq, rp.prod_seq, p.prod_nm, p.prod_no,
       rp.st_yn,
       CASE WHEN rp.st_yn = 'Y' THEN '기준품목' ELSE '대상품목' END AS prod_type,
       rp.req_qty,
       rp.rp_prod_sts_cd,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_inven_rp_prod rp
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE rp.rp_seq = 1001
AND rp.del_yn = 'N'
ORDER BY rp.st_yn DESC, rp.prod_seq;

-- 기준품목별 대상품목 목록 조회
SELECT
    base.rp_prod_seq AS base_rp_prod_seq,
    base.prod_seq AS base_prod_seq,
    base_p.prod_nm AS base_prod_nm,
    base.req_qty AS base_qty,
    target.rp_prod_seq AS target_rp_prod_seq,
    target.prod_seq AS target_prod_seq,
    target_p.prod_nm AS target_prod_nm,
    target.req_qty AS target_qty,
    ROUND(target.req_qty / NULLIF(base.req_qty, 0), 2) AS conversion_rate
FROM wms_inven_rp_prod base
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
    JOIN wms_inven_rp_prod target ON base.rp_seq = target.rp_seq
    JOIN mdm_prod target_p ON target.prod_seq = target_p.prod_seq
WHERE base.rp_seq = 1001
AND base.st_yn = 'Y'
AND target.st_yn = 'N'
AND base.del_yn = 'N'
AND target.del_yn = 'N'
ORDER BY target.rp_prod_seq;

-- 미처리 품목전환 품목 조회 (지정/처리중)
SELECT r.rp_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.st_yn,
       CASE WHEN rp.st_yn = 'Y' THEN '기준품목' ELSE '대상품목' END AS prod_type,
       rp.req_qty,
       rp.rp_prod_sts_cd,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.rp_prod_sts_cd IN ('33', '55')
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd, r.rp_no, rp.st_yn DESC;

-- 품목별 기준품목 현황 (해당 품목이 기준품목으로 사용된 경우)
SELECT r.rp_no, r.req_ymd, r.rp_sts_cd,
       rp.prod_seq, p.prod_nm,
       rp.req_qty,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE rp.prod_seq = 1001
AND rp.st_yn = 'Y'
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd DESC;

-- 품목별 대상품목 현황 (해당 품목이 대상품목으로 전환된 경우)
SELECT r.rp_no, r.req_ymd, r.rp_sts_cd,
       base.prod_seq AS base_prod_seq,
       base_p.prod_nm AS base_prod_nm,
       rp.prod_seq, p.prod_nm,
       rp.req_qty,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    JOIN wms_inven_rp_prod base ON r.rp_seq = base.rp_seq AND base.st_yn = 'Y'
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
WHERE rp.prod_seq = 2002
AND rp.st_yn = 'N'
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd DESC;

-- IF 송신 대기 품목 조회
SELECT r.rp_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.st_yn, rp.req_qty,
       rp.if_idx
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND rp.if_send_yn = 'N'
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY rp.reg_dt;

-- 예상 유통기한 정보가 있는 품목 조회
SELECT r.rp_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.st_yn, rp.req_qty,
       rp.est_exp_ymd, rp.est_mng_ymd, rp.est_lot_no
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND (rp.est_exp_ymd IS NOT NULL OR rp.est_mng_ymd IS NOT NULL OR rp.est_lot_no IS NOT NULL)
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd;

-- 전환 작업별 품목 수량 통계
SELECT r.rp_no,
       COUNT(CASE WHEN rp.st_yn = 'Y' THEN 1 END) AS base_cnt,
       COUNT(CASE WHEN rp.st_yn = 'N' THEN 1 END) AS target_cnt,
       SUM(CASE WHEN rp.st_yn = 'Y' THEN rp.req_qty ELSE 0 END) AS total_base_qty,
       SUM(CASE WHEN rp.st_yn = 'N' THEN rp.req_qty ELSE 0 END) AS total_target_qty
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND r.req_ymd = '20250226'
AND rp.del_yn = 'N'
GROUP BY r.rp_no
ORDER BY r.rp_no;

-- 처리 이력이 없는 미완료 품목
SELECT r.rp_no, r.req_ymd,
       rp.prod_seq, p.prod_nm,
       rp.st_yn, rp.req_qty,
       rp.rp_prod_sts_cd
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_rp_tran rt ON rp.rp_prod_seq = rt.rp_prod_seq
        AND rt.del_yn = 'N'
WHERE r.biz_seq = 1
AND rp.rp_prod_sts_cd != '77'
AND rt.rp_tran_seq IS NULL
AND rp.del_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd;

-- 일자별 품목전환 품목 현황
SELECT r.req_ymd,
       COUNT(rp.rp_prod_seq) AS total_prod_cnt,
       COUNT(CASE WHEN rp.st_yn = 'Y' THEN 1 END) AS base_prod_cnt,
       COUNT(CASE WHEN rp.st_yn = 'N' THEN 1 END) AS target_prod_cnt,
       SUM(CASE WHEN rp.st_yn = 'Y' THEN rp.req_qty ELSE 0 END) AS total_base_qty,
       SUM(CASE WHEN rp.st_yn = 'N' THEN rp.req_qty ELSE 0 END) AS total_target_qty
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
WHERE r.biz_seq = 1
AND r.req_ymd BETWEEN '20250201' AND '20250228'
AND rp.del_yn = 'N'
GROUP BY r.req_ymd
ORDER BY r.req_ymd;
```