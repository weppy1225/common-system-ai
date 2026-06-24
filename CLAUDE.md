# common-system-ai

업무 시스템 AI 프레임워크 레포지토리다. 화면설계·지식베이스·소스코드 패턴·산출물·BE/FE 개발 자동화 스킬을 통합 관리하며, AI 에이전트(Claude Code·Codex)가 업무 시스템 개발 전 주기를 수행하기 위한 지식·규칙·명령의 단일 허브로 동작한다.

## 작업 히스토리 (최우선 규칙 — 절대 생략 금지)

모든 파일 생성/변경/삭제 작업마다 **작업한 레포**의 `history/` 폴더에 작업 히스토리 파일을 남긴다. BE 작업은 BE 레포, FE 작업은 FE 레포, 허브 문서 작업은 허브 레포에 남긴다(작업한 레포 = 기록 레포). 한 작업이 여러 레포에 걸치면 각 레포에 각각 남긴다.

### 경로·파일명 규칙
- 형식: `history/{작업자}/{레포명}_YYYYMMDD-HHmmss.md`
  - 예: `history/ShinHyunKyu/common-system-ai_20260624-084337.md`
- `{작업자}` 는 **git 자격증명에서 동적 도출**한다 (`git config user.name`) — 하드코딩 금지. 작업자별 하위폴더로 분리한다(작업자마다·머신마다 git 계정이 다르므로 고정값을 적으면 틀린다).
- `{레포명}` 은 작업 중인 레포 폴더명(`common-system-ai` / `common-system-be` / `common-system-fe`).
- `HHmmss` 는 **실제 작업 시점의 현재 시각** — 임의값 금지 (시각은 셸 명령으로 확인: `date +"%Y%m%d-%H%M%S"`)
- 반드시 그 레포의 `history/{작업자}/` 폴더 아래에만 생성 (다른 위치 생성 금지)

### 운영 규칙
- 작업 단위가 작아도 예외 없이 작성
- 커밋 전 history 파일이 존재하는지 **반드시 확인**. 없으면 커밋 금지
- history 파일 없이 커밋하면 작업 추적이 불가능하므로 절대 생략하지 않는다

### 파일 본문 템플릿
```markdown
---
date: YYYY-MM-DD HH:mm:ss
author: {작업자}
---

# 작업 히스토리

## {작업 요약 — 한 줄}

### 변경 내용
1. **{변경 항목}**
   - 이전: ...
   - 이후: ...
   - 사유: ...

### 신규 파일 생성
- `{경로}`
  - {설명}
```

## 목적

- 회의록·미팅 내용을 문서화하여 요건을 정리한다.
- 정리된 요건을 기반으로 화면설계 MD 파일과 프로토타입 HTML 파일을 생성한다.
- 메뉴별 지식베이스(기본설계·데이터모델·API·BE/FE 흐름)를 구축하여 AI 개발의 컨텍스트 원천으로 사용한다.
- BE/FE 개발 자동화 스킬을 중앙 관리하여 BE·FE 레포에서 호출한다.
- 생성된 화면설계 산출물은 백엔드 DB 설계 및 개발의 기준 자료로 사용된다.

## 디렉토리 구조

레포는 **역할별 최상위 폴더 × 시스템별(프로젝트) 네임스페이스** 2축으로 구성된다. 여러 업무 시스템(WMS·OMS·WCS …)을 한 허브에서 개발하며, 같은 종류의 지식은 시스템이 달라도 같은 계층·같은 상대경로에 둔다.

```
common-system-ai\
├── .claude\
│   ├── skills\        # 슬래시 커맨드 스킬 (개발/산출물/유틸)
│   └── rules\         # 조건부(paths)/항상 로딩 규칙 — UI·BE·DB·문서·경로 + 시스템별(oms-*) + 시스템공통(common-code)
├── knowledgebase\    # ① 코어 + ② 도메인 표준 (메뉴 횡단 공통 배경)
│   ├── 10-domain\         메뉴 횡단 공통 업무규칙 (WHY, 사람 작성)
│   ├── domains\           ② 도메인(시스템) 표준 — 같은 도메인 프로젝트끼리 공유. domains\wms\ · domains\oms\(install-guide·patterns\be|db|fe)
│   └── 40-install-guide\·50-dev-workflow\·20-md-index·30-src-index
├── spec\             # ③ 프로젝트(시스템)별 지식베이스 — `{프로젝트}\`
│   ├── common-system\    [WMS] {메뉴}\ 설계(00~07·99) + _knowledge\(실 스키마·메뉴·공통코드값)
│   └── kyochon-oms\      [OMS] {메뉴}\ 설계 + _knowledge\(실데이터: 스키마·메뉴·용어·API)
├── prototype\        # 검증용 화면 (시스템별 `{프로젝트}\`)
├── patterns\         # ① 코어 소스코드 패턴 (시스템 무관: 10-screen-design·20-database·30-backend·40-frontend·_common-arch)
├── deliverables\     # 고객 제출 산출물 (시스템 공통)
└── scripts\          # 레포 유틸 스크립트 (콘텐츠 아님)
```

