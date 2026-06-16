# wms_inbiz_inwh (WMS_입하입고연결)

## 1. 개요
**입하(`wms_inbiz`)와 입고(`wms_inwh`) 간의 연결 정보**를 관리하는 매핑 테이블.
구매발주(입하) 정보가 실제 입고 작업으로 이어질 때 두 정보 간의 관계를 정의한다.

### 1.1 입하-입고 연결 흐름
```
wms_inbiz (입하 헤더)
└─ wms_inbiz_prod (입하 품목)
        └─ wms_inbiz_inwh (입하-입고 연결) ← **현재 테이블**
              ├─ wms_inwh (입고 헤더)
              └─ wms_inwh_prod (입고 품목)
                    └─ wms_inwh_tran (입고 처리 이력) → 재고 증가
                          └─ wms_inwh_label (입고 라벨) - 선발행 라벨
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| | inbiz_seq | integer | Y | | 입하 SEQ → wms_inbiz |
| | inbiz_prod_seq | bigint | Y | | 입하품목 SEQ → wms_inbiz_prod |
| | inwh_seq | integer | Y | | 입고 SEQ → wms_inwh |
| | inwh_prod_seq | bigint | Y | | 입고품목 SEQ → wms_inwh_prod |
| | req_qty | decimal(10,2) | Y | 0 | 요청 수량 |
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
| (PK 없음 - 복합 인덱스 활용) | | | |
| IX_wms_inbiz_inwh_inbiz | inbiz_seq, inbiz_prod_seq | N | |
| IX_wms_inbiz_inwh_inwh | inwh_seq, inwh_prod_seq | N | |

> **참고**: 별도의 PK 컬럼 없이 복합 인덱스로 구성

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| inbiz_seq, inbiz_prod_seq | wms_inbiz_prod | inbiz_seq, inbiz_prod_seq | wms_inbiz_prod_TO_wms_inbiz_inwh |
| inwh_seq, inwh_prod_seq | wms_inwh_prod | inwh_seq, inwh_prod_seq | wms_inwh_prod_TO_wms_inbiz_inwh |

---

## 5. 업무 규칙

### 5.1 연결 생성 조건
- 입하 정보를 기반으로 입고 생성 시 자동 연결
- 또는 기존 입고에 입하를 연결할 때 수동 생성
- 입하품목과 입고품목 간의 매핑 정보 저장

### 5.2 연결 관계
- **1:1 관계** : 하나의 입하품목이 하나의 입고품목과 연결 (일반적인 경우)
- **1:N 관계** : 하나의 입하품목이 여러 입고품목으로 분할 (분할 입고)
- **N:1 관계** : 여러 입하품목이 하나의 입고품목으로 통합 (입하 통합 처리)

### 5.3 수량 관리
- `req_qty` : 입고 요청 수량 (입하품목 기준)
- 입하품목의 `req_qty` = 연결된 모든 입고품목의 `req_qty` 합계
- 입고품목의 `req_qty` = 연결된 모든 입하품목의 `req_qty` 합계

### 5.4 상태 동기화
- 입고 처리(`wms_inwh_tran`) 시 연결된 입하의 상태도 간접적으로 관리
- 입고 확정(`inwh_sts_cd` = '77') 시 입하 상태도 완료 처리 가능

### 5.5 처리 흐름

#### 5.5.1 입하 등록 (ERP 연동)
- 외부 시스템에서 입하 정보 수신 시 `wms_inbiz`, `wms_inbiz_prod` 등록

#### 5.5.2 입고 생성
- 입하 정보를 기반으로 `wms_inwh`, `wms_inwh_prod` 생성
- `wms_inbiz_inwh`에 연결 정보 저장

#### 5.5.3 라벨 발행
- `wms_inwh_label`에 입고 라벨 선발행
- `wms_inwh_prod`의 라벨발행여부(`pub_sku1_yn`, `pub_sku2_yn`) 갱신

#### 5.5.4 입고 처리
- 라벨 스캔 → `wms_inwh_tran` 생성
- `wms_inwh_prod`의 `ex_qty` 증가 및 상태 변경
- `wms_inwh` 헤더 상태 변경
- 재고(`wms_inven`) 증가

### 5.6 수량 정합성
- 입하품목의 `req_qty` = 연결된 모든 입고품목의 `req_qty` 합계
- 입고품목의 `req_qty` = 연결된 모든 입하품목의 `req_qty` 합계
- 입고 처리 후 `ex_qty` 업데이트 시 정합성 검증 필요

### 5.7 부분 입고
- 하나의 입하품목에 대해 여러 번에 나누어 입고 가능
- 각 입고 건마다 별도 연결 정보 생성
- 입하품목의 `ex_qty` 누적 관리로 잔여 수량 추적

### 5.8 취소/삭제
- 입고 또는 입하가 취소되면 연결 정보는 유지 (이력 보존)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 6. 주요 조회 예시

```sql
-- 입하별 연결된 입고 정보
SELECT ib.inbiz_no, ib.po_no,
       iw.inwh_no, iw.inwh_sts_cd,
       ibi.req_qty,
       p.prod_nm
