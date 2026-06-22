---
title: 워크스페이스 레포 경로 규칙
description: AI 허브에서 형제 BE/FE 레포의 src 경로를 결정하는 규칙. 프로젝트명은 워크스페이스 폴더명(workspace-{프로젝트})에서 도출하고, AI 허브(common-system-ai)는 모든 프로젝트 공통이다. BE/FE 코드 생성·테스트·DB·spec 스킬 실행 전 STEP 0 에서 항상 적용한다.
status: active
version: 2.0.0
repo_role: ai-hub
agent_usage: rule
tags:
  - workspace
  - repo-path
  - code-generation
---

# 워크스페이스 레포 경로 규칙

각 프로젝트는 `workspace-{프로젝트}/` 디렉토리 아래 **3개 레포**로 구성된다.

- **AI 허브는 모든 프로젝트 공통인 `common-system-ai`** 다. 스킬·규칙·patterns·화면설계 산출물을 보유하며, 스킬 실행 위치(CWD)다. 프로젝트가 바뀌어도 **이름이 바뀌지 않는다.**
- **백엔드·프론트는 프로젝트별**로 `{프로젝트}-be`·`{프로젝트}-fe` 다. 역할 접미사 `-be`/`-fe`는 **항상 맨 끝**에 온다.

```
workspace-{프로젝트}/        # 워크스페이스 폴더 (예: workspace-bnk-wms)
├── common-system-ai/        # AI 허브 (모든 프로젝트 공통). 스킬·규칙·spec·prototype. 스킬 실행 위치(CWD)
├── {프로젝트}-be/           # 백엔드 (예: bnk-wms-be). src/main/java, DEV_DOC, gradle
└── {프로젝트}-fe/           # 프론트엔드 (예: bnk-wms-fe). src/views, package.json
```

스킬은 **항상 AI 허브에서 실행**된다. 형제 BE/FE 레포는 **워크스페이스 폴더명에서 프로젝트명을 도출**해 찾는다(아래). 허브 이름(`common-system-ai`)은 프로젝트마다 동일하므로 **허브 폴더명이 아니라 워크스페이스 폴더명(`workspace-{프로젝트}`)이 도출 기준**이다. 따라서 `workspace-common-system` → `common-system-be`, `workspace-bnk-wms` → `bnk-wms-be` 처럼 **워크스페이스만 바꾸면 형제가 그대로 따라온다.**

---

## 레포 경로 결정 (BLOCKING — 코드 생성·테스트·spec 스킬의 STEP 0)

```bash
# 현재 워킹 디렉토리 = AI 허브 레포 (항상 *-ai, 공통 common-system-ai)
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WS=$(dirname "$AI_DIR")
AI_NAME=$(basename "$AI_DIR")      # 허브 레포 폴더명 (공통: common-system-ai)

# 프로젝트명 = 워크스페이스 폴더명 "workspace-{프로젝트}" 에서 "workspace-" 접두어를 뗀 부분.
#   허브 이름(항상 common-system-ai)이 아니라 워크스페이스 폴더에서 도출한다 — 허브는 모든 프로젝트 공통이라 이름이 프로젝트를 따라가지 않기 때문.
WS_NAME=$(basename "$WS")          # 예: workspace-bnk-wms  (또는 workspace-common-system)
PROJECT=${WS_NAME#workspace-}      # "workspace-" 제거 → 예: bnk-wms  (또는 common-system)

# 형제 = 프로젝트명 + -be / -fe (없으면 *-be / *-fe 탐색 폴백)
BE_DIR="$WS/${PROJECT}-be"
[ -d "$BE_DIR" ] || BE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-be' | head -1)

FE_DIR="$WS/${PROJECT}-fe"
[ -d "$FE_DIR" ] || FE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-fe' | head -1)

# 레포 이름(NAME) — 산문·로그·메시지에서 "레포명 단어"가 필요할 때.
# DIR 의 basename 으로 뽑는다(${PROJECT}-be 가 아니라) → find 폴백으로 실폴더명이
# 프로젝트명과 달라도 실제 폴더명을 그대로 따른다.
BE_NAME=$(basename "$BE_DIR")      # 예: bnk-wms-be
FE_NAME=$(basename "$FE_DIR")      # 예: bnk-wms-fe

echo "AI_DIR=$AI_DIR  AI_NAME=$AI_NAME  WS=$WS  PROJECT=$PROJECT"
echo "BE_DIR=$BE_DIR  BE_NAME=$BE_NAME"
echo "FE_DIR=$FE_DIR  FE_NAME=$FE_NAME"
```