### 시스템(프로젝트)별 분할 — 3계층

시스템 지식은 3계층으로 분리한다. 충돌 시 우선순위: **③ 프로젝트 확정 > ② 도메인 표준 > ① 코어** (③=실제값, ①=기본값).

| 계층 | 위치 | 시스템 무관/별 | 예 |
|---|---|---|---|
| ① 코어 | `patterns/`, `.claude/rules/`(무접두), `knowledgebase/10·40·50` | 시스템 무관(공유) | be-layer-pattern, `_common-arch/common-code.md`, `common-code` rule |
| ② 도메인(시스템) 표준 | `knowledgebase/domains/{도메인}/` (WMS=`wms/`, OMS=`oms/`) + `.claude/rules/{system}-*`(OMS=`oms-*`) | 도메인별 공유 | 인터페이스 컨벤션, OMS 레이어·SQL·FE 패턴 |
| ③ 프로젝트(시스템) 지식베이스 | `spec/{프로젝트}/_knowledge/` + `spec/{프로젝트}/{메뉴}/` | 배포 단위별 | 실 테이블·메뉴·공통코드값·메뉴별 설계 |

| 시스템 | 프로젝트 폴더 `{프로젝트}` | 도메인 | BE/FE 레포 |
|---|---|---|---|
| WMS | `common-system` | wms | (workspace 형제 `*-be`·`*-fe`) |
| OMS | `kyochon-oms` | oms | `kyochon-oms-be` · `kyochon-oms-fe` |

> 같은 종류의 지식은 시스템이 달라도 같은 계층·같은 상대경로에 둔다(WMS·OMS 대칭). 새 시스템(WCS 등) 추가 시 `knowledgebase/domains/{도메인}/`·`spec/{프로젝트}/`·`.claude/rules/{system}-*` 를 같은 방식으로 만든다.
> `{프로젝트}` 도출·형제 BE/FE 레포 경로 규칙 → `.claude/rules/repo-paths.md`. 전체 구조·영역 역할·SoT 규칙 → [STRUCTURE.md](./STRUCTURE.md).

### 개발 대상 시스템 자동 판별

BE/FE 코드·메뉴 설계 작업 시작 시 **대상 시스템(WMS·OMS 등)을 함께 열린 `*-be`/`*-fe` 레포에서 자동 판별**한다. 판별 신호·절차·실패 처리·허브(ai-kb) 수정과의 구분은 → `.claude/rules/system-detect.md` (개발 파일 작업 시 lazy 로딩).

## 프로토타입 파일 구조

> 허브(`common-system-ai`)는 모든 프로젝트 공통이므로, `spec/`·`prototype/` 는 **프로젝트 층 `{프로젝트}/` 아래**에 둔다. `{프로젝트}` 는 워크스페이스 폴더명(`workspace-{프로젝트}`)에서 도출한다(→ `.claude/rules/repo-paths.md`).

