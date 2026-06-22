---
title: 테이블 컬럼 네이밍 규칙
description: WMS DB 테이블과 컬럼 이름을 정할 때 반드시 따라야 하는 네이밍 규칙
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: rule
domain: database
tags:
  - database
  - naming-rule
  - table
  - column
  - snake_case
---

# 테이블 컬럼 네이밍 규칙 (Table Column Naming Rule)

## 1. 테이블 네이밍 규칙

### 1.1 기본 패턴
```
{PREFIX}_{DOMAIN}[_{SUB_DOMAIN}]
```

### 1.2 Prefix 분류

| Prefix | 용도 | 예시 |
|--------|------|------|
| **MDM** | Master Data Management (기준정보) | `MDM_PROD` (품목), `MDM_BIZ` (사업장) |
| **WMS** | Warehouse Management System (창고관리) | `WMS_INVEN` (재고), `WMS_INWH` (입고) |
| **SM** | System Management (시스템관리) | `SM_COMM_H` (공통코드), `SM_MENU` (메뉴) |
| **SIF** | System Interface (시스템 인터페이스) | `SIF_BATCH_HISTORY` (배치이력) |
| **WES** | Warehouse Execution System | `WES_PROCESS_HISTORY` (처리이력) |

### 1.3 테이블명 구성 규칙

#### 1.3.1 마스터 테이블
```sql
-- 패턴: {PREFIX}_{DOMAIN}
MDM_PROD -- 품목
MDM_BIZ -- 사업장
MDM_CONT -- 거래처
MDM_WH -- 창고
MDM_LOC -- 위치
```

#### 1.3.2 연결 테이블 (Many-to-Many)
```sql
-- 패턴: {PREFIX}_{DOMAIN1}_{DOMAIN2}
MDM_BIZ_PROD -- 사업장_품목
MDM_BIZ_CONT -- 사업장_거래처
MDM_BIZ_WH -- 사업장_창고
MDM_CONT_PROD -- 거래처_품목
MDM_USER_BIZ -- 사용자_권한사업장
```

#### 1.3.3 상세/처리 테이블
```sql
-- 패턴: {PREFIX}_{DOMAIN}_PROD (품목 상세)
WMS_INWH_PROD -- 입고_품목
WMS_OUTWH_PROD -- 출고_품목
WMS_OUTBIZ_PROD -- 출하_품목
WMS_RETURN_PROD -- 반품_품목

-- 패턴: {PREFIX}_{DOMAIN}_TRAN (처리/트랜잭션)
WMS_INWH_TRAN -- 입고_처리
WMS_OUTWH_TRAN -- 출고_처리
WMS_INVEN_AD_TRAN -- 재고조정_처리
WMS_INVEN_MV_TRAN -- 재고이동_처리
```

#### 1.3.4 설정/옵션 테이블
```sql
-- 패턴: {PREFIX}_{DOMAIN}_CONFIG
SM_BIZ_CONFIG -- 사업장_설정
SM_PROD_OPT_CONFIG -- 품목_옵션_설정
SM_MENU_OPT_CONFIG -- 메뉴_옵션_설정
SM_API_CONFIG -- API_설정
```

#### 1.3.5 로그/이력 테이블
```sql
-- 패턴: {PREFIX}_LOG_{DOMAIN}
SM_LOG_API -- API_로그
SM_LOG_CONN -- 접근_로그
SM_LOG_ERROR -- 에러_로그
SM_LOG_MENU -- 메뉴_접근_로그

-- 패턴: {PREFIX}_{DOMAIN}_HISTORY
SIF_BATCH_HISTORY -- 배치_이력
WES_PROCESS_HISTORY -- 처리_이력
SM_ALARM_HISTORY -- 알람_이력
SM_USER_PWD_HISTORY -- 비밀번호_변경_이력
```

---

## 2. 컬럼 네이밍 규칙

### 2.1 기본 패턴
```
{DOMAIN}[_{ATTRIBUTE}][_{TYPE}]
```

