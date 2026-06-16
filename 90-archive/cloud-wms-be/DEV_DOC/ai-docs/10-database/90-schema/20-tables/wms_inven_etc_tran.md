# wms_inven_etc_tran (WMS_예외출고_처리)

## 1. 개요
예외출고 품목의 **실제 출고 처리 이력**을 관리하는 테이블.
예외출고 검증 후 창고에서 실제로 출고되는 내역을 기록하며, 재고(`wms_inven`) 감소의 근거가 된다.

### 1.1 예외출고 처리 이력 흐름
```
wms_inven_etc (예외출고 헤더) → wms_inven_etc_prod (예외출고 품목)
                                  └─ wms_inven_etc_tran (예외출고 처리 이력) → wms_inven 감소
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | etc_tran_seq | bigint | N | nextval('wms_inven_etc_tran_seq') | 예외출고 처리 SEQ |
| PK/FK | etc_prod_seq | bigint | N | | 예외출고 품목 SEQ → wms_inven_etc_prod |
| PK/FK | etc_seq | integer | N | | 예외출고 SEQ → wms_inven_etc |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | wh_seq | integer | N | | 창고 SEQ → mdm_wh |
| | loc_seq | bigint | N | | 위치 SEQ → mdm_loc |
| | sku1 | varchar(100) | N | | SKU1 |
| | sku2 | varchar(100) | N | | SKU2 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량(예외출고) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량(예외출고) |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | proc_ymd | varchar(8) | Y | | 처리 연월일 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시분초 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

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
| wms_inven_etc_tran_PK | etc_tran_seq, etc_prod_seq, etc_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| etc_tran_seq | wms_inven_etc_tran_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| etc_prod_seq, etc_seq | wms_inven_etc_prod | etc_prod_seq, etc_seq | wms_inven_etc_prod_TO_wms_inven_etc_tran |

---

## 6. 업무 규칙

### 6.1 예외출고 처리 등록
- 예외출고 품목(`wms_inven_etc_prod`)에 대한 실제 출고 처리 시 생성
- 하나의 예외출고 품목에 대해 여러 번 처리 가능 (부분 출고)
- `proc_qty` : 이번 처리에서 출고하는 수량

### 6.2 수량 관리
- `proc_qty` : 실제 출고 처리 수량
- `ex_qty` : 해당 품목의 누적 처리 수량
- `wms_inven_etc_prod.ex_qty`와 동기화 필요
- `wms_inven_etc_prod.ex_qty` = 동일 `etc_prod_seq`의 `proc_qty` 합계
- `proc_qty` + 기존 `ex_qty` ≤ `wms_inven_etc_prod.req_qty`

### 6.3 재고 위치 정보
- `wh_seq` : 출고 창고 (FROM 창고)
- `loc_seq` : 출고 위치 (FROM 위치)
- 실제 재고가 존재하는 위치여야 함
- 재고 위치는 예외출고 품목의 예상 정보와 다를 수 있음

### 6.4 SKU 정보
- `sku1`, `sku2` : 실제 출고된 재고의 SKU 값
- `wms_inven` 테이블의 SKU와 일치해야 함
- 재고 차감 시 동일 SKU 조합의 재고에서 차감

### 6.5 LOT 정보
- `lot_no` : 출고된 재고의 LOT 번호
- 품목의 LOT 관리 여부에 따라 필수값
- LOT 관리 품목은 반드시 LOT 번호 입력 필요

### 6.6 처리 정보
- `proc_ymd`, `proc_hms` : 처리 일시 (보통 현재 일시)
- `proc_user_id` : 처리 작업자 ID
- `proc_bundle_no` : 일괄 처리 시 묶음 번호 (여러 건 동시 처리 시 사용)

### 6.7 재고 차감 처리
- `wms_inven_etc_tran` 생성 시 실제 재고(`wms_inven`) 차감 처리 필요
- 차감 조건: 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고 존재
- `proc_qty`만큼 `inven_qty` 감소
- 재고 부족 시 출고 불가 또는 부분 출고만 가능

### 6.8 재고 부족 처리
- 출고 처리 시 재고 부족이 발생하면 처리 불가
- 부분 출고 가능한 경우 잔여 수량만큼만 처리
- 재고 부족 사유 기록 및 알림 생성 가능

### 6.9 상태 갱신
- `wms_inven_etc_prod.ex_qty` 갱신
- `wms_inven_etc_prod.ex_qty` = `wms_inven_etc_prod.req_qty`인 경우 `etc_prod_sts_cd`를 '77'(확정)로 변경
- 모든 품목이 확정되면 `wms_inven_etc.etc_sts_cd`를 '77'(확정)로 변경

### 6.10 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 예외출고 처리 내역 송신 여부
- 처리 이력 단위로 송신 관리
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.11 취소/삭제
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 해당 처리 수량만큼 재고 복원 필요
- 이미 확정된 예외출고의 처리 이력은 삭제 불가 (취소는 별도 조정 처리)

### 6.12 중복 처리 방지
- 동일 `etc_prod_seq`에 대해 중복 처리 시 수량 합계가 `req_qty` 초과하지 않도록 제어
- `proc_bundle_no`로 일괄 처리 건 구분 가능

### 6.13 예외출고 유형별 특성
예외출고 유형(`etc_type_cd`)에 따라 처리 시 고려사항:

| 유형 | 처리 특성 |
|------|----------|
| EX01 (폐기) | 폐기장소 지정, 폐기 증빙 |
| EX03 (개발) | 개발 프로젝트 코드 기록 |
| EX05 (샘플) | 샘플 수량 제한 확인 |
| EX07 (기증) | 기증처 정보 기록 |
| EX09 (식약청출고) | 규제 정보 기록 |
| EX11 (구매반품) | 반품 사유 기록 |
| EX13 (생산투입) | 생산 라인 정보 기록 |
| EX15 (유효일초과) | 유통기한 만료 확인 |
| EX17 (파손) | 파손 사유, 사진 증빙 |
| EX19 (불량) | 불량 코드, QC 정보 |
| EX21 (부자재출고) | 부자재 재고 차감 |
| EX91 (기타예외) | 상세 사유 필수 기록 |

---

## 7. 주요 조회 예시

```sql
-- 예외출고별 처리 이력 조회
SELECT et.etc_tran_seq, et.prod_seq, p.prod_nm,
       et.proc_qty, et.proc_ymd, et.proc_hms, et.proc_user_id,
       et.wh_seq, w.wh_nm,
       et.loc_seq, l.loc_nm,
       et.sku1, et.sku2, et.lot_no
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
    JOIN mdm_prod p ON et.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON et.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON et.loc_seq = l.loc_seq
