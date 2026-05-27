# KB 구조 설계서

| 항목 | 내용 |
|---|---|
| 문서번호 | WBS-1.4 |
| 작성일 | 2026-05-18 |
| 작성자 | 신현규 |
| 버전 | v1.0 |
| 대상 저장소 | cloud-wms-doc / cloud-wms-fe / cloud-wms-be |

---

## 1. 개요

### 1-1. 목적

이 문서는 cloud-wms 프로젝트 3개 저장소(`cloud-wms-doc`, `cloud-wms-fe`, `cloud-wms-be`)에서 Claude Code가 참조하는 **Knowledge Base(KB)** 의 전체 구조, 카테고리 분류, 파일 역할, 그리고 Sonnet/Opus 모델 라우팅 기준을 정의한다.

### 1-2. KB 정의

> **KB(Knowledge Base)** 란 Claude Code가 코드 생성·문서 작성·설계 판단 시 참조하는 모든 규칙, 가이드, 컨벤션, 스키마, 템플릿 파일의 집합이다.

Claude Code는 작업 시작 전 자동으로 KB를 읽어 규칙을 파악하고, 이를 기반으로 프로젝트에 맞는 산출물을 생성한다.

### 1-3. 적용 범위

| 저장소 | 역할 | KB 주요 목적 |
|---|---|---|
| cloud-wms-doc | 화면설계 산출물 저장소 | UI 규칙, 산출물 자동화 명령어 정의 |
| cloud-wms-fe | Vue 3 프론트엔드 | 컴포넌트 규칙, CRUD 패턴, BE 계약 정의 |
| cloud-wms-be | Spring MVC 백엔드 | 레이어 아키텍처, DB 스키마, 개발 워크플로우 정의 |

---

## 2. KB 전체 아키텍처

### 2-1. 3개 저장소 KB 구조 도식

```
cloud-wms (AI 프레임워크)
│
├── cloud-wms-doc/               ← 화면설계 KB
│   ├── CLAUDE.md                ← 진입점: 프로젝트 목적, 파일 구조, 슬래시 명령어
│   └── .claude/
│       ├── rules/               ← UI 작성 규칙 (7개)
│       ├── commands/            ← 산출물 생성 명령어 (9개)
│       └── skills/              ← 자동화 스킬 (17개)
│
├── cloud-wms-fe/                ← 프론트엔드 KB
│   ├── CLAUDE.md                ← 진입점: 스택, 금지사항, API 규약
│   ├── .claude/
│   │   ├── rules/               ← 코딩 규칙 (3개)
│   │   ├── commands/            ← 메뉴 생성/검증 명령어 (3개)
│   │   └── agents/              ← 전문 에이전트 (2개)
│   └── ai-docs/                 ← 상세 지식 베이스
│       ├── 00-memory/           ← 시스템 아키텍처, 메뉴코드, 용어사전
│       └── 20-frontend/         ← FE 아키텍처, 규칙, 컨벤션, 가이드, 프롬프트
│
└── cloud-wms-be/                ← 백엔드 KB
    ├── CLAUDE.md                ← 진입점: 스택, 핵심 원칙, 워크플로우
    ├── .claude/
    │   ├── rules/               ← 개발 판단 기준 (6개)
    │   ├── commands/            ← 설계/개발/유틸 명령어 (20개)
    │   ├── skills/              ← 코드 패턴 스킬 (5개)
    │   ├── agents/              ← 자동 탐색 에이전트 (6개)
    │   └── settings.json        ← 자동화 훅 (4개)
    └── DEV_DOC/ai-docs/         ← 상세 지식 베이스
        ├── 00-memory/           ← 시스템 아키텍처, 메뉴코드
        ├── 10-database/         ← DB 스키마, 규칙, 공통코드
        ├── 20-backend/          ← BE 아키텍처, 컨벤션, 가이드, 스펙
        └── 30-interface/        ← 외부연동 명세
```

### 2-2. KB 로딩 방식

| 로딩 방식 | 대상 파일 | 시점 |
|---|---|---|
| **자동 로드** | `CLAUDE.md`, `.claude/rules/*.md` | 대화 시작 시 항상 |
| **명령어 호출** | `.claude/commands/*.md` | `/명령어` 입력 시 |
| **스킬 자동 감지** | `.claude/skills/*/SKILL.md` | 관련 파일 편집 감지 시 |
| **에이전트 호출** | `.claude/agents/*.md` | 명령어 내부에서 `@에이전트` 호출 시 |
| **필요 시 참조** | `ai-docs/`, `DEV_DOC/ai-docs/` | 에이전트 또는 명령어가 명시적으로 읽을 때 |

