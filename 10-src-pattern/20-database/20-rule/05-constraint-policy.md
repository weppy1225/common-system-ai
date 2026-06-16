---
title: 제약조건 정책
description: WMS DB 테이블에 PK, FK, UNIQUE, NOT NULL, CHECK, INDEX 제약조건을 적용할 때 반드시 따라야 하는 정책
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: rule
domain: database
tags:
  - database
  - constraint
  - primary-key
  - foreign-key
  - index
  - ddl
---

# 제약조건 정책 (Constraint Policy)

> DBMS: PostgreSQL 15.2 / Schema: public

---

## 1. PK(Primary Key) 정책

- PK는 **단일 시퀀스 컬럼** 또는 **복합 컬럼** 방식을 사용한다.
  - **단일 PK**: 독립적으로 식별 가능한 마스터/업무 테이블 — `{테이블_엔티티}_seq` (시퀀스 자동증가)
  - **복합 PK**: 연결 테이블, 재고 테이블 등 복수 키로만 유일성이 보장되는 테이블
- PK 타입: `INTEGER` 또는 `BIGINT` 사용 (테이블별 상이, 도메인 문서 기준)
  - `INTEGER` (int4): 대부분의 기준정보/업무 테이블 (mdm_biz, mdm_prod, wms_inwh 등)
  - `BIGINT`: 대용량 데이터 테이블 (mdm_loc — 대형 센터 로케이션 수 고려)
- 복합 PK 또는 PK 없음 테이블:
  - `wms_inven` (재고: biz_seq, center_seq, prod_seq, sku1, sku2, wh_seq, loc_seq)
  - `wms_inven_sku` (SKU이력: biz_seq, prod_seq, sku1, sku2)
  - `mdm_doc_no` (문서번호: biz_seq, inout_type_cd, base_ymd)
  - `mdm_biz_biz`, `mdm_biz_cont`, `mdm_biz_prod` (사업장 연결 테이블 — 2열 복합 PK)
  - `mdm_biz_center`, `mdm_user_biz`, `mdm_user_center` (권한 매핑 테이블 — PK 없음, UNIQUE 인덱스 활용)
  - `wms_inbiz_inwh` (입하-입고 연결 테이블 — PK 없음, 복합 인덱스 활용)
  - `sm_comm_h`, `sm_comm_d`, `sm_api_config`, `sm_menu_group` 등 시스템 설정/코드 테이블 (복합 PK)

```sql
-- 단일 PK 예시
ALTER TABLE mdm_prod ADD CONSTRAINT mdm_prod_pkey PRIMARY KEY (prod_seq);

-- 시퀀스 기본값 설정
ALTER TABLE mdm_prod ALTER COLUMN prod_seq SET DEFAULT nextval('mdm_prod_seq'::regclass);
```

---

## 2. FK(Foreign Key) 정책

- FK는 참조 무결성 보장 목적으로만 선언
- **CASCADE DELETE/UPDATE 사용 금지** — 소프트 삭제 정책과 충돌
- FK 제약조건명 규칙: `{참조테이블}_TO_{FK테이블}` (예: `mdm_biz_TO_wms_inwh`)

```sql
-- FK 선언 예시 (CASCADE 없음)
ALTER TABLE wms_inwh
    ADD CONSTRAINT mdm_biz_TO_wms_inwh FOREIGN KEY (biz_seq) REFERENCES mdm_biz(biz_seq);
```

---

## 3. 삭제 정책

| 테이블 유형 | 삭제 방식 | 비고 |
|---|---|---|
| `MDM_*` 기준정보 테이블 | **논리삭제** `use_yn = 'N'` | 조회 시 `AND use_yn = 'Y'` 조건 필수 |
| `WMS_*` 업무 테이블 | `del_yn` 컬럼이 있으면 **논리삭제** `del_yn = 'Y'` | 조회 시 `AND del_yn = 'N'` 조건 필수 |
| 삭제 플래그 없는 매핑·처리 테이블 | **물리삭제** `DELETE FROM` | 기존 소스/스키마 확인 |

```sql
-- MDM_* 기준정보: 논리삭제
UPDATE mdm_prod SET use_yn = 'N', mod_id = ?, mod_dt = NOW() WHERE prod_seq = ?;

-- WMS_* 업무: 물리삭제
DELETE FROM wms_inwh WHERE inwh_seq = ?;
```

---

## 4. NOT NULL 정책

- PK 컬럼: 항상 NOT NULL
- Audit 컬럼(`reg_id`, `reg_dt`): NOT NULL
- `use_yn` / `del_yn`: NOT NULL, DEFAULT 'Y' / 'N'
- 업무 필수값 컬럼: NOT NULL (도메인 문서 기준)
- 선택값 컬럼: NULL 허용

---

## 5. UNIQUE 제약조건 정책

- 중복 불가 비즈니스 키에 UNIQUE 제약조건 설정
- 제약조건명 규칙: `UK_{테이블명}` (예: `UK_mdm_biz_wh`)

```sql
-- UNIQUE 예시
ALTER TABLE mdm_biz_wh ADD CONSTRAINT UK_mdm_biz_wh UNIQUE (biz_seq, wh_seq);
```

---

## 6. DEFAULT 값 정책

| 컬럼 | DEFAULT |
|------|---------|
| `use_yn` | `'Y'` |
| `del_yn` | `'N'` |
| `reg_dt` | `NOW()` |
| PK(`*_seq`) | `nextval('{테이블명}_seq'::regclass)` |

---

## 7. INDEX 정책

- PK에는 자동 인덱스 생성
- 조회 조건에 자주 사용되는 컬럼에 추가 인덱스 설정
- 인덱스명 규칙:
  - PK 인덱스: `{테이블명}_pkey` (자동 생성) 또는 `PK_{테이블명}`
  - UNIQUE 인덱스: `UK_{테이블명}` (예: `UK_mdm_biz_wh`)
  - 일반 인덱스: `IX_{테이블명}` 또는 `IX_{테이블명}{숫자}` (예: `IX_wms_inwh1`)

---

## 8. CHECK 제약조건 정책

- 코드값(`_cd` 컬럼)의 유효성은 애플리케이션 레이어에서 검증 (DB CHECK 제약조건 미사용)
- 수량(`qty`), 금액 등 음수 불가 컬럼에 한해 CHECK 적용 가능

```sql
-- CHECK 예시
ALTER TABLE wms_inwh_prod ADD CONSTRAINT wms_inwh_prod_qty_check CHECK (qty >= 0);
```
