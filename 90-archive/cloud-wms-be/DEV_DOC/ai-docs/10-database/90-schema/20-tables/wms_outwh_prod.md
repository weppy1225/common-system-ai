# wms_outwh_prod (WMS_출고품목)

## 1. 개요
`wms_outwh`(출고)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
출고 요청 품목별로 수량, 상태, 예상 정보 등을 저장하며, 실제 출고 처리(`wms_outwh_tran`)와 연결된다.

### 1.1 출고품목 처리 흐름
```
wms_outwh (출고 헤더)
└─ wms_outwh_prod (출고 품목) ← **현재 테이블**
        ├─ wms_outwh_assign (출고 지시) - 재고 위치 지정
        └─ wms_outwh_tran (출고 처리 이력) - 실제 출고 처리
              ↓
        wms_outbiz_outwh (출하-출고 연결) → 출하 처리 연동
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | outwh_prod_seq | bigint | N | nextval('wms_outwh_prod_seq') | 출고품목 SEQ |
| FK | outwh_seq | integer | N | | 출고 SEQ → wms_outwh |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | outwh_prod_sts_cd | varchar(50) | N | | 출고품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | est_mng_ymd | varchar(8) | Y | | 예상 제조일자 (YYYYMMDD) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | est_cn | varchar(1000) | Y | | 예상 일련번호(CN) |
| | if_idx | varchar(20) | Y | | IF 내부순번 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **outwh_prod_sts_cd** (`OUTWH_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 33 | 지정 |
> | 55 | 처리중 |
> | 77 | 확정 |

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
| wms_outwh_prod_PK | outwh_prod_seq, outwh_seq | Y | Y |
| IX_wms_outwh_prod_prod | prod_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| outwh_prod_seq | wms_outwh_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| outwh_seq | wms_outwh | outwh_seq | wms_outwh_TO_wms_outwh_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_outwh_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_outwh_tran | outwh_prod_seq, outwh_seq | wms_outwh_prod_TO_wms_outwh_tran |
| wms_outwh_assign | req_prod_seq | wms_outwh_assign (참조) |
| wms_outbiz_outwh | outwh_prod_seq, outwh_seq | wms_outbiz_outwh |

---

## 7. 업무 규칙

