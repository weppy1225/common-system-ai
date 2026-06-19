---
name: KB_100
description: 【지식베이스 자동 생성】 메뉴코드를 입력받아 cloud-wms-be(Java) + cloud-wms-fe(Vue) 소스를 분석하고 spec/{메뉴코드}/ 에 01~07 + 99 총 8개 문서를 자동 생성한다. /KB_100 {메뉴코드} 형식으로 실행. 기존 문서가 있으면 bakup{YYMMDD}{순번} 폴더로 백업 후 새로 생성한다. 사용자가 "지식베이스 만들어줘", "KB 문서 생성", "소스 분석 문서 뽑아줘", "KB_100 실행해줘" 라고 말해도 이 스킬을 사용한다.
allowed-tools: PowerShell, Read, Agent
---

# 지식베이스 자동 생성 [KB_100]

메뉴코드: **$ARGUMENTS**

> **용도·정책**: 설계 문서가 없는 **레거시 메뉴**의 BE/FE 소스를 역공학하여 `spec/{메뉴코드}/` 에 **초안(status: draft)** 을 생성한다. 사람이 검토 후 status를 올린다(SD 명령으로 재작성하면 그게 정본). **`{메뉴코드}-00-domain.md`(업무지식)는 사람 전용 — 생성하지도 덮어쓰지도 않는다.** 기존 문서가 있으면 백업 후 재생성하되 `00-domain`은 백업에서 제외(보존)한다.

---

## 실행 구조

```
메인 세션  : 메뉴 조회 → 경로 계산 → 백업
서브에이전트: 소스 파일 전체 읽기 → 8개 문서 생성·Write
```

메인 세션에서 소스 파일을 직접 읽지 않는다.
3단계까지 처리 후 Agent 도구로 서브에이전트를 실행하고 위임한다.

---

## 1단계 — 메뉴 정보 조회 [메인 세션]

`knowledgebase/15-menu-list.md` 를 Read 한다.
`$ARGUMENTS` (대소문자 무관) 에 해당하는 행을 찾아 아래 값을 추출한다.

| 변수 | 추출 방법 | 예시 |
|---|---|---|
| `MENU_CODE` | 메뉴코드 소문자 | `mdbz01` |
| `MENU_NM` | 메뉴명 | `사업장` |
| `GROUP_CODE` | 상위코드 소문자 | `md8000` |
| `GROUP_NM` | 상위메뉴명 | `기준정보` |
| `DOMAIN` | 아래 표 변환 | `master` |

**DOMAIN 변환:**

| 상위코드 패턴 | domain |
|---|---|
| MD* | master |
| SM*, MM* | system |
| IW* | inbound |
| RT* | return |
| IV* | inventory |
| DL* | outbound |
| IF* | interface |
| 기타 | common |

메뉴코드 조회 실패 시: `15-menu-list.md 에서 {ARGUMENTS} 를 찾을 수 없습니다` 출력 후 종료.

---

## 2단계 — 소스 경로 결정 [메인 세션]

PowerShell로 워크스페이스 루트를 계산한다.

```powershell
$DocRoot    = git rev-parse --show-toplevel
$Workspace  = Split-Path $DocRoot -Parent
# 형제 레포는 허브 폴더명에서 역할 접미사만 떼어 도출 (→ .claude/rules/repo-paths.md)
$Prefix     = (Split-Path $DocRoot -Leaf) -replace '-[^-]+$',''   # 허브 폴더명에서 끝의 역할 토큰(-ai 등) 제거 → 프로젝트 접두어
$BeDir      = Join-Path $Workspace "$Prefix-be"
if (-not (Test-Path $BeDir)) { $BeDir = (Get-ChildItem $Workspace -Directory -Filter '*-be' | Select-Object -First 1).FullName }
$FeDir      = Join-Path $Workspace "$Prefix-fe"
if (-not (Test-Path $FeDir)) { $FeDir = (Get-ChildItem $Workspace -Directory -Filter '*-fe' | Select-Object -First 1).FullName }
$BePath     = "$BeDir\src\main\java\be\$GROUP_CODE\$MENU_CODE"
$FePath     = "$FeDir\src\views\be\$GROUP_CODE\$MENU_CODE"
$OutPath    = "spec\$MENU_CODE"
$MenuUpper  = $MENU_CODE.ToUpper()   # 예: MDBZ01
$Today      = Get-Date -Format "yyyy-MM-dd"
```