```text
prototype/{프로젝트}/
├── index.html                              # 메인 프레임. 메뉴 클릭 시 {메뉴코드}/{메뉴코드}-wireframe.html 로드
├── _common/                              # 공통 UI
│   ├── left-menu.html
│   ├── CPCT01_popup.html
│   ├── CPPD01_popup.html
│   ├── icon-preview.html
│   ├── common.css
│   ├── common.js
│   └── _template/                          # SD_311 생성 템플릿
└── _common-m/                              # PDA 모바일 공용 셸
    ├── menu.html
    ├── main.html
    ├── mobile.css
    ├── ui-standard.html
    ├── assets/
    └── common/_template/                   # SD_312 생성 템플릿

spec/{프로젝트}/{메뉴코드}/       # 메뉴별 설계 정본 (마크다운)
├── {메뉴코드}-00-domain.md                 # 업무지식 WHY (사람 전용, 스킬 금지)
├── {메뉴코드}-01-basic-design.md
├── {메뉴코드}-02-ui.md                     # SD_310_UI 생성
├── {메뉴코드}-03-data-model.md
├── {메뉴코드}-04-be-mapper-sql.md
├── {메뉴코드}-05-api.md
├── {메뉴코드}-06-be-flow.md
├── {메뉴코드}-07-fe-flow.md
└── {메뉴코드}-99-issues.md

prototype/{프로젝트}/{메뉴코드}/  # PC 검증용 실행물 (SD_311 생성)
├── {메뉴코드}-wireframe.html
└── {메뉴코드}-mock-data.js

prototype/{프로젝트}/{메뉴코드}m/ # PDA 모바일 검증용 실행물 (SD_312 생성)
├── {메뉴코드}m-wireframe.html
└── {메뉴코드}m-mock-data.js
```

### 파일 역할

| 파일 | 역할 |
|---|---|
| `prototype/{프로젝트}/index.html` | 좌측 메뉴 트리, 탭 바, 콘텐츠 iframe. 메뉴 클릭 시 `loadContent('{메뉴코드}/{메뉴코드}-wireframe.html')` 호출 |
| `prototype/{프로젝트}/_common/left-menu.html` | `index.html`과 동일 파일. `_common/` 경로에서 직접 접근할 때 사용 |
| `prototype/{프로젝트}/_common/CPCT01_popup.html` | 거래처 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `prototype/{프로젝트}/_common/CPPD01_popup.html` | 품목 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `prototype/{프로젝트}/_common/icon-preview.html` | 툴바 버튼에 사용할 수 있는 SVG 아이콘 목록. **이 파일에 없는 아이콘은 사용 금지** |
| `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-00-domain.md` | 업무지식·노하우(WHY). **사람 전용 — 자동화 스킬 생성·수정 금지** |
| `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-02-ui.md` | 화면요건정리 문서. `/SD_310_UI {메뉴코드}` 명령어의 입력 소스 |
| `prototype/{프로젝트}/{메뉴코드}/{메뉴코드}-wireframe.html` | 완성된 프로토타입. `prototype/{프로젝트}/index.html`의 iframe 안에서 로드됨 |
| `prototype/{프로젝트}/{메뉴코드}/{메뉴코드}-mock-data.js` | 테스트 데이터. `const {MENUCODE}_DATA = {...}` 형태로 선언. HTML에서 `<script src>` 로 로드 |

### 팝업 통신 방식

메뉴 화면(iframe) → 부모(`index.html`) → 팝업 iframe 순서로 `postMessage`로 통신한다.

```
{메뉴코드}-02-wireframe.html  →  window.parent.postMessage({ type: 'OPEN_CP_LAYER' })
index.html                    →  CPCT01_popup.html 오픈
CPCT01_popup                  →  postMessage({ type: 'CP_SELECTED', data: {...} })
index.html                    →  {메뉴코드}-02-wireframe.html 로 결과 전달
```

## Slash Commands

대부분 `/명령어 {메뉴코드}` 형식으로 실행한다. 전체 현황은 `/skill_list` 로 확인.

> **DB/API 설계 정본 체계**: 메뉴별 정본은 `/SD_db`·`/SD_api` (→ `spec/{프로젝트}/{메뉴코드}/-03-data-model.md`·`-05-api.md`). `/SD_db_apply`는 그 DDL을 test/dev DB에 반영. `/SD_331`~`/SD_334`는 실DB 추출 산출물이며 정본을 대체하지 않는다.

### 🛠️ 개발 자동화 — 설계·코드·테스트 생성 (15)

