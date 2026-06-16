# wms_inven_mv (WMS_재고이동)

## 1. 개요
**재고를 한 위치에서 다른 위치로 이동(Movement)하는 요청 헤더** 테이블.
창고 내 위치 변경, 구역 이동, 작업장 이동 등 재고의 물리적 위치 변경 시 사용된다.

### 1.1 재고이동 처리 흐름
```
재고이동 요청
└─ wms_inven_mv (재고이동 헤더) ← **현재 테이블**
        └─ wms_inven_mv_prod (재고이동 품목)
              └─ wms_inven_mv_tran (재고이동 처리 이력)
                    ↓
              재고모듈
              ├─ wms_inven 재고 위치 변경 (FROM → TO)
              ├─ wms_inven_sku 이력 등록
              └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | mv_seq | integer | N | nextval('wms_inven_mv_seq') | 재고이동 SEQ |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | mv_no | varchar(30) | N | | 재고이동 번호 (문서번호) |
| | mv_type_cd | varchar(50) | N | | 재고이동 유형 코드 |
| | mv_sts_cd | varchar(50) | N | '11' | 재고이동 상태 코드 |
| | req_ymd | varchar(8) | N | | 요청 일자 (YYYYMMDD) |
| | req_hms | varchar(6) | Y | | 요청 시간 (HHMMSS) |
| | req_user_nm | varchar(100) | Y | | 요청자명 |
| | req_dept_nm | varchar(100) | Y | | 요청 부서명 |
| | to_wh_seq | integer | Y | | 이동할 창고 SEQ (TO) → mdm_wh |
| | fr_wh_seq | integer | Y | | 이동전 창고 SEQ (FROM) → mdm_wh |
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

> **mv_type_cd** (`MV_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | IM01 | 창고이동 | 창고 간 이동 |
> | IM03 | 작업이동 | 작업장 이동 |

> **mv_sts_cd** (`MV_STS_CD`)
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
| wms_inven_mv_PK | mv_seq | Y | Y |
| UIX_wms_inven_mv | biz_seq, mv_no | Y | |
| IX_wms_inven_mv | biz_seq, center_seq, req_ymd | N | |
| IX_wms_inven_mv_wh | fr_wh_seq, to_wh_seq | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| mv_seq | wms_inven_mv_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| to_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_to |
| fr_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_mv_fr |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_mv_prod | mv_seq | wms_inven_mv_TO_wms_inven_mv_prod |

---

## 7. 업무 규칙

### 7.1 재고이동 생성
- `mv_no` : `mdm_doc_no` 기반으로 사업장별 채번 (수불유형 `IM`)
- `mv_sts_cd = '11'(예정)` 으로 시작

### 7.2 재고이동 유형

| 유형 | 코드 | 설명 |
|---|---|---|
| 창고이동 | IM01 | 동일 센터 내 다른 창고로 이동 |
| 작업이동 | IM03 | 작업장(피킹존, 검수존 등)으로 이동 |

### 7.3 창고 정보
- `fr_wh_seq` : 이동 전 창고 (FROM)
- `to_wh_seq` : 이동 후 창고 (TO)
- 동일 창고 내 위치 이동 시 두 값 동일 가능

### 7.4 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 이동 요청 등록 |
| 지정 | 33 | 이동할 재고 위치 지정 완료 |
| 처리중 | 55 | 일부 이동 처리됨 |
| 확정 | 77 | 이동 완료 (전량 처리) |

### 7.5 처리 단계

#### 7.5.1 이동 요청 등록
- 이동 대상 품목 및 수량 지정
- `mv_sts_cd = '11'`

#### 7.5.2 재고 지정
- 실제 이동할 재고 위치(SKU) 지정
- `mv_sts_cd = '33'`

#### 7.5.3 이동 처리
- `wms_inven_mv_tran` 생성
- 재고 위치 변경
- `mv_sts_cd` 갱신

#### 7.5.4 이동 확정
- 모든 품목 처리 완료 시 `mv_sts_cd = '77'`
- 이후 수정 불가

### 7.6 재고 이동 원칙
- 이동 전 재고(FROM)에서 수량 차감
- 이동 후 재고(TO)에서 수량 증가
- 동일 SKU 정보 유지 (LOT, 유통기한 등)