WHERE e.etc_no = 'EX2502260001'
AND et.del_yn = 'N'
ORDER BY et.proc_ymd, et.proc_hms;

-- 품목별 처리 이력 요약
SELECT ep.etc_prod_seq, p.prod_nm,
       ep.req_qty,
       COUNT(et.etc_tran_seq) AS tran_count,
       SUM(et.proc_qty) AS total_proc_qty,
       MIN(et.proc_ymd) AS first_proc_ymd,
       MAX(et.proc_ymd) AS last_proc_ymd
FROM wms_inven_etc_prod ep
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_etc_tran et ON ep.etc_prod_seq = et.etc_prod_seq
        AND et.del_yn = 'N'
WHERE ep.etc_seq = 1001
AND ep.del_yn = 'N'
GROUP BY ep.etc_prod_seq, p.prod_nm, ep.req_qty
ORDER BY ep.etc_prod_seq;

-- 특정 위치에서 출고된 예외출고 처리 이력
SELECT et.etc_tran_seq, e.etc_no, e.etc_type_cd,
       et.prod_seq, p.prod_nm,
       et.proc_qty, et.proc_ymd,
       et.sku1, et.sku2, et.lot_no
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
    JOIN mdm_prod p ON et.prod_seq = p.prod_seq
WHERE et.wh_seq = 10
AND et.loc_seq = 1001
AND et.del_yn = 'N'
ORDER BY et.proc_ymd DESC;

-- 작업자별 처리 현황
SELECT et.proc_user_id,
       COUNT(*) AS tran_count,
       SUM(et.proc_qty) AS total_proc_qty,
       MIN(et.proc_ymd) AS first_proc_ymd,
       MAX(et.proc_ymd) AS last_proc_ymd
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.proc_ymd BETWEEN '20250201' AND '20250228'
AND et.del_yn = 'N'
GROUP BY et.proc_user_id
ORDER BY total_proc_qty DESC;

