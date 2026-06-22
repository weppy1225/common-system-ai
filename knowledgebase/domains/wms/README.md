---
title: WMS 도메인 표준
description: WMS 프로젝트들이 공유하는 표준 지식(인터페이스 컨벤션·업무 흐름·약어)의 진입점
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: wms
tags:
  - domain-standard
  - wms
---

# WMS 도메인 표준 (Domain Baseline)

WMS **도메인에 속한 모든 프로젝트가 공유**하는 표준 개념·규약을 둔다. 특정 고객/프로젝트의 실데이터(실 테이블·메뉴·코드)는 여기 두지 않는다 — 그건 `spec/{프로젝트}/_knowledge/` 의 ③ 계층이다.

## 무엇을 넣나 (프로젝트가 달라도 같은 것)

| 폴더/파일 | 내용 |
|---|---|
| `interface-convention/` | SIF 외부연동 코딩 컨벤션 골격 (E2W 수신·W2E 송신 패키지 구조·클래스 명명·예외 처리) |
| `biz-flow/outbound-workflow.md` | 표준 출고 업무 흐름 (즉시출하·출고출하·상차·송장 프로세스 개념) |
| `glossary-std.md` | 표준 약어 (IW, RQ, PC, SC 등) |

## 무엇을 넣지 않나 (프로젝트마다 다른 것)

- 실 테이블 스키마·컬럼 사전 → `spec/{프로젝트}/_knowledge/db-schema/`·`glossary/`
- 실제 API 목록·필드 명세 → `spec/{프로젝트}/_knowledge/interface/`
- 메뉴 레지스트리·공통코드 → `spec/{프로젝트}/_knowledge/`

## 계층 관계

```
① 코어        patterns/ · .claude/           전 프로젝트·전 도메인 공통
② 도메인 표준  knowledgebase/domains/{도메인}/ 같은 도메인 프로젝트끼리 공유  ← 여기
③ 프로젝트     spec/{프로젝트}/_knowledge/     프로젝트 전용 실데이터
```

충돌 시 우선순위: **③ > ②**. 도메인 표준은 기본값, 프로젝트 확정값이 이긴다.
