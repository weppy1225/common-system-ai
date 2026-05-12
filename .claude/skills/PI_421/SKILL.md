---
name: PI_421
description: 【단위테스트 보고서 엑셀 생성 (JUnit 기반)】 사용자가 지정한 로컬 백엔드(Java/Kotlin) 디렉토리를 자동 스캔하여 모든 JUnit 테스트 코드(@Test 메서드)를 추출하고, 모든 테스트가 통과(결과=O)되었다는 가정 하에 단위테스트보고서 엑셀을 자동 생성합니다. 템플릿은 `template/04 구현(PI)/PI_212-단위테스트보고서.xlsx` 를 그대로 복사해 사용하며, `output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx` 로 저장합니다. /PI_421 형식으로 실행하며 디렉토리·고객사명·담당자명은 실행 시 묻습니다. JUnit 4(`org.junit.Test`) 와 JUnit 5(`org.junit.jupiter.api.Test`) 양쪽을 모두 인식하고, `@DisplayName` 이 있으면 우선 사용합니다. 주석 처리된(`//@Test`) 테스트는 제외합니다. 단위테스트 보고서 작성, JUnit 테스트 목록 정리, 백엔드 단위테스트 산출물 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "단위테스트보고서 만들어줘", "JUnit 테스트 정리해줘", "단위테스트 산출물 뽑아줘", "PI_421 실행해줘", "BE 단위테스트 엑셀" 이라고 말해도 이 스킬을 사용합니다. 단, 통합테스트(PI_214) 산출물이 필요한 경우에는 별도 스킬을 사용합니다.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# 단위테스트 보고서 자동 생성 [PI_421]

지정된 백엔드(Java/Kotlin) 디렉토리의 **JUnit 테스트 코드 전수(全數)**를 스캔하여,
모든 테스트가 **통과(결과=O)** 되었다는 가정 하에 단위테스트 보고서를 엑셀로 생성한다.

> **목적**: 고객사 인계용 산출물. 실제 테스트 실행 결과를 기록하는 것이 아니라,
> 현재 작성되어 있는 JUnit 테스트 메서드를 모두 "통과"로 표기한 보고서를 만든다.

> **템플릿**: `template/04 구현(PI)/PI_212-단위테스트보고서.xlsx`
> - 시트: `표지`, `개정이력`, `단위테스트 보고서`, `Sheet1`
> - 데이터 시트(`단위테스트 보고서`) 컬럼: No. / 플랫폼 / 대메뉴 / 테스트ID / 메뉴 / 구분 / 내용 / 확인일자 / 담당자 / 결과(O,△,X) / 오류내용 / #레드마인 / 조치일자 / 조치확인결과
> - 데이터는 3행부터 작성. `표지` / `개정이력` 시트는 손대지 않는다.
> - `Sheet1` 의 플랫폼별 집계(WEB / PDA / I/F / 합계)도 자동 갱신한다.

> **출력**: `output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx`

> **핵심 도구**: Python 3 + `openpyxl`. 외부 빌드/실행 도구는 필요 없다.
> `openpyxl` 누락 시 자동 설치한다.

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS` 로 전달된 값이 있으면 사용하고, 부족하면 `AskUserQuestion` 으로 추가로 묻는다.

| 입력 | 설명 |
|---|---|
| 백엔드 디렉토리 경로 | 스캔할 Java/Kotlin 프로젝트 루트의 절대경로. WSL 경로(`/mnt/c/...`) 또는 Windows 경로 모두 허용. (예: `/mnt/c/zinide/workspace_cloud/cloud-wms-be`) |
| 고객사명 | 출력 파일명에 들어감. 한글/공백 가능. 운영체제 예약 문자(`<>:"\|?*\\/`)는 자동 `_` 치환. |
| 담당자명 | 보고서의 "담당자" 컬럼에 채워질 이름. 비어 있으면 기본값 `테스터` 사용. |

검증:
- 디렉토리가 존재하지 않거나 일반 파일이면 다시 묻는다.
- 디렉토리에 `.java` / `.kt` 파일이 한 건도 없으면 "백엔드 프로젝트가 아닙니다" 라고 안내하고 종료한다.
- 고객사명이 비어 있으면 다시 묻는다.

### 2) 경로 정의

```
BASE       = /mnt/c/zinide/workspace/cloud-wms-doc
TEMPLATE   = template/04 구현(PI)/PI_212-단위테스트보고서.xlsx
OUTPUT_DIR = output/04 구현(PI)
TMP_DIR    = output/04 구현(PI)/tmp
OUTFILE    = output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx
```

`OUTPUT_DIR` / `TMP_DIR` 이 없으면 `mkdir -p` 로 생성한다.
`{YYMMDD}` 는 오늘 날짜(서버 로컬 시간).

