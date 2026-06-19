---
title: 주석 네이밍 규칙
description: WMS DB 테이블과 컬럼에 COMMENT ON 주석을 작성할 때 반드시 따라야 하는 규칙
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: rule
domain: database
tags:
  - database
  - comment
  - naming-rule
  - ddl
---

# 주석 네이밍 규칙 (Comment Naming Convention)

## 1. 기본 원칙

### 1.1 주석 언어
```sql
-- 한글 사용 (업무 도메인 용어)
COMMENT ON TABLE MDM_PROD IS '품목';
COMMENT ON COLUMN MDM_PROD.prod_seq IS '품목_SEQ';

-- 영문 직역 금지
COMMENT ON TABLE MDM_PROD IS 'Product'; -- X
COMMENT ON COLUMN MDM_PROD.prod_seq IS 'Product Sequence'; -- X
```

### 1.2 구분자
```sql
-- 언더스코어(_) 사용
'품목_SEQ', '입고_처리_SEQ', '재고_수불_이력'

-- 공백, 하이픈 사용 금지
'품목 SEQ' -- X
'품목-SEQ' -- X
```

---

## 2. 테이블 주석 규칙

### 2.1 기본 패턴
```
{PREFIX}_{도메인}[_{하위도메인}]
```

### 2.2 Prefix별 한글 명명

#### 2.2.1 MDM (Master Data Management)
```sql
COMMENT ON TABLE MDM_PROD IS 'MDM_품목';
COMMENT ON TABLE MDM_BIZ IS 'MDM_사업장';
COMMENT ON TABLE MDM_CONT IS 'MDM_거래처';
COMMENT ON TABLE MDM_WH IS 'MDM_창고';
COMMENT ON TABLE MDM_LOC IS 'MDM_위치';
COMMENT ON TABLE MDM_CENTER IS 'MDM_센터';
COMMENT ON TABLE MDM_CAR IS 'MDM_차량';
COMMENT ON TABLE MDM_USER IS 'MDM_사용자';
```

#### 2.2.2 WMS (Warehouse Management System)
```sql
COMMENT ON TABLE WMS_INWH IS 'WMS_입고';
COMMENT ON TABLE WMS_OUTWH IS 'WMS_출고';
COMMENT ON TABLE WMS_INVEN IS 'WMS_재고';
COMMENT ON TABLE WMS_OUTBIZ IS 'WMS_출하';
COMMENT ON TABLE WMS_RETURN IS 'WMS_반품';
COMMENT ON TABLE WMS_INVOICE IS 'WMS_송장';
COMMENT ON TABLE WMS_LOAD IS 'WMS_상차';
```

#### 2.2.3 SM (System Management)
```sql
COMMENT ON TABLE SM_USER IS '시스템_사용자';
COMMENT ON TABLE SM_MENU IS '시스템_메뉴';
COMMENT ON TABLE SM_COMM_H IS '시스템_공통코드';
COMMENT ON TABLE SM_COMM_D IS '시스템_공통코드_상세';
COMMENT ON TABLE SM_BIZ_CONFIG IS '시스템_사업장_설정';
COMMENT ON TABLE SM_API_CONFIG IS '시스템_API_설정';
```

### 2.3 연결 테이블 (조인 테이블)
```sql
COMMENT ON TABLE MDM_BIZ_PROD IS 'MDM_사업장_품목';
COMMENT ON TABLE MDM_BIZ_CONT IS 'MDM_사업장_거래처';
COMMENT ON TABLE MDM_BIZ_WH IS 'MDM_사업장_창고';
COMMENT ON TABLE MDM_CONT_PROD IS 'MDM_거래처_품목';
COMMENT ON TABLE MDM_USER_BIZ IS 'MDM_권한사업장';
COMMENT ON TABLE MDM_USER_CENTER IS 'MDM_권한센터';
```

