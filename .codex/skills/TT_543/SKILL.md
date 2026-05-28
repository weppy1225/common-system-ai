---
name: TT_543
description: "【운영자매뉴얼 PPTX 생성 (Windows/WSL/Linux/Mac 통합)】 사용자가 지정한 프론트엔드 + 백엔드 디렉토리를 자동 스캔하여 \"운영자(관리자)가 시스템·사용자·권한·메뉴·공통코드·사업장·센터·창고 등을 설정하는 관리성 메뉴\"만 자동 식별합니다. 식별된 메뉴들을 실제 dev/배포 서버에 Playwright(헤드리스, 한국어 로케일 ko-KR)로 접속하여 화면 캡처한 뒤, `template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx`를 base로 python-pptx 기반의 운영자매뉴얼 PPTX를 자동 생성합니다. 실행 환경(Windows PowerShell vs WSL/Linux/macOS Bash)을 자동 감지하여 해당 OS 분기 블록만 실행합니다. PPT 양식·레이아웃·색상·도형 라벨링은 모두 TT_541(PC 사용자매뉴얼) 스킬과 동일한 양식을 따르며, 차이점은 (1) 대상 메뉴를 운영자/관리자 메뉴로만 필터링, (2) 표지 제목이 \"운영자 매뉴얼\" 입니다. 라벨·테두리·배지·커넥터·설명패널은 모두 PPT 안의 도형(add_shape)으로 그려 PowerPoint 내부에서 직접 편집할 수 있도록 합니다. /TT_543 형식으로 실행하며 FE 경로·BE 경로·고객사명·BASE_URL·로그인 정보는 실행 시 묻습니다. 산출물은 `output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx` 단일 파일로 떨어집니다. 운영자 매뉴얼 작성, 관리자 매뉴얼 작성, 시스템 설정 매뉴얼, 운영자용 PPT 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 \"운영자매뉴얼 만들어줘\", \"관리자 매뉴얼 PPT 뽑아줘\", \"TT_543 실행해줘\", \"관리자 화면 캡쳐해서 PPT 만들어줘\", \"운영자 매뉴얼 산출물 만들어줘\", \"WSL에서 운영자 매뉴얼 만들어줘\", \"Linux에서 관리자 매뉴얼 캡쳐해줘\" 라고 말해도 이 스킬을 사용합니다. 단, PC 사용자 매뉴얼(입출고·재고 등 업무 화면)이 필요한 경우는 `/TT_541`, PDA 사용자 매뉴얼이 필요한 경우는 `/TT_542` 을 사용합니다."
metadata:
  short-description: "Use .claude/skills/TT_543 as the source skill"
---

# TT_543

This is a thin Codex wrapper. Source of truth: [../../../.claude/skills/TT_543/SKILL.md](../../../.claude/skills/TT_543/SKILL.md).

When this skill is used:
- Read ../../../.claude/skills/TT_543/SKILL.md first and follow that workflow.
- Resolve relative paths such as scripts/, evals/, or referenced assets from ../../../.claude/skills/TT_543/.
- Keep implementation and generated helper scripts in the .claude skill directory unless the user explicitly asks to fork them for Codex.