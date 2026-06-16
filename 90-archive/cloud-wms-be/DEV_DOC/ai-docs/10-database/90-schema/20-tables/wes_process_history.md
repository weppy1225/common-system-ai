# wes_process_history (WES_처리_이력)

## 1. 개요
**WES(Warehouse Execution System)와의 연동 처리 이력**을 관리하는 테이블.
WES로 전송된 송장 정보, 처리 결과, 에러 내역 등을 저장하여 WES 연동 모니터링 및 장애 추적에 활용한다.

### 1.1 WES 처리 이력 흐름
```
WES 연동 요청 발생 → wes_process_history 저장 (요청 정보) → WES 처리 → wes_process_history 업데이트 (처리 결과)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | wes_proc_seq | integer | N | nextval('wes_proc_seq') | WES 처리 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | if_seq | integer | Y | | IF SEQ (sif_batch_history 참조) |
| | wes_proc_no | integer | N | 0 | WES 처리 묶음 번호 |
| | invoice_seq | integer | N | | 송장 SEQ |
| | parent_invoice_seq | integer | Y | | 부모 송장 SEQ |
| | invoice_no | varchar(30) | Y | | 송장 번호 |
| | add_invoice_yn | char(1) | N | 'N' | 추가 송장 여부 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 (WES) |
| | proc_hms | varchar(6) | Y | | 처리 시분초 (WES) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID (WES) |
| | invoice_prod_seq | bigint | Y | | 송장 품목 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 (송장 기준) |
| | proc_yn | char(1) | N | 'N' | 처리 여부 |
| | err_msg | text | Y | | 에러 메시지 |
| | wms_proc_ymd | varchar(8) | Y | | 처리 연월일 (WMS) |
| | wms_proc_hms | varchar(6) | Y | | 처리 시분초 (WMS) |

> **add_invoice_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | Y | 추가 송장 | 분할/추가 생성된 송장 |
> | N | 일반 송장 | 원본 송장 |

> **proc_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | Y | 처리 완료 | WES 처리 완료 |
> | N | 미처리 | WES 처리 대기/진행중 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wes_process_history_PK | wes_proc_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| wes_proc_seq | wes_proc_seq |

---

## 5. 업무 규칙

### 5.1 WES 연동 개요
- WES: 창고 실행 시스템 (지게차 지시, 피킹 경로 최적화 등)
- WMS에서 WES로 송장 정보 전송
- WES 처리 결과를 WMS로 반영

### 5.2 처리 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| wes_proc_no | WES 처리 묶음 번호 | 여러 건을 묶어서 전송 시 사용 |
| if_seq | SIF 배치 이력 SEQ | sif_batch_history 연결 |
| proc_ymd/hms | WES 처리 일시 | WES에서 실제 처리된 시간 |
| proc_user_id | WES 처리자 ID | WES 시스템 사용자 |

### 5.3 송장 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| invoice_seq | 송장 SEQ | wms_invoice 참조 |
| parent_invoice_seq | 부모 송장 SEQ | 추가 송장인 경우 원본 송장 |
| invoice_no | 송장 번호 | |
| add_invoice_yn | 추가 송장 여부 | 분할 출하 등 |

### 5.4 품목 정보

| 필드 | 설명 | 비고 |
|------|------|------|
| invoice_prod_seq | 송장 품목 SEQ | wms_invoice_prod 참조 |
| prod_seq | 품목 SEQ | |
| proc_qty | 처리 수량 | WES에서 처리된 수량 |

### 5.5 처리 상태
- `proc_yn = 'N'`: WES로 전송되었으나 아직 처리되지 않음
- `proc_yn = 'Y'`: WES 처리 완료, 결과 수신됨

### 5.6 에러 처리
- `err_msg`: WES 처리 중 발생한 에러 메시지
- 실패 시 재처리 로직 연동

### 5.7 WMS 반영
- `wms_proc_ymd`, `wms_proc_hms`: WMS에 결과 반영된 시간
- WES 처리 완료 후 WMS 데이터 업데이트 시 기록

---

## 6. 주요 조회 예시

```sql
-- 최근 WES 처리 이력 조회
SELECT wes_proc_seq, biz_seq, invoice_no,
       proc_yn, proc_ymd, proc_hms,
       proc_user_id, proc_qty,
       err_msg
FROM wes_process_history
ORDER BY wes_proc_seq DESC
LIMIT 100;

-- 특정 송장의 WES 처리 이력
SELECT wes_proc_seq, wes_proc_no,
       proc_yn, proc_ymd, proc_hms,
       proc_qty, err_msg
FROM wes_process_history
WHERE invoice_no = 'INV20250226-001'
OR invoice_seq = 1001
ORDER BY wes_proc_seq;

