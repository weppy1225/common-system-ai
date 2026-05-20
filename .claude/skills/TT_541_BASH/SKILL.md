---
name: TT_541_BASH
description: 【PC 사용자매뉴얼 PPTX 생성 (WSL/Linux/Mac)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 프론트엔드 프로젝트의 실제 dev/배포 서버에 Playwright(헤드리스, 데스크탑 1440×900)로 접속하여 PC(데스크탑) 사용자 메뉴별 화면을 캡처하고, template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx 를 base로 python-pptx 기반의 PC 사용자매뉴얼 PPTX를 자동 생성합니다. TT_541(Windows 기본)과 동일한 기능을 WSL/Linux/Mac 환경에서 Bash로 실행합니다. /TT_541_BASH 형식으로 실행하며 FE 프로젝트 경로·고객사명·BASE_URL·메뉴 목록·로그인 정보는 실행 시 묻습니다. 산출물은 output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx 단일 파일로 떨어집니다. PC 사용자 매뉴얼 작성, 데스크탑 사용자용 매뉴얼, 화면 캡처 PPT, WMS PC 사용자 매뉴얼 PPTX 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "WSL에서 PC 사용자매뉴얼 만들어줘", "Linux에서 사용자 매뉴얼 PPT 뽑아줘", "TT_541_BASH 실행해줘" 라고 말해도 이 스킬을 사용합니다. Windows 환경에서는 /TT_541 을 사용합니다. PDA 사용자 매뉴얼이 필요한 경우는 /TT_542_BASH, 운영자 매뉴얼은 /TT_543_BASH 을 사용합니다.
type: skill
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# PC 사용자 매뉴얼 PPTX 자동 생성 스킬 (WSL/Linux/Mac) [TT_541_BASH]

대상 FE 프로젝트: **$ARGUMENTS**

TT_541의 WSL/Linux/macOS 등가 버전이다. 동일한 스크립트(`scripts/`)를 사용하며, PowerShell 대신 Bash로 실행한다.

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

BASE="$DOC_ROOT"
TEMPLATE="$BASE/template/05 이행(TT)/사용자_매뉴얼_템플릿.pptx"
OUT_DIR="$BASE/output/05 이행(TT)"
TMP_DIR="$BASE/output/05 이행(TT)/tmp_541"
SCRIPTS="$BASE/.claude/skills/TT_541_BASH/scripts"
OUT_FILE="$BASE/output/05 이행(TT)/TT_541_사용자매뉴얼_PC_{고객사명}.pptx"
```

## 실행 스크립트

TT_541과 동일한 scripts/ 디렉토리의 Node.js/Python 스크립트를 사용한다.

```bash
# 의존성 설치 (최초 1회)
cd "$DOC_ROOT/.claude/skills/TT_541_BASH/scripts"
[ ! -f package.json ] && npm init -y
[ ! -d node_modules/playwright ] && npm install playwright
npx playwright install chromium 2>/dev/null

python3 -c "from pptx import Presentation; from PIL import Image" 2>/dev/null || \
    pip3 install --user python-pptx Pillow

# 1단계: FE 스캔
cd "$DOC_ROOT"
node ".claude/skills/TT_541_BASH/scripts/01_scan_project.js" "{FE경로}"

# 3단계: 화면 캡처
node ".claude/skills/TT_541_BASH/scripts/02_capture_screens.js"

# 4단계: PPTX 생성
python3 ".claude/skills/TT_541_BASH/scripts/03_make_pptx.py"
```

## 나머지 워크플로우

TT_541 SKILL.md와 동일. 경로 구분자만 `\` → `/` 로 변경한다.

> Windows 환경에서는 `/TT_541` 스킬을 사용한다.