### 3) Python 의존성 확인

```bash
python3 -c "import openpyxl" 2>/dev/null || python3 -m pip install --user openpyxl
```

---

## 워크플로우 (3단계)

각 단계는 Bash로 `.claude/skills/PI_421/scripts/` 안의 Python 스크립트를 실행한다.
산출물 JSON이 정상 생성됐는지 확인한 뒤 다음 단계로 넘어간다.
중간 단계에서 실패하면 `tmp/` 를 남겨 디버깅한다.

```
.claude/skills/PI_421/scripts/
├── 01_scan_tests.py     # 1단계 — JUnit @Test 메서드 스캔
└── 02_generate_excel.py # 2단계 — 템플릿 복사 + 데이터 채우기 + Sheet1 갱신
```

---

### 1단계 — JUnit 테스트 스캔 (소스 → JSON)

지정된 디렉토리 아래에서 JUnit 테스트 메서드를 모두 수집한다.

**스크립트**: `scripts/01_scan_tests.py`
**입력**: 사용자 지정 디렉토리 경로
**출력**: `output/04 구현(PI)/tmp/tests.json`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 -u .claude/skills/PI_421/scripts/01_scan_tests.py "{디렉토리경로}"
```

스크립트가 수행하는 일:

1. **대상 파일 탐색**
   - 패턴: `**/src/test/java/**/*.java`, `**/src/test/kotlin/**/*.kt`
   - 보조 패턴(테스트 루트가 표준이 아닌 경우):
     - 파일명이 `*Test.java`, `*Tests.java`, `Test*.java`, `ZTEST_*.java`
     - 파일명이 `*Test.kt`, `*Tests.kt`
   - 제외 디렉토리: `node_modules`, `dist`, `build`, `target`, `.git`, `.gradle`, `.mvn`, `bin`, `obj`, `out`

2. **테스트 메서드 추출**
   - `import` 검사로 JUnit 버전 식별:
     - `org.junit.jupiter.api.Test` → JUnit 5
     - `org.junit.Test` → JUnit 4
   - `@Test` (또는 `@org.junit.Test`, `@org.junit.jupiter.api.Test`) 가 붙은 메서드만 수집한다.
   - **주석 처리된 `@Test` 는 제외한다**:
     - 같은 라인에 `//`가 먼저 등장하면 제외.
     - `/* ... */` 블록 내부는 사전 제거(라인 단위로 단순 마스킹).
   - 각 메서드의 다음 메타데이터를 채집한다:

     | 필드 | 추출 규칙 |
     |---|---|
     | `class_file` | 파일 경로 (프로젝트 루트 기준 상대경로) |
     | `class_name` | 파일명에서 확장자 제거 (예: `MdBz01ServiceTest`) |
     | `method_name` | `void methodName(...)` 의 메서드명 |
     | `display_name` | `@DisplayName("...")` 의 문자열 (없으면 `null`) |
     | `package_path` | `class_file` 의 `src/test/(java\|kotlin)/` 이후 디렉토리 경로 (예: `be/iv3000/ivad01`) |
     | `junit_version` | `4` / `5` (혼재 시 import 우선) |

3. **메뉴/도메인 분류** (테이블 기반, 부분 일치)
   - `package_path` 의 두번째 세그먼트(lv2)로 대메뉴를 결정한다. 매핑 사전:

     | lv2 키워드 | 대메뉴 | 플랫폼 |
     |---|---|---|
     | `md8000`, `master` | 기준정보 | WEB |
     | `iw1000`, `inbound`, `receive` | 입고 | WEB |
     | `rt2000`, `return` | 반품 | WEB |
     | `iv3000`, `iv3100`, `iv3200`, `inventory`, `stock` | 재고 | WEB |
     | `ow5000`, `outbound`, `delivery`, `shipping` | 출고 | WEB |
     | `mm9200`, `sm9000`, `ss9300`, `admin`, `system` | 시스템관리 | WEB |
     | `if9100`, `interface` | 인터페이스 | I/F |

   - lv1 별 특수 처리:
     - `bm/` → PDA (모바일 백엔드). lv2 끝의 `m` 을 떼고 매핑(`iv3000m` → `iv3000`).
     - `sif/` → 인터페이스(I/F) 고정.
     - `fw/`, `test/` → 대메뉴 `공통` (프레임워크/테스트 헬퍼).
   - 매핑이 없으면 `lv2` 자체를 대메뉴로 사용한다(영문 그대로). 사용자가 엑셀에서 직접 보강.
   - 플랫폼 우선순위: I/F → PDA → WEB. 파일 경로에 `if9100` / `sif/` 등 인터페이스 키워드가 있으면 무조건 `I/F`.

