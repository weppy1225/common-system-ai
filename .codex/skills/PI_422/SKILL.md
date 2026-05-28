---
name: PI_422
description: "【통합테스트보고서 엑셀 생성 (Windows/WSL/Linux/Mac 통합)】 dist/ 폴더의 ui.md 파일을 스캔하여 메뉴별 통합테스트 시나리오를 자동 생성하고, template/04 구현(PI)/PI.214-통합테스트보고서.xlsx 템플릿에 채워 output/04 구현(PI)/PI.422_통합테스트보고서_{고객사명}.xlsx 로 저장합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /PI_422 형식으로 실행하며 고객사명·담당자·테스트 기간은 실행 시 묻습니다. 통합테스트 보고서 작성, 테스트 시나리오 정리, 통합테스트 결과 엑셀 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"통합테스트보고서 만들어줘\", \"통합테스트 엑셀 만들어줘\", \"PI_422 실행해줘\", \"WSL에서 통합테스트보고서 만들어줘\", \"Linux에서 테스트 시나리오 엑셀로\" 라고 말해도 이 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/PI_422 as the source skill"
---

# PI_422

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/PI_422/SKILL.md](../../../.claude/skills/PI_422/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/PI_422/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/PI_422/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.