---

## 3. KB 카테고리 분류

### 3-1. 공통 카테고리 체계

모든 저장소의 KB 파일은 아래 6가지 카테고리로 분류된다.

| 카테고리 | 기호 | 설명 | 예시 |
|---|---|---|---|
| **진입점** | EP | Claude가 가장 먼저 읽는 파일. 프로젝트 맥락과 핵심 원칙 요약 | `CLAUDE.md` |
| **규칙** | RU | 개발 판단 기준, 체크리스트, 금지사항 | `.claude/rules/*.md` |
| **명령어** | CM | 슬래시 명령어로 호출하는 작업 워크플로우 | `.claude/commands/*.md` |
| **스킬** | SK | 특정 파일 편집 시 자동 참조하는 코드 패턴 | `.claude/skills/*/SKILL.md` |
| **에이전트** | AG | 특정 탐색·분석을 전담하는 서브 에이전트 | `.claude/agents/*.md` |
| **상세문서** | DD | 아키텍처, 스키마, 가이드 등 깊이 있는 참조 문서 | `ai-docs/`, `DEV_DOC/ai-docs/` |

### 3-2. 저장소별 KB 파일 목록

#### cloud-wms-doc KB

| 카테고리 | 파일 경로 | 역할 |
|---|---|---|
| EP | `CLAUDE.md` | 프로젝트 목적, dist/ 구조, 슬래시 명령어, postMessage 통신 방식 |
| RU | `.claude/rules/common_ui.md` | 모든 화면 공통 규칙 (레이아웃, 컬러, 팝업, 테스트 데이터) |
| RU | `.claude/rules/area_search.md` | 검색 필터 영역 규칙 (5컬럼, 레이블, 입력 컴포넌트) |
| RU | `.claude/rules/area_result_grid.md` | 결과 그리드 규칙 (헤더, 컬럼 너비 기준표, 페이징) |
| RU | `.claude/rules/area_btn.md` | 기능 버튼 툴바 규칙 (CRUD 버튼, 정렬, 스타일) |
| RU | `.claude/rules/area_multi_input_grid.md` | 다중 입력 그리드 규칙 (인라인 입력, 체크박스) |
| RU | `.claude/rules/popup_biz.md` | 업무규칙 팝업 규칙 (화면구성 테이블, 드래그 이동) |
| RU | `.claude/rules/popup_reg.md` | 등록/수정 팝업 규칙 (폼 레이아웃, 컴포넌트, 모드 전환) |
| CM | `.claude/commands/deploy.md` | FTP 배포 명령어 (`/deploy`) |
| CM | `.claude/commands/PI_111.md` | 프로그램 소스 ZIP 생성 (`/PI_111`) |
| CM | `.claude/commands/PI_112.md` | 프로그램 목록 엑셀 생성 (`/PI_112`) |
| CM | `.claude/commands/PI_113.md` | 공통코드정의서 생성 (`/PI_113`) |
| CM | `.claude/commands/PI_212.md` | 단위테스트 보고서 생성 (`/PI_212`) |
| CM | `.claude/commands/SD_211.md` | ERD 뷰어 생성 (`/SD_211`) |
| CM | `.claude/commands/TT_551.md` | DB 이관 명령어 (`/TT_551`) |
| CM | `.claude/commands/PI_issue_mod.md` | 레드마인 이슈 수정 (`/PI_issue_mod`) |
| CM | `.claude/commands/PI_time_reg.md` | 레드마인 작업시간 등록 (`/PI_time_reg`) |
| SK | `.claude/skills/PI_411/SKILL.md` | 프로그램 소스 ZIP 생성 스킬 |
| SK | `.claude/skills/PI_412/SKILL.md` | 프로그램 목록 엑셀 생성 스킬 |
| SK | `.claude/skills/PI_421/SKILL.md` | 단위테스트 보고서 스킬 (JUnit) |
| SK | `.claude/skills/RA_222/SKILL.md` | 요구사항정의서 생성 스킬 |
| SK | `.claude/skills/SD_331/SKILL.md` | 테이블정의서 생성 스킬 |
| SK | `.claude/skills/SD_332/SKILL.md` | 공통코드정의서 생성 스킬 |
| SK | (이외 11개 스킬) | 각종 산출물 자동화 |