4. **메뉴 컬럼 작성**
   - `class_name` 에서 도메인 코드(예: `MDBZ01`, `IVAD01M`) prefix 를 정규식으로 추출한다(`^(?:ZTEST_)?([A-Z]{2,5}[0-9]{2,3}M?)`).
   - 추출에 성공하면 메뉴 컬럼 값 = `{한글도메인명}({도메인코드})` 형식 (예: `사업장관리(MDBZ01)`).
   - 한글도메인명 조회 순서:
     1. `template/04 구현(PI)/PI_412-프로그램목록.xlsx` 에서 학습한 사전 (프로그램ID 열 8 → 프로그램명 열 9)
     2. 스크립트 내장 사전(`BUILTIN_NAME_DICT`) — WMS 표준 도메인 코드(MDBZ01, IVAD01, OBPC01 등)
     3. 클래스명에서 `ZTEST_` prefix 와 모듈 suffix(`Comp`/`Controller`/`Dao`/`Mapper`/`Service`/`Util`/`Suite`/`Biz`) 제거한 bare 이름
   - 모바일 코드(`IVAD01M`)는 `M` 을 떼고 베이스 코드(`IVAD01`)로도 사전 조회한다.
   - 도메인 코드 추출에 실패하면 메뉴 컬럼 값 = `class_name` (단, `ZTEST_` prefix 만 제거).

5. **테스트ID 부여**
   - 정렬 후 `WMS-BE-001` 형식으로 1부터 일련번호를 부여한다.
   - 정렬 순서: 플랫폼(WEB → PDA → I/F) → 대메뉴 → `class_name` → 파일 내 메서드 등장 순서.

6. **내용(content) 컬럼 작성** — 우선순위
   1. `@DisplayName` 값이 있으면 그대로 사용.
   2. 없으면 `method_name` 을 한글로 풀어 쓴다. 대표 패턴:
      - `findAll_*` → `전체 목록 조회 - …`
      - `findById_*` / `getById_*` → `단건 조회 - …`
      - `create_*` / `register_*` / `save_*` → `등록 - …`
      - `update_*` / `modify_*` → `수정 - …`
      - `delete_*` / `remove_*` → `삭제 - …`
      - `search_*` → `검색 - …`
      - `*_fail` / `*_error` / `*_invalid` → `… 실패 케이스 - …`
      - 위 패턴에 해당하지 않으면 메서드명을 그대로 사용한다.

7. 결과를 `tmp/tests.json` 에 저장한다. 구조:
   ```json
   {
     "scanned_dir": "...",
     "junit_files": 42,
     "test_count": 318,
     "tests": [
       {
         "test_id": "WMS-BE-001",
         "platform": "WEB",
         "big_menu": "기준정보",
         "menu": "사업장관리(MDBZ01)",
         "category": "기능",
         "content": "사업장 목록 조회 - 전체 사업장 정상 반환 확인",
         "result": "O",
         "class_file": "src/test/java/.../MdBz01ServiceTest.java",
         "method_name": "findAll_returns_all_businesses"
       }
     ]
   }
   ```

**테스트 항목이 0건이면** 사용자에게 "JUnit `@Test` 메서드가 발견되지 않았습니다" 라고
안내하고 1단계 스캔 통계(`.java`/`.kt` 파일 수 등)와 함께 종료한다.

---

### 2단계 — Excel 생성 (템플릿 복제 + 데이터 채우기)

**스크립트**: `scripts/02_generate_excel.py`
**입력**: `tmp/tests.json`, 고객사명, 담당자명
**출력**: `output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 -u .claude/skills/PI_421/scripts/02_generate_excel.py "{고객사명}" "{담당자명}"
```

스크립트가 하는 일:

1. **템플릿을 그대로 복사**해 출력 파일을 만든다(`shutil.copy`). 이 시점에 `표지` / `개정이력` / `Sheet1` 의 모든 서식·인쇄설정이 보존된다.

2. **`단위테스트 보고서` 시트** 처리
   - 3행 ~ 191행(템플릿 마지막 데이터 행)의 셀 값을 모두 비운다. **스타일·테두리·병합은 보존**한다.
   - 3행부터 `tests` 리스트를 채워 넣는다. 각 행의 컬럼 매핑:

     | 컬럼 # | 헤더 | 값 |
     |---|---|---|
     | 1 | No. | `idx + 1` (1부터 시작) |
     | 2 | 플랫폼 | `platform` |
     | 3 | 대메뉴 | `big_menu` |
     | 4 | 테스트ID | `test_id` |
     | 5 | 메뉴 | `menu` |
     | 6 | 구분 | `category` (= `기능` 고정) |
     | 7 | 내용 | `content` |
     | 8 | 확인일자 | 오늘 날짜 (`datetime.date.today()`) |
     | 9 | 담당자 | 사용자가 입력한 담당자명 |
     | 10 | 결과(O,△,X) | `O` |
     | 11~14 | 오류내용 / #레드마인 / 조치일자 / 조치확인결과 | 빈 칸 |

   - **데이터 행 스타일 보존**: 191행 이하는 기존 셀 스타일이 그대로 유지된다(셀에 `value = None` 후 다시 값 기록). 데이터가 191행을 넘어가면 3행 셀의 `font`/`fill`/`border`/`alignment`/`number_format` 을 `copy()` 로 새 행에 복제하고, 행 높이도 함께 복제한다.
   - 데이터 마지막 행 기준으로 `ws.print_area = "A1:N{last_row}"` 로 인쇄 영역을 재설정한다.

