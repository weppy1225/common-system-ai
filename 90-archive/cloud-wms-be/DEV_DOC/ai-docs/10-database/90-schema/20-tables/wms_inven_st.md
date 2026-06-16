# wms_inven_st (WMS_세트작업)

## 1. 개요
여러 품목을 조립하여 **세트(Set) 상품을 생성**하거나, 반대로 세트 상품을 **구성품목으로 분해**하는 작업을 관리하는 테이블.
세트구성 여부(`assembly_yn`)에 따라 조립(세트구성) 또는 분해(세트해체) 작업을 처리한다.

### 1.1 세트작업 처리 흐름
```
wms_inven_st (세트작업 헤더)
└─ wms_inven_st_prod (세트작업 품목)
        ├─ 세트품목(st_yn = 'Y') : 조립/분해의 대상이 되는 세트 품목
        └─ 구성품목(st_yn = 'N') : 세트를 구성하는 개별 품목
              └─ wms_inven_st_tran (세트작업 처리 이력 → 재고 변동)
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | st_seq | integer | N | nextval('wms_inven_st_seq') | 세트작업 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | wh_seq | integer | N | | 작업창고 SEQ → mdm_wh |
| | st_no | varchar(30) | N | | 세트작업 번호 (문서번호) |
| | assembly_yn | char(1) | N | 'N' | 세트구성 여부 |
| | st_type_cd | varchar(50) | N | | 세트작업 유형 코드 |
| | st_sts_cd | varchar(50) | N | '11' | 세트작업 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | req_no | varchar(30) | Y | | 문서 번호 (타시스템) |
| | note | varchar(1000) | Y | | 비고 |
| | if_key | varchar(50) | Y | | IF 연동 키 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **assembly_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | Y | 세트구성 | 조립 작업 (구성품목 → 세트) |
> | N | 세트해체 | 분해 작업 (세트 → 구성품목) |

> **st_type_cd** (`ST_TYPE_CD` - [공통코드](#st_type_cd))
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | ST01 | 세트작업 | 세트 구성/조립 |
> | ST03 | 해체작업 | 세트 해체/분해 |

> **st_sts_cd** (`ST_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
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
| wms_inven_st_PK | st_seq | Y | Y |
| UIX_wms_inven_st | biz_seq, st_no | Y | |
| IX_wms_inven_st | biz_seq, center_seq, req_ymd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| st_seq | wms_inven_st_seq |

---

## 5. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_st_prod | st_seq | wms_inven_st_TO_wms_inven_st_prod |
| wms_inven_st_tran | st_seq | wms_inven_st_TO_wms_inven_st_tran |

---

## 6. 업무 규칙

