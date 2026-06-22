---
title: 포팅·리브랜딩 가이드
description: 공유 AI 허브(common-system-ai) 프레임워크에 새 프로젝트를 붙이거나, 프레임워크 자체를 리브랜딩할 때 무엇을·어디를·왜 하는지 설명한다. 프로젝트 정체성은 워크스페이스 폴더명에서 도출하고, 프로젝트별 산출물은 spec/{프로젝트}·prototype/{프로젝트} 하위에 둔다.
status: active
version: 2.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
related:
  - .claude/rules/repo-paths.md
  - .claude/rules/md-frontmatter.md
  - STRUCTURE.md
tags:
  - rebranding
  - portability
  - repo-path
  - workspace
---

# 포팅·리브랜딩 가이드

> **AI 허브 `common-system-ai` 는 모든 프로젝트가 공유하는 단일 프레임워크 레포다.** 프로젝트마다 이름을 바꾸지 않는다. 프로젝트 정체성은 **워크스페이스 폴더명 `workspace-{프로젝트}`** 에서 런타임에 도출하고, 프로젝트별 산출물(`spec/`·`prototype/`)은 허브 안에서 **`{프로젝트}/` 하위로 네임스페이싱**한다. 그래서 새 프로젝트를 붙일 때 **허브의 실행 코드·문서는 한 줄도 안 고친다.** 새로 만드는 것은 워크스페이스 폴더와 프로젝트별 BE/FE 레포, 그리고 `spec/{프로젝트}/`·`prototype/{프로젝트}/` 폴더뿐이다.

정본 규칙: [`.claude/rules/repo-paths.md`](./.claude/rules/repo-paths.md) (경로·변수 도출) · [`.claude/rules/md-frontmatter.md`](./.claude/rules/md-frontmatter.md) (frontmatter `repo_role`).

---

## 01 — 워크스페이스 모델

각 프로젝트는 `workspace-{프로젝트}/` 폴더 안에 3개 레포로 구성된다. **허브는 공통(이름 고정), BE/FE는 프로젝트별(이름 다름).**

```
C:\zinide\
├── workspace-common-system\
│   ├── common-system-ai\        # 공유 허브 (프레임워크 + spec/{프로젝트} + prototype/{프로젝트})
│   ├── common-system-be\
│   └── common-system-fe\
├── workspace-bnk-wms\
│   ├── common-system-ai\        # ← 같은 공유 허브 (이름 동일)
│   ├── bnk-wms-be\
│   └── bnk-wms-fe\
└── workspace-kyochon-oms\
    ├── common-system-ai\        # ← 같은 공유 허브
    ├── kyochon-oms-be\
    └── kyochon-oms-fe\
```

스킬은 **항상 허브에서 실행**된다. 프로젝트명은 **워크스페이스 폴더명에서** 도출하고(허브명이 아님 — 허브는 어디서나 `common-system-ai`), 그 프로젝트명으로 형제 BE/FE 와 허브 안 `spec/{프로젝트}`·`prototype/{프로젝트}` 를 모두 가리킨다.

```
워크스페이스 폴더명 ──basename──▶ workspace-{프로젝트} ──workspace- 제거──▶ PROJECT
   PROJECT ─+ -be/-fe──▶ BE_DIR · FE_DIR (형제 레포)
   PROJECT ─────────────▶ $AI_DIR/spec/$PROJECT · $AI_DIR/prototype/$PROJECT (허브 안 산출물)
```

프로젝트명으로 조립한 형제 폴더가 없으면 `*-be`/`*-fe` 패턴으로 한 번 더 찾고, 그래도 없으면 사용자에게 묻는다.

---

## 02 — 변수 체계: 경로(DIR)·이름(NAME)·프로젝트(PROJECT)

레포마다 **경로**(절대경로)와 **이름**(폴더명 단어)이 한 쌍. `*_NAME` 은 항상 대응 `*_DIR` 의 `basename` 이다. 경로가 필요하면 `*_DIR`, 산문·로그에 들어가는 레포명 단어가 필요하면 `*_NAME` — **둘을 섞지 않는다.** 허브 안 프로젝트별 산출물 경로에는 `$PROJECT` 층을 붙인다.

| 역할 | 경로 (DIR) | 이름 (NAME) | 현재 값(예) |
|---|---|---|---|
| AI 허브 (CWD, 공통) | `$AI_DIR` | `$AI_NAME` | `common-system-ai` (고정) |
| 백엔드 (프로젝트별) | `$BE_DIR` | `$BE_NAME` | `bnk-wms-be` |
| 프론트엔드 (프로젝트별) | `$FE_DIR` | `$FE_NAME` | `bnk-wms-fe` |
| 프로젝트명 | — | `$PROJECT` | `bnk-wms` |

도출 코드(STEP 0)는 `repo-paths.md` 정본을 따른다. 핵심 식:

```bash
AI_DIR=$(git rev-parse --show-toplevel)   # …/workspace-bnk-wms/common-system-ai
WS=$(dirname "$AI_DIR")                    # …/workspace-bnk-wms
PROJECT=$(basename "$WS")                  # workspace-bnk-wms
PROJECT=${PROJECT#workspace-}              # bnk-wms   ← 프로젝트 정체성
BE_DIR="$WS/${PROJECT}-be"                 # …/bnk-wms-be   (없으면 *-be 폴백)
BE_NAME=$(basename "$BE_DIR")              # bnk-wms-be
# 허브 안 프로젝트별 산출물
#   $AI_DIR/spec/$PROJECT/{메뉴코드}/...
#   $AI_DIR/prototype/$PROJECT/...
```

