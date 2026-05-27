---
name: SD_332_BASH
description: 【공통코드정의서 엑셀 생성 (WSL/Linux/Mac)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔하여 DB(PostgreSQL/MSSQL/MySQL/MariaDB)에 직접 접속하고, sm_comm_h/sm_comm_d 공통코드를 추출하여 PI_113-공통코드정의서 엑셀 파일을 자동 생성합니다. /SD_332_BASH {디렉토리경로} 형식으로 실행합니다. 공통코드정의서 작성, 공통코드 엑셀 추출, DB 공통코드를 산출물로 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "공통코드정의서 만들어줘", "공통코드 뽑아줘", "SD_332_BASH 실행해줘" 라고 말해도 이 스킬을 사용합니다. Windows 환경에서는 기본 SD_332 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# 공통코드정의서 자동 생성 (WSL/Linux/Mac) [SD_332_BASH]

대상 디렉토리: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리에서 DB 접속 설정 파일을 자동 스캔하여 DB(PostgreSQL/MySQL/MariaDB/MSSQL)에 직접 접속한다.
`sm_comm_h`(공통코드 그룹)과 `sm_comm_d`(상세코드)를 조회하여
`template/04 구현(PI)/PI_113-공통코드정의서.xlsx` 템플릿에 데이터를 채워 넣고
`output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx` 파일을 생성한다.

---

## 사전 준비

### 인자 확정

`$ARGUMENTS`가 비어 있으면 사용자에게 디렉토리 경로를 물어본다.

### 경로 정의 (동적)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"

TEMPLATE="$DOC_ROOT/template/04 구현(PI)/PI_113-공통코드정의서.xlsx"
OUTPUT_DIR="$DOC_ROOT/output/04 구현(PI)"
TMP_DIR="$DOC_ROOT/output/04 구현(PI)/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/SD_332_BASH/scripts"
```

`OUTPUT_DIR`과 `TMP_DIR`이 없으면 생성한다.

---

## 단계별 워크플로우

### 1단계 — DB 접속정보 스캔

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_332_BASH/scripts/01_scan_db_config.py "{디렉토리경로}"
```

**출력**: `output/04 구현(PI)/tmp/db_candidates.json`

---

### 2단계 — 사용자 확인 및 비밀번호 보강

`db_candidates.json`을 Read 툴로 읽어 후보를 확인한다.

1. **후보가 0개**: AskUserQuestion으로 접속정보를 직접 입력 받는다.
2. **후보가 1개**: 진행 확인 + password 누락 시 별도로 묻는다.
3. **후보가 2개 이상**: 선택 받는다.

확정된 접속정보를 `output/04 구현(PI)/tmp/db_target.json`로 저장한다.

---

### 3단계 — Python 의존성 자동 설치

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_332_BASH/scripts/02_extract_common_codes.py --check-only
```

---

### 4단계 — 공통코드 추출

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_332_BASH/scripts/02_extract_common_codes.py
```

**출력**: `output/04 구현(PI)/tmp/common_codes.json`

---

### 5단계 — Excel 생성

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_332_BASH/scripts/03_generate_excel.py
```

**출력**: `output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx`

---

### 6단계 — 임시 파일 정리 (필수)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
rm -rf "$DOC_ROOT/output/04 구현(PI)/tmp"
```

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리 확정
- [ ] `tmp/db_candidates.json` 생성
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장)
- [ ] 필요한 Python 라이브러리 import 가능
- [ ] DB 연결 성공 및 `tmp/common_codes.json` 생성
- [ ] 출력 파일 생성
- [ ] `3.코드그룹` / `4.상세코드` 시트에 DB 데이터가 채워짐
- [ ] `output/04 구현(PI)/tmp/` 폴더 자동 삭제 완료

---

## 완료 보고 형식

```
✓ 공통코드정의서 생성 완료 [SD_332_BASH]

대상 디렉토리: {디렉토리경로}
DB:           {driver} {host}:{port}/{database} (profile={profile})
출력파일:     output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx

수집 통계:
  - 코드그룹(SM_COMM_H): N개
  - 상세코드(SM_COMM_D): N개

임시 파일 정리: tmp/ 삭제 완료
```
