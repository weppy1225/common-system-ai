# wms_inwh_label (WMS_입고라벨)

## 1. 개요
입고 처리 이전에 **선발행(pre-print)되는 SKU(재고단위) 라벨 정보**를 관리하는 테이블.
실물 Box/Pallet에 부착할 라벨을 먼저 발행하고, 이후 라벨이 부착된 실물을 스캔하여 입고 처리가 완료된다.

### 1.1 입고라벨 발행 및 처리 흐름

```
① 입고예정 수신 (ERP → WMS)
    wms_inwh, wms_inwh_prod 등록

② SKU 발행 (라벨 선발행)
    wms_inwh_label 신규 등록
    └─ wms_inwh_prod 라벨발행여부(pub_sku1_yn, pub_sku2_yn) update

③ 라벨 출력 → Box/Pallet에 부착

④ 실물 입고 처리 (라벨 스캔)
    ├─ 3-1 재고모듈
    │    ├─ wms_inven 신규재고등록 (이미 존재하는 경우 update)
    │    ├─ wms_inven_sku 이력 등록 (이미 존재하는 경우 update)
    │    └─ wms_inven_inout 수불이력 등록
    │
    └─ 3-2 D2 등록 (입고 처리)
         ├─ wms_inwh_tran 등록
         ├─ wms_inwh_prod 처리수량(ex_qty) 및 상태값(inwh_prod_sts_cd) update
         └─ wms_inwh 헤더 상태값(inwh_sts_cd) update
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | inwh_label_seq | bigint | N | nextval('wms_inwh_label_seq') | 입고라벨 SEQ |
| | req_seq | integer | N | | 요청 SEQ (wms_inwh.inwh_seq) |
| | req_prod_seq | bigint | N | | 요청 품목 SEQ (wms_inwh_prod.inwh_prod_seq) |
| | inout_type_cd | varchar(50) | N | | 수불 유형 코드 ('IW') |
| | biz_seq | integer | N | | 사업장 SEQ → mdm_biz |
| | center_seq | integer | N | | 센터 SEQ → mdm_center |
| | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | sku1_seq | integer | Y | | SKU1 일련번호 (라벨 발행 시 생성) |
| | sku2_seq | integer | Y | | SKU2 일련번호 (라벨 발행 시 생성) |
| | sku_base | varchar(100) | N | | SKU 기준 (B/C/N) |
| | mng_ymd | varchar(8) | Y | | 제조일자 (YYYYMMDD) |
| | exp_ymd | varchar(8) | Y | | 유통기한 (YYYYMMDD) |
| | lot_no | varchar(30) | Y | | LOT 번호 |
| | sku1 | varchar(100) | N | | SKU1 (재고단위1 - Box 단위) |
| | sku2 | varchar(100) | N | | SKU2 (재고단위2 - Pallet 단위) |
| | load_qty | decimal(10,2) | N | 1 | 적재 수량 (Pallet당 Box 수 등) |
| | create_ymd | varchar(8) | N | | 생성 일자 (YYYYMMDD) |
| | create_hms | varchar(6) | N | | 생성 시간 (HHMMSS) |
| | create_user_id | varchar(20) | N | | 생성자 ID |
| | proc_yn | char(1) | N | 'N' | 처리 여부 (라벨 스캔 완료 여부) |
| | proc_ymd | varchar(8) | Y | | 처리 일자 (YYYYMMDD) |
| | proc_hms | varchar(6) | Y | | 처리 시간 (HHMMSS) |
| | proc_user_id | varchar(20) | Y | | 처리자 ID |
| | note | varchar(1000) | Y | | 비고 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **inout_type_cd** (`INOUT_TYPE_CD`)
>
> | 코드 | 코드명 | 비고 |
> |---|---|---|
> | IW | 입고 | 입고 처리 |

> **sku_base** (`SKU_MNG_CD` 참조)
>
> | 코드 | 코드명 |
> |---|---|
> | B | 유통표준코드 |
> | C | 자사물류코드 |
> | N | 사용안함 |

> **proc_yn** (`CFM_YN`)
>
> | 코드 | 코드명 |
> |---|---|
> | N | 미처리 (라벨 미사용) |
> | Y | 처리완료 (라벨 스캔 완료) |

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
| wms_inwh_label_PK | inwh_label_seq | Y | Y |
| UIX_wms_inwh_label_sku | sku1, sku2 | Y | |
| IX_wms_inwh_label_req | req_seq, req_prod_seq | N | |
| IX_wms_inwh_label_proc | proc_yn, create_ymd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| inwh_label_seq | wms_inwh_label_seq |
| sku1_seq | (별도 관리 - 품목별 채번) |
| sku2_seq | (별도 관리 - 품목별 채번) |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| req_seq | wms_inwh | inwh_seq | wms_inwh_TO_wms_inwh_label |
| req_prod_seq | wms_inwh_prod | inwh_prod_seq | wms_inwh_prod_TO_wms_inwh_label |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inwh_label |
| biz_seq | mdm_biz | biz_seq | mdm_biz_TO_wms_inwh_label |
| center_seq | mdm_center | center_seq | mdm_center_TO_wms_inwh_label |

---

## 6. 업무 규칙

### 6.1 ① 입고예정 수신 (ERP 연동)
- ERP에서 입고예정 정보 수신 시 `wms_inwh`, `wms_inwh_prod` 등록
- `wms_inwh_prod.pub_sku1_yn`, `pub_sku2_yn`은 'N' (초기값)

### 6.2 ② SKU 발행 (라벨 선발행)
- 입고 작업 전 라벨 출력 필요 시 SKU 발행
- `wms_inwh_label` 신규 등록
- `req_seq` = `wms_inwh.inwh_seq`
- `req_prod_seq` = `wms_inwh_prod.inwh_prod_seq`
- `sku1`, `sku2` : 품목번호 + 일련번호 조합으로 생성 (예: `PROD001-20250226-0001`)
- `proc_yn` = 'N'
- `wms_inwh_prod` 라벨발행여부 update
- `pub_sku1_yn` = 'Y' (SKU1 발행)
- `pub_sku2_yn` = 'Y' (SKU2 발행, 파렛트 단위 관리 시)
- 발행된 라벨 출력 → 실제 Box/Pallet에 부착

### 6.3 ③ 실물 입고 처리 (라벨 스캔)
작업자가 라벨이 부착된 Box/Pallet 스캔 시 아래 처리 수행

#### 6.3.1 재고모듈
1. **`wms_inven` 재고 등록/갱신**
- `sku1`, `sku2`, `wh_seq`, `loc_seq` 기준으로 재고 존재 여부 확인
- 존재하지 않으면 신규 등록, 존재하면 `inven_qty` 증가
2. **`wms_inven_sku` 이력 등록**
- SKU 단위 재고 이력 저장 (생성 이력)
3. **`wms_inven_inout` 수불이력 등록**
- 수불 유형 `IW`로 입고 처리 이력 저장

#### 6.3.2 입고 처리 (D2 등록)
1. **`wms_inwh_tran` 등록**
- `inwh_seq`, `inwh_prod_seq` 참조
- `sku1`, `sku2` 정보 함께 저장
- `proc_qty` = `load_qty` (또는 스캔 수량)
2. **`wms_inwh_prod` 처리수량 및 상태 갱신**
- `ex_qty` = 기존 `ex_qty` + `proc_qty`
- `ex_qty` = `req_qty` 이면 `inwh_prod_sts_cd` = '77'(확정)
3. **`wms_inwh` 헤더 상태 갱신**
- 해당 입고의 모든 품목이 확정('77')되면 `inwh_sts_cd` = '77'(확정)
4. **`wms_inwh_label` 처리 완료 갱신**
- `proc_yn` = 'Y'
- `proc_ymd`, `proc_hms`, `proc_user_id` 저장

### 6.4 라벨 재발행
- 라벨 분실/훼손 시 동일 정보로 재발행 가능
- 재발행 시 `mod_id`, `mod_dt` 갱신
- 기존 라벨 정보는 유지 (이력 추적)
- 이미 처리(`proc_yn` = 'Y')된 라벨은 재발행 불가

### 6.5 기타 규칙
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리
- 한 번 처리(`proc_yn = 'Y'`)된 라벨은 재사용 불가
- `sku1`(Box), `sku2`(Pallet)는 계층 관계 유지

---

## 7. 주요 조회 예시

```sql
-- 미처리 라벨 목록 (발행만 되고 아직 입고되지 않은 라벨)
SELECT l.inwh_label_seq, l.sku1, l.sku2, l.prod_seq,
       l.mng_ymd, l.exp_ymd, l.lot_no, l.load_qty,
       l.create_ymd, l.create_hms, l.create_user_id,
       p.prod_nm
