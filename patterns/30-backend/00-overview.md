---
title: 30-backend 백엔드 패턴
description: 백엔드 아키텍처·API/메뉴코드 규칙·코딩 컨벤션·레이어별(Controller·Comp·TxComp·Dao·Mapper) 작성 가이드·테스트 컨벤션 문서를 찾을 때 읽는 30-backend 진입점. 문서 3계층(Rule/Convention/Guide) 정의와 중복 금지(SoT) 원칙을 담는다.
status: active
version: 1.1.0
author: ShinHyunKyu
repo_role: ai-hub
agent_usage: reference
---

# 30-backend

백엔드 패턴 문서의 진입점이다. 문서는 **강제성(누가, 얼마나 강제하나)** 기준으로 3계층으로 나눈다.

## 문서 3계층 — Rule / Convention / Guide

| 계층 | 폴더 | 강제성 | 의미 | 어기면 |
|---|---|---|---|---|
| **Rule (규칙)** | `20-rule/` | 강제 | 언어·프레임워크 또는 **프로젝트 계약**이 강제. 입력→출력이 결정적으로 도출됨 | 작동/계약이 깨진다 ("틀리다") |
| **Convention (관례)** | `30-convention/` | 합의 | 어겨도 돌아가지만 팀이 하나로 통일한 약속 (레이어 책임·어노테이션·네이밍 스타일) | 코드리뷰 지적·협업 마찰 ("어색하다") |
| **Guide (지침)** | `40-guide/` | 권장 | 위 규칙·관례를 실제 코드로 적용하는 단계별 매뉴얼·예시 | 크게 문제없음 ("이렇게 하면 좋다") |

> ⚠️ **이 레포의 `20-rule/` 보충**: 일반적으로 Rule은 "언어/프레임워크가 강제하는 것"(세미콜론 누락·`${}` 오용 등)을 뜻한다. 본 레포의 `20-rule/`(API 네이밍·메뉴코드)은 언어강제는 아니지만 **프로젝트 계약상 강제로 취급**한다 — 어기면 BE↔FE API 계약·메뉴체계가 깨지기 때문이다. 그래서 "어색하다"가 아니라 "틀리다"로 본다.

## 중복 금지 — 같은 주제는 한 곳(SoT)에만

같은 내용을 여러 계층에 적지 않는다. 한 주제의 정의는 **단일 정의처(SoT)** 한 곳에 두고, 다른 문서는 **포인터(링크)** 로만 참조한다. 계층 경계가 모호해 중복이 새면 드리프트가 발생한다(예: API URL 패턴이 rule·convention 양쪽에 박혀 표기가 어긋난 사례).

| 주제 | 단일 정의처(SoT) |
|---|---|
| API URL·HTTP메서드·인터페이스 ID | `20-rule/01-api-naming-rule.md` |
| 메뉴코드 채번·패키지·베이스경로 | `20-rule/02-menu-code-rule.md` |
| 레이어 책임·어노테이션·예외·DTO·네이밍 | `30-convention/01-coding-convention.md` |
| 레이어별 작성법(Controller·Dao·Mapper·Comp…) | `40-guide/*` |

## 하위 구조

- `10-architecture/` — 레이어 아키텍처·BE↔FE 위치
- `20-rule/` — API 네이밍·메뉴코드 규칙
- `30-convention/` — 코딩 컨벤션·헤더+상세 구조 컨벤션
- `40-guide/` — 레이어별 작성 매뉴얼(Controller·Dao·Mapper·Comp·CompUtil·TxComp)
- `50-test/` — 테스트 컨벤션

## 상세 문서 목록

- [백엔드 패키지 구조](./10-architecture/02-package-structure.md) — Java 소스 패키지 구조(be/bm/fw/sif/test/vm)·파일 명명 규칙
- [헤더+상세 구조 메뉴 컨벤션](./30-convention/02-header-detail-convention.md) — 헤더+상세 2단 구조·문서번호 채번·상태 관리 메뉴 코딩 컨벤션
- [백엔드 테스트 코딩 컨벤션](./50-test/02-test-coding-convention.md) — JUnit 테스트 클래스 구조·어노테이션·assert 패턴·엣지케이스 매트릭스
