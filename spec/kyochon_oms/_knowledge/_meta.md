---
title: kyochon_oms 프로젝트 지식 메타
description: 이 프로젝트가 속한 도메인과 전역 지식(_knowledge)의 구성을 선언한다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon_oms
domain: oms
tags:
  - project-meta
  - knowledge-index
  - oms
---

# kyochon_oms 프로젝트 지식 메타

## 도메인 선언

- **project**: `kyochon_oms`
- **domain**: `oms`
- **형제 레포**: `kyochon-oms-be`(BE) · `kyochon-oms-fe`(FE)

이 프로젝트는 **OMS 도메인**에 속한다. 따라서 AI 에이전트·스킬·규칙은 다음 두 층에서 지식을 읽는다.

| 층 | 위치 | 내용 |
|---|---|---|
| ② 도메인 표준 (OMS 공통) | `knowledgebase/domains/oms/install-guide/` · `knowledgebase/domains/oms/patterns/` · `.claude/rules/oms-*` | 기동·빌드·배포 차이, BE/FE/DB 코딩 컨벤션, SQL/MyBatis/네이밍 규칙, 보안 규칙 |
| ③ 프로젝트 확정 (이 프로젝트 전용) | `spec/kyochon_oms/_knowledge/` | 실 테이블 스키마·메뉴·컬럼사전·실 API 목록/필드명세 |

> 충돌 시 우선순위: **③ 프로젝트 확정 > ② 도메인 표준.** 도메인 표준은 "기본값", 프로젝트 확정은 "실제값"이다.

## OMS 도메인 표준 문서 (② 층)

도메인 표준은 시스템(도메인)별로 `knowledgebase/domains/{도메인}/` 에 둔다(WMS=`knowledgebase/domains/wms/`, OMS=`knowledgebase/domains/oms/`). OMS 도메인 표준 문서는 아래와 같다.

| 경로 | 내용 |
|---|---|
| `knowledgebase/domains/oms/install-guide/oms-01-startup-guide.md` | OMS 고유 기동·빌드·배포 차이 (Ant WAR, PostgreSQL+SQL Server 멀티 DB, Vite mode 분기) |
| `knowledgebase/domains/oms/patterns/be/` | BE 레이어 작성 패턴, 채번 공통모듈 |
| `knowledgebase/domains/oms/patterns/db/` | SQL 쿼리 스타일, MyBatis 컨벤션, 네이밍 규칙 |
| `knowledgebase/domains/oms/patterns/fe/` | 라우터·메뉴 등록, 공통코드 commCdStore |
| `.claude/rules/oms-backend-convention.md` | BE 코딩 컨벤션 |
| `.claude/rules/oms-frontend-convention.md` | FE 코딩 컨벤션 |
| `.claude/rules/oms-db-convention.md` | DB 컨벤션 |
| `.claude/rules/oms-security.md` | 보안 규칙(민감정보 노출 방지) |

## `_knowledge/` 구성 (③ 프로젝트 확정 층)

| 경로 | 내용 | 채우는 방법 |
|---|---|---|
| `db-schema/` | 실 테이블 카탈로그 + 공통코드 | `/SD_331`(테이블정의서)·`/SD_333`(DDL) 추출 후 정리, 또는 `/KB_100 {메뉴코드}` |
| `glossary/dictionary.yaml` | 컬럼 용어 사전 (컬럼명 → 한글 의미) | 테이블정의서 컬럼 주석에서 도출 |
| `interface/api-list.md` | ERP 연동 API 목록 | BE 인터페이스 컨트롤러 스캔 후 정리 |
| `menu-list.md` | 메뉴코드 레지스트리 | BE/FE 컨트롤러·라우터 스캔 후 정리 |

> 본 `_knowledge/` 하위 데이터 파일은 현재 **스캐폴드(빈 골격)** 상태다. 실 데이터는 추정하지 않고 위 "채우는 방법"의 스킬·소스 스캔으로 확정해 채운다.

## 새 프로젝트 추가 시

같은 OMS 도메인의 새 프로젝트는 `spec/{프로젝트}/_knowledge/` 에 자신의 실데이터만 생성하고, 이 `_meta.md` 를 복사해 `project` 값만 바꾼다. 도메인 표준(`knowledgebase/domains/oms/install-guide/`·`knowledgebase/domains/oms/patterns/`)은 공유하므로 복제하지 않는다.