FROM wms_inwh_label l
    JOIN mdm_prod p ON l.prod_seq = p.prod_seq
WHERE l.biz_seq = 1
AND l.center_seq = 1
AND l.proc_yn = 'N'
AND l.del_yn = 'N'
ORDER BY l.create_ymd, l.create_hms;

-- 특정 입고건의 라벨 발행 및 처리 현황
SELECT l.inwh_label_seq, l.sku1, l.sku2,
       l.proc_yn, l.proc_ymd, l.proc_user_id,
       ip.req_qty, ip.ex_qty, ip.inwh_prod_sts_cd,
       p.prod_nm
FROM wms_inwh_label l
    JOIN wms_inwh_prod ip ON l.req_prod_seq = ip.inwh_prod_seq
    JOIN wms_inwh i ON ip.inwh_seq = i.inwh_seq
    JOIN mdm_prod p ON l.prod_seq = p.prod_seq
WHERE i.biz_seq = 1
AND i.inwh_no = 'IW2502250001'
AND l.del_yn = 'N'
ORDER BY l.create_ymd, l.create_hms;

-- 품목별 라벨 발행 대비 처리 현황
SELECT p.prod_nm,
       COUNT(*) AS total_label_cnt,
       SUM(CASE WHEN l.proc_yn = 'Y' THEN 1 ELSE 0 END) AS proc_cnt,
       ROUND(SUM(CASE WHEN l.proc_yn = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS proc_rate
FROM wms_inwh_label l
    JOIN mdm_prod p ON l.prod_seq = p.prod_seq
WHERE l.biz_seq = 1
AND l.create_ymd BETWEEN '20250201' AND '20250228'
AND l.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY proc_rate;

-- 입고 처리 소요 시간 분석 (라벨 발행부터 처리까지)
SELECT l.sku1,
       l.create_ymd || l.create_hms AS create_dtm,
       l.proc_ymd || l.proc_hms AS proc_dtm,
       (TO_TIMESTAMP(l.proc_ymd || l.proc_hms, 'YYYYMMDDHH24MISS') - 
        TO_TIMESTAMP(l.create_ymd || l.create_hms, 'YYYYMMDDHH24MISS')) AS elapsed_time,
       i.inwh_no, p.prod_nm
FROM wms_inwh_label l
    JOIN wms_inwh i ON l.req_seq = i.inwh_seq
    JOIN mdm_prod p ON l.prod_seq = p.prod_seq
WHERE l.biz_seq = 1
AND l.proc_yn = 'Y'
AND l.proc_ymd = '20250226'
AND l.del_yn = 'N'
ORDER BY elapsed_time;
```