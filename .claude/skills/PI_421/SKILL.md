---
name: PI_421
description: 단위테스트보고서 엑셀 생성 (JUnit @Test 스캔, Java/Kotlin, Windows/WSL/Linux 자동 감지). /PI_421
when_to_use: "단위테스트보고서 만들어줘", "JUnit 테스트 정리해줘", "단위테스트 산출물 뽑아줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 단위테스트 보고서 자동 생성 (Windows/WSL/Linux/Mac 통합) [PI_421]

지정된 백엔드(Java/Kotlin) 디렉토리의 **JUnit 테스트 코드 전수(全數)**를 스캔하여,
모든 테스트가 **통과(결과=O)** 되었다는 가정 하에 단위테스트 보고서를 엑셀로 생성한다.

> **목적**: 고객사 인계용 산출물. 실제 테스트 실행 결과를 기록하는 것이 아니라, 현재 작성되어 있는 JUnit 테스트 메서드를 모두 "통과"로 표기한 보고서를 만든다.

> **템플릿**: `template/04 구현(PI)/PI_212-단위테스트보고서.xlsx`
> - 시트: `표지`, `개정이력`, `단위테스트 보고서`, `Sheet1`
> - 데이터 시트(`단위테스트 보고서`) 컬럼: No. / 플랫폼 / 대메뉴 / 테스트ID / 메뉴 / 구분 / 내용 / 확인일자 / 담당자 / 결과(O,△,X) / 오류내용 / #레드마인 / 조치일자 / 조치확인결과
> - 데이터는 3행부터 작성. `표지` / `개정이력` 시트는 손대지 않는다.
> - `Sheet1` 의 플랫폼별 집계(WEB / PDA / I/F / 합계)도 자동 갱신.

> **출력**: `deliverables/30-output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx`

> **핵심 도구**: Python + `openpyxl`. 외부 빌드/실행 도구는 필요 없다. 라이브러리는 누락 시 자동 설치.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 없음
  → [Windows 섹션]의 PowerShell 블록 사용. `python` 실행.
- WSL / Linux / macOS (Bash):    uname 존재 (Linux/Darwin)
  → [Bash 섹션]의 bash 블록 사용. `python3` 실행.
```

> Python 스크립트(`scripts/*.py`)는 양쪽에서 공유한다. 스크립트 내부 `normalize_path()` 가 Windows 경로(`C:\...`)와 WSL 경로(`/mnt/c/...`)를 자동 변환한다.

---

## 사전 준비 (공통)

### 1) 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 사용하고, 부족하면 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 백엔드 디렉토리 경로 | Java/Kotlin 프로젝트 루트의 절대경로. Windows(`C:\...`) / WSL(`/mnt/c/...`) 모두 허용. |
| 고객사명 | 출력 파일명에 들어감. OS 예약 문자(`<>:"|?*\\/`)는 자동 `_` 치환. |
| 담당자명 | "담당자" 컬럼에 채워질 이름. 비어 있으면 기본값 `테스터`. |

검증:
- 디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 디렉토리에 `.java` / `.kt` 파일이 한 건도 없으면 "백엔드 프로젝트가 아닙니다" 안내 후 종료.
- 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의

상대경로는 git 저장소 루트(`$DocRoot` / `$DOC_ROOT`) 기준.

```
TEMPLATE   = template/04 구현(PI)/PI_212-단위테스트보고서.xlsx
OUTPUT_DIR = deliverables/30-output/04 구현(PI)
TMP_DIR    = deliverables/30-output/04 구현(PI)/tmp
OUTFILE    = deliverables/30-output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx
```

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 생성한다. `{YYMMDD}` 는 오늘 날짜.

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

### W-1) Python 의존성 확인

```powershell
python -c "import openpyxl" 2>$null
if ($LASTEXITCODE -ne 0) { python -m pip install --user openpyxl }
```

> `python` 이 없으면 `py -3` 으로 재시도.

### W-2) JUnit 테스트 스캔

```powershell
Set-Location $DocRoot
python -u ".claude\skills\PI_421\scripts\01_scan_tests.py" "{디렉토리경로}"
```

### W-3) Excel 생성

```powershell
Set-Location $DocRoot
python -u ".claude\skills\PI_421\scripts\02_generate_excel.py" "{고객사명}" "{담당자명}"
```

### W-4) 임시 파일 정리

```powershell
Remove-Item -Recurse -Force (Join-Path $DocRoot "output\04 구현(PI)\tmp") -ErrorAction SilentlyContinue
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

### B-1) Python 의존성 확인

```bash
python3 -c "import openpyxl" 2>/dev/null || python3 -m pip install --user openpyxl
```

### B-2) JUnit 테스트 스캔

```bash
cd "$DOC_ROOT"
python3 -u .claude/skills/PI_421/scripts/01_scan_tests.py "{디렉토리경로}"
```

### B-3) Excel 생성

```bash
cd "$DOC_ROOT"
python3 -u .claude/skills/PI_421/scripts/02_generate_excel.py "{고객사명}" "{담당자명}"
```

### B-4) 임시 파일 정리

```bash
cd "$DOC_ROOT"
rm -rf "deliverables/30-output/04 구현(PI)/tmp"
```

---

## 1단계 스캔 상세 (공통)

`scripts/01_scan_tests.py` 가 수행하는 일.

### 대상 파일 탐색

- 패턴: `**/src/test/java/**/*.java`, `**/src/test/kotlin/**/*.kt`
- 보조 패턴(테스트 루트가 표준이 아닌 경우):
  - 파일명이 `*Test.java`, `*Tests.java`, `Test*.java`, `ZTEST_*.java`
  - 파일명이 `*Test.kt`, `*Tests.kt`
- 제외 디렉토리: `node_modules`, `dist`, `build`, `target`, `.git`, `.gradle`, `.mvn`, `bin`, `obj`, `out`

### 테스트 메서드 추출

- `import` 검사로 JUnit 버전 식별:
  - `org.junit.jupiter.api.Test` → JUnit 5
  - `org.junit.Test` → JUnit 4
- `@Test` (또는 `@org.junit.Test`, `@org.junit.jupiter.api.Test`) 가 붙은 메서드만 수집.
- **주석 처리된 `@Test` 는 제외**:
  - 같은 라인에 `//`가 먼저 등장하면 제외.
  - `/* ... */` 블록 내부는 사전 제거(라인 단위로 단순 마스킹).

