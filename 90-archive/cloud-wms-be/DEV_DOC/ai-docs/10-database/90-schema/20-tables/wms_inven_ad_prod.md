# wms_inven_ad_prod (WMS_재고조정품목)

## 1. 개요
`wms_inven_ad`(재고조정)에 속한 **품목 단위 상세 정보**를 관리하는 테이블.
재고조정 대상 품목별로 조정 수량, 상태, 예상 정보 등을 저장하며, 실제 재고조정 처리(`wms_inven_ad_tran`)와 연결된다.

### 1.1 재고조정품목 처리 흐름
```
wms_inven_ad (재고조정 헤더)
└─ wms_inven_ad_prod (재고조정 품목) ← **현재 테이블**
        └─ wms_inven_ad_tran (재고조정 처리 이력)
              ↓
        재고모듈
        ├─ wms_inven 재고 증감
        ├─ wms_inven_sku 이력 등록
        └─ wms_inven_inout 수불이력 등록
```

---

## 2. 테이블 정의

| PK/FK | 컬럼명 | 타입 | NULL | 기본값 | 설명 |
|---|---|---|---|---|---|
| PK | ad_prod_seq | bigint | N | nextval('wms_inven_ad_prod_seq') | 재고조정품목 SEQ |
| FK | ad_seq | integer | N | | 재고조정 SEQ → wms_inven_ad |
| FK | prod_seq | integer | N | | 품목 SEQ → mdm_prod |
| | ad_prod_sts_cd | varchar(50) | N | | 재고조정품목 상태 코드 |
| | req_qty | decimal(10,2) | N | 0 | 요청 수량 (조정 수량) |
| | ex_qty | decimal(10,2) | N | 0 | 기처리 수량 |
| | new_inven_yn | char(1) | N | 'N' | 신규재고 여부 |
| | est_wh_seq | integer | Y | | 예상 창고 SEQ → mdm_wh |
| | est_mng_ymd | varchar(8) | Y | | 예상 제조일자 (YYYYMMDD) |
| | est_exp_ymd | varchar(8) | Y | | 예상 유통기한 (YYYYMMDD) |
| | est_lot_no | varchar(30) | Y | | 예상 LOT 번호 |
| | if_err_seq | integer | Y | | IF 에러 SEQ |
| | if_idx | varchar(20) | Y | | IF 내부순번 |
| | if_send_yn | char(1) | N | 'N' | IF 송신 여부 |
| | del_yn | char(1) | N | 'N' | 삭제 여부 |
| | reg_id | varchar(20) | N | | 등록 ID |
| | reg_dt | timestamp | N | now() | 등록 일시 |
| | mod_id | varchar(20) | Y | | 수정 ID |
| | mod_dt | timestamp | Y | | 수정 일시 |

> **ad_prod_sts_cd** (`AD_PROD_STS_CD`)
>
> | 코드 | 코드명 |
> |---|---|
> | 11 | 예정 |
> | 55 | 처리중 |
> | 77 | 확정 |

> **new_inven_yn** (`USE_YN` 계열)
>
> | 코드 | 코드명 | 설명 |
> |---|---|---|
> | N | 기존재고 | 기존 재고에 대한 조정 |
> | Y | 신규재고 | 신규 재고 생성 조정 |

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
| wms_inven_ad_prod_PK | ad_prod_seq, ad_seq | Y | Y |
| IX_wms_inven_ad_prod_prod | prod_seq | N | |
| IX_wms_inven_ad_prod_sts | ad_prod_sts_cd | N | |

---

## 4. 시퀀스

| 컬럼 | 시퀀스명 |
|---|---|
| ad_prod_seq | wms_inven_ad_prod_seq |

---

## 5. FK 관계

| FK 컬럼 | 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|---|
| ad_seq | wms_inven_ad | ad_seq | wms_inven_ad_TO_wms_inven_ad_prod |
| prod_seq | mdm_prod | prod_seq | mdm_prod_TO_wms_inven_ad_prod |
| est_wh_seq | mdm_wh | wh_seq | mdm_wh_TO_wms_inven_ad_prod |

---

## 6. 참조됨 (참조하는 테이블)

