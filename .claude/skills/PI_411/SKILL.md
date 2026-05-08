---
name: PI_411
description: 【프로그램 소스 ZIP 생성】 사용자가 지정한 로컬 git 저장소 디렉토리의 전체 코드를 git archive(또는 gh CLI)로 ZIP 파일로 패키징하여 output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip 형식으로 자동 저장합니다. /PI_411 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. 프로그램 소스 ZIP 생성, 소스 코드 패키징, 산출물용 소스 압축, 고객사 인계용 소스 ZIP 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "소스 ZIP 만들어줘", "프로그램 소스 압축해줘", "PI_411 실행해줘", "산출물용 소스 zip 뽑아줘", "git 저장소 zip으로 다운로드해줘", "고객 인계용 소스 압축" 이라고 말해도 이 스킬을 사용합니다.
allowed-tools: Bash, Read, AskUserQuestion
---

# 프로그램 소스 ZIP 생성 [PI_411]

지정된 로컬 git 저장소 디렉토리를 `git archive` 명령으로 ZIP 파일로 패키징하여
`output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip` 파일로 저장한다.

> 사용 도구: 시스템에 설치된 `git`(필수). 원격 기준 zip이 필요한 경우에 한해 `gh`(선택). gh가 없거나 GitHub 외부 저장소면 `git archive`만 사용한다.

> 기본 동작: **`git archive HEAD`** (로컬 현재 브랜치의 HEAD 커밋 기준). git이 추적 중인 파일만 zip에 담기며, `.git` 폴더와 미커밋 변경은 포함되지 않는다.

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS`는 무시한다. 다음 세 정보를 AskUserQuestion으로 차례대로 받는다.

| 입력 | 설명 |
|---|---|
| 디렉토리 경로 | git 저장소가 위치한 로컬 경로. 절대경로 권장. (예: `/mnt/c/zinide/workspace/cloud-wms-be`) |
| 고객사명 | ZIP 파일명에 그대로 들어감. 한글/공백 가능. |
| 패키징 모드 | `full`(전체 — 추적된 모든 파일) 또는 `handoff`(고객사 인계용 — 코드+빌드설정만). 기본값은 `handoff`. |

- 디렉토리가 존재하지 않거나 git 저장소가 아니면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.
- 고객사명에 운영체제 예약 문자(`<>:"|?*\\/`)가 포함되면 자동으로 `_`로 치환하고 사용자에게 변환된 결과를 알린다.

#### 패키징 모드 정의

| 모드 | 동작 |
|---|---|
| `full` | 추적 중인 모든 파일을 포함. `git archive HEAD` 단순 실행. |
| `handoff` | 고객사에게 인계할 **소스 + 빌드 설정**만 포함. AI/IDE 설정, 개발 문서, 테스트 라이브러리 등을 자동 제외하여 ZIP 크기를 최소화. |

- 사용자가 명시적으로 모드를 지정하지 않으면 `handoff`(고객사 인계용)를 기본으로 제안한다. 산출물 목적이 고객 인계이기 때문이다.
- `full` 모드는 사내 백업·아카이브 용도로만 사용한다.

### 2) 경로 정의

```
BASE       = /mnt/c/zinide/workspace/cloud-wms-doc
OUTPUT_DIR = output/04 구현(PI)
OUTFILE    = output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip
```

`OUTPUT_DIR`이 없으면 `mkdir -p`로 생성한다.

---

## 단계별 워크플로우

### 1단계 — 디렉토리 및 git 저장소 검증

```bash
TARGET_DIR="{디렉토리경로}"
git -C "$TARGET_DIR" rev-parse --is-inside-work-tree 2>/dev/null
```

출력이 `true`가 아니면 git 저장소가 아니다. 사용자에게 디렉토리를 다시 묻는다.

```bash
# 정확한 저장소 루트로 정규화 (서브디렉토리에서 호출되어도 루트로 이동)
TARGET_DIR=$(git -C "$TARGET_DIR" rev-parse --show-toplevel)
```

### 2단계 — 저장소 메타정보 수집

