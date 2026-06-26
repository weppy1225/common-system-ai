---
name: PI_412
description: 프로그램 목록 엑셀 생성 (BE Controller + FE Component 자동 스캔). /PI_412
when_to_use: "프로그램 목록 만들어줘", "프로그램목록 엑셀 뽑아줘", "API 목록 정리해줘", "컴포넌트 목록 추출해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 프로그램 목록 자동 생성 (Windows/WSL/Linux/Mac 통합) [PI_412]

지정된 로컬 프로젝트 디렉토리(백엔드/프론트엔드/모노레포)를 자동 스캔하여 프로그램 목록을 추출하고
`deliverables/10-templates/04 구현(PI)/PI_412-프로그램목록.xlsx` **템플릿을 복사하여 데이터를 채워**
`deliverables/30-output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx` 로 저장한다.

> **목적**: 고객사 인계용 산출물. PI_412 템플릿 형식(Lv1~Lv7 디렉토리 계층 + 모듈명/모듈설명/개발방식)을 그대로 사용하며, **파일 1개 = 1행** 단위로 집계한다.

> **출력 시트 구조** (템플릿 그대로 보존):
> - `표지`, `개정이력`, `프로그램목록_BE`, `프로그램목록_FE`
> - 두 데이터 시트의 3행부터 새 데이터로 교체

