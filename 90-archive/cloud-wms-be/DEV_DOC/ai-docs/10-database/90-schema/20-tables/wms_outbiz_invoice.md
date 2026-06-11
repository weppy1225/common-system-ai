# wms_outbiz_invoice (WMS_출하송장연결)

## 1. 개요
**출하(`wms_outbiz`)와 송장(`wms_invoice`) 간의 연결 정보**를 관리하는 매핑 테이블.
송장출하(OB03) 유형에서 사용되며, 출하 품목과 송장 품목 간의 관계를 정의한다.

### 1.1 출하-송장 연결 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_invoice (출하-송장 연결) ← **현재 테이블**
              ├─ wms_invoice (송장 헤더)
              └─ wms_invoice_prod (송장 품목)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outbiz_seq | integer | N | | 출하 SEQ → wms_outbiz |
| PK | outbiz_prod_seq | bigint | N | | 출하품목 SEQ → wms_outbiz_prod |
| PK | invoice_seq | integer | N | | 송장 SEQ → wms_invoice |
| PK | invoice_prod_seq | bigint | N | | 송장품목 SEQ → wms_invoice_prod |
| | outbiz_req_qty | decimal(10,2) | N | 0 | 출하 요청 수량 |
| | outbiz_ex_qty | decimal(10,2) | N | 0 | 출하 처리 수량 |
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
| wms_outbiz_invoice_PK | outbiz_seq, outbiz_prod_seq, invoice_seq, invoice_prod_seq | Y | Y |
| IX_wms_outbiz_invoice_outbiz | outbiz_seq, outbiz_prod_seq | N | |
| IX_wms_outbiz_invoice_invoice | invoice_seq, invoice_prod_seq | N | |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_invoice |
| invoice_seq, invoice_prod_seq | wms_invoice_prod | invoice_seq, invoice_prod_seq | wms_invoice_prod_TO_wms_outbiz_invoice |

---

## 5. 업무 규칙

### 5.1 연결 생성 조건
- 송장출하(OB03) 등록 시 자동 생성
- 또는 송장 발행 시 출하 정보와 연결하여 생성

### 5.2 연결 관계
- **1:1 관계** : 하나의 출하품목이 하나의 송장품목과 연결 (단포장)
- **N:1 관계** : 여러 출하품목이 하나의 송장품목과 연결 (합포장)
- **1:N 관계** : 하나의 출하품목이 여러 송장품목과 연결 (부분 송장 발행)

### 5.3 수량 관리
- `outbiz_req_qty` : 출하 요청 수량 (출하품목의 `req_qty`와 동일)
- `outbiz_ex_qty` : 출하 처리된 수량 (송장 발행/처리된 수량)
- 송장 품목의 `req_qty`와 `ex_qty`와 연동

### 5.4 송장 유형별 처리

#### 5.4.1 단포장(S)
- 하나의 출하품목 → 하나의 송장품목
- `outbiz_req_qty` = 송장품목의 `req_qty`

#### 5.4.2 합포장(M)
- 여러 출하품목 → 하나의 송장품목 (부모)
- 각 출하품목의 수량이 합산되어 송장품목 수량 결정
- `parent_invoice_prod_seq`로 부모-자식 관계 설정

### 5.5 상태 동기화
- 출하 상태와 송장 상태는 별도 관리
- 송장 확정(`invoice_sts_cd` = '77') 시 출하 처리 진행 가능
- 출하 처리 완료 시 송장도 함께 확정 처리

### 5.6 취소/삭제
- 출하 또는 송장이 취소(`'99'`)되면 연결 정보는 유지 (이력 보존)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 6. 주요 조회 예시