FROM wms_inbiz_inwh ibi
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
    JOIN wms_inwh iw ON ibi.inwh_seq = iw.inwh_seq
    JOIN wms_inbiz_prod ibp ON ibi.inbiz_prod_seq = ibp.inbiz_prod_seq
    JOIN mdm_prod p ON ibp.prod_seq = p.prod_seq
WHERE ib.biz_seq = 1
AND ib.inbiz_no = 'IB2502260001'
AND ibi.del_yn = 'N'
ORDER BY ibi.inwh_prod_seq;

-- 입고별 연결된 입하 정보
SELECT iw.inwh_no, iw.inwh_sts_cd,
       ib.inbiz_no, ib.po_no,
       ibi.req_qty,
       p.prod_nm
FROM wms_inbiz_inwh ibi
    JOIN wms_inwh iw ON ibi.inwh_seq = iw.inwh_seq
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
    JOIN wms_inwh_prod iwp ON ibi.inwh_prod_seq = iwp.inwh_prod_seq
    JOIN mdm_prod p ON iwp.prod_seq = p.prod_seq
WHERE iw.biz_seq = 1
AND iw.inwh_no = 'IW2502260001'
AND ibi.del_yn = 'N'
ORDER BY ibi.inbiz_prod_seq;

-- 분할 입고 현황 (하나의 입하가 여러 입고로)
SELECT ib.inbiz_no,
       COUNT(DISTINCT ibi.inwh_seq) AS inwh_cnt,
       COUNT(DISTINCT ibi.inwh_prod_seq) AS inwh_prod_cnt,
       SUM(ibi.req_qty) AS total_qty,
       ib.inbiz_sts_cd
FROM wms_inbiz_inwh ibi
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
WHERE ib.biz_seq = 1
AND ib.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND ibi.del_yn = 'N'
GROUP BY ib.inbiz_no, ib.inbiz_sts_cd
HAVING COUNT(DISTINCT ibi.inwh_seq) > 1
ORDER BY ib.reg_dt DESC;

-- 미완료 연결 건 (입고 미완료)
SELECT ibi.inbiz_seq, ib.inbiz_no,
       ibi.inwh_seq, iw.inwh_no,
       ibi.req_qty,
       iwp.req_qty AS inwh_req_qty,
       iwp.ex_qty AS inwh_ex_qty,
       (iwp.req_qty - iwp.ex_qty) AS remain_qty
FROM wms_inbiz_inwh ibi
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
    JOIN wms_inwh iw ON ibi.inwh_seq = iw.inwh_seq
    JOIN wms_inwh_prod iwp ON ibi.inwh_prod_seq = iwp.inwh_prod_seq
WHERE ib.biz_seq = 1
AND iwp.ex_qty < iwp.req_qty
AND iw.inwh_sts_cd NOT IN ('77', '99')
AND ib.inbiz_sts_cd NOT IN ('77', '99')
AND ibi.del_yn = 'N'
ORDER BY ib.req_ymd, ib.inbiz_no;

