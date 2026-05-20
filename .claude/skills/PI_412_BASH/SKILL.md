---
name: PI_412_BASH
description: 【프로그램 목록 엑셀 생성 (WSL/Linux/Mac)】 사용자가 지정한 로컬 프로젝트 디렉토리를 자동 스캔하여 백엔드(API/Controller)와 프론트엔드(Component/Page/Popup) 프로그램 목록을 추출하고, output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx 엑셀 파일로 자동 저장합니다. /PI_412_BASH 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. Spring Boot(Java/Kotlin), React/Vue(TS/JS), Node.js(Express/NestJS), Python(Django/FastAPI) 스택을 자동 감지하고 모노레포에서는 BE/FE를 동시에 처리합니다. WSL/Linux/Mac 환경에서 프로그램 목록 작성, 프로그램 명세 정리, API 목록 추출, 컴포넌트 목록 정리, 산출물용 프로그램 목록 엑셀 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "프로그램 목록 만들어줘", "프로그램목록 엑셀 뽑아줘", "API 목록 정리해줘", "컴포넌트 목록 추출해줘", "PI_412_BASH 실행해줘", "산출물용 프로그램 목록" 이라고 말해도 이 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 프로그램 목록 자동 생성 [PI_412_BASH]

지정된 로컬 프로젝트 디렉토리(백엔드/프론트엔드/모노레포)를 자동 스캔하여 프로그램 목록을 추출하고
`template/04 구현(PI)/PI_412-프로그램목록.xlsx` **템플릿을 복사하여 데이터를 채워**
`output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx` 로 저장한다.

> **목적**: 고객사 인계용 산출물. PI_412 템플릿 형식(Lv1~Lv7 디렉토리 계층 + 모듈명/모듈설명/개발방식)을 그대로 사용하며, **파일 1개 = 1행** 단위로 집계한다.

> **출력 시트 구조** (템플릿 그대로 보존):
> - `표지`, `개정이력`, `프로그램목록_BE`, `프로그램목록_FE`
> - 두 데이터 시트의 3행부터 새 데이터로 교체

> **핵심 도구**: Python 3 + `openpyxl`. 외부 빌드/실행 도구는 필요 없다. 라이브러리는 누락 시 자동 설치한다.

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS`가 비어 있으면 AskUserQuestion으로 다음 두 정보를 받는다.

| 입력 | 설명 |
|---|---|
| 디렉토리 경로 | 스캔할 프로젝트 루트의 절대경로. 모노레포면 루트, 단일 스택이면 해당 저장소 루트. (예: `/mnt/c/zinide/workspace/wms-bnk-be`) |
| 고객사명 | 출력 파일명에 들어감. 한글/공백 가능. 운영체제 예약 문자(`<>:"|?*\\/`)는 자동 `_` 치환. |

`$ARGUMENTS`가 1개의 토큰이면 디렉토리로 간주하고 고객사명만 별도로 묻는다.
디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다. 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"

