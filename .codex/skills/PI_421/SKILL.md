---
name: PI_421
description: "【단위테스트 보고서 엑셀 생성 (JUnit 기반, Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 로컬 백엔드(Java/Kotlin) 디렉토리를 자동 스캔하여 모든 JUnit 테스트 코드(@Test 메서드)를 추출하고, 모든 테스트가 통과(결과=O)되었다는 가정 하에 단위테스트보고서 엑셀을 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. 템플릿은 `template/04 구현(PI)/PI_212-단위테스트보고서.xlsx` 를 그대로 복사해 사용하며, `output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx` 로 저장합니다. /PI_421 형식으로 실행하며 디렉토리·고객사명·담당자명은 실행 시 묻습니다. JUnit 4(`org.junit.Test`) 와 JUnit 5(`org.junit.jupiter.api.Test`) 양쪽을 모두 인식하고, `@DisplayName` 이 있으면 우선 사용합니다. 주석 처리된(`//@Test`) 테스트는 제외합니다. 단위테스트 보고서 작성, JUnit 테스트 목록 정리, 백엔드 단위테스트 산출물 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"단위테스트보고서 만들어줘\", \"JUnit 테스트 정리해줘\", \"단위테스트 산출물 뽑아줘\", \"PI_421 실행해줘\", \"BE 단위테스트 엑셀\", \"WSL에서 단위테스트보고서 만들어줘\", \"Linux에서 JUnit 보고서 엑셀로\" 라고 말해도 이 스킬을 사용합니다. 단, 통합테스트(PI_214) 산출물이 필요한 경우에는 별도 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/PI_421 as the source skill"
---

# PI_421

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/PI_421/SKILL.md](../../../.claude/skills/PI_421/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/PI_421/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/PI_421/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.