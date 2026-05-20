---
name: TT_550_BASH
description: 【DB 이관용 SQL 준비물 생성 (실DB 접속, WSL/Linux/Mac, Python 전용)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 백엔드 디렉토리의 DB 설정 파일을 자동 스캔해 인하우스 PostgreSQL DB에 접속하고, `COMMENT ON TABLE` 의 `@migrate:` 마커가 달린 테이블만 자동 수집하여 그룹별 INSERT SQL 파일과 메타데이터(manifest.json)를 생성합니다. TT_550(Windows 기본)과 동일한 기능을 WSL/Linux/Mac 환경에서 Bash로 실행합니다. WSL/Linux/Mac 에서는 PowerShell 모드 없이 Python(psycopg2) 모드만 사용합니다. /TT_550_BASH 형식으로 실행하며 백엔드 경로·고객사명·dump 그룹은 실행 시 묻습니다. DB 이관용 SQL 준비물 생성, dump SQL 파일 만들기, 공통코드/마스터 데이터 INSERT 스크립트 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "WSL에서 DB 이관 SQL 만들어줘", "Linux에서 공통코드 데이터 dump 떠줘", "TT_550_BASH 실행해줘" 라고 말해도 이 스킬을 사용합니다. Windows 환경에서는 /TT_550 을 사용합니다. DDL(스키마) 만 필요하면 /SD_333_BASH, DB 이관계획서 엑셀이 필요하면 /TT_551(이 스킬 실행 후 호출)을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 이관용 SQL 준비물 생성 (실 DB 접속, WSL/Linux/Mac) [TT_550_BASH]

TT_550의 WSL/Linux/macOS 등가 버전이다. PowerShell 없이 Python(psycopg2) + bash만 사용한다.

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
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"

BASE="$DOC_ROOT"
SCRIPTS="$BASE/.claude/skills/TT_550_BASH/scripts"
```

## 실행 환경 체크

```bash
python3 -c "import psycopg2" 2>/dev/null || {
    echo "ERROR: psycopg2-binary 필요"
    echo "  pip3 install --user psycopg2-binary"
    exit 1
}
```

## 실행 스크립트

TT_550과 동일한 scripts/py/ 디렉토리의 Python 스크립트를 Bash에서 직접 호출한다.

```bash
cd "$DOC_ROOT"
python3 ".claude/skills/TT_550_BASH/scripts/_scan_config.py" "{BE경로}" "{출력경로}"
python3 ".claude/skills/TT_550_BASH/scripts/py/01_collect_markers.py" ...
python3 ".claude/skills/TT_550_BASH/scripts/py/02_dump_data.py" ...
python3 ".claude/skills/TT_550_BASH/scripts/py/03_write_manifest.py" ...
```

## 나머지 워크플로우

TT_550 SKILL.md와 동일. PowerShell 모드는 지원하지 않으며 Python(psycopg2) 모드만 사용한다.

> Windows 환경에서는 `/TT_550` 스킬을 사용한다.
