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

| 영역 | 패턴 문서 (SSoT) | 얇은 rule (트리거) |
|---|---|---|
| 공통 UI | `10-web/01-common-ui.md` | `.claude/rules/common_ui.md` |
| 검색 필터 | `10-web/02-search-area.md` | `.claude/rules/area_search.md` |
| 기능 버튼(Toolbar) | `10-web/03-toolbar-buttons.md` | `.claude/rules/area_btn.md` |
| 결과 그리드 | `10-web/04-result-grid.md` | `.claude/rules/area_result_grid.md` |
| 다중 입력 그리드 | `10-web/05-multi-input-grid.md` | `.claude/rules/area_multi_input_grid.md` |
| 등록/수정 팝업 | `10-web/06-popup-register.md` | `.claude/rules/popup_reg.md` |
| 업무규칙 팝업 | `10-web/07-popup-biz-rule.md` | `.claude/rules/popup_biz.md` |

## 상세 패턴 문서

- WEB 화면 패턴 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
- PDA 화면 패턴 인덱스: → `patterns/10-screen-design/20-pda/00-overview.md`
