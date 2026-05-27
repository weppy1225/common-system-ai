---
name: TT_543_BASH
description: 【운영자매뉴얼 PPTX 생성 (WSL/Linux/Mac)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 프론트엔드 + 백엔드 디렉토리를 자동 스캔하여 운영자/관리자 메뉴만 식별하고 Playwright(헤드리스, 한국어 로케일 ko-KR)로 화면 캡처 후 python-pptx 기반의 운영자매뉴얼 PPTX를 자동 생성합니다. TT_543(Windows 기본)과 동일한 기능을 WSL/Linux/Mac 환경에서 Bash로 실행합니다. /TT_543_BASH 형식으로 실행하며 FE 경로·BE 경로·고객사명·BASE_URL·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx 단일 파일로 떨어집니다. 운영자 매뉴얼 작성, 관리자 매뉴얼 작성 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "WSL에서 운영자매뉴얼 만들어줘", "Linux에서 관리자 매뉴얼 PPT 뽑아줘", "TT_543_BASH 실행해줘" 라고 말해도 이 스킬을 사용합니다. Windows 환경에서는 /TT_543 을 사용합니다. PC 사용자 매뉴얼이 필요한 경우는 /TT_541_BASH, PDA 사용자 매뉴얼이 필요한 경우는 /TT_542_BASH 를 사용합니다.
type: skill
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 운영자 매뉴얼 PPTX 자동 생성 스킬 (WSL/Linux/Mac) [TT_543_BASH]

대상 FE/BE 프로젝트: **$ARGUMENTS**

TT_543의 WSL/Linux/macOS 등가 버전이다. 동일한 스크립트(`scripts/`)를 사용하며, PowerShell 대신 Bash로 실행한다.

---

## 경로 감지 (Bash)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then
    PROJ_CODE="${BASH_REMATCH[1]}"
else
    PROJ_CODE="cloud"
fi
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"

BASE="$DOC_ROOT"
TEMPLATE="$BASE/template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx"
TMP_DIR="$BASE/output/05 이행(TT)/tmp_543"
SCRIPTS="$BASE/.claude/skills/TT_543_BASH/scripts"
OUT_FILE="$BASE/output/05 이행(TT)/TT_543_운영자매뉴얼_{고객사명}.pptx"
```

## 실행 스크립트

TT_543과 동일한 scripts/ 디렉토리의 Node.js/Python 스크립트를 Bash에서 직접 호출한다.

```bash
cd "$DOC_ROOT"
node ".claude/skills/TT_543_BASH/scripts/01_scan_admin_menus.js" "{FE경로}" "{BE경로}"
node ".claude/skills/TT_543_BASH/scripts/02_capture_screens.js"
python3 ".claude/skills/TT_543_BASH/scripts/03_make_pptx.py"
```

## 나머지 워크플로우

TT_543 SKILL.md와 동일. 경로 구분자만 `\` → `/` 로 변경한다.

> Windows 환경에서는 `/TT_543` 스킬을 사용한다.
