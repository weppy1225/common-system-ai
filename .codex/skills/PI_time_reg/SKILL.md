---
name: PI_time_reg
description: "【레드마인 이슈 작업시간 등록】 사용자가 지정한 레드마인 이슈에 대해 오늘 날짜(`spent_on`) 기준으로 작업시간(`hours`)과 작업내역 코멘트(`comments`)를 등록합니다. `/PI_time_reg {이슈번호} {시간} {작업내역}` 형식으로 실행하며, 첫 번째 토큰이 이슈번호(숫자, `#` 접두사 허용), 두 번째 토큰이 시간(소수점 허용, 예: 4, 1.5, 0.5), 세 번째 토큰부터 끝까지가 작업내역(공백 포함)입니다. 내부적으로 `mcp__redmine__createTimeEntry` MCP 도구를 호출합니다. 레드마인 시간 등록, 작업시간 입력, 공수 등록, 타임 엔트리 생성 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"작업시간 등록해줘\", \"레드마인 공수 4시간 등록\", \"PI_time_reg 실행해줘\", \"#16129 1.5시간 등록해줘\" 라고 말해도 이 스킬을 사용합니다. 단, 진행율(done_ratio)이나 이슈 노트(notes) 업데이트가 필요한 경우에는 PI_issue_mod 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/PI_time_reg as the source skill"
---

# PI_time_reg

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/PI_time_reg/SKILL.md](../../../.claude/skills/PI_time_reg/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/PI_time_reg/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/PI_time_reg/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.