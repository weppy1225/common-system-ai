---
name: PI_411
description: 프로그램 소스 ZIP 생성 (git archive, Windows/WSL/Linux 자동 감지). /PI_411
when_to_use: "소스 ZIP 만들어줘", "프로그램 소스 압축해줘", "고객 인계용 소스 압축", "산출물용 소스 zip 뽑아줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell, Read, AskUserQuestion
---

# 프로그램 소스 ZIP 생성 (Windows/WSL/Linux/Mac 통합) [PI_411]

지정된 로컬 git 저장소 디렉토리를 `git archive` 명령으로 ZIP 파일로 패키징하여
`deliverables/30-output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip` 파일로 저장한다.

> 사용 도구: 시스템에 설치된 `git`(필수). 원격 기준 zip이 필요한 경우에 한해 `gh`(선택). gh가 없거나 GitHub 외부 저장소면 `git archive`만 사용한다.
>
> 기본 동작: **`git archive HEAD`** (로컬 현재 브랜치의 HEAD 커밋 기준). git이 추적 중인 파일만 zip에 담기며, `.git` 폴더와 미커밋 변경은 포함되지 않는다.

---

## OS 분기 — 가장 먼저 실행

스킬 시작 시 환경 변수 `OS` / `uname` 로 실행 환경을 판별하고, 이후 단계에서 **해당 OS 섹션의 블록만** 실행한다.

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 명령 없음
  → [Windows 섹션]의 PowerShell 블록 사용. `PowerShell` 도구 또는 `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "..."` 패턴.
- WSL / Linux / macOS (Bash):    uname 명령 존재 (Linux/Darwin)
  → [Bash 섹션]의 bash 블록 사용. `Bash` 도구 그대로 사용.
```

> 두 섹션의 로직(검증 → 메타정보 수집 → 화이트리스트 빌드 → archive 실행 → 검증)은 동일하며, OS 셸 문법만 다르다.

---

## 사전 준비 (공통)

### 1) 입력 받기

`$ARGUMENTS`는 무시한다. 다음 세 정보를 AskUserQuestion으로 차례대로 받는다.

| 입력 | 설명 |
|---|---|
| 디렉토리 경로 | git 저장소가 위치한 로컬 경로. 절대경로 권장. |
| 고객사명 | ZIP 파일명에 그대로 들어감. 한글/공백 가능. |
| 패키징 모드 | `full`(전체) 또는 `handoff`(고객사 인계용). 기본 `handoff`. |

- 디렉토리가 존재하지 않거나 git 저장소가 아니면 다시 묻는다.
- 고객사명이 비어 있으면 다시 묻는다.
- 고객사명에 운영체제 예약 문자(`<>:"|?*\\/`)가 포함되면 자동으로 `_`로 치환하고 사용자에게 변환된 결과를 알린다.

#### 패키징 모드 정의

| 모드 | 동작 |
|---|---|
| `full` | 추적 중인 모든 파일을 포함. `git archive HEAD` 단순 실행. |
| `handoff` | 고객사에게 인계할 **소스 + 빌드 설정**만 포함. AI/IDE 설정·개발 문서·테스트 라이브러리 자동 제외. |

### 2) 경로 정의

```
BASE       = $DocRoot         (git rev-parse --show-toplevel)
OUTPUT_DIR = deliverables/30-output/04 구현(PI)
OUTFILE    = deliverables/30-output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip
```

### 3) 포함/제외 정책 (handoff 모드)

#### 포함 후보 (있으면 포함)