-- 미처리 WES 건 조회 (WES 전송 후 응답 대기)
SELECT wes_proc_seq, invoice_no,
       wes_proc_no, prod_seq, proc_qty,
       proc_ymd, proc_hms
FROM wes_process_history
WHERE proc_yn = 'N'
AND proc_ymd <= TO_CHAR(CURRENT_DATE - INTERVAL '1 hour', 'YYYYMMDD')
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 에러 발생 건 조회
SELECT wes_proc_seq, invoice_no,
       proc_ymd, proc_hms,
       err_msg
FROM wes_process_history
WHERE err_msg IS NOT NULL
AND proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
ORDER BY proc_ymd DESC, proc_hms DESC;

-- 일자별 WES 처리 현황
SELECT proc_ymd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN proc_yn = 'Y' THEN 1 ELSE 0 END) AS success_cnt,
       SUM(CASE WHEN proc_yn = 'N' THEN 1 ELSE 0 END) AS pending_cnt,
       SUM(CASE WHEN err_msg IS NOT NULL THEN 1 ELSE 0 END) AS error_cnt
FROM wes_process_history
WHERE proc_ymd BETWEEN '20250201' AND '20250228'
GROUP BY proc_ymd
ORDER BY proc_ymd DESC;

-- 추가 송장 처리 현황
SELECT add_invoice_yn,
       COUNT(*) AS cnt,
       SUM(proc_qty) AS total_qty
FROM wes_process_history
WHERE proc_ymd = '20250226'
GROUP BY add_invoice_yn;

-- WES 처리 묶음별 현황
SELECT wes_proc_no,
       COUNT(*) AS invoice_cnt,
       SUM(proc_qty) AS total_qty,
       MIN(proc_ymd) AS first_proc,
       MAX(proc_ymd) AS last_proc
FROM wes_process_history
WHERE wes_proc_no > 0
AND proc_ymd = '20250226'
GROUP BY wes_proc_no
ORDER BY wes_proc_no;

-- SIF 배치 이력과 연동 조회
SELECT w.wes_proc_seq, w.invoice_no,
       w.proc_yn, w.proc_ymd, w.proc_hms,
       s.if_id, s.if_nm, s.if_status_cd,
       w.err_msg
FROM wes_process_history w
    LEFT JOIN sif_batch_history s ON w.if_seq = s.if_seq
WHERE w.proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '3 days', 'YYYYMMDD')
ORDER BY w.wes_proc_seq DESC;

-- 품목별 WES 처리 현황
SELECT w.prod_seq, p.prod_nm,
       COUNT(*) AS proc_cnt,
       SUM(w.proc_qty) AS total_qty
FROM wes_process_history w
    JOIN mdm_prod p ON w.prod_seq = p.prod_seq
WHERE w.proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
GROUP BY w.prod_seq, p.prod_nm
ORDER BY total_qty DESC;

-- 처리 시간 분석 (WES 처리 시간)
SELECT wes_proc_seq, invoice_no,
       proc_ymd, proc_hms,
       wms_proc_ymd, wms_proc_hms,
       EXTRACT(EPOCH FROM 
           (TO_TIMESTAMP(wms_proc_ymd || wms_proc_hms, 'YYYYMMDDHH24MISS') - 
            TO_TIMESTAMP(proc_ymd || proc_hms, 'YYYYMMDDHH24MISS'))) AS process_sec
FROM wes_process_history
WHERE proc_yn = 'Y'
AND wms_proc_ymd IS NOT NULL
AND proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '7 days', 'YYYYMMDD')
ORDER BY process_sec DESC;

-- 사용자별 처리 현황
SELECT proc_user_id,
       COUNT(*) AS proc_cnt,
       SUM(proc_qty) AS total_qty
FROM wes_process_history
WHERE proc_user_id IS NOT NULL
AND proc_ymd >= TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'YYYYMMDD')
GROUP BY proc_user_id
ORDER BY proc_cnt DESC;

-- 부모/자식 송장 관계 조회
SELECT parent.invoice_no AS parent_invoice,
       child.invoice_no AS child_invoice,
       child.proc_yn, child.proc_qty
FROM wes_process_history parent
    JOIN wes_process_history child ON parent.invoice_seq = child.parent_invoice_seq
WHERE parent.invoice_no = 'INV20250226-001'
ORDER BY child.wes_proc_seq;

-- 시간대별 WES 처리 집계
SELECT SUBSTR(proc_hms, 1, 2) AS hour,
       COUNT(*) AS proc_cnt,
       SUM(proc_qty) AS total_qty
FROM wes_process_history
WHERE proc_ymd = '20250226'
GROUP BY SUBSTR(proc_hms, 1, 2)
ORDER BY hour;
```