#### cloud-wms-fe KB

| 카테고리 | 파일 경로 | 역할 |
|---|---|---|
| EP | `CLAUDE.md` | Vue 3 스택, 금지사항, API 메서드 규약, 응답 네이밍 |
| RU | `.claude/rules/01-commit-rule.md` | 커밋 메시지 한글, AI 표기 금지, --no-verify 금지 |
| RU | `.claude/rules/02-fe-code-rule.md` | 함수 접두사 규칙, import 순서, 절대 금지사항 |
| RU | `.claude/rules/03-doc-rule.md` | 문서 단일 소스 원칙, 갱신 트리거, YAML frontmatter |
| CM | `.claude/commands/new-menu-from-be-spec.md` | BE 스펙 기반 메뉴 Vue 파일 생성 |
| CM | `.claude/commands/sync-be-spec.md` | BE 스펙 동기화 (API 매핑, 공통코드 갱신) |
| CM | `.claude/commands/util-verify-menu.md` | 메뉴 계약 검증 (HTTP 메서드, URL, 응답 네이밍) |
| AG | `.claude/agents/be-spec-reader.md` | BE 80-spec 파싱 → FE용 정보 추출 |
| AG | `.claude/agents/fe-code-reviewer.md` | Vue 3 코드 컨벤션 자동 리뷰 |
| DD | `ai-docs/00-memory/02-system-architecture.md` | 시스템 3-Tier 아키텍처 (UI/BIZ/DB) |
| DD | `ai-docs/00-memory/03-menu-code-rule.md` | 메뉴코드 형식, 타입, 전체 메뉴 코드 맵 |
| DD | `ai-docs/00-memory/04-dictionary-of-terms.md` | DB 컬럼명-한글 용어사전 (60+ 항목) |
| DD | `ai-docs/20-frontend/00-frontend-ai-entry.md` | **AI 진입점**: 필수 확인 순서, 핵심 원칙, 업무군 코드 맵 |
| DD | `ai-docs/20-frontend/10-architecture/` | FE 아키텍처, BE-FE HTTP 계약, 기술 스택 |
| DD | `ai-docs/20-frontend/20-rule/` | 네이밍 규칙, AI 워크플로우 규칙 |
| DD | `ai-docs/20-frontend/30-convention/` | Vue 파일 템플릿, CRUD 패턴, BE 스펙 소비 방법 |
| DD | `ai-docs/20-frontend/40-guide/` | Z* 컴포넌트 가이드 (그리드, 폼, 버튼, 팝업, 공통코드 등) |
| DD | `ai-docs/20-frontend/60-menus/` | 메뉴별 API 매핑 문서 |
| DD | `ai-docs/20-frontend/70-prompts/` | 작업 유형별 프롬프트 템플릿 (8개) |

#### cloud-wms-be KB