```bash
cd "$TARGET_DIR"

REPO_NAME=$(basename "$TARGET_DIR")
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SHORT_SHA=$(git rev-parse --short HEAD)
SUBJECT=$(git log -1 --pretty=%s)
ORIGIN=$(git remote get-url origin 2>/dev/null || echo "(없음)")
DIRTY_COUNT=$(git status --porcelain | wc -l | tr -d ' ')
```

수집한 메타정보는 완료 보고에 포함한다. `DIRTY_COUNT > 0`이면 사용자에게 한 번 안내한다.

> 안내 문구 예시: "워킹 디렉토리에 미커밋 변경이 N개 있습니다. `git archive`는 HEAD 기준이라 이 변경은 zip에 포함되지 않습니다. 이대로 진행하시겠습니까?"

사용자가 "포함하고 싶다"라고 답하면 먼저 커밋하거나 `git stash` 후 진행하도록 안내하고, 일단 진행을 일시 중단한다. "이대로 진행"이면 다음 단계로 넘어간다.

### 3단계 — ZIP 생성 (기본: git archive)

공통 변수 준비:

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc
mkdir -p "output/04 구현(PI)"

COMPANY="{고객사명}"

# 브랜치명에 슬래시(/)가 있으면 (예: feature/spring-boot-migration) prefix에 그대로 쓰면
# zip 내부에 두 단계 폴더가 생기므로 _로 치환한다.
SAFE_BRANCH=$(printf '%s' "$BRANCH" | tr '/' '_')
PREFIX="${REPO_NAME}-${SAFE_BRANCH}/"
OUTFILE="output/04 구현(PI)/PI_411_프로그램소스_${COMPANY}.zip"
```

#### 3-A. `full` 모드 — 전체 ZIP

```bash
git -C "$TARGET_DIR" archive \
  --format=zip \
  --prefix="$PREFIX" \
  --output="$(pwd)/$OUTFILE" \
  HEAD
```

#### 3-B. `handoff` 모드 — 고객사 인계용 ZIP (필터링)

핵심: `git archive HEAD -- {pathspecs}` 형태로 **포함할 경로만 명시 전달**한다. 추적 여부를 미리 확인해서 존재하는 항목만 pathspec에 추가한다 (없는 경로를 넘기면 git archive가 에러 종료).

##### B-1. 포함 경로 후보 정의

| 카테고리 | 후보 (있으면 포함) |
|---|---|
| **소스** | `src` |
| **버전 관리 메타** | `.gitignore`, `.gitattributes` |
| **README** | `README.md`, `README.me`, `README.txt`, `README.rst`, `README` |
| **빌드 — Ant** | `build.xml` |
| **빌드 — Maven** | `pom.xml`, `mvnw`, `mvnw.cmd`, `.mvn` |
| **빌드 — Gradle** | `build.gradle`, `build.gradle.kts`, `settings.gradle`, `settings.gradle.kts`, `gradle`, `gradlew`, `gradlew.bat`, `gradle.properties` |
| **빌드 — Node** | `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `tsconfig.json` (+ `tsconfig.*.json`) |
| **빌드 — Python** | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`, `Pipfile`, `Pipfile.lock`, `poetry.lock` |
| **CI** | `Jenkinsfile` (+ `Jenkinsfile-*`), `.gitlab-ci.yml`, `azure-pipelines.yml` |
| **컨테이너** | `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `.dockerignore` |
| **IDE 템플릿** | `.project.template`, `.classpath.template` (실제 `.project`/`.classpath`는 제외) |
| **루트 설정** | `.editorconfig`, `lombok.config` |

##### B-2. 자동 제외 항목 (pathspec에 절대 포함하지 않음)