### 2.4 상세/처리 테이블
```sql
-- 품목 상세 테이블 패턴
COMMENT ON TABLE WMS_INWH_PROD IS 'WMS_입고_품목';
COMMENT ON TABLE WMS_OUTWH_PROD IS 'WMS_출고_품목';
COMMENT ON TABLE WMS_OUTBIZ_PROD IS 'WMS_출하_품목';
COMMENT ON TABLE WMS_RETURN_PROD IS 'WMS_반품_품목';
COMMENT ON TABLE WMS_LOAD_PROD IS 'WMS_상차_품목';

-- 처리 테이블 패턴
COMMENT ON TABLE WMS_INWH_TRAN IS 'WMS_입고_처리';
COMMENT ON TABLE WMS_OUTWH_TRAN IS 'WMS_출고_처리';
COMMENT ON TABLE WMS_INVEN_AD_TRAN IS 'WMS_재고조정_처리';
COMMENT ON TABLE WMS_INVEN_MV_TRAN IS 'WMS_재고이동_처리';
COMMENT ON TABLE WMS_RETURN_TRAN IS 'WMS_반품_처리';
```

### 2.5 로그/이력 테이블
```sql
COMMENT ON TABLE SM_LOG_API IS '시스템_로그_API';
COMMENT ON TABLE SM_LOG_CONN IS '시스템_로그_접근';
COMMENT ON TABLE SM_LOG_ERROR IS '시스템_로그_에러';
COMMENT ON TABLE SM_LOG_MENU IS '시스템_로그_메뉴접근';
COMMENT ON TABLE SIF_BATCH_HISTORY IS 'SIF_배치_이력';
COMMENT ON TABLE WES_PROCESS_HISTORY IS 'WES_처리_이력';
COMMENT ON TABLE SM_ALARM_HISTORY IS '시스템_알람_이력';
```

---

## 3. 컬럼 주석 규칙

### 3.1 기본 패턴
```
{도메인}[_{속성}][_{타입}]
```

### 3.2 PK (Primary Key)
```sql
-- 패턴: {도메인}_SEQ
COMMENT ON COLUMN MDM_PROD.prod_seq IS '품목_SEQ';
COMMENT ON COLUMN MDM_BIZ.biz_seq IS '사업장_SEQ';
COMMENT ON COLUMN WMS_INWH.inwh_seq IS '입고_SEQ';
COMMENT ON COLUMN WMS_OUTWH.outwh_seq IS '출고_SEQ';
-- wms_inven은 복합 PK (biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq) — inven_seq 컬럼 없음
COMMENT ON COLUMN WMS_INVEN_INOUT.inven_inout_seq IS '재고_수불_SEQ';
```

### 3.3 FK (Foreign Key)
```sql
-- 패턴: {참조도메인}_SEQ
COMMENT ON COLUMN WMS_INWH_PROD.biz_seq IS '사업장_SEQ';
COMMENT ON COLUMN WMS_INWH_PROD.prod_seq IS '품목_SEQ';
COMMENT ON COLUMN WMS_INWH_PROD.inwh_seq IS '입고_SEQ';
COMMENT ON COLUMN WMS_INVEN.wh_seq IS '창고_SEQ';
COMMENT ON COLUMN WMS_INVEN.loc_seq IS '위치_SEQ';
COMMENT ON COLUMN WMS_INVEN.cont_seq IS '거래처_SEQ';
```

### 3.4 코드 컬럼
```sql
-- 패턴: {도메인}_{속성}_코드
COMMENT ON COLUMN MDM_PROD.prod_div_cd IS '품목_구분_코드';
COMMENT ON COLUMN MDM_PROD.unit_cd IS '단위_코드';
COMMENT ON COLUMN WMS_INWH.inwh_sts_cd IS '입고_상태_코드';
COMMENT ON COLUMN WMS_INWH.inwh_type_cd IS '입고_유형_코드';
COMMENT ON COLUMN WMS_OUTWH.outwh_sts_cd IS '출고_상태_코드';
COMMENT ON COLUMN WMS_INVEN.inout_type_cd IS '수불_유형_코드';
COMMENT ON COLUMN SM_COMM_D.comm_d_cd IS '하위_코드';
COMMENT ON COLUMN SM_COMM_H.comm_h_cd IS '상위_코드';
```

### 3.5 명칭 컬럼
```sql
-- 패턴: {도메인}_명 / {도메인}명
COMMENT ON COLUMN MDM_PROD.prod_nm IS '품목_명';
COMMENT ON COLUMN MDM_PROD.prod_nm_short IS '품목_명_약칭';
COMMENT ON COLUMN MDM_BIZ.biz_nm IS '사업장_명';
COMMENT ON COLUMN MDM_CONT.cont_nm IS '거래처_명';
COMMENT ON COLUMN MDM_WH.wh_nm IS '창고_명';
COMMENT ON COLUMN MDM_LOC.loc_nm IS '위치_명';
COMMENT ON COLUMN SM_USER.user_nm IS '사용자_명';
```

