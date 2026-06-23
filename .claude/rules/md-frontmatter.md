---
title: Markdown Frontmatter Rule
description: 모든 프로젝트에서 AI 에이전트가 사용할 Markdown 문서에 YAML frontmatter를 작성하는 규칙
version: 1.0.0
status: active
paths:
  - "**/*.md"
agent_usage: rule
tags:
  - markdown
  - frontmatter
  - ai-agent
---

# Markdown Frontmatter 작성 규칙

모든 프로젝트(`{프로젝트}-ai`, `{프로젝트}-be`, `{프로젝트}-fe`)에서 AI 에이전트가 사용할 가능성이 높은 Markdown 파일을 새로 작성하거나 의미 있게 수정할 때는 YAML frontmatter를 문서 맨 앞에 둔다.

기존 문서에 frontmatter가 없더라도 단순 오탈자 수정, 링크 보정, 포맷 정리만 하는 경우에는 억지로 추가하지 않는다. 문서의 목적, 범위, 사용 시점, 에이전트 동작, 산출물 계약이 바뀌는 수정이면 추가한다.

## 기본 원칙

- frontmatter는 문서 첫 줄에서 `---`로 시작하고 `---`로 닫은 뒤 본문 제목을 둔다.
- AI가 문서를 고를 때 필요한 정보만 넣는다.
- 값은 추정하지 않는다. 실제 파일, 명령 문서, 코드, DB 문서에서 확인한 값만 적는다.
- key는 영문 snake_case를 사용한다.
- 배열 값은 YAML list를 사용한다.
- `author`는 **문서를 작성·수정하는 시점의 git 자격증명**에서 동적으로 도출한다. 값을 하드코딩하지 않는다. 이유: 작성자마다·머신마다 git 계정이 다르므로 고정값을 적으면 틀린다.
  - 도출: `git config user.name` (필요 시 `git config user.email` 병기).
  - 표기: `author: <user.name>` 또는 `author: <user.name> <user.email>`.
  - 신규 작성 시 추가한다. 의미 있는 수정 시 기존 `author`는 유지하고 `last_modified_by`에 수정자 git 자격증명을 적는다(원작자 보존).
- `repo_role`은 문서가 속한 레포의 **역할**만 적는다(`ai-hub` / `be` / `fe`). 브랜드·도메인이 들어간 실제 레포명(`common-system-ai` 등)을 넣지 않는다 — 리브랜딩(예: cloud→bandai) 시 문서 일괄 수정이 발생하기 때문이다. 실제 레포 정체성은 git·폴더명에서 런타임 도출한다(→ `repo-paths.md`).
- 경로는 저장소 루트 기준 상대 경로를 사용한다.
- 민감정보, DB 접속정보, 토큰, 고객 데이터는 넣지 않는다.
- Claude Code와 Codex가 공식적으로 해석하는 frontmatter와 내부 확장 메타데이터를 섞어 설명하지 않는다.

## 제외 대상

- 단순 메모, 임시 복붙, 짧은 일회성 노트
- 외부 도구가 frontmatter를 허용하지 않는 Markdown
- 생성물이거나 벤더 문서라 사람이 직접 관리하지 않는 파일
- 기존 문서의 오탈자, 링크, 포맷만 고치는 경우

## 기본 템플릿

아래 템플릿은 내부 문서 메타데이터다. Claude Code나 Codex의 공식 frontmatter 스키마가 아니다.

```yaml
---
title: 문서 제목
description: AI 에이전트가 이 문서를 언제 써야 하는지 한 문장으로 설명
status: draft | active | deprecated | archived
version: 1.0.0
author: <git config user.name>        # 작성 시점 git 자격증명에서 도출, 하드코딩 금지
repo_role: ai-hub | be | fe
applies_to:
  - path/or/glob
agent_usage: instruction | memory | rule | workflow | command | skill | agent | spec | plan | task | output | reference
tags:
  - keyword
---
```

## 선택 필드

아래 필드는 내부 확장 필드다. 문서 성격상 필요할 때만 추가한다.

```yaml
source_of_truth: true
related:
  - path/to/related.md
depends_on:
  - path/to/prerequisite.md
inputs:
  - 입력 문서 또는 데이터
outputs:
  - 생성되는 산출물
validation:
  - 검증 방법 또는 실행 명령
menu_code: md8000
domain: inbound | outbound | inventory | master | system | interface | common | frontend | document
last_modified_by: <git config user.name>   # 의미 있는 수정 시 수정자(원작자 author는 유지)
last_verified: YYYY-MM-DD
```

## 공식 frontmatter와 내부 확장 필드

- Claude Code Skill의 `SKILL.md`는 공식 필드인 `description`을 우선 사용하고, 필요 시 `name`, `when_to_use`, `allowed-tools` 등 공식 필드를 사용한다.
- Codex Skill의 `SKILL.md`는 공식적으로 `name`과 `description`을 포함해야 한다.
- Codex App UI 메타데이터, invocation policy, tool dependency는 `SKILL.md` frontmatter가 아니라 `agents/openai.yaml`에 둔다.
- Codex `AGENTS.md`는 공식 frontmatter 스키마가 없다. 내부 확장 필드는 필요할 때만 최소로 붙인다.

## 작성 체크리스트

- `description`만 읽어도 AI가 문서 사용 시점을 판단할 수 있는가?
- `agent_usage`가 문서의 역할을 정확히 나타내는가?
- `author`를 `git config user.name`에서 도출했는가? (고정값 하드코딩 금지)
- `SKILL.md`는 Claude Code/Codex 공식 필드(`name`, `description` 등)를 우선 사용했는가?
- `repo_role`이 레포 역할(`ai-hub`/`be`/`fe`)로 적혔는가? (실제 레포명·브랜드명을 넣지 않았는가?)
- `applies_to`, `inputs`, `outputs`, `related` 경로가 실제 근거와 맞는가?
- 민감정보나 확인되지 않은 값이 없는가?
