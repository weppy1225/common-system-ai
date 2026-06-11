# wms_inven_inout (WMS_재고_수불)

## 1. 개요
모든 **재고 수불(입고/출고/이동/조정)의 상세 이력**을 관리하는 테이블.
재고 변동이 발생할 때마다 기록되며, 재고 추적과 감사(Audit)의 근거 자료가 된다.

### 1.1 재고 수불 이력 흐름
```
재고 변동 발생 → wms_inven_inout 저장 → wms_inven 증감 반영
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inven_inout_seq | bigint | N | nextval('wms_inven_inout_seq') | 재고 수불 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ |
| | prod_seq | integer | N | | 품목 SEQ |
| | proc_ymd | varchar(8) | N | | 처리 연월일 |
| | proc_hmsms | varchar(9) | N | | 처리 시분초밀리초 |
| | inout_type_cd | varchar(50) | N | | 수불 유형 코드 |
| | inout_dtl_cd | varchar(50) | N | | 수불 상세 코드 |
| | proc_qty | decimal(10,2) | N | 0 | 처리 수량 |
| | proc_user_id | varchar(20) | N | | 처리자 ID |
| | center_seq | integer | N | | 센터 SEQ |
| | fr_wh_seq | integer | Y | | FROM 창고 SEQ |
| | fr_loc_seq | bigint | Y | | FROM 위치 SEQ |
| | fr_sku1 | varchar(100) | Y | | FROM SKU1 |
| | fr_sku2 | varchar(100) | Y | | FROM SKU2 |
| | to_wh_seq | integer | Y | | TO 창고 SEQ |
| | to_loc_seq | bigint | Y | | TO 위치 SEQ |
| | to_sku1 | varchar(100) | Y | | TO SKU1 |
| | to_sku2 | varchar(100) | Y | | TO SKU2 |
| | fr_lot_no | varchar(30) | Y | | FROM LOT 번호 |
| | fr_mng_ymd | varchar(8) | Y | | FROM 입고/제조일자 |
| | fr_exp_ymd | varchar(8) | Y | | FROM 유통기한 |
| | to_lot_no | varchar(30) | Y | | TO LOT 번호 |
| | to_mng_ymd | varchar(8) | Y | | TO 입고/제조일자 |
| | to_exp_ymd | varchar(8) | Y | | TO 유통기한 |
| | proc_bundle_no | varchar(30) | Y | | 처리 묶음 번호 |
| | req_seq | integer | N | | 요청 SEQ |
| | req_no | varchar(30) | N | | 업무 번호 |
| | proc_sts_cd | char(1) | N | 'Y' | 처리 상태 코드 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inout_type_cd** (`INOUT_TYPE_CD` - 공통코드)
>
> | 코드 | 코드명 |
> |---|---|
> | IW | 입고 |
> | RT | 반품 |
> | OW | 출고 |
> | OB | 출하 |
> | IM | 재고이동 |
> | AD | 재고조정 |
> | EX | 예외출고 |
> | RP | 품목전환 |
> | ST | 세트작업 |
> | DV | SKU분할 |
> | MR | SKU병합 |
> | SC | SKU변경 |

> **proc_sts_cd** (`PROC_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | Y | 정상 처리 |
> | N | 취소/삭제됨 |

---

## 3. 인덱스

| 인덱스명 | 컬럼 | UNIQUE | PK |
|---|---|---|---|
| wms_inven_inout_PK | inven_inout_seq | Y | Y |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inven_inout_seq | wms_inven_inout_seq |

---

## 5. 업무 규칙

### 5.1 수불 이력 기록
- 모든 재고 변동은 반드시 이력으로 기록
- 재고 증가/감소/이동 각각에 대해 상세 정보 저장

### 5.2 수불 유형별 처리

| 유형 | 설명 | FR/TO | 수량 영향 |
|------|------|-------|----------|
| IW (입고) | 창고 입고 | TO만 존재 | + |
| RT (반품) | 반품 입고 | TO만 존재 | + |
| OW (출고) | 창고 출고 | FR만 존재 | - |
| OB (출하) | 출하 처리 | FR만 존재 | - |
| IM (재고이동) | 위치 이동 | FR, TO 모두 존재 | 변화 없음 |
| AD (재고조정) | 실사 조정 | FR 또는 TO | +/- |
| EX (예외출고) | 예외 출고 | FR만 존재 | - |
| RP (품목전환) | 품목 전환 | FR, TO 모두 존재 | 변화 없음 |
| ST (세트작업) | 세트 조립/분해 | FR, TO 모두 존재 | 변화 없음 |
| DV (SKU분할) | SKU 분할 | FR, TO 모두 존재 | 변화 없음 |
| MR (SKU병합) | SKU 병합 | FR, TO 모두 존재 | 변화 없음 |
| SC (SKU변경) | SKU 변경 | FR, TO 모두 존재 | 변화 없음 |

