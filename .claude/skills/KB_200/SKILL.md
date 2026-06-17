---
name: KB_200
description: 【지식베이스 검증】 메뉴코드를 입력받아 7개 KB 문서와 실제 BE/FE 소스를 비교 분석하여 일치율·누락·과잉 항목을 리포트한다. 역공학 품질 검증 및 개발 완료 후 문서 동기화 확인에 사용한다. /KB_200 {메뉴코드} 형식으로 실행. 사용자가 "지식베이스 검증", "KB 검증", "문서 일치율 확인", "역공학 검증", "KB_200 실행해줘" 라고 말해도 이 스킬을 사용한다.
allowed-tools: PowerShell, Read, Write, Agent
disable-model-invocation: true
---

> ⚠ **재설계 대상 (동결)**: 폴더 재설계(STRUCTURE-TARGET.md)로 `70-knowledgebase/`는 폐지됐다. 검증 대상을 `spec/{메뉴코드}/` ↔ 라이브 소스 비교로 재설계하기 전까지 자동 호출을 차단한다. → MIGRATION-PLAN.md Phase F 이후 별도 작업.

# 지식베이스 검증 [KB_200]

메뉴코드: **$ARGUMENTS**

---

## 개요

7개 KB 문서에서 구조화된 요소를 추출하고, 실제 BE/FE 소스에서 동일 요소를 추출하여
두 집합을 비교한다. 생성(역공학)과 개발 완료 후 동기화 확인 양쪽에서 사용한다.

```
KB 문서 7개  →  추출: API·SQL·업무규칙·화면요소
실제 소스    →  추출: API·SQL·업무규칙·화면요소
                  ↓
            교차 비교 → 검증 리포트 생성
```

---

## 1단계 — 메뉴 정보 조회 [메인 세션]

`70-knowledgebase/menu-list.md` 를 Read 한다.
`$ARGUMENTS`(대소문자 무관) 에 해당하는 행을 찾아 아래 값을 추출한다.

| 변수 | 추출 방법 | 예시 |
|---|---|---|
| `MENU_CODE` | 메뉴코드 소문자 | `mdbz01` |
| `MENU_NM` | 메뉴명 | `사업장` |
| `GROUP_CODE` | 상위코드 소문자 | `md8000` |

메뉴코드 조회 실패 시: `menu-list.md 에서 {ARGUMENTS} 를 찾을 수 없습니다` 출력 후 종료.

KB 문서 폴더(`70-knowledgebase/{MENU_CODE}/`)가 없거나 `.md` 파일이 0개이면:
`KB 문서가 없습니다. 먼저 /KB_100 {메뉴코드} 를 실행하세요.` 출력 후 종료.

---

## 2단계 — 경로 계산 [메인 세션]

```powershell
$DocRoot   = git rev-parse --show-toplevel
$Workspace = Split-Path $DocRoot -Parent
$BePath    = "$Workspace\cloud-wms-be\src\main\java\be\$GROUP_CODE\$MENU_CODE"
$FePath    = "$Workspace\cloud-wms-fe\src\views\be\$GROUP_CODE\$MENU_CODE"
$KbPath    = "70-knowledgebase\$MENU_CODE"
$MenuUpper = $MENU_CODE.ToUpper()
$Today     = Get-Date -Format "yyyy-MM-dd"
$ReportFile = "$KbPath\${MENU_CODE}-KB-verify-$(Get-Date -Format 'yyyyMMdd').md"
```

BE 경로와 FE 경로 존재 여부를 확인하고 결과를 기록한다.
없는 경로는 경고 출력 후 해당 영역은 "소스 없음"으로 처리하고 계속한다.

---

## 3단계 — 서브에이전트 실행 [Agent 도구 호출]

아래 형식으로 Agent 도구를 호출한다.
`{MENU_CODE}`, `{MenuUpper}`, `{MENU_NM}`, `{BePath}`, `{FePath}`, `{KbPath}`, `{ReportFile}`, `{Today}` 는
2단계에서 계산한 실제 값으로 치환한다.