| 카테고리 | 파일 경로 | 역할 |
|---|---|---|
| EP | `CLAUDE.md` | Java 11 + Spring 스택, 핵심 원칙 5가지, 개발 워크플로우 |
| EP | `AGENTS.md` | 슬래시 커맨드 매핑, 아키텍처, 절대 금지 10가지 |
| RU | `.claude/rules/rule.md` | 전체 규칙 파일 연결 인덱스 |
| RU | `.claude/rules/backend-convention.md` | 레이어 체크리스트, Comp/TxComp 판단 기준, 예외 클래스 선택 |
| RU | `.claude/rules/db-convention.md` | Mapper 네이밍, @Param 기준, SELECT/INSERT/UPDATE 체크리스트 |
| RU | `.claude/rules/biz-framework.md` | InvenManager/DocNoGenerator 사용 판단 기준 |
| RU | `.claude/rules/security.md` | 민감정보 코드 포함 금지, 커밋 전 체크리스트 |
| RU | `.claude/rules/test-runner.md` | JUnit Docker 자동 실행 규칙, 테스트 회피 금지 |
| CM | `.claude/commands/design/design-db.md` | 신규 테이블/컬럼 설계 |
| CM | `.claude/commands/design/design-spec.md` | 기능 명세 작성 |
| CM | `.claude/commands/design/design-plan.md` | 레이어별 개발 계획 |
| CM | `.claude/commands/design/design-task.md` | 작업 항목 분해 |
| CM | `.claude/commands/dev/dev-all.md` | 전 레이어 일괄 개발 (Mapper→Controller) |
| CM | `.claude/commands/dev/dev-mapper.md` | Mapper 단독 개발 |
| CM | `.claude/commands/dev/dev-dao.md` | Dao 단독 개발 |
| CM | `.claude/commands/dev/dev-comp.md` | Comp 단독 개발 |
| CM | `.claude/commands/dev/dev-inven-tx.md` | InvenManager TxComp 개발 |
| CM | `.claude/commands/util/util-db-apply.md` | DB 스크립트 적용 |
| CM | `.claude/commands/util/util-api-docs.md` | API 문서 자동 생성 |
| CM | `.claude/commands/util/util-work-status.md` | 작업 진행 현황 조회 |
| SK | `.claude/skills/backend-convention/SKILL.md` | Controller/Comp/TxComp/Dao 코드 패턴 |
| SK | `.claude/skills/db-convention/SKILL.md` | MyBatis XML 쿼리 패턴 |
| SK | `.claude/skills/biz-framework/SKILL.md` | InvenManager/DocNoGenerator 호출 패턴 |
| SK | `.claude/skills/sif-convention/SKILL.md` | SIF 외부연동 코드 패턴 |
| AG | `.claude/agents/code-layer-explorer.md` | 메뉴코드로 기존 레이어 파일 전체 탐색 |
| AG | `.claude/agents/db-doc-reader.md` | 테이블명/키워드로 DB 문서 조회·요약 |
| AG | `.claude/agents/junit-result-reporter.md` | Docker testTarget 실행 + PASS/FAIL 요약 |
| AG | `.claude/agents/work-initializer.md` | 작업 폴더·산출물 탐색 |
| AG | `.claude/agents/work-status-reporter.md` | 레이어별 소스·테스트 완료 현황 |
| AG | `.claude/agents/spec-planner.md` | 화면설계·DB 분석 후 spec/plan 작성 |
| DD | `DEV_DOC/ai-docs/00-memory/02-system-architecture.md` | 시스템 3-Tier 아키텍처, ERP 연동 구조 |
| DD | `DEV_DOC/ai-docs/00-memory/03-menu-code-rule.md` | 메뉴코드 체계, 패키지 구조, API URL 규칙 |
| DD | `DEV_DOC/ai-docs/10-database/` | DB 아키텍처, 네이밍 규칙, 공통코드, 테이블 스키마 |
| DD | `DEV_DOC/ai-docs/20-backend/30-convention/` | 전체 코딩 컨벤션, 헤더-디테일 구조, JUnit 컨벤션 |
| DD | `DEV_DOC/ai-docs/20-backend/40-guide/` | 레이어별 작성 가이드 (Controller/Dao/Mapper/Comp/TxComp) |
| DD | `DEV_DOC/ai-docs/20-backend/80-spec/` | 메뉴별 기능 명세/개발 계획/작업 항목 (산출물) |

---

## 4. KB 파일 명명 규칙

```
{NN}-{subject}-{detail}.md
│     │         │
│     │         └─ 세부 주제 (선택)
│     └─────────── 주제명 (kebab-case, 영문)
└─────────────────── 2자리 순번 (00~99)
```

| 순번 범위 | 용도 |
|---|---|
| 00-01 | 개요(overview), 이력(history) |
| 02-09 | 메모리/참조 정보 |
| 10-19 | 아키텍처 |
| 20-29 | 규칙(rule) |
| 30-39 | 컨벤션(convention) |
| 40-49 | 가이드(guide) |
| 50-59 | 테스트 |
| 60-69 | 메뉴별 문서 |
| 70-79 | 프롬프트 |
| 80-89 | 스펙/명세 (산출물) |
| 90-99 | 스키마/아카이브 |

---

## 5. Sonnet / Opus 라우팅 정의

### 5-1. 모델 특성 비교