| 카테고리 | 후보 |
|---|---|
| 소스 | `src` |
| 버전 관리 메타 | `.gitignore`, `.gitattributes` |
| README | `README.md`, `README.me`, `README.txt`, `README.rst`, `README` |
| 빌드 — Ant | `build.xml` |
| 빌드 — Maven | `pom.xml`, `mvnw`, `mvnw.cmd`, `.mvn` |
| 빌드 — Gradle | `build.gradle`, `build.gradle.kts`, `settings.gradle`, `settings.gradle.kts`, `gradle`, `gradlew`, `gradlew.bat`, `gradle.properties` |
| 빌드 — Node | `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `tsconfig.json` (+ `tsconfig.*.json`) |
| 빌드 — Python | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`, `Pipfile`, `Pipfile.lock`, `poetry.lock` |
| CI | `Jenkinsfile` (+ `Jenkinsfile-*`), `.gitlab-ci.yml`, `azure-pipelines.yml` |
| 컨테이너 | `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `.dockerignore` |
| IDE 템플릿 | `.project.template`, `.classpath.template` |
| 루트 설정 | `.editorconfig`, `lombok.config` |

#### 자동 제외 (pathspec에 포함하지 않음)

| 카테고리 | 제외 대상 |
|---|---|
| AI/도구 디렉토리 | `.claude/`, `.agents/`, `.codex/`, `.cursor/` |
| AI 가이드 문서 | `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, `GEMINI.md` |
| IDE 설정 | `.vscode/`, `.idea/`, `.settings/`, `.eclipse/` |
| 원시 IDE 파일 | `.project`, `.classpath` |
| 개발 내부 문서 | `DEV_DOC/`, `doc/`, `docs/` |
| 테스트 라이브러리 | `lib-test/`, `test-libs/` |
| GitHub 메타 | `.github/` |

---

# === Windows 섹션 (PowerShell) ===

> **Bash 도구 사용 규칙:** Windows 환경에서는 `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell 명령>"` 또는 PowerShell 7+ 이 있다면 `pwsh -NoProfile -Command "..."` 패턴 사용. 여러 줄 스크립트는 임시 `.ps1` 파일로 저장 후 `powershell.exe -File <path>`로 실행.

### W-0) 경로 동적 감지

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$Workspace = Split-Path $DocRoot -Parent
$RepoName = Split-Path $DocRoot -Leaf
if ($RepoName -match '^wms-(.+)-doc$') { $ProjCode = $Matches[1] } else { $ProjCode = "cloud" }
$BeRoot = Join-Path $Workspace "wms-$ProjCode-be"
$FeRoot = Join-Path $Workspace "wms-$ProjCode-fe"
```

### W-1) 디렉토리 및 git 저장소 검증

```powershell
$TargetDir = "{디렉토리경로}"
$check = git -C $TargetDir rev-parse --is-inside-work-tree 2>$null
if ($check -ne "true") {
    Write-Error "git 저장소가 아닙니다: $TargetDir"
    exit 1
}
$TargetDir = (git -C $TargetDir rev-parse --show-toplevel).Trim()
```

### W-2) 저장소 메타정보 수집

```powershell
Set-Location $TargetDir
$RepoName    = Split-Path -Leaf $TargetDir
$Branch      = (git rev-parse --abbrev-ref HEAD).Trim()
$ShortSha    = (git rev-parse --short HEAD).Trim()
$Subject     = (git log -1 --pretty=%s).Trim()
$Origin      = (git remote get-url origin 2>$null); if (-not $Origin) { $Origin = "(없음)" }
$DirtyCount  = (git status --porcelain | Measure-Object -Line).Lines
```

`$DirtyCount > 0`이면 사용자에게 한 번 안내한다.

### W-3) ZIP 생성 — 공통 변수

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
Set-Location $DocRoot
$OutDir = Join-Path $DocRoot "output\04 구현(PI)"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$Company    = "{고객사명}"
$SafeBranch = $Branch -replace '/', '_'
$Prefix     = "$RepoName-$SafeBranch/"
$OutFile    = Join-Path $OutDir "PI_411_프로그램소스_$Company.zip"
```

### W-3A) `full` 모드

```powershell
git -C $TargetDir archive `
    --format=zip `
    --prefix="$Prefix" `
    --output="$OutFile" `
    HEAD
```

### W-3B) `handoff` 모드 — 화이트리스트 빌드

전체 스크립트는 임시 `.ps1` 파일로 저장 후 실행 권장 (`$env:TEMP\PI_411.ps1`).