```sql
-- 출하별 연결된 송장 정보
SELECT ob.outbiz_no, ob.rcv_nm,
       iv.invoice_no, iv.invoice_sts_cd,
       obi.outbiz_req_qty, obi.outbiz_ex_qty,
       p.prod_nm
FROM wms_outbiz_invoice obi
    JOIN wms_outbiz ob ON obi.outbiz_seq = ob.outbiz_seq
    JOIN wms_invoice iv ON obi.invoice_seq = iv.invoice_seq
    JOIN wms_outbiz_prod op ON obi.outbiz_prod_seq = op.outbiz_prod_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND obi.del_yn = 'N'
ORDER BY obi.invoice_prod_seq;

-- 송장별 연결된 출하 정보
SELECT iv.invoice_no,
       ob.outbiz_no, ob.rcv_nm,
       obi.outbiz_req_qty, obi.outbiz_ex_qty,
       p.prod_nm
FROM wms_outbiz_invoice obi
    JOIN wms_invoice iv ON obi.invoice_seq = iv.invoice_seq
    JOIN wms_outbiz ob ON obi.outbiz_seq = ob.outbiz_seq
    JOIN wms_outbiz_prod op ON obi.outbiz_prod_seq = op.outbiz_prod_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE iv.biz_seq = 1
AND iv.invoice_no = 'INV20250226-001'
AND obi.del_yn = 'N'
ORDER BY obi.outbiz_prod_seq;

-- 합포장 관계 조회 (여러 출하가 하나의 송장으로)
SELECT iv.invoice_no,
       COUNT(DISTINCT obi.outbiz_seq) AS outbiz_cnt,
       COUNT(DISTINCT obi.outbiz_prod_seq) AS outbiz_prod_cnt,
       SUM(obi.outbiz_req_qty) AS total_req_qty,
       SUM(obi.outbiz_ex_qty) AS total_ex_qty
FROM wms_outbiz_invoice obi
    JOIN wms_invoice iv ON obi.invoice_seq = iv.invoice_seq
WHERE iv.biz_seq = 1
AND iv.invoice_pack_cd = 'M' -- 합포장
AND iv.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obi.del_yn = 'N'
GROUP BY iv.invoice_no
ORDER BY iv.reg_dt DESC;

-- 미처리 연결 건 (출하 미완료)
SELECT obi.outbiz_seq, ob.outbiz_no,
       obi.invoice_seq, iv.invoice_no,
       obi.outbiz_req_qty, obi.outbiz_ex_qty,
       (obi.outbiz_req_qty - obi.outbiz_ex_qty) AS remain_qty
FROM wms_outbiz_invoice obi
    JOIN wms_outbiz ob ON obi.outbiz_seq = ob.outbiz_seq
    JOIN wms_invoice iv ON obi.invoice_seq = iv.invoice_seq
WHERE ob.biz_seq = 1
AND obi.outbiz_ex_qty < obi.outbiz_req_qty
AND ob.outbiz_sts_cd NOT IN ('77', '99')
AND iv.invoice_sts_cd NOT IN ('77', '99')
AND obi.del_yn = 'N'
ORDER BY ob.req_ymd, ob.outbiz_no;

-- 출하품목과 송장품목 매핑 현황
SELECT op.outbiz_prod_seq, ob.outbiz_no,
       ip.invoice_prod_seq, iv.invoice_no,
       op.req_qty AS outbiz_qty,
       ip.req_qty AS invoice_qty,
       obi.outbiz_ex_qty AS mapped_qty
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    LEFT JOIN wms_outbiz_invoice obi ON op.outbiz_prod_seq = obi.outbiz_prod_seq
    LEFT JOIN wms_invoice_prod ip ON obi.invoice_prod_seq = ip.invoice_prod_seq
    LEFT JOIN wms_invoice iv ON ip.invoice_seq = iv.invoice_seq
WHERE ob.biz_seq = 1
AND ob.req_ymd = '20250226'
AND op.del_yn = 'N'
ORDER BY ob.outbiz_no, op.outbiz_prod_seq;

-- 연결 정보 통계
SELECT
    COUNT(*) AS total_connection_cnt,
    SUM(CASE WHEN outbiz_ex_qty >= outbiz_req_qty THEN 1 ELSE 0 END) AS completed_cnt,
    ROUND(SUM(CASE WHEN outbiz_ex_qty >= outbiz_req_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_outbiz_invoice
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N';
```