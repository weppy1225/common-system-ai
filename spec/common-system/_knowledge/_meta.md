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
| ② 도메인 표준 (WMS 프로젝트 공유) | `knowledgebase/domains/wms/` | 인터페이스 코딩 컨벤션 골격·표준 업무 흐름·표준 약어 |
| ③ 프로젝트 확정 (이 프로젝트 전용) | `spec/common-system/_knowledge/` | 실 테이블 스키마·메뉴·컬럼사전·실 API 목록/필드명세 |

> 충돌 시 우선순위: **③ 프로젝트 확정 > ② 도메인 표준.** 도메인 표준은 "기본값", 프로젝트 확정은 "실제값"이다.

## `_knowledge/` 구성

| 경로 | 내용 | 이전 위치 |
|---|---|---|
| `db-schema/` | 실 테이블 카탈로그(`mdm_`·`sm_`·업무 테이블) + 공통코드 | `patterns/20-database/40-schema/` |
| `glossary/dictionary.yaml` | 컬럼 용어 사전 (컬럼명 → 한글 의미) | `patterns/20-database/50-glossary/01-dictionary.yaml` |
| `interface/api-list.md` | ERP 연동 API 목록 | `patterns/50-interface/10-api/01-erp-interface-api.md` |
| `interface/detail/` | API별 Request/Response 필드 명세 | `patterns/50-interface/10-api/20-detail/` |
| `menu-list.md` | 메뉴코드 레지스트리 | `knowledgebase/15-menu-list.md` |

## 새 프로젝트 추가 시

같은 WMS 도메인의 새 프로젝트(예: `bnk-wms`)는 `spec/{프로젝트}/_knowledge/` 에 자신의 실데이터만 생성하고, 이 `_meta.md` 를 복사해 `project`·`domain` 값만 바꾼다. 도메인 표준(`knowledgebase/domains/wms/`)은 공유하므로 복제하지 않는다.
