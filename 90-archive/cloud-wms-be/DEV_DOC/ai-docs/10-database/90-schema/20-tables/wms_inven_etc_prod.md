# wms_inven_etc_prod (WMS_예외출고_품목)

## 1. 개요
예외출고 요청의 **품목 상세 정보**를 관리하는 테이블.
예외출고 헤더(`wms_inven_etc`)에 속한 각 품목별로 요청 수량, 처리 상태, 예상 속성(유통기한, LOT번호 등)을 저장한다.

### 1.1 예외출고 품목 처리 흐름
```
wms_inven_etc (예외출고 헤더)
└─ wms_inven_etc_prod (예외출고 품목)
        └─ wms_inven_etc_tran (예외출고 처리 이력 → 재고 감소)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | etc_prod_seq | bigint | N | nextval('wms_inven_etc_prod_seq') | 예외출고 품목 SEQ |
| PK/FK | etc_seq | integer | N | | 예외출고 SEQ → wms_inven_etc |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | etc_prod_sts_cd | varchar(50) | N | | 예외출고 품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량(예외출고) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량(예외출고) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_mng_ymd | varchar(8) | Y | | 예상 입고/제조일자 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | if_idx | varchar(20) | Y | | IF 내부 순번 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **etc_prod_sts_cd** (`ETC_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
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
| wms_inven_etc_prod_PK | etc_prod_seq, etc_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| etc_prod_seq | wms_inven_etc_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| etc_seq | wms_inven_etc | etc_seq | wms_inven_etc_TO_wms_inven_etc_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_etc_tran | etc_prod_seq, etc_seq | wms_inven_etc_prod_TO_wms_inven_etc_tran |

---

## 7. 업무 규칙

### 7.1 예외출고 품목 등록
- 예외출고 헤더(`wms_inven_etc`) 등록 시 함께 생성
- 하나의 예외출고 헤더에 여러 품목 등록 가능
- `req_qty` : 예외출고 요청 수량
- `ex_qty` : 실제 처리 완료된 수량 (기본값 0)

### 7.2 예상 속성 정보
- 예외출고 접수 단계에서 예상 정보 입력 가능
- `est_exp_ymd` : 예상 유통기한 (폐기/불량 처리 시 참고)
- `est_mng_ymd` : 예상 제조일자/입고일자
- `est_lot_no` : 예상 LOT 번호
- 실제 처리 시(`wms_inven_etc_tran`)에는 확정된 값으로 대체

### 7.3 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 55 | 처리중 | 출고 진행 중 (일부 처리됨) |
| 77 | 확정 | 전체 수량 처리 완료 |

### 7.4 수량 관리
- `req_qty` ≥ `ex_qty` (요청 수량 이상 처리 불가)
- `ex_qty`는 `wms_inven_etc_tran`의 `proc_qty` 합계와 동일
- `req_qty` = `ex_qty` 시 해당 품목 상태 '77'(확정)으로 자동 변경 가능

### 7.5 예외출고 유형별 특성
예외출고 유형(`etc_type_cd`)에 따라 품목 처리 시 고려사항:

| 유형 | 품목 처리 특성 |
|------|---------------|
| EX01 (폐기) | 유통기한 확인, 폐기 사유 기록 |
| EX03 (개발) | 개발 프로젝트 코드 연동 |
| EX05 (샘플) | 샘플 수량 제한 확인 |
| EX07 (기증) | 기증처 정보 확인 |
| EX09 (식약청출고) | 규제 정보 확인 |
| EX11 (구매반품) | 구매 정보 연동 |
| EX13 (생산투입) | 생산 BOM 정보 확인 |
| EX15 (유효일초과) | 유통기한 확인 |
| EX17 (파손) | 파손 사유, 사진 등 증빙 |
| EX19 (불량) | 불량 코드, QC 정보 |
| EX21 (부자재출고) | 부자재 재고 확인 |
| EX91 (기타예외) | 상세 사유 필수 입력 |

### 7.6 재고 지정
- 예외출고 품목은 출고할 재고의 위치/SKU를 지정해야 함
- `etc_sts_cd = '33'(지정)` 단계에서 `wms_inven_etc_tran`을 통해 실제 재고 연결
- 재고 부족 시 출고 불가 또는 부분 출고 처리

### 7.7 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 예외출고 품목 정보 송신 여부
- 품목별 송신 상태 관리 (헤더와 별도)
- `if_idx` : 외부 시스템에서의 순번/인덱스
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 7.8 삭제 처리
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 헤더 삭제 시 하위 품목도 일괄 논리삭제 처리 필요
- 삭제된 품목은 처리 이력에서 제외

### 7.9 처리 이력 연동
- `wms_inven_etc_tran`에서 실제 처리 내역 관리
- `ex_qty`는 `wms_inven_etc_tran.proc_qty`의 합계로 유지/갱신
- `etc_prod_sts_cd`는 `ex_qty`와 `req_qty` 비교하여 자동 갱신 가능

### 7.10 부분 처리
- 예외출고는 부분 처리 가능 (예: 요청 100개 중 50개만 우선 출고)
- 부분 처리 시 `ex_qty` 갱신, 상태는 '55'(처리중) 유지
- 잔여 수량은 이후 추가 처리 가능

---

## 8. 주요 조회 예시