> **핵심 도구**: Python + `openpyxl`. 외부 빌드/실행 도구는 필요 없다. 라이브러리는 누락 시 자동 설치한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션]의 PowerShell 블록 사용. `python` 실행.
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션]의 bash 블록 사용. `python3` 실행.
```

> Python 스크립트(`scripts/*.py`)는 양쪽에서 동일하게 동작한다. 스크립트 내부에서 git rev-parse 로 REPO_BASE를 동적 감지하므로 경로 설정이 불필요하다.

---

## 사전 준비 (공통)

### 1) 입력 받기

`$ARGUMENTS`가 비어 있으면 AskUserQuestion으로 다음 두 정보를 받는다.

| 입력 | 설명 |
|---|---|
| 디렉토리 경로 | 스캔할 프로젝트 루트의 절대경로. 모노레포면 루트, 단일 스택이면 해당 저장소 루트. (예: `C:\zinide\workspace-{프로젝트}\{프로젝트}-be` 또는 `/mnt/c/zinide/workspace-{프로젝트}/{프로젝트}-be`) |
| 고객사명 | 출력 파일명에 들어감. 한글/공백 가능. 운영체제 예약 문자(`<>:"|?*\\/`)는 자동 `_` 치환. |

`$ARGUMENTS`가 1개의 토큰이면 디렉토리로 간주하고 고객사명만 별도로 묻는다.
디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다. 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
OUTPUT_DIR = deliverables/30-output/04 구현(PI)
TMP_DIR    = deliverables/30-output/04 구현(PI)/tmp
SCRIPTS    = .claude/skills/PI_412/scripts
OUTFILE    = deliverables/30-output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx
```

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
$RepoPrefix = $RepoName -replace '-[^-]+$',''
$BeRoot = Join-Path $Workspace "$RepoPrefix-be"
$FeRoot = Join-Path $Workspace "$RepoPrefix-fe"
```

### W-1) Python 의존성 확인

```powershell
python -c "import openpyxl" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user openpyxl }
```

### W-2) 프로젝트 스캔

```powershell
Set-Location $DocRoot
python ".claude\skills\PI_412\scripts\01_scan_project.py" "{디렉토리경로}"
```

### W-3) 프로그램 메타데이터 추출

```powershell
Set-Location $DocRoot
python ".claude\skills\PI_412\scripts\02_extract_programs.py"
```

### W-4) Excel 생성

```powershell
Set-Location $DocRoot
python ".claude\skills\PI_412\scripts\03_generate_excel.py" "{고객사명}"
```

### W-5) 임시 파일 정리

```powershell
Remove-Item -Recurse -Force (Join-Path $DocRoot "deliverables\30-output\04 구현(PI)\tmp") -ErrorAction SilentlyContinue
```

---

# === Bash 섹션 (WSL/Linux/Mac) ===

### B-0) 경로 동적 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
REPO_PREFIX="${REPO_NAME%-*}"
BE_ROOT="$WORKSPACE/${REPO_PREFIX}-be"
FE_ROOT="$WORKSPACE/${REPO_PREFIX}-fe"

OUTPUT_DIR="$DOC_ROOT/deliverables/30-output/04 구현(PI)"
TMP_DIR="$OUTPUT_DIR/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/PI_412/scripts"
```

### B-1) Python 의존성 확인

```bash
python3 -c "import openpyxl" 2>/dev/null || python3 -m pip install --user openpyxl
```

### B-2) 프로젝트 스캔

```bash
cd "$DOC_ROOT"
python3 .claude/skills/PI_412/scripts/01_scan_project.py "{디렉토리경로}"
```

### B-3) 프로그램 메타데이터 추출

```bash
cd "$DOC_ROOT"
python3 .claude/skills/PI_412/scripts/02_extract_programs.py
```

### B-4) Excel 생성

```bash
cd "$DOC_ROOT"
python3 .claude/skills/PI_412/scripts/03_generate_excel.py "{고객사명}"
```

### B-5) 임시 파일 정리

```bash
cd "$DOC_ROOT"
rm -rf "deliverables/30-output/04 구현(PI)/tmp"
```

---

## 1단계 스캔 — 스택 감지 (공통)

`scripts/01_scan_project.py` 가 수행하는 일.

1. 디렉토리 안에서 다음 마커 파일을 탐색하여 **스택**을 결정한다.

   | 마커 | 감지 결과 |
   |---|---|
   | `pom.xml`, `build.gradle(.kts)`, `settings.gradle`, `build.xml`, `.classpath`, `.project` | Java/Kotlin (BE) — Maven/Gradle/Ant/Eclipse 모두 지원 |
   | `.java`/`.kt` 파일 5개 이상 (마커 없음) | Java/Kotlin (BE) 추정 |
   | `package.json`, `.vue`, `.tsx`/`.jsx` | Frontend (Vue/React/JS/TS/SCSS/CSS) |
   | `requirements.txt`, `pyproject.toml`, `setup.py`, `manage.py` | Python (BE) |

   여러 마커가 혼재하면 모두 활성화한다(모노레포 대응).

2. 다음 디렉토리는 **무조건 제외**한다: `node_modules`, `dist`, `build`, `target`, `.git`, `.next`, `.nuxt`, `.svelte-kit`, `out`, `__pycache__`, `.venv`, `venv`, `.idea`, `.vscode`, `coverage`, `tmp`, `.gradle`, `.mvn`, `bin`, `obj`.

3. 활성화된 스택별 **모든 소스 파일**을 파일 단위로 수집한다.

   | 스택 | 후보 파일 패턴 |
   |---|---|
   | Java/Kotlin (BE) | `src/main/java/**/*.java`, `src/main/java/**/*.xml`, `src/main/kotlin/**/*.kt` (단, `test/` 패키지와 `ZTEST_*`, `*Test.java` 제외) |
   | Frontend | `src/**/*.vue`, `src/**/*.{tsx,jsx,ts,js,mjs,scss,css}` |
   | Python (BE) | `**/*.py` (단, `tests/`, `migrations/` 제외) |

4. 결과를 `tmp/scan.json`에 저장한다 (스택 키: `spring` / `frontend` / `python`).

> **스택 0개**: 사용자에게 디렉토리가 잘못됐거나 지원 스택이 아니라고 안내하고 종료.

---

## 2단계 추출 — 메타데이터 (공통)

`scripts/02_extract_programs.py` 가 수행하는 일. 각 후보 파일을 **파일 단위(1파일=1행)**로 추출한다.

### Lv 분해 규칙

| section | 처리 | 예 |
|---|---|---|
| BE | `src/main/java`(또는 kotlin/resources) prefix 제거 후 디렉토리를 Lv1~Lv7에 매핑 | `src/main/java/be/iv3000/ivad01/IVAD01Controller.java` → Lv1=`be`, Lv2=`iv3000`, Lv3=`ivad01` |
| FE | `src` 자체를 Lv1로 사용 | `src/api/ContractorData.js` → Lv1=`src`, Lv2=`api` |

### 항목 필드 (PI_412 템플릿 컬럼과 1:1 대응)

| 필드 | 설명 |
|---|---|
| `lv1` ~ `lv7` (BE) / `lv1` ~ `lv6` (FE) | 디렉토리 계층 |
| `program_id` | 가장 깊은 의미 디렉토리 코드. 보조 디렉토리(`bean`, `excel`, `util` 등)는 건너뜀 |
| `program_name` | 한글 도메인명. ① 템플릿 사전 → ② Controller 한글 코멘트 → ③ 빈값 |
| `module_name` | 파일명(확장자 제거) — 예: `IVAD01Controller` |
| `module_desc` | ① 템플릿 사전 → ② `{program_name} {모듈타입}` 휴리스틱 |
| `dev_type` | 확장자 (`java` / `xml` / `kt` / `vue` / `scss` / `css` / `js` / `ts` 등) |
| `req_id`, `remark` | 기본 빈값 |
| `path` | 프로젝트 루트 기준 상대 경로 |

### 모듈 타입 휴리스틱

파일명에서 도메인 코드 prefix(예: `IVAD01`)를 제거한 suffix를 모듈 타입으로 본다. 알려진 suffix: `Controller`, `Comp`, `CompUtil`, `TxComp`, `Dao`, `Mapper`, `SqlMapper`, `Service`, `Request`, `Response`, `VO`, `DTO`, `Config`, `Util`, `Exception`, `Filter`, `Interceptor`, `Handler` 등.

### 정렬 규칙

`section` (BE → FE) → Lv1 → Lv2 → ... → Lv7 → `module_name` → `dev_type` 안정 정렬.

---

## 3단계 Excel 생성 (공통)

`scripts/03_generate_excel.py` 가 수행하는 일.

1. **`deliverables/10-templates/04 구현(PI)/PI_412-프로그램목록.xlsx` 를 그대로 복사**해 `deliverables/30-output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx` 생성. 표지/개정이력/프로그램목록 헤더 서식이 모두 보존된다.
2. **`프로그램목록_BE` 시트**: 3행부터 기존 데이터 셀 값을 비우고(스타일 보존), 새 데이터를 채워 넣는다. auto_filter 범위를 `A2:N{last_row}`로 갱신.
3. **`프로그램목록_FE` 시트**: 동일하게 3행부터 데이터 교체. FE 후보가 0건이면 헤더만 남기고 auto_filter도 헤더 한 줄로 축소.
4. **표지** / **개정이력** 시트는 손대지 않는다.
5. 저장 후 절대 경로 출력.

---

## 완료 체크리스트 (공통)

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리·고객사명 확정
- [ ] `tmp/scan.json` 생성 — 스택과 후보 파일 목록 확인
- [ ] `tmp/programs.json` 생성 — 추출 항목 1건 이상
- [ ] `deliverables/30-output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx` 생성
- [ ] `프로그램목록_BE` / `프로그램목록_FE` 시트에 데이터·필터 적용 확인
- [ ] `표지` / `개정이력` 시트가 템플릿 그대로 보존됐는지 확인
- [ ] `deliverables/30-output/04 구현(PI)/tmp/` 삭제 완료

---

## 완료 보고 형식

```
✓ 프로그램 목록 생성 완료 [PI_412]

실행 환경:   Windows PowerShell   또는   Bash on Linux/Mac/WSL
대상 디렉토리: {디렉토리경로}
감지된 스택:   {예: spring, react}
출력 파일:     deliverables/30-output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx

수집 통계:
  - 백엔드(BE):  N건
  - 프론트(FE):  N건
  - 합계:        N건

도메인 Top 5:
  1. order   — 18건
  2. product — 12건
  ...
```

---

## 주의사항 (공통)

- **모노레포 자동 동시 추출**: 한 디렉토리에 BE와 FE 마커가 모두 있으면 두 스택을 동시에 추출하여 한 엑셀의 `프로그램목록_BE` / `프로그램목록_FE` 시트에 각각 채운다.
- **추출 단위는 파일 1건 = 1행**. 컨트롤러 메서드 단위가 아닌 PI_412 템플릿 형식을 그대로 따른다.
- **프로그램명 미매핑**: 템플릿 사전과 코드 한글 코멘트 모두 실패하면 program_name을 빈 칸으로 둔다 (사용자가 엑셀에서 직접 보강).
- **테스트/리소스 제외**: `src/main/java/test/` 패키지, `ZTEST_*`, `*Test.java`, `*Tests.java`, 그리고 `src/main/resources/` 하위(logback/sqlmap-config 등 설정 파일)는 결과에 포함하지 않는다.
- **거대한 저장소**: 후보 파일이 수천 개 이상이면 추출에 수십 초 ~ 수 분 걸릴 수 있다.
- **고객사명 정규화**: 파일명에 사용 불가능한 문자(`<>:"|?*\\/`)는 자동으로 `_`로 치환한다.
- **템플릿 파일 필수**: `deliverables/10-templates/04 구현(PI)/PI_412-프로그램목록.xlsx`이 없으면 3단계에서 종료.
- **출력 파일 덮어쓰기**: 동일 파일명이 존재하면 덮어쓰기 전에 사용자에게 한 번 확인한다.

### Windows 특화

- **Python 실행 명령**: `python` (또는 `py -3`). PATH 등록 필요.
- **pip --user 위치**: `%APPDATA%\Python\Python3X\Scripts` — PATH 추가 안내가 필요할 수 있음.

### Bash 특화

- **Python 실행 명령**: `python3`.
- **pip --user 위치**: `~/.local/bin` — PATH 추가 안내가 필요할 수 있음.
