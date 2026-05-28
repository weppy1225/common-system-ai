---
name: PI_411
description: "【프로그램 소스 ZIP 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 로컬 git 저장소 디렉토리의 전체 코드를 `git archive`(또는 `gh CLI`)로 ZIP 파일로 패키징하여 `output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip` 형식으로 자동 저장합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /PI_411 형식으로 실행하며 디렉토리·고객사명·패키징 모드(full|handoff)는 실행 시 묻습니다. 프로그램 소스 ZIP 생성, 소스 코드 패키징, 산출물용 소스 압축, 고객사 인계용 소스 ZIP 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"소스 ZIP 만들어줘\", \"프로그램 소스 압축해줘\", \"PI_411 실행해줘\", \"산출물용 소스 zip 뽑아줘\", \"git 저장소 zip으로 다운로드해줘\", \"고객 인계용 소스 압축\", \"WSL에서 소스 ZIP 만들어줘\", \"Linux에서 소스 압축해줘\" 라고 말해도 이 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/PI_411 as the source skill"
---

# PI_411

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/PI_411/SKILL.md](../../../.claude/skills/PI_411/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/PI_411/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/PI_411/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.