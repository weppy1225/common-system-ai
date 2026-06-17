# cloud-wms-doc

WMS AI 프레임워크 레포지토리다. 화면설계·지식베이스·소스코드 패턴·산출물·BE/FE 개발 자동화 스킬을 통합 관리하며, AI 에이전트(Claude Code·Codex)가 WMS 개발 전 주기를 수행하기 위한 지식·규칙·명령의 단일 허브로 동작한다.

## 목적

- 회의록·미팅 내용을 문서화하여 요건을 정리한다.
- 정리된 요건을 기반으로 화면설계 MD 파일과 프로토타입 HTML 파일을 생성한다.
- 메뉴별 지식베이스(기본설계·데이터모델·API·BE/FE 흐름)를 구축하여 AI 개발의 컨텍스트 원천으로 사용한다.
- BE/FE 개발 자동화 스킬을 중앙 관리하여 cloud-wms-be · cloud-wms-fe 에서 호출한다.
- 생성된 화면설계 산출물은 백엔드 DB 설계 및 개발의 기준 자료로 사용된다.

## 디렉토리 구조

```
cloud-wms-doc\
├── .claude\
│   ├── skills\       # 슬래시 커맨드 스킬
│   └── rules\        # 항상 적용되는 UI·문서·코딩 규칙
├── patterns\   # 소스코드 패턴 (DB·BE·FE·IF)
├── deliverables\  # 산출물 (템플릿·원천·결과)
├── 30-domain\        # 메뉴별 지식베이스
├── 50-prototype\     # 화면 프로토타입 배포 프레임
├── 60-system\        # 시스템 운영·인프라 가이드
└── 90-archive\       # 아카이브 문서
```

> 전체 디렉토리 구조·영역별 역할·KB 문서 역할 분리(SoT) 규칙: → [STRUCTURE.md](./STRUCTURE.md)

## 프로토타입 파일 구조

```text
50-prototype/
├── index.html                              # 메인 프레임. 메뉴 클릭 시 ../30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-wireframe.html 로드
├── 10-common/                              # 공통 UI
│   ├── left-menu.html
│   ├── CPCT01_popup.html
│   ├── CPPD01_popup.html
│   ├── icon-preview.html
│   ├── wms-ui.css
│   ├── wms-common.js
│   └── _template/                          # SD_311 생성 템플릿
└── 20-mobile/                              # PDA 모바일 프로토타입
    ├── menu.html
    ├── main.html
    ├── mobile.css
    ├── ui-standard.html
    ├── assets/
    └── common/_template/                   # SD_312 생성 템플릿

30-domain/30-wms-business/{메뉴코드}/       # 메뉴별 지식베이스 + 프로토타입
├── {메뉴코드}-01-basic-design.md
├── {메뉴코드}-02-ui.md                     # SD_310_UI 생성
├── {메뉴코드}-02-wireframe.html            # SD_311 생성
├── {메뉴코드}-02-mock-data.js              # SD_311 생성
├── {메뉴코드}-03-data-model.md
├── {메뉴코드}-04-be-mapper-sql.md
├── {메뉴코드}-05-api.md
├── {메뉴코드}-06-be-flow.md
├── {메뉴코드}-07-fe-flow.md
└── {메뉴코드}-99-issues.md
```

### 파일 역할

| 파일 | 역할 |
|---|---|
| `50-prototype/index.html` | 좌측 메뉴 트리, 탭 바, 콘텐츠 iframe. 메뉴 클릭 시 `loadContent('../30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-wireframe.html')` 호출 |
| `50-prototype/10-common/left-menu.html` | `index.html`과 동일 파일. `10-common/` 경로에서 직접 접근할 때 사용 |
| `50-prototype/10-common/CPCT01_popup.html` | 거래처 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `50-prototype/10-common/CPPD01_popup.html` | 품목 검색 팝업. `postMessage` 방식으로 부모와 통신 |
| `50-prototype/10-common/icon-preview.html` | 툴바 버튼에 사용할 수 있는 SVG 아이콘 목록. **이 파일에 없는 아이콘은 사용 금지** |
| `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-ui.md` | 화면요건정리 문서. `/SD_310_UI {메뉴코드}` 명령어의 입력 소스 |
| `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-wireframe.html` | 완성된 프로토타입. `50-prototype/index.html`의 iframe 안에서 로드됨 |
| `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-02-mock-data.js` | 테스트 데이터. `const {MENUCODE}_DATA = {...}` 형태로 선언. HTML에서 `<script src>` 로 로드 |

### 팝업 통신 방식

메뉴 화면(iframe) → 부모(`index.html`) → 팝업 iframe 순서로 `postMessage`로 통신한다.

```
{메뉴코드}-02-wireframe.html  →  window.parent.postMessage({ type: 'OPEN_CP_LAYER' })
index.html                    →  CPCT01_popup.html 오픈
CPCT01_popup                  →  postMessage({ type: 'CP_SELECTED', data: {...} })
index.html                    →  {메뉴코드}-02-wireframe.html 로 결과 전달
```

## Slash Commands

모든 명령은 `/명령어 {메뉴코드}` 형식으로 실행한다.

### 화면설계 산출물

