---
name: SD_api
description: 화면설계·DB 기반 API 명세서 작성. /SD_db 완료 후 실행. 결과물은 AI 허브 spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md. /SD_api {메뉴코드}
when_to_use: "api.md 작성해줘", "API 설계서 만들어줘", "기능명세 만들어줘", "API 명세 설계해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Bash
model: claude-opus-4-7
---

# API 명세서 설계 [SD_api]

다음 지시에 따라 API 명세서(`{메뉴코드}-05-api.md`)를 작성한다.

## 실행 절차

### Step 0 — 레포 경로 결정 (BLOCKING)

스킬은 AI 허브(`common-system-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 경로를 결정한다.

```bash
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WS=$(dirname "$AI_DIR")
WS_NAME=$(basename "$WS")
PROJECT=${WS_NAME#workspace-}

BE_DIR="$WS/${PROJECT}-be"
[ -d "$BE_DIR" ] || BE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-be' | head -1)

# API 명세서 저장 위치 — AI 허브 spec/$PROJECT/{메뉴코드}/
API_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md"

# DB 설계 문서 (있으면 우선 참조)
DB_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md"

# UI 명세
UI_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md"

# wireframe: PC / PDA 모바일 자동 분기
if [ -f "$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html" ]; then
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html"
else
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-wireframe.html"
fi
```

> **산출물 저장 위치**: `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md` (AI 허브, repo_role: ai-hub)
> `$AI_DIR/spec/$PROJECT/{메뉴코드}/` 폴더가 없으면 생성한다.
> `$BE_DIR`은 FE 소스 참조용으로 사용한다 (API 명세서 저장 대상 아님).

### Step 1 — 기능 정보 파악

사용자가 지정한 기능명 또는 현재 대화 컨텍스트에서 아래 정보를 확인한다:

- 기능명 (예: "입고요청 관리", "품목 목록 출력")
- 메뉴코드 (있다면)
- 도메인 (MDM / IW / OW / IV / RT / SIF 중)

### Step 2 — 기존 파일 확인

`$AI_DIR/spec/$PROJECT/{메뉴코드}/` 하위를 확인한다.

| 케이스 | 조건 | 처리 방법 |
|---|---|---|
| **A. api.md 있음** | `{메뉴코드}-05-api.md` 존재 | 파일을 읽어 내용을 업데이트한다 |
| **B. api.md 없음 + BE 소스 있음** | 파일 없음, `$BE_DIR/src/main/java/` 해당 패키지 존재 | BE 소스를 읽어 구현 상태를 분석한 뒤 **신규 작성**한다 |
| **C. 신규 기능** | 파일·BE 소스 모두 없음 | 폴더를 생성하고 신규 작성한다 |

### Step 3 — 관련 문서 읽기 (BLOCKING)

코드 작성 전 반드시 아래 문서를 읽는다:

1. `$DB_MD` (`spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md`) — DB 설계 결과 (존재하는 경우 **최우선 참조**)
2. `$UI_MD` (`spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md`) — 화면설계 UI 명세
3. `$WIREFRAME` — 화면 프로토타입
4. `spec/$PROJECT/_knowledge/db-schema/` — 프로젝트 DB 스키마 (DB 설계 문서 없을 때)
5. `$BE_DIR/src/main/java/` 해당 패키지 — BE 소스 (케이스 B)
6. `$BE_DIR/DEV_DOC/ai-docs/20-backend/20-rule/02-api-naming-rule.md` — API 네이밍 규칙 (존재하는 경우)

### Step 4 — api.md 작성

**`작성자` 필드 (MUST — 추정 금지)**:
파일 작성 전 반드시 아래를 실행하고 그 결과를 frontmatter `author` 및 본문 `작성자` 항목에 기입한다.

```bash
git config user.name
```

아래 템플릿으로 `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md` 를 작성한다:

````markdown
---
title: {메뉴코드} {기능명} — API 명세서
description: {기능명} API 설계 시 참조
status: draft
version: 1.0.0
author: {git config user.name 실행 결과}
repo_role: ai-hub
agent_usage: spec
tags:
  - {메뉴코드}
  - api-spec
  - {프로젝트명}
related:
  - spec/{프로젝트}/{메뉴코드}/{메뉴코드}-03-data-model.md
last_verified: {YYYY-MM-DD}
---

# {기능명} API 명세서
> 작성일: {YYYY-MM-DD} | 작성자: {git config user.name 실행 결과} | 상태: 초안

---

## 1. 기본 정보

| 항목 | 내용 |
|---|---|
| 메뉴코드 | {메뉴코드} |
| 메뉴명 | {메뉴명} |
| 메뉴그룹 | {메뉴그룹} |
| 패키지 | `be.{그룹}.{메뉴코드}/` |
| URL prefix | 권장: `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_복수형}` |
| 해당 도메인 | MDM / IW / OW / IV / RT / SIF |

> URL/메서드는 **권장 예시**이며 고정 규칙이 아니다. 실제 구현은 컬렉션 경로에 `PUT`/`PATCH`를 사용하거나, `/{stSeq}/trans` 같은 업무별 하위 경로를 둘 수 있다.

---

## 2. 기능 개요

{기능에 대한 2-3문장 설명}

---

## 3. API 목록

| Interface ID | HTTP Method | URL | 설명 |
|---|---|---|---|
| {메뉴코드}_POST_{리소스}S | POST | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s` | 목록 조회 |
| {메뉴코드}_PUT_INSERT | PUT | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s` | 단건 등록(권장 예시) |
| {메뉴코드}_GET_{리소스} | GET | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s/{seq}` | 단건 조회 |
| {메뉴코드}_PATCH_UPDATE | PATCH | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s` | 단건 수정(권장 예시) |
| {메뉴코드}_DELETE_{리소스}S | DELETE | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s` | 삭제 |
| {메뉴코드}_POST_ACTION | POST | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스}s/{seq}/trans` | 업무 처리형 하위 경로 예시 |

---

## 4. 사용 테이블

| 테이블명 | 용도 | 주요 컬럼 |
|---|---|---|
| `{테이블명}` | {용도} | `{컬럼1}`, `{컬럼2}` |

---

## 5. Bean 설계

### {메뉴코드}Response (응답 DTO)

```java
extends ResponseData
- List<{메뉴코드}Search> post{리소스}s  // 목록
- {메뉴코드}{리소스} {리소스_인스턴스}    // 단건
```

### Search (조회 파라미터 + 결과)

```java
extends BaseParam
- Integer bizSeq
- String searchKeyword
// ... 검색조건 및 결과 컬럼
```

### (도메인 DTO)

```java
implements Serializable
// 주요 필드 목록
```

---

## 6. 비즈니스 규칙

1. {규칙1}
2. {규칙2}
3. {규칙3}

---

## 7. 유효성 검증

| 검증 항목 | 방법 | 오류 메시지 |
|---|---|---|
| {필드명} 중복 | `checkDuplicate*No()` | "중복된 {필드명}입니다" |
| {필드명} 연관 삭제 방지 | `check*SeqInOtherTbl()` | "연관 데이터가 존재합니다" |

---

## 8. 관련 문서

- DB 설계: `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-03-data-model.md`
- DB 스키마: `spec/{프로젝트}/_knowledge/db-schema/`
- 코딩 컨벤션: `{$BE_DIR}/DEV_DOC/ai-docs/20-backend/30-convention/02-backend-coding-convention.md` (존재하는 경우)
````

---

### Step 5 — 완료 안내

생성된 산출물 목록과 다음 단계를 안내한다:

```
✅ {메뉴코드}-05-api.md 생성 완료
   위치: spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md

다음 단계: /PI_be_all (또는 /PI_be_mapper → /PI_be_dao → /PI_be_comp 순서)
```
