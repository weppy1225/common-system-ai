---
title: 화면 설계 패턴 인덱스
description: WEB/PDA 화면 설계 및 프로토타입 작성 패턴 문서 인덱스. SD_310_UI·SD_311·SD_312 스킬 실행 시 참조.
status: active
version: 1.1.0
repo_role: ai-hub
agent_usage: reference
domain: frontend
tags:
  - screen-design
  - ui-pattern
  - prototype
---

# 화면 설계 패턴 인덱스

WEB / PDA 화면 설계·프로토타입 작성 패턴을 관리한다.

## 디렉토리 구성

| 디렉토리 | 설명 |
|---|---|
| `10-web/` | PC 웹 화면 설계 패턴 |
| `20-pda/` | PDA 모바일 화면 설계 패턴 |

## 참조 방향 (rule → pattern)

화면설계 HTML 작업의 **상세 구현 SSoT는 patterns leaf 문서**(`10-web/01~07`)다.
`.claude/rules/*`는 HTML 파일(`paths: **/*.html`) 작업 시 자동 로드되는 **얇은 트리거**로, 금지/필수 판단 기준만 두고 패턴 문서로 라우팅한다.

> 영역별 패턴 문서 ↔ rule 라우팅 표(7개 영역 + 핵심 규칙 요약)는 → [`10-web/00-overview.md §영역별 패턴 문서`](./10-web/00-overview.md). 여기엔 중복하지 않는다.

## 상세 패턴 문서

- WEB 화면 패턴 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
- PDA 화면 패턴 인덱스: → `patterns/10-screen-design/20-pda/00-overview.md`
