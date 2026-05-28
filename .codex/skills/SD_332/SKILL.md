---
name: SD_332
description: "【공통코드정의서 엑셀 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔하여 DB(PostgreSQL/MSSQL/MySQL/MariaDB)에 직접 접속하고, sm_comm_h/sm_comm_d 공통코드를 추출하여 PI_113-공통코드정의서 엑셀 파일을 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. /SD_332 {디렉토리경로} 형식으로 실행합니다. 공통코드정의서 작성, 공통코드 테일러링, 공통코드 엑셀 추출, DB 공통코드를 산출물로 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"공통코드정의서 만들어줘\", \"공통코드 뽑아줘\", \"공통코드 엑셀로 추출\", \"PI_113 산출물 만들어줘\", \"공통코드 테일러링 해줘\", \"SD_332 실행해줘\", \"WSL에서 공통코드정의서 만들어줘\", \"Linux에서 공통코드 뽑아줘\" 라고 말해도 이 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/SD_332 as the source skill"
---

# SD_332

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/SD_332/SKILL.md](../../../.claude/skills/SD_332/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/SD_332/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/SD_332/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.