| 구분 | Claude Sonnet 4.6 | Claude Opus 4.7 |
|---|---|---|
| **특징** | 빠른 응답, 비용 효율 | 높은 추론 능력, 복잡한 판단 |
| **적합 작업** | 반복적·패턴 기반 작업 | 복잡한 설계·분석·판단 |
| **컨텍스트 처리** | 중간 규모 컨텍스트 | 대용량 컨텍스트 처리 우수 |
| **기본값** | 기본 모델 (대부분 작업) | 명시적으로 지정할 때만 사용 |

### 5-2. 작업 유형별 모델 라우팅

#### Sonnet 사용 (기본값)

| 작업 유형 | 근거 | 예시 |
|---|---|---|
| **CRUD 코드 생성** | 패턴이 정형화되어 있어 반복 적용 가능 | `/dev-mapper`, `/dev-dao`, `/dev-comp` |
| **UI 프로토타입 생성** | rules/ 파일의 규칙을 따라 HTML 생성 | `/ui {메뉴코드}` |
| **산출물 자동화** | 템플릿 기반 Excel/ZIP/HTML 생성 | `/PI_411`, `/PI_412`, `/SD_331` |
| **문서 검색 및 요약** | DB 스키마 조회, 파일 탐색 | `@db-doc-reader`, `@code-layer-explorer` |
| **코드 컨벤션 검증** | 규칙 파일과 대조하는 패턴 매칭 | `@fe-code-reviewer`, `/util-verify-menu` |
| **단순 명세 작성** | 기존 양식 기반으로 채우는 작업 | `/design-task`, 회의록 정리 |
| **커밋 메시지 작성** | 변경 내역 요약 (단순 서술) | git commit |
| **FTP 배포** | 파일 목록 확인 후 명령어 실행 | `/deploy` |
| **레드마인 연동** | API 파라미터 파싱 후 호출 | `/PI_issue_mod`, `/PI_time_reg` |

#### Opus 사용 (복잡한 작업)

| 작업 유형 | 근거 | 예시 |
|---|---|---|
| **KB 구조 설계** | 여러 저장소를 종합 분석하고 체계를 설계하는 고차원 판단 | WBS 1.4 (이 문서) |
| **DB 스키마 신규 설계** | 도메인 이해 + 정규화 + 기존 테이블과의 관계 분석 필요 | `/design-db` |
| **전체 기능 명세 작성** | 화면설계·DB·API를 종합 분석하여 명세 도출 | `/design-spec` |
| **멀티 레이어 일괄 개발** | Mapper → Dao → CompUtil → TxComp → Comp → Controller 6단계 추론 | `/dev-all` |
| **재고 트랜잭션 개발** | InvenManager 판단 기준 + 도메인 규칙 복합 적용 | `/dev-inven-tx` |
| **외부연동(SIF) 설계** | 외부 시스템 스펙 분석 + 오류 처리 설계 | `/design-if-spec`, `/dev-if-all` |
| **아키텍처 설계 검토** | 시스템 전체 구조에 영향을 미치는 변경 판단 | 기술 부채 개선, 공통 프레임워크 변경 |
| **표준 패턴 도출** | 10+ 프로젝트 공통 패턴 분석 및 추상화 | WBS 1.3 표준 패턴 라이브러리 |
| **복잡한 SQL 최적화** | 실행 계획 분석 + 인덱스 전략 + 쿼리 재작성 | `/util-mybatis-sql` (복잡한 쿼리) |

### 5-3. 라우팅 판단 기준 플로우차트

```
작업 시작
   │
   ▼
[기존 패턴/규칙이 있는가?]
   │                  │
  YES                 NO
   │                  │
   ▼                  ▼
Sonnet 사용    [여러 파일/시스템을 종합 분석해야 하는가?]
               │                        │
              YES                       NO
               │                        │
               ▼                        ▼
          Opus 사용              [판단 결과가 다른 작업에 영향?]
                                  │              │
                                 YES             NO
                                  │              │
                                  ▼              ▼
                             Opus 사용      Sonnet 사용
```

### 5-4. 프로젝트별 기본 모델 설정

| 저장소 | 기본 모델 | Opus 전환 조건 |
|---|---|---|
| cloud-wms-doc | **Sonnet** | KB 구조 변경, 새 UI 규칙 체계 설계 시 |
| cloud-wms-fe | **Sonnet** | 신규 Z* 컴포넌트 설계, 아키텍처 변경 시 |
| cloud-wms-be | **Sonnet** | `/design-db`, `/design-spec`, `/dev-all`, `/dev-inven-tx` 실행 시 |