```powershell
$Include = New-Object System.Collections.Generic.List[string]

function Add-IfTracked {
    param([string]$Path)
    $tracked = git -C $TargetDir ls-files -- $Path 2>$null
    if ($tracked) { $Include.Add($Path) | Out-Null }
}

function Add-GlobRoot {
    param([string]$Pattern)
    $files = git -C $TargetDir ls-files -- $Pattern 2>$null
    foreach ($f in $files) {
        if ($f -and ($f -notmatch '/')) { $Include.Add($f) | Out-Null }
    }
}

foreach ($p in @('src', '.gitignore', '.gitattributes')) { Add-IfTracked $p }
foreach ($p in @('README.md', 'README.me', 'README.txt', 'README.rst', 'README')) { Add-IfTracked $p }

$buildCandidates = @(
    'build.xml',
    'pom.xml', 'mvnw', 'mvnw.cmd', '.mvn',
    'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts',
    'gradle', 'gradlew', 'gradlew.bat', 'gradle.properties',
    'package.json', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'tsconfig.json',
    'pyproject.toml', 'setup.py', 'setup.cfg', 'Pipfile', 'Pipfile.lock', 'poetry.lock'
)
foreach ($p in $buildCandidates) { Add-IfTracked $p }
Add-GlobRoot 'tsconfig.*.json'
Add-GlobRoot 'requirements*.txt'

Add-IfTracked 'Jenkinsfile'
Add-GlobRoot 'Jenkinsfile-*'
foreach ($p in @('.gitlab-ci.yml', 'azure-pipelines.yml')) { Add-IfTracked $p }
foreach ($p in @('Dockerfile', 'docker-compose.yml', 'docker-compose.yaml', '.dockerignore')) { Add-IfTracked $p }
foreach ($p in @('.project.template', '.classpath.template', '.editorconfig', 'lombok.config')) { Add-IfTracked $p }

if ($Include -notcontains 'src') {
    Write-Warning "src/ 디렉토리가 추적되지 않습니다. 표준 레이아웃이 아닐 수 있으니 'full' 모드 사용을 검토하세요."
    exit 1
}

$gitArgs = @(
    '-C', $TargetDir, 'archive',
    '--format=zip',
    "--prefix=$Prefix",
    "--output=$OutFile",
    'HEAD',
    '--'
) + $Include

& git @gitArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "git archive 실패 (exit $LASTEXITCODE)"
    exit 1
}
```

### W-3-alt) gh api zipball (원격 기준, 선택)

```powershell
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh가 인증되지 않았습니다. 'gh auth login' 후 다시 실행하세요."
    exit 1
}
$RepoFull = (gh repo view --json nameWithOwner -q .nameWithOwner).Trim()
gh api "repos/$RepoFull/zipball/$Branch" -H "Accept: application/vnd.github.v3.raw" | Set-Content -Path $OutFile -AsByteStream
```

> PowerShell 5.1은 `-Encoding Byte`, PowerShell 7+는 `-AsByteStream` 사용.

### W-4) 결과 검증

```powershell
if (-not (Test-Path $OutFile)) { Write-Error "ZIP 파일이 생성되지 않음: $OutFile"; exit 1 }
$SizeBytes = (Get-Item $OutFile).Length
if ($SizeBytes -eq 0) { Write-Error "ZIP 파일이 비어 있음: $OutFile"; exit 1 }

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}
$SizeHuman = Format-FileSize $SizeBytes

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($OutFile)
$Entries = $zip.Entries.Count
$zip.Dispose()

Write-Host "ZIP 크기: $SizeHuman ($SizeBytes bytes)"
Write-Host "포함 항목: $Entries 개"
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
FE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-fe"
```

### B-1) 디렉토리 및 git 저장소 검증

```bash
TARGET_DIR="{디렉토리경로}"
git -C "$TARGET_DIR" rev-parse --is-inside-work-tree 2>/dev/null
TARGET_DIR=$(git -C "$TARGET_DIR" rev-parse --show-toplevel)
```

### B-2) 저장소 메타정보 수집