| 참조 테이블 | 참조 컬럼 | 제약명 |
|---|---|---|
| wms_inven_ad_tran | ad_prod_seq, ad_seq | wms_inven_ad_prod_TO_wms_inven_ad_tran |

---

## 7. 업무 규칙

### 7.1 재고조정품목 생성
- 재고조정 헤더 등록 시 품목별로 생성
- `ad_prod_sts_cd = '11'(예정)` 으로 시작
- `req_qty` : 조정 요청 수량 (증가: 양수, 감소: 음수)

### 7.2 조정 유형별 특성

#### 7.2.1 실사조정(AD01)
- 재고실사 결과에 따른 조정
- `new_inven_yn` : 일반적으로 'N' (기존재고 조정)

#### 7.2.2 기타조정(AD91)
- 파손, 변질, 오류 등 예외 상황
- `new_inven_yn` : 상황에 따라 결정

#### 7.2.3 기초조정(AD99)
- 기초재고 설정
- `new_inven_yn` : 일반적으로 'Y' (신규재고)

### 7.3 수량 관리
- `req_qty` : 조정 요청 수량
- **양수(+)**: 재고 증가
- **음수(-)**: 재고 감소
- `ex_qty` : 실제 처리된 누적 수량
- 모든 수량이 처리되면(`ex_qty = req_qty`) 상태는 `'77'(확정)` 으로 변경

### 7.4 예상 정보
- 신규재고 생성 시(`new_inven_yn = 'Y'`) 필요한 정보
- `est_wh_seq`, `est_mng_ymd`, `est_exp_ymd`, `est_lot_no` : 조정 후 생성될 재고 정보
- 기존재고 조정 시에는 실제 재고 정보 사용

### 7.5 상태 변화

| 상태 | 코드 | 설명 |
|---|---|---|
| 예정 | 11 | 조정 요청 등록 |
| 처리중 | 55 | 일부 조정 처리됨 |
| 확정 | 77 | 조정 완료 (전량 처리) |

### 7.6 처리 단계

#### 7.6.1 조정 요청 등록
- 조정 대상 품목 및 수량 지정
- `ad_prod_sts_cd = '11'`

#### 7.6.2 조정 처리
- `wms_inven_ad_tran` 생성
- `ex_qty` 증가
- `ad_prod_sts_cd` 갱신

#### 7.6.3 조정 확정
- `ex_qty = req_qty` 시 `ad_prod_sts_cd = '77'`
- 상위 헤더 상태 갱신 트리거

### 7.7 신규재고 vs 기존재고

| 구분 | new_inven_yn = 'N' | new_inven_yn = 'Y' |
|---|---|---|
| 대상 | 기존 SKU 조정 | 신규 SKU 생성 |
| 위치 | 기존 위치 사용 | `est_wh_seq` 사용 |
| 이력 | 기존 SKU 이력 유지 | 신규 SKU 이력 생성 |
| 사용처 | 실사조정, 감소 | 기초재고, 신규발생 |

### 7.8 IF 송신
- `if_send_yn` : 외부 시스템(ERP/회계)으로 조정 정보 송신 여부 관리
- `if_idx` : 외부 시스템에서의 순번 정보

### 7.9 취소/삭제
- 확정(`'77'`)된 품목은 변경 불가
- 미확정 상태에서만 수정/삭제 가능
- 물리삭제 금지 — `del_yn = 'Y'` 로 논리삭제 처리

---

## 8. 주요 조회 예시