### 2.2 주요 규칙

#### 2.2.1 모든 컬럼은 `lower_snake_case` 사용
```sql
prod_seq -- 올바름
prodSeq -- 카멜케이스 사용 금지
PROD_SEQ -- 대문자 사용 금지
```

#### 2.2.2 약어 사용 원칙

| 원어 | 약어 | 예시 |
|------|------|------|
| sequence | seq | `prod_seq`, `biz_seq` |
| number | no | `inwh_no`, `prod_no` |
| code | cd | `unit_cd`, `sts_cd` |
| name | nm | `prod_nm`, `user_nm` |
| year-month-day | ymd | `req_ymd`, `proc_ymd` |
| hour-minute-second | hms | `req_hms`, `proc_hms` |
| quantity | qty | `inven_qty`, `req_qty` |
| datetime | dt | `reg_dt`, `mod_dt` |
| yes/no | yn | `use_yn`, `del_yn` |
| status | sts | `inwh_sts_cd` |

---

## 3. 컬럼 유형별 네이밍

### 3.1 PK (Primary Key)
```sql
-- 패턴: {테이블명}_seq
prod_seq -- MDM_PROD 테이블
biz_seq -- MDM_BIZ 테이블
inwh_seq -- WMS_INWH 테이블
outwh_seq -- WMS_OUTWH 테이블
inven_seq -- WMS_INVEN 테이블 (없음, 복합키 사용)
```

### 3.2 FK (Foreign Key)
```sql
-- 패턴: {참조테이블}_seq
biz_seq -- 사업장 SEQ 참조
prod_seq -- 품목 SEQ 참조
cont_seq -- 거래처 SEQ 참조
wh_seq -- 창고 SEQ 참조
loc_seq -- 위치 SEQ 참조
center_seq -- 센터 SEQ 참조
```

### 3.3 코드 컬럼
```sql
-- 패턴: {도메인}_{속성}_cd
prod_div_cd -- 품목_구분_코드
sku_mng_cd -- SKU_관리_코드
inwh_sts_cd -- 입고_상태_코드
outwh_type_cd -- 출고_유형_코드
inven_inout_cd -- 재고_수불_코드
proc_sts_cd -- 처리_상태_코드
```

### 3.4 수량 컬럼
```sql
-- 패턴: {속성}_qty
req_qty -- 요청_수량
proc_qty -- 처리_수량
inven_qty -- 재고_수량
wt_qty -- 대기_수량 (waiting)
ex_qty -- 기처리_수량 (executed)
inwh_qty -- 입고_수량
```

### 3.5 일자/시간 컬럼

#### 3.5.1 연월일 (YYYYMMDD 형식)
```sql
-- 패턴: {속성}_ymd
req_ymd -- 요청_연월일
proc_ymd -- 처리_연월일
cfm_ymd -- 확정_연월일
reg_ymd -- 등록_연월일
exp_ymd -- 유통기한_연월일
mng_ymd -- 제조/입고_일자
```

#### 3.5.2 시분초 (HHMMSS 형식)
```sql
-- 패턴: {속성}_hms
req_hms -- 요청_시분초
proc_hms -- 처리_시분초
cfm_hms -- 확정_시분초
```

#### 3.5.3 일시 (DATETIME/TIMESTAMP)
```sql
-- 패턴: {속성}_dt
reg_dt -- 등록_일시
mod_dt -- 수정_일시
cfm_dt -- 확인_일시
conn_dt -- 접근_일시
```

### 3.6 사용자 컬럼
```sql
-- 패턴: {속성}_user_id / {속성}_id
proc_user_id -- 처리자_ID
req_user_id -- 요청자_ID
cfm_user_id -- 확정자_ID
reg_id -- 등록자_ID
mod_id -- 수정자_ID

-- 패턴: {속성}_user_nm / {속성}_nm
proc_user_nm -- 처리자_명
req_user_nm -- 요청자_명
user_nm -- 사용자_명
```