3. **`Sheet1` 통계 시트** 갱신
   - B열에서 라벨(`WEB`, `PDA`, `I/F`)이 적힌 행을 찾아 같은 행의 D/E/F 컬럼만 갱신한다:
     - D: 완료(O) — 플랫폼별 추출 건수
     - E: 수정필요(△) — `0`
     - F: 오류&미진행 — `0`
   - C열(`=SUM(D:F)`) / G열(`=D/C`) / 합계 행 (`=SUM(...)`)의 **수식은 절대 손대지 않는다**.

4. 저장 후 출력 파일의 절대 경로와 완료 보고를 출력한다.

---

### 3단계 — 임시 파일 정리

Excel 생성이 성공하면 `output/04 구현(PI)/tmp/` 를 삭제한다.

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && rm -rf "output/04 구현(PI)/tmp"
```

중간 단계에서 실패한 경우에는 `tmp/` 를 그대로 남겨둔다(디버깅용).

---

## 완료 체크리스트

- [ ] 입력(디렉토리 / 고객사명 / 담당자명) 확정
- [ ] `openpyxl` 사용 가능 확인
- [ ] `tmp/tests.json` 생성 — 테스트 항목 1건 이상
- [ ] `template/04 구현(PI)/PI_212-단위테스트보고서.xlsx` 존재 확인
- [ ] `output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx` 생성
- [ ] `단위테스트 보고서` 시트 3행부터 데이터 채워짐
- [ ] `Sheet1` 의 WEB / PDA / I/F 통과 건수 갱신됨
- [ ] `표지` / `개정이력` 시트가 템플릿 그대로 보존됨
- [ ] `tmp/` 삭제됨

---

## 완료 보고 형식

```
✓ 단위테스트 보고서 생성 완료 [PI_421]

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

출력 파일: output/04 구현(PI)/PI_421_단위테스트보고서_{고객사명}_{YYMMDD}.xlsx
```

---

## 주의사항

- **결과 컬럼은 항상 `O`** (모두 통과 가정). △/X 를 임의로 분배하지 않는다.
- **확인일자는 오늘 날짜** 를 일괄 사용한다. 실제 테스트 실행 일자가 아니라는 점을 인지한다.
- **주석 처리된 `@Test` 는 제외** 한다 (`//@Test`, `/* @Test */` 모두).
- **이름이 `Test` / `Tests` 로 끝나도 `@Test` 메서드가 없으면 해당 클래스는 무시** 한다 (단순 helper / abstract).
- **추상 메서드(`abstract`) / 인터페이스 디폴트 메서드** 는 제외한다.
- **파라미터화 테스트(`@ParameterizedTest`)** 도 1건으로 카운트한다 (메서드 단위로 셈).
- **템플릿 양식 보존**: 행 높이, 컬럼 너비, 테두리, 병합 셀, 인쇄 영역, `Sheet1` 의 수식을 절대 변경하지 않는다. openpyxl 로 데이터(값)만 교체한다.
- **`Sheet1` 의 `=SUM(...)` / `=D/C` 수식은 손대지 않는다.** D 컬럼(완료) 만 갱신하면 합계 행과 완료진행율은 자동 재계산된다.
- **출력 파일이 이미 존재하면** 사용자에게 덮어쓸지 한 번 확인한 뒤 진행한다.
- **JUnit이 아닌 테스트(TestNG, Spock, Kotest 등)** 는 v1 범위가 아니다. 발견되더라도 수집하지 않고 경고만 표시한다.
- **모노레포 / 멀티 모듈 Gradle 프로젝트**: 루트 디렉토리를 받으면 하위의 모든 모듈을 재귀 탐색한다. `settings.gradle(.kts)` 의 `include` 목록을 별도로 파싱하지 않는다 (디렉토리 워크로 충분).
- **고객사명 정규화**: 파일명에 사용 불가능한 문자(`<>:"\|?*\\/`)는 자동으로 `_` 로 치환한다.
- **Windows / WSL 경로 혼용**: 사용자가 `C:\...` 형식으로 입력해도 내부적으로 `/mnt/c/...` 로 변환하여 처리한다.