-- 입하품목과 입고품목 매핑 현황
SELECT ibp.inbiz_prod_seq, ib.inbiz_no,
       iwp.inwh_prod_seq, iw.inwh_no,
       ibp.req_qty AS inbiz_qty,
       iwp.req_qty AS inwh_qty,
       ibi.req_qty AS mapped_qty
FROM wms_inbiz_prod ibp
    JOIN wms_inbiz ib ON ibp.inbiz_seq = ib.inbiz_seq
    LEFT JOIN wms_inbiz_inwh ibi ON ibp.inbiz_prod_seq = ibi.inbiz_prod_seq
    LEFT JOIN wms_inwh_prod iwp ON ibi.inwh_prod_seq = iwp.inwh_prod_seq
    LEFT JOIN wms_inwh iw ON iwp.inwh_seq = iw.inwh_seq
WHERE ib.biz_seq = 1
AND ib.req_ymd = '20250226'
AND ibp.del_yn = 'N'
ORDER BY ib.inbiz_no, ibp.inbiz_prod_seq;

-- 수량 정합성 검증 (입하품목 vs 연결된 입고품목 합계)
SELECT
    ibp.inbiz_prod_seq,
    ibp.req_qty AS inbiz_req_qty,
    SUM(ibi.req_qty) AS total_mapped_qty,
    CASE 
        WHEN ibp.req_qty = SUM(ibi.req_qty) THEN '정상'
        ELSE '불일치'
    END AS status
FROM wms_inbiz_prod ibp
    LEFT JOIN wms_inbiz_inwh ibi ON ibp.inbiz_prod_seq = ibi.inbiz_prod_seq
WHERE ibp.biz_seq = 1
AND ibp.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND ibp.del_yn = 'N'
AND ibi.del_yn = 'N'
GROUP BY ibp.inbiz_prod_seq, ibp.req_qty
HAVING ibp.req_qty != COALESCE(SUM(ibi.req_qty), 0);

-- 라벨 발행 현황 포함 연결 정보
SELECT ib.inbiz_no, ibp.prod_seq, p.prod_nm,
       iw.inwh_no,
       iwp.pub_sku1_yn, iwp.pub_sku2_yn,
       (SELECT COUNT(*) FROM wms_inwh_label 
        WHERE req_prod_seq = iwp.inwh_prod_seq) AS label_cnt
FROM wms_inbiz_inwh ibi
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
    JOIN wms_inbiz_prod ibp ON ibi.inbiz_prod_seq = ibp.inbiz_prod_seq
    JOIN wms_inwh iw ON ibi.inwh_seq = iw.inwh_seq
    JOIN wms_inwh_prod iwp ON ibi.inwh_prod_seq = iwp.inwh_prod_seq
    JOIN mdm_prod p ON ibp.prod_seq = p.prod_seq
WHERE ib.biz_seq = 1
AND ib.req_ymd = '20250226'
AND ibi.del_yn = 'N'
ORDER BY ib.inbiz_no, ibp.inbiz_prod_seq;

-- 연결 정보 통계
SELECT
    COUNT(*) AS total_connection_cnt,
    COUNT(DISTINCT inbiz_seq) AS inbiz_cnt,
    COUNT(DISTINCT inwh_seq) AS inwh_cnt,
    SUM(req_qty) AS total_qty,
    AVG(req_qty) AS avg_qty
FROM wms_inbiz_inwh
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N';

-- 입하-입고 처리 현황 (완료율)
SELECT
    COUNT(*) AS total_cnt,
    SUM(CASE WHEN ib.inbiz_sts_cd = '77' AND iw.inwh_sts_cd = '77' 
             THEN 1 ELSE 0 END) AS completed_cnt,
    ROUND(SUM(CASE WHEN ib.inbiz_sts_cd = '77' AND iw.inwh_sts_cd = '77' 
                  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_inbiz_inwh ibi
    JOIN wms_inbiz ib ON ibi.inbiz_seq = ib.inbiz_seq
    JOIN wms_inwh iw ON ibi.inwh_seq = iw.inwh_seq
WHERE ib.biz_seq = 1
AND ib.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ibi.del_yn = 'N';
```