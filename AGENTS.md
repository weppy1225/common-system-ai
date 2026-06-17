---
title: cloud-wms-doc Codex 에이전트 지침
description: Codex가 이 저장소에서 작업할 때 먼저 확인할 최소 지침과 정본 문서 포인터를 제공한다.
status: active
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
---

# cloud-wms-doc AGENTS

이 저장소는 WMS 화면설계, 메뉴별 지식베이스, 개발 자동화 규칙과 스킬을 함께 관리하는 AI 작업 허브다.
Codex는 이 문서를 진입점으로 사용하고, 세부 구조와 규칙은 정본 문서를 따라야 한다.

## Codex 행동 규칙

- 실제 파일을 읽거나 검색해 확인한 근거만으로 작성·수정한다. 확인 전 추정하지 않는다.
- 변수명, 필드명, 컬럼명, API 경로, 파일 경로를 이름만 보고 추정하지 않는다.
- Git 커밋이 필요한 경우 커밋 메시지는 한글로 작성하고, `Co-Authored-By` 등 AI 작성 표시는 넣지 않는다.

## 정본 문서

- 저장소 전체 구조와 영역별 역할은 `STRUCTURE.md`를 따른다.
- 워크스페이스 및 레포 경로 규약은 `.claude/rules/repo-paths.md`를 따른다.
- 메뉴별 KB 정본 경로는 `spec/{메뉴코드}/...` 이다.
- 상시 적용 규칙은 `.claude/rules/` 아래 문서를 따른다.

## 스킬과 명령

- 슬래시 커맨드 스킬 정의는 `.claude/skills/`에 있다.
- 전체 명령 목록과 설명은 `CLAUDE.md`의 `Slash Commands` 표를 참조한다.