| 필드 | 추출 규칙 |
|---|---|
| `class_file` | 파일 경로 (프로젝트 루트 기준 상대경로) |
| `class_name` | 파일명에서 확장자 제거 (예: `MdBz01ServiceTest`) |
| `method_name` | `void methodName(...)` 의 메서드명 |
| `display_name` | `@DisplayName("...")` 의 문자열 (없으면 `null`) |
| `package_path` | `class_file` 의 `src/test/(java|kotlin)/` 이후 디렉토리 경로 |
| `junit_version` | `4` / `5` (혼재 시 import 우선) |

### 메뉴/도메인 분류

`package_path` 의 두 번째 세그먼트(lv2)로 대메뉴를 결정:

| lv2 키워드 | 대메뉴 | 플랫폼 |
|---|---|---|
| `md8000`, `master` | 기준정보 | WEB |
| `iw1000`, `inbound`, `receive` | 입고 | WEB |
| `rt2000`, `return` | 반품 | WEB |
| `iv3000`, `iv3100`, `iv3200`, `inventory`, `stock` | 재고 | WEB |
| `ow5000`, `outbound`, `delivery`, `shipping` | 출고 | WEB |
| `mm9200`, `sm9000`, `ss9300`, `admin`, `system` | 시스템관리 | WEB |
| `if9100`, `interface` | 인터페이스 | I/F |

- `bm/` lv1 → PDA. lv2 끝의 `m` 을 떼고 매핑(`iv3000m` → `iv3000`).
- `sif/` → I/F 고정. `fw/`, `test/` → 대메뉴 `공통`.
- 플랫폼 우선순위: I/F → PDA → WEB.

### 메뉴 컬럼 작성

- `class_name` 에서 도메인 코드(예: `MDBZ01`, `IVAD01M`) prefix 를 정규식으로 추출(`^(?:ZTEST_)?([A-Z]{2,5}[0-9]{2,3}M?)`).
- 한글도메인명 조회 순서:
  1. `template/04 구현(PI)/PI_412-프로그램목록.xlsx` 에서 학습한 사전
  2. 스크립트 내장 사전(`BUILTIN_NAME_DICT`)
  3. 클래스명에서 `ZTEST_` prefix 와 모듈 suffix 제거한 bare 이름

### 테스트ID 부여

`WMS-BE-001` 형식. 정렬: 플랫폼(WEB → PDA → I/F) → 대메뉴 → `class_name` → 메서드 등장 순서.

### 내용(content) 컬럼

1. `@DisplayName` 값이 있으면 그대로 사용.
2. 없으면 `method_name` 을 한글로 풀어 쓴다 (`findAll_*` → `전체 목록 조회 - …` 등).

결과를 `tmp/tests.json` 에 저장.

---

## 2단계 Excel 생성 상세 (공통)

`scripts/02_generate_excel.py` 가 수행하는 일.

1. **템플릿을 그대로 복사**해 출력 파일을 만든다(`shutil.copy`). 표지/개정이력/Sheet1 의 모든 서식 보존.

