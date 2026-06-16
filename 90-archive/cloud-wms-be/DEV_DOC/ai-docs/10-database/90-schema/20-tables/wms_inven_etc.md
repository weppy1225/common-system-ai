# wms_inven_etc (WMS_예외출고)

## 1. 개요
정상적인 출하 프로세스가 아닌 **예외적인 상황에서의 출고**를 관리하는 테이블.
폐기, 개발용, 샘플, 기증, 불량품 처리 등 다양한 예외 출고 유형을 처리하며, 재고 차감의 근거가 된다.

### 1.1 예외출고 처리 흐름
```
wms_inven_etc (예외출고 헤더)
└─ wms_inven_etc_prod (예외출고 품목)
        └─ wms_inven_etc_tran (예외출고 처리 이력 → 재고 감소)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | etc_seq | integer | N | nextval('wms_inven_etc_seq') | 예외출고 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | etc_no | varchar(30) | N | | 예외출고 번호 (문서번호) |
| | etc_type_cd | varchar(50) | N | | 예외출고 유형 코드 |
| | etc_sts_cd | varchar(50) | N | '11' | 예외출고 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| | erp_wh_cd | varchar(50) | Y | | 출고처 코드 (타시스템) |
| | note | varchar(1000) | Y | | 비고 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **etc_type_cd** (`ETC_TYPE_CD` - [공통코드](#etc_type_cd))
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | EX01 | 폐기 | 폐기 처분 |
> | EX03 | 개발 | 개발용 출고 |
> | EX05 | 샘플 | 샘플 출고 |
> | EX07 | 기증 | 기증용 출고 |
> | EX09 | 식약청출고 | 식약청 제출용 |
> | EX11 | 구매반품 | 구매 반품 |
> | EX13 | 생산투입 | 생산 라인 투입 |
> | EX15 | 유효일초과 | 유통기한 초과 |
> | EX17 | 파손 | 파손품 처리 |
> | EX19 | 불량 | 불량품 처리 |
> | EX21 | 부자재출고 | 부자재 출고 |
> | EX91 | 기타예외 | 기타 예외 출고 |

> **etc_sts_cd** (`ETC_STS_CD`)
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
| wms_inven_etc_PK | etc_seq | Y | Y |
| UIX_wms_inven_etc | biz_seq, etc_no | Y | |
| IX_wms_inven_etc | biz_seq, center_seq, req_ymd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| etc_seq | wms_inven_etc_seq |

---

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_etc_prod | etc_seq | wms_inven_etc_TO_wms_inven_etc_prod |
| wms_inven_etc_tran | etc_seq | wms_inven_etc_TO_wms_inven_etc_tran |

---

## 6. 업무 규칙

### 6.1 예외출고 등록
- `etc_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `EX`)
- 예외출고 등록 시 `etc_sts_cd = '11'(예정)` 으로 시작
- 일반 출하(`wms_outbiz`)와 달리 고객 주문 없이 내부 사유로 출고

### 6.2 예외출고 유형별 처리

#### 6.2.1 EX01 (폐기)
- 재고 가치가 없는 폐기 대상 출고
- 폐기 사유, 폐기 방법 등 별도 관리 필요

#### 6.2.2 EX03 (개발)
- 개발 목적 샘플, 테스트용 출고
- 개발 프로젝트 연동 가능

#### 6.2.3 EX05 (샘플)
- 고객/거래처 샘플 제공
- 샘플 비용 처리 등 별도 관리

#### 6.2.4 EX07 (기증)
- 기부, 홍보용 출고
- 기증처 정보 관리

#### 6.2.5 EX09 (식약청출고)
- 규제 기관 제출용 샘플
- 식약청 보고 등 연동

#### 6.2.6 EX11 (구매반품)
- 구매처 반품
- 구매 정보 연동

#### 6.2.7 EX13 (생산투입)
- 생산 라인 원자재 투입
- 생산 관리 시스템 연동

#### 6.2.8 EX15 (유효일초과)
- 유통기한 초과로 폐기/반품
- 임박재고 관리와 연동

#### 6.2.9 EX17 (파손)
- 물류 작업 중 파손
- 파손 보고서 연동

#### 6.2.10 EX19 (불량)
- 품질 불량품 처리
- QC 정보 연동

#### 6.2.11 EX21 (부자재출고)
- 포장재, 라벨 등 부자재 출고
- 부자재 재고 관리와 연동

#### 6.2.12 EX91 (기타예외)
- 위 유형에 해당하지 않는 예외 출고

### 6.3 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 33 | 지정 | 출고 위치/재고 지정 완료 |
| 55 | 처리중 | 실제 출고 작업 진행 중 |
| 77 | 확정 | 출고 완료 |

### 6.4 예외출고 처리 단계

#### 6.4.1 예외출고 예정
- 예외출고 정보 등록 (`etc_sts_cd = '11'`)
- 요청 부서/담당자, 사유 등 입력

#### 6.4.2 재고 지정
- 출고할 재고 위치 지정 (`etc_sts_cd = '33'`)
- `wms_inven_etc_prod`에 예상 정보 입력

#### 6.4.3 출고 처리중
- 실제 출고 작업 시작 (`etc_sts_cd = '55'`)
- 부분 출고 가능

#### 6.4.4 출고 확정
- 출고 완료 처리 (`etc_sts_cd = '77'`)
- `wms_inven_etc_tran` 생성하여 실제 재고 차감
- 재고(`wms_inven`) 감소

### 6.5 수량 관리
- `wms_inven_etc_prod.req_qty` : 요청 수량
- `wms_inven_etc_prod.ex_qty` : 누적 처리 수량
- `wms_inven_etc_tran.proc_qty` : 각 처리 건별 수량
- `ex_qty` = 동일 `etc_prod_seq`의 `proc_qty` 합계

