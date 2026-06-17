---
title: 시퀀스 생성 규칙
description: WMS DB 테이블에 시퀀스(SEQUENCE)를 생성할 때 반드시 따라야 하는 규칙
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: rule
domain: database
tags:
  - database
  - sequence
  - ddl
  - postgresql
---

# 시퀀스 생성 규칙 (Sequence Creation Rule)

## 1. 기본 규칙

- 시퀀스명 = `{테이블명}_seq`
- `CREATE SEQUENCE {테이블명}_seq START 1;`
- 주의: 업무번호는 시퀀스를 사용하지 않음 `{업무명}_no` 형태 사용 (예: `outwh_no`, `inwh_no`)

## 2. START 값 설정

| 상황 | START 값 |
|------|---------|
| 신규 테이블 | `1` |
| 기존 데이터가 있는 경우 | `(SELECT MAX({pk컬럼}) + 1 FROM {테이블명})` |

기존 데이터가 있을 때 예시:

```sql
-- 현재 max seq 조회 후 그 다음 번호부터 시작
CREATE SEQUENCE wms_inwh_seq START 1001;
-- 또는 동적으로 설정
SELECT setval('wms_inwh_seq', (SELECT MAX(inwh_seq) FROM wms_inwh));
```

## 3. 헤더/자식 테이블 seq 타입 규칙

**테이블 구조에 따라 seq 컬럼의 데이터 타입을 다르게 적용한다.**

| 테이블 역할 | seq 데이터 타입 | 이유 |
|------------|----------------|------|
| 헤더(H) 테이블 | `int4` | 헤더는 단건 문서 단위 — 최대 21억 건으로 충분 |
| 자식(D1~Dn) 테이블 | `bigint` | 자식은 다건 적재 — int4 오버플로우 방지 |

```sql
-- 헤더 테이블: int4 PK
CREATE TABLE wms_inwh_req (
    inwh_req_seq  int4  NOT NULL DEFAULT nextval('wms_inwh_req_seq'::regclass),
    ...
    CONSTRAINT wms_inwh_req_pkey PRIMARY KEY (inwh_req_seq)
);

-- 자식 테이블: bigint PK
CREATE TABLE wms_inwh_req_prod (
    inwh_req_prod_seq  bigint  NOT NULL DEFAULT nextval('wms_inwh_req_prod_seq'::regclass),
    inwh_req_seq       int4    NOT NULL,   -- 헤더 FK: 헤더와 동일 타입(int4) 사용
    ...
    CONSTRAINT wms_inwh_req_prod_pkey PRIMARY KEY (inwh_req_prod_seq)
);
```

> FK 컬럼 타입은 **참조하는 부모 테이블 PK 타입과 반드시 일치**시킨다.

---

## 4. 생성 예시

```sql
-- 입고 (wms_inwh_*)
CREATE SEQUENCE wms_inwh_seq START 1;
CREATE SEQUENCE wms_inwh_prod_seq START 1;
CREATE SEQUENCE wms_inwh_tran_seq START 1;
```

```sql
-- 기준정보 (mdm_*)
CREATE SEQUENCE mdm_prod_seq START 1;
CREATE SEQUENCE mdm_wh_seq START 1;
CREATE SEQUENCE mdm_loc_seq START 1;
```

## 5. 컬럼 기본값 설정

```sql
-- 테이블 컬럼의 DEFAULT로 시퀀스 연결
ALTER TABLE wms_inwh
    ALTER COLUMN inwh_seq SET DEFAULT nextval('wms_inwh_seq'::regclass);
```