OUTPUT_DIR="$DOC_ROOT/output/04 구현(PI)"
TMP_DIR="$OUTPUT_DIR/tmp"
SCRIPTS="$DOC_ROOT/.claude/skills/PI_412_BASH/scripts"
OUTFILE="$OUTPUT_DIR/PI_412_프로그램목록_{고객사명}.xlsx"
```

`OUTPUT_DIR`과 `TMP_DIR`이 없으면 `mkdir -p`로 생성한다.

### 3) Python 의존성 확인

`openpyxl`이 import 가능한지 점검하고 누락 시 설치한다.

```bash
python3 -c "import openpyxl" 2>/dev/null || python3 -m pip install --user openpyxl
```

---

## 단계별 워크플로우

각 단계는 Bash로 스크립트를 실행하고 결과 JSON을 다음 단계가 읽는 방식으로 진행한다. 산출물 JSON이 정상 생성됐는지 확인한 뒤 다음 단계로 넘어간다.

---

### 1단계 — 프로젝트 스캔 및 스택 감지

**스크립트**: `scripts/01_scan_project.py`
**입력**: 사용자 지정 디렉토리 경로
**출력**: `output/04 구현(PI)/tmp/scan.json`

```bash
cd "$DOC_ROOT" && \
python3 .claude/skills/PI_412_BASH/scripts/01_scan_project.py "{디렉토리경로}"
```

스크립트가 수행하는 일:

1. 디렉토리 안에서 다음 마커 파일을 탐색하여 **스택**을 결정한다.

   | 마커 | 감지 결과 |
   |---|---|
   | `pom.xml`, `build.gradle(.kts)`, `settings.gradle`, `build.xml`, `.classpath`, `.project` | Java/Kotlin (BE) — Maven/Gradle/Ant/Eclipse 모두 지원 |
   | `.java`/`.kt` 파일 5개 이상 (마커 없음) | Java/Kotlin (BE) 추정 |
   | `package.json`, `.vue`, `.tsx`/`.jsx` | Frontend (Vue/React/JS/TS/SCSS/CSS) |
   | `requirements.txt`, `pyproject.toml`, `setup.py`, `manage.py` | Python (BE) |

   여러 마커가 혼재하면 모두 활성화한다(모노레포 대응).

2. 다음 디렉토리는 **무조건 제외**한다: `node_modules`, `dist`, `build`, `target`, `.git`, `.next`, `.nuxt`, `.svelte-kit`, `out`, `__pycache__`, `.venv`, `venv`, `.idea`, `.vscode`, `coverage`, `tmp`, `.gradle`, `.mvn`, `bin`, `obj`.

3. 활성화된 스택별 **모든 소스 파일**을 파일 단위로 수집한다 (컨트롤러만이 아니라 Comp/Dao/Mapper 등 모듈 파일 전부).

   | 스택 | 후보 파일 패턴 |
   |---|---|
   | Java/Kotlin (BE) | `src/main/java/**/*.java`, `src/main/java/**/*.xml`, `src/main/kotlin/**/*.kt` (단, `test/` 패키지와 `ZTEST_*`, `*Test.java` 제외) |
   | Frontend | `src/**/*.vue`, `src/**/*.{tsx,jsx,ts,js,mjs,scss,css}` |
   | Python (BE) | `**/*.py` (단, `tests/`, `migrations/` 제외) |

4. 결과를 `tmp/scan.json`에 저장한다 (스택 키: `spring` / `frontend` / `python`).

> **스택 0개**: 사용자에게 디렉토리가 잘못됐거나 지원 스택이 아니라고 안내하고 종료한다. (디렉토리 재입력 권유)

---

### 2단계 — 프로그램 메타데이터 추출

**스크립트**: `scripts/02_extract_programs.py`
**입력**: `tmp/scan.json`
**출력**: `tmp/programs.json`

```bash
cd "$DOC_ROOT" && \
python3 .claude/skills/PI_412_BASH/scripts/02_extract_programs.py
```

스크립트는 각 후보 파일을 **파일 단위(1파일=1행)**로 추출한다. PI_412 템플릿이 파일별 행 구성이므로 메서드 단위로 분할하지 않는다.

#### Lv 분해 규칙

| section | 처리 | 예 |
|---|---|---|
| BE | `src/main/java`(또는 kotlin/resources) prefix 제거 후 디렉토리를 Lv1~Lv7에 매핑 | `src/main/java/be/iv3000/ivad01/IVAD01Controller.java` → Lv1=`be`, Lv2=`iv3000`, Lv3=`ivad01` |
| FE | `src` 자체를 Lv1로 사용 | `src/api/ContractorData.js` → Lv1=`src`, Lv2=`api` |

#### 항목 필드 (PI_412 템플릿 컬럼과 1:1 대응)

| 필드 | 설명 |
|---|---|
| `lv1` ~ `lv7` (BE) / `lv1` ~ `lv6` (FE) | 디렉토리 계층 |
| `program_id` | 가장 깊은 의미 디렉토리 코드. 보조 디렉토리(`bean`, `excel`, `util` 등)는 건너뛰고 그 위 단계 사용. (예: `be/iv3000/ivad01/bean` → `ivad01`) |
| `program_name` | 한글 도메인명. **우선순위**: ① 템플릿 사전(`PI_412-프로그램목록.xlsx`의 Controller/Service 행에서 학습) → ② Controller 파일의 한글 코멘트 → ③ 빈값(사용자 보강) |
| `module_name` | 파일명(확장자 제거) — 예: `IVAD01Controller` |
| `module_desc` | **우선순위**: ① 템플릿 사전(모듈명 → 모듈설명 매핑) → ② `{program_name} {모듈타입}` 휴리스틱 (예: `재고조정 Controller`, `재고조정 Mapper`) |
| `dev_type` | 확장자 (`java` / `xml` / `kt` / `vue` / `scss` / `css` / `js` / `ts` 등) |
| `req_id`, `remark` | 기본 빈값 (사용자가 직접 보강) |
| `path` | 프로젝트 루트 기준 상대 경로 |

#### 모듈 타입 휴리스틱

파일명에서 도메인 코드 prefix(예: `IVAD01`)를 제거한 suffix를 모듈 타입으로 본다. 알려진 suffix 매핑: `Controller`, `Comp`, `CompUtil`, `TxComp`, `Dao`, `Mapper`, `SqlMapper`, `Service`, `Request`, `Response`, `VO`, `DTO`, `Config`, `Util`, `Exception`, `Filter`, `Interceptor`, `Handler` 등.

#### 템플릿 사전 학습

- `template/04 구현(PI)/PI_412-프로그램목록.xlsx`를 읽어 `(program_id → program_name)`, `(module_name → module_desc)` 매핑을 미리 구축한다.
- 같은 program_id에서 **Controller/Service** 행의 program_name을 우선 채택 (도메인 대표 명칭).
- 템플릿에 없는 도메인은 1차 패스에서 코드 내 Controller 파일의 한글 코멘트로 보강한다.

#### 정렬 규칙

`section` (BE → FE) → Lv1 → Lv2 → ... → Lv7 → `module_name` → `dev_type` 안정 정렬.

추출이 0건이면 사용자에게 "지원 패턴이 발견되지 않았다"라고 안내하고 1단계 스캔 결과를 함께 보고한다.

---

### 3단계 — Excel 생성

**스크립트**: `scripts/03_generate_excel.py`
**입력**: `tmp/programs.json`, 고객사명
**출력**: `output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx`

```bash
cd "$DOC_ROOT" && \
python3 .claude/skills/PI_412_BASH/scripts/03_generate_excel.py "{고객사명}"
```

스크립트가 하는 일:

1. **`template/04 구현(PI)/PI_412-프로그램목록.xlsx` 를 그대로 복사**해 `output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx`을 만든다. 이 시점에 표지·개정이력·프로그램목록 헤더의 모든 서식이 보존된다.

2. **`프로그램목록_BE` 시트** (Lv1~Lv7 + 프로그램ID + 프로그램명 + 모듈명 + 모듈설명 + 개발방식 + 요구사항ID + 비고)
   - 3행부터 기존 데이터 셀 값을 모두 비운다 (스타일은 보존).
   - 3행부터 새 데이터를 채워 넣는다. 각 행 셀의 폰트/테두리/정렬은 템플릿 데이터 첫 행 스타일을 복제한다.
   - auto_filter 범위를 `A2:N{last_row}`로 갱신한다.

3. **`프로그램목록_FE` 시트** (Lv1~Lv6 + 프로그램ID + 프로그램명 + 모듈명 + 모듈설명 + 개발방식 + 요구사항ID + 비고)
   - 동일하게 3행부터 데이터 교체. FE 후보가 0건이면 헤더만 남기고 auto_filter도 헤더 한 줄로 축소한다.

4. **표지** / **개정이력** 시트는 손대지 않는다 (템플릿 그대로).

5. 저장 후 절대 경로 출력.

---

### 4단계 — 임시 파일 정리

Excel 생성이 성공하면 `output/04 구현(PI)/tmp/` 디렉토리를 삭제한다.

```bash
cd "$DOC_ROOT" && \
rm -rf "output/04 구현(PI)/tmp"
```

중간 단계에서 실패한 경우에는 디버깅을 위해 `tmp/`를 남겨둔다.

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리·고객사명 확정
- [ ] `tmp/scan.json` 생성 — 스택과 후보 파일 목록 확인
- [ ] `tmp/programs.json` 생성 — 추출 항목 1건 이상
- [ ] `output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx` 생성
- [ ] `프로그램목록_BE` / `프로그램목록_FE` 시트에 데이터·필터 적용 확인
- [ ] `표지` / `개정이력` 시트가 템플릿 그대로 보존됐는지 확인
- [ ] `output/04 구현(PI)/tmp/` 삭제 완료

---

## 완료 보고 형식

```
✓ 프로그램 목록 생성 완료 [PI_412_BASH]

대상 디렉토리: {디렉토리경로}
감지된 스택:   {예: spring, react}
출력 파일:     output/04 구현(PI)/PI_412_프로그램목록_{고객사명}.xlsx

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

## 주의사항

- **모노레포 자동 동시 추출**: 한 디렉토리에 BE와 FE 마커가 모두 있으면 두 스택을 동시에 추출하여 한 엑셀의 `프로그램목록_BE` / `프로그램목록_FE` 시트에 각각 채운다. 분리해서 뽑고 싶다면 사용자가 BE/FE 디렉토리를 따로 지정해 두 번 실행한다.
- **추출 단위는 파일 1건 = 1행**. 컨트롤러 메서드 단위가 아닌 PI_412 템플릿 형식을 그대로 따른다.
- **프로그램명 미매핑**: 템플릿 사전과 코드 한글 코멘트 모두 실패하면 program_name을 빈 칸으로 둔다(사용자가 엑셀에서 직접 보강). 강제로 영문 humanize 값을 넣지 않는다.
- **테스트/리소스 제외**: `src/main/java/test/` 패키지, `ZTEST_*`, `*Test.java`, `*Tests.java`, 그리고 `src/main/resources/` 하위(logback/sqlmap-config 등 설정 파일)는 결과에 포함하지 않는다.
- **거대한 저장소**: 후보 파일이 수천 개 이상이면 추출에 수십 초 ~ 수 분 걸릴 수 있다. 진행 중에는 1·2단계의 stat을 출력해 진행 상황을 알린다.
- **고객사명 정규화**: 파일명에 사용 불가능한 문자(`<>:"|?*\\/`)는 자동으로 `_`로 치환한다.
- **템플릿 파일 필수**: `template/04 구현(PI)/PI_412-프로그램목록.xlsx`이 없으면 3단계에서 종료. 템플릿이 있어야 표지/개정이력/헤더 서식과 도메인 한글명 사전이 모두 적용된다.
- **출력 디렉토리에 기존 파일이 있을 때**: 동일 파일명이 존재하면 덮어쓰기 전에 사용자에게 한 번 확인한다.
- **WSL/Linux/Mac 전용**: Windows 환경에서는 PI_412 스킬을 사용한다.
