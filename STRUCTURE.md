---
title: common-system-ai 레포 전체 디렉토리 구조 및 영역 역할
description: 레포 최상위 디렉토리 구조, 각 영역의 역할, 메뉴별 산출 위치와 경계 규칙. 프롬프트 개정·문서 생성/재생성의 기준 문서. (2026-06 재설계 적용)
status: active
version: 2.1.0
repo_role: ai-hub
agent_usage: reference
domain: common
applies_to:
  - "**"
last_verified: 2026-06-22
---

# common-system-ai 레포 전체 디렉토리 구조

업무 시스템 AI 프레임워크 허브 레포. 화면설계·지식베이스·소스패턴·산출물·BE/FE 자동화 스킬의 단일 허브.

> 재설계 배경·결정 근거·이전 매핑은 git 커밋·PR 이력 참조.

---

## 최상위 구조

```
common-system-ai\
├── .claude\
│   ├── skills\        # 슬래시 커맨드 (개발/산출물/유틸 3그룹)
│   └── rules\         # 항상/조건부 적용 규칙 (UI·BE·문서·경로 4그룹)
├── knowledgebase\    # 메뉴 횡단 공통 배경지식 (AI가 읽는 도서관)
├── spec\             # 메뉴별 설계 정본 (마크다운)
├── prototype\        # 검증용 화면 (공용 셸 + 메뉴별 wireframe)
├── patterns\         # 소스코드 패턴 (HOW)
├── deliverables\     # 고객 제출 산출물
└── scripts\          # 레포 유틸 스크립트 (문서 색인 생성 등)
```

| 폴더 | 역할 | 읽는 사람 | 매체 |
|---|---|---|---|
| `knowledgebase/` | 이 프로젝트가 어떻게 돌아가나 (공통 배경) | AI·개발자 | 마크다운 |
| `spec/` | 이 메뉴를 왜·무엇·어떻게 설계했나 | AI·개발자 | 마크다운 |
| `prototype/` | 화면이 이렇게 생겼다 (검증용) | PL·PM·고객 | 실행 HTML/JS |
| `patterns/` | 코드는 이 패턴으로 짜라 | AI·개발자 | 마크다운 |
| `deliverables/` | 고객 제출 문서 | 고객 | 문서·엑셀·PPT |
| `scripts/` | 레포 유틸 스크립트 (콘텐츠 아님) | 개발자 | 파이썬 |

원칙: **최상위는 역할 이름(번호 없음)**. 번호는 순서가 있는 `knowledgebase/`·`spec/{프로젝트}/{메뉴}/` 안에서만 쓴다.
`scripts/`는 콘텐츠가 아니라 도구다.
- `gen-md-map.py` — 레포 문서 지도 → `knowledgebase/20-md-index.html` 생성기
- `check-doc-refs.py` — rules↔patterns 참조 무결성 가드. 깨진 참조(ERROR)·미참조 패턴 문서(WARN)를 검출. `python scripts/check-doc-refs.py`, ERROR 있으면 종료코드 1.

---

## knowledgebase/ (번호 = 읽는 순서)

```
knowledgebase/
├── 00-overview.md       개요
├── 10-domain/           메뉴 횡단 공통 업무규칙·용어·엔티티 관계 (WHY, 사람 작성)
├── domains/             ② 도메인(시스템) 표준 — 같은 도메인 프로젝트끼리 공유. 시스템별: domains/wms/ · domains/oms/(install-guide·patterns/be|db|fe)
├── 20-md-index.md       MD 문서 색인 (문서 위치)
├── 20-md-index.html     ↑의 HTML 뷰 — scripts/gen-md-map.py 생성물 (직접 편집 금지)
├── 30-src-index/        소스코드 색인 (코드 위치 — 실제 코드는 BE/FE 레포)
├── 40-install-guide/    설치·셋업
└── 50-dev-workflow/     개발 워크플로우
```

> 트리에 붙은 `②`(`domains/`)·`③`(`spec/{프로젝트}/_knowledge/`) 등 **①②③ 계층 라벨**의 정의·충돌 우선순위(③ 프로젝트 확정 > ② 도메인 표준 > ① 코어, ③=실제값·①=기본값)는 `CLAUDE.md` §"시스템(프로젝트)별 분할 — 3계층" 이 SoT 다. 여기서는 폴더↔계층 매핑을 위한 라벨로만 쓴다.

---

## spec/{프로젝트}/{메뉴}/ (파일 순서 = 읽는 순서)

`spec/`·`prototype/` 는 **시스템(프로젝트)별 네임스페이스** `{프로젝트}/` 아래에 둔다. 현재 프로젝트: `common-system`(WMS) · `kyochon-oms`(OMS). 각 프로젝트는 `_knowledge/`(③ 프로젝트 확정 데이터: 실 스키마·메뉴·공통코드값)와 `{메뉴}/`(메뉴별 설계)를 가진다. `{프로젝트}` 도출은 → `.claude/rules/repo-paths.md`.

