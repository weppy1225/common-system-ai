---
title: 포팅·리브랜딩 가이드
description: 이 AI 허브 프레임워크를 다른 프로젝트(접두어)에 이식하거나 리브랜딩할 때 무엇을·어디를·왜 수정하는지 설명한다. 폴더명만 바꾸면 실행 코드는 자동 추종하며, 산문 리터럴만 정해진 자리를 수정한다.
status: active
version: 1.0.0
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

> 이 프레임워크는 레포 이름을 코드에 박지 않는다. 경로·이름은 **지금 열려 있는 폴더 이름에서 런타임에 도출**한다. 그래서 다른 프로젝트(`bnk-wms`, `acme-erp` …)에 붙일 때 **실행 코드는 한 줄도 안 고친다.** 손대는 것은 폴더명과, 산문에 남은 리터럴뿐이다.
>
> 아래 예시의 `cloud-wms-*` 는 현재 프로젝트명일 뿐이며, 메커니즘을 설명하기 위한 illustration 이다.

정본 규칙: [`.claude/rules/repo-paths.md`](./.claude/rules/repo-paths.md) (경로·변수 도출) · [`.claude/rules/md-frontmatter.md`](./.claude/rules/md-frontmatter.md) (frontmatter `repo_role`).

---

## 01 — 왜 리브랜딩에 면역인가

스킬은 **항상 AI 허브에서 실행**되고, 형제 BE/FE 레포는 **허브 폴더명에서 역할 접미사(`-ai`)만 떼어** 도출한다. 레포명이 바뀌어도 규칙은 그대로다.

```
현재 폴더명 ──basename──▶ AI_NAME ──끝의 -ai 제거──▶ PREFIX
          ──+ -be/-fe──▶ BE_DIR · FE_DIR ──basename──▶ BE_NAME · FE_NAME
```

접두어로 조립한 형제 폴더가 없으면 `*-be`/`*-fe` 패턴으로 한 번 더 찾고, 그래도 없으면 사용자에게 묻는다.

---

## 02 — 변수 체계: 경로(DIR)와 이름(NAME)

레포마다 **경로**(절대경로)와 **이름**(폴더명 단어)이 한 쌍. `*_NAME` 은 항상 대응 `*_DIR` 의 `basename` 이다. 경로가 필요하면 `*_DIR`, 산문·로그에 들어가는 레포명 단어가 필요하면 `*_NAME` — **둘을 섞지 않는다.**

| 역할 | 경로 (DIR) | 이름 (NAME) | 현재 값(예) |
|---|---|---|---|
| AI 허브 (CWD) | `$AI_DIR` | `$AI_NAME` | `cloud-wms-ai` |
| 백엔드 | `$BE_DIR` | `$BE_NAME` | `cloud-wms-be` |
| 프론트엔드 | `$FE_DIR` | `$FE_NAME` | `cloud-wms-fe` |

도출 코드(STEP 0)는 `repo-paths.md` 정본을 따른다. 핵심 식:

```bash
AI_NAME=$(basename "$AI_DIR")   # cloud-wms-ai
PREFIX=${AI_NAME%-*}            # cloud-wms
BE_DIR="$WS/${PREFIX}-be"       # …/cloud-wms-be   (없으면 *-be 폴백)
BE_NAME=$(basename "$BE_DIR")   # cloud-wms-be
```

---

## 03 — 표기 분류 정책: 리터럴 레포명을 만나면 무엇을 하나

변수 치환은 **실행되는 컨텍스트(스킬의 셸 코드)** 에서만 동작한다. 순수 산문 `.md` 는 치환 엔진이 없으므로 — 발생 위치의 성격에 따라 처리를 나눈다.