| 명령어 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | 대화형 인터뷰로 화면요건 `-02-ui.md` 작성 |
| `/SD_db {메뉴코드}` | 화면설계 기반 DB 설계 → `-03-data-model.md`(DDL) |
| `/SD_db_apply {메뉴코드}` | `/SD_db` DDL을 psql로 test/dev DB에 반영 |
| `/SD_api {메뉴코드}` | 화면설계·DB 기반 API 명세 `-05-api.md` |
| `/PI_be_all {메뉴코드}` | BE 전체 레이어 (Mapper→Dao→TxComp→Comp→Controller) |
| `/PI_be_mapper {메뉴코드}` | BE Mapper (Mapper.java + Mapper.xml) |
| `/PI_be_dao {메뉴코드}` | BE DAO 레이어 |
| `/PI_be_comp {메뉴코드}` | BE Comp 레이어 |
| `/PI_be_excel {메뉴코드}` | BE 엑셀 업로드 |
| `/PI_be_inven {메뉴코드}` | BE 재고 확정 처리 |
| `/PI_fe_all {메뉴코드}` | FE 목록 화면 + 팝업 전체 |
| `/PI_fe_list {메뉴코드}` | FE 검색·목록 화면 |
| `/PI_fe_edit {메뉴코드}` | FE 등록/수정 팝업 |
| `/PI_test_be {메뉴코드}` | BE JUnit + API 테스트 실행 |
| `/PI_test_fe {메뉴코드}` | FE 단위 테스트 실행 |

> BE 명령은 BE 레포, FE 명령은 FE 레포에서 실행. FE E2E(`/playwright-spec`·`/e2e-menu-test`)는 **FE 레포** `.claude/`에 정의됨(이 레포 아님).

### 📦 산출물 자동화 — 고객 제출 문서 생성 (16)

| 명령어 | 설명 |
|---|---|
| `/RA_222` | 회의록 분석 → 요구사항정의서 엑셀 |
| `/SD_311 {메뉴코드}` | ui.md → PC 프로토타입 HTML+mock, 메뉴 자동 등록 |
| `/SD_312 {메뉴코드}` | ui.md → PDA 모바일 프로토타입 HTML |
| `/SD_331 [경로]` | 실DB → 테이블정의서 엑셀 |
| `/SD_332 [경로]` | 실DB → 공통코드정의서 엑셀 |
| `/SD_333 [경로]` | 실DB → DDL SQL 파일 |
| `/SD_334 [경로]` | 실DB → ERD 뷰어 HTML |
| `/PI_411 {메뉴코드}` | 프로그램 소스 ZIP |
| `/PI_412` | 프로그램 목록 엑셀 (BE·FE 스캔) |
| `/PI_421` | 단위테스트보고서 엑셀 |
| `/PI_422` | 통합테스트보고서 엑셀 |
| `/TT_541` | PC 사용자매뉴얼 PPTX |
| `/TT_542` | PDA 사용자매뉴얼 PPTX |
| `/TT_543` | 관리자매뉴얼 PPTX |
| `/TT_550` | DB 이관용 INSERT SQL 생성 |
| `/TT_551 [V번호\|all]` | DB 마이그레이션 스크립트 실행 |

### 🔧 유틸 — 배포·관리·메타 (8)

| 명령어 | 설명 |
|---|---|
| `/daily_brief` | 저장소 fetch·pull 후 새 커밋을 목록(누가·언제·왜)+상세로 리포팅 |
| `/md_index` | 파일·폴더 지도 `20-md-index.html` 재생성 (gen-md-map.py) |
| `/deploy [{메뉴코드}]` | 프로토타입 FTP 배포 (메뉴 지정 또는 변경 감지) |
| `/PI_issue_mod` | 레드마인 이슈 진행율·작업이력 수정 |
| `/PI_time_reg` | 레드마인 이슈 작업시간 등록 |
| `/KB_100 {메뉴코드}` | 소스 역공학 → spec 초안 생성 (재설계 대상·동결) |
| `/KB_200 {메뉴코드}` | 설계 ↔ 소스 드리프트 검증 (동결) |
| `/skill_list` | 커스텀 스킬 현황표 출력 |

## UI 규칙

프로토타입 HTML 작성 규칙은 `.claude/rules/`에 정의되어 있으며 자동으로 적용된다.

## 에이전트 동작 규칙

- 코드·제안 전 반드시 실제 파일을 확인하고 근거 기반으로 작성한다.
- 변수명·필드명·컬럼명·API 경로·파일 경로는 이름만 보고 추정하지 않는다. 파일에서 확인 후 사용한다.
- 커밋 메시지는 한글로 작성한다.
- `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-00-domain.md`(업무지식)는 사람 전용 — 자동화 스킬이 생성·수정하지 않는다.
