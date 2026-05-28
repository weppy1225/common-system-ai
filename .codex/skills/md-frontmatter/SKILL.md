---
name: md-frontmatter
description: Use when creating or meaningfully modifying Markdown files that may be consumed by AI agents, including official agent instructions, session memory, rules, commands, skills, and project docs.
metadata:
  short-description: Add AI-agent-friendly Markdown frontmatter
---

# Markdown Frontmatter

Use this skill when creating or meaningfully modifying Markdown files that may be consumed by Codex, Claude, repository agents, or slash-command workflows.

Primary guide:
- [`../../rules/md-frontmatter.md`](../../rules/md-frontmatter.md)

Execution notes:
- Read the linked rule before adding frontmatter.
- Add frontmatter only when the Markdown document is new or its purpose, scope, workflow role, or output contract changes.
- Do not add frontmatter for trivial typo, link, or formatting-only edits.
- Do not guess metadata. Use only values verified from repository files, command documents, code, or DB documents.
- For official Codex or Claude Code files such as `SKILL.md`, use official fields first (`name`, `description`, and documented tool-specific fields). Treat WMS fields as internal metadata and include `wms_meta: true` when using them.
