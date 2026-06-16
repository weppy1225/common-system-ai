---
title: cloud-wms-doc 레포 전체 디렉토리 구조 및 지식베이스 역할 분리 설계안
description: 레포 최상위 디렉토리 구조, 각 영역의 역할, 그리고 메뉴별 지식베이스(01~07+99)의 작업 세트별 로드 모델·사실당 단일 집(SoT) 역할 분리 규칙. 프롬프트 개정과 문서 생성/재생성의 기준 문서.
status: draft
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
applies_to:
  - "**"
last_verified: 2026-06-09
---

# cloud-wms-doc 레포 전체 디렉토리 구조 (설계안)

WMS AI 프레임워크 레포. 화면설계·지식베이스·소스패턴·산출물·BE/FE 자동화 스킬의 단일 허브.
이 문서는 **(A) 레포 전체 구조** 와 **(B) 메뉴별 지식베이스 문서 역할 분리 규칙** 을 함께 고정한다.

---

## A. 레포 전체 디렉토리 구조

```
cloud-wms-doc/
├── 00-overview.md                # 전체 진입점 인덱스
├── STRUCTURE.md                  # (이 문서) 레포 구조 + KB 역할 분리 기준
├── AGENTS.md                     # Codex 에이전트 지침
├── CLAUDE.md                     # Claude Code 에이전트 지침
│
├── .claude/
│   ├── skills/                   # 슬래시 커맨드 스킬 (SD_* · PI-* · TT_* · RA_222 · deploy 등)
│   ├── rules/                    # 항상 적용되는 규칙
│   │   ├── common_ui.md · area_*.md · popup_*.md   # 프로토타입 UI 규칙
│   │   ├── backend-convention.md · db-convention.md · biz-framework.md · sif-convention.md
│   │   ├── md-frontmatter.md      # MD frontmatter 작성 규칙
│   │   └── repo-paths.md          # 경로 규약
│   └── settings.local.json
│
├── 10-src-pattern/               # ▣ 소스코드 패턴 표준 (메뉴 공통·전역 지식)
│   ├── 00-overview.md
│   ├── 10-screen-design/         # 화면설계 패턴 (10-web / 20-pda)
│   ├── 20-database/              # DB 패턴
│   ├── 30-backend/               # BE 패턴
│   │   └── be-layer-pattern.md   # ★ Controller·Comp·TxComp·Dao 레이어 역할 (KB 06이 의존)
│   ├── 40-frontend/              # FE 패턴
│   └── 50-interface/             # 인터페이스 패턴
│
├── 20-deliverables/              # ▣ 산출물 표준
│   ├── 10-templates/             # 양식·예시
│   ├── 20-sources/               # 원천자료 (회의록·화면캡처·고객자료)
│   └── 30-output/                # 스킬 생성 결과물 (02 분석 ~ 06 PM, 고객 제출)
│
├── 30-domain/                    # ▣ 메뉴별 지식베이스 (← 본 문서 B장 적용 대상)
│   ├── 00-overview.md
│   ├── 10-md-index.md            # 메뉴 인덱스
│   ├── 20-src-index/             # 기존 프로젝트 소스코드 인덱스 (13개 프로젝트)
│   ├── 30-wms-business/          # 업무 그룹 (메뉴별 KB)
│   │   └── {메뉴코드}/           # 예: mdbz01, mdpr01, mdwh01 …
│   │       ├── {메뉴코드}-01-basic-design.md     # 기본설계  (BE)
│   │       ├── {메뉴코드}-02-ui.md               # 화면설계  (FE)
│   │       ├── {메뉴코드}-03-data-model.md       # DB 설계   (BE)
│   │       ├── {메뉴코드}-04-be-mapper-sql.md    # 쿼리      (BE)
│   │       ├── {메뉴코드}-05-api.md              # API 계약  (BE+FE ★허브)
│   │       ├── {메뉴코드}-06-be-flow.md          # BE 흐름   (BE)
│   │       ├── {메뉴코드}-07-fe-flow.md          # FE 흐름   (FE)
│   │       └── {메뉴코드}-99-issues.md           # 확인/조치 (별도 로드)
│   ├── 40-issue/                 # 이슈 모음
│   ├── 50-install-guide/         # 설치 가이드
│   └── 60-development-workflow/  # 개발 워크플로
│
├── 50-prototype/                 # ▣ 화면 프로토타입 배포 프레임
│   ├── index.html                # 메인 프레임 (메뉴 클릭 시 wireframe 로드)
│   ├── 10-common/                # 공통 팝업(CPCT01/CPPD01)·left-menu·wms-ui.css 등
│   └── 20-mobile/                # PDA 모바일 프로토타입
│
├── 60-system/                    # ▣ 시스템 운영·인프라 가이드
│   └── deploy/                   # 빌드·배포 가이드
│       └── local-deploy-guide.md # 로컬 Tomcat 빌드·배포·검증 절차
│
└── 90-archive/                   # ▣ 아카이브 문서
```