### 3.7 상태 관리 컬럼 (공통)
```sql
use_yn -- 사용_여부 (Y/N)
del_yn -- 삭제_여부 (Y/N)
reg_id -- 등록자_ID
reg_dt -- 등록_일시
mod_id -- 수정자_ID
mod_dt -- 수정_일시
```

### 3.8 YES/NO 플래그
```sql
-- 패턴: {속성}_yn
use_yn -- 사용_여부
del_yn -- 삭제_여부
cfm_yn -- 확정_여부
proc_yn -- 처리_여부
apply_yn -- 적용_여부
admin_yn -- 관리자_여부
qc_yn -- 검사_여부
return_yn -- 반품처리_여부
```

### 3.9 번호 컬럼
```sql
-- 패턴: {도메인}_no
prod_no -- 품목_번호
inwh_no -- 입고_번호
outwh_no -- 출고_번호
outbiz_no -- 출하_번호
invoice_no -- 송장_번호
so_no -- 주문_번호 (sales order)
po_no -- 발주_번호 (purchase order)
lot_no -- LOT_번호
```

### 3.10 명칭 컬럼
```sql
-- 패턴: {도메인}_nm
prod_nm -- 품목_명
biz_nm -- 사업장_명
cont_nm -- 거래처_명
user_nm -- 사용자_명
wh_nm -- 창고_명
loc_nm -- 위치_명

-- 약칭: {도메인}_nm_short
prod_nm_short -- 품목_명_약칭
biz_nm_short -- 사업장_명_약칭
cont_nm_short -- 거래처_명_약칭
```

### 3.11 SKU 관련
```sql
sku1 -- SKU1 (바코드/LOT 등)
sku2 -- SKU2 (파레트 번호 등)
sku1_seq -- SKU1_일련번호
sku2_seq -- SKU2_일련번호
sku_base -- SKU_기준
sku_mng_cd -- SKU_관리_유형_코드
sku2_mng_yn -- 파렛트_관리_여부
```

### 3.12 바코드 관련
```sql
prod_barcode -- 품목_바코드
parent_barcode -- 상위_품목_바코드
loc_barcode -- 위치_바코드
barcode_type_cd -- 바코드_유형_코드
barcode_type_cd1 -- 1D_바코드_유형_코드
barcode_type_cd2 -- 2D_바코드_유형_코드
```

### 3.13 이동 관련 (FROM-TO)
```sql
-- FR (FROM) 패턴
fr_wh_seq -- 출발_창고_SEQ
fr_loc_seq -- 출발_위치_SEQ
fr_lot_no -- 출발_LOT_번호
fr_exp_ymd -- 출발_유통기한
fr_sku1 -- 출발_SKU1
fr_sku2 -- 출발_SKU2

-- TO 패턴
to_wh_seq -- 도착_창고_SEQ
to_loc_seq -- 도착_위치_SEQ
to_lot_no -- 도착_LOT_번호
to_exp_ymd -- 도착_유통기한
to_sku1 -- 도착_SKU1
to_sku2 -- 도착_SKU2
```

### 3.14 외부 연동 컬럼
```sql
-- 패턴: if_{속성}
if_prod_id -- IF_품목_ID
if_biz_id -- IF_사업장_ID
if_cont_id -- IF_거래처_ID
if_wh_id -- IF_창고_ID
if_key -- IF_KEY
if_seq -- IF_SEQ
if_send_yn -- IF_송신_여부
```

---

## 4. 특수 규칙

### 4.1 순번/인덱스
```sql
seq -- 순번 (상세 테이블에서)
disp_no -- 표시_순서
menu_idx -- 메뉴_순서
load_idx -- 적재_차수
st_idx -- 재고실사_차수
```

### 4.2 치수/무게
```sql
len_x -- 가로 (length X)
len_y -- 세로 (length Y)
len_z -- 높이 (length Z)
wgt -- 중량 (weight)
net_weight -- 순중량
cbm -- CBM (Cubic Meter)
```