```sql
-- 재고조정별 품목 현황
SELECT ad.ad_no, ad.ad_type_cd,
       ap.ad_prod_seq, p.prod_nm,
       ap.req_qty, ap.ex_qty,
       ap.ad_prod_sts_cd,
       ap.new_inven_yn
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ad.center_seq = 1
AND ad.req_ymd = '20250226'
AND ap.del_yn = 'N'
ORDER BY ad.ad_no, ap.ad_prod_seq;

-- 특정 재고조정의 품목 상세
SELECT ap.ad_prod_seq, p.prod_no, p.prod_nm,
       ap.req_qty, ap.ex_qty,
       ap.ad_prod_sts_cd,
       ap.new_inven_yn,
       ap.est_wh_seq, ap.est_mng_ymd,
       ap.est_exp_ymd, ap.est_lot_no
FROM wms_inven_ad_prod ap
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ap.ad_seq = 100
AND ap.del_yn = 'N'
ORDER BY ap.ad_prod_seq;

-- 미완료 조정품목 목록 (예정/처리중)
SELECT ap.ad_prod_seq, ad.ad_no,
       p.prod_nm, ap.req_qty, ap.ex_qty,
       (CASE 
           WHEN ap.req_qty >= 0 THEN ap.req_qty - ap.ex_qty
           ELSE ap.req_qty - ap.ex_qty  -- 음수인 경우 처리
        END) AS remain_qty,
       ap.ad_prod_sts_cd,
       ap.new_inven_yn
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ap.ad_prod_sts_cd IN ('11', '55')
AND ap.del_yn = 'N'
ORDER BY ad.req_ymd, ad.ad_no;

-- 신규재고 생성 조정 조회
SELECT ap.ad_prod_seq, ad.ad_no, ad.ad_type_cd,
       p.prod_nm, ap.req_qty,
       ap.est_wh_seq, ap.est_mng_ymd,
       ap.est_exp_ymd, ap.est_lot_no
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ap.new_inven_yn = 'Y'
AND ap.ad_prod_sts_cd != '77'
AND ap.del_yn = 'N'
ORDER BY ad.req_ymd;

-- 품목별 재고조정 현황
SELECT p.prod_nm,
       COUNT(DISTINCT ap.ad_prod_seq) AS adjust_cnt,
       SUM(CASE WHEN ap.req_qty > 0 THEN ap.req_qty ELSE 0 END) AS increase_qty,
       SUM(CASE WHEN ap.req_qty < 0 THEN ap.req_qty ELSE 0 END) AS decrease_qty,
       SUM(ap.ex_qty) AS processed_qty
FROM wms_inven_ad_prod ap
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ap.biz_seq = 1
AND ap.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ap.del_yn = 'N'
GROUP BY p.prod_nm
ORDER BY adjust_cnt DESC;

-- 상태별 재고조정품목 현황
SELECT
    ap.ad_prod_sts_cd,
    COUNT(*) AS prod_cnt,
    SUM(ap.req_qty) AS total_qty,
    SUM(ap.ex_qty) AS processed_qty,
    AVG(ABS(ap.req_qty)) AS avg_abs_qty
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
WHERE ad.biz_seq = 1
AND ad.req_ymd = '20250226'
AND ap.del_yn = 'N'
GROUP BY ap.ad_prod_sts_cd
ORDER BY ap.ad_prod_sts_cd;

-- 유형별 증감 현황
SELECT
    ad.ad_type_cd,
    SUM(CASE WHEN ap.req_qty > 0 THEN ap.req_qty ELSE 0 END) AS total_increase,
    SUM(CASE WHEN ap.req_qty < 0 THEN ap.req_qty ELSE 0 END) AS total_decrease,
    COUNT(DISTINCT ap.ad_prod_seq) AS item_cnt
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
WHERE ad.biz_seq = 1
AND ap.reg_dt >= CURRENT_DATE - INTERVAL '30 days'
AND ap.del_yn = 'N'
GROUP BY ad.ad_type_cd
ORDER BY ad.ad_type_cd;

-- IF 송신 대기 건 조회
SELECT ap.ad_prod_seq, ad.ad_no, p.prod_nm,
       ap.req_qty, ap.ex_qty,
       ap.ad_prod_sts_cd, ap.if_idx
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ap.if_send_yn = 'N'
AND ap.del_yn = 'N'
ORDER BY ap.reg_dt;

-- 대규모 조정 품목 (절대값 기준)
SELECT ap.ad_prod_seq, ad.ad_no,
       p.prod_nm, ap.req_qty,
       ABS(ap.req_qty) AS abs_qty,
       ap.new_inven_yn
FROM wms_inven_ad_prod ap
    JOIN wms_inven_ad ad ON ap.ad_seq = ad.ad_seq
    JOIN mdm_prod p ON ap.prod_seq = p.prod_seq
WHERE ad.biz_seq = 1
AND ABS(ap.req_qty) > 1000
AND ap.del_yn = 'N'
ORDER BY abs_qty DESC;
```