BE 경로와 FE 경로 존재 여부를 확인한다.
없는 경로는 경고 출력 후 해당 경로 관련 문서는 "소스 없음" 으로 기재하고 계속한다.

---

## 3단계 — 기존 문서 백업 [메인 세션]

`$OutPath` 에 `.md` 파일이 1개 이상 있으면 PowerShell로 백업한다.

```powershell
$yymmdd = Get-Date -Format "yyMMdd"
$seq = 1
do { $bkName = "bakup${yymmdd}$($seq.ToString('D2'))"; $seq++ }
while (Test-Path "$OutPath\$bkName")
New-Item -ItemType Directory -Path "$OutPath\$bkName" -Force | Out-Null
Get-ChildItem -Path $OutPath -Filter "*.md" | Where-Object { $_.Name -notlike "*-00-domain.md" } | Move-Item -Destination "$OutPath\$bkName"
Write-Host "백업 완료: $bkName"
```

`$OutPath` 폴더 자체가 없으면 생성한다.

```powershell
New-Item -ItemType Directory -Path $OutPath -Force | Out-Null
```

---

## 4단계 — 서브에이전트 실행 [Agent 도구 호출]

아래 형식으로 Agent 도구를 호출한다.
`{MENU_CODE}`, `{MENU_NM}`, `{GROUP_CODE}`, `{GROUP_NM}`, `{DOMAIN}`, `{BePath}`, `{FePath}`, `{OutPath}`, `{MenuUpper}`, `{Today}` 는 1~3단계에서 계산한 실제 값으로 치환한다.

