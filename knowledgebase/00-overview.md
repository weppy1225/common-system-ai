---
title: knowledgebase 라이브러리 개요
description: AI가 개발 전에 읽는 메뉴 횡단 공통 배경지식 라이브러리. 번호=읽는 순서. 메뉴별 설계는 spec/, 검증 화면은 prototype/ 에 있다.
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
last_verified: 2026-06-17
---

# knowledgebase — AI 배경지식 라이브러리

이 시스템이 **어떻게 돌아가는지** 알려주는 메뉴 횡단 공통 지식이다. 번호는 읽는 순서다.
메뉴별 설계는 `spec/{메뉴}/`, 검증용 화면(HTML)은 `prototype/`에 있다 — 여기엔 없다.

## 구조 (번호 = 읽는 순서)

```
knowledgebase/
├── 00-overview.md       (이 파일) 개요 — 여기부터
├── 10-domain/           메뉴 횡단 공통 업무규칙·용어·엔티티 관계 (WHY, 사람이 작성)
├── 20-md-index.md       MD 문서 색인 — 문서가 어디 있나
├── 30-src-index/        소스코드 색인 — 코드가 어디 있나 (실제 코드는 BE/FE 레포)
├── 40-install-guide/    설치·셋업
├── 50-dev-workflow/     개발 워크플로우
└── menu-list.md         메뉴 레지스트리
```

## 경계 규칙

- **knowledgebase = 메뉴 횡단 공통 배경**만. 특정 메뉴 고유 지식은 `spec/{메뉴}/{메뉴}-00-domain.md`에 둔다.
- `10-domain`은 *소스를 읽어도 알 수 없는* 공통 업무규칙(WHY)만. 사람이 작성하며 자동화 대상이 아니다.
- `20-src-index`/`30-src-index`는 **위치 색인**이지 코드 요약본이 아니다. AS-IS 정본은 소스 코드 자체.
- 전체 레포 구조: → 루트 `STRUCTURE.md`