| 분류                   | 예                               | 처리                                         | 리브랜딩  |
| -------------------- | ------------------------------- | ------------------------------------------ | ----- |
| **실행 코드** (스킬 셸)     | `$Workspace\cloud-wms-be\src\…` | 도출 변수 `$BE_DIR`/`$BE_NAME` 로 교체            | 자동    |
| **A. frontmatter**   | `description: cloud-wms-be에서…`  | `repo_role: be` 로, 본문 description 엔 브랜드 제거 | 자동    |
| **B. 식별자 산문**        | "대응 백엔드: `cloud-wms-be`"        | 역할어로 환원 → "BE 레포"/"백엔드"                    | 영구 면역 |
| **C1. AI가 읽는 경로·출처** | `> 출처: ../cloud-wms-be/src/…`   | 브랜드 접두부만 `$BE_DIR/…` 로 추상화                 | 자동    |
| **C2. 사람이 복붙하는 명령**  | `cd C:\…\cloud-wms-be`          | 실예시 유지 (+`$BE_DIR` 병기)                     | 수동 1회 |
| **유지**               | 규칙 자체의 설명 예시 · README/제목        | 그대로 둠 (메커니즘 설명용)                           | 해당 없음 |

**핵심:** "이름이 정보를 안 주는 자리"(B)는 역할어로 → 엔진 없이도 영구 면역. "정보가치 있는 실제 경로"(C1)는 브랜드 접두부만 변수화. 진짜 못 피하는 건 사람이 터미널에 그대로 붙여넣는 **C2뿐**.

---

## 04 — 리브랜딩 시 손대는 곳 (md 파일 인벤토리)

> 아래는 **작성 시점 스냅샷** 기준(`.md` 내 `cloud-wms-` 약 25개 파일·76건)이다. 실제 sweep 전에 `git grep -n 'cloud-wms-'` 로 한 번 더 대조한다.

### 자동 — 실행 코드 (변수로 교체 대상)
- `.claude/skills/KB_100/SKILL.md` :64–65 — `$Workspace\cloud-wms-be|fe\…` → **수정 완료** (PREFIX 도출 + `*-be`/`*-fe` 폴백)
- `.claude/skills/KB_200/SKILL.md` :52–53 — 동일 패턴 → **수정 완료**

→ 워크스페이스만 동적으로 구하고 형제 이름을 박아두던 하드코딩을 `repo-paths.md` 방식(`PREFIX` 도출)으로 교체.

> 참고: `.claude/skills/SD_334/SKILL.md` :40 의 `cloud-wms-be` 는 실행 코드가 아니라 "사용자에게 BE 경로를 묻는다" 흐름의 **예시**(바로 아래 `wms-bnk-be` 예시 병기)다 — 교체 대상 아님.

### 자동 — A. frontmatter (`repo_role` 로)
- `knowledgebase/40-install-guide/deploy/local-deploy-guide.md` :2–3 (title/description)
- `patterns/30-backend/10-architecture/04-library.md` :3
- `patterns/30-backend/10-architecture/02-package-structure.md` :3
- `patterns/40-frontend/10-architecture/01-folder-structure.md` :3

### 영구 면역 — B. 식별자 산문 (역할어로 환원)
- `CLAUDE.md` :10, :117
- `.claude/rules/git-workflow.md` :11–13, :22 (레포 운영 표)
- `patterns/40-frontend/00-overview.md` :23, :25
- `patterns/40-frontend/10-architecture/02-be-fe-contract.md` :21
- `patterns/40-frontend/20-convention/03-backend-spec-consumption.md` :23
- `patterns/30-backend/10-architecture/02-package-structure.md` :20
- `spec/mdbz01/mdbz01-06-be-flow.md` :211, :226, :327
- `.claude/skills/TT_541/SKILL.md` :199 · `STRUCTURE.md` :15 (제목)

### 자동 — C1. AI가 읽는 경로·출처 (`$BE_DIR/…`)
- `patterns/30-backend/be-layer-pattern.md` :49, :60
- `patterns/30-backend/30-convention/02-header-detail-convention.md` :533, :535, :563
- `patterns/30-backend/50-test/02-test-coding-convention.md` :340
- `patterns/40-frontend/10-architecture/03-menu-registration.md` :32
- `patterns/40-frontend/20-convention/03-backend-spec-consumption.md` :28, :59, :77
- `patterns/_common-arch/tech-stack.md` :88 · `deliverables/20-sources/UI/ui-template.md` :21
- 디렉토리 트리 루트: `STRUCTURE.md`:26 · `CLAUDE.md`:16 · `02-package-structure.md`:29 · `01-folder-structure.md`:22

