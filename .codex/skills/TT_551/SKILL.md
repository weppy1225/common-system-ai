---
name: TT_551
description: "【DB 이관 스크립트 실행 (Windows/WSL/Linux 통합)】 `input/TT.551/` 폴더의 PowerShell 마이그레이션 스크립트를 인수(V0~V10 또는 all)에 따라 실행합니다. 실행 환경(Windows 네이티브 PowerShell vs WSL/Linux의 `powershell.exe` 경유)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. `/TT_551` 또는 `/TT_551 V3` 형식으로 실행합니다. DB 이관 스크립트 실행, 공통코드/사업장/센터/창고/메뉴/사용자 이관, 전체 이관 실행, 함수·프로시저 재생성 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"TT_551 실행해줘\", \"DB 이관 스크립트 실행해줘\", \"이관 실행 V3\", \"migrate V5 실행\", \"V2 이관해줘\", \"공통코드 이관\", \"사업장 이관 실행\", \"전체 이관 실행\", \"migrate all 실행\", \"이관 스크립트 실행해줘\", \"WSL에서 DB 이관 실행해줘\", \"WSL에서 migrate V3 실행\" 라고 말해도 이 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/TT_551 as the source skill"
---

# TT_551

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/TT_551/SKILL.md](../../../.claude/skills/TT_551/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/TT_551/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/TT_551/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.