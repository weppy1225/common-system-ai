# wms_outbiz_outwh (WMS_출하출고연결)

## 1. 개요
**출하(`wms_outbiz`)와 출고(`wms_outwh`) 간의 연결 정보**를 관리하는 매핑 테이블.
출하 요청이 실제 출고 작업으로 이어질 때 두 정보 간의 관계를 정의한다.

### 1.1 출하-출고 연결 흐름
```
wms_outbiz (출하 헤더)
└─ wms_outbiz_prod (출하 품목)
        └─ wms_outbiz_outwh (출하-출고 연결) ← **현재 테이블**
              ├─ wms_outwh (출고 헤더)
              └─ wms_outwh_prod (출고 품목)
                    └─ wms_outwh_tran (출고 처리 이력) → 재고 차감
                          ↓
                    wms_outbiz_tran (출하 처리 이력) 생성
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outbiz_seq | integer | N | | 출하 SEQ → wms_outbiz |
| PK | outbiz_prod_seq | bigint | N | | 출하품목 SEQ → wms_outbiz_prod |
| PK | outwh_seq | integer | N | | 출고 SEQ → wms_outwh |
| PK | outwh_prod_seq | bigint | N | | 출고품목 SEQ → wms_outwh_prod |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | outwh_req_qty | decimal(10,2) | N | 0 | 출고 요청 수량 |
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
| wms_outbiz_outwh_PK | outbiz_seq, outbiz_prod_seq, outwh_seq, outwh_prod_seq | Y | Y |
| IX_wms_outbiz_outwh_outbiz | outbiz_seq, outbiz_prod_seq | N | |
| IX_wms_outbiz_outwh_outwh | outwh_seq, outwh_prod_seq | N | |
| IX_wms_outbiz_outwh_prod | prod_seq | N | |

---

## 4. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outbiz_seq, outbiz_prod_seq | wms_outbiz_prod | outbiz_seq, outbiz_prod_seq | wms_outbiz_prod_TO_wms_outbiz_outwh |
| outwh_seq, outwh_prod_seq | wms_outwh_prod | outwh_seq, outwh_prod_seq | wms_outwh_prod_TO_wms_outbiz_outwh |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outbiz_outwh |

---

## 5. 업무 규칙

### 5.1 연결 생성 조건
- 출하 정보를 기반으로 출고 생성 시 자동 연결
- 또는 기존 출고에 출하를 연결할 때 수동 생성
- 출하품목과 출고품목 간의 매핑 정보 저장

### 5.2 연결 관계
- **1:1 관계** : 하나의 출하품목이 하나의 출고품목과 연결 (일반적인 경우)
- **N:1 관계** : 여러 출하품목이 하나의 출고품목으로 통합 (출하 통합 처리)
- **1:N 관계** : 하나의 출하품목이 여러 출고품목으로 분할 (분할 출고)

### 5.3 수량 관리
- `outwh_req_qty` : 출고 요청 수량 (출하품목 기준)
- 출하품목의 `req_qty` = 연결된 모든 출고품목의 `outwh_req_qty` 합계
- 출고품목의 `req_qty` = 연결된 모든 출하품목의 `outwh_req_qty` 합계

### 5.4 상태 동기화
- 출고 처리(`wms_outwh_tran`) 시 연결된 출하 처리(`wms_outbiz_tran`) 생성
- 출고 확정(`outwh_sts_cd` = '77') 시 출하도 함께 확정 처리

### 5.5 처리 흐름

#### 5.5.1 출하 등록 → 출고 생성
- `wms_outbiz` 등록 시 `wms_outwh` 자동 생성
- `wms_outbiz_outwh`에 연결 정보 저장

#### 5.5.2 출고 처리
- `wms_outwh_tran` 생성으로 실제 재고 차감
- 출고 처리 후 `outwh_req_qty`만큼 출하 처리된 것으로 간주

#### 5.5.3 출하 처리 연동
- 출고 처리 시 `wms_outbiz_tran` 자동 생성
- 출하품목의 `ex_qty` 증가 및 상태 변경

### 5.6 수량 정합성
- 출하품목의 `req_qty` = 연결된 모든 출고품목의 `outwh_req_qty` 합계
- 출고품목의 `req_qty` = 연결된 모든 출하품목의 `outwh_req_qty` 합계
- 출고 처리 후 `ex_qty` 업데이트 시 정합성 검증 필요

### 5.7 취소/삭제
- 출고 또는 출하가 취소(`'99'`)되면 연결 정보는 유지 (이력 보존)
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 6. 주요 조회 예시

```sql
-- 출하별 연결된 출고 정보
SELECT ob.outbiz_no, ob.rcv_nm,
       ow.outwh_no, ow.outwh_sts_cd,
       obo.outwh_req_qty,
       p.prod_nm
FROM wms_outbiz_outwh obo
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
    JOIN wms_outwh ow ON obo.outwh_seq = ow.outwh_seq
    JOIN wms_outbiz_prod obp ON obo.outbiz_prod_seq = obp.outbiz_prod_seq
    JOIN mdm_prod p ON obp.prod_seq = p.prod_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND obo.del_yn = 'N'
ORDER BY obo.outwh_prod_seq;

-- 출고별 연결된 출하 정보
SELECT ow.outwh_no, ow.outwh_sts_cd,
       ob.outbiz_no, ob.rcv_nm,
       obo.outwh_req_qty,
       p.prod_nm
FROM wms_outbiz_outwh obo
    JOIN wms_outwh ow ON obo.outwh_seq = ow.outwh_seq
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
    JOIN wms_outwh_prod owp ON obo.outwh_prod_seq = owp.outwh_prod_seq
    JOIN mdm_prod p ON owp.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND ow.outwh_no = 'OW2502260001'