| 카테고리 | 제외 대상 |
|---|---|
| AI/도구 디렉토리 | `.claude/`, `.agents/`, `.codex/`, `.cursor/` |
| AI 가이드 문서 | `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, `GEMINI.md` |
| IDE 설정 | `.vscode/`, `.idea/`, `.settings/`, `.eclipse/` |
| 원시 IDE 파일 | `.project`, `.classpath` (템플릿 버전만 인계) |
| 개발 내부 문서 | `DEV_DOC/`, `doc/`, `docs/` |
| 테스트 라이브러리 | `lib-test/`, `test-libs/` |
| GitHub 메타 | `.github/` |

> 제외 항목은 pathspec에 추가하지 않는 방식으로 자연스럽게 빠진다. `:!exclude` 패턴은 사용하지 않는다 (포함 경로 화이트리스트만으로 충분).

##### B-3. 쉘 스크립트 — 포함 경로 빌드 + 아카이브 실행

```bash
# 포함 경로 배열 빌드 (추적 중인 것만)
INCLUDE=()

add_if_tracked() {
  local p="$1"
  if [ -n "$(git -C "$TARGET_DIR" ls-files -- "$p" 2>/dev/null | head -1)" ]; then
    INCLUDE+=( "$p" )
  fi
}

add_glob_root() {
  # 루트 레벨에서 glob 매칭되는 추적 파일들을 모두 포함
  local pattern="$1"
  while IFS= read -r f; do
    [ -n "$f" ] && INCLUDE+=( "$f" )
  done < <(git -C "$TARGET_DIR" ls-files -- "$pattern" 2>/dev/null | awk -F/ 'NF==1')
}

# 소스 + 메타
for p in src .gitignore .gitattributes; do add_if_tracked "$p"; done

# README (대소문자/확장자 변형)
for p in README.md README.me README.txt README.rst README; do add_if_tracked "$p"; done

# 빌드 - Ant/Maven/Gradle/Node/Python
for p in \
  build.xml \
  pom.xml mvnw mvnw.cmd .mvn \
  build.gradle build.gradle.kts settings.gradle settings.gradle.kts \
  gradle gradlew gradlew.bat gradle.properties \
  package.json package-lock.json yarn.lock pnpm-lock.yaml tsconfig.json \
  pyproject.toml setup.py setup.cfg Pipfile Pipfile.lock poetry.lock; do
  add_if_tracked "$p"
done
add_glob_root 'tsconfig.*.json'
add_glob_root 'requirements*.txt'

# CI
add_if_tracked "Jenkinsfile"
add_glob_root 'Jenkinsfile-*'
for p in .gitlab-ci.yml azure-pipelines.yml; do add_if_tracked "$p"; done

# 컨테이너
for p in Dockerfile docker-compose.yml docker-compose.yaml .dockerignore; do add_if_tracked "$p"; done

# IDE 템플릿 + 루트 설정
for p in .project.template .classpath.template .editorconfig lombok.config; do add_if_tracked "$p"; done

# 검증: 최소한 src/ 는 있어야 함
HAS_SRC=false
for p in "${INCLUDE[@]}"; do [ "$p" = "src" ] && HAS_SRC=true; done
if [ "$HAS_SRC" = false ]; then
  echo "⚠️  src/ 디렉토리가 추적되지 않습니다. 표준 레이아웃이 아닐 수 있으니 'full' 모드 사용을 검토하세요."
  exit 1
fi

echo "포함 경로 ${#INCLUDE[@]}개:"
printf '  - %s\n' "${INCLUDE[@]}"

# 아카이브 실행
git -C "$TARGET_DIR" archive \
  --format=zip \
  --prefix="$PREFIX" \
  --output="$(pwd)/$OUTFILE" \
  HEAD -- "${INCLUDE[@]}"