### 7.1 출고품목 생성
- 출고 등록 시 출하(`wms_outbiz_prod`) 정보를 기반으로 생성
- `outwh_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 출고 요청 수량 (출하 요청 수량과 동일)

### 7.2 예상 정보
- `est_mng_ymd`, `est_exp_ymd`, `est_lot_no`, `est_cn` : 출고 단계에서 예상 정보 입력
- 출하 품목의 예상 정보(`wms_outbiz_prod.est_*`)에서 복사

### 7.3 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 출고 요청 등록 |
| 지정 | 33 | 출고지시(`wms_outwh_assign`)로 재고 위치 지정 완료 |
| 처리중 | 55 | 실제 출고 작업 시작 |
| 확정 | 77 | 출고 완료 (전량 처리) |

### 7.4 수량 관리
- `req_qty` : 출고 요청 수량
- `ex_qty` : 실제 출고 처리(`wms_outwh_tran`)된 누적 수량
- 모든 수량이 처리되면(`ex_qty = req_qty`) 상태는 `'77'(확정)` 으로 변경

### 7.5 출고지시 연동
- `wms_outwh_assign`을 통해 실제 출고할 재고 위치 지정
- 하나의 출고품목에 여러 출고지시가 있을 수 있음 (분할 출고)
- 출고지시의 `req_qty` 합계 = 출고품목의 `req_qty`

### 7.6 출하 연동
- `wms_outbiz_outwh`를 통해 출하 품목과 연결
- 출고 확정 시 연결된 출하의 출하처리(`wms_outbiz_tran`) 생성

### 7.7 IF 송신
- `if_send_yn` : 외부 시스템(ERP)으로 출고품목 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'
- `if_idx` : 외부 시스템에서의 순번 정보

### 7.8 취소/삭제
- 출고 확정(`'77'`) 후에는 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 출고별 품목 현황
SELECT ow.outwh_no, ow.outwh_sts_cd,
       op.outwh_prod_seq, p.prod_nm,
       op.req_qty, op.ex_qty,
       op.outwh_prod_sts_cd,
       op.est_lot_no, op.est_exp_ymd
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND ow.center_seq = 1
AND ow.req_ymd = '20250226'
AND op.del_yn = 'N'
ORDER BY ow.outwh_no, op.outwh_prod_seq;

-- 특정 출고의 품목 상세
SELECT op.outwh_prod_seq, p.prod_no, p.prod_nm,
       op.req_qty, op.ex_qty,
       op.outwh_prod_sts_cd,
       op.est_mng_ymd, op.est_exp_ymd, op.est_lot_no,
       (SELECT COUNT(*) FROM wms_outwh_assign WHERE req_prod_seq = op.outwh_prod_seq) AS assign_cnt
FROM wms_outwh_prod op
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE op.outwh_seq = 100
AND op.del_yn = 'N'
ORDER BY op.outwh_prod_seq;

-- 미완료 출고품목 목록 (예정/지정/처리중)
SELECT op.outwh_prod_seq, ow.outwh_no,
       p.prod_nm, op.req_qty, op.ex_qty,
       (op.req_qty - op.ex_qty) AS remain_qty,
       op.outwh_prod_sts_cd,
       op.est_exp_ymd, op.est_lot_no
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND op.outwh_prod_sts_cd IN ('11', '33', '55')
AND op.del_yn = 'N'
ORDER BY ow.req_ymd, ow.outwh_no;

-- 출하품목과 출고품목 연결 조회
SELECT ob.outbiz_no, ob.rcv_nm,
       obp.prod_seq, obp.req_qty AS outbiz_req_qty,
       ow.outwh_no,
       op.outwh_prod_seq, op.req_qty AS outwh_req_qty,
       op.outwh_prod_sts_cd
FROM wms_outbiz_prod obp
    JOIN wms_outbiz ob ON obp.outbiz_seq = ob.outbiz_seq
    JOIN wms_outbiz_outwh obo ON obp.outbiz_prod_seq = obo.outbiz_prod_seq
    JOIN wms_outwh_prod op ON obo.outwh_prod_seq = op.outwh_prod_seq
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
WHERE ob.biz_seq = 1
AND ob.outbiz_no = 'OB2502260001'
AND obp.del_yn = 'N'
AND op.del_yn = 'N';

-- 품목별 출고 현황
SELECT p.prod_nm,
       COUNT(DISTINCT op.outwh_prod_seq) AS outwh_prod_cnt,
       COUNT(DISTINCT op.outwh_seq) AS outwh_cnt,
       SUM(op.req_qty) AS total_req_qty,
       SUM(op.ex_qty) AS total_ex_qty,
       ROUND(SUM(op.ex_qty) * 100.0 / NULLIF(SUM(op.req_qty), 0), 2) AS completion_rate
FROM wms_outwh_prod op
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE op.biz_seq = 1
AND op.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND op.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY total_req_qty DESC;

-- 상태별 출고품목 현황
SELECT
    op.outwh_prod_sts_cd,
    COUNT(*) AS prod_cnt,
    SUM(op.req_qty) AS total_qty
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
WHERE ow.biz_seq = 1
AND ow.req_ymd = '20250226'
AND op.del_yn = 'N'
GROUP BY op.outwh_prod_sts_cd
ORDER BY op.outwh_prod_sts_cd;

-- IF 송신 대기 건 조회
SELECT op.outwh_prod_seq, ow.outwh_no, p.prod_nm,
       op.req_qty, op.ex_qty,
       op.outwh_prod_sts_cd
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND op.if_send_yn = 'N'
AND op.del_yn = 'N'
ORDER BY op.reg_dt;

-- 유통기한 임박 품목 출고 현황
SELECT op.outwh_prod_seq, ow.outwh_no,
       p.prod_nm, op.req_qty,
       op.est_exp_ymd
FROM wms_outwh_prod op
    JOIN wms_outwh ow ON op.outwh_seq = ow.outwh_seq
    JOIN mdm_prod p ON op.prod_seq = p.prod_seq
WHERE ow.biz_seq = 1
AND op.est_exp_ymd BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
AND op.outwh_prod_sts_cd != '77'
AND op.del_yn = 'N'
ORDER BY op.est_exp_ymd;
```