### 5.3 FR/TO 정보
- **FROM 정보**: 재고가 감소한 위치/SKU/LOT (출고, 이동 원천)
- **TO 정보**: 재고가 증가한 위치/SKU/LOT (입고, 이동 대상)
- 단순 증감(입고/출고)은 해당하는 쪽만 기록

### 5.4 처리 시간
- `proc_ymd`: 처리 일자 (YYYYMMDD)
- `proc_hmsms`: 처리 시분초 + 밀리초 (HHMMSS + 3자리)
- 밀리초까지 기록하여 동시 처리 구분

### 5.5 관련 업무 정보
- `req_seq`, `req_no`: 수불을 발생시킨 업무 문서
- 예: 출하번호, 입고번호, 반품번호 등
- `proc_bundle_no`: 일괄 처리 시 묶음 번호

### 5.6 수량 일관성
- 재고 감소 작업: `proc_qty`만큼 FROM 재고 감소
- 재고 증가 작업: `proc_qty`만큼 TO 재고 증가
- 이동 작업: FROM 감소, TO 증가 동시 발생

### 5.7 취소 처리
- `proc_sts_cd = 'N'`으로 취소 표시
- 취소 시 반대 방향의 수불 이력 추가 필요
- 원본 이력은 유지하고 취소 이력 별도 기록

### 5.8 감사 추적
- 모든 재고 변동의 추적 가능
- 누가, 언제, 어떤 작업으로 재고가 변했는지 확인
- 오류 발생 시 원인 분석 자료

---

## 6. 주요 조회 예시