### 최상위 영역 역할

| 영역 | 역할 | 소비 주체 |
|---|---|---|
| `.claude/skills` | 개발 전 주기 자동화 커맨드 | 에이전트 실행 |
| `.claude/rules` | 항상 적용되는 UI·코딩·문서 규칙 | 에이전트 상시 로드 |
| `10-src-pattern` | **메뉴 공통/전역 지식**(레이어·쿼리·화면 패턴) | KB 문서가 이름으로 참조 |
| `20-deliverables` | 고객 제출 산출물(양식·원천·결과) | 스킬 입출력 |
| `30-domain` | **메뉴별 지식베이스** = 코딩 컨텍스트 원천 | 작업별 선택 로드 |
| `50-prototype` | 화면설계 프로토타입 배포 | 브라우저 |
| `60-system` | 시스템 운영·인프라 가이드 (빌드·배포·설치) | 운영자·개발자 참조 |
| `90-archive` | 아카이브 문서 보관 | 참조 |

> **공통 지식의 home은 `10-src-pattern/`이다.** 레이어 역할(`be-layer-pattern.md`)·쿼리 패턴·화면 패턴은 이미 여기 존재하므로, 메뉴 KB는 이를 **복제하지 않고 이름으로만 참조**한다. (별도 `_common/` 디렉토리를 만들지 않는다.)

---

## B. 메뉴별 지식베이스 (30-domain) 문서 역할 분리

메뉴 KB는 **AI 코딩 에이전트가 작업별로 일부 문서만 골라 로드**한다. 아래 규칙은 이 전제 위에 선다.

### B-1. 메뉴 폴더 구조 / 채번

`30-domain/30-wms-business/{메뉴코드}/` 아래, 개발 파이프라인 순서로 채번한다.

| 순번 | 파일 | 역할 | 작업 세트 |
|---|---|---|---|
| 01 | `{메뉴}-01-basic-design.md` | 기본설계 (업무 정의·참여자·시나리오·업무규칙) | BE |
| 02 | `{메뉴}-02-ui.md` | 화면설계 (화면목록·레이아웃·UI속성) | FE |
| 03 | `{메뉴}-03-data-model.md` | DB 설계 (테이블·관계·상태 파생) | BE |
| 04 | `{메뉴}-04-be-mapper-sql.md` | 쿼리 (SQL 명세) | BE |
| 05 | `{메뉴}-05-api.md` | **API 계약 (필드·엔드포인트·상태표시값) — 허브** | BE+FE |
| 06 | `{메뉴}-06-be-flow.md` | BE 흐름 (시퀀스·예외) | BE |
| 07 | `{메뉴}-07-fe-flow.md` | FE 흐름 (함수 시퀀스·구현 포인트) | FE |
| 99 | `{메뉴}-99-issues.md` | 확인/조치 레지스터 | 별도 로드 |

### B-2. 핵심 원칙

**원칙 1 — 독립의 단위는 "문서"가 아니라 "작업 세트"**

| 작업 세트 | 로드 문서 |
|---|---|
| BE 작업 (Mapper·Dao·Comp) | 01 · 03 · 04 · 05 · 06 + `10-src-pattern/30-backend/*` |
| FE 작업 (목록·팝업) | 02 · 05 · 07 + `10-src-pattern/10-screen-design/*` |
| 교집합(허브) | **05** — 모든 작업에 항상 로드 |

→ 각 **세트가 자기완결**이면 된다. 개별 문서가 혼자 완결될 필요는 없다.

**원칙 2 — 사실 1개 = 집 1곳(SoT).** 같은 사실을 여러 문서에 복붙하지 않는다(§B-3).

**원칙 3 — 경로 링크(`./xxx.md`) 금지, "이름 언급"만.** 같은 세트 문서는 함께 로드되므로 경로 없이 이름만 쓴다(예: `필드 정의는 05-api 참조`). frontmatter `related`/`depends_on`에 절대경로를 넣지 않는다. ← 기존 `mdbz01-v2`·`70-knowledgebase` 깨진 링크의 근본 원인 제거.

