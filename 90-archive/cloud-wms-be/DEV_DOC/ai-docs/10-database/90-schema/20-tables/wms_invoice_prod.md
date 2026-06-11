# wms_invoice_prod (WMS_송장품목)

## 1. 개요
`wms_invoice`(송장)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
송장에 포함된 품목별로 수량 정보를 저장하며, 출하 품목(`wms_outbiz_prod`)과 연결된다.

### 1.1 송장품목 처리 흐름
```
wms_invoice (송장 헤더)
└─ wms_invoice_prod (송장 품목) ← **현재 테이블**
        └─ wms_invoice_tran (송장 처리 이력)
              ↑
wms_outbiz_prod (출하 품목)
└─ wms_outbiz_invoice (출하-송장 연결)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | invoice_prod_seq | bigint | N | nextval('wms_invoice_prod_seq') | 송장품목 SEQ |
| FK | invoice_seq | integer | N | | 송장 SEQ → wms_invoice |
| | parent_invoice_prod_seq | bigint | Y | | 부모 송장품목 SEQ (합포장 시) |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | invoice_prod_nm | varchar(100) | Y | | 송장 품목명 (출하시점 품목명 저장) |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

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
| wms_invoice_prod_PK | invoice_prod_seq, invoice_seq | Y | Y |
| IX_wms_invoice_prod_prod | prod_seq | N | |
| IX_wms_invoice_prod_parent | parent_invoice_prod_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| invoice_prod_seq | wms_invoice_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| invoice_seq | wms_invoice | invoice_seq | wms_invoice_TO_wms_invoice_prod |
| parent_invoice_prod_seq | wms_invoice_prod | invoice_prod_seq | wms_invoice_prod_TO_wms_invoice_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_invoice_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_invoice_tran | invoice_prod_seq, invoice_seq | wms_invoice_prod_TO_wms_invoice_tran |
| wms_outbiz_invoice | invoice_prod_seq, invoice_seq | wms_outbiz_invoice |

---

## 7. 업무 규칙

### 7.1 송장품목 생성
- 송장출하(OB03) 등록 시 `wms_outbiz_prod` 정보를 기반으로 생성
- 또는 별도 송장 발행 프로세스에서 `wms_outbiz_invoice` 연결 후 생성
- `invoice_prod_nm` : 출하 시점의 품목명을 저장 (이후 품목명 변경 영향 방지)

### 7.2 송장 유형별 처리

#### 7.2.1 단포장(S)
- 하나의 `wms_outbiz_prod`가 하나의 `wms_invoice_prod`로 생성
- `parent_invoice_prod_seq` = NULL

#### 7.2.2 합포장(M)
- 여러 `wms_outbiz_prod`가 하나의 `wms_invoice_prod`로 통합
- 부모-자식 관계 설정
- 부모 품목: 실제 송장에 표시될 품목 정보
- 자식 품목: `parent_invoice_prod_seq`에 부모 SEQ 저장
- 합포장 시 수량은 부모 품목에 집계

### 7.3 수량 관리
- `req_qty` : 송장에 기재된 요청 수량
- `ex_qty` : 실제 처리(출고)된 수량
- 일반적으로 `req_qty` = `ex_qty` (송장 발행 후 출고 처리)

### 7.4 송장품목 상태
- 별도 상태 코드 없이 송장 헤더(`wms_invoice.invoice_sts_cd`)로 일괄 관리
- 송장 상태가 확정('77')되면 해당 송장의 모든 품목도 확정으로 간주

### 7.5 품목명 저장
- `invoice_prod_nm` : 송장 발행 시점의 품목명 저장
- 이후 `mdm_prod`의 품목명이 변경되어도 송장 출력 시 과거 품목명 유지 가능

### 7.6 취소/삭제
- 송장 확정('77') 후에는 품목 정보 변경 불가
- 송장 취소('99') 시 품목 정보는 그대로 유지 (이력 보존)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 송장별 품목 현황
SELECT iv.invoice_no, iv.invoice_sts_cd,
       ip.invoice_prod_seq, ip.prod_seq,
       p.prod_nm, ip.invoice_prod_nm,
       ip.req_qty, ip.ex_qty
FROM wms_invoice_prod ip
    JOIN wms_invoice iv ON ip.invoice_seq = iv.invoice_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND iv.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND ip.del_yn = 'N'
ORDER BY iv.invoice_no, ip.invoice_prod_seq;

-- 특정 송장의 품목 상세
SELECT ip.invoice_prod_seq,
       p.prod_no, p.prod_nm AS current_prod_nm,
       ip.invoice_prod_nm AS invoice_prod_nm,
       ip.req_qty, ip.ex_qty,
       ob.outbiz_no
FROM wms_invoice_prod ip
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
    LEFT JOIN wms_outbiz_invoice obi ON ip.invoice_seq = obi.invoice_seq 
        AND ip.invoice_prod_seq = obi.invoice_prod_seq
    LEFT JOIN wms_outbiz ob ON obi.outbiz_seq = ob.outbiz_seq
WHERE ip.invoice_seq = 100
AND ip.del_yn = 'N'
ORDER BY ip.invoice_prod_seq;

-- 합포장 관계 조회 (부모-자식)
SELECT p.invoice_prod_seq AS parent_prod_seq,
       p.prod_seq AS parent_prod,
       p.req_qty AS parent_qty,
       c.invoice_prod_seq AS child_prod_seq,
       c.prod_seq AS child_prod,
       c.req_qty AS child_qty
FROM wms_invoice_prod p
    JOIN wms_invoice_prod c ON p.invoice_prod_seq = c.parent_invoice_prod_seq
WHERE p.invoice_seq = 100
AND p.del_yn = 'N'
AND c.del_yn = 'N'
ORDER BY p.invoice_prod_seq, c.invoice_prod_seq;

-- 출하품목과 송장품목 연결 조회
SELECT ob.outbiz_no, ob.rcv_nm,
       op.prod_seq, op.req_qty AS outbiz_req_qty,
       iv.invoice_no,
       ip.invoice_prod_seq, ip.req_qty AS invoice_req_qty,
       ip.invoice_prod_nm
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    JOIN wms_outbiz_invoice obi ON op.outbiz_prod_seq = obi.outbiz_prod_seq
    JOIN wms_invoice_prod ip ON obi.invoice_prod_seq = ip.invoice_prod_seq
    JOIN wms_invoice iv ON ip.invoice_seq = iv.invoice_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND op.del_yn = 'N'
AND ip.del_yn = 'N';

-- 품목별 송장 발행 현황
SELECT p.prod_nm,
       COUNT(DISTINCT ip.invoice_prod_seq) AS invoice_prod_cnt,
       COUNT(DISTINCT iv.invoice_seq) AS invoice_cnt,
       SUM(ip.req_qty) AS total_qty
FROM wms_invoice_prod ip
    JOIN wms_invoice iv ON ip.invoice_seq = iv.invoice_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND iv.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ip.del_yn = 'N'
AND iv.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_qty DESC;

-- 품목명 변경 이력 추적 (송장 발행 시점 품목명 vs 현재 품목명)
SELECT ip.invoice_prod_seq,
       p.prod_nm AS current_prod_nm,
       ip.invoice_prod_nm AS past_prod_nm,
       iv.invoice_no, iv.reg_dt AS invoice_date,
       CASE WHEN p.prod_nm != ip.invoice_prod_nm 
            THEN '변경됨' 
            ELSE '동일' 
       END AS name_status
FROM wms_invoice_prod ip
    JOIN wms_invoice iv ON ip.invoice_seq = iv.invoice_seq
    JOIN mdm_prod p ON ip.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND p.prod_nm != ip.invoice_prod_nm
AND ip.del_yn = 'N'
AND iv.del_yn = 'N'
ORDER BY iv.reg_dt DESC;
```