```
Agent(
  description: "KB 검증 — {MenuUpper} {MENU_NM}",
  prompt: """
[서브에이전트 지침 — KB 검증]

너는 WMS 지식베이스 품질 검증 에이전트다.
아래 순서로 KB 문서와 실제 소스를 각각 읽고, 4개 차원에서 비교한 검증 리포트를 생성한다.

━━━━━━━━━━━━━━━━━━━━━━━━━━
기본 정보
━━━━━━━━━━━━━━━━━━━━━━━━━━
MENU_CODE  : {MENU_CODE}
MENU_UPPER : {MenuUpper}
MENU_NM    : {MENU_NM}
KB_PATH    : {KbPath}
BE_PATH    : {BePath}
FE_PATH    : {FePath}
REPORT_FILE: {ReportFile}
TODAY      : {Today}

━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1 — KB 문서 읽기
━━━━━━━━━━━━━━━━━━━━━━━━━━

아래 7개 파일을 모두 Read 한다. 없으면 건너뛴다.

{KbPath}\{MENU_CODE}-01-basic-design.md
{KbPath}\{MENU_CODE}-02-screen.md
{KbPath}\{MENU_CODE}-03-data-model.md
{KbPath}\{MENU_CODE}-04-be-mapper-sql.md
{KbPath}\{MENU_CODE}-05-api.md
{KbPath}\{MENU_CODE}-06-be-flow.md
{KbPath}\{MENU_CODE}-07-fe-flow.md

읽으면서 아래 요소를 추출한다.

[KB-API] 05-api.md → API 엔드포인트 목록
  추출 형식: HTTP메서드 + 경로 (예: GET /mdbz01/bizs)

[KB-SQL] 04-be-mapper-sql.md → SQL statement 목록
  추출 형식: SQL명(statement ID) + 유형(SELECT/INSERT/UPDATE/DELETE) + 업무 용도

[KB-RULE] 01-basic-design.md → 업무규칙(BR-N) 목록
  추출 형식: 규칙 번호 + 한 줄 설명

[KB-SCREEN] 02-screen.md → 화면 구성 요소
  추출 형식:
  - 검색 조건 항목 목록
  - 목록 그리드 컬럼 목록
  - 팝업별 폼 항목 목록
  - 버튼 목록

[KB-BE-FLOW] 06-be-flow.md → BE 업무 목록
  추출 형식: 업무명 + HTTP메서드

[KB-FE-FLOW] 07-fe-flow.md → FE 함수/업무 목록
  추출 형식: 업무명 + 관련 API 경로

━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2 — 실제 소스 읽기
━━━━━━━━━━━━━━━━━━━━━━━━━━

아래 파일들을 Read/Glob 한다. 없으면 건너뛴다.

[BE]
{BePath}\{MenuUpper}Controller.java    ← @RequestMapping, @GetMapping 등 어노테이션에서 API 추출
{BePath}\{MenuUpper}Mapper.xml         ← <select id="">, <insert id=""> 등 statement ID 추출
{BePath}\{MenuUpper}Comp.java          ← 업무 로직 메서드명, 검증 조건 추출
{BePath}\{MenuUpper}TxComp.java        ← 트랜잭션 메서드명 추출

[FE]
{FePath}\*.vue                         ← Glob으로 전체. template에서 폼항목·컬럼·버튼, script에서 함수명·API호출 추출

각 파일에서 추출:

[SRC-API] Controller.java → 실제 API 엔드포인트 목록
  추출 형식: HTTP메서드 + @RequestMapping 조합 경로

[SRC-SQL] Mapper.xml → 실제 SQL statement 목록
  추출 형식: statement ID + 태그명(select/insert/update/delete) + FROM/JOIN 테이블

[SRC-RULE] Comp.java + TxComp.java → 실제 검증/업무 로직
  추출 형식: 조건문 기반 업무 제약 목록 (업무 언어로 요약)

[SRC-SCREEN] Vue 파일 → 실제 화면 구성 요소
  추출 형식:
  - 검색 조건 바인딩 필드 목록 (v-model, searchObj 키)
  - 그리드 컬럼 목록 (dataField 또는 헤더 텍스트)
  - 팝업 폼 항목 목록
  - 버튼 목록 (텍스트 또는 @click 핸들러 기준)

━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3 — 4개 차원 비교
━━━━━━━━━━━━━━━━━━━━━━━━━━

아래 4개 차원에서 각각 비교한다.

──────────────────────────
차원 A. API 일치율
──────────────────────────
KB-API ↔ SRC-API 를 비교한다.
- 일치: KB와 소스 양쪽에 존재하는 엔드포인트
- 문서 누락(소스에 있으나 KB 문서에 없음): KB를 보완해야 함
- 문서 과잉(KB 문서에 있으나 소스에 없음): 소스 미구현 또는 문서 오류

일치율 = 일치 건수 / MAX(KB-API 건수, SRC-API 건수) × 100

──────────────────────────
차원 B. SQL 커버리지
──────────────────────────
KB-SQL ↔ SRC-SQL 를 비교한다.
- statement ID 기준으로 매핑
- 일치: 양쪽에 존재하는 statement
- 문서 누락: 소스에 있으나 KB에 없는 statement
- 문서 과잉: KB에 있으나 소스에 없는 statement

일치율 = 일치 건수 / MAX(KB-SQL 건수, SRC-SQL 건수) × 100

──────────────────────────
차원 C. 업무규칙 커버리지
──────────────────────────
KB-RULE ↔ SRC-RULE 를 비교한다.
- 소스에서 추출한 검증 로직이 KB 업무규칙에 반영되어 있는지 의미 기반으로 판단
- 완전 반영 / 부분 반영 / 누락 으로 분류
- 소스에 있으나 KB 규칙에 없는 제약은 "문서 누락 규칙"으로 기록

커버리지 = 완전반영 건수 / SRC-RULE 총 건수 × 100

──────────────────────────
차원 D. 화면 구성 일치율
──────────────────────────
KB-SCREEN ↔ SRC-SCREEN 을 비교한다.
- 검색 조건 항목, 그리드 컬럼, 팝업 폼 항목, 버튼을 각각 비교
- 항목명 기준으로 매핑 (한글명 또는 영문 필드명 대응 포함)
- 일치 / 문서 누락 / 문서 과잉 으로 분류

일치율 = 일치 항목 수 / MAX(KB 항목 수, SRC 항목 수) × 100

──────────────────────────
종합 일치율
──────────────────────────
종합 = (차원A + 차원B + 차원C + 차원D) / 4
등급:
  90% 이상  → ✅ 우수 (소스 생성에 활용 가능)
  70~89%    → 🟡 보통 (일부 보완 필요)
  70% 미만  → 🔴 미흡 (KB 문서 재검토 필요)

━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4 — 검증 리포트 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━

아래 구조로 리포트를 작성하고 {ReportFile} 에 Write 한다.

───────────────── 리포트 구조 ─────────────────

---
title: {MenuUpper} 지식베이스 검증 리포트
description: KB 문서와 실제 소스의 일치율·누락·과잉 항목을 비교 분석한 검증 리포트
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: output
menu_code: {MENU_CODE}
verified_at: "{Today}"
---

# {MenuUpper} 지식베이스 검증 리포트

> 검증일: {Today}

## 종합 결과

| 차원 | KB 항목 수 | 소스 항목 수 | 일치 수 | 일치율 |
|---|---|---|---|---|
| A. API | N | N | N | N% |
| B. SQL | N | N | N | N% |
| C. 업무규칙 | N | N | N | N% |
| D. 화면 구성 | N | N | N | N% |
| **종합** | | | | **N%** |

**등급: ✅/🟡/🔴 {등급 설명}**

---

## 차원 A — API 일치율 (N%)

### 일치 항목
| HTTP | 경로 | 비고 |
|---|---|---|

### 문서 누락 (소스에 있으나 KB에 없음) ← KB 보완 필요
| HTTP | 경로 | 소스 위치 |
|---|---|---|

### 문서 과잉 (KB에 있으나 소스에 없음) ← 소스 미구현 확인 필요
| HTTP | 경로 | KB 문서 |
|---|---|---|

---

## 차원 B — SQL 커버리지 (N%)

### 일치 항목
| Statement ID | 유형 | 비고 |
|---|---|---|

### 문서 누락 (소스에 있으나 KB에 없음)
| Statement ID | 유형 | 테이블 |
|---|---|---|

### 문서 과잉 (KB에 있으나 소스에 없음)
| Statement ID | 유형 | KB 문서 |
|---|---|---|

---

## 차원 C — 업무규칙 커버리지 (N%)

### 완전 반영
| 소스 로직 요약 | KB 규칙 번호 |
|---|---|

### 부분 반영
| 소스 로직 요약 | KB 규칙 번호 | 누락된 내용 |
|---|---|---|

### 문서 누락 (소스에 있으나 KB 규칙에 없음)
| 소스 로직 요약 | 발견 위치 | 권장 조치 |
|---|---|---|

---

## 차원 D — 화면 구성 일치율 (N%)

### 검색 조건 비교
| 항목명 | KB | 소스 | 상태 |
|---|---|---|---|

### 그리드 컬럼 비교
| 컬럼명 | KB | 소스 | 상태 |
|---|---|---|---|

### 팝업 폼 항목 비교 (팝업별)
| 항목명 | KB | 소스 | 상태 |
|---|---|---|---|

### 버튼 비교
| 버튼명 | KB | 소스 | 상태 |
|---|---|---|---|

---

## 권장 조치

### 즉시 보완 필요 (문서 누락)
소스에 있으나 KB 문서에 없는 항목을 아래 파일에 추가한다.

| 항목 | 추가 대상 파일 | 내용 요약 |
|---|---|---|

### 확인 필요 (문서 과잉)
KB 문서에 있으나 소스에 없는 항목의 원인을 확인한다.

| 항목 | 원인 추정 | 권장 조치 |
|---|---|---|

### 다음 단계

- [ ] 문서 누락 항목 보완 후 `/KB_200 {MENU_CODE}` 재실행으로 검증
- [ ] 종합 90% 이상 달성 시 소스 생성 단계 진행 가능

───────────────── 리포트 끝 ─────────────────

Write 완료 후 종료한다.
  """
)
```

---

## 4단계 — 완료 보고 [메인 세션]

서브에이전트 완료 후 아래 형식으로 보고한다.

```
✅ KB_200 검증 완료: {MenuUpper} ({MENU_NM})
  📋 리포트: {ReportFile}

  종합 일치율: N%  {등급}
  ├── A. API        : N%  (일치 N / 총 N)
  ├── B. SQL        : N%  (일치 N / 총 N)
  ├── C. 업무규칙   : N%  (일치 N / 총 N)
  └── D. 화면 구성  : N%  (일치 N / 총 N)

  ⚠️ 문서 누락 N건 → 리포트 참조 후 KB 문서 보완 권장
  💡 90% 이상이면 소스 생성 단계 진행 가능
```