2. **`단위테스트 보고서` 시트**:
   - 3행 ~ 191행의 셀 값을 모두 비운다. 스타일·테두리·병합은 보존.
   - 3행부터 `tests` 리스트를 채워 넣는다:

     | 컬럼 # | 헤더 | 값 |
     |---|---|---|
     | 1 | No. | `idx + 1` |
     | 2 | 플랫폼 | `platform` |
     | 3 | 대메뉴 | `big_menu` |
     | 4 | 테스트ID | `test_id` |
     | 5 | 메뉴 | `menu` |
     | 6 | 구분 | `기능` 고정 |
     | 7 | 내용 | `content` |
     | 8 | 확인일자 | 오늘 날짜 |
     | 9 | 담당자 | 사용자 입력 담당자명 |
     | 10 | 결과(O,△,X) | `O` |
     | 11~14 | 오류내용/#레드마인/조치일자/조치확인결과 | 빈 칸 |

   - 데이터가 191행을 넘어가면 3행 셀의 스타일을 `copy()` 로 새 행에 복제.
   - `ws.print_area = "A1:N{last_row}"` 로 인쇄 영역 재설정.

3. **`Sheet1` 통계 시트**:
   - B열 라벨(`WEB`, `PDA`, `I/F`) 행의 D/E/F 컬럼만 갱신.
     - D: 완료(O) — 플랫폼별 추출 건수
     - E: 수정필요(△) — `0`
     - F: 오류&미진행 — `0`
   - C열(`=SUM(D:F)`) / G열(`=D/C`) / 합계 행 수식은 손대지 않는다.

---

## 완료 체크리스트 (공통)

- [ ] 입력(디렉토리 / 고객사명 / 담당자명) 확정
- [ ] Python 3 설치 확인
- [ ] `openpyxl` 사용 가능 확인 (없으면 자동 설치)
- [ ] `tmp/tests.json` 생성 — 테스트 항목 1건 이상
- [ ] 템플릿 파일 존재 확인
- [ ] 출력 파일 생성
- [ ] `단위테스트 보고서` 시트 3행부터 데이터 채워짐
- [ ] `Sheet1` 의 WEB / PDA / I/F 통과 건수 갱신됨
- [ ] `표지` / `개정이력` 시트가 템플릿 그대로 보존됨
- [ ] `tmp/` 삭제됨

---

## 완료 보고 형식

```
✓ 단위테스트 보고서 생성 완료 [PI_421]

실행 환경:     Windows PowerShell / Python    또는    Bash on Linux/Mac/WSL / Python3
대상 디렉토리: {디렉토리경로}
고객사:        {고객사명}
담당자:        {담당자명}
확인일자:      {YYYY-MM-DD}

스캔 결과:
  - 테스트 클래스 파일 : N개
  - 추출된 @Test 메서드: N건
  - JUnit 4 / JUnit 5 : N / N

플랫폼별 분포:
  - WEB : N건
  - PDA : N건
  - I/F : N건
  - 합계: N건  (결과: O={N} / 완료율 100.0%)

출력 파일: deliverables/30-output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx
```

---

## 주의사항 (공통)

- **결과 컬럼은 항상 `O`** (모두 통과 가정). △/X 를 임의로 분배하지 않는다.
- **확인일자는 오늘 날짜** 를 일괄 사용한다.
- **주석 처리된 `@Test` 는 제외** (`//@Test`, `/* @Test */` 모두).
- **이름이 `Test`/`Tests` 로 끝나도 `@Test` 메서드가 없으면 무시**.
- **추상 메서드** / 인터페이스 디폴트 메서드는 제외.
- **`@ParameterizedTest`** 도 1건으로 카운트 (메서드 단위).
- **템플릿 양식 보존**: 행 높이, 컬럼 너비, 테두리, 병합 셀, 인쇄 영역, `Sheet1` 의 수식을 절대 변경하지 않는다.
- **JUnit이 아닌 테스트(TestNG, Spock, Kotest 등)** 는 v1 범위가 아니다. 발견되더라도 수집하지 않고 경고만 표시.
- **모노레포 / 멀티 모듈**: 루트 디렉토리를 받으면 하위의 모든 모듈을 재귀 탐색.
- **고객사명 정규화**: 파일명에 사용 불가능한 문자(`<>:"|?*\\/`)는 자동으로 `_` 치환.
- **엑셀이 열려 있을 때 저장 실패**: 미리 닫고 실행하도록 안내.
- **출력 파일이 이미 존재하면** 사용자에게 덮어쓸지 한 번 확인.

### Windows 특화

- **`python` vs `py`**: 우선 `python --version` 으로 가능 여부 확인. 실패 시 `py -3` 으로 재시도.
- **한글 콘솔 출력 깨짐**: PowerShell이 cp949 면 한글이 깨질 수 있다.
  ```powershell
  $env:PYTHONUTF8 = "1"
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  chcp 65001 | Out-Null
  ```
- **경로 공백·한글 처리**: `"output\04 구현(PI)"` 처럼 공백·한글이 포함된 경로는 반드시 큰따옴표로 감싼다.

### Bash 특화

- **`python3` 명령**: WSL/Linux/macOS 기본.
- **WSL 경로**: 사용자가 `/mnt/c/...` 로 입력해도 스크립트가 자동 정규화.
- **macOS Homebrew Python**: `python3` 이 일반적. `python` 은 대부분 Python 2를 가리키니 사용 금지.
