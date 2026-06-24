---
title: OMS 도메인 표준
description: OMS 프로젝트들이 공유하는 표준 지식(기동·빌드·배포 차이, BE/DB/FE 코딩 패턴)의 진입점
status: active
version: 1.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: reference
domain: oms
tags:
  - domain-standard
  - oms
---

# OMS 도메인 표준 (Domain Baseline)

OMS **도메인에 속한 모든 프로젝트가 공유**하는 표준 개념·규약을 둔다. 특정 고객/프로젝트의 실데이터(실 테이블·메뉴·코드)는 여기 두지 않는다 — 그건 `spec/{프로젝트}/_knowledge/` 의 ③ 계층이다.
숨은 전제: OMS = 전통 Spring(Boot 아님) · Ant WAR 빌드 · OMS=PostgreSQL + ERP=SQL Server 멀티 DB · Vue3+Vite+Pinia. FE는 **한 레포 두 UI 시스템** — 쇼핑몰(가맹점 `/bc`, e-commerce 스타일·AUIGrid 미사용)과 관리자(Admin `/be`, WMS식 AUIGrid). 상세 → `install-guide/01-startup-guide.md` §3.0.

## 무엇을 넣나 (프로젝트가 달라도 같은 것)

| 폴더/파일 | 내용 |
|---|---|
| `install-guide/01-startup-guide.md` | OMS 고유 기동·빌드·배포 차이 (Ant WAR, 멀티 DB, Vite mode 분기) |
| `patterns/be/` | BE 레이어 작성 패턴(`01-layer-pattern`), 채번 공통모듈(`03-numbering-module`) |
| `patterns/db/` | SQL 쿼리 스타일(`01-sql-query-style`), MyBatis 컨벤션(`02-mybatis-convention`), 네이밍 규칙(`03-naming-rule`) |
| `patterns/fe/` | 라우터·메뉴 등록(`01-router-menu-register`), 공통코드 commCdStore(`02-common-code-commCdStore`) |

> 자동 로딩 코딩 규칙(`.claude/rules/oms-*`)은 `paths` 트리거가 `.claude/rules/` 에서만 동작하므로 그쪽에 둔다. 이 폴더는 상세 패턴 문서를, rules 는 판단 기준을 담고 서로 참조한다.

## 무엇을 넣지 않나 (프로젝트마다 다른 것)

- 실 테이블 스키마·컬럼 사전 → `spec/{프로젝트}/_knowledge/db-schema/`·`glossary/`
- 실제 API 목록·필드 명세 → `spec/{프로젝트}/_knowledge/interface/`
- 메뉴 레지스트리·공통코드값 → `spec/{프로젝트}/_knowledge/`

## 계층 관계

```
① 코어        patterns/ · .claude/(무접두)        전 프로젝트·전 도메인 공통
② 도메인 표준  knowledgebase/domains/{도메인}/      같은 도메인 프로젝트끼리 공유  ← 여기
③ 프로젝트     spec/{프로젝트}/_knowledge/          프로젝트 전용 실데이터
```

충돌 시 우선순위: **③ > ②**. 도메인 표준은 기본값, 프로젝트 확정값이 이긴다.