---

## 03 — 프로젝트별 산출물 위치 (네임스페이싱)

허브는 한 레포 안에 **여러 프로젝트의 화면설계·검증물**을 담는다. 충돌을 막기 위해 `spec/`·`prototype/` 바로 아래에 **프로젝트 층** `{프로젝트}/` 를 둔다.

```
common-system-ai/
├── .claude/  patterns/          # 프레임워크 — 전 프로젝트 공통 (프로젝트 층 없음)
├── deliverables/                # 산출물 (※ 프로젝트 분리 정책 보류 — 추후 결정)
├── spec/
│   ├── common-system/{메뉴코드}/...
│   ├── bnk-wms/{메뉴코드}/...
│   └── kyochon-oms/{메뉴코드}/...
└── prototype/
    ├── common-system/{index.html, _common/, _common-m/, {메뉴코드}/...}
    ├── bnk-wms/...
    └── kyochon-oms/...
```

- `prototype/{프로젝트}/` 는 셸(`index.html`·`_common`·`_common-m`·`_template`)까지 **프로젝트별로 통째** 둔다 — 메뉴 트리·공통 UI가 프로젝트마다 다르고, 내부 상대경로(`../_common/`, `loadContent('{메뉴코드}/...')`)가 그대로 보존된다.
- `patterns/`·`.claude/`(스킬·규칙)는 프레임워크라 **프로젝트 층이 없다.**
- `deliverables/` 는 프로젝트 분리 정책을 아직 정하지 않았다(보류).

---

## 04 — 새 프로젝트에 붙이기 (포팅)

허브를 공유하므로 **개명·치환이 없다.** 새 워크스페이스와 BE/FE 레포만 만들면 된다.

```bash
# 1. 워크스페이스 폴더 생성 (이름이 프로젝트 정체성 — workspace-{프로젝트})
mkdir C:\zinide\workspace-bnk-wms

# 2. 공유 허브를 그 안에 클론 (이름은 그대로 common-system-ai)
cd C:\zinide\workspace-bnk-wms
git clone <common-system-ai remote> common-system-ai

# 3. 프로젝트별 BE/FE 레포 클론/생성 ({프로젝트}-be / {프로젝트}-fe)
git clone <bnk-wms-be remote> bnk-wms-be
git clone <bnk-wms-fe remote> bnk-wms-fe

# 4. 허브에서 스킬 실행 — spec/bnk-wms/·prototype/bnk-wms/ 는 첫 생성 시 자동으로 만들어진다
#    (PROJECT 는 워크스페이스 폴더명에서 도출되므로 별도 설정 불필요)
```

- 워크스페이스 폴더를 `workspace-{프로젝트}` 로만 두면 `repo-paths.md` 가 형제 `{프로젝트}-be`/`-fe` 와 허브 안 `spec/{프로젝트}`·`prototype/{프로젝트}` 를 자동으로 가리킨다.
- 형제 폴더명이 프로젝트명과 달라도 `*-be`/`*-fe` 폴백으로 잡고, 못 찾으면 사용자에게 묻는다.
- BE/FE 문서 안의 레포명은 **역할어**(`BE 레포`/`백엔드`)나 `repo_role`(→ `md-frontmatter.md`)로 써두면 프로젝트가 달라도 그대로 동작한다.

---

## 05 — 프레임워크 자체 리브랜딩 (드문 경우)

위 포팅은 허브를 안 건드린다. 단, **프레임워크의 정체성 이름 자체**(`common-system` → 다른 브랜드)를 바꾸는 일회성 작업은 별개다. 이때만 산문·경로 예시의 리터럴을 일괄 치환한다.

```bash
# 1. 세 레포(공유 허브 포함) 폴더·GitHub 레포명 변경
# 2. 실행 코드·frontmatter·도출 → 손댈 것 없음 (런타임 도출 / repo_role)
# 3. 산문·경로 예시의 리터럴만 전 레포 일괄 치환
git grep -l 'common-system-' | xargs sed -i 's/common-system-/<새브랜드>-/g'
# 4. 확인
git grep -n 'common-system-'   # → 0건이면 완료
```

> 표기 분류 원칙(자동 면역 vs 수동): 이름이 정보를 안 주는 식별자 산문은 **역할어**로 환원해 엔진 없이도 영구 면역, AI가 읽는 실제 경로는 `$BE_DIR/…` 로 변수화해 자동 추종, 사람이 터미널에 붙여넣는 복붙 명령만 수동 1회 치환된다. `repo_role` frontmatter 를 미리 적용해 두면 치환 대상이 경로 예시로만 줄어든다.

---

## 06 — 변수로 풀 것 vs `REPOSITORY.md` 로 풀 것

| | 폴더명에서 도출 가능 | 폴더명에서 도출 불가 |
|---|---|---|
| 대상 | 경로·레포 이름·프로젝트명 | git remote URL, 서버 호스트·포트, DB 스키마·계정, 레드마인 프로젝트 ID, FTP 대상 등 |
| 처리 | `repo-paths.md` 런타임 도출 유지. **정적 파일로 옮기지 않는다** — 옮기면 유지보수 1건 추가 + 폴더명과 어긋날 위험만 생긴다 | 흩어두면 진짜 지뢰. **이런 환경 사실의 SoT 로 `REPOSITORY.md` 를 만드는 건 권장** |

가장 믿을 SoT 는 "폴더명 그 자체"다. `REPOSITORY.md` 를 만든다면 경로/이름은 거기에 "→ repo-paths.md 도출" 포인터만 두고, 실제 SoT 는 폴더명으로 둔다.
