---
name: TT_541
description: "【PC 사용자매뉴얼 PPTX 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스, 데스크탑 1440×900)로 접속하여 PC(데스크탑) 사용자 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 PC 사용자매뉴얼 PPTX를 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. PDA(모바일) 메뉴는 자동 제외되며 별도 스킬 /TT_542 에서 처리합니다. PDA 자동 식별 기준: 라우트 경로에 `/bm/`·`/pda/`·`/mobile/` 포함, 부모 segment 가 `*m` 패턴(`iv3000m` 등), 메뉴코드 끝이 `m`(`ivad01m` 등). 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_541 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx 단일 파일로 떨어집니다. PC 사용자 매뉴얼 작성, 데스크탑 사용자용 매뉴얼, 화면 캡처 PPT, WMS PC 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"PC 사용자매뉴얼 만들어줘\", \"사용자 매뉴얼 PPT 뽑아줘\", \"TT_541 실행해줘\", \"데스크탑 화면 캡쳐해서 PPT 만들어줘\", \"PC 사용자 매뉴얼 산출물 만들어줘\", \"WSL에서 사용자 매뉴얼 PPT 만들어줘\", \"Linux에서 PC 매뉴얼 캡쳐해줘\" 라고 말해도 이 스킬을 사용합니다. 단, PDA 사용자 매뉴얼이 필요한 경우는 /TT_542, 운영자 매뉴얼은 /TT_543 을 사용합니다."
metadata:
  short-description: "Use .claude/skills/TT_541 as the source skill"
---

# TT_541

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/TT_541/SKILL.md](../../../.claude/skills/TT_541/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/TT_541/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/TT_541/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.