```sql
-- 특정 기간의 수불 이력 조회
SELECT inven_inout_seq, proc_ymd, proc_hmsms,
       inout_type_cd, inout_dtl_cd,
       proc_qty, proc_user_id,
       fr_wh_seq, fr_loc_seq, fr_sku1, fr_sku2,
       to_wh_seq, to_loc_seq, to_sku1, to_sku2,
       req_no
FROM wms_inven_inout
WHERE biz_seq = 1
AND proc_ymd BETWEEN '20250201' AND '20250228'
AND proc_sts_cd = 'Y'
ORDER BY proc_ymd DESC, proc_hmsms DESC;

-- 특정 품목의 수불 이력
SELECT ii.*, p.prod_nm
FROM wms_inven_inout ii
    JOIN mdm_prod p ON ii.prod_seq = p.prod_seq
WHERE ii.biz_seq = 1
AND ii.prod_seq = 1001
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.proc_ymd DESC, ii.proc_hmsms DESC;

-- 일자별 수불 통계
SELECT proc_ymd,
       COUNT(*) AS tran_cnt,
       SUM(CASE WHEN inout_type_cd IN ('IW', 'RT') THEN proc_qty ELSE 0 END) AS in_qty,
       SUM(CASE WHEN inout_type_cd IN ('OW', 'OB', 'EX') THEN proc_qty ELSE 0 END) AS out_qty,
       COUNT(DISTINCT proc_user_id) AS worker_cnt
FROM wms_inven_inout
WHERE biz_seq = 1
AND proc_ymd BETWEEN '20250201' AND '20250228'
AND proc_sts_cd = 'Y'
GROUP BY proc_ymd
ORDER BY proc_ymd;

-- 특정 위치의 수불 이력 (FROM 기준)
SELECT ii.*, p.prod_nm
FROM wms_inven_inout ii
    JOIN mdm_prod p ON ii.prod_seq = p.prod_seq
WHERE ii.biz_seq = 1
AND ii.fr_wh_seq = 10
AND ii.fr_loc_seq = 1001
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.proc_ymd DESC, ii.proc_hmsms DESC;

-- 특정 위치의 수불 이력 (TO 기준)
SELECT ii.*, p.prod_nm
FROM wms_inven_inout ii
    JOIN mdm_prod p ON ii.prod_seq = p.prod_seq
WHERE ii.biz_seq = 1
AND ii.to_wh_seq = 10
AND ii.to_loc_seq = 1001
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.proc_ymd DESC, ii.proc_hmsms DESC;

-- 수불 유형별 통계
SELECT inout_type_cd, inout_dtl_cd,
       COUNT(*) AS tran_cnt,
       SUM(proc_qty) AS total_qty,
       COUNT(DISTINCT proc_user_id) AS worker_cnt
FROM wms_inven_inout
WHERE biz_seq = 1
AND proc_ymd BETWEEN '20250201' AND '20250228'
AND proc_sts_cd = 'Y'
GROUP BY inout_type_cd, inout_dtl_cd
ORDER BY inout_type_cd, inout_dtl_cd;

-- 작업자별 처리 현황
SELECT proc_user_id,
       COUNT(*) AS tran_cnt,
       SUM(proc_qty) AS total_qty,
       MIN(proc_ymd) AS first_work,
       MAX(proc_ymd) AS last_work
FROM wms_inven_inout
WHERE biz_seq = 1
AND proc_ymd BETWEEN '20250201' AND '20250228'
AND proc_sts_cd = 'Y'
GROUP BY proc_user_id
ORDER BY total_qty DESC;

-- 특정 업무 번호의 수불 이력
SELECT ii.*, p.prod_nm
FROM wms_inven_inout ii
    JOIN mdm_prod p ON ii.prod_seq = p.prod_seq
WHERE ii.biz_seq = 1
AND ii.req_no = 'OB2502260001'
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.inven_inout_seq;

-- 재고이동(IM) 유형 상세 조회
SELECT ii.inven_inout_seq, ii.proc_ymd, ii.proc_hmsms,
       ii.fr_wh_seq, w_fr.wh_nm AS fr_wh_nm,
       ii.fr_loc_seq, l_fr.loc_nm AS fr_loc_nm,
       ii.fr_sku1, ii.fr_sku2,
       ii.to_wh_seq, w_to.wh_nm AS to_wh_nm,
       ii.to_loc_seq, l_to.loc_nm AS to_loc_nm,
       ii.to_sku1, ii.to_sku2,
       ii.proc_qty,
       ii.proc_user_id
FROM wms_inven_inout ii
    LEFT JOIN mdm_wh w_fr ON ii.fr_wh_seq = w_fr.wh_seq
    LEFT JOIN mdm_loc l_fr ON ii.fr_loc_seq = l_fr.loc_seq
    LEFT JOIN mdm_wh w_to ON ii.to_wh_seq = w_to.wh_seq
    LEFT JOIN mdm_loc l_to ON ii.to_loc_seq = l_to.loc_seq
WHERE ii.biz_seq = 1
AND ii.inout_type_cd = 'IM'
AND ii.proc_ymd = '20250226'
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.proc_hmsms;

-- 취소된 수불 이력 조회
SELECT ii.*, p.prod_nm
FROM wms_inven_inout ii
    JOIN mdm_prod p ON ii.prod_seq = p.prod_seq
WHERE ii.biz_seq = 1
AND ii.proc_sts_cd = 'N'
AND ii.mod_dt >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY ii.mod_dt DESC;

-- LOT 번호별 수불 이력
SELECT ii.inven_inout_seq, ii.proc_ymd,
       ii.inout_type_cd, ii.proc_qty,
       ii.fr_lot_no, ii.fr_mng_ymd, ii.fr_exp_ymd,
       ii.to_lot_no, ii.to_mng_ymd, ii.to_exp_ymd,
       ii.req_no
FROM wms_inven_inout ii
WHERE ii.biz_seq = 1
AND (ii.fr_lot_no = 'LOT20250201-001' OR ii.to_lot_no = 'LOT20250201-001')
AND ii.proc_sts_cd = 'Y'
ORDER BY ii.proc_ymd DESC, ii.proc_hmsms DESC;

-- 시간대별 수불 집계 (피크 타임 분석)
SELECT SUBSTR(proc_hmsms, 1, 2) AS hour,
       COUNT(*) AS tran_cnt,
       SUM(proc_qty) AS total_qty
FROM wms_inven_inout
WHERE biz_seq = 1
AND proc_ymd = '20250226'
AND proc_sts_cd = 'Y'
GROUP BY SUBSTR(proc_hmsms, 1, 2)
ORDER BY hour;
```