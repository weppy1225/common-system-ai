---
title: 워크스페이스 레포 경로 규칙
description: AI 허브(wms-{code}-ai)에서 형제 BE/FE 레포의 src 경로를 결정하는 규칙. BE/FE 코드 생성·테스트·DB·spec 스킬 실행 전 STEP 0 에서 항상 적용한다.
status: active
version: 1.0.0
wms_meta: true
project: wms-{code}-ai
agent_usage: rule
tags:
  - workspace
  - repo-path
  - code-generation
---

# 워크스페이스 레포 경로 규칙

모든 프로젝트는 `workspace/` 디렉토리 아래 **프로젝트당 3개 레포**로 구성된다.

```
workspace/
├── wms-{프로젝트코드}-ai/    # AI 허브. 스킬·규칙·화면설계(30-domain)·프로토타입(prototype) 보유. 스킬 실행 위치(CWD)
├── wms-{프로젝트코드}-be/    # 백엔드. src/main/java, DEV_DOC, gradle
└── wms-{프로젝트코드}-fe/    # 프론트엔드. src/views, package.json
```

스킬은 **항상 AI 허브(`wms-{프로젝트코드}-ai`)에서 실행**된다. 따라서 BE/FE 코드 생성·테스트는 `..`(workspace) 기준 형제 레포의 `src` 디렉토리를 대상으로 한다.

> 현재 실제 레포명이 `cloud-wms-doc` / `cloud-wms-be` / `cloud-wms-fe` 인 경우도 아래 폴백 규칙으로 동일하게 동작한다.

---

## 레포 경로 결정 (BLOCKING — 코드 생성·테스트·spec 스킬의 STEP 0)

```bash
# 현재 워킹 디렉토리 = AI 허브 레포
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
WS=$(dirname "$AI_DIR")

# 프로젝트 코드: wms-{code}-ai 형식이면 {code} 추출 (아니면 빈 값)
PROJECT_CODE=$(basename "$AI_DIR" | sed -nE 's/^wms-(.+)-ai$/\1/p')

# BE 레포: wms-{code}-be 우선 → cloud-wms-be 폴백 → *-be 탐색
BE_DIR="$WS/wms-${PROJECT_CODE}-be"
{ [ -n "$PROJECT_CODE" ] && [ -d "$BE_DIR" ]; } || BE_DIR="$WS/cloud-wms-be"
[ -d "$BE_DIR" ] || BE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-be' | head -1)

# FE 레포: wms-{code}-fe 우선 → cloud-wms-fe 폴백 → *-fe 탐색
FE_DIR="$WS/wms-${PROJECT_CODE}-fe"
{ [ -n "$PROJECT_CODE" ] && [ -d "$FE_DIR" ]; } || FE_DIR="$WS/cloud-wms-fe"
[ -d "$FE_DIR" ] || FE_DIR=$(find "$WS" -maxdepth 1 -type d -name '*-fe' | head -1)

echo "AI_DIR=$AI_DIR"; echo "BE_DIR=$BE_DIR"; echo "FE_DIR=$FE_DIR"
```

`BE_DIR` 또는 `FE_DIR` 이 비어 있으면(형제 레포를 못 찾으면) **사용자에게 경로를 직접 묻는다.**

Windows PowerShell 환경에서는 동일 규칙을 PowerShell로 수행한다(`Split-Path`, `Get-ChildItem -Directory -Filter '*-be'`).

---

## 경로 기준 규약 (BLOCKING)

| 경로 유형 | 기준 레포 | 표기 예 |
|---|---|---|
| `src/main/java/`, `src/main/resource/`, `DEV_DOC/`, `build/`, `./gradlew`, `db.md`, `api.md` 등 BE 산출물 | `$BE_DIR` | `$BE_DIR/src/main/java/be/...` |
| `src/views/`, `package.json`, `vitest/` 등 FE 산출물 | `$FE_DIR` | `$FE_DIR/src/views/be/...` |
| `30-domain/`, `prototype/`, `patterns/`, `deliverables/` 화면설계·문서 | `$AI_DIR` (허브, CWD) | `$AI_DIR/30-domain/30-wms-business/{메뉴코드}/...` |

- **BE 전용 스킬**: 작업 시작 시 `cd "$BE_DIR"` 후 진행하면 스킬 본문의 상대경로(`src/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)가 그대로 동작한다.
- **FE 전용 스킬**: `cd "$FE_DIR"` 후 진행하면 `src/views/...`, `package.json` 이 그대로 동작한다.
- **허브 문서와 BE/FE를 동시에 다루는 스킬**(예: SD-db, SD-api): `cd` 하지 말고 위 표의 기준 변수(`$AI_DIR` / `$BE_DIR`)를 경로 앞에 붙여 명시한다.
- **형제 레포(BE/FE)의 파일은 해당 스킬의 산출 대상이 아닌 한 읽기 전용으로 취급한다.**
