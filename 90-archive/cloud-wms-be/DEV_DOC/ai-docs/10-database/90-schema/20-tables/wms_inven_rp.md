# wms_inven_rp (WMS_품목전환)

## 1. 개요
재고 품목을 **다른 품목으로 전환**하는 작업을 관리하는 테이블.
예를 들어, 대표품목을 구성품목으로 분해하거나, 반대로 구성품목을 대표품목으로 조립하는 등의 품목 전환 작업을 처리한다.

### 1.1 품목전환 처리 흐름
```
wms_inven_rp (품목전환 헤더)
└─ wms_inven_rp_prod (품목전환 품목)
        ├─ 기준품목(st_yn = 'Y') : 전환의 기준이 되는 품목
        └─ 대상품목(st_yn = 'N') : 전환될 품목
              └─ wms_inven_rp_tran (품목전환 처리 이력 → 재고 변동)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | rp_seq | integer | N | nextval('wms_inven_rp_seq') | 품목전환 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | rp_no | varchar(30) | N | | 품목전환 번호 (문서번호) |
| | rp_type_cd | varchar(50) | N | | 품목전환 유형 코드 |
| | rp_sts_cd | varchar(50) | N | '11' | 품목전환 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **rp_type_cd** (`RP_TYPE_CD` - [공통코드](#rp_type_cd))
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | RP01 | 품목전환 | 일반 품목 전환 |

> **rp_sts_cd** (`RP_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 33 | 지정 |
> | 77 | 완료 |

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
| wms_inven_rp_PK | rp_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| rp_seq | wms_inven_rp_seq |

---

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_rp_prod | rp_seq | wms_inven_rp_TO_wms_inven_rp_prod |
| wms_inven_rp_tran | rp_seq | wms_inven_rp_TO_wms_inven_rp_tran |

---

## 6. 업무 규칙

### 6.1 품목전환 등록
- `rp_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `RP`)
- 품목전환 등록 시 `rp_sts_cd = '11'(예정)` 으로 시작
- `mdm_rp_prod` 마스터 데이터를 기반으로 전환 관계 정의

### 6.2 품목전환 유형

#### 6.2.1 RP01 (품목전환)
- 기준품목을 대상품목으로 전환
- 예: 완제품 → 구성품목들로 분해, 또는 구성품목들 → 완제품으로 조립
- 전환 비율은 `mdm_rp_prod`의 `qty`에 따라 결정

### 6.3 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 33 | 지정 | 전환 위치/재고 지정 완료 |
| 77 | 완료 | 전환 작업 완료 |

### 6.4 품목전환 처리 단계

#### 6.4.1 품목전환 예정
- 품목전환 정보 등록 (`rp_sts_cd = '11'`)
- 기준품목과 대상품목 지정 (`wms_inven_rp_prod`에 등록)
- `st_yn`으로 기준품목 여부 구분

#### 6.4.2 재고 지정
- 전환할 재고 위치 지정 (`rp_sts_cd = '33'`)
- 기준품목의 출고 위치와 대상품목의 입고 위치 지정
- `wms_inven_rp_tran`을 통해 처리 준비

#### 6.4.3 전환 완료
- 실제 전환 작업 완료 (`rp_sts_cd = '77'`)
- `wms_inven_rp_tran` 생성하여 실제 재고 변동 처리
- 기준품목 재고 감소 + 대상품목 재고 증가

### 6.5 전환 관계
- `wms_inven_rp_prod`에서 기준품목(`st_yn = 'Y'`)과 대상품목(`st_yn = 'N'`)을 함께 관리
- 하나의 기준품목에 여러 대상품목이 연결될 수 있음
- 대상품목은 여러 기준품목에 속할 수 없음 (단일 전환 관계)

### 6.6 수량 관리
- 기준품목의 `req_qty` : 전환할 기준품목 수량
- 대상품목의 `req_qty` : 전환 후 생성될 대상품목 수량
- 전환 비율은 `mdm_rp_prod.qty`에 따라 자동 계산
- 예: 기준품목 1개 → 대상품목 A 2개, 대상품목 B 3개

### 6.7 재고 변동 처리

#### 6.7.1 기준품목 재고 감소
- 기준품목(`st_yn = 'Y'`)의 재고에서 전환 수량만큼 차감
- `wms_inven_rp_tran`에서 `st_yn = 'Y'` 레코드로 차감 처리
- 차감 위치: `wh_seq`, `loc_seq`, `sku1`, `sku2` 지정 필요

#### 6.7.2 대상품목 재고 증가
- 대상품목(`st_yn = 'N'`)의 재고로 전환 수량만큼 증가
- `wms_inven_rp_tran`에서 `st_yn = 'N'` 레코드로 증가 처리
- 입고 위치: `wh_seq`, `loc_seq` 지정 필요
- SKU 정보는 대상품목에 맞게 생성/지정

### 6.8 재고 부족 처리
- 기준품목의 재고가 전환 수량보다 부족하면 전환 불가
- 부분 전환은 허용되지 않음 (전체 수량 한 번에 처리)

### 6.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 품목전환 정보 송신 여부
- `if_key` : 외부 시스템 연동 키
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.10 취소/삭제
- 완료(`'77'`)된 품목전환은 취소 불가 (재고 변동 발생)
- 미완료 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제
- 삭제 시 관련 하위 데이터도 논리삭제 처리

### 6.11 유사 기능과의 차이점

| 기능 | 설명 | 적용场景 |
|------|------|----------|
| 세트작업(st) | 세트 구성/해체 | 완제품 ↔ 구성품 |
| 품목전환(rp) | 품목 자체 전환 | 제품 ↔ 원자재, 규격 변경 |
| 재고이동(mv) | 위치만 변경 | 동일 품목 위치 변경 |
| 재고조정(ad) | 수량 증감 | 재고 실사 조정 |

---

## 7. 주요 조회 예시

```sql
-- 품목전환 현황
SELECT rp_no, rp_type_cd, rp_sts_cd,
       req_ymd, req_user_nm, req_dept_nm
