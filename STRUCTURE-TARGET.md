---
title: cloud-wms-ai 목표 폴더 구조 (재설계 확정안)
description: AI 허브 레포 최상위 폴더 재설계 확정안. 폴더별 역할·경계 규칙, 메뉴별 산출 위치, 현행→목표 이전 매핑을 고정한다. W2.3 이후 폴더 변경·스킬 경로 개정의 기준 문서.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
applies_to:
  - "**"
last_verified: 2026-06-17
---

# cloud-wms-ai 목표 폴더 구조 (재설계 확정안)

WMS AI 프레임워크 허브 레포의 **목표(TO-BE) 최상위 구조**를 고정한다.
현행 `STRUCTURE.md`는 **현재(AS-IS)** 구조를 기술하며, 이 문서는 **목표 구조 + 이전 매핑**을 기술한다.
이전 작업(churn) 완료 후 이 문서가 `STRUCTURE.md`를 대체한다.

> 확정 시점: 2026-06 (WBS W2.3 업무지식 구축). 이후 W3.1(개발 자동화 27개)·W3.2(산출물 자동화 15개) 스킬이 이 경로 위에서 동작하므로 먼저 고정한다.

---

## 0. 설계 원칙 (BLOCKING)

1. **최상위는 "역할 이름", 번호 없음.** 번호는 순서가 있는 곳(`knowledgebase/`, `spec/{메뉴}/`) 안에서만 쓴다.
2. **직관은 번호가 아니라 단어에서 나온다.** 폴더 이름은 *주제*가 아니라 *역할*을 가리킨다. (예: `domain` ○, `wms-business` ✗)
3. **소스 코드가 AS-IS 정본.** 코드를 요약·복제한 문서를 따로 저장하지 않는다. 위치는 `30-src-index`로 찾는다.
4. **들어오는 지식**(`knowledgebase`·`spec`·`patterns`)은 읽고, **나가는 것**(`prototype`·`deliverables`)은 낸다.
5. **구분은 폴더가 아니라 파일명/상태로** 표현할 수 있으면 그렇게 한다.

---

## A. 목표 최상위 구조

```
cloud-wms-ai/
│
├── knowledgebase/   읽고 시작 — 프로젝트 전체 배경지식 (메뉴 횡단·공통)
├── spec/            무엇을 만드나 — 메뉴별 설계 + 업무지식 (마크다운 전부)
├── prototype/       화면 미리보기 — 고객·PM이 클릭 검증하는 HTML
├── patterns/        어떻게 짜나 — 코드 작성 표준 패턴 (HOW)
├── deliverables/    고객에게 낼 것 — 최종 산출물
│
└── .claude/
    ├── skills/      슬래시 명령어 (개발 자동화 W3.1 + 산출물 자동화 W3.2)
    └── rules/       항상 적용되는 규칙
```

| 폴더 | 정의 | 읽는 사람 | 매체 |
|---|---|---|---|
| `knowledgebase/` | 이 프로젝트는 어떻게 돌아가나 (공통 배경) | AI·개발자 | 마크다운 |
| `spec/` | 이 메뉴를 왜·무엇·어떻게 설계했나 | AI·개발자 | 마크다운 |
| `prototype/` | 화면이 이렇게 생겼다 (검증용) | PL·PM·고객 | 실행 HTML/JS |
| `patterns/` | 코드는 이 패턴으로 짜라 | AI·개발자 | 마크다운 |
| `deliverables/` | 고객 제출 문서 | 고객 | 문서·엑셀·PPT |

---

## B. knowledgebase/ — 메뉴 횡단 공통지식 (번호 = 읽는 순서)

```
knowledgebase/
├── 00-overview.md       개요          ← 여기부터
├── 10-domain/           공통 업무지식   ← 이 시스템이 다루는 업무 (배경·WHY, 메뉴 횡단만)
├── 20-md-index.md       MD 문서 색인    ┐ 필요할 때 찾는 지도
├── 30-src-index/        소스코드 색인    ┘ (요약 아님 — 위치 색인)
├── 40-install-guide/    설치·셋업
└── 50-dev-workflow/     개발 워크플로우
```

- 읽는 흐름: **개요(무엇) → 업무지식(왜) → 색인(어디) → 설치·워크플로우(어떻게 일하나)**.
- `10-domain/`은 **메뉴 횡단 공통** 업무규칙·용어·엔티티 관계만 둔다. 메뉴 고유 업무지식은 `spec/{메뉴}/{메뉴}-00-domain.md`에 둔다.
- 옛 `40-issue`는 폐지하고 메뉴별 `99-issues`로 spec에 흡수했다.

---

## C. spec/{메뉴}/ — 한 메뉴의 모든 설계 (파일 순서 = 읽는 순서)