### 7.7 IF 송신
- `if_send_yn` : 외부 시스템(ERP/WMS)으로 재고이동 정보 송신 여부 관리
- 최초 등록 시 'N', 송신 성공 시 'Y', 실패 시 'E'

### 7.8 취소/삭제
- 확정(`'77'`)된 이동은 취소 불가 (재고 변동 발생)
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 재고이동 유형별 현황
SELECT mv_type_cd, mv_sts_cd, COUNT(*) AS cnt
FROM wms_inven_mv
WHERE biz_seq = 1
AND center_seq = 1
AND req_ymd = '20250226'
AND del_yn = 'N'
GROUP BY mv_type_cd, mv_sts_cd
ORDER BY mv_type_cd, mv_sts_cd;

-- 특정 재고이동 상세
SELECT mv_seq, mv_no, mv_type_cd, mv_sts_cd,
       req_ymd, req_user_nm, req_dept_nm,
       fr_wh_seq, to_wh_seq,
       note
FROM wms_inven_mv
WHERE biz_seq = 1
AND mv_no = 'IM2502260001'
AND del_yn = 'N';

-- 미처리 재고이동 목록 (예정/지정/처리중)
SELECT mv_no, mv_type_cd, mv_sts_cd,
       req_ymd, req_user_nm,
       fr_wh_seq, to_wh_seq
FROM wms_inven_mv
WHERE biz_seq = 1
AND center_seq = 1
AND mv_sts_cd IN ('11', '33', '55')
AND del_yn = 'N'
ORDER BY req_ymd, mv_no;

-- 창고 간 이동 현황
SELECT mv.mv_no, mv.mv_sts_cd,
       fw.wh_nm AS from_wh,
       tw.wh_nm AS to_wh,
       mv.req_ymd
FROM wms_inven_mv mv
    JOIN mdm_wh fw ON mv.fr_wh_seq = fw.wh_seq
    JOIN mdm_wh tw ON mv.to_wh_seq = tw.wh_seq
WHERE mv.biz_seq = 1
AND mv.fr_wh_seq != mv.to_wh_seq
AND mv.reg_dt >= CURRENT_DATE - INTERVAL '7 days'
AND mv.del_yn = 'N'
ORDER BY mv.req_ymd DESC;

-- 일자별 재고이동 현황
SELECT req_ymd,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN mv_type_cd = 'IM01' THEN 1 ELSE 0 END) AS warehouse_mv_cnt,
       SUM(CASE WHEN mv_type_cd = 'IM03' THEN 1 ELSE 0 END) AS work_mv_cnt,
       SUM(CASE WHEN mv_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_inven_mv
WHERE biz_seq = 1
AND req_ymd BETWEEN '20250201' AND '20250228'
AND del_yn = 'N'
GROUP BY req_ymd
ORDER BY req_ymd;

-- 유형별 이동 건수 통계
SELECT
    mv_type_cd,
    COUNT(*) AS total_cnt,
    SUM(CASE WHEN mv_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt,
    ROUND(SUM(CASE WHEN mv_sts_cd = '77' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM wms_inven_mv
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY mv_type_cd
ORDER BY mv_type_cd;

-- IF 송신 대기 건 조회
SELECT mv_no, mv_type_cd, mv_sts_cd,
       req_ymd, req_user_nm
FROM wms_inven_mv
WHERE biz_seq = 1
AND if_send_yn = 'N'
AND del_yn = 'N'
ORDER BY reg_dt;

-- 부서별 재고이동 현황
SELECT req_dept_nm,
       COUNT(*) AS req_cnt,
       SUM(CASE WHEN mv_sts_cd = '77' THEN 1 ELSE 0 END) AS completed_cnt
FROM wms_inven_mv
WHERE biz_seq = 1
AND req_dept_nm IS NOT NULL
AND reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND del_yn = 'N'
GROUP BY req_dept_nm
ORDER BY req_cnt DESC;

-- 월별 재고이동 추이
SELECT TO_CHAR(reg_dt, 'YYYY-MM') AS month,
       COUNT(*) AS total_cnt,
       SUM(CASE WHEN mv_type_cd = 'IM01' THEN 1 ELSE 0 END) AS warehouse_mv_cnt
FROM wms_inven_mv
WHERE biz_seq = 1
AND reg_dt >= CURRENT_DATE - INTERVAL '6 months'
AND del_yn = 'N'
GROUP BY TO_CHAR(reg_dt, 'YYYY-MM')
ORDER BY month;
```