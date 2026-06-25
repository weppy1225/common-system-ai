---
title: OMS 도메인 표준
description: OMS 도메인 개념(업무 흐름·용어·기술 전제)의 진입점. 코딩 패턴·구현 규칙은 spec/{프로젝트}/_knowledge/patterns/ 에 있다.
status: active
version: 1.1.0
author: binaryarc
repo_role: ai-hub
agent_usage: reference
domain: oms
tags:
  - domain-standard
  - oms
---

# OMS 도메인 표준 (Domain Baseline)

OMS **도메인에 속한 모든 프로젝트가 공유**하는 개념·기술 전제를 둔다. 특정 고객/프로젝트의 실데이터(실 테이블·메뉴·코드·구현 패턴)는 여기 두지 않는다 — 그건 `spec/{프로젝트}/_knowledge/` 의 ③ 계층이다.
숨은 전제: OMS = 전통 Spring(Boot 아님) · Ant WAR 빌드 · OMS=PostgreSQL + ERP=SQL Server 멀티 DB · Vue3+Vite+Pinia. FE는 **한 레포 두 UI 시스템** — 쇼핑몰(가맹점 `/bc`, e-commerce 스타일·AUIGrid 미사용)과 관리자(Admin `/be`, WMS식 AUIGrid).

## 무엇을 넣나 (프로젝트가 달라도 같은 도메인 개념)

- OMS 업무 흐름 (주문·출하·반품 등 비즈니스 프로세스 개요)
- OMS 표준 용어·약어 정의 (glossary)
- OMS 기술 전제 (Spring 전통, 멀티 DB 구조, FE 모드 분기 개요)

## 무엇을 넣지 않나

| 유형 | 위치 |
|---|---|
| 구현 패턴 (BE 레이어·SQL·MyBatis·FE 라우터 등) | `spec/{프로젝트}/_knowledge/patterns/` |
| 기동·빌드·배포 가이드 | `spec/{프로젝트}/_knowledge/install-guide/` |
| 실 테이블 스키마·컬럼 사전 | `spec/{프로젝트}/_knowledge/db-schema/` |
| 실제 API 목록·필드 명세 | `spec/{프로젝트}/_knowledge/interface/` |
| 메뉴 레지스트리·공통코드값 | `spec/{프로젝트}/_knowledge/` |

## 계층 관계

```
① 코어        patterns/ · .claude/(무접두)        전 프로젝트·전 도메인 공통
② 도메인 표준  knowledgebase/domains/{도메인}/      같은 도메인 프로젝트끼리 공유  ← 여기
③ 프로젝트     spec/{프로젝트}/_knowledge/          프로젝트 전용 실데이터
```

충돌 시 우선순위: **③ > ②**. 도메인 표준은 기본값, 프로젝트 확정값이 이긴다.