```
spec/{프로젝트}/{메뉴}/
├── {메뉴}-00-domain.md         업무지식 WHY — 사람 전용, 자동화 스킬 생성·수정 금지
├── {메뉴}-01-basic-design.md   기본설계
├── {메뉴}-02-ui.md             화면요건            〔/SD_310_UI〕
├── {메뉴}-03-data-model.md     DB 설계             〔/SD_db〕
├── {메뉴}-04-be-mapper-sql.md  쿼리 명세
├── {메뉴}-05-api.md            API 명세 ★허브      〔/SD_api〕
├── {메뉴}-06-be-flow.md        BE 흐름
├── {메뉴}-07-fe-flow.md        FE 흐름
└── {메뉴}-99-issues.md         설계 미결·하드코딩 등
```

---

## prototype/ (PC=`{메뉴}`, 모바일=`{메뉴}m`)

```
prototype/
├── _common/             PC 공용 셸 (index, 메뉴, 팝업, common.css, common.js)
├── _common-m/           모바일 공용 셸 (menu·main·mobile.css·ui-standard·assets·common/_template)
├── {메뉴}/              PC 검증물 — {메뉴}-wireframe.html + {메뉴}-mock-data.js   〔/SD_311〕
└── {메뉴}m/             모바일 검증물 — {메뉴}m-wireframe.html + {메뉴}m-mock-data.js  〔/SD_312〕
```

---

## patterns/ (코드 작성 패턴 — HOW)

```
patterns/
├── 00-overview.md       패턴 개요
├── 10-screen-design/    화면설계 패턴 (10-web · 20-pda)
├── 20-database/         DB 패턴 (도메인·타입·네이밍·시퀀스·SQL컨벤션)
├── 30-backend/          BE 패턴 (10-architecture · 20-rule)
├── 40-frontend/         FE 패턴 (10-architecture · 20-convention)
└── _common-arch/        공통 아키텍처 (be/fe-architecture·exceptions)
```

---

## .claude/skills/ (성격별 3그룹)

스킬은 **출력 성격**으로 분류한다. 전체 명령 목록은 `/skill_list` 또는 `CLAUDE.md` 명령표 참조.

| 그룹 | 수 | 무엇을 만드나 | 출력 위치 |
|---|---|---|---|
| 🛠️ 개발 자동화 | 15 | 설계·코드·테스트 (SD_310_UI·SD_db·SD_api·PI_be_*·PI_fe_*·PI_test_*) | `spec/`, BE/FE 레포 |
| 📦 산출물 자동화 | 16 | 프로토타입·고객 제출 문서 (SD_311·312·SD_33x·RA_222·PI_4xx·TT_5xx) | `prototype/`, `deliverables/30-output` |
| 🔧 유틸 | 8 | 배포·레드마인·KB·메타 (deploy·daily_brief·md_index·PI_issue_mod·PI_time_reg·KB_100·KB_200·skill_list) | — |

## .claude/rules/ (성격별 그룹)

규칙은 `paths` 글로브로 **조건부 로딩**(매칭 파일 작업 시 첨부)되거나, `paths` 생략 시 **항상 로딩**된다. 시스템 무관(코어)·시스템 공통·시스템별(OMS) 3종이 공존한다.

| 그룹 | 수 | 시스템 | 적용 대상 |
|---|---|---|---|
| UI·화면 | 7 | 무관(코어) | 와이어프레임 HTML 작업 시 자동 트리거되는 **얇은 rule**(common_ui·area_*·popup_*) — 금지/필수 판단 기준만 두고 상세 구현은 `patterns/10-screen-design/10-web/01~07`(SSoT)로 라우팅 |
| BE·DB·연동 | 4 | 무관(코어) | BE·Mapper·재고·SIF (backend/db/wms-biz-framework/wms-sif-convention) |
| 공통코드 | 1 | 공통(전 시스템) | BE·FE 공통코드 사용 (common-code) |
| 시스템별 컨벤션 | 4 | OMS 전용 | oms-backend/db/frontend-convention·oms-security |
| 문서·메타 | 2 | 무관(코어) | frontmatter 작성 (md-frontmatter·rule-skill-frontmatter) |
| 경로·환경·git | 3 | 무관(코어) | 워크스페이스 레포 경로(repo-paths, 항상)·git 워크플로우(git-workflow)·개발 대상 시스템 자동 판별(system-detect, lazy) |

> 시스템별 컨벤션은 `{system}-` 접두어 + `paths` 글로브로 구분한다. 새 시스템(WCS 등) 추가 시 같은 방식으로 `{system}-*` 규칙을 둔다.
> 개발 시작 시 대상 시스템 판별은 `system-detect`(lazy 로딩)이 담당한다. 허브(ai-kb) 자체 수정은 시스템 판별 대상이 아니다.

---

## 경계 규칙 (BLOCKING)

1. 메뉴별 설계·업무지식·미결은 모두 `spec/{프로젝트}/{메뉴}/` (마크다운), 검증 화면은 `prototype/{메뉴}/` (실행 HTML).
2. `{메뉴}-00-domain.md`는 **사람 전용**. 자동화 스킬은 01~07만 생성/갱신한다.
3. AS-IS 정본은 **소스 코드**. 역공학 요약 문서를 저장하지 않는다(위치는 `30-src-index`). `KB_100`=레거시 소스를 `spec/` 초안(draft)으로 역공학(00-domain 제외), `KB_200`=`spec/`↔라이브 소스 드리프트 검증.
4. `knowledgebase/`는 메뉴 횡단 공통 지식만. 메뉴 고유 지식은 `spec/`.
