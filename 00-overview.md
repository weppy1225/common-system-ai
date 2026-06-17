---
title: cloud-wms-doc 전체 진입점 인덱스
description: WMS AI 프레임워크 레포지토리의 전체 구조와 각 섹션 역할을 설명하는 진입점 문서
status: active
version: 1.0.0
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

| 폴더 | 역할 |
|---|---|
| `.claude/` | Claude Code 스킬·규칙. 수정 시 담당자 확인 필수 |
| `patterns/` | WEB/PDA 화면·DB·BE·FE 소스코드 패턴 표준화 |
| `deliverables/` | 산출물 템플릿(10)·원천자료(20)·생성결과물(30) |
| `30-domain/` | 메뉴별 지식베이스 + 프로토타입 단일 보관소 |
| `50-prototype/` | 화면 프로토타입 공용 셸 (index.html + 공통 UI) |
| `60-system/` | 시스템 운영·인프라 가이드 (빌드·배포·설치) |
| `90-archive/` | 아카이브 문서 보관 |

## 주요 Slash Commands (Claude Code)

| 명령어 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | 화면요건 문서 대화형 작성 → `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-ui.md` |
| `/SD_311 {메뉴코드}` | 프로토타입 생성 → `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-wireframe.html` |
| `/SD_312 {메뉴코드}` | PDA 모바일 프로토타입 생성 |
| `/deploy {메뉴코드}` | FTP 배포 |

## 에이전트 동작 규칙
- 코드/제안 전 반드시 실제 파일 확인 후 근거 기반으로 작성
- 변수명·필드명·경로는 추정 금지. 파일에서 확인 후 사용
- 커밋 메시지는 한글로 작성
