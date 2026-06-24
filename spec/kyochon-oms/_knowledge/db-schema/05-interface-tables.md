---
title: kyochon-oms 인터페이스·가상계좌 테이블 정의서
description: kyochon-oms 인터페이스(sif_*)·가상계좌(vacs_*)·외부연동(ideatec_*) 테이블 목록을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon-oms
domain: database
tags:
  - database
  - table
  - interface
  - vacs
  - schema
last_verified: 2026-06-23
---

# kyochon-oms 인터페이스·가상계좌 테이블 정의서

> - DB: PostgreSQL / Schema: public
> - 테이블 prefix: `sif_`(인터페이스 배치) · `vacs_`(가상계좌) · `ideatec_`(외부 연동)
> - 출처: 실 OMS dev DB `pg_class` 조회 (2026-06-23). 설명은 DB comment 원본. comment 미설정 테이블은 빈칸.

---

## 1. 테이블 목록

| 테이블명 | 설명 |
|---|---|
| sif_batch_history | SIF_배치_이력 |
| vacs_ahst | 가상계좌_거래내역_원장 |
| vacs_vact | (DB comment 미설정) |
| vacs_totl | (DB comment 미설정) |
| vacs_errlog | (DB comment 미설정) |
| ideatec_history | 이데아텍_이력 |

---

## 2. 비고

> 인터페이스 컨벤션(연동 방식·배치 규칙)은 도메인 표준 문서를 참조한다 → `knowledgebase/domains/oms/`.
> 컬럼 단위 상세는 실 스키마(`\d sif_*`, `\d vacs_*`)를 우선 확인한다.