```bash
cd "$TARGET_DIR"
REPO_NAME=$(basename "$TARGET_DIR")
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SHORT_SHA=$(git rev-parse --short HEAD)
SUBJECT=$(git log -1 --pretty=%s)
ORIGIN=$(git remote get-url origin 2>/dev/null || echo "(없음)")
DIRTY_COUNT=$(git status --porcelain | wc -l | tr -d ' ')
```

`DIRTY_COUNT > 0`이면 사용자에게 한 번 안내한다.

### B-3) ZIP 생성 — 공통 변수

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
cd "$DOC_ROOT"
mkdir -p "deliverables/30-output/04 구현(PI)"

COMPANY="{고객사명}"
SAFE_BRANCH=$(printf '%s' "$BRANCH" | tr '/' '_')
PREFIX="${REPO_NAME}-${SAFE_BRANCH}/"
OUTFILE="deliverables/30-output/04 구현(PI)/PI_411_프로그램소스_${COMPANY}.zip"
```

### B-3A) `full` 모드

```bash
git -C "$TARGET_DIR" archive \
  --format=zip \
  --prefix="$PREFIX" \
  --output="$(pwd)/$OUTFILE" \
  HEAD
```

### B-3B) `handoff` 모드 — 화이트리스트 빌드

```bash
INCLUDE=()

add_if_tracked() {
  local p="$1"
  if [ -n "$(git -C "$TARGET_DIR" ls-files -- "$p" 2>/dev/null | head -1)" ]; then
    INCLUDE+=( "$p" )
  fi
}

add_glob_root() {
  local pattern="$1"
  while IFS= read -r f; do
    [ -n "$f" ] && INCLUDE+=( "$f" )
  done < <(git -C "$TARGET_DIR" ls-files -- "$pattern" 2>/dev/null | awk -F/ 'NF==1')
}

for p in src .gitignore .gitattributes; do add_if_tracked "$p"; done
for p in README.md README.me README.txt README.rst README; do add_if_tracked "$p"; done

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

add_if_tracked "Jenkinsfile"
add_glob_root 'Jenkinsfile-*'
for p in .gitlab-ci.yml azure-pipelines.yml; do add_if_tracked "$p"; done
for p in Dockerfile docker-compose.yml docker-compose.yaml .dockerignore; do add_if_tracked "$p"; done
for p in .project.template .classpath.template .editorconfig lombok.config; do add_if_tracked "$p"; done

HAS_SRC=false
for p in "${INCLUDE[@]}"; do [ "$p" = "src" ] && HAS_SRC=true; done
if [ "$HAS_SRC" = false ]; then
  echo "⚠️  src/ 디렉토리가 추적되지 않습니다. 표준 레이아웃이 아닐 수 있으니 'full' 모드 사용을 검토하세요."
  exit 1
fi

git -C "$TARGET_DIR" archive \
  --format=zip \
  --prefix="$PREFIX" \
  --output="$(pwd)/$OUTFILE" \
  HEAD -- "${INCLUDE[@]}"
```

### B-3-alt) gh api zipball (원격 기준, 선택)

```bash
gh auth status >/dev/null 2>&1 || { echo "gh 인증 필요"; exit 1; }
REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/${REPO_FULL}/zipball/${BRANCH}" > "$OUTFILE"
```

### B-4) 결과 검증

```bash
test -s "$OUTFILE" || { echo "ZIP 파일이 비어 있거나 생성되지 않음: $OUTFILE"; exit 1; }

SIZE_BYTES=$(stat -c%s "$OUTFILE" 2>/dev/null || stat -f%z "$OUTFILE")
SIZE_HUMAN=$(du -h "$OUTFILE" | cut -f1)

if command -v unzip >/dev/null 2>&1; then
  ENTRIES=$(unzip -Z1 "$OUTFILE" | wc -l | tr -d ' ')
else
  ENTRIES=$(python3 -c "import zipfile,sys; print(len(zipfile.ZipFile(sys.argv[1]).namelist()))" "$OUTFILE")
fi

