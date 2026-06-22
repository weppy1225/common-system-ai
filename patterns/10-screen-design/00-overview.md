---
title: 화면 설계 패턴 인덱스
description: WMS WEB/PDA 화면 설계 및 프로토타입 작성 패턴 문서 인덱스. SD_310_UI·SD_311·SD_312 스킬 실행 시 참조.
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

WMS WEB / PDA 화면 설계·프로토타입 작성 패턴을 관리한다.

## 디렉토리 구성

| 디렉토리 | 설명 |
|---|---|
| `10-web/` | PC 웹 화면 설계 패턴 |
| `20-pda/` | PDA 모바일 화면 설계 패턴 |

## 항상 적용되는 규칙 (Always-Loaded Rules)

아래 파일들은 Claude Code에 **항상 자동 로드**되는 UI 규칙 파일이다.
스킬 실행 시 별도 로드 없이 즉시 적용된다.

| 파일 | 적용 영역 |
|---|---|
| `.claude/rules/common_ui.md` | 공통 UI (헤더·모달·그리드 공통) |
| `.claude/rules/area_search.md` | 검색 필터 영역 |
| `.claude/rules/area_btn.md` | 기능 버튼(Toolbar) 영역 |
| `.claude/rules/area_result_grid.md` | 결과 그리드 영역 |
| `.claude/rules/area_multi_input_grid.md` | 다중 입력 그리드 영역 |
| `.claude/rules/popup_reg.md` | 등록/수정 팝업 |
| `.claude/rules/popup_biz.md` | 업무규칙 팝업 |

## 상세 패턴 문서

- WEB 화면 패턴 인덱스: → `patterns/10-screen-design/10-web/00-overview.md`
- PDA 화면 패턴 인덱스: → `patterns/10-screen-design/20-pda/00-overview.md`