```

##### B-4. 커스텀 추가/제외가 필요한 경우

표준 후보 외에 프로젝트별 커스텀 디렉토리(예: `config/`, `scripts/`, `db/migration/`)도 포함하고 싶다면 사용자에게 확인 후 `INCLUDE+=( "config" )` 형태로 추가한다. 반대로 표준 후보 중 일부를 빼야 하면 빌드 후 `INCLUDE=( ... )` 에서 해당 항목을 제거한다.

##### 옵션 설명 (공통)

- `--format=zip`: 명시적으로 ZIP 형식 지정. (구버전 git에서도 안전)
- `--prefix={REPO_NAME}-{SAFE_BRANCH}/`: 압축을 풀면 `cloud-wms-be-main/` 같은 폴더 안에 파일이 풀린다. (GitHub zipball과 동일 구조)
- `HEAD`: 현재 브랜치의 최신 커밋 트리.
- `SAFE_BRANCH`: 브랜치명의 `/`를 `_`로 치환하여 zip 내부 폴더가 한 단계로 유지되도록 한다.
- `-- {pathspecs}`: `handoff` 모드에서만 사용. 화이트리스트로 포함할 경로 명시.

> 포함 범위: git이 추적 중(=tracked)인 파일만 포함된다. `.gitignore`에 무관하게 untracked/modified 파일은 zip에 들어가지 않는다.
> `.git` 폴더는 포함되지 않는다 (산출물에 git 메타데이터를 담지 않는다).

### 3단계 (대안) — gh api zipball (원격 기준)

사용자가 명시적으로 "원격 기준 zip"을 요청했거나, 로컬보다 원격이 더 최신이라고 알려진 경우에만 사용한다.

```bash
cd "$TARGET_DIR"

# gh 인증 확인
gh auth status >/dev/null 2>&1 || {
  echo "gh가 인증되지 않았습니다. 'gh auth login' 후 다시 실행하세요."
  exit 1
}

REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

cd /mnt/c/zinide/workspace/cloud-wms-doc
mkdir -p "output/04 구현(PI)"
OUTFILE="output/04 구현(PI)/PI_411_프로그램소스_${COMPANY}.zip"

gh api "repos/${REPO_FULL}/zipball/${BRANCH}" > "$OUTFILE"
```

원격이 GitHub이 아니면 (예: GitLab/Bitbucket) 이 방식은 사용 불가. 자동으로 방식 A(`git archive`)로 폴백한다.

### 4단계 — 결과 검증

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc

# 파일 존재 및 크기
test -s "$OUTFILE" || { echo "ZIP 파일이 비어 있거나 생성되지 않음: $OUTFILE"; exit 1; }

SIZE_BYTES=$(stat -c%s "$OUTFILE" 2>/dev/null || stat -f%z "$OUTFILE")
SIZE_HUMAN=$(du -h "$OUTFILE" | cut -f1)

# 내부 항목 수 (unzip이 없으면 python으로 폴백)
if command -v unzip >/dev/null 2>&1; then
  ENTRIES=$(unzip -Z1 "$OUTFILE" | wc -l | tr -d ' ')
else
  ENTRIES=$(python3 -c "import zipfile,sys; print(len(zipfile.ZipFile(sys.argv[1]).namelist()))" "$OUTFILE")
fi

echo "ZIP 크기: $SIZE_HUMAN (${SIZE_BYTES} bytes)"
echo "포함 항목: ${ENTRIES}개"
```

- 파일 크기가 0이거나 항목 수가 0이면 실패로 간주, 사용자에게 보고하고 종료한다.
- `SIZE_BYTES > 100MB`이면 완료 보고에 경고 메시지를 추가한다.

---

## 완료 체크리스트

- [ ] 사용자에게 디렉토리·고객사명·패키징 모드 받기 (AskUserQuestion)
- [ ] 디렉토리가 git 저장소임을 확인 (`git rev-parse --is-inside-work-tree` = true)
- [ ] 현재 브랜치/커밋/원격 URL/dirty 여부 수집
- [ ] dirty면 사용자에게 안내 후 동의받고 진행
- [ ] `output/04 구현(PI)/` 폴더 생성
- [ ] 브랜치명의 `/`를 `_`로 치환 (`SAFE_BRANCH`)
- [ ] `handoff` 모드면 포함 경로 화이트리스트 빌드 + `src` 추적 검증
- [ ] `git archive --format=zip --prefix=... --output=... [-- pathspecs]` 실행
- [ ] zip 파일 크기 0 아님
- [ ] zip 내부 항목 수 0 아님

---

## 완료 보고 형식