### 4.3 요일 (스케줄링)
```sql
sun -- 일요일
mon -- 월요일
tue -- 화요일
wed -- 수요일
thu -- 목요일
fri -- 금요일
sat -- 토요일
```

### 4.4 날짜 범위
```sql
start_ymd -- 시작_연월일
end_ymd -- 종료_연월일
start_hms -- 시작_시분초
end_hms -- 종료_시분초
search_start_ymd -- 검색_시작_일
search_end_ymd -- 검색_종료_일
```

---

## 5. 네이밍 체크리스트

### 5.1 DO (권장)
- [x] `lower_snake_case` 사용
- [x] 명확한 약어 사용 (seq, cd, yn, ymd, hms)
- [x] 도메인_속성_타입 순서 유지
- [x] FK는 참조 테이블명_seq 형식
- [x] 공통 컬럼(use_yn, del_yn, reg_id, mod_id) 일관성 유지

### 5.2 DON'T (금지)
- [ ] camelCase 사용 금지
- [ ] UPPER_CASE 사용 금지
- [ ] 한글 컬럼명 사용 금지
- [ ] 불명확한 약어 사용 금지
- [ ] 특수문자 사용 금지 (언더스코어 제외)

---

## 6. 예시: 테이블 생성 템플릿

```sql
-- 마스터 테이블 예시
CREATE TABLE MDM_{DOMAIN} (
    {domain}_seq        INTEGER         NOT NULL DEFAULT NEXTVAL('mdm_{domain}_seq'),
    biz_seq             INTEGER         NOT NULL,
    {domain}_no         VARCHAR(50)     NOT NULL,
    {domain}_nm         VARCHAR(200)    NOT NULL,
    {domain}_nm_short   VARCHAR(100),
    {attribute}_cd      VARCHAR(50),
    use_yn              CHAR(1)         NOT NULL DEFAULT 'Y',
    del_yn              CHAR(1)         NOT NULL DEFAULT 'N',
    note                VARCHAR(1000),
    reg_id              VARCHAR(50)     NOT NULL,
    reg_dt              TIMESTAMP       NOT NULL DEFAULT NOW(),
    mod_id              VARCHAR(50),
    mod_dt              TIMESTAMP,
    CONSTRAINT mdm_{domain}_PK PRIMARY KEY ({domain}_seq)
);

-- 상세 테이블 예시
CREATE TABLE WMS_{DOMAIN}_PROD (
    {domain}_prod_seq   INTEGER         NOT NULL DEFAULT NEXTVAL('wms_{domain}_prod_seq'),
    {domain}_seq        INTEGER         NOT NULL,
    biz_seq             INTEGER         NOT NULL,
    prod_seq            INTEGER         NOT NULL,
    seq                 SMALLINT        NOT NULL DEFAULT 0,
    req_qty             DECIMAL(10,2)   NOT NULL DEFAULT 1,
    proc_qty            DECIMAL(10,2)   NOT NULL DEFAULT 0,
    {domain}_prod_sts_cd VARCHAR(50)    NOT NULL,
    use_yn              CHAR(1)         NOT NULL DEFAULT 'Y',
    del_yn              CHAR(1)         NOT NULL DEFAULT 'N',
    reg_id              VARCHAR(50)     NOT NULL,
    reg_dt              TIMESTAMP       NOT NULL DEFAULT NOW(),
    mod_id              VARCHAR(50),
    mod_dt              TIMESTAMP,
    CONSTRAINT wms_{domain}_prod_PK PRIMARY KEY ({domain}_prod_seq, {domain}_seq),
    CONSTRAINT wms_{domain}_TO_wms_{domain}_prod FOREIGN KEY ({domain}_seq)
        REFERENCES WMS_{DOMAIN}({domain}_seq)
);
```

---

이 네이밍 규칙을 따르면 WMS 프로젝트 전체에서 일관된 데이터베이스 구조를 유지할 수 있습니다!