### 6.6 재고 차감
- 예외출고 확정 시 실제 재고 차감
- 차감 조건: 동일한 `biz_seq`, `center_seq`, `prod_seq`, `sku1`, `sku2`, `wh_seq`, `loc_seq` 조합의 재고 존재
- `proc_qty`만큼 `inven_qty` 감소
- 재고 부족 시 출고 불가 또는 부분 출고만 가능

### 6.7 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 예외출고 정보 송신 여부
- `if_key` : 외부 시스템 연동 키
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.8 취소/삭제
- 확정(`'77'`)된 예외출고는 취소 불가 (재고 변동 발생)
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 관련 하위 데이터도 논리삭제 처리

### 6.9 일반 출하와의 차이점
| 구분 | 일반 출하(wms_outbiz) | 예외출고(wms_inven_etc) |
|------|---------------------|------------------------|
| 대상 | 고객 주문 | 내부 사유 |
| 연동 | 송장, 택배, 상차 | 단순 재고 차감 |
| 회계 | 매출 인식 | 비용/폐기 처리 |
| 승인 | 일반적 | 관리자 승인 필요 |

---

## 7. 주요 조회 예시

```sql
-- 예외출고 유형별 현황
SELECT etc_type_cd, etc_sts_cd, COUNT(*) AS cnt
FROM wms_inven_etc
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY etc_type_cd, etc_sts_cd
ORDER BY etc_type_cd, etc_sts_cd;

-- 미처리 예외출고 목록 (예정/지정/처리중)
SELECT etc_no, etc_type_cd, etc_sts_cd,
       req_ymd, req_user_nm, req_dept_nm,
       note
FROM wms_inven_etc
WHERE biz_seq = 1
AND center_seq = 1
AND etc_sts_cd NOT IN ('77')
AND del_yn = 'N'
ORDER BY req_ymd, etc_no;

-- 예외출고 상세 조회 (품목 포함)
SELECT e.etc_no, e.req_ymd, e.req_user_nm, e.req_dept_nm,
       e.etc_type_cd, e.etc_sts_cd, e.note,
       ep.prod_seq, p.prod_nm, p.prod_no,
       ep.req_qty, ep.ex_qty,
       ep.etc_prod_sts_cd,
       ep.est_exp_ymd, ep.est_lot_no
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
    JOIN mdm_prod p ON ep.prod_seq = p.prod_seq
WHERE e.biz_seq = 1
AND e.etc_no = 'EX2502260001'
AND e.del_yn = 'N'
ORDER BY ep.etc_prod_seq;

-- 부서별 예외출고 현황
SELECT req_dept_nm,
       COUNT(*) AS etc_cnt,
       SUM(ep.req_qty) AS total_req_qty,
       SUM(ep.ex_qty) AS total_proc_qty
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
WHERE e.biz_seq = 1
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND e.del_yn = 'N'
GROUP BY req_dept_nm
ORDER BY total_req_qty DESC;

-- 예외출고 처리 이력 조회
SELECT e.etc_no, e.req_ymd,
       et.etc_tran_seq, et.prod_seq, p.prod_nm,
       et.proc_qty, et.proc_ymd, et.proc_hms, et.proc_user_id,
       et.wh_seq, w.wh_nm,
       et.loc_seq, l.loc_nm,
       et.sku1, et.sku2, et.lot_no
FROM wms_inven_etc_tran et
    JOIN wms_inven_etc e ON et.etc_seq = e.etc_seq
    JOIN mdm_prod p ON et.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON et.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON et.loc_seq = l.loc_seq
WHERE e.biz_seq = 1
AND e.etc_no = 'EX2502260001'
AND et.del_yn = 'N'
ORDER BY et.proc_ymd, et.proc_hms;

-- 폐기/불량 처리 현황 (EX01, EX17, EX19)
SELECT e.etc_type_cd,
       COUNT(*) AS etc_cnt,
       SUM(ep.req_qty) AS total_qty,
       SUM(CASE WHEN e.etc_sts_cd = '77' THEN ep.req_qty ELSE 0 END) AS completed_qty
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
WHERE e.biz_seq = 1
AND e.etc_type_cd IN ('EX01', 'EX17', 'EX19')
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND e.del_yn = 'N'
GROUP BY e.etc_type_cd
ORDER BY e.etc_type_cd;

-- IF 송신 대기 건 조회
SELECT etc_no, etc_type_cd, etc_sts_cd,
       req_ymd, req_user_nm, req_dept_nm
FROM wms_inven_etc
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 사유별 예외출고 현황
SELECT etc_type_cd, note,
       COUNT(*) AS cnt,
       SUM(ep.req_qty) AS total_qty
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
WHERE e.biz_seq = 1
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND e.del_yn = 'N'
AND e.note IS NOT NULL
GROUP BY etc_type_cd, note
ORDER BY cnt DESC;

-- 일자별 예외출고 처리 현황
SELECT e.req_ymd,
       COUNT(DISTINCT e.etc_seq) AS etc_cnt,
       COUNT(DISTINCT e.etc_type_cd) AS type_cnt,
       SUM(ep.req_qty) AS total_req_qty,
       SUM(ep.ex_qty) AS total_proc_qty
FROM wms_inven_etc e
    JOIN wms_inven_etc_prod ep ON e.etc_seq = ep.etc_seq
WHERE e.biz_seq = 1
AND e.req_ymd BETWEEN '20250201' AND '20250228'
AND e.del_yn = 'N'
GROUP BY e.req_ymd
ORDER BY e.req_ymd;
```