---
name: PI_test_be
description: BE JUnit 단위테스트 + Bruno CLI API 테스트 실행 (Windows/WSL/Linux 자동 감지). /PI_test_be {메뉴코드}
when_to_use: "BE 테스트 실행해줘", "JUnit 테스트 돌려줘", "단위테스트 실행해줘", "Bruno 테스트 실행해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Bash, Glob
model: claude-sonnet-4-6
---

# BE 테스트 실행 [PI_test_be]

로컬 Gradle(또는 Ant)로 JUnit 레이어 테스트를 직접 실행하고, Controller는 Bruno CLI로 API 테스트한다.

## 실행 옵션

- `/PI_test_be {메뉴코드}` — 특정 메뉴코드 테스트 (`ZTEST_{메뉴코드}*` 패턴)
- `/PI_test_be` — 전체 JUnit 테스트 실행

## 테스트 유형 선택

| 유형 | 대상 레이어 | 도구 |
|---|---|---|
| JUnit (레이어 테스트) | Mapper / Dao / CompUtil / TxComp / Comp | Gradle 또는 Ant |
| API 테스트 | Controller | Bruno CLI |

---

## Step 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`./gradlew`, `build/test-results/...`, `src/main/java/...`)는 `$BE_DIR`(= 형제 `../{프로젝트}-be`) 기준이다.

---

## Step 1 — 실행 환경 및 빌드 도구 감지

OS를 먼저 감지한다:

```bash
uname -s 2>/dev/null || echo "Windows"
```

### Windows 환경 (gradlew.bat 우선)

```bash
test -f gradlew.bat && echo GRADLE_BAT || (test -f ./gradlew && echo GRADLE || (test -f build.xml && echo ANT || echo NONE))
```

### Linux/WSL/macOS 환경

```bash
test -f ./gradlew && echo GRADLE || (test -f build.xml && echo ANT || echo NONE)
```

| 결과 | 동작 |
|---|---|
| `GRADLE_BAT` | Step 2에서 `./gradlew.bat` 사용 |
| `GRADLE` | Step 2에서 `./gradlew` 사용 |
| `ANT` | Step 2 Ant fallback 실행 |
| `NONE` | 오류 보고 후 중단 |

---

## Step 2 — JUnit 레이어 테스트 (Gradle)

### Gradle — 특정 메뉴코드

```bash
# Windows
./gradlew.bat test --tests '*.ZTEST_{메뉴코드}*'

# Linux/WSL/macOS
./gradlew test --tests '*.ZTEST_{메뉴코드}*'
```

### Gradle — 전체 테스트

```bash
./gradlew test          # Linux/WSL/macOS
./gradlew.bat test      # Windows
```

### Gradle — 특정 레이어 단독

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'
./gradlew test --tests '*.ZTEST_{메뉴코드}Dao'
./gradlew test --tests '*.ZTEST_{메뉴코드}Comp'
```

### Ant fallback — 특정 메뉴코드

```bash
ant test -Dtest.pattern=ZTEST_{메뉴코드}*
```

### Ant fallback — 특정 클래스

```bash
ant test -Dtest.class=ZTEST_{메뉴코드}Mapper
ant test -Dtest.class=ZTEST_{메뉴코드}Comp
```

> Ant 사용 시 실제 `build.xml`을 Read 툴로 읽어 프로퍼티명(`test.pattern` / `test.class`)이 맞는지 확인한다.

---

## Step 3 — JUnit 결과 파싱

Gradle 실행 후 XML 결과 위치: `build/test-results/test/TEST-*.xml`

### 특정 메뉴코드 결과 파싱
```bash
find build/test-results/test -name "TEST-*ZTEST_{메뉴코드}*.xml" -exec cat {} \;
```

### 실패 파일만 특정
```bash
find build/test-results/test -name "TEST-*.xml" | xargs grep -l 'failures="[^0]"\|errors="[^0]"' 2>/dev/null
```

### 실패 메시지 상세
```bash
grep -A10 '<failure\|<error' build/test-results/test/TEST-*ZTEST_{메뉴코드}*.xml 2>/dev/null | head -100
```

### 성공/실패 집계
```bash
grep -h 'tests="\|failures="\|errors="' build/test-results/test/TEST-*.xml 2>/dev/null | \
  awk -F'"' '{for(i=1;i<=NF;i++){if($i~/(tests|failures|errors)=/)print $i"="$(i+1)}}'