```
✓ 프로그램 소스 ZIP 생성 완료 [PI_411]

대상 저장소: {디렉토리경로}
저장소명:    {REPO_NAME}
브랜치:      {BRANCH}
HEAD 커밋:   {SHORT_SHA} ({SUBJECT})
원격 URL:    {ORIGIN}
워킹 상태:   clean   (또는 "dirty: N개 변경 — zip 미포함")

패키징 모드: handoff (고객사 인계용)   또는 full (전체)
생성 방식:   git archive    (또는 "gh api zipball")
ZIP 내부 prefix: {REPO_NAME}-{BRANCH}/

[handoff 모드일 때만]
포함 경로:   src, build.xml, Jenkinsfile, ...   (실제 INCLUDE 배열 나열)
제외 정책:   .claude/, .agents/, .settings/, lib-test/, DEV_DOC/, CLAUDE.md, AGENTS.md, .project, .classpath 등

출력 파일:   output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip ({SIZE_HUMAN})
포함 항목:   {ENTRIES}개
```

---

## 주의사항

- **uncommitted 변경 미포함**: `git archive`는 HEAD 기준이므로 워킹 디렉토리의 미커밋 변경(modified, untracked)은 zip에 포함되지 않는다. 이는 의도된 동작이며, 산출물의 재현 가능성을 보장하기 위함이다. 미커밋 변경까지 포함하려면 사용자가 먼저 커밋하거나 stash를 활용해야 한다.
- **`.git` 폴더 미포함**: 산출물에 git 메타데이터(커밋 히스토리, 원격 URL 등)를 넣지 않는다. 고객사 인계용 소스이므로 의도된 동작이다.
- **`.gitignore` 동작**: `git archive`는 git이 추적 중인 파일만 담으므로, `.gitignore`에 의해 무시되는 파일(`node_modules/`, `build/`, `target/` 등)은 zip에 포함되지 않는다. 빌드 산출물도 함께 보내야 한다면 별도로 빌드 후 zip에 추가해야 한다.
- **고객사명 처리**: 파일명에 그대로 사용. 한글/공백 가능. 슬래시(`/`, `\\`)나 운영체제 예약 문자(`<>:"|?*`)는 자동으로 `_`로 치환한다.
- **gh 인증 누락**: 방식 B(gh api zipball)를 선택했는데 `gh auth status`가 실패하면 사용자에게 `gh auth login`을 먼저 실행하도록 안내한다.
- **대용량 저장소**: zip 파일이 100MB를 초과하면 결과 보고에 경고 메시지를 추가한다. 빌드 산출물(`build/`, `target/`, `node_modules/`, `lib-test/` 등)이 `.gitignore`에 빠져 추적되고 있을 가능성이 크니 점검하도록 안내한다. (`git ls-files | awk -F/ '{print $1}' | sort -u` 로 추적 중인 최상위 항목 확인)
- **브랜치명에 슬래시(`/`) 포함**: `feature/spring-boot-migration` 같이 슬래시가 들어간 브랜치명은 `--prefix`에 그대로 쓰면 zip 안에 두 단계 폴더가 만들어진다. `SAFE_BRANCH=$(... | tr '/' '_')` 로 치환하여 한 단계 폴더로 유지한다.
- **GitHub 외부 저장소**: 방식 B(gh api)는 사용할 수 없다. 자동으로 방식 A(git archive)로 폴백한다.
- **submodule**: `git archive`는 기본적으로 submodule 내용을 포함하지 않는다. submodule이 있는 저장소면 사용자에게 안내한다.
- **`handoff` 모드 — 누락 항목 점검**: 표준 후보 외에 프로젝트별 커스텀 디렉토리(예: `config/`, `scripts/`, `db/`, `infra/`)가 있을 수 있다. 결과 보고 직전에 `git ls-files | awk -F/ '{print $1}' | sort -u` 와 INCLUDE 배열을 대조해서 누락 항목이 있는지 사용자에게 한 번 확인한다.
- **`handoff` 모드 — 표준 레이아웃 가정**: `src/` 디렉토리 추적이 핵심 가정이다. 멀티모듈 모노레포(예: `frontend/`, `backend/` 분리)에서는 `src` 후보가 비어 있을 수 있으므로, 그 경우 사용자에게 후보 디렉토리(`backend/src`, `frontend/src` 등)를 직접 확인받아 INCLUDE에 추가한다.
