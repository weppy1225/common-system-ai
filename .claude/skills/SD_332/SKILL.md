---
name: SD_332
description: 실DB 접속 → 공통코드정의서 엑셀 생성 (sm_comm_h/sm_comm_d, Windows/WSL/Linux 자동 감지). /SD_332 {디렉토리경로}
when_to_use: "공통코드정의서 만들어줘", "공통코드 뽑아줘", "공통코드 엑셀로 추출", "공통코드 테일러링 해줘" 요청 시 사용.
argument-hint: "[디렉토리경로]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, AskUserQuestion
---

# 공통코드정의서 자동 생성 (Windows/WSL/Linux/Mac 통합) [SD_332]

대상 디렉토리: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리에서 DB 접속 설정 파일(`application-local.properties`, `application-dev.properties`, `application*.yml` 등)을 자동 스캔하여 DB(PostgreSQL/MySQL/MariaDB/MSSQL)에 직접 접속한다.
`sm_comm_h`(공통코드 그룹)과 `sm_comm_d`(상세코드)를 조회하여
`template/04 구현(PI)/PI_113-공통코드정의서.xlsx` 템플릿에 데이터를 채워 넣고
`output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx` 파일을 생성한다.

> **클라이언트 도구 불필요**: psql/mysql/sqlcmd 같은 OS 클라이언트 없이 Python 라이브러리(psycopg2-binary / pymysql / pymssql)만으로 직접 접속한다. 라이브러리는 필요 시 `pip install --user`로 자동 설치한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션] — `python` 실행.
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션] — `python3` 실행.
```

> Python 스크립트(`scripts/*.py`)는 양쪽에서 공유. 차이는 `python` vs `python3` 명령뿐.

---

## 사전 준비 (공통)

### 인자 확정

`$ARGUMENTS`가 비어 있으면 사용자에게 디렉토리 경로를 물어본다. 경로가 존재하지 않으면 다시 물어본다.

### 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
TEMPLATE   = template/04 구현(PI)/PI_113-공통코드정의서.xlsx
OUTPUT_DIR = output/04 구현(PI)
TMP_DIR    = output/04 구현(PI)/tmp
SCRIPTS    = .claude/skills/SD_332/scripts
```

`OUTPUT_DIR` 과 `TMP_DIR` 이 없으면 생성한다.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$BeRoot = Join-Path $Workspace "wms-$ProjCode-be"
```

### W-1) DB 접속정보 스캔

```powershell
Set-Location $DocRoot
python .claude/skills/SD_332/scripts/01_scan_db_config.py "{디렉토리경로}"
```

### W-2) 의존성 확인

```powershell
python .claude/skills/SD_332/scripts/02_extract_common_codes.py --check-only
```

### W-3) 공통코드 추출

```powershell
python .claude/skills/SD_332/scripts/02_extract_common_codes.py
```

### W-4) Excel 생성

```powershell
python .claude/skills/SD_332/scripts/03_generate_excel.py
```

### W-5) 임시 파일 정리

```powershell
Remove-Item -Recurse -Force "$DocRoot\output\04 구현(PI)\tmp"
```

---

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"
```

### B-1) DB 접속정보 스캔

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_332/scripts/01_scan_db_config.py "{디렉토리경로}"
```

### B-2) 의존성 확인

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_332/scripts/02_extract_common_codes.py --check-only
```

### B-3) 공통코드 추출

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_332/scripts/02_extract_common_codes.py
```

### B-4) Excel 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/SD_332/scripts/03_generate_excel.py
```

### B-5) 임시 파일 정리

```bash
rm -rf "$DOC_ROOT/output/04 구현(PI)/tmp"
```

---

## 1단계 스캔 — DB 접속정보 후보 (공통)

`scripts/01_scan_db_config.py` 가 디렉토리(하위 포함)에서 다음 패턴을 인식하여 DB 접속 후보를 추출한다.

| 패턴 | 추출 키 |
|---|---|
| `application-{profile}.properties` | `db.url`, `db.username`, `db.password`, `db.driverClassName`, `spring.datasource.*` |
| `application-{profile}.yml` / `.yaml` | `spring.datasource.url/username/password` |
| `application.properties` / `application.yml` | 위와 동일 |
| `*.env`, `.env.*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL` |

**프로파일 우선순위**: `local` > `dev` > `default(application.*)` > 그 외(`prod`, `test`).
스크립트는 발견된 후보 전체를 JSON 배열에 담고 추천 후보 1개를 `recommended` 키로 표시한다.

**JDBC URL 파싱**: `db.url=jdbc:log4jdbc:postgresql://localhost:5433/wms_local` 같은 URL에서 driver/host/port/database/schema/options를 분해한다. `log4jdbc:` 프록시 prefix는 제거한다.

**driver 정규화**: `postgresql`/`postgres` → `postgresql`, `mysql`/`mariadb` → `mysql`, `sqlserver`/`mssql` → `mssql`.

---

## 1.5단계 — 사용자 확인 및 비밀번호 보강 (공통)

`db_candidates.json` 을 Read 툴로 읽어 후보 목록을 확인한다.

1. **후보 0개**: AskUserQuestion으로 DB 종류·host·port·database·user·password를 직접 입력 받는다.
2. **후보 1개**: 추천 정보로 진행할지 사용자에게 한 번 확인. password가 비어 있으면 별도로 묻는다.
3. **후보 2개 이상**: AskUserQuestion으로 어떤 후보(profile)를 사용할지 선택받는다.

확정된 접속정보를 `output/04 구현(PI)/tmp/db_target.json`로 저장한다.

```json
{
  "driver": "postgresql",
  "host": "localhost",
  "port": 5432,
  "database": "wms_local",
  "user": "wms_local_sa",
  "password": "...",
  "schema": "public",
  "profile": "local"
}
```

> 비밀번호는 평문으로 임시 저장된다. Excel 생성이 성공하면 마지막 단계에서 `tmp/` 폴더를 자동 삭제한다.

---

## 의존성 매핑 (공통)

| driver | Python 라이브러리 | 설치 명령 |
|---|---|---|
| postgresql | psycopg2 | `pip install --user psycopg2-binary` |
| mysql | pymysql | `pip install --user pymysql` |
| mssql | pymssql | `pip install --user pymssql` |
| (공통) | openpyxl | `pip install --user openpyxl` |

`--check-only` 옵션은 import 시도만 수행하고 누락된 라이브러리 목록을 출력. 누락 발견 시 즉시 설치 후 재검증.

---

## 공통코드 추출 상세 (공통)

`scripts/02_extract_common_codes.py` 가 수집하는 정보:

- **그룹(`sm_comm_h`)**: `biz_seq, comm_h_cd, comm_h_nm, user_cd_yn, inout_cd, use_yn` (전체 행, USE_YN 무관)
- **상세(`sm_comm_d`)**: `biz_seq, comm_h_cd, comm_d_cd, comm_d_nm, ref_h_cd, ref_d_cd, disp_no, disp_yn, use_yn`

조회 SQL은 driver별로 작성하지만 컬럼명은 동일하다. PostgreSQL은 lowercase, MSSQL은 quoted identifier `[sm_comm_h]`, MySQL은 backtick.

**정렬 규칙**:
- 그룹: `biz_seq, comm_h_cd`
- 상세: `biz_seq, comm_h_cd, disp_no, comm_d_cd`

JSON 구조:

```json
{
  "extracted_at": "YYYY-MM-DDTHH:MM:SS",
  "db": { "driver": "postgresql", "host": "...", "database": "..." },
  "groups": [
    {"biz_seq":1,"comm_h_cd":"DEL_YN","comm_h_nm":"삭제여부","user_cd_yn":"N","inout_cd":null,"use_yn":"Y"}
  ],
  "details": [
    {"biz_seq":1,"comm_h_cd":"DEL_YN","comm_d_cd":"Y","comm_d_nm":"삭제","ref_h_cd":null,"ref_d_cd":null,"disp_no":1,"disp_yn":"Y","use_yn":"Y"}
  ]
}
```

연결 실패·테이블 없음·권한 부족 시 명확한 메시지(시도한 쿼리, 응답 메시지)를 출력하고 종료한다.

---

## Excel 생성 상세 (공통)

`scripts/03_generate_excel.py` 가 수행하는 일:

1. 템플릿을 출력 경로로 복사. 파일명: `PI_113-공통코드정의서_{YYMMDD}.xlsx`.
2. **`3.코드그룹` 시트** (헤더: 7행, 데이터: 8행~):
   - 기존 샘플 데이터(8행 이후) 모두 비움.
   - DB에서 추출한 그룹 데이터를 8행부터 채움:
     - A: `biz_seq` (정수)
     - B: `comm_h_cd`
     - C: `comm_h_nm`
     - D: 코드설명 — 빈 값 (사용자 자유 칼럼)
     - G: `user_cd_yn`
     - H: `inout_cd`
     - I: `use_yn` 이 'N'이면 "미사용", 'Y'면 빈 값
3. **`4.상세코드` 시트** (헤더: 2~3행, 데이터: 4행~):
   - 기존 샘플 데이터(4행 이후) 모두 비움.
   - DB에서 추출한 상세 데이터를 4행부터 채움:
     - A=biz_seq, B=comm_h_cd, C=comm_d_cd, D=comm_d_nm, E=ref_h_cd, F=ref_d_cd, G=disp_no, H=disp_yn, I=use_yn
4. **`그룹SQL` / `상세SQL` 시트**: 기존 INSERT 수식이 그대로 동작하도록 데이터 행 수만큼 수식을 복제·확장.
5. **`표지` / `개정이력`**: 템플릿 그대로. `3.코드그룹` E4 작성일자는 오늘 날짜로 갱신.
6. **데이터 행 스타일 일관성**: 템플릿 한계를 넘는 새 행에 첫 데이터 행의 폰트·테두리·채움·정렬·셀 서식·행 높이를 복사 적용.
7. 저장.

```
[3.코드그룹]  (헤더: 7행, 데이터: 8행~)
A=biz_seq   B=comm_h_cd   C=comm_h_nm   D=(설명, 빈값)
G=user_cd_yn   H=inout_cd   I=비고(use_yn='N'이면 "미사용", 그 외 빈값)

[4.상세코드]  (헤더: 2~3행, 데이터: 4행~)
A=biz_seq   B=comm_h_cd   C=comm_d_cd   D=comm_d_nm
E=ref_h_cd  F=ref_d_cd    G=disp_no     H=disp_yn   I=use_yn

[그룹SQL]   3.코드그룹의 8~N행을 참조하는 수식, 행 수에 맞춰 자동 확장
[상세SQL]   4.상세코드의 4~M행을 참조하는 수식, 행 수에 맞춰 자동 확장
```

---

## 임시 파일 정리 (필수)

Excel 산출물이 정상적으로 생성된 직후 `output/04 구현(PI)/tmp/` 폴더를 즉시 삭제한다. 이 폴더에는 DB 비밀번호가 평문으로 저장된 `db_target.json` 이 포함되어 있으므로 작업 종료 시점에 반드시 제거해야 한다.

**규칙**:
- Excel 생성이 성공한 경우에만 자동 삭제한다. 중간 단계에서 실패하면 디버깅을 위해 `tmp/`를 남겨둔다.
- 사용자에게 별도로 묻지 않고 자동 정리한다.
- 정리 결과는 완료 보고에 한 줄로 명시한다.

---

## 완료 체크리스트 (공통)

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리 확정
- [ ] `tmp/db_candidates.json` 생성 (스캔 결과)
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장)
- [ ] 누락된 password 확인 후 보강
- [ ] 필요한 Python 라이브러리 import 가능 (`--check-only` 통과)
- [ ] DB 연결 성공 및 `tmp/common_codes.json` 생성
- [ ] 출력 파일 `output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx` 생성
- [ ] `3.코드그룹` / `4.상세코드` 시트에 DB 데이터가 채워지고 샘플 데이터는 남지 않음
- [ ] `그룹SQL` / `상세SQL` 수식이 데이터 행 수만큼 확장됨
- [ ] `output/04 구현(PI)/tmp/` 폴더 자동 삭제 완료 (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ 공통코드정의서 생성 완료 [SD_332]

실행 환경:     Windows PowerShell   또는   Bash on Linux/Mac/WSL
대상 디렉토리: {디렉토리경로}
DB:           {driver} {host}:{port}/{database} (profile={profile})
출력파일:     output/04 구현(PI)/PI_113-공통코드정의서_{YYMMDD}.xlsx

수집 통계:
  - 코드그룹(SM_COMM_H): N개
  - 상세코드(SM_COMM_D): N개
  - 사용중 그룹:         N개
  - 미사용 그룹:         N개

스캔된 설정 파일: {파일 목록}
임시 파일 정리:    tmp/ 삭제 완료
```

---

## 주의사항 (공통)

- **비밀번호 노출 방지 (필수)**: AskUserQuestion으로 받은 비밀번호와 `tmp/db_target.json`은 평문이므로, Excel 생성 성공 직후 `tmp/` 폴더를 자동 삭제한다.
- **driver 자동 감지 실패**: JDBC URL의 prefix가 비표준(`jdbc:log4jdbc:...`)이면 1단계 스크립트가 wrapper prefix를 벗긴다. 그래도 인식이 안 되면 사용자에게 직접 driver를 선택하도록 묻는다.
- **테이블명/컬럼명 대소문자**: PostgreSQL은 lowercase, MSSQL은 대소문자 무관, MySQL은 OS에 따라 다름. 스크립트는 모두 lowercase 식별자로 접근한다.
- **권한 부족**: `sm_comm_h`/`sm_comm_d`에 SELECT 권한이 없으면 명확한 에러로 종료한다.
- **수식 보존**: `그룹SQL`/`상세SQL` 시트의 수식은 row index만 갱신하여 복제한다.

### Windows 특화

- **Python 실행 명령**: `python` (PATH 등록 필요). `py -3` 도 가능.
- **한글 콘솔 출력**: `chcp 65001` + `$env:PYTHONUTF8 = "1"` 권장.

### Bash 특화

- **Python 실행 명령**: `python3`.
- **WSL 경로**: `/mnt/c/...` 형태로 입력 가능.
