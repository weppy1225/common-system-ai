---
title: Markdown Frontmatter Rule for Codex
description: WMS 계열 모든 프로젝트에서 Codex가 사용할 Markdown 문서에 YAML frontmatter를 작성하는 규칙
version: 1.0.0
status: active
applies_to:
  - "**/*.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "GEMINI.md"
  - "claude-memory-type.md"
  - ".codex/**/*.md"
  - ".claude/**/*.md"
  - ".agents/**/*.md"
  - "DEV_DOC/**/*.md"
  - "docs/**/*.md"
  - "output-doc/**/*.md"
agent_usage: rule
tags:
  - markdown
  - frontmatter
  - codex
  - wms
---

# Markdown Frontmatter 작성 규칙

AI 에이전트가 사용할 가능성이 높은 Markdown 파일을 새로 작성하거나 의미 있게 수정할 때는 문서 맨 앞에 YAML frontmatter를 둔다.

적용 기준은 `.claude/rules/md-frontmatter.md`와 동일하다.

주의:
- WMS 내부 메타데이터는 Claude Code/Codex 공식 frontmatter 스키마가 아니다.
- `project`, `agent_usage`, `applies_to`, `related`, `validation`, `menu_code` 같은 WMS 내부 필드를 쓰면 `wms_meta: true`를 포함한다.
- Codex Skill의 `SKILL.md`는 공식적으로 `name`과 `description`을 포함해야 한다.
- Codex `AGENTS.md`는 공식 frontmatter 스키마가 없다.