### 3.6 번호 컬럼
```sql
-- 패턴: {도메인}_번호
COMMENT ON COLUMN MDM_PROD.prod_no IS '품목_번호';
COMMENT ON COLUMN WMS_INWH.inwh_no IS '입고_번호';
COMMENT ON COLUMN WMS_OUTWH.outwh_no IS '출고_번호';
COMMENT ON COLUMN WMS_OUTBIZ.outbiz_no IS '출하_번호';
COMMENT ON COLUMN WMS_INVOICE.invoice_no IS '송장_번호';
COMMENT ON COLUMN WMS_INVEN.lot_no IS 'LOT_번호';
COMMENT ON COLUMN MDM_BIZ.biz_no IS '사업자_번호';
```

### 3.7 수량 컬럼
```sql
-- 패턴: {속성}_수량
COMMENT ON COLUMN WMS_INWH_PROD.req_qty IS '요청_수량';
COMMENT ON COLUMN WMS_INWH_PROD.proc_qty IS '처리_수량';
COMMENT ON COLUMN WMS_INWH_PROD.ex_qty IS '기처리_수량';
COMMENT ON COLUMN WMS_INVEN.inven_qty IS '재고_수량';
COMMENT ON COLUMN WMS_INVEN.wt_qty IS '대기재고_수량';
COMMENT ON COLUMN MDM_PROD.in_qty IS '입수량';
COMMENT ON COLUMN MDM_PROD.pallet_stack_qty IS '파렛트_배단_수';
```

### 3.8 일자/시간 컬럼

#### 3.8.1 연월일 (YMD)
```sql
-- 패턴: {속성}_연월일
COMMENT ON COLUMN WMS_INWH.req_ymd IS '예정_연월일';
COMMENT ON COLUMN WMS_INWH.proc_ymd IS '처리_연월일';
COMMENT ON COLUMN WMS_INWH.cfm_ymd IS '확정_연월일';
COMMENT ON COLUMN WMS_INVEN.exp_ymd IS '유통기한_연월일';
COMMENT ON COLUMN WMS_INVEN.mng_ymd IS '입고/제조일자';
```

#### 3.8.2 시분초 (HMS)
```sql
-- 패턴: {속성}_시분초
COMMENT ON COLUMN WMS_INWH.req_hms IS '예정_시분초';
COMMENT ON COLUMN WMS_INWH.proc_hms IS '처리_시분초';
COMMENT ON COLUMN WMS_INWH.cfm_hms IS '확정_시분초';
```

#### 3.8.3 일시 (DT)
```sql
-- 패턴: {속성}_일시
COMMENT ON COLUMN SM_USER.reg_dt IS '등록_일시';
COMMENT ON COLUMN SM_USER.mod_dt IS '수정_일시';
COMMENT ON COLUMN SM_LOG_CONN.conn_dt IS '접근_일시';
COMMENT ON COLUMN SM_LOG_API.req_dt IS '요청_일시';
COMMENT ON COLUMN SM_LOG_API.res_dt IS '응답_일시';
```

### 3.9 YES/NO 플래그
```sql
-- 패턴: {속성}_여부
COMMENT ON COLUMN MDM_PROD.use_yn IS '사용_여부';
COMMENT ON COLUMN MDM_PROD.del_yn IS '삭제_여부';
COMMENT ON COLUMN WMS_INWH.cfm_yn IS '확정_여부';
COMMENT ON COLUMN WMS_INWH.proc_yn IS '처리_여부';
COMMENT ON COLUMN MDM_PROD.qc_yn IS '검사_여부';
COMMENT ON COLUMN MDM_PROD.lot_no_mng_yn IS 'LOT번호_관리_여부';
COMMENT ON COLUMN MDM_PROD.mng_ymd_mng_yn IS '제조일자_관리_여부';
COMMENT ON COLUMN MDM_PROD.eff_mng_yn IS '유통기한_관리_여부';
```