FROM wms_inven_rp
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
ORDER BY rp_no;

-- 미처리 품목전환 목록 (예정/지정)
SELECT rp_no, rp_type_cd, rp_sts_cd,
       req_ymd, req_user_nm, note
FROM wms_inven_rp
WHERE biz_seq = 1
AND center_seq = 1
AND rp_sts_cd IN ('11', '33')
AND del_yn = 'N'
ORDER BY req_ymd, rp_no;

-- 품목전환 상세 조회 (품목 포함)
SELECT r.rp_no, r.req_ymd, r.req_user_nm,
       rp.prod_seq, p.prod_nm, p.prod_no,
       rp.st_yn,
       CASE WHEN rp.st_yn = 'Y' THEN '기준품목' ELSE '대상품목' END AS prod_type,
       rp.req_qty,
       rp.est_exp_ymd, rp.est_lot_no
FROM wms_inven_rp r
    JOIN wms_inven_rp_prod rp ON r.rp_seq = rp.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
WHERE r.biz_seq = 1
AND r.rp_no = 'RP2502260001'
AND r.del_yn = 'N'
ORDER BY rp.st_yn DESC, rp.prod_seq;

-- 기준품목별 대상품목 전환 정보
SELECT
    base.prod_seq AS base_prod_seq,
    base_p.prod_nm AS base_prod_nm,
    base.req_qty AS base_qty,
    target.prod_seq AS target_prod_seq,
    target_p.prod_nm AS target_prod_nm,
    target.req_qty AS target_qty,
    r.rp_no, r.rp_sts_cd
FROM wms_inven_rp_prod base
    JOIN wms_inven_rp r ON base.rp_seq = r.rp_seq
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
    JOIN wms_inven_rp_prod target ON base.rp_seq = target.rp_seq
    JOIN mdm_prod target_p ON target.prod_seq = target_p.prod_seq
WHERE r.biz_seq = 1
AND base.st_yn = 'Y'
AND target.st_yn = 'N'
AND r.del_yn = 'N'
AND base.del_yn = 'N'
AND target.del_yn = 'N'
ORDER BY r.rp_no, base.prod_seq, target.prod_seq;

-- 품목전환 처리 이력 조회
SELECT rt.rp_tran_seq, r.rp_no,
       rt.st_yn,
       CASE WHEN rt.st_yn = 'Y' THEN '기준품목' ELSE '대상품목' END AS prod_type,
       rt.prod_seq, p.prod_nm,
       rt.proc_qty,
       rt.wh_seq, w.wh_nm,
       rt.loc_seq, l.loc_nm,
       rt.sku1, rt.sku2, rt.lot_no,
       rt.proc_ymd, rt.proc_hms, rt.proc_user_id
