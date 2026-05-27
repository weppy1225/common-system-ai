---
name: SD_331_BASH
description: 【테이블정의서 엑셀 생성 (실DB 접속, WSL/Linux/Mac)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 직접 접속하고, 시스템 카탈로그에서 스키마를 추출하여 SD.212-테이블정의서 엑셀 파일을 자동 생성합니다. /SD_331_BASH {디렉토리경로} 형식으로 실행합니다. 살아있는 DB에 직접 붙어 information_schema/pg_catalog/sys.*/user_* 등을 조회해 테이블·컬럼·인덱스·제약조건·FK를 뽑아냅니다. 사용자가 "DB에서 직접 테이블정의서 뽑아줘", "라이브 DB 스키마 엑셀로", "운영 DB 접속해서 테이블 명세서", "SD_331_BASH 실행해줘" 라고 말하면 이 스킬을 사용합니다. Windows 환경에서는 기본 SD_331 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# 테이블정의서 자동 생성 (실 DB 접속, WSL/Linux/Mac) [SD_331_BASH]

대상 디렉토리: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리에서 DB 접속 설정 파일을 자동 스캔하고, 검출된 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 **직접 접속**하여 시스템 카탈로그에서 스키마(테이블·컬럼·인덱스·제약조건·FK)를 추출한 뒤,
`template/03 설계(SD)/SD.212-테이블정의서.xlsx` 템플릿을 기반으로
`output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx` 파일을 생성한다.

> **클라이언트 도구 불필요**: psql/mysql/sqlcmd/sqlplus 같은 OS 클라이언트가 설치되지 않은 환경을 가정한다. Python 라이브러리(psycopg2-binary / pymysql / pymssql / oracledb)만으로 직접 접속한다.

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
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"

TEMPLATE="$DOC_ROOT/template/03 설계(SD)/SD.212-테이블정의서.xlsx"
OUTPUT_DIR="$DOC_ROOT/output/03 설계(SD)"
TMP_DIR="$DOC_ROOT/output/03 설계(SD)/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/SD_331_BASH/scripts"
```

`OUTPUT_DIR`과 `TMP_DIR`이 없으면 생성한다.

---

## 단계별 워크플로우

### 1단계 — 디렉토리 스캔으로 DB 접속정보 후보 추출

**스크립트**: `scripts/01_scan_config.py`

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_331_BASH/scripts/01_scan_config.py "{디렉토리경로}"
```

스캔 대상 파일 패턴 및 추출 키는 SD_331 (Windows 기본)과 동일하다.

---

### 2단계 — 사용자 확인 및 누락 정보 보강

`db_candidates.json`을 Read 툴로 읽어 후보 목록을 확인한다.

1. **후보가 0개**: AskUserQuestion으로 DB 종류와 접속정보를 직접 입력 받는다.
2. **후보가 1개**: 사용자에게 진행할지 확인한다. password가 누락되었으면 별도로 묻는다.
3. **후보가 2개 이상**: AskUserQuestion으로 어떤 후보를 사용할지 선택받는다.

확정된 접속정보를 `output/03 설계(SD)/tmp/db_target.json`로 저장한다.

---

### 3단계 — 의존성 확인 및 자동 설치

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_331_BASH/scripts/02_extract_schema.py --check-only
```

누락된 라이브러리를 `python3 -m pip install --user`로 설치한 뒤 재검증한다.

---

### 4단계 — DB 접속 및 스키마 추출

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_331_BASH/scripts/02_extract_schema.py
```

**출력**: `output/03 설계(SD)/tmp/schema.json`

---

### 5단계 — Excel 생성

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
python3 .claude/skills/SD_331_BASH/scripts/03_generate_excel.py
```

**출력**: `output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx`

---

### 6단계 — 임시 파일 정리 (필수)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
rm -rf "$DOC_ROOT/output/03 설계(SD)/tmp"
```

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리 확정
- [ ] `tmp/db_candidates.json` 생성
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장)
- [ ] 누락된 password 확인 후 보강
- [ ] 필요한 Python 라이브러리 import 가능
- [ ] DB 연결 성공 및 `tmp/schema.json` 생성
- [ ] 출력 파일 생성
- [ ] `output/03 설계(SD)/tmp/` 폴더 삭제 완료

---

## 완료 보고 형식

```
✓ 테이블정의서 생성 완료 [SD_331_BASH]

대상 디렉토리: {디렉토리경로}
DB: {driver} {host}:{port}/{database} (schema={schema})
출력파일: output/03 설계(SD)/SD.212-테이블정의서_{DB명}_{YYMMDD}.xlsx

수집 통계:
  - 테이블:     N개
  - 컬럼:       N개
  - 인덱스:     N개
  - 제약조건:   N개
  - FK:         N개
```