-- 일자별 예외출고 처리 현황
SELECT et.proc_ymd,
       COUNT(DISTINCT et.etc_seq) AS etc_cnt,
       COUNT(*) AS tran_cnt,
       SUM(et.proc_qty) AS total_qty
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.proc_ymd BETWEEN '20250201' AND '20250228'
AND et.del_yn = 'N'
GROUP BY et.proc_ymd
ORDER BY et.proc_ymd;

-- IF 송신 대기 처리 이력
SELECT et.etc_tran_seq, e.etc_no, e.etc_type_cd,
       et.prod_seq, p.prod_nm,
       et.proc_qty, et.proc_ymd
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
    JOIN mdm_prod p ON et.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND et.if_send_yn = 'N'
AND et.del_yn = 'N'
ORDER BY et.reg_dt;

-- 처리 묶음 번호별 조회
SELECT et.proc_bundle_no,
       COUNT(*) AS tran_cnt,
       SUM(et.proc_qty) AS total_qty,
       MIN(et.proc_ymd) AS min_proc_ymd,
       MAX(et.proc_ymd) AS max_proc_ymd,
       COUNT(DISTINCT et.etc_seq) AS etc_cnt
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.proc_bundle_no IS NOT NULL
AND et.proc_ymd = '20250226'
AND et.del_yn = 'N'
GROUP BY et.proc_bundle_no
ORDER BY et.proc_bundle_no;

-- 예외출고 유형별 처리 현황
SELECT e.etc_type_cd,
       COUNT(DISTINCT et.etc_tran_seq) AS tran_cnt,
       SUM(et.proc_qty) AS total_qty,
       COUNT(DISTINCT et.proc_user_id) AS worker_cnt
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.proc_ymd BETWEEN '20250201' AND '20250228'
AND et.del_yn = 'N'
GROUP BY e.etc_type_cd
ORDER BY e.etc_type_cd;

-- 창고별 예외출고 처리 현황
SELECT et.wh_seq, w.wh_nm,
       COUNT(*) AS tran_cnt,
       SUM(et.proc_qty) AS total_qty,
       COUNT(DISTINCT et.prod_seq) AS prod_cnt
FROM wms_inven_etc_tran et
    JOIN mdm_wh w ON et.wh_seq = w.wh_seq
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.proc_ymd BETWEEN '20250201' AND '20250228'
AND et.del_yn = 'N'
GROUP BY et.wh_seq, w.wh_nm
ORDER BY total_qty DESC;

-- LOT 번호별 처리 현황
SELECT et.lot_no,
       COUNT(*) AS tran_cnt,
       SUM(et.proc_qty) AS total_qty,
       MIN(et.proc_ymd) AS first_proc_ymd,
       MAX(et.proc_ymd) AS last_proc_ymd
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
WHERE e.biz_seq = 1
AND et.lot_no IS NOT NULL
AND et.proc_ymd BETWEEN '20250201' AND '20250228'
AND et.del_yn = 'N'
GROUP BY et.lot_no
ORDER BY et.lot_no;

-- 재고 부족으로 부분 처리된 건 조회
SELECT e.etc_no, e.etc_type_cd,
       ep.prod_seq, p.prod_nm,
       ep.req_qty, ep.ex_qty,
       (ep.req_qty - ep.ex_qty) AS shortage_qty
FROM wms_inven_etc_prod ep
    JOIN wms_inven_etc e ON ep.etc_seq = e.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
    JOIN wms_inven_etc_tran et ON ep.etc_prod_seq = et.etc_prod_seq
WHERE e.biz_seq = 1
AND ep.etc_prod_sts_cd = '55' -- 처리중 (부분 처리)
AND ep.ex_qty < ep.req_qty
AND et.del_yn = 'N'
AND ep.del_yn = 'N'
AND e.del_yn = 'N'
GROUP BY e.etc_no, e.etc_type_cd, ep.prod_seq, p.prod_nm, ep.req_qty, ep.ex_qty
ORDER BY shortage_qty DESC;
```