`BE_DIR` 또는 `FE_DIR` 이 비어 있으면(형제 레포를 못 찾으면) **사용자에게 경로를 직접 묻는다.**

Windows PowerShell 환경에서는 동일 규칙을 PowerShell로 수행한다. 프로젝트명은 워크스페이스 폴더명에서 뽑는다: `$WS = Split-Path $AI_DIR -Parent`, `$PROJECT = (Split-Path $WS -Leaf) -replace '^workspace-',''`. 형제는 `Join-Path $WS "$PROJECT-be"` (없으면 `Get-ChildItem $WS -Directory -Filter '*-be' | Select-Object -First 1`). 이름은 `$AI_NAME = Split-Path $AI_DIR -Leaf`, `$BE_NAME = Split-Path $BE_DIR -Leaf`, `$FE_NAME = Split-Path $FE_DIR -Leaf` 로 뽑는다.

---

## 경로 기준 규약 (BLOCKING)

| 경로 유형 | 기준 레포 | 표기 예 |
|---|---|---|
| `src/main/java/`, `src/main/resource/`, `DEV_DOC/`, `build/`, `./gradlew`, `db.md`, `api.md` 등 BE 산출물 | `$BE_DIR` | `$BE_DIR/src/main/java/be/...` |
| `src/views/`, `package.json`, `vitest/` 등 FE 산출물 | `$FE_DIR` | `$FE_DIR/src/views/be/...` |
| `patterns/`, `deliverables/` 프레임워크·산출물 (프로젝트 무관) | `$AI_DIR` (허브, CWD) | `$AI_DIR/patterns/...` |
| `spec/`, `prototype/` 화면설계·검증물 (**프로젝트별**) | `$AI_DIR` + **프로젝트 층 `$PROJECT`** | `$AI_DIR/spec/$PROJECT/{메뉴코드}/...` · `$AI_DIR/prototype/$PROJECT/...` |
| 프로젝트명 단어(산문·로그·메시지에 들어가는 레포명) | `$AI_NAME` / `$BE_NAME` / `$FE_NAME` | `"BE(\`$BE_NAME\`) 소스를 읽는다"` |

- **BE 전용 스킬**: 작업 시작 시 `cd "$BE_DIR"` 후 진행하면 스킬 본문의 상대경로(`src/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)가 그대로 동작한다.
- **FE 전용 스킬**: `cd "$FE_DIR"` 후 진행하면 `src/views/...`, `package.json` 이 그대로 동작한다.
- **허브 문서와 BE/FE를 동시에 다루는 스킬**(예: SD_db, SD_api): `cd` 하지 말고 위 표의 기준 변수(`$AI_DIR` / `$BE_DIR`)를 경로 앞에 붙여 명시한다.
- **경로 vs 이름 구분**: 파일·디렉토리 **경로**가 필요하면 `$AI_DIR`/`$BE_DIR`/`$FE_DIR`(절대경로)을, 산문·로그·메시지에 들어가는 **레포명 단어**가 필요하면 `$AI_NAME`/`$BE_NAME`/`$FE_NAME` 을 쓴다 — 둘을 섞지 않는다. (`*_NAME` 은 항상 대응 `*_DIR` 의 basename 이다.)
- **허브 `spec/`·`prototype/` 는 프로젝트별로 네임스페이싱한다.** 허브(`common-system-ai`)는 모든 프로젝트 공통이므로, 화면설계 정본(`spec/`)·검증 프로토타입(`prototype/`)은 `spec/$PROJECT/{메뉴코드}/...`·`prototype/$PROJECT/...` 처럼 **프로젝트 층(`$PROJECT`) 아래**에 둔다. `$PROJECT` 는 STEP 0 도출값(워크스페이스 폴더명 기반)이다. 반면 `patterns/`·`deliverables/` 는 프로젝트 공통이라 프로젝트 층이 없다.
- **형제 레포(BE/FE)의 파일은 해당 스킬의 산출 대상이 아닌 한 읽기 전용으로 취급한다.**
