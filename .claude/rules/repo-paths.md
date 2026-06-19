---
title: 워크스페이스 레포 경로 규칙
description: AI 허브에서 형제 BE/FE 레포의 src 경로를 결정하는 규칙. 허브 폴더명에서 역할 접미사만 떼어 형제를 도출하므로 레포명이 바뀌어도 동작한다. BE/FE 코드 생성·테스트·DB·spec 스킬 실행 전 STEP 0 에서 항상 적용한다.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: rule
tags:
  - workspace
  - repo-path
  - code-generation
---

# 워크스페이스 레포 경로 규칙

모든 프로젝트는 `workspace/` 디렉토리 아래 **프로젝트당 3개 레포**로 구성된다. 레포명은 **`{프로젝트}-{역할}`** 형식이고, 역할 접미사는 **항상 맨 끝**에 온다: AI 허브 `-ai`(현재는 `-doc`), 백엔드 `-be`, 프론트 `-fe`.

```
workspace/
├── {프로젝트}-ai/    # AI 허브 (예: cloud-wms-ai). 스킬·규칙·spec·prototype 보유. 스킬 실행 위치(CWD)
├── {프로젝트}-be/    # 백엔드. src/main/java, DEV_DOC, gradle
└── {프로젝트}-fe/    # 프론트엔드. src/views, package.json
```

스킬은 **항상 AI 허브에서 실행**된다. 형제 BE/FE 레포는 **허브 폴더명에서 역할 접미사만 떼어** 도출한다(아래). 따라서 `cloud-wms-*` → `bnk-wms-*` 처럼 **이름이 바뀌어도 규칙은 그대로** 동작한다. (역할 접미사 `-be`/`-fe`만 유지하면 됨)

---

## 레포 경로 결정 (BLOCKING — 코드 생성·테스트·spec 스킬의 STEP 0)

```bash
# 현재 워킹 디렉토리 = AI 허브 레포
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WS=$(dirname "$AI_DIR")

# 프로젝트 접두어 = 허브 폴더명에서 마지막 역할 토큰(-doc/-ai 등) 제거
#   cloud-wms-doc → cloud-wms · cloud-wms-ai → cloud-wms · bnk-wms-ai → bnk-wms
BASE=$(basename "$AI_DIR")
PREFIX=${BASE%-*}

# 형제 = 같은 접두어 + -be / -fe (없으면 *-be / *-fe 탐색 폴백)
BE_DIR="$WS/${PREFIX}-be"
[ -d "$BE_DIR" ] || BE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-be' | head -1)

FE_DIR="$WS/${PREFIX}-fe"
[ -d "$FE_DIR" ] || FE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-fe' | head -1)

echo "AI_DIR=$AI_DIR"; echo "PREFIX=$PREFIX"; echo "BE_DIR=$BE_DIR"; echo "FE_DIR=$FE_DIR"
```

`BE_DIR` 또는 `FE_DIR` 이 비어 있으면(형제 레포를 못 찾으면) **사용자에게 경로를 직접 묻는다.**

Windows PowerShell 환경에서는 동일 규칙을 PowerShell로 수행한다(`Split-Path`, `Get-ChildItem -Directory -Filter '*-be'`).

---

## 경로 기준 규약 (BLOCKING)

| 경로 유형 | 기준 레포 | 표기 예 |
|---|---|---|
| `src/main/java/`, `src/main/resource/`, `DEV_DOC/`, `build/`, `./gradlew`, `db.md`, `api.md` 등 BE 산출물 | `$BE_DIR` | `$BE_DIR/src/main/java/be/...` |
| `src/views/`, `package.json`, `vitest/` 등 FE 산출물 | `$FE_DIR` | `$FE_DIR/src/views/be/...` |
| `spec/`, `prototype/`, `patterns/`, `deliverables/` 화면설계·문서 | `$AI_DIR` (허브, CWD) | `$AI_DIR/spec/{메뉴코드}/...` |

- **BE 전용 스킬**: 작업 시작 시 `cd "$BE_DIR"` 후 진행하면 스킬 본문의 상대경로(`src/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)가 그대로 동작한다.
- **FE 전용 스킬**: `cd "$FE_DIR"` 후 진행하면 `src/views/...`, `package.json` 이 그대로 동작한다.
- **허브 문서와 BE/FE를 동시에 다루는 스킬**(예: SD_db, SD_api): `cd` 하지 말고 위 표의 기준 변수(`$AI_DIR` / `$BE_DIR`)를 경로 앞에 붙여 명시한다.
- **형제 레포(BE/FE)의 파일은 해당 스킬의 산출 대상이 아닌 한 읽기 전용으로 취급한다.**