AND obo.del_yn = 'N'
ORDER BY obo.outbiz_prod_seq;

-- 출하 통합 처리 현황 (하나의 출고에 여러 출하)
SELECT ow.outwh_no,
       COUNT(DISTINCT obo.outbiz_seq) AS outbiz_cnt,
       COUNT(DISTINCT obo.outbiz_prod_seq) AS outbiz_prod_cnt,
       SUM(obo.outwh_req_qty) AS total_qty,
       ow.outwh_sts_cd
FROM wms_outbiz_outwh obo
    JOIN wms_outwh ow ON obo.outwh_seq = ow.outwh_seq
WHERE ow.biz_seq = 1
AND ow.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obo.del_yn = 'N'
GROUP BY ow.outwh_no, ow.outwh_sts_cd
HAVING COUNT(DISTINCT obo.outbiz_seq) > 1
ORDER BY ow.reg_dt DESC;

-- 분할 출고 현황 (하나의 출하가 여러 출고로)
SELECT ob.outbiz_no,
       COUNT(DISTINCT obo.outwh_seq) AS outwh_cnt,
       COUNT(DISTINCT obo.outwh_prod_seq) AS outwh_prod_cnt,
       SUM(obo.outwh_req_qty) AS total_qty,
       ob.outbiz_sts_cd
FROM wms_outbiz_outwh obo
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
WHERE ob.biz_seq = 1
AND ob.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obo.del_yn = 'N'
GROUP BY ob.outbiz_no, ob.outbiz_sts_cd
HAVING COUNT(DISTINCT obo.outwh_seq) > 1
ORDER BY ob.reg_dt DESC;

-- 미처리 연결 건 (출고 미완료)
SELECT obo.outbiz_seq, ob.outbiz_no,
       obo.outwh_seq, ow.outwh_no,
       obo.outwh_req_qty,
       owp.req_qty AS outwh_req_qty,
       owp.ex_qty AS outwh_ex_qty,
       (owp.req_qty - owp.ex_qty) AS remain_qty
FROM wms_outbiz_outwh obo
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
    JOIN wms_outwh ow ON obo.outwh_seq = ow.outwh_seq
    JOIN wms_outwh_prod owp ON obo.outwh_prod_seq = owp.outwh_prod_seq
WHERE ob.biz_seq = 1
AND owp.ex_qty < owp.req_qty
AND ow.outwh_sts_cd NOT IN ('77', '99')
AND ob.outbiz_sts_cd NOT IN ('77', '99')
AND obo.del_yn = 'N'
ORDER BY ob.req_ymd, ob.outbiz_no;

-- 출하품목과 출고품목 매핑 현황
SELECT obp.outbiz_prod_seq, ob.outbiz_no,
       owp.outwh_prod_seq, ow.outwh_no,
       obp.req_qty AS outbiz_qty,
       owp.req_qty AS outwh_qty,
       obo.outwh_req_qty AS mapped_qty
FROM wms_outbiz_prod obp
    JOIN wms_outbiz ob ON obp.outbiz_seq = ob.outbiz_seq
    LEFT JOIN wms_outbiz_outwh obo ON obp.outbiz_prod_seq = obo.outbiz_prod_seq
    LEFT JOIN wms_outwh_prod owp ON obo.outwh_prod_seq = owp.outwh_prod_seq
    LEFT JOIN wms_outwh ow ON owp.outwh_seq = ow.outwh_seq
WHERE ob.biz_seq = 1
AND ob.req_ymd = '20250226'
AND obp.del_yn = 'N'
ORDER BY ob.outbiz_no, obp.outbiz_prod_seq;

-- 수량 정합성 검증 (출하품목 vs 연결된 출고품목 합계)
SELECT
    obp.outbiz_prod_seq,
    obp.req_qty AS outbiz_req_qty,
    SUM(obo.outwh_req_qty) AS total_mapped_qty,
    CASE 
        WHEN obp.req_qty = SUM(obo.outwh_req_qty) THEN '정상'
        ELSE '불일치'
    END AS status
FROM wms_outbiz_prod obp
    LEFT JOIN wms_outbiz_outwh obo ON obp.outbiz_prod_seq = obo.outbiz_prod_seq
WHERE obp.biz_seq = 1
AND obp.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND obp.del_yn = 'N'
AND obo.del_yn = 'N'
GROUP BY obp.outbiz_prod_seq, obp.req_qty
HAVING obp.req_qty != COALESCE(SUM(obo.outwh_req_qty), 0);

-- 연결 정보 통계
SELECT
    COUNT(*) AS total_connection_cnt,
    COUNT(DISTINCT outbiz_seq) AS outbiz_cnt,
    COUNT(DISTINCT outwh_seq) AS outwh_cnt,
    SUM(outwh_req_qty) AS total_qty,
    AVG(outwh_req_qty) AS avg_qty
FROM wms_outbiz_outwh
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N';

-- 출하-출고 처리 현황 (완료율)
SELECT
    COUNT(*) AS total_cnt,
    SUM(CASE WHEN ob.outbiz_sts_cd = '77' AND ow.outwh_sts_cd = '77' 
             THEN 1 ELSE 0 END) AS completed_cnt,
    ROUND(SUM(CASE WHEN ob.outbiz_sts_cd = '77' AND ow.outwh_sts_cd = '77' 
                  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_outbiz_outwh obo
    JOIN wms_outbiz ob ON obo.outbiz_seq = ob.outbiz_seq
    JOIN wms_outwh ow ON obo.outwh_seq = ow.outwh_seq
WHERE ob.biz_seq = 1
AND ob.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND obo.del_yn = 'N';
```