### 3.10 사용자 컬럼
```sql
-- 처리자
COMMENT ON COLUMN WMS_INWH_TRAN.proc_user_id IS '처리자_ID';
COMMENT ON COLUMN WMS_INWH.req_user_nm IS '요청_사용자_명';
COMMENT ON COLUMN WMS_INWH.cfm_user_id IS '확정자_ID';

-- 등록/수정자
COMMENT ON COLUMN MDM_PROD.reg_id IS '등록자';
COMMENT ON COLUMN MDM_PROD.mod_id IS '수정자';

-- 사용자 정보
COMMENT ON COLUMN SM_USER.user_id IS '사용자_ID';
COMMENT ON COLUMN SM_USER.user_nm IS '사용자_명';
```

### 3.11 SKU 관련
```sql
COMMENT ON COLUMN WMS_INVEN.sku1 IS 'SKU1';
COMMENT ON COLUMN WMS_INVEN.sku2 IS 'SKU2';
COMMENT ON COLUMN WMS_INVEN.sku1_seq IS 'SKU1_일련번호';
COMMENT ON COLUMN WMS_INVEN.sku2_seq IS 'SKU2_일련번호';
COMMENT ON COLUMN MDM_PROD.sku_mng_cd IS 'SKU_관리_유형_코드';
COMMENT ON COLUMN MDM_PROD.sku2_mng_yn IS '파렛트_관리_여부';
```

### 3.12 바코드 관련
```sql
COMMENT ON COLUMN MDM_PROD.prod_barcode IS '품목_BARCODE';
COMMENT ON COLUMN MDM_PROD.parent_barcode IS '상위_품목_BARCODE';
COMMENT ON COLUMN MDM_LOC.loc_barcode IS '위치_BARCODE';
COMMENT ON COLUMN MDM_PROD.barcode_type_cd IS '바코드_유형_코드';
COMMENT ON COLUMN MDM_PROD.barcode_type_cd1 IS '1D_바코드_유형_코드';
COMMENT ON COLUMN MDM_PROD.barcode_type_cd2 IS '2D_바코드_유형_코드';
```

### 3.13 치수/무게
```sql
COMMENT ON COLUMN MDM_PROD.len_x IS '가로';
COMMENT ON COLUMN MDM_PROD.len_y IS '세로';
COMMENT ON COLUMN MDM_PROD.len_z IS '높이';
COMMENT ON COLUMN MDM_PROD.wgt IS '중량';
COMMENT ON COLUMN MDM_PROD.net_weight IS '순중량';
COMMENT ON COLUMN MDM_PROD.cbm IS 'CBM';
```

### 3.14 이동 관련 (FROM-TO)
```sql
-- FROM
COMMENT ON COLUMN WMS_INVEN_MV.fr_wh_seq IS 'FR_창고_SEQ';
COMMENT ON COLUMN WMS_INVEN_MV.fr_loc_seq IS 'FR_위치_SEQ';
COMMENT ON COLUMN WMS_INVEN_MV.fr_lot_no IS 'FR_LOT_번호';
COMMENT ON COLUMN WMS_INVEN_MV.fr_exp_ymd IS 'FR_유통기한';
COMMENT ON COLUMN WMS_INVEN_MV.fr_sku1 IS 'FR_SKU1';

-- TO
COMMENT ON COLUMN WMS_INVEN_MV.to_wh_seq IS 'TO_창고_SEQ';
COMMENT ON COLUMN WMS_INVEN_MV.to_loc_seq IS 'TO_위치_SEQ';
COMMENT ON COLUMN WMS_INVEN_MV.to_lot_no IS 'TO_LOT_번호';
COMMENT ON COLUMN WMS_INVEN_MV.to_exp_ymd IS 'TO_유통기한';
COMMENT ON COLUMN WMS_INVEN_MV.to_sku1 IS 'TO_SKU1';
```

### 3.15 외부 연동 (IF)
```sql
COMMENT ON COLUMN MDM_PROD.if_prod_id IS 'IF_품목_ID';
COMMENT ON COLUMN MDM_BIZ.if_biz_id IS 'IF_사업장_ID';
COMMENT ON COLUMN MDM_CONT.if_cont_id IS 'IF_거래처_ID';
COMMENT ON COLUMN MDM_WH.if_wh_id IS 'IF_창고_ID';
COMMENT ON COLUMN SIF_BATCH_HISTORY.if_key IS 'IF_KEY';
COMMENT ON COLUMN SIF_BATCH_HISTORY.if_seq IS 'IF_SEQ';
COMMENT ON COLUMN SIF_BATCH_HISTORY.if_send_yn IS 'IF_송신_여부';
```

