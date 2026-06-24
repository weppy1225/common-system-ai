---
title: knowledgebase 라이브러리 개요
description: AI가 개발 전에 읽는 메뉴 횡단 공통 배경지식 라이브러리. 번호=읽는 순서. 메뉴별 설계는 spec/, 검증 화면은 prototype/ 에 있다.
status: active
version: 2.1.0
repo_role: ai-hub
agent_usage: reference
domain: common
last_modified_by: ShinHyunKyu
last_verified: 2026-06-24
---

# knowledgebase — AI 배경지식 라이브러리

이 시스템이 **어떻게 돌아가는지** 알려주는 메뉴 횡단 공통 지식이다. 번호는 읽는 순서다.
메뉴별 설계는 `spec/{프로젝트}/{메뉴}/`, 검증용 화면(HTML)은 `prototype/`에 있다 — 여기엔 없다.

## 읽는 순서 (번호 = 읽는 순서)

1. `10-domain/` — 메뉴 횡단 공통 업무규칙·용어·엔티티 관계 (WHY, 사람이 작성)
2. `domains/` — 도메인 표준 (같은 도메인 프로젝트끼리 공유, 예: `domains/wms/`)
3. `20-md-index.md` / `30-src-index/` — 문서·소스 위치 색인
4. `40-install-guide/` → `50-dev-workflow/` — 설치·셋업 후 개발 워크플로우

> 디렉토리 트리(정본)는 → [`STRUCTURE.md` §knowledgebase/](../STRUCTURE.md). 여기엔 중복하지 않는다.

## 경계 규칙

- **knowledgebase = 메뉴 횡단 공통 배경**만. 특정 메뉴 고유 지식은 `spec/{프로젝트}/{메뉴}/{메뉴}-00-domain.md`에 둔다.
- **메뉴 레지스트리·실 스키마·공통코드 등 프로젝트 확정 데이터**는 여기 두지 않는다 → `spec/{프로젝트}/_knowledge/`. **도메인 표준**(인터페이스 컨벤션 골격·표준 업무 흐름 등)은 `domains/{도메인}/`.
- `10-domain`은 *소스를 읽어도 알 수 없는* 공통 업무규칙(WHY)만. 사람이 작성하며 자동화 대상이 아니다.
- `20-md-index`·`30-src-index`는 **위치 색인**이지 내용 사본이 아니다. 정본은 실제 파일 자체(문서는 해당 MD, 코드의 AS-IS 정본은 BE/FE 소스).
- 전체 레포 구조: → 루트 `STRUCTURE.md`