FROM wms_inven_rp_tran rt
    JOIN wms_inven_rp r ON rt.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rt.prod_seq = p.prod_seq
    LEFT JOIN mdm_wh w ON rt.wh_seq = w.wh_seq
    LEFT JOIN mdm_loc l ON rt.loc_seq = l.loc_seq
WHERE r.biz_seq = 1
AND r.rp_no = 'RP2502260001'
AND rt.del_yn = 'N'
ORDER BY rt.st_yn DESC, rt.proc_ymd, rt.proc_hms;

-- 일자별 품목전환 처리 현황
SELECT r.req_ymd,
       COUNT(*) AS rp_cnt,
       SUM(CASE WHEN r.rp_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
       COUNT(DISTINCT rp.prod_seq) AS prod_cnt
FROM wms_inven_rp r
    JOIN wms_inven_rp_prod rp ON r.rp_seq = rp.rp_seq
WHERE r.biz_seq = 1
AND r.req_ymd BETWEEN '20250201' AND '20250228'
AND r.del_yn = 'N'
GROUP BY r.req_ymd
ORDER BY r.req_ymd;

-- IF 송신 대기 건 조회
SELECT rp_no, rp_type_cd, rp_sts_cd,
       req_ymd, req_user_nm
FROM wms_inven_rp
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 품목별 전환 이력 (해당 품목이 기준품목으로 사용된 경우)
SELECT r.rp_no, r.req_ymd,
       '기준품목' AS role,
       rp.prod_seq, p.prod_nm,
       rp.req_qty,
       rt.proc_ymd, rt.proc_qty AS actual_qty
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    LEFT JOIN wms_inven_rp_tran rt ON rp.rp_seq = rt.rp_seq 
        AND rp.prod_seq = rt.prod_seq AND rt.st_yn = 'Y'
WHERE rp.prod_seq = 1001
AND rp.st_yn = 'Y'
AND r.del_yn = 'N'
ORDER BY r.req_ymd DESC;

-- 품목별 전환 이력 (해당 품목이 대상품목으로 전환된 경우)
SELECT r.rp_no, r.req_ymd,
       '대상품목' AS role,
       base.prod_seq AS base_prod_seq,
       base_p.prod_nm AS base_prod_nm,
       rp.prod_seq, p.prod_nm,
       rp.req_qty,
       rt.proc_ymd, rt.proc_qty AS actual_qty
FROM wms_inven_rp_prod rp
    JOIN wms_inven_rp r ON rp.rp_seq = r.rp_seq
    JOIN mdm_prod p ON rp.prod_seq = p.prod_seq
    JOIN wms_inven_rp_prod base ON r.rp_seq = base.rp_seq AND base.st_yn = 'Y'
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
    LEFT JOIN wms_inven_rp_tran rt ON rp.rp_seq = rt.rp_seq 
        AND rp.prod_seq = rt.prod_seq AND rt.st_yn = 'N'
WHERE rp.prod_seq = 2002
AND rp.st_yn = 'N'
AND r.del_yn = 'N'
ORDER BY r.req_ymd DESC;

-- 미완료 품목전환 중 재고 부족 가능성 있는 건
SELECT r.rp_no, r.req_ymd,
       base.prod_seq, base_p.prod_nm,
       base.req_qty,
       COALESCE(SUM(i.inven_qty), 0) AS current_inven
FROM wms_inven_rp r
    JOIN wms_inven_rp_prod base ON r.rp_seq = base.rp_seq AND base.st_yn = 'Y'
    JOIN mdm_prod base_p ON base.prod_seq = base_p.prod_seq
    LEFT JOIN wms_inven i ON i.biz_seq = r.biz_seq 
        AND i.center_seq = r.center_seq
        AND i.prod_seq = base.prod_seq
        AND i.del_yn = 'N'
WHERE r.biz_seq = 1
AND r.rp_sts_cd != '77'
AND r.del_yn = 'N'
GROUP BY r.rp_no, r.req_ymd, base.prod_seq, base_p.prod_nm, base.req_qty
HAVING COALESCE(SUM(i.inven_qty), 0) < base.req_qty
ORDER BY r.req_ymd;
```