### 3.16 기타 특수 컬럼
```sql
-- 비고
COMMENT ON COLUMN MDM_PROD.note IS '비고';
COMMENT ON COLUMN WMS_INWH.note1 IS '비고_1';
COMMENT ON COLUMN WMS_INWH.note2 IS '비고_2';

-- 순번
COMMENT ON COLUMN WMS_INWH_PROD.seq IS '순번';
COMMENT ON COLUMN SM_MENU.disp_no IS '표시_순서';
COMMENT ON COLUMN WMS_LOAD.load_idx IS '차수';

-- 주소
COMMENT ON COLUMN MDM_BIZ.addr IS '주소';
COMMENT ON COLUMN MDM_BIZ.addr_dtl IS '주소_상세';
COMMENT ON COLUMN MDM_BIZ.post_no IS '우편_번호';

-- 연락처
COMMENT ON COLUMN MDM_BIZ.tel IS '전화번호';
COMMENT ON COLUMN MDM_BIZ.fax IS '팩스';
COMMENT ON COLUMN SM_USER.email IS '이메일';
```

---

## 4. 주석 작성 원칙

### 4.1 필수 주석 대상
```sql
-- 모든 테이블
COMMENT ON TABLE {table_name} IS '{논리명}';

-- 모든 컬럼
COMMENT ON COLUMN {table_name}.{column_name} IS '{논리명}';

-- 중요 제약조건 (선택사항)
COMMENT ON CONSTRAINT {constraint_name} ON {table_name} IS '{설명}';
```

### 4.2 주석 작성 시점
```sql
-- 테이블 생성 직후 작성
CREATE TABLE MDM_FREEGIFT (...);

COMMENT ON TABLE MDM_FREEGIFT IS '사은품_프로모션';
COMMENT ON COLUMN MDM_FREEGIFT.freegift_seq IS '사은품_SEQ';
COMMENT ON COLUMN MDM_FREEGIFT.promotion_id IS '프로모션_ID';
-- ... (모든 컬럼에 주석 작성)
```

### 4.3 약어 주석 처리
```sql
-- 약어는 대문자로 유지 (✅ 올바른 예)
COMMENT ON COLUMN WMS_INWH.inwh_seq IS '입고_SEQ';
COMMENT ON COLUMN MDM_PROD.prod_no IS '품목_번호';
COMMENT ON COLUMN WMS_INVEN.lot_no IS 'LOT_번호';
COMMENT ON COLUMN MDM_PROD.hs_code IS 'HS_CODE';
COMMENT ON COLUMN WMS_INVEN.cbm IS 'CBM';

-- 약어를 한글로 풀어쓰지 않음 (❌ 잘못된 예)
-- COMMENT ON COLUMN WMS_INWH.inwh_seq IS '입고_시퀀스';
-- COMMENT ON COLUMN MDM_PROD.hs_code IS '에이치에스_코드';
```

### 4.4 괄호 사용 규칙
```sql
-- 설명이 필요한 경우
COMMENT ON COLUMN WMS_INWH_PROD.proc_user_id IS '처리자_ID(입고)';
COMMENT ON COLUMN MDM_PROD.mng_ymd IS '입고/제조일자';
COMMENT ON COLUMN WMS_INVEN.inout_cd IS '수불_유형_여부';
COMMENT ON COLUMN SM_COMM_D.comm_d_cd IS '하위_코드';

-- 타시스템 연동 표시
COMMENT ON COLUMN WMS_INWH.erp_wh_cd IS '입고처_CODE(타시스템)';
COMMENT ON COLUMN WMS_OUTWH.req_no IS '문서_번호(타시스템)';

-- NEW 표시 (신규 추가)
COMMENT ON TABLE MDM_USER IS 'MDM_사용자(NEW)';
COMMENT ON TABLE SM_LOG_CONN_DTL IS '시스템_로그_접근_상세(NEW)';
```

---

## 5. 전체 예시