```
spec/mdpr01/                       (예: 사은품관리)
├── mdpr01-00-domain.md         ★ 업무지식/노하우 (WHY) — 사람만 작성, 스킬 금지
├── mdpr01-01-basic-design.md      기본설계 — 메뉴 목적·범위·주요 기능
├── mdpr01-02-ui.md                화면요건 — 레이아웃·컴포넌트·버튼     〔/SD_310_UI〕
├── mdpr01-03-data-model.md        데이터모델 — 테이블·컬럼·관계          〔/SD-db〕
├── mdpr01-04-be-mapper-sql.md     BE 쿼리 — Mapper SQL 설계
├── mdpr01-05-api.md               API 명세 — 엔드포인트·요청/응답        〔/SD-api〕
├── mdpr01-06-be-flow.md           BE 흐름 — Controller→Comp→Dao 시퀀스
├── mdpr01-07-fe-flow.md           FE 흐름 — Vue 동작·API 호출 시퀀스
└── mdpr01-99-issues.md            설계 미결·애매·하드코딩 등 남은 이슈
```

- 읽는 순서: **00 왜 → 01 무엇 → 02~05 설계 → 06~07 흐름 → 99 미결**.
- `{메뉴}-00-domain.md`는 **사람 전용**. 자동화 스킬은 01~07만 생성/갱신하고 00은 절대 건드리지 않는다.
- 파일명에 메뉴코드 접두사를 유지한다(자기 식별성: 탭·검색·diff·첨부에서 메뉴를 즉시 식별).

---

## D. prototype/ — 검증용 실행물 (PC=`{메뉴}`, 모바일=`{메뉴}m`)

```
prototype/
├── _common/             PC 공통 셸 (index, 메뉴, 팝업, wms-ui.css, wms-common.js)
├── _common-m/           모바일 공통 셸 (menu, main, mobile.css …)
├── mdpr01/              사은품관리 PC      — mdpr01-wireframe.html + mock-data.js
└── mdpr01m/             사은품관리 모바일   — mdpr01m-wireframe.html + mock-data.js
```

- PC·모바일은 `m` 접미사로 구분한다. 시스템 전체 컨벤션과 동일하며 `prototype/mdpr01m` ↔ FE `views/bm/iw1000m/iwrq01m` ↔ `30-src-index`가 1:1로 매핑된다.
- 실행 HTML/JS(검증물)는 전부 prototype에, 마크다운 설계는 전부 spec에 둔다(매체 기준 분리).

---

## E. 메뉴 하나는 어디에?

| 알고 싶은 것 | 가는 곳 |
|---|---|
| 이 메뉴, 왜·무엇·어떻게 설계? | `spec/{메뉴}/` |
| 화면 어떻게 생겼나? (PC/모바일) | `prototype/{메뉴}/` · `prototype/{메뉴}m/` |
| 프로젝트 공통 배경·업무규칙은? | `knowledgebase/` |
| 코드 짜는 패턴은? | `patterns/` |
| 실제 코드는? | BE/FE 레포 (위치는 `knowledgebase/30-src-index`) |

---

## F. 현행 → 목표 이전 매핑

| 현행 (AS-IS) | 목표 (TO-BE) | 비고 |
|---|---|---|
| `30-domain/30-wms-business/{메뉴}/{메뉴}-01~07.md` | `spec/{메뉴}/{메뉴}-01~07.md` | 설계 마크다운 |
| `30-domain/.../{메뉴}-99-issues.md` | `spec/{메뉴}/{메뉴}-99-issues.md` | 설계 미결 |
| (없음, 신규 작성) | `spec/{메뉴}/{메뉴}-00-domain.md` | 업무지식 WHY, 사람 전용 |
| `30-domain/.../{메뉴}-02-wireframe.html` `*-mock-data.js` | `prototype/{메뉴}/` | PC 검증물 |
| `50-prototype/20-mobile/{그룹}m/{메뉴}.html` | `prototype/{메뉴}m/` | 모바일 검증물 |
| `50-prototype/10-common/` | `prototype/_common/` | PC 공통 셸 |
| `50-prototype/20-mobile/` (공통) | `prototype/_common-m/` | 모바일 공통 셸 |
| `10-src-pattern/` | `patterns/` | 코드 패턴 HOW |
| `70-knowledgebase/_common/` (기술 아키텍처) | `patterns/` | be/fe-architecture·tech-stack·exceptions |
| `70-knowledgebase/{메뉴}/` (역공학 요약) | **폐기** | AS-IS 정본은 소스. 위치는 30-src-index |
| `60-system/` | `knowledgebase/40-install-guide/` | 설치·운영 |
| `ai-dev-procedure.md` | `knowledgebase/50-dev-workflow/` | 워크플로우 |
| `20-deliverables/` | `deliverables/` | 고객 산출물 |
| `00-overview.md` (루트) | `knowledgebase/00-overview.md` | 도서관 안으로 |

---

## G. 남은 작업 (churn)

1. 위 매핑대로 폴더/파일 이동.
2. `CLAUDE.md`·`STRUCTURE.md`·`.claude/rules/repo-paths.md` 경로 갱신.
3. 27개 개발 스킬 + 15개 산출물 스킬의 입력/출력 경로 참조 수정.
4. 자동화 스킬에 "`{메뉴}-00-domain.md`는 생성/수정 금지" 규칙 추가.
5. 완료 후 이 문서로 `STRUCTURE.md` 대체.
