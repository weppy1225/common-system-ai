# wms_outbiz_load (WMS_출하상차연결)

## 1. 개요
**출하(`wms_outbiz`)와 상차(`wms_load`) 간의 연결 정보**를 관리하는 매핑 테이블.
상차출하(OB05) 유형에서 사용되며, 출하 품목과 상차 품목 간의 관계를 정의한다.

### 1.1 출하-상차 연결 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_load (출하-상차 연결) ← **현재 테이블**
              ├─ wms_load (상차 헤더)
              └─ wms_load_prod (상차 품목)
                    └─ wms_load_tran (상차 처리 이력)
                          ↓
                    wms_outbiz_tran (출하 처리 이력) 생성
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | load_seq | integer | N | | 상차 SEQ → wms_load |
| PK | load_prod_seq | bigint | N | | 상차품목 SEQ → wms_load_prod |
| PK | outbiz_seq | integer | N | | 출하 SEQ → wms_outbiz |
| PK | outbiz_prod_seq | bigint | N | | 출하품목 SEQ → wms_outbiz_prod |
| | load_qty | decimal(10,2) | N | 0 | 상차 수량 |
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
| wms_outbiz_load_PK | load_seq, load_prod_seq, outbiz_seq, outbiz_prod_seq | Y | Y |
| IX_wms_outbiz_load_outbiz | outbiz_seq, outbiz_prod_seq | N | |
| IX_wms_outbiz_load_load | load_seq, load_prod_seq | N | |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| load_seq, load_prod_seq | wms_load_prod | load_seq, load_prod_seq | wms_load_prod_TO_wms_outbiz_load |
| outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_load |

---

## 5. 업무 규칙

### 5.1 연결 생성 조건
- 상차출하(OB05) 등록 시 자동 생성
- 또는 상차 계획 수립 시 출하 정보와 연결하여 생성

### 5.2 연결 관계
- **1:1 관계** : 하나의 출하품목이 하나의 상차품목과 연결 (일반적인 경우)
- **N:1 관계** : 여러 출하품목이 하나의 상차품목과 연결 (통합 상차)
- **1:N 관계** : 하나의 출하품목이 여러 상차품목과 연결 (분할 상차)

### 5.3 수량 관리
- `load_qty` : 실제 상차된 수량
- 출하품목의 `req_qty`와 상차품목의 `req_qty`는 동일해야 함
- 상차 처리 시 `load_qty`만큼 출하 처리 진행

### 5.4 상차 유형별 처리

#### 5.4.1 단일 상차
- 하나의 출하가 하나의 상차로 처리
- 출하품목과 상차품목이 1:1로 매핑

#### 5.4.2 통합 상차
- 여러 출하를 하나의 차량에 함께 상차
- 여러 출하품목이 하나의 상차품목으로 통합
- `load_qty`는 각 출하품목 수량의 합계

#### 5.4.3 분할 상차
- 하나의 출하를 여러 차량에 나누어 상차
- 하나의 출하품목이 여러 상차품목으로 분할
- 각 상차품목의 `load_qty` 합계 = 출하품목 `req_qty`

### 5.5 상태 동기화
- 상차 처리(`wms_load_tran`) 시 연결된 출하 처리(`wms_outbiz_tran`) 생성
- 상차 확정(`load_sts_cd` = '77') 시 출하도 함께 확정 처리 가능

### 5.6 수량 정합성
- 출하품목의 `req_qty` = 연결된 모든 상차품목의 `load_qty` 합계
- 상차품목의 `req_qty` = 연결된 모든 출하품목의 `load_qty` 합계
- 상차 처리 후 `ex_qty` 업데이트 시 정합성 검증 필요

### 5.7 취소/삭제
- 상차 또는 출하가 취소(`'99'`)되면 연결 정보는 유지 (이력 보존)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 6. 주요 조회 예시