---

## 6. KB 통제 원칙

### 6-1. 자동화 훅 (cloud-wms-be)

Claude Code가 파일을 편집할 때 아래 위반 사항을 자동 감지한다.

| 감지 조건 | 근거 규칙 | 동작 |
|---|---|---|
| `ZTEST_*.java`에서 `@Test` 삭제 | test-runner.md §6-1 | 경고 및 중단 |
| `ZTEST_*.java`에 `@Disabled` 추가 | test-runner.md §6-1 | 경고 및 중단 |
| TxComp 외 파일에 `@Transactional` 선언 | backend-convention.md §10 | 경고 및 중단 |
| `Mapper.xml`에서 `DELETE FROM` 사용 | db-convention.md §9 | 경고 + 소프트 삭제 안내 |
| git commit 전 평문 민감정보 포함 | security.md §3 | 경고 및 중단 |

### 6-2. BLOCKING 조건

아래 조건을 충족하지 않으면 다음 단계 진행이 차단된다.

| 저장소 | BLOCKING 조건 | 근거 |
|---|---|---|
| cloud-wms-be | DB 사용 전 테이블 스키마 문서 확인 | 임의 추정 금지 |
| cloud-wms-be | 각 레이어 JUnit 통과 후 다음 레이어 진행 | 품질 보증 |
| cloud-wms-be | Controller JUnit 통과 후 통합검증 필수 | 최종 검증 |
| cloud-wms-fe | BE 스펙 문서 확인 후 API 연동 코드 작성 | 계약 준수 |

---

## 7. KB 유지보수 가이드

### 7-1. KB 파일 추가 기준

| 상황 | 추가 위치 | 담당 |
|---|---|---|
| 새 UI 컴포넌트 규칙 필요 | `.claude/rules/area_{명칭}.md` | FE 설계자 |
| 새 산출물 자동화 | `.claude/skills/{코드}/SKILL.md` | 자동화 담당 |
| 새 개발 명령어 | `.claude/commands/{phase}/{명칭}.md` | 백엔드 개발자 |
| 새 테이블 추가 | `DEV_DOC/ai-docs/10-database/90-schema/20-tables/{테이블명}.md` | DBA |
| 새 메뉴 개발 | `DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/` | 개발자 |

### 7-2. KB 갱신 트리거

| 이벤트 | 갱신 대상 파일 |
|---|---|
| API URL 변경 | `ai-docs/20-frontend/60-menus/{메뉴}/menu.md` |
| 공통코드 추가 | `DEV_DOC/ai-docs/10-database/90-schema/30-data/01-common-code.md` |
| 테이블 컬럼 변경 | `DEV_DOC/ai-docs/10-database/90-schema/20-tables/{테이블명}.md` |
| 새 Z* 컴포넌트 출시 | `ai-docs/20-frontend/40-guide/` |
| 개발 워크플로우 변경 | `CLAUDE.md` (해당 저장소) |

### 7-3. KB 파일 금지 사항

- 동일 내용을 두 파일에 중복 작성하지 않는다. (단일 소스 원칙)
- BE 스펙 원본 파일(`80-spec/`)을 FE 쪽에서 직접 수정하지 않는다.
- `rules/` 파일에 프로젝트 맥락(특정 메뉴, 특정 데이터)을 적지 않는다. 규칙은 범용적이어야 한다.
- KB 파일에 DB 접속 정보, JWT Secret, API Key 등 민감정보를 포함하지 않는다.

---

## 8. KB 규모 현황

| 저장소 | EP | RU | CM | SK | AG | DD | 합계 |
|---|---|---|---|---|---|---|---|
| cloud-wms-doc | 1 | 7 | 9 | 17 | 0 | 0 | **34** |
| cloud-wms-fe | 1 | 3 | 3 | 0 | 2 | 35+ | **44+** |
| cloud-wms-be | 2 | 6 | 20 | 5 | 6 | 50+ | **89+** |
| **합계** | **4** | **16** | **32** | **22** | **8** | **85+** | **167+** |

> EP: 진입점 / RU: 규칙 / CM: 명령어 / SK: 스킬 / AG: 에이전트 / DD: 상세문서