**원칙 4 — 세트 밖 중복은 런타임 비용 0.** BE는 02를, FE는 03·04를 로드하지 않으므로 세트가 다른 문서 간 중복은 토큰을 쓰지 않는다. 단 유지보수를 위해 가급적 05 단일 집 유지.

**원칙 5 — 세트 밖 사실이 필요하면 = 분리가 틀린 신호.** 링크로 때우지 말고 역할 분리/로드 세트를 다시 잡는다.

### B-3. 사실당 단일 집 (SoT 매핑)

| 사실 | 집 (SoT) |
|---|---|
| 업무 정의·참여자·시나리오·업무규칙 BR-n | **01** |
| 화면 레이아웃·폼/그리드 형태·UI속성(정렬·입력유형·필수·편집여부) | **02** |
| 테이블 목록·상태 DB 파생(컬럼 조합) | **03** (+ 정밀 JOIN은 실DB/04) |
| SQL 명세 (복잡 SQL만 풀 텍스트) | **04** |
| **DTO 필드·타입·제약 / 엔드포인트 / 상태 표시값** | **05 (허브)** |
| BE 시퀀스·예외 | **06** |
| FE 함수 시퀀스·구현 포인트 | **07** |
| 레이어 역할(Controller~Dao) | **`10-src-pattern/30-backend/be-layer-pattern.md`** |
| 쿼리·화면 공통 패턴 | **`10-src-pattern/`** 해당 영역 |

### B-4. 문서별 포함 / 제외 요약

- **01**: 업무정의·참여자·시나리오·BR / 제외: 상태표(→03)·SQL·API경로
- **02**: 화면목록·레이아웃·UI속성·검색조건(파라미터명까지 자기완결) / 제외: 필드 타입(→05). ※04로 링크 금지(FE 세트에 04 없음)
- **03**: 테이블목록·관계요약·상태 DB파생 + DB싱크 경고 / 제외: 상태 표시값(→05)·풀 SQL(→04)
- **04**: SQL 목록 + JOIN·서브쿼리·CASE 있는 SQL만 풀 텍스트 / 제외: 단순 CRUD 풀 SQL·반환컬럼표(→05)
- **05(허브)**: 엔드포인트·DTO 필드표·상태 표시값(전부 SoT) / 제외 없음
- **06**: 메뉴 특이사항·mermaid 시퀀스·예외표(의미는 BR 번호 참조) / 제외: 레이어 일반론(→src-pattern)·업무목록표(→05)
- **07**: mermaid 시퀀스·구현 포인트 / 제외: 파일구성표(→02)·API필드(→05)
- **99**: 이슈 레지스터. 상시 KB에 끼우지 않음

### B-5. frontmatter 규칙

- `related`/`depends_on`에 **절대경로 금지** (필요 시 파일명만).
- 같은 메뉴·같은 생성 회차는 **version 통일**.
- 존재하지 않는 파일 참조 금지 — 참조 전 실재 확인.

---

## C. 파이프라인 (스킬 → 문서)

```
RA_222 (요구사항)
   └─> SD_310_UI ──> 02-ui
          └─> SD_311 ──> 02-wireframe.html / 02-mock-data.js (50-prototype 연동)
   SD-db   ──> 03-data-model
   SD-api  ──> 05-api
   (BE 흐름·쿼리: 04 / 06,  FE 흐름: 07)
   PI-be-* ──> cloud-wms-be 구현   (01·03·04·05·06 로드)
   PI-fe-* ──> cloud-wms-fe 구현   (02·05·07 로드)
```

> 01(기본설계) → 02(화면설계) → 03(DB) → 04(쿼리) → 05(API) → 06(BE흐름) → 07(FE흐름) → 99(이슈) 순으로 채번·생성한다.

---

## D. 기존 결함 → 본 설계의 해소

| 기존 결함 | 해소 |
|---|---|
| `mdbz01-v2`·`70-knowledgebase` 깨진 경로 | 경로 링크 폐지(B-2 원칙3) |
| 없는 `_common/*` 참조 | **`_common` 신설 대신 기존 `10-src-pattern/` 재사용**(A장) |
| 04↔05 반환컬럼 중복, 06↔05 업무목록 중복 | 사실당 단일 집(B-3) |
| 04 비대(단순 CRUD 풀 SQL) | 복잡 SQL만 풀 텍스트(B-4) |
| 버전·경로 불일치(04·05 잔존) | frontmatter 규칙(B-5) |
| 02 검색 파라미터를 04로 링크(자기완결 깨짐) | 02 자기완결 유지(B-4) |