```sql
-- =============================================
-- 사은품 프로모션 테이블 생성 및 주석
-- =============================================

CREATE TABLE MDM_FREEGIFT (
    freegift_seq        INTEGER         NOT NULL DEFAULT NEXTVAL('mdm_freegift_seq'),
    biz_seq             INTEGER         NOT NULL,
    promotion_id        VARCHAR(20)     NOT NULL,
    promotion_nm        VARCHAR(200)    NOT NULL,
    promotion_type_cd   VARCHAR(20)     NOT NULL,
    gift_count_cd       VARCHAR(20)     NOT NULL,
    target_type_cd      VARCHAR(20)     NOT NULL,
    target_qty          INTEGER,
    apply_start_ymd     VARCHAR(8)      NOT NULL,   -- 적용시작일자 YYYYMMDD
    apply_end_ymd       VARCHAR(8)      NOT NULL,   -- 적용종료일자 YYYYMMDD
    apply_yn            CHAR(1)         NOT NULL DEFAULT 'N',
    note                VARCHAR(500),
    use_yn              CHAR(1)         NOT NULL DEFAULT 'Y',
    del_yn              CHAR(1)         NOT NULL DEFAULT 'N',
    reg_id              VARCHAR(50)     NOT NULL,
    reg_dt              TIMESTAMP       NOT NULL DEFAULT NOW(),
    mod_id              VARCHAR(50),
    mod_dt              TIMESTAMP,
    CONSTRAINT mdm_freegift_pkey PRIMARY KEY (freegift_seq)
);

-- 테이블 주석
COMMENT ON TABLE MDM_FREEGIFT IS 'MDM_사은품_프로모션';

-- 컬럼 주석
COMMENT ON COLUMN MDM_FREEGIFT.freegift_seq IS '사은품_SEQ';
COMMENT ON COLUMN MDM_FREEGIFT.biz_seq IS '사업장_SEQ';
COMMENT ON COLUMN MDM_FREEGIFT.promotion_id IS '프로모션_ID';
COMMENT ON COLUMN MDM_FREEGIFT.promotion_nm IS '프로모션명';
COMMENT ON COLUMN MDM_FREEGIFT.promotion_type_cd IS '프로모션_유형_코드';
COMMENT ON COLUMN MDM_FREEGIFT.gift_count_cd IS '증정횟수_코드';
COMMENT ON COLUMN MDM_FREEGIFT.target_type_cd IS '대상구분_코드';
COMMENT ON COLUMN MDM_FREEGIFT.target_qty IS '대상수량';
COMMENT ON COLUMN MDM_FREEGIFT.apply_start_ymd IS '적용_시작_연월일';
COMMENT ON COLUMN MDM_FREEGIFT.apply_end_ymd IS '적용_종료_연월일';
COMMENT ON COLUMN MDM_FREEGIFT.apply_yn IS '적용_여부';
COMMENT ON COLUMN MDM_FREEGIFT.note IS '비고';
COMMENT ON COLUMN MDM_FREEGIFT.use_yn IS '사용_여부';
COMMENT ON COLUMN MDM_FREEGIFT.del_yn IS '삭제_여부';
COMMENT ON COLUMN MDM_FREEGIFT.reg_id IS '등록자';
COMMENT ON COLUMN MDM_FREEGIFT.reg_dt IS '등록_일시';
COMMENT ON COLUMN MDM_FREEGIFT.mod_id IS '수정자';
COMMENT ON COLUMN MDM_FREEGIFT.mod_dt IS '수정_일시';
```

---

## 6. 주석 작성 체크리스트

### 6.1 DO (권장)
- [x] 모든 테이블과 컬럼에 주석 작성
- [x] 한글 사용, 언더스코어로 구분
- [x] 약어는 대문자 유지 (SEQ, ID, CODE, LOT)
- [x] 일관된 용어 사용 (수량, 여부, 일시, 번호)
- [x] 테이블 생성 직후 바로 주석 작성
- [x] Prefix 포함 (MDM_, WMS_, SM_)

### 6.2 DON'T (금지)
- [ ] 영문 주석 사용 금지
- [ ] 공백 사용 금지 (언더스코어 사용)
- [ ] 약어를 한글로 풀어쓰기 금지
- [ ] 불명확한 용어 사용 금지
- [ ] 주석 누락 금지

---

이 주석 규칙을 따르면 데이터베이스 스키마를 명확하게 이해하고 유지보수할 수 있습니다!
