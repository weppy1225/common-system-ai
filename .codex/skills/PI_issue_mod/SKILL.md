---
name: PI_issue_mod
description: "【레드마인 이슈 작업이력 수정】 사용자가 지정한 레드마인 이슈에 대해 진행율(`done_ratio`)과 작업이력 노트(`notes`)를 업데이트합니다. `/PI_issue_mod {이슈번호} {진행율} {작업내역}` 형식으로 실행하며, 첫 번째 토큰이 이슈번호(숫자), 두 번째 토큰이 진행율(0~100), 세 번째 토큰부터 끝까지가 작업내역(공백 포함)입니다. 내부적으로 `mcp__redmine__updateIssue` MCP 도구를 호출합니다. 레드마인 이슈 업데이트, 진행율 변경, 작업 노트 추가, 레드마인 코멘트 추가 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"이슈 진행율 업데이트해줘\", \"레드마인 작업 코멘트 추가\", \"이슈 #123 진행율 80으로 바꿔줘\", \"PI_issue_mod 실행해줘\" 라고 말해도 이 스킬을 사용합니다. 단, 단순히 작업시간(hours)만 등록하는 경우에는 PI_time_reg 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/PI_issue_mod as the source skill"
---

# PI_issue_mod

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/PI_issue_mod/SKILL.md](../../../.claude/skills/PI_issue_mod/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/PI_issue_mod/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/PI_issue_mod/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.