---
title: 작업자 신원 — 사용법·키 사전
description: 이 머신/작업자의 신원 사실(Claude 로그인·git commit·gh 인증)을 어떻게 읽고/도출하는지와 각 신원의 의미·주의점을 설명하는 가이드. 실제 값은 담지 않는다(값은 SET_USER.md, gitignore). 신원은 머신·작업자별로 달라지므로 커밋 파일에 하드코딩하지 않는다.
status: active
version: 1.0.0
author: ShinHyunKyu
repo_role: ai-hub
agent_usage: reference
related:
  - SET_USER.md
  - SET_ENV_USAGE.md
  - .claude/rules/git-workflow.md
  - .claude/rules/repo-paths.md
  - .claude/rules/md-frontmatter.md
tags:
  - identity
  - git
  - github
  - workflow
  - config
---

# SET_USER_USAGE — 작업자 신원 사용법·키 사전

> **이 파일은 가이드다(값 없음).** 머신·작업자마다 달라지는 신원의 **실제 값은 `SET_USER.md`** 에 있고, 그 파일은 **`.gitignore` 대상**이다(커밋 금지).
>
> **왜 커밋하지 않는가.** 허브(`common-system-ai`)는 **모든 워크스페이스가 같은 git 레포를 클론**해 쓴다(`PORTING.md §01`). 신원 값(`git config user.name`·gh 계정)은 **머신·작업자마다 다르므로**, 박아서 커밋하면 다른 머신에서 틀린 값이 된다. 이 레포의 일관된 원칙(`CLAUDE.md` 히스토리 `{작업자}`·`md-frontmatter.md` `author` 모두 git config 동적 도출, 하드코딩 금지)과 같은 이유다.

## 1. 신원 3종 (개념)

업무 시 신원은 **3가지가 별개로** 움직인다. 섞으면 안 된다.

| 신원 | 무엇인가 | 도출 방법 | 어디에 쓰이나 |
|---|---|---|---|
| **Claude 로그인** | 지금 Claude에게 명령하는 **실제 사용자(사람)** | Claude Code 세션 컨텍스트(`userEmail`) | 누가 작업을 지시했는지 |
| **git commit 신원** | `git commit` 작성자로 기록되는 값 | `git config user.name` / `git config user.email` | 커밋 author, 작업 히스토리 폴더 `history/{작업자}/`, frontmatter `author` |
| **gh 인증 계정** | GitHub 작업(PR 생성/머지) 수행 신원 | `gh api user --jq .login` | PR 생성·머지 등 GitHub API 작업 |

> ⚠️ **Claude 로그인 ≠ git commit 신원.** Claude 로그인 사용자와 이 머신의 git config 작성자가 다를 수 있다. 커밋하면 author 는 **git config 값**으로 찍힌다(Claude 로그인 사용자가 아님).

## 2. 사용법

1. **AI(읽기/도출)**: 신원이 필요하면 **셸로 직접 도출**하는 것을 1순위로 한다(가장 정확·최신).
   ```bash
   git config user.name        # git commit 작성자명
   git config user.email       # git commit 이메일
   gh api user --jq .login     # gh 인증 계정 (GitHub 작업 신원)
   ```
   - `history/{작업자}/` 의 `{작업자}`, frontmatter `author` 는 **항상 `git config user.name`** 에서 도출한다(하드코딩 금지).
2. **SET_USER.md(값 파일)**: 이 머신의 스냅샷·주의 메모가 필요할 때만 본다(예: "이 gh 계정은 PR 관리자라 머지 금지" 같은 도출 불가 사실). **커밋하지 않는다.**
3. **새 머신/작업자**: `SET_USER.md` 가 없으면 위 셸 명령으로 값을 확인해 새로 만든다(`.gitignore` 대상이라 레포에 없는 게 정상).

> 검증: `SET_USER.md` 가 추적되지 않는지 확인 — `git check-ignore SET_USER.md` 가 경로를 출력해야 한다.

## 3. 키 의미 사전 (SET_USER.md 의 키)

| 키 | 의미 | 출처 / 도출 |
|---|---|---|
| `CLAUDE_LOGIN` | Claude 로그인 사용자(실제 작업 지시자) | Claude Code 세션 `userEmail` |
| `GIT_USER_NAME` | git commit 작성자명 (= `history/{작업자}/`, `author`) | `git config user.name` |
| `GIT_USER_EMAIL` | git commit 이메일 | `git config user.email` |
| `GH_LOGIN` | gh 인증 계정 (GitHub PR 작업 신원) | `gh api user --jq .login` |
| `GH_IS_PR_ADMIN` | gh 계정이 **PR 관리자**인지 여부(머지 권한·금지 규칙에 영향) | 도출 불가 — 사람이 기록 |

## 4. 주의점 (도출만으로는 알 수 없는 사실)

- **gh 계정이 PR 관리자(`weppy1225` 등)이면 Claude 는 PR 머지를 하지 않는다.** 규칙상 "PR 생성은 작업자, 머지는 PR 관리자"인데, 이 머신의 gh 인증이 관리자 계정이면 `gh pr create` 시 관리자 이름으로 PR 이 열린다. 작업자 신원으로 PR 을 열어야 하면 gh 재로그인이 필요하다. (상세 → `.claude/rules/git-workflow.md §2~§3`)
- 커밋·푸시·PR 생성은 **사용자가 명시 요청할 때만** 한다. PR 머지는 사용자가 명시 요청한 경우에만 예외적으로 한다.
- 다른 작업자 머신에선 위 모든 값이 **각자의 값**이다. 이 파일·`SET_USER.md` 의 특정 계정명을 일반화하지 않는다.
