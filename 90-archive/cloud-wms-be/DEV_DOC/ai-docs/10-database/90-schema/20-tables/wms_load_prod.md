# wms_load_prod (WMS_상차품목)

## 1. 개요
`wms_load`(상차)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
상차 작업 대상 품목별로 수량, 상태, 예상 정보 등을 저장하며, 실제 상차 처리와 연결된다.

### 1.1 상차품목 처리 흐름
```
wms_load (상차 헤더)
└─ wms_load_prod (상차 품목) ← **현재 테이블**
        └─ wms_load_tran (상차 처리 이력)
              ↑
        wms_outbiz_prod (출하 품목) - wms_outbiz_load 통해 연결
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | load_prod_seq | bigint | N | nextval('wms_load_prod_seq') | 상차품목 SEQ |
| FK | load_seq | integer | N | | 상차 SEQ → wms_load |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | load_prod_sts_cd | varchar(50) | N | | 상차품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | est_mng_ymd | varchar(8) | Y | | 예상 제조일자 (YYYYMMDD) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | group_outwh_no | varchar(30) | N | | 그룹 출고 번호 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **load_prod_sts_cd** (`LOAD_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 77 | 확정 |

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
| wms_load_prod_PK | load_prod_seq, load_seq | Y | Y |
| IX_wms_load_prod_prod | prod_seq | N | |
| IX_wms_load_prod_group | group_outwh_no | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| load_prod_seq | wms_load_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| load_seq | wms_load | load_seq | wms_load_TO_wms_load_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_load_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_load_tran | load_prod_seq, load_seq | wms_load_prod_TO_wms_load_tran |
| wms_outbiz_load | load_prod_seq, load_seq | wms_outbiz_load |

---

## 7. 업무 규칙

### 7.1 상차품목 생성
- 상차출하(OB05) 등록 시 `wms_outbiz_prod` 정보를 기반으로 생성
- `wms_outbiz_load`를 통해 출하 품목과 상차 품목 연결
- `load_prod_sts_cd = '11'(예정)` 으로 시작

### 7.2 수량 관리
- `req_qty` : 상차 요청 수량 (출하 요청 수량과 동일)
- `ex_qty` : 실제 상차 처리된 수량
- 모든 수량이 처리되면(`req_qty = ex_qty`) 상태는 `'77'(확정)` 으로 변경

### 7.3 예상 정보
- `est_mng_ymd`, `est_exp_ymd`, `est_lot_no` : 상차 단계에서 예상 정보 입력
- 출하 품목의 예상 정보(`wms_outbiz_prod.est_*`)에서 복사

### 7.4 그룹 출고 번호
- `group_outwh_no` : 여러 출하를 묶어서 일괄 상차할 때 사용
- 동일 그룹 내 상차품목들은 함께 상차 처리 가능
- `wms_outbiz`의 `group_outwh_no`와 연동

### 7.5 상차 처리 단계

#### 7.5.1 상차 예정
- 상차 계획에 포함된 품목
- `load_prod_sts_cd = '11'`

#### 7.5.2 상차 완료
- 실제 상차 작업 완료 시
- `load_prod_sts_cd = '77'`
- `ex_qty` = `req_qty`
- `wms_load_tran`에 처리 이력 생성

### 7.6 출하 연동
- `wms_outbiz_load`를 통해 출하 품목과 연결
- 상차 완료 시 연결된 출하 품목의 출하처리(`wms_outbiz_tran`) 생성

### 7.7 취소/삭제
- 상차 확정(`'77'`) 후에는 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 상차별 품목 현황
SELECT ld.load_no, ld.load_sts_cd,
       lp.load_prod_seq, lp.prod_seq,
       p.prod_nm, lp.req_qty, lp.ex_qty,
       lp.load_prod_sts_cd, lp.est_lot_no
FROM wms_load_prod lp
    JOIN wms_load ld ON lp.load_seq = ld.load_seq
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND ld.center_seq = 1
AND ld.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND lp.del_yn = 'N'
ORDER BY ld.load_no, lp.load_prod_seq;

