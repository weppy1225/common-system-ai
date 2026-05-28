---
name: UI_100
description: "【WMS 화면요건 문서(ui.md) 대화형 작성】 사용자에게 단계별로 질문해서 메뉴 기본정보·화면구조·검색조건·그리드·팝업·업무규칙을 수집하고 input/UI/ui-template.md 형식으로 dist/{메뉴코드}/ui.md를 생성한다. /UI_100 {메뉴코드} 형식으로 실행. \"ui.md 만들어줘\", \"화면요건 작성\", \"화면설계 전 요건 정리\", \"ui 스펙 만들어줘\" 요청 시 이 스킬을 사용한다. BE/FE 개발 시작 전 기획 단계에서 사용."
metadata:
  short-description: "Use .claude/skills/UI_100 as the source skill"
---

# UI_100

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/UI_100/SKILL.md](../../../.claude/skills/UI_100/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/UI_100/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/UI_100/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.