echo "ZIP 크기: $SIZE_HUMAN (${SIZE_BYTES} bytes)"
echo "포함 항목: ${ENTRIES}개"
```

---

## 완료 체크리스트 (공통)

- [ ] 사용자에게 디렉토리·고객사명·패키징 모드 받기 (AskUserQuestion)
- [ ] 디렉토리가 git 저장소임을 확인
- [ ] 현재 브랜치/커밋/원격 URL/dirty 여부 수집
- [ ] dirty면 사용자에게 안내 후 동의받고 진행
- [ ] `deliverables/30-output/04 구현(PI)/` 폴더 생성
- [ ] 브랜치명의 `/`를 `_`로 치환 (`SafeBranch` / `SAFE_BRANCH`)
- [ ] `handoff` 모드면 포함 경로 화이트리스트 빌드 + `src` 추적 검증
- [ ] `git archive --format=zip --prefix=... --output=... [-- pathspecs]` 실행
- [ ] zip 파일 크기 0 아님
- [ ] zip 내부 항목 수 0 아님

---

## 완료 보고 형식

```
✓ 프로그램 소스 ZIP 생성 완료 [PI_411]

실행 환경:   Windows PowerShell {PSVersion}   또는   Bash on Linux/Mac/WSL
대상 저장소: {디렉토리경로}
저장소명:    {RepoName}
브랜치:      {Branch}
HEAD 커밋:   {ShortSha} ({Subject})
원격 URL:    {Origin}
워킹 상태:   clean   (또는 "dirty: N개 변경 — zip 미포함")

패키징 모드: handoff (고객사 인계용)   또는 full (전체)
생성 방식:   git archive    (또는 "gh api zipball")
ZIP 내부 prefix: {RepoName}-{Branch}/

[handoff 모드일 때만]
포함 경로:   src, build.xml, Jenkinsfile, ...
제외 정책:   .claude/, .agents/, .settings/, lib-test/, DEV_DOC/, CLAUDE.md, AGENTS.md, .project, .classpath 등

출력 파일:   deliverables/30-output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip ({SizeHuman})
포함 항목:   {Entries}개
```

---

## 주의사항 (공통)

- **uncommitted 변경 미포함:** `git archive`는 HEAD 기준. 미커밋 변경은 zip에 포함되지 않음.
- **`.git` 폴더 미포함:** 산출물에 git 메타데이터를 담지 않음.
- **`.gitignore` 동작:** git이 추적 중인 파일만 포함됨.
- **고객사명 처리:** 슬래시(`/`, `\`)나 OS 예약 문자(`<>:"|?*`)는 자동 `_` 치환.
- **gh 인증 누락:** 방식 B(gh api zipball) 선택 시 `gh auth login` 안내.
- **대용량 저장소:** zip > 100MB면 경고. 빌드 산출물 추적 여부 점검.
- **브랜치명 슬래시:** `feature/xxx` 같은 경우 `SAFE_BRANCH`로 `_` 치환.
- **GitHub 외부 저장소:** gh api 사용 불가 → 자동으로 `git archive` 폴백.
- **submodule:** `git archive`는 submodule 내용 미포함.
- **handoff 모드 누락 점검:** 표준 후보 외 프로젝트별 커스텀 디렉토리 확인 필요.
- **handoff 모드 표준 레이아웃 가정:** `src/` 미추적 시 멀티모듈 후보(`backend/src`, `frontend/src`) 직접 확인.

### Windows 특화

- **PowerShell 실행 정책:** `-ExecutionPolicy Bypass`로 명시 호출.
- **PowerShell 버전:** 5.1 ↔ 7+ 차이 (`-Encoding Byte` ↔ `-AsByteStream`) 분기.
- **경로 공백:** "output\04 구현(PI)" 등 한글·공백 경로는 큰따옴표 또는 `Join-Path` 사용.
- **한글 콘솔 깨짐:** `[Console]::OutputEncoding = [Text.UTF8Encoding]::new()` 로 UTF-8 강제.
- **git/gh 설치:** Windows에 기본 미설치 — `git --version` / `gh --version` 사전 점검.