### 6.1 세트작업 등록
- `st_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `ST`)
- 세트작업 등록 시 `st_sts_cd = '11'(예정)` 으로 시작
- `mdm_st_prod` 마스터 데이터를 기반으로 세트 구성 정보 정의

### 6.2 세트구성 여부에 따른 작업 유형

#### 6.2.1 조립 작업 (assembly_yn = 'Y')
- 여러 구성품목을 조립하여 하나의 세트품목 생성
- 구성품목 재고 감소 + 세트품목 재고 증가
- `st_type_cd`는 'ST01'(세트작업)

#### 6.2.2 분해 작업 (assembly_yn = 'N')
- 하나의 세트품목을 분해하여 구성품목으로 해체
- 세트품목 재고 감소 + 구성품목 재고 증가
- `st_type_cd`는 'ST03'(해체작업)

### 6.3 상태 코드 변경

| 상태 | 설명 | 비고 |
|------|------|------|
| 11 | 예정 | 최초 등록 상태 |
| 55 | 처리중 | 작업 진행 중 (일부 처리) |
| 77 | 완료 | 작업 완료 |

### 6.4 세트작업 처리 단계

#### 6.4.1 세트작업 예정
- 세트작업 정보 등록 (`st_sts_cd = '11'`)
- 세트품목과 구성품목 지정 (`wms_inven_st_prod`에 등록)
- `mdm_st_prod_seq`로 마스터 세트 구성 정보 연결

#### 6.4.2 작업 처리중
- 실제 작업 시작 (`st_sts_cd = '55'`)
- `wms_inven_st_tran`을 통해 처리 내역 기록
- 부분 처리 가능 (일부 수량만 우선 처리)

#### 6.4.3 작업 완료
- 모든 수량 처리 완료 (`st_sts_cd = '77'`)
- 재고 변동 최종 반영

### 6.5 세트 구성 정보
- `wms_inven_st_prod`에서 세트품목(`st_yn = 'Y'`)과 구성품목(`st_yn = 'N'`)을 함께 관리
- `mdm_st_prod_seq`로 마스터 세트 구성 정보 참조
- 마스터 정보에는 세트 구성 비율(`qty`)이 정의됨

### 6.6 수량 관리

#### 6.6.1 조립 작업 (assembly_yn = 'Y')
- 구성품목 `req_qty` : 조립에 사용될 구성품목 수량
- 세트품목 `req_qty` : 생성될 세트 수량
- 구성품목 수량 = 세트품목 수량 × 구성 비율

#### 6.6.2 분해 작업 (assembly_yn = 'N')
- 세트품목 `req_qty` : 분해할 세트 수량
- 구성품목 `req_qty` : 분해 후 생성될 구성품목 수량
- 구성품목 수량 = 세트품목 수량 × 구성 비율

### 6.7 재고 변동 처리

#### 6.7.1 조립 작업 (assembly_yn = 'Y')
| 품목 구분 | 재고 변동 | 위치 |
|----------|----------|------|
| 구성품목 | 감소 | FR 위치 (출고) |
| 세트품목 | 증가 | TO 위치 (입고) |

#### 6.7.2 분해 작업 (assembly_yn = 'N')
| 품목 구분 | 재고 변동 | 위치 |
|----------|----------|------|
| 세트품목 | 감소 | FR 위치 (출고) |
| 구성품목 | 증가 | TO 위치 (입고) |

### 6.8 재고 부족 처리
- 조립 작업 시 구성품목 재고 부족 시 작업 불가
- 분해 작업 시 세트품목 재고 부족 시 작업 불가
- 부분 처리 가능 (가용 재고만큼만 처리)

### 6.9 IF 연동
- `if_send_yn` : 외부 시스템(ERP)으로 세트작업 정보 송신 여부
- `if_key` : 외부 시스템 연동 키
- `if_err_seq` : 송신 실패 시 에러 SEQ 연결

### 6.10 취소/삭제
- 완료(`'77'`)된 세트작업은 취소 불가 (재고 변동 발생)
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
-- 세트작업 유형별 현황
SELECT st_type_cd, assembly_yn, st_sts_cd, COUNT(*) AS cnt
FROM wms_inven_st
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY st_type_cd, assembly_yn, st_sts_cd
ORDER BY st_type_cd, assembly_yn, st_sts_cd;

-- 미처리 세트작업 목록 (예정/처리중)
SELECT st_no, st_type_cd, assembly_yn, st_sts_cd,
       req_ymd, req_user_nm, req_dept_nm,
       wh_seq, note
FROM wms_inven_st
WHERE biz_seq = 1
AND center_seq = 1
AND st_sts_cd IN ('11', '55')
AND del_yn = 'N'
ORDER BY req_ymd, st_no;

-- 세트작업 상세 조회 (품목 포함)
SELECT s.st_no, s.req_ymd, s.assembly_yn, s.st_type_cd,
       sp.prod_seq, p.prod_nm, p.prod_no,
       sp.st_yn,
       CASE WHEN sp.st_yn = 'Y' THEN '세트품목' ELSE '구성품목' END AS prod_type,
       sp.req_qty,
       sp.est_exp_ymd, sp.est_lot_no,
       sp.mdm_st_prod_seq
FROM wms_inven_st s
    JOIN wms_inven_st_prod sp ON s.st_seq = sp.st_seq
    JOIN mdm_prod p ON sp.prod_seq = p.prod_seq
WHERE s.biz_seq = 1
AND s.st_no = 'ST2502260001'
AND s.del_yn = 'N'
ORDER BY sp.st_yn DESC, sp.prod_seq;

-- 조립 작업 현황 (assembly_yn = 'Y')
SELECT st_no, req_ymd, st_sts_cd,
       wh_seq, req_user_nm
FROM wms_inven_st
WHERE biz_seq = 1
AND assembly_yn = 'Y'
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
ORDER BY req_ymd;

-- 분해 작업 현황 (assembly_yn = 'N')
SELECT st_no, req_ymd, st_sts_cd,
       wh_seq, req_user_nm
FROM wms_inven_st
WHERE biz_seq = 1
AND assembly_yn = 'N'
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
ORDER BY req_ymd;

-- 세트별 구성품목 정보 (마스터 기준)
SELECT
    set_prod.prod_seq AS set_prod_seq,
    set_p.prod_nm AS set_prod_nm,
    comp.prod_seq AS comp_prod_seq,
    comp_p.prod_nm AS comp_prod_nm,
    sp.req_qty AS set_qty,
    sp2.req_qty AS comp_qty,
    ROUND(sp2.req_qty / NULLIF(sp.req_qty, 0), 2) AS comp_rate
FROM wms_inven_st s
    JOIN wms_inven_st_prod sp ON s.st_seq = sp.st_seq AND sp.st_yn = 'Y'
    JOIN mdm_prod set_p ON sp.prod_seq = set_p.prod_seq
    JOIN wms_inven_st_prod sp2 ON s.st_seq = sp2.st_seq AND sp2.st_yn = 'N'
    JOIN mdm_prod comp_p ON sp2.prod_seq = comp_p.prod_seq
WHERE s.st_no = 'ST2502260001'
AND s.del_yn = 'N'
ORDER BY comp_p.prod_nm;

-- 일자별 세트작업 처리 현황
SELECT s.req_ymd,
       COUNT(*) AS st_cnt,
       SUM(CASE WHEN s.assembly_yn = 'Y' THEN 1 ELSE 0 END) AS assembly_cnt,
       SUM(CASE WHEN s.assembly_yn = 'N' THEN 1 ELSE 0 END) AS disassembly_cnt,
       SUM(CASE WHEN s.st_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_inven_st s
WHERE s.biz_seq = 1
AND s.req_ymd BETWEEN '20250201' AND '20250228'
AND s.del_yn = 'N'
GROUP BY s.req_ymd
ORDER BY s.req_ymd;

-- IF 송신 대기 건 조회
SELECT st_no, st_type_cd, assembly_yn, st_sts_cd,
       req_ymd, req_user_nm
FROM wms_inven_st
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 작업창고별 세트작업 현황
SELECT s.wh_seq, w.wh_nm,
       COUNT(*) AS st_cnt,
       SUM(CASE WHEN s.assembly_yn = 'Y' THEN 1 ELSE 0 END) AS assembly_cnt,
       SUM(CASE WHEN s.assembly_yn = 'N' THEN 1 ELSE 0 END) AS disassembly_cnt
FROM wms_inven_st s
    JOIN mdm_wh w ON s.wh_seq = w.wh_seq
WHERE s.biz_seq = 1
AND s.req_ymd BETWEEN '20250201' AND '20250228'
AND s.del_yn = 'N'
GROUP BY s.wh_seq, w.wh_nm
ORDER BY s.wh_seq;

-- 요청 부서별 세트작업 현황
SELECT req_dept_nm,
       COUNT(*) AS st_cnt,
       SUM(sp.req_qty) AS total_set_qty
FROM wms_inven_st s
    JOIN wms_inven_st_prod sp ON s.st_seq = sp.st_seq
WHERE s.biz_seq = 1
AND sp.st_yn = 'Y'
AND s.req_ymd BETWEEN '20250201' AND '20250228'
AND s.del_yn = 'N'
GROUP BY req_dept_nm
ORDER BY total_set_qty DESC;

-- 미완료 세트작업 중 재고 부족 가능성 있는 건 (조립 작업)
SELECT s.st_no, s.req_ymd,
       set_prod.prod_seq AS set_prod_seq,
       set_p.prod_nm AS set_prod_nm,
       comp.prod_seq AS comp_prod_seq,
       comp_p.prod_nm AS comp_prod_nm,
       comp.req_qty AS required_qty,
       COALESCE(SUM(i.inven_qty), 0) AS current_inven
FROM wms_inven_st s
    JOIN wms_inven_st_prod set_prod ON s.st_seq = set_prod.st_seq AND set_prod.st_yn = 'Y'
    JOIN mdm_prod set_p ON set_prod.prod_seq = set_p.prod_seq
    JOIN wms_inven_st_prod comp ON s.st_seq = comp.st_seq AND comp.st_yn = 'N'
    JOIN mdm_prod comp_p ON comp.prod_seq = comp_p.prod_seq
    LEFT JOIN wms_inven i ON i.biz_seq = s.biz_seq 
        AND i.center_seq = s.center_seq
        AND i.prod_seq = comp.prod_seq
        AND i.del_yn = 'N'
WHERE s.biz_seq = 1
AND s.assembly_yn = 'Y'
AND s.st_sts_cd != '77'
AND s.del_yn = 'N'
GROUP BY s.st_no, s.req_ymd, set_prod.prod_seq, set_p.prod_nm,
         comp.prod_seq, comp_p.prod_nm, comp.req_qty
HAVING COALESCE(SUM(i.inven_qty), 0) < comp.req_qty
ORDER BY s.req_ymd;
```