| 명령어 | 설명 |
|---|---|
| `/SD_310_UI {메뉴코드}` | 대화형 인터뷰로 `{메뉴코드}-02-ui.md` 작성 |
| `/SD_311 {메뉴코드}` | `{메뉴코드}-02-ui.md` 를 읽어 `-02-wireframe.html` + `-02-mock-data.js` 생성, 메뉴 자동 등록 |
| `/SD_312 {메뉴코드}` | `{메뉴코드}-02-ui.md` 를 읽어 PDA 모바일 wireframe HTML 생성 |

### 지식베이스 · 산출물

> DB/API 설계 정본 체계:
> - 메뉴별 KB 문서 작성·갱신의 정본 명령은 `/SD-db`, `/SD-api` 이다.
> - `/SD-db` 는 `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-03-data-model.md` 작성용이다.
> - `/SD-api` 는 `30-domain/30-wms-business/{메뉴코드}/{메뉴코드}-05-api.md` 작성용이다.
> - `/SD-db-apply` 는 `/SD-db` 결과 DDL을 DB에 반영할 때만 사용한다.
> - `/SD_331` ~ `/SD_334` 는 실DB 접속 기반의 추출·생성형 산출물 명령이며, 메뉴 KB 설계 문서의 정본을 대체하지 않는다.

| 명령어 | 설명 |
|---|---|
| `/RA_222 {메뉴코드}` | 분석 산출물 생성 |
| `/SD-db {메뉴코드}` | 화면설계 기반 DB 변경사항 도출 + db.md(DDL SQL 포함) 작성 |
| `/SD-db-apply {메뉴코드}` | db.md의 DDL을 psql로 test/dev DB에 반영 |
| `/SD-api {메뉴코드}` | 화면설계·DB 기반 api.md(API 설계+기능명세) 작성 |
| `/SD_331 {메뉴코드}` | DB 설계 산출물 생성 |
| `/SD_332 {메뉴코드}` | DB 설계 산출물 갱신 |
| `/SD_333 {메뉴코드}` | API 명세 산출물 생성 |
| `/SD_334 {메뉴코드}` | API 명세 산출물 갱신 |
| `/PI_411 {메뉴코드}` | 구현 산출물 생성 |
| `/PI_412 {메뉴코드}` | 구현 산출물 갱신 |
| `/PI_421 {메뉴코드}` | 단위테스트 보고서 생성 |
| `/PI_422 {메뉴코드}` | 통합테스트 보고서 엑셀 생성 |
| `/TT_541 {메뉴코드}` | 이행 산출물 생성 |
| `/TT_542 {메뉴코드}` | 이행 산출물 갱신 |
| `/TT_543 {메뉴코드}` | 이행 검증 |
| `/TT_550 {메뉴코드}` | DB 이관 스크립트 생성 |
| `/TT_551 {메뉴코드}` | DB 이관 스크립트 실행 |

### BE 개발 (cloud-wms-be 에서 실행)

| 명령어 | 설명 |
|---|---|
| `/PI-be-all {메뉴코드}` | BE 전체 레이어 일괄 구현 |
| `/PI-be-comp {메뉴코드}` | BE Component 레이어 구현 |
| `/PI-be-dao {메뉴코드}` | BE DAO 레이어 구현 |
| `/PI-be-mapper {메뉴코드}` | BE Mapper XML 구현 |
| `/PI-be-excel {메뉴코드}` | BE 엑셀 기능 구현 |
| `/PI-be-inven {메뉴코드}` | BE 재고처리 구현 |
| `/PI-test-be {메뉴코드}` | BE 단위테스트 실행 |

### FE 개발 (cloud-wms-fe 에서 실행)

| 명령어 | 설명 |
|---|---|
| `/PI-fe-all {메뉴코드}` | FE 전체 메뉴 일괄 구현 |
| `/PI-fe-list {메뉴코드}` | FE 목록 화면 구현 |
| `/PI-fe-edit {메뉴코드}` | FE 등록/수정 화면 구현 |
| `/playwright-spec {메뉴코드}` | Playwright E2E 스펙 파일 생성 |
| `/e2e-menu-test {메뉴코드}` | FE 메뉴 E2E 테스트 실행 |
| `/PI-test-fe {메뉴코드}` | FE E2E 테스트 실행 |

> 참고: `/playwright-spec`, `/e2e-menu-test` 와 `playwright-spec-writer` 에이전트는 이 레포(`cloud-wms-doc`)의 `.claude/skills/` 가 아니라 **FE 레포 `cloud-wms-fe/.claude/skills/` · `cloud-wms-fe/.claude/agents/`** 에 정의되어 있다. FE 개발 명령은 `cloud-wms-fe` 에서 실행되므로 진입점도 해당 레포에 있다.

### 공통 · 배포

| 명령어 | 설명 |
|---|---|
| `/PI_issue_mod` | 이슈 수정 산출물 반영 |
| `/PI_time_reg` | 공수 등록 |
| `/deploy {메뉴코드}` | 해당 메뉴 프로토타입을 FTP 서버에 업로드 |
| `/deploy` | 변경된 메뉴 감지 후 FTP 배포 (전체 또는 선택) |

## UI 규칙

프로토타입 HTML 작성 규칙은 `.claude/rules/`에 정의되어 있으며 자동으로 적용된다.