```

---

## Step 4 — Bruno CLI API 테스트 (Controller)

### Bruno CLI 설치 확인
```bash
bru --version 2>/dev/null || npm install -g @usebruno/cli
```

### Bruno 파일 존재 확인
```bash
find src/main/java/be -type d -name "test" -path "*/{메뉴코드}/test" 2>/dev/null || echo "Bruno 파일 없음"
```

파일이 없으면:
> "Bruno 파일이 없습니다. Controller 완성 후 `src/main/java/be/{도메인}/{메뉴코드}/test/` 경로에 `.bru` 파일을 작성해 주세요."

### 폴더 전체 실행
```bash
bru run src/main/java/be/{도메인}/{메뉴코드}/test/ --env dev
```

### 단일 .bru 파일 실행
```bash
bru run src/main/java/be/{도메인}/{메뉴코드}/test/{테스트명}.bru --env dev
```

### JSON 보고서 생성
```bash
bru run src/main/java/be/{도메인}/{메뉴코드}/test/ --env dev --reporter json
```

---

## Step 5 — 결과 보고 포맷 (JUnit + Bruno 통합)

```
===== BE 테스트 결과 보고 =====
테스트 대상: {메뉴코드 또는 "전체"}
실행 환경: {Windows / Linux / WSL / macOS}
빌드 도구: Gradle / Ant
실행 시각: {시각}

[JUnit 레이어 결과]
- ZTEST_{메뉴코드}Mapper    : PASS (N개 테스트)
- ZTEST_{메뉴코드}Dao       : PASS (N개 테스트)
- ZTEST_{메뉴코드}CompUtil  : PASS (N개 테스트) [있는 경우]
- ZTEST_{메뉴코드}TxComp    : PASS (N개 테스트) [있는 경우]
- ZTEST_{메뉴코드}Comp      : PASS (N개 테스트)

[Bruno API 결과]
- {테스트명}.bru : PASS
- 총 N requests passed / M failed

[실패 시]
실패 클래스/파일: {클래스명 또는 .bru 파일명}
실패 메서드/요청: {메서드명 또는 요청명}
에러 메시지: {에러 내용}
원인 분석: {분석 결과}
```

---

## Step 6 — 실패 처리

### JUnit 실패

BUILD FAILED 시:
1. XML `<failure>` / `<error>` 태그 파싱으로 실패 케이스 특정
2. 원인 분류:
   - `NullPointerException` → 빈 객체 주입 문제
   - `DataAccessException` / `PSQLException` → SQL 오류, 컬럼명/타입 불일치
   - `BeanCreationException` → 스프링 빈 설정 오류
   - `AssertionError` → 기대값/실제값 불일치
   - `현재 트랜잭션은 중지되어 있습니다` cascade → **첫 번째 진짜 실패** 특정 후 그것만 fix
3. 수정 → 동일 명령 재실행
4. 3회 연속 동일 실패 → 자동 수정 루프 중단 + 사용자에게 상세 보고

stale .class 의심 시:
```bash
./gradlew cleanTest test --tests '*.ZTEST_{메뉴코드}*'
```

### Bruno 실패

| 오류 | 원인 | 조치 |
|---|---|---|
| `✗ assertion failed` | API 응답값 불일치 | 응답 필드 및 Controller 로직 점검 |
| `connect ECONNREFUSED` | 서버 미기동 | Spring Boot 서버 실행 후 재시도 |
| `401 Unauthorized` | 인증 토큰 만료 | `dev` 환경 파일의 토큰 갱신 |
| `404 Not Found` | 엔드포인트 URL 오류 | `.bru` 파일의 URL 및 Controller 매핑 확인 |

---

## 레이어별 테스트 시점 요약

| 단계 | 명령어 | 완료 조건 |
|---|---|---|
| Mapper 완성 | `./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'` | BUILD SUCCESSFUL |
| Dao 완성 | `./gradlew test --tests '*.ZTEST_{메뉴코드}Dao'` | BUILD SUCCESSFUL |
| CompUtil/TxComp 완성 | `./gradlew test --tests '*.ZTEST_{메뉴코드}CompUtil'` 등 | BUILD SUCCESSFUL |
| Comp 완성 | `./gradlew test --tests '*.ZTEST_{메뉴코드}Comp'` | BUILD SUCCESSFUL |
| Controller 완성 | `bru run src/main/java/be/{도메인}/{메뉴코드}/test/ --env dev` | 전체 request PASS |
