---
title: common-system 프로젝트 지식 메타
description: 이 프로젝트가 속한 도메인과 전역 지식(_knowledge)의 구성을 선언한다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
project: common-system
domain: wms
tags:
  - project-meta
  - knowledge-index
---

# common-system 프로젝트 지식 메타

## 도메인 선언

- **project**: `common-system`
- **domain**: `wms`

이 프로젝트는 **WMS 도메인**에 속한다. 따라서 AI 에이전트·스킬·규칙은 다음 두 층에서 지식을 읽는다.

| 층 | 위치 | 내용 |
|---|---|---|
| ② 도메인 표준 (WMS 프로젝트 공유) | `.claude/rules/wms-*` | WMS 도메인 룰만 — 실제 WMS 표준·실데이터는 ③에 통합 |
| ③ 프로젝트 확정 (이 프로젝트 전용) | `spec/common-system/_knowledge/` | 실 테이블 스키마·메뉴·컬럼사전·실 API 목록/필드명세, SIF 코딩 컨벤션, 표준 약어, 빌드·배포 가이드, 업무 흐름 |

> 충돌 시 우선순위: **③ 프로젝트 확정 > ② 도메인 표준.** 도메인 표준은 "기본값", 프로젝트 확정은 "실제값"이다.
> **WMS 기준 프로젝트 = common-system 으로 확정**(2026-06-26): SIF 코딩 컨벤션 등 WMS 코딩 규약은 ② 가 아니라 이 프로젝트(③)에 두고, WMS 도메인 룰(`wms-sif-convention.md`)이 여기를 SSoT로 참조한다.

## `_knowledge/` 구성

| 경로 | 내용 | 이전 위치 |
|---|---|---|
| `db-schema/` | 실 테이블 카탈로그(`mdm_`·`sm_`·업무 테이블) + 공통코드 | `patterns/20-database/40-schema/` |
| `glossary/dictionary.yaml` | 컬럼 용어 사전 (컬럼명 → 한글 의미) | `patterns/20-database/50-glossary/01-dictionary.yaml` |
| `glossary/abbreviations.md` | 표준 업무 약어 (IW·RQ·PC·SC 등) | (구 WMS 도메인 표준에서 통합) |
| `interface/api-list.md` | ERP 연동 API 목록 | `patterns/50-interface/10-api/01-erp-interface-api.md` |
| `interface/detail/` | API별 Request/Response 필드 명세 | `patterns/50-interface/10-api/20-detail/` |
| `interface/convention/` | SIF 외부연동 코딩 컨벤션(E2W/W2E 패키지·클래스 명명·예외) | (구 WMS 인터페이스 컨벤션에서 통합) |
| `menu-list.md` | 메뉴코드 레지스트리 | (구 메뉴 레지스트리에서 통합) |
| `install-guide/` | BE 빌드·배포 가이드(Gradle/Spring Boot) + 배포 식별자 리네임 맵 | (구 install-guide에서 통합) |
| `domain/` | 실 테이블 기반 업무 흐름(출고 워크플로우 등) | (구 WMS 업무흐름에서 통합) |

## 새 프로젝트 추가 시

같은 WMS 도메인의 새 프로젝트(예: `bnk-wms`)는 `spec/{프로젝트}/_knowledge/` 에 자신의 실데이터만 생성하고, 이 `_meta.md` 를 복사해 `project`·`domain` 값만 바꾼다. 도메인 표준(`.claude/rules/wms-*`)은 공유하므로 복제하지 않는다.