```
Agent(
  description: "KB 문서 생성 — {MenuUpper} {MENU_NM}",
  prompt: """
[서브에이전트 지침 — KB 문서 생성]

너는 WMS 소스코드 분석 전문 에이전트다.
아래 소스 파일들을 모두 읽은 뒤 8개 지식베이스 문서를 순서대로 생성하고 Write 한다.

━━━━━━━━━━━━━━━━━━━━━━━━━━
기본 정보
━━━━━━━━━━━━━━━━━━━━━━━━━━
MENU_CODE  : {MENU_CODE}
MENU_UPPER : {MenuUpper}
MENU_NM    : {MENU_NM}
GROUP_CODE : {GROUP_CODE}
GROUP_NM   : {GROUP_NM}
DOMAIN     : {DOMAIN}
TODAY      : {Today}
OUT_PATH   : {OutPath}

━━━━━━━━━━━━━━━━━━━━━━━━━━
소스 파일 목록 (전부 읽을 것)
━━━━━━━━━━━━━━━━━━━━━━━━━━

[BE — Java]
{BePath}\{MenuUpper}Controller.java
{BePath}\{MenuUpper}Comp.java
{BePath}\{MenuUpper}TxComp.java
{BePath}\{MenuUpper}Dao.java
{BePath}\{MenuUpper}Mapper.java
{BePath}\{MenuUpper}Mapper.xml        ← MyBatis XML, 핵심 소스
{BePath}\{MenuUpper}CompUtil.java     ← 없으면 건너뜀
{BePath}\bean\*.java                  ← Glob으로 전체

[FE — Vue]
{FePath}\*.vue                        ← Glob으로 전체

없는 파일은 건너뛰고 진행한다.

━━━━━━━━━━━━━━━━━━━━━━━━━━
생성할 문서 (순서대로)
━━━━━━━━━━━━━━━━━━━━━━━━━━

각 문서는 생성 즉시 Write 한다. 모아두지 않는다.
모든 파일 경로: {OutPath}\{MENU_CODE}-NN-xxx.md

──────────────────────────
■ 01 {OutPath}\{MENU_CODE}-01-basic-design.md
──────────────────────────
분석 대상: Comp + TxComp + Mapper.xml(SQL 로직) + Vue(화면 흐름)
목적: 비개발자도 이해할 수 있는 업무 관점 설계서.
      개발 착수 전에도 작성 가능한 순수 업무 언어로만 기술한다.
      "누가·무엇을·왜·어떤 순서로" 만 기술.

❌ 절대 포함 금지 항목 (소스에서 발견해도 문서에 그대로 옮기지 않는다):

| 금지 유형 | 금지 예시 |
|---|---|
| DB 테이블명 | MDM_WH, TB_WH_GROUP, MDM_BIZ_WH |
| DB 컬럼명 | wh_group_cd, use_yn, cfm_yn, tpl_yn |
| 공통코드 값 | WH_GROUP_CD, OWN, TPL, SHIPPER |
| API 경로 | /mdbz01/bizs, PUT /centers, GET /list |
| Java 클래스·메서드명 | MDWH01Comp, saveBizCenter, @Transactional |
| Vue 함수명 | vfn_saveCenter, onMounted, emit |
| 기술 용어 | SQL, REST, Vue, MyBatis, JOIN, WHERE |

✅ 소스의 기술 구현을 업무 언어로 번역한다:
  - `use_yn = 'N'` → "사용 중지 상태"
  - `cfm_yn = 'Y' AND use_yn = 'Y'` → "승인 완료 상태"
  - `authTypeCd = 'ADMIN'` → "관리자 권한 사용자"
  - `DELETE FROM ...` → "데이터 삭제" (단, 규칙 위반은 99-issues에 등록)

섹션 구성:
  1. 업무 정의 (1~3문단)
  2. 관리 대상 정보 (표)
  3. 업무 참여자/역할
  4. 업무 흐름 전체 (ASCII 다이어그램)
  5. 세부 업무 시나리오 (케이스별: 등록/수정/삭제/상태변경 등)
  6. 상태 흐름 (상태 컬럼 있으면: ASCII + 상태 표)
  7. 핵심 업무 규칙 BR-1, BR-2... (Comp/TxComp 검증 로직에서 도출, 업무 언어로 기술)
  8. 권한별 업무 범위 (권한 분기 있으면, 기술 구현 아닌 업무 범위로 기술)
  9. 한 줄 요약 (> 인용문)

프런트매터:
---
title: {MenuUpper} 기본설계 — {MENU_NM}
description: {MENU_CODE} 메뉴의 업무 정의·관리대상·참여자·업무흐름·상태변화·업무규칙을 기술하는 업무 관점 기본설계서.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
last_updated: "{Today}"
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-02-ui.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-03-data-model.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-06-be-flow.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-07-fe-flow.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-99-issues.md"
tags: [basic-design, business, {DOMAIN}]
---

──────────────────────────
■ 02 {OutPath}\{MENU_CODE}-02-ui.md
──────────────────────────
분석 대상: Vue 파일 전체 <template> 블록
목적: 화면이 어떤 기능을 제공하고 레이아웃이 어떻게 구성되는지 기술.
      구현 기술과 무관하게 "어떤 항목이 있고, 어떤 입력 방식이고, 어떤 제약이 있는지"만 기술.

❌ 절대 포함 금지 항목 (소스에서 발견해도 문서에 그대로 옮기지 않는다):

| 금지 유형 | 금지 예시 |
|---|---|
| Vue 파일명 | mdwh01.vue, mdwh01Edt.vue |
| 컴포넌트명 | ZSelect, ZAuiGrid, ZCodeMulti, ZText, ZRadio, ZBtn, LayerPopup |
| 필드명/바인딩 | searchWhObj.centerSeq, editWhObj.whGroupCd, v-model, v-if |
| 그리드 옵션 | enableFilter, showRowCheckColumn, softRemoveRowMode, dataField |
| 이벤트 핸들러 | cellClick, lfn_whGridCellClickHandler, selectionChange |
| Vue 기술 용어 | emit, ref, watch, onMounted, TemplateRenderer |
| minWidth / 퍼센트 너비 | minWidth: 90px, width: 10% |

✅ 기술 구현을 UI 기능 언어로 번역한다:
  - `ZSelect` → "드롭다운 선택"
  - `ZCodeMulti` → "다중 선택"
  - `ZText` → "텍스트 입력"
  - `ZRadio` → "라디오 버튼 선택"
  - `enableFilter: true` → "(컬럼 필터 지원)"
  - `visible: false` → "(목록에 미표시, 내부 처리용)"
  - `emit('vfn_searchWh')` → "저장 완료 후 목록 자동 갱신"
  - `v-if="isUpdate"` → "(수정 모드에서만 표시)"

섹션 구성:
  1. 화면 목록 (화면명 / 화면코드 / 형태 / 설명 표)
     - 파일명 제외, 화면코드만 기재
     - 팝업 코드 규칙: {MenuUpper}P01, P02 ... 순번 채번
  2. 메인 화면
     2-1. 전체 레이아웃 (ASCII 다이어그램 — 영역 구성만, 컴포넌트명 제외)
     2-2. 검색 조건 (순번 / 항목명 / 입력유형 / 필수 / 비고 표)
          입력유형: 드롭다운 / 다중선택 / 텍스트 입력 / 날짜 선택 등 기능 설명으로 기술
     2-3. 목록 컬럼 (컬럼명 / 정렬 / 비고 표)
          - 필드명, minWidth, 그리드 옵션 제외
          - "(내부 처리용, 목록 미표시)" 형태로만 표기
  3. 팝업별 섹션 (있는 것만)
     3-1. 폼 항목 (순번 / 항목명 / 입력유형 / 필수 / 등록 가능 / 수정 가능 / 비고 표)
          - 컴포넌트명, 필드명 제외
          - 활성/비활성 조건은 업무 언어로 기술 (예: "등록 후 변경 불가")
     3-2. 버튼 목록 (버튼명 / 조건 / 동작 설명)
  4. 화면 간 연동 요약
     - 기술 구현 제외, 사용자 액션과 결과만 기술
     - 예: "[추가] 클릭 → 창고 등록 팝업 오픈"
     - 예: "저장 완료 → 목록 자동 갱신"

프런트매터:
---
title: {MenuUpper} 화면 구조 (UI 명세)
description: {MENU_CODE} {MENU_NM}의 화면 기능·레이아웃 명세. 화면 구성 영역, 검색 조건, 목록 컬럼, 팝업 항목을 구현 기술 없이 기술.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "spec/{MENU_CODE}/{MENU_CODE}-01-basic-design.md"
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-07-fe-flow.md"
tags: [detail-design, screen, ui, {DOMAIN}]
---

──────────────────────────
■ 03 {OutPath}\{MENU_CODE}-03-data-model.md
──────────────────────────
분석 대상: Mapper.xml(FROM/JOIN 절) + bean/*.java(필드명)
목적: 테이블·관계·상태값 설계 해석.

섹션 구성:
  1. 물리 테이블 목록 (업무개념/물리테이블명/비고 표)
     Mapper.xml 모든 FROM + JOIN 에서 추출. 각 테이블이 업무적으로 어떤 역할을 하는지 한 줄로 설명한다.
  2. 상태값 / 코드 규칙
     CASE 문, WHERE 조건에서 상태머신 도출
     코드 컬럼별 값 목록 표 (코드값 / 의미 / 비고)
     상태 전이가 있으면 ASCII 다이어그램으로 표현

프런트매터:
---
title: {MenuUpper} 데이터 모델 (테이블·관계·상태값)
description: {MENU_CODE} {MENU_NM} 업무의 물리 테이블 매핑, 테이블 간 관계 의미, 상태값/코드 규칙을 설계 해석 수준으로 기술.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "spec/{MENU_CODE}/{MENU_CODE}-01-basic-design.md"
  - "patterns/_common-arch/tech-stack.md"
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-04-be-mapper-sql.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
tags: [detail-design, data-model, {DOMAIN}]
---

──────────────────────────
■ 04 {OutPath}\{MENU_CODE}-04-be-mapper-sql.md
──────────────────────────
분석 대상: {MenuUpper}Mapper.xml
목적: 화면의 버튼·기능 단위로 어떤 SQL이 실행되는지 목록을 정의한다.
      상세 SQL 구현은 소스(Mapper.xml)에 있으므로 여기서는 목록만 관리한다.
      02-ui의 화면·버튼 구성과 03-data-model의 테이블 목록을 기준으로 작성한다.

섹션 구성:
  SQL 목록 표 (화면 / 기능·버튼 / SQL명 / 유형)
  - 화면: 02-ui 기준 화면명 (예: 메인, 사업장 등록 팝업)
  - 기능·버튼: 해당 SQL을 호출하는 버튼 또는 기능명 (예: 조회, 저장, 삭제)
  - SQL명: Mapper statement ID 그대로
  - 유형: SELECT / INSERT / UPDATE / DELETE
  - 하나의 버튼이 여러 SQL을 호출하면 행을 나눠 각각 기재한다

프런트매터:
---
title: {MenuUpper} SQL 목록
description: {MENU_CODE} {MENU_NM}에서 사용하는 SQL statement 목록. 상세 구현은 Mapper.xml 참조.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "spec/{MENU_CODE}/{MENU_CODE}-03-data-model.md"
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-06-be-flow.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
tags: [detail-design, backend, sql, {DOMAIN}]
---

──────────────────────────
■ 05 {OutPath}\{MENU_CODE}-05-api.md
──────────────────────────
분석 대상: {MenuUpper}Controller.java + Vue 파일(zAxios 호출 대조)
목적: FE·BE 공용 REST API 계약 문서.

섹션 구성:
  1. Base 경로 (Controller @RequestMapping 에서 추출)
  2. 엔드포인트 목록 (검증됨 — Vue 호출과 대조)
     업무 / HTTP / URL(서버 기준) / 호출 화면 / 요청·응답 비고 표
     FE zAxios 인터셉터 prefix 처리 주석 포함
  3. 레거시/미사용 엔드포인트 (삭제 말고 확인 안내)
  4. 주요 요청/응답 필드 (bean/*.java 에서 도출, 필드/설명/비고 표)
  5. 설계 포인트 (같은 URL을 메서드로 구분하거나 이름 유사 다른 기능 경고)

프런트매터:
---
title: {MenuUpper} API 명세 (FE·BE 공용)
description: {MENU_CODE} {MENU_NM}의 REST API 명세. FE/BE가 함께 참조하는 단일 계약 문서.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "spec/{MENU_CODE}/{MENU_CODE}-02-ui.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-03-data-model.md"
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-06-be-flow.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-07-fe-flow.md"
tags: [detail-design, api, {DOMAIN}]
---

──────────────────────────
■ 06 {OutPath}\{MENU_CODE}-06-be-flow.md
──────────────────────────
분석 대상: Comp.java + TxComp.java + CompUtil.java
목적: 서버에서 각 업무를 컴포넌트 간 상호작용 흐름으로 시각화한다.
      소스 코드를 복사하지 않는다. 흐름과 판단 포인트만 다이어그램으로 표현한다.

섹션 구성:
  1. API별 시퀀스 다이어그램 — 05-api 엔드포인트 목록 기준으로 API마다 아래 형식으로 기술
     Vue 미호출(미연결) API는 🟠 표시
     ─────────────────────────
     ### {HTTP메서드} {경로} — {API 용도 한 줄}

     ```
     Controller      Comp              TxComp          Dao
          │               │                  │              │
          │─ 메서드() ────>│                  │              │
          │               │─ 검증 ──────────────────────────X  [실패→예외]
          │               │─ 조회() ──────────────────────────>│
          │               │<──────────────────────────────── │
          │               │─ 메서드TX() ────>│                │
          │               │                 │─ DML() ────────>│
          │               │                 │<────────────────│
          │<──────────────│                 │                │
     ```

     규칙:
     - 참여자(Actor)는 실제 클래스명 사용 (Controller, Comp, TxComp, Dao)
     - 분기/판단은 다이어그램 안에 `[조건 설명]` 으로 표기
       예: `[이미지 있으면]`, `[ACCEPT 상태면 → 예외]`
     - 소스 코드(변수명, 구현 상세)를 그대로 쓰지 않는다
     - 루프(반복)는 `loop [N건 반복]` 표기

     예시 패턴:
     ```
     Controller      Comp            TxComp          Dao
          │               │                │              │
          │─ 수정() ──────>│                │              │
          │               │─ 기존 조회 ────────────────────>│
          │               │<────────────────────────────── │
          │               │─ 저장TX() ─────>│              │
          │               │                │─ DML() ──────>│
          │               │                │<──────────────│
          │<──────────────│                │              │
     ```
     ─────────────────────────

  2. 예외 처리 목록
     - `patterns/_common-arch/be-exceptions.md` 의 공통 예외는 기재하지 않는다
     - 이 메뉴 고유의 업무 예외만 기재한다 (조건 / 결과 표)
     - 소스의 예외 클래스명이 아니라 "어떤 상황에서 무슨 결과가 나오는지" 위주로 기술
     - 예: "이미 승인된 입고예정에 재승인 요청 → 중복 처리 오류 반환"
     - 공통과 겹치는 예외는 생략한다. 없으면 "공통 예외 외 메뉴 고유 예외 없음" 으로 기재

  3. 기술 이슈 (물리DELETE / N+1 / 중복조회 / 미사용코드)
     - 이슈 제목 + 한 단락 설명
     - 코드 인용 없이 현상과 영향만 기술

프런트매터:
---
title: {MenuUpper} BE 구현 흐름 (서버 처리)
description: {MENU_CODE} {MENU_NM}의 백엔드 컴포넌트 흐름. Controller-Comp-TxComp-Dao 간 시퀀스 다이어그램과 예외·이슈를 기술.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "patterns/_common-arch/be-architecture.md"
  - "patterns/_common-arch/be-exceptions.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-04-be-mapper-sql.md"
tags: [detail-design, backend, sequence, {DOMAIN}]
---

──────────────────────────
■ 07 {OutPath}\{MENU_CODE}-07-fe-flow.md
──────────────────────────
분석 대상: Vue 파일 전체 <script> 블록
목적: 화면에서 각 업무를 함수 호출 흐름으로 시각화한다.
      소스 코드를 복사하지 않는다. 함수 간 호출 흐름과 API 연동 포인트만 다이어그램으로 표현한다.

섹션 구성:
  1. 파일 구성 (Vue파일명 / 화면형태 / 역할 표) — 이 메뉴 고유. 공통 패턴은 patterns/_common-arch/fe-architecture.md 참조

  2. API별 시퀀스 다이어그램 — 05-api 엔드포인트 목록 기준으로 API마다 아래 형식으로 기술
     Vue 미호출(미연결) API는 🟠 표시
     ─────────────────────────
     ### {HTTP메서드} {경로} — {API 용도 한 줄}

     ```
     메인화면              팝업                API
       │                    │                  │
       │─ vfn_xxx() ──────────────────────────────
       │─ 조건 수집 / 검증
       │─ POST {경로} ────────────────────────────>│
       │<─────────────────────────────────────────│
       │─ 그리드 갱신
     ```
     ─────────────────────────

     규칙:
     - 참여자(Actor)는 Vue 파일 단위로 구분 (공통 패턴은 patterns/_common-arch/fe-architecture.md 참조)
     - 함수명은 소스 코드 그대로 사용 (vfn_xxx, lfn_xxx, onMounted 등)
     - API 호출은 HTTP 메서드 + 경로 명시 (예: POST /mdwh01/whs)
     - 팝업 연동은 열기/닫기/콜백(emit) 흐름 포함
     - 루프는 `loop [N건 반복]` 표기

  3. 메뉴 고유 구현 포인트
     - patterns/_common-arch/fe-architecture.md 의 공통 패턴과 다른 부분만 기재
     - 예: 특수한 그리드 편집 방식, 비표준 팝업 연동, 특이한 상태 초기화 로직 등
     - 없으면 "공통 패턴 외 특이사항 없음" 으로 기재

프런트매터:
---
title: {MenuUpper} FE 구현 흐름 (화면 처리)
description: {MENU_CODE} {MENU_NM}의 프론트엔드 구현 흐름. 파일 구성, 업무별 함수 호출 시퀀스 다이어그램, 구현 포인트를 기술.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: spec
menu_code: {MENU_CODE}
domain: {DOMAIN}
depends_on:
  - "patterns/_common-arch/fe-architecture.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-02-ui.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
tags: [detail-design, frontend, vue, {DOMAIN}]
---

──────────────────────────
■ 08 {OutPath}\{MENU_CODE}-99-issues.md
──────────────────────────
분석 대상: 01~07 문서 + 소스 교차 분석
목적: 개발 착수 전 확인·결정 필요 항목 레지스터.

이슈 발굴 체크리스트:
  🔴 기능 공백:
    - Controller 에 있으나 어떤 Vue 도 호출 안 하는 엔드포인트
    - 화면에 버튼 없거나 import 안 된 팝업 (ref 선언만 있고 미사용)
    - 상태 전이가 불가능한 상태 (도달 경로 없는 상태값)
  🟠 정책/정합:
    - DELETE FROM 직접 사용 (소프트삭제 원칙 상충)
    - 상태머신 도달성 문제
    - BE 검증 조건과 업무규칙 문구 불일치
  🟡 정리/개선:
    - Mapper.xml 에 있으나 Dao 호출자 없는 statement (Dead SQL)
    - for 루프 내 단건 DML 반복 (N+1)
    - 동일 쿼리 2회 이상 호출
    - FE 존재하지 않는 함수 호출
    - 같은 규칙을 다른 위치에서 다르게 표현 (문구 드리프트)

섹션 구성:
  ## 요약  (# / 우선 / 이슈 / 근거 표)
  ## 🔴 기능 공백  (현상 / 파급 / 확인 필요 항목)
  ## 🟠 정책 / 정합  (같은 구조)
  ## 🟡 정리 / 개선  (같은 구조)
  > 본 레지스터는 소스를 수정하지 않는다.  ← 고정 문구

프런트매터:
---
title: {MenuUpper} Open Issues / 확인 필요 사항
description: {MENU_CODE} {MENU_NM} 설계 문서화 과정에서 식별된 소스-문서 불일치·미연결 기능·정리 후보를 모은 확인/조치 레지스터.
status: draft
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: task
menu_code: {MENU_CODE}
domain: {DOMAIN}
related:
  - "spec/{MENU_CODE}/{MENU_CODE}-05-api.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-04-be-mapper-sql.md"
  - "spec/{MENU_CODE}/{MENU_CODE}-06-be-flow.md"
tags: [open-issues, verification, {DOMAIN}]
---

━━━━━━━━━━━━━━━━━━━━━━━━━━
공통 주의사항
━━━━━━━━━━━━━━━━━━━━━━━━━━
- 소스에 없는 내용은 추측하지 않는다. 확인 안 된 사항은 ⚠️ 표시 후 99-issues 에 등록.
- SQL 은 Mapper.xml 원문을 가능한 그대로 인용한다 (```sql 블록).
- 함수명·메서드명·필드명은 소스 코드 그대로 사용한다.
- 각 문서 생성 즉시 Write 한다.
  """
)
```

---

## 5단계 — 완료 보고 [메인 세션]

서브에이전트 완료 후 `knowledgebase/15-menu-list.md` 의 해당 행 상태를 `완료`로 갱신한다.

```powershell
$menuListPath = "knowledgebase\15-menu-list.md"
(Get-Content $menuListPath -Encoding utf8) | ForEach-Object {
    if ($_ -match "\|\s*$MenuUpper\s*\|") {
        $_ -replace '\|\s*-\s*\|\s*$', '| 완료 |'
    } else { $_ }
} | Set-Content $menuListPath -Encoding utf8
```

갱신 후 아래 형식으로 보고한다.

```
✅ KB_100 완료: {MenuUpper} ({MENU_NM})
  📁 spec/{MENU_CODE}/
     ├── {MENU_CODE}-01-basic-design.md
     ├── {MENU_CODE}-02-ui.md
     ├── {MENU_CODE}-03-data-model.md
     ├── {MENU_CODE}-04-be-mapper-sql.md
     ├── {MENU_CODE}-05-api.md
     ├── {MENU_CODE}-06-be-flow.md
     ├── {MENU_CODE}-07-fe-flow.md
     └── {MENU_CODE}-99-issues.md
  🗂️ 백업: {bkName}  (백업 없으면 이 줄 생략)
  ⚠️ 이슈 N건 발견 → 99-issues.md 참조
```