```sql
-- 예외출고별 품목 목록 조회
SELECT ep.etc_prod_seq, ep.prod_seq, p.prod_nm, p.prod_no,
       ep.req_qty, ep.ex_qty,
       ep.etc_prod_sts_cd,
       ep.est_exp_ymd, ep.est_lot_no
FROM wms_inven_etc_prod ep
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE ep.etc_seq = 1001
AND ep.del_yn = 'N'
ORDER BY ep.etc_prod_seq;

-- 미처리 예외출고 품목 조회 (예정/처리중)
SELECT e.etc_no, e.req_ymd, e.etc_type_cd,
       ep.prod_seq, p.prod_nm,
       ep.req_qty, ep.ex_qty,
       (ep.req_qty - ep.ex_qty) AS pending_qty,
       ep.est_exp_ymd, ep.est_lot_no
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND ep.etc_prod_sts_cd IN ('11', '55')
AND ep.req_qty > ep.ex_qty
AND ep.del_yn = 'N'
AND e.del_yn = 'N'
ORDER BY e.req_ymd, e.etc_no;

-- 예외출고 유형별 품목 현황
SELECT e.etc_type_cd,
       COUNT(DISTINCT e.etc_seq) AS etc_cnt,
       COUNT(ep.etc_prod_seq) AS prod_cnt,
       SUM(ep.req_qty) AS total_req_qty,
       SUM(ep.ex_qty) AS total_proc_qty
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
WHERE e.biz_seq = 1
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND ep.del_yn = 'N'
AND e.del_yn = 'N'
GROUP BY e.etc_type_cd
ORDER BY e.etc_type_cd;

-- 유통기한 임박 품목 조회 (폐기/불량 예정)
SELECT e.etc_no, e.req_ymd, e.etc_type_cd,
       ep.prod_seq, p.prod_nm,
       ep.req_qty, ep.est_exp_ymd,
       CURRENT_DATE - TO_DATE(ep.est_exp_ymd, 'YYYYMMDD') AS exp_d_day
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND e.etc_type_cd IN ('EX01', 'EX15', 'EX19')
AND ep.est_exp_ymd IS NOT NULL
AND TO_DATE(ep.est_exp_ymd, 'YYYYMMDD') <= CURRENT_DATE + INTERVAL '30 days'
AND ep.etc_prod_sts_cd != '77'
AND ep.del_yn = 'N'
ORDER BY ep.est_exp_ymd;

-- IF 송신 대기 품목 조회
SELECT e.etc_no, e.req_ymd, e.etc_type_cd,
       ep.prod_seq, p.prod_nm,
       ep.req_qty, ep.if_idx
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND ep.if_send_yn = 'N'
AND ep.del_yn = 'N'
AND e.del_yn = 'N'
ORDER BY ep.reg_dt;

-- 품목별 처리 이력 요약
SELECT ep.etc_prod_seq, p.prod_nm,
       ep.req_qty, ep.ex_qty,
       COUNT(et.etc_tran_seq) AS tran_count,
       SUM(et.proc_qty) AS total_proc_qty
FROM wms_inven_etc_prod ep
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_etc_tran et ON ep.etc_prod_seq = et.etc_prod_seq
        AND et.del_yn = 'N'
WHERE ep.etc_seq = 1001
AND ep.del_yn = 'N'
GROUP BY ep.etc_prod_seq, p.prod_nm, ep.req_qty, ep.ex_qty
ORDER BY ep.etc_prod_seq;

-- 부서별 요청 품목 현황
SELECT e.req_dept_nm,
       COUNT(ep.etc_prod_seq) AS prod_cnt,
       SUM(ep.req_qty) AS total_req_qty,
       SUM(CASE WHEN ep.etc_prod_sts_cd = '77' THEN ep.req_qty ELSE 0 END) AS completed_qty
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND ep.del_yn = 'N'
GROUP BY e.req_dept_nm
ORDER BY total_req_qty DESC;

-- 품목별 예상 vs 실제 처리 현황
SELECT ep.etc_prod_seq, p.prod_nm,
       ep.est_exp_ymd, MIN(et.exp_ymd) AS actual_exp_ymd,
       ep.est_lot_no, MIN(et.lot_no) AS actual_lot_no,
       COUNT(et.etc_tran_seq) AS tran_cnt
FROM wms_inven_etc_prod ep
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_etc_tran et ON ep.etc_prod_seq = et.etc_prod_seq
        AND et.del_yn = 'N'
WHERE ep.etc_seq = 1001
AND ep.del_yn = 'N'
GROUP BY ep.etc_prod_seq, p.prod_nm, ep.est_exp_ymd, ep.est_lot_no
ORDER BY ep.etc_prod_seq;

-- 미완료 품목 중 처리 지연 건
SELECT e.etc_no, e.req_ymd, e.etc_type_cd,
       ep.prod_seq, p.prod_nm,
       ep.req_qty, ep.ex_qty,
       CURRENT_DATE - TO_DATE(e.req_ymd, 'YYYYMMDD') AS delay_days
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND ep.etc_prod_sts_cd != '77'
AND e.req_ymd < TO_CHAR(CURRENT_DATE - INTERVAL '3 days', 'YYYYMMDD')
AND ep.del_yn = 'N'
AND e.del_yn = 'N'
ORDER BY e.req_ymd;
```