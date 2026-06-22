---
name: SD_api
description: 화면설계·DB 기반 api.md(API 설계+기능명세) 작성. /SD_db 완료 후 실행. /SD_api {메뉴코드}
when_to_use: "api.md 작성해줘", "API 설계서 만들어줘", "기능명세 만들어줘", "design-spec 실행해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Glob, Grep
model: claude-opus-4-7
---

# API 명세서 설계 [SD_api]

다음 지시에 따라 기능 명세서(`api.md`)를 작성한다.

## 실행 절차

### Step 0 — 레포 경로 결정 (BLOCKING)

스킬은 AI 허브(`wms-{code}-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(화면설계 보유 허브 = CWD)와 `$BE_DIR`(api.md·DEV_DOC 대상 BE 레포 = 형제 `../wms-{code}-be`)을 결정한다.

```bash
# .claude/rules/repo-paths.md 참조 — AI_DIR(허브, CWD) / BE_DIR(형제 ../wms-{code}-be)
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
# BE_DIR 은 repo-paths.md 규칙으로 결정

# 허브 spec/prototype 는 프로젝트 층 아래 — 프로젝트명은 워크스페이스 폴더명에서 도출 (→ repo-paths.md)
PROJECT=$(basename "$(dirname "$AI_DIR")"); PROJECT=${PROJECT#workspace-}

# ui.md·wireframe 등 화면설계는 허브($AI_DIR)의 spec/$PROJECT/ 에 위치
UI_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md"

# wireframe: PC / PDA 모바일 자동 분기 (PC=prototype/$PROJECT/{메뉴코드}/, PDA=prototype/$PROJECT/{메뉴코드}m/)
if [ -f "$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html" ]; then
  # PC 화면
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html"
else
  # PDA 모바일 화면
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-wireframe.html"
fi
```

> 이 스킬에서 `api.md`, `db.md`, `DEV_DOC/...`, `{기능폴더}/...` 등 BE 산출물 표기는 모두 **`$BE_DIR` 기준**이다 (예: `$BE_DIR/DEV_DOC/ai-docs/...`).
> `$BE_DIR` 또는 허브의 `spec/$PROJECT/{메뉴코드}/` 폴더가 없으면 사용자에게 경로를 직접 묻는다.

### Step 1 — 기능 정보 파악

사용자가 지정한 기능명 또는 현재 대화 컨텍스트에서 아래 정보를 확인한다:

- 기능명 (예: "입고요청 관리", "품목 목록 출력")
- 메뉴코드 (있다면)
- 도메인 (MDM / IW / OW / IV / RT / SIF 중)

### Step 2 — 기존 폴더 확인

`$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/` 하위 폴더를 확인한다.

케이스에 따라 아래와 같이 처리한다:

| 케이스 | 조건 | 처리 방법 |
| --- | --- | --- |
| **A. 기존 기능 + api.md 있음** | 해당 폴더 + api.md 존재 | api.md를 읽어 내용을 업데이트한다 |
| **B. 기존 기능 + api.md 없음** | 해당 폴더는 있으나 api.md 없음 | `$BE_DIR/src/main/java/` 하위 해당 패키지의 기존 코드를 읽어 구현 상태를 분석한 뒤, 해당 폴더에 api.md를 **신규 작성**한다 |
| **C. 신규 기능** | 폴더 자체가 없음 | `{메뉴코드}` 형식으로 새 폴더를 생성하고 api.md를 작성한다 |

> 폴더명 예시: `mdpd01`, `iwrq01`, `owpk01`

### Step 3 — 관련 문서 읽기 (BLOCKING)

코드 작성 전 반드시 아래 문서를 읽는다:

1. `$BE_DIR/DEV_DOC/ai-docs/20-backend/20-rule/02-api-naming-rule.md` — 메뉴코드·네이밍 규칙
2. 기능 폴더의 `db.md` — DB 설계 결과 (존재하는 경우 **우선 참조**)
3. `$UI_MD` (`spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md`) — 화면설계 UI 명세 (Step 0에서 추출한 변수 사용)
4. `$WIREFRAME` — 화면 프로토타입 (PC: `prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html` / PDA: `prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-wireframe.html`)
5. `$BE_DIR/DEV_DOC/ai-docs/10-database/00-database-overview.md` — 관련 테이블 분석
6. 해당 도메인 테이블 컬럼 명세 (`$BE_DIR/DEV_DOC/ai-docs/10-database/90-schema/20-tables/`)
7. `$BE_DIR/DEV_DOC/ai-docs/20-backend/30-convention/02-backend-coding-convention.md` — 코딩 컨벤션

### Step 4 — api.md 작성

아래 템플릿으로 `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md` 를 작성한다:

```markdown
# {기능명} API 명세서
> 작성일: {YYYY-MM-DD} | 작성자: AI | 상태: 초안

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

- DB 설계: `db.md` (존재하는 경우)
- DB 명세: `DEV_DOC/ai-docs/10-database/90-schema/20-tables/{테이블명}.md`
- 코딩 컨벤션: `DEV_DOC/ai-docs/20-backend/30-convention/02-backend-coding-convention.md`
- 개발 가이드: `DEV_DOC/ai-docs/20-backend/80-spec/02-new-backend-api-addition-procedure.md`
```

---

### Step 5 — 완료 안내

생성된 산출물 목록과 다음 단계를 안내한다:

```
✅ api.md 생성 완료

다음 단계: /PI_be_all (또는 /PI_be_mapper → /PI_be_dao → /PI_be_comp 순서)
```
