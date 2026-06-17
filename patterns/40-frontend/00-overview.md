---
title: WMS FE AI 문서 진입점
description: FE 개발 AI가 가장 먼저 읽어야 하는 문서. 프로젝트 개요, 작업 순서, 핵심 원칙, 업무군 코드 맵을 포함한다.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: frontend
tags:
  - overview
  - vue3
  - vite
  - pinia
---

# WMS-BNK-FE AI 문서 진입점

> **이 프로젝트에서 작업하는 모든 AI가 가장 먼저 읽어야 하는 문서입니다.**

## 1. 프로젝트 개요

- **이름**: cloud-wms-fe (창고관리시스템 프론트엔드)
- **스택**: Vue 3 + Vite + Pinia + Vue Router + AUI Grid + axios + vue-i18n
- **대응 백엔드**: `cloud-wms-be` (Spring + MyBatis)
- **이중 UI**: PC(`src/views/be`) / 모바일(`src/views/bm`)
- **메뉴 코드 체계**: 메뉴코드는 **영문소문자 4자 + 숫자 2자** 고정 — 상세는 `patterns/40-frontend/20-convention/01-naming.md`. 예: `md8000 > mdct01` (거래처), `iv3000 > ivst01` (재고현황)

## 2. AI 작업 전 필수 확인 순서

새 요청을 받으면 **아래 순서대로** 문서를 참고하세요.

1. **`00-overview.md`** (현재 문서) — 전체 방향
2. **`patterns/40-frontend/20-convention/01-naming.md`** — 네이밍 규칙 (vfn_, gfn_, sfn_, Z*)
3. **`patterns/40-frontend/20-convention/03-backend-spec-consumption.md`** — BE spec 직접 소비 규칙
4. **`patterns/40-frontend/20-convention/02-file-template.md`** — 신규 .vue 파일 스켈레톤
5. **`patterns/40-frontend/50-pattern/`** — 작업 유형별 레시피 (CRUD, 팝업, 엑셀 등)
6. **`patterns/40-frontend/30-component/` / `patterns/40-frontend/40-store/`** — 컴포넌트·스토어 API 카탈로그

## 3. 핵심 원칙

- 기존 패턴 모방 > 신규 생성 (`components/be`, `components/comm`, `assets/js/common.js` 먼저 검색)
- 수정 범위 최소화 (요청 밖 리팩토링 금지)
- 한글 주석 유지
- `commCdStore` / `bizCenterStore` 거쳐서 공통코드·사업장 사용 (axios 직접 호출 금지)

## 4. 주요 명령어

```bash
npm run dev:dev     # 개발 서버 (dev 모드)
npm run build:test  # 테스트 빌드
npm run lint        # ESLint 자동수정
npm run test:unit   # 단위테스트 (vitest)
```

## 5. 업무군 코드 맵

| 코드 | 업무 |
| --- | --- |
| md8000 | 기준정보 (거래처/상품/위치/사업장…) |
| iv3000 | 재고 (입고/이동/조정) |
| iv3100 | 재고 수불·이동 조회 |
| iv3200 | 재고실사 |
| iw1000 | 입고 |
| ow5000 | 출고 |
| rt2000 | 반품 |
| if9100 | 인터페이스 |
| cm9400 | 공통관리 |
| mm9200 | 출력물·라벨 관리 |
| sm9000 | 시스템관리 |
| ss9300 | 보안/세션 |

## 6. 문서 구조

```
patterns/40-frontend/
├─ 00-overview.md                 ← 지금 이 문서
├─ 10-architecture/               기술/폴더/연동 구조
├─ 20-convention/                 네이밍·파일템플릿·BE 스펙 소비
├─ 30-component/                  Z* 컴포넌트 카탈로그
├─ 40-store/                      Pinia 스토어 가이드
└─ 50-pattern/                    작업 유형별 레시피
```