```sql
-- 출하별 연결된 상차 정보
SELECT ob.outbiz_no, ob.rcv_nm,
       ld.load_no, ld.load_sts_cd,
       obl.load_qty,
       p.prod_nm
FROM wms_outbiz_load obl
    JOIN wms_outbiz ob ON obl.outbiz_seq = ob.outbiz_seq
    JOIN wms_load ld ON obl.load_seq = ld.load_seq
    JOIN wms_outbiz_prod op ON obl.outbiz_prod_seq = op.outbiz_prod_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND obl.del_yn = 'N'
ORDER BY obl.load_prod_seq;

-- 상차별 연결된 출하 정보
SELECT ld.load_no, ld.load_sts_cd,
       ob.outbiz_no, ob.rcv_nm,
       obl.load_qty,
       p.prod_nm
FROM wms_outbiz_load obl
    JOIN wms_load ld ON obl.load_seq = ld.load_seq
    JOIN wms_outbiz ob ON obl.outbiz_seq = ob.outbiz_seq
    JOIN wms_outbiz_prod op ON obl.outbiz_prod_seq = op.outbiz_prod_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND ld.load_no = 'LOAD2502260001'
AND obl.del_yn = 'N'
ORDER BY obl.outbiz_prod_seq;

-- 통합 상차 현황 (하나의 상차에 여러 출하)
SELECT ld.load_no,
       COUNT(DISTINCT obl.outbiz_seq) AS outbiz_cnt,
       COUNT(DISTINCT obl.outbiz_prod_seq) AS outbiz_prod_cnt,
       SUM(obl.load_qty) AS total_load_qty,
       ld.load_sts_cd
FROM wms_outbiz_load obl
    JOIN wms_load ld ON obl.load_seq = ld.load_seq
WHERE ld.biz_seq = 1
AND ld.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obl.del_yn = 'N'
GROUP BY ld.load_no, ld.load_sts_cd
HAVING COUNT(DISTINCT obl.outbiz_seq) > 1
ORDER BY ld.reg_dt DESC;

-- 분할 상차 현황 (하나의 출하가 여러 상차로)
SELECT ob.outbiz_no,
       COUNT(DISTINCT obl.load_seq) AS load_cnt,
       COUNT(DISTINCT obl.load_prod_seq) AS load_prod_cnt,
       SUM(obl.load_qty) AS total_load_qty,
       ob.outbiz_sts_cd
FROM wms_outbiz_load obl
    JOIN wms_outbiz ob ON obl.outbiz_seq = ob.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obl.del_yn = 'N'
GROUP BY ob.outbiz_no, ob.outbiz_sts_cd
HAVING COUNT(DISTINCT obl.load_seq) > 1
ORDER BY ob.reg_dt DESC;

-- 미처리 연결 건 (상차 미완료)
SELECT obl.outbiz_seq, ob.outbiz_no,
       obl.load_seq, ld.load_no,
       obl.load_qty,
       lp.req_qty, lp.ex_qty,
       (lp.req_qty - lp.ex_qty) AS remain_qty
FROM wms_outbiz_load obl
    JOIN wms_outbiz ob ON obl.outbiz_seq = ob.outbiz_seq
    JOIN wms_load ld ON obl.load_seq = ld.load_seq
    JOIN wms_load_prod lp ON obl.load_prod_seq = lp.load_prod_seq
WHERE ob.biz_seq = 1
AND lp.ex_qty < lp.req_qty
AND ld.load_sts_cd NOT IN ('77', '99')
AND ob.outbiz_sts_cd NOT IN ('77', '99')
AND obl.del_yn = 'N'
ORDER BY ob.req_ymd, ob.outbiz_no;

-- 출하품목과 상차품목 매핑 현황
SELECT op.outbiz_prod_seq, ob.outbiz_no,
       lp.load_prod_seq, ld.load_no,
       op.req_qty AS outbiz_qty,
       lp.req_qty AS load_qty,
       obl.load_qty AS mapped_qty
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    LEFT JOIN wms_outbiz_load obl ON op.outbiz_prod_seq = obl.outbiz_prod_seq
    LEFT JOIN wms_load_prod lp ON obl.load_prod_seq = lp.load_prod_seq
    LEFT JOIN wms_load ld ON lp.load_seq = ld.load_seq
WHERE ob.biz_seq = 1
AND ob.req_ymd = '20250226'
AND op.del_yn = 'N'
ORDER BY ob.outbiz_no, op.outbiz_prod_seq;

-- 수량 정합성 검증 (출하품목 vs 연결된 상차품목 합계)
SELECT
    op.outbiz_prod_seq,
    op.req_qty AS outbiz_req_qty,
    SUM(obl.load_qty) AS total_mapped_load_qty,
    CASE 
        WHEN op.req_qty = SUM(obl.load_qty) THEN '정상'
        ELSE '불일치'
    END AS status
FROM wms_outbiz_prod op
    LEFT JOIN wms_outbiz_load obl ON op.outbiz_prod_seq = obl.outbiz_prod_seq
WHERE op.biz_seq = 1
AND op.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND op.del_yn = 'N'
AND obl.del_yn = 'N'
GROUP BY op.outbiz_prod_seq, op.req_qty
HAVING op.req_qty != COALESCE(SUM(obl.load_qty), 0);

-- 연결 정보 통계
SELECT
    COUNT(*) AS total_connection_cnt,
    COUNT(DISTINCT outbiz_seq) AS outbiz_cnt,
    COUNT(DISTINCT load_seq) AS load_cnt,
    SUM(load_qty) AS total_qty,
    AVG(load_qty) AS avg_qty
FROM wms_outbiz_load
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N';
```