---
title: kyochon-oms 프로젝트 지식 메타
description: 이 프로젝트가 속한 도메인과 전역 지식(_knowledge)의 구성을 선언한다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: kyochon-oms
domain: oms
tags:
  - project-meta
  - knowledge-index
  - oms
---

# kyochon-oms 프로젝트 지식 메타

## 도메인 선언

- **project**: `kyochon-oms`
- **domain**: `oms`
- **형제 레포**: `kyochon-oms-be`(BE) · `kyochon-oms-fe`(FE)

이 프로젝트는 **OMS 도메인**에 속한다. 따라서 AI 에이전트·스킬·규칙은 다음 두 층에서 지식을 읽는다.

| 층 | 위치 | 내용 |
|---|---|---|
| ② 도메인 표준 (OMS 공통) | `knowledgebase/domains/oms/`(README 개념) · `.claude/rules/oms-*` | OMS 업무흐름·용어·기술전제, BE/FE/DB 코딩 컨벤션, 보안 규칙 |
| ③ 프로젝트 확정 (이 프로젝트 전용) | `spec/kyochon-oms/_knowledge/` | 기동·빌드·배포 차이, BE/FE/DB 구현 패턴, 실 테이블 스키마·메뉴·컬럼사전·실 API 목록/필드명세 |

> 충돌 시 우선순위: **③ 프로젝트 확정 > ② 도메인 표준.** 도메인 표준은 "기본값", 프로젝트 확정은 "실제값"이다.

## OMS 도메인 표준 문서 (② 층)

도메인 표준은 시스템(도메인)별로 `knowledgebase/domains/{도메인}/` 에 둔다(WMS=`knowledgebase/domains/wms/`, OMS=`knowledgebase/domains/oms/`). ② 층에는 **OMS 도메인 개념**(업무흐름·용어·기술전제)과 도메인 공통 코딩 규칙만 둔다. 기동·빌드·배포 차이와 BE/FE/DB 구현 패턴은 ③ 프로젝트 층(`spec/kyochon-oms/_knowledge/`)으로 이동했다(아래 ③ 표 참조).

| 경로 | 내용 |
|---|---|
| `knowledgebase/domains/oms/README.md` | OMS 도메인 개념 진입점 (업무흐름·용어·기술전제) |
| `.claude/rules/oms-backend-convention.md` | BE 코딩 컨벤션 |
| `.claude/rules/oms-frontend-convention.md` | FE 코딩 컨벤션 |
| `.claude/rules/oms-db-convention.md` | DB 컨벤션 |
| `.claude/rules/oms-security.md` | 보안 규칙(민감정보 노출 방지) |

## `_knowledge/` 구성 (③ 프로젝트 확정 층)

| 경로 | 내용 | 채우는 방법 |
|---|---|---|
| `install-guide/01-startup-guide.md` | OMS 고유 기동·빌드·배포 차이 (Ant WAR, PostgreSQL+SQL Server 멀티 DB, Vite mode 분기) | ② → ③ 이동 완료 |
| `patterns/be/` · `patterns/db/` · `patterns/fe/` | BE 레이어·채번 / SQL·MyBatis·네이밍 / 라우터·메뉴·commCdStore 구현 패턴 | ② → ③ 이동 완료 |
| `auth-login.md` | 로그인 API·JWT 인증 구조·curl/JUnit 인증 방법 | 실 코드 검증 완료(2026-06-23) |
| `db-schema/` | 실 테이블 카탈로그 + 공통코드 | `/SD_331`(테이블정의서)·`/SD_333`(DDL) 추출 후 정리, 또는 `/KB_100 {메뉴코드}` |
| `glossary/dictionary.yaml` | 컬럼 용어 사전 (컬럼명 → 한글 의미) | 테이블정의서 컬럼 주석에서 도출 |
| `interface/api-list.md` | ERP 연동 API 목록 | BE 인터페이스 컨트롤러 스캔 후 정리 |
| `menu-list.md` | 메뉴코드 레지스트리 | BE/FE 컨트롤러·라우터 스캔 후 정리 |

> 본 `_knowledge/` 하위 데이터 파일은 현재 **스캐폴드(빈 골격)** 상태다. 실 데이터는 추정하지 않고 위 "채우는 방법"의 스킬·소스 스캔으로 확정해 채운다.

## 새 프로젝트 추가 시

같은 OMS 도메인의 새 프로젝트는 `spec/{프로젝트}/_knowledge/` 에 자신의 실데이터·구현 패턴·기동가이드를 생성하고, 이 `_meta.md` 를 복사해 `project` 값만 바꾼다. 도메인 표준(`knowledgebase/domains/oms/` 개념·`.claude/rules/oms-*`)은 공유하므로 복제하지 않는다. (기동가이드·구현 패턴은 ③ 프로젝트 층이므로 프로젝트마다 자체 보유한다.)