### 수동 1회 — C2. 복붙 실행 명령
- `knowledgebase/50-dev-workflow/ai-dev-procedure.md` :135, :307, :418 (`cd …`)
- `knowledgebase/40-install-guide/deploy/local-deploy-guide.md` :18, :36, :59

사람이 터미널에 그대로 붙여넣는 실예시. 리브랜딩 sed 에 함께 쓸려간다.

### 유지 — 손대지 않음
- `.claude/rules/repo-paths.md` :21, :38 — 도출 규칙의 설명 예시
- `.claude/rules/md-frontmatter.md` :29 — 규칙 본문 예시
- `README.md`:1 · `CLAUDE.md`:1 · `STRUCTURE.md`:2 — 레포 자기 이름(제목)

---

## 05 — 리브랜딩 절차 (예: `cloud-wms` → `bnk-wms`)

```bash
# 1. 세 레포 폴더 이름만 바꾼다 (역할 접미사 -ai/-be/-fe 는 유지)
#    cloud-wms-ai → bnk-wms-ai · cloud-wms-be → bnk-wms-be · cloud-wms-fe → bnk-wms-fe

# 2. 실행 코드·frontmatter·도출 → 손댈 것 없음 (런타임 도출 / repo_role)

# 3. 산문·경로 예시의 리터럴만 전 레포 일괄 치환
git grep -l 'cloud-wms-' | xargs sed -i 's/cloud-wms-/bnk-wms-/g'

# 4. 확인
git grep -n 'cloud-wms-'   # → 0건이면 완료
```

B(역할어)·A(`repo_role`)를 미리 적용해 두면 3단계 치환 대상이 C1/C2 경로 예시로만 줄어든다. 흩어진 지뢰가 **정해진 한 줄 작업**이 된다.

---

## 06 — 변수로 풀 것 vs `REPOSITORY.md` 로 풀 것

| | 폴더명에서 도출 가능 | 폴더명에서 도출 불가 |
|---|---|---|
| 대상 | 경로·레포 이름 | git remote URL, 서버 호스트·포트, DB 스키마·계정, 레드마인 프로젝트 ID, FTP 대상 등 |
| 처리 | `repo-paths.md` 런타임 도출 유지. **정적 파일로 옮기지 않는다** — 옮기면 유지보수 1건 추가 + 폴더명과 어긋날 위험만 생긴다 | 흩어두면 진짜 지뢰. **이런 환경 사실의 SoT 로 `REPOSITORY.md` 를 만드는 건 권장** |

가장 믿을 SoT 는 "폴더명 그 자체"다. `REPOSITORY.md` 를 만든다면 경로/이름은 거기에 "→ repo-paths.md 도출" 포인터만 두고, 실제 SoT 는 폴더명으로 둔다.

---

## 07 — 새 프로젝트에 붙이기

워크스페이스에 **프로젝트당 3개 레포**를, 역할 접미사를 **맨 끝**에 두어 만든다. 접두어는 자유.

```
{workspace}/
├── {프로젝트}-ai/    # AI 허브 — 스킬·규칙·spec·prototype, 스킬 실행 위치(CWD)
├── {프로젝트}-be/    # 백엔드  — src/main/java, DEV_DOC
└── {프로젝트}-fe/    # 프론트  — src/views, package.json
```

- 허브를 `{프로젝트}-ai` 로 두면 `repo-paths.md` 가 형제 `-be`/`-fe` 를 자동으로 찾는다.
- 형제 폴더명이 접두어와 달라도 `*-be`/`*-fe` 폴백으로 잡고, 못 찾으면 사용자에게 묻는다.
- 이름이 필요한 산문은 B 정책(역할어)으로, 경로 인용은 C1(`$BE_DIR`)로 써두면 — 새 프로젝트엔 그대로 복사만 하면 동작한다.