-- 특정 상차의 품목 상세
SELECT lp.load_prod_seq, p.prod_no, p.prod_nm,
       lp.req_qty, lp.ex_qty,
       lp.load_prod_sts_cd,
       lp.est_mng_ymd, lp.est_exp_ymd, lp.est_lot_no,
       lp.group_outwh_no
FROM wms_load_prod lp
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE lp.load_seq = 100
AND lp.del_yn = 'N'
ORDER BY lp.load_prod_seq;

-- 그룹 출고 번호별 상차품목 현황
SELECT lp.group_outwh_no,
       COUNT(DISTINCT lp.load_prod_seq) AS prod_cnt,
       COUNT(DISTINCT lp.load_seq) AS load_cnt,
       SUM(lp.req_qty) AS total_req_qty,
       SUM(lp.ex_qty) AS total_ex_qty
FROM wms_load_prod lp
WHERE lp.biz_seq = 1
AND lp.group_outwh_no IS NOT NULL
AND lp.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND lp.del_yn = 'N'
GROUP BY lp.group_outwh_no
ORDER BY lp.group_outwh_no;

-- 출하품목과 상차품목 연결 조회
SELECT ob.outbiz_no, ob.rcv_nm,
       op.prod_seq, op.req_qty AS outbiz_req_qty,
       ld.load_no, ld.load_sts_cd,
       lp.load_prod_seq, lp.req_qty AS load_req_qty,
       lp.load_prod_sts_cd
FROM wms_outbiz_prod op
    JOIN wms_outbiz ob ON op.outbiz_seq = ob.outbiz_seq
    JOIN wms_outbiz_load obl ON op.outbiz_prod_seq = obl.outbiz_prod_seq
    JOIN wms_load_prod lp ON obl.load_prod_seq = lp.load_prod_seq
    JOIN wms_load ld ON lp.load_seq = ld.load_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND op.del_yn = 'N'
AND lp.del_yn = 'N';

-- 미완료 상차품목 목록 (예정)
SELECT lp.load_prod_seq, ld.load_no,
       p.prod_nm, lp.req_qty,
       lp.est_exp_ymd, lp.est_lot_no,
       lp.group_outwh_no
FROM wms_load_prod lp
    JOIN wms_load ld ON lp.load_seq = ld.load_seq
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE ld.biz_seq = 1
AND lp.load_prod_sts_cd = '11'
AND lp.del_yn = 'N'
ORDER BY ld.reg_dt, lp.load_prod_seq;

-- 품목별 상차 현황
SELECT p.prod_nm,
       COUNT(DISTINCT lp.load_prod_seq) AS load_prod_cnt,
       COUNT(DISTINCT lp.load_seq) AS load_cnt,
       SUM(lp.req_qty) AS total_req_qty,
       SUM(lp.ex_qty) AS total_ex_qty,
       ROUND(SUM(lp.ex_qty) * 100.0 / NULLIF(SUM(lp.req_qty), 0), 2) AS completion_rate
FROM wms_load_prod lp
    JOIN mdm_prod p ON lp.prod_seq = p.prod_seq
WHERE lp.biz_seq = 1
AND lp.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND lp.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_req_qty DESC;

-- 상차 처리 현황 (완료율)
SELECT ld.load_no,
       COUNT(lp.load_prod_seq) AS total_prod_cnt,
       SUM(CASE WHEN lp.load_prod_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
       ROUND(SUM(CASE WHEN lp.load_prod_sts_cd = '77' THEN 1 ELSE 0 END) * 100.0 / COUNT(lp.load_prod_seq), 2) AS completion_rate,
       SUM(lp.req_qty) AS total_qty,
       SUM(lp.ex_qty) AS completed_qty
FROM wms_load ld
    LEFT JOIN wms_load_prod lp ON ld.load_seq = lp.load_seq
WHERE ld.biz_seq = 1
AND ld.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND lp.del_yn = 'N'
GROUP BY ld.load_no, ld.reg_dt
ORDER BY ld.reg_dt;
```