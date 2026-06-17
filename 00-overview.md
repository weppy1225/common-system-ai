---
title: cloud-wms-doc 전체 진입점 인덱스
description: WMS AI 프레임워크 레포지토리의 전체 구조와 각 섹션 역할을 설명하는 진입점 문서
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
tags:
  - index
  - overview
---

# cloud-wms-doc

WMS 프로젝트의 화면설계·지식베이스·소스코드 패턴·산출물을 통합 관리하는 AI 프레임워크 레포지토리.

## 섹션 구조

| 폴더 | 역할 | 누가 읽나 |
|---|---|---|
| `.claude/` | Claude Code 스킬·규칙 (수정 시 담당자 확인) | AI |
| `knowledgebase/` | 메뉴 횡단 공통 배경지식 (개요·업무지식·색인·설치·워크플로우) | AI·개발자 |
| `spec/{메뉴}/` | 메뉴별 설계 정본 (00-domain ~ 07 + 99) | AI·개발자 |
| `prototype/` | 검증용 화면 (공용 셸 + 메뉴별 wireframe HTML) | PL·PM·고객 |
| `patterns/` | WEB/PDA·DB·BE·FE 소스코드 패턴 표준 | AI·개발자 |
| `deliverables/` | 산출물 템플릿(10)·원천(20)·생성결과(30) | 고객 |

> 전체 구조·폴더 역할·경계 규칙: → `STRUCTURE.md`

## 주요 Slash Commands (Claude Code)

| 명령어 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | 화면요건 문서 대화형 작성 → `spec/{메뉴코드}/{메뉴코드}-02-ui.md` |
| `/SD_311 {메뉴코드}` | PC 프로토타입 생성 → `prototype/{메뉴코드}/{메뉴코드}-wireframe.html` |
| `/SD_312 {메뉴코드}` | PDA 모바일 프로토타입 생성 → `prototype/{메뉴코드}m/` |
| `/deploy {메뉴코드}` | FTP 배포 |

## 에이전트 동작 규칙
- 코드/제안 전 반드시 실제 파일 확인 후 근거 기반으로 작성
- 변수명·필드명·경로는 추정 금지. 파일에서 확인 후 사용
- 커밋 메시지는 한글로 작성
- **`spec/{메뉴}/{메뉴}-00-domain.md`(업무지식)는 사람 전용 — 자동화 스킬이 생성·수정하지 않는다**
