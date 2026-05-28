---
name: deploy
description: "【FTP 배포】 cloud-wms-doc 프로젝트의 dist/ 산출물(메인 진입점, 공통 메뉴/CSS/JS, 메뉴별 wireframe·mock-data·ui.md)을 zinDev FTP 서버(168.126.28.62)의 `/WEB_BASE/CLOUD_WMS_DOC/dist/` 경로로 업로드합니다. `/deploy {메뉴코드}` 형식으로 실행하면 해당 메뉴 폴더와 공통 자산을 함께 배포하고, 인자 없이 `/deploy` 만 실행하면 `git diff`로 최근 변경된 메뉴코드 폴더를 감지하여 배포 대상을 자동으로 정합니다(변경된 폴더가 여러 개면 선택 요청, 0개면 전체 배포 확인). 시스템에 `ftp` 클라이언트가 있으면 ftp 방식, 없으면 `curl` 방식으로 자동 선택해 업로드합니다. FTP 배포, 화면설계 산출물 배포, dist 업로드, 메뉴 배포, WMS 와이어프레임 배포 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"배포해줘\", \"FTP 올려줘\", \"dist 배포\", \"deploy 실행해줘\", \"화면 올려줘\", \"메뉴 배포해줘\" 라고 말해도 이 스킬을 사용합니다."
metadata:
  short-description: "Use .claude/skills/deploy as the source skill"
---

# deploy

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/deploy/SKILL.md](../../../.claude/skills/deploy/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/deploy/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/deploy/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.