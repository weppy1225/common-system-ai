---
name: PI_411_WIN
description: 【프로그램 소스 ZIP 생성 (Windows 전용)】 Windows 네이티브(PowerShell) 환경에서 사용자가 지정한 로컬 git 저장소 디렉토리의 전체 코드를 git archive(또는 gh CLI)로 ZIP 파일로 패키징하여 output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip 형식으로 자동 저장합니다. /PI_411_WIN 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. PowerShell에서 직접 실행 가능하도록 모든 명령은 PowerShell 문법으로 작성되어 있으며, WSL이나 Git Bash가 없어도 동작합니다. Windows에서 프로그램 소스 ZIP 생성, 소스 코드 패키징, 산출물용 소스 압축, 고객사 인계용 소스 ZIP 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "Windows에서 소스 ZIP 만들어줘", "PowerShell로 소스 압축해줘", "PI_411_WIN 실행해줘", "윈도우용 PI_411 실행해줘", "윈도우 PS로 소스 ZIP 뽑아줘" 라고 말해도 이 스킬을 사용합니다. 단, Linux/WSL/macOS 환경에서는 기본 PI_411 스킬을 사용합니다.
allowed-tools: Bash, Read, AskUserQuestion
---

# 프로그램 소스 ZIP 생성 (Windows 전용) [PI_411_WIN]

지정된 로컬 git 저장소 디렉토리를 `git archive` 명령으로 ZIP 파일로 패키징하여
`output/04 구현(PI)/PI_411_프로그램소스_{고객사명}.zip` 파일로 저장한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL·Git Bash 불필요.
>
> 사용 도구: 시스템에 설치된 `git`(필수). 원격 기준 zip이 필요한 경우에 한해 `gh`(선택). gh가 없거나 GitHub 외부 저장소면 `git archive`만 사용한다.
>
> 기본 동작: **`git archive HEAD`** (로컬 현재 브랜치의 HEAD 커밋 기준). git이 추적 중인 파일만 zip에 담기며, `.git` 폴더와 미커밋 변경은 포함되지 않는다.

> **Bash 도구 사용 규칙 (중요):**
> 이 스킬은 Windows 네이티브 환경을 가정한다. Bash 도구로 명령을 실행할 때는 반드시 다음 패턴 중 하나를 사용한다.
>
> ```
> powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "<PowerShell 명령>"
> ```
> 또는 PowerShell 7+ 이 있다면
> ```
> pwsh -NoProfile -Command "<PowerShell 명령>"
> ```
>
> 여러 줄 스크립트는 임시 `.ps1` 파일로 저장 후 `powershell.exe -File <path>` 로 실행한다.

---

## 사전 준비

### 1) 입력 받기

`$ARGUMENTS`는 무시한다. 다음 세 정보를 AskUserQuestion으로 차례대로 받는다.

| 입력 | 설명 |
|---|---|
| 디렉토리 경로 | git 저장소가 위치한 로컬 경로. 절대경로 권장. (예: `C:\zinide\workspace\cloud-wms-be`) |
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

- 사용자가 명시적으로 모드를 지정하지 않으면 `handoff`(고객사 인계용)를 기본으로 제안한다.
- `full` 모드는 사내 백업·아카이브 용도로만 사용한다.

### 2) 경로 정의

```
BASE       = C:\zinide\workspace\cloud-wms-doc
OUTPUT_DIR = output\04 구현(PI)
OUTFILE    = output\04 구현(PI)\PI_411_프로그램소스_{고객사명}.zip
```

`OUTPUT_DIR`이 없으면 `New-Item -ItemType Directory -Force` 로 생성한다.

> **경로 구분자 주의:** PowerShell은 `/`와 `\` 둘 다 인식하므로 둘 중 하나로 통일해서 쓴다. 본 스킬은 Windows 관행에 따라 `\`를 사용한다. 단, `git -C` 인자에는 `/`를 써도 무방하며, git archive의 `--prefix`는 zip 내부 경로이므로 반드시 `/`로 쓴다.

---

## 단계별 워크플로우

### 1단계 — 디렉토리 및 git 저장소 검증

```powershell
$TargetDir = "{디렉토리경로}"

# git 저장소 여부 확인
$check = git -C $TargetDir rev-parse --is-inside-work-tree 2>$null
if ($check -ne "true") {
    Write-Error "git 저장소가 아닙니다: $TargetDir"
    exit 1
}

# 정확한 저장소 루트로 정규화
$TargetDir = (git -C $TargetDir rev-parse --show-toplevel).Trim()
```

### 2단계 — 저장소 메타정보 수집

```powershell
Set-Location $TargetDir

$RepoName    = Split-Path -Leaf $TargetDir
$Branch      = (git rev-parse --abbrev-ref HEAD).Trim()
$ShortSha    = (git rev-parse --short HEAD).Trim()
$Subject     = (git log -1 --pretty=%s).Trim()
$Origin      = (git remote get-url origin 2>$null)
if (-not $Origin) { $Origin = "(없음)" }
$DirtyCount  = (git status --porcelain | Measure-Object -Line).Lines
```

수집한 메타정보는 완료 보고에 포함한다. `$DirtyCount > 0`이면 사용자에게 한 번 안내한다.

> 안내 문구 예시: "워킹 디렉토리에 미커밋 변경이 N개 있습니다. `git archive`는 HEAD 기준이라 이 변경은 zip에 포함되지 않습니다. 이대로 진행하시겠습니까?"

사용자가 "포함하고 싶다"라고 답하면 먼저 커밋하거나 `git stash` 후 진행하도록 안내하고, 일단 진행을 일시 중단한다. "이대로 진행"이면 다음 단계로 넘어간다.

### 3단계 — ZIP 생성 (기본: git archive)

공통 변수 준비:

```powershell
$BaseDir = "C:\zinide\workspace\cloud-wms-doc"
Set-Location $BaseDir

$OutDir = Join-Path $BaseDir "output\04 구현(PI)"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$Company = "{고객사명}"

# 브랜치명에 슬래시(/)가 있으면 (예: feature/spring-boot-migration) prefix에 그대로 쓰면
# zip 내부에 두 단계 폴더가 생기므로 _로 치환한다.
$SafeBranch = $Branch -replace '/', '_'
$Prefix     = "$RepoName-$SafeBranch/"

$OutFile = Join-Path $OutDir "PI_411_프로그램소스_$Company.zip"
```

#### 3-A. `full` 모드 — 전체 ZIP

```powershell
git -C $TargetDir archive `
    --format=zip `
    --prefix="$Prefix" `
    --output="$OutFile" `
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

##### B-3. PowerShell 스크립트 — 포함 경로 빌드 + 아카이브 실행

전체 스크립트가 길어지므로 임시 `.ps1` 파일로 저장 후 실행하는 것을 권장한다. 예: `$env:TEMP\PI_411_WIN.ps1`.

```powershell
# 포함 경로 배열 빌드 (추적 중인 것만)
$Include = New-Object System.Collections.Generic.List[string]

function Add-IfTracked {
    param([string]$Path)
    $tracked = git -C $TargetDir ls-files -- $Path 2>$null
    if ($tracked) { $Include.Add($Path) | Out-Null }
}

function Add-GlobRoot {
    param([string]$Pattern)
    # 루트 레벨에서 glob 매칭되는 추적 파일들을 모두 포함
    $files = git -C $TargetDir ls-files -- $Pattern 2>$null
    foreach ($f in $files) {
        if ($f -and ($f -notmatch '/')) { $Include.Add($f) | Out-Null }
    }
}

# 소스 + 메타
foreach ($p in @('src', '.gitignore', '.gitattributes')) { Add-IfTracked $p }

# README (대소문자/확장자 변형)
foreach ($p in @('README.md', 'README.me', 'README.txt', 'README.rst', 'README')) { Add-IfTracked $p }

# 빌드 - Ant/Maven/Gradle/Node/Python
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

# CI
Add-IfTracked 'Jenkinsfile'
Add-GlobRoot 'Jenkinsfile-*'
foreach ($p in @('.gitlab-ci.yml', 'azure-pipelines.yml')) { Add-IfTracked $p }

# 컨테이너
foreach ($p in @('Dockerfile', 'docker-compose.yml', 'docker-compose.yaml', '.dockerignore')) { Add-IfTracked $p }

# IDE 템플릿 + 루트 설정
foreach ($p in @('.project.template', '.classpath.template', '.editorconfig', 'lombok.config')) { Add-IfTracked $p }

# 검증: 최소한 src/ 는 있어야 함
if ($Include -notcontains 'src') {
    Write-Warning "src/ 디렉토리가 추적되지 않습니다. 표준 레이아웃이 아닐 수 있으니 'full' 모드 사용을 검토하세요."
    exit 1
}

Write-Host "포함 경로 $($Include.Count)개:"
$Include | ForEach-Object { Write-Host "  - $_" }

# 아카이브 실행 — pathspec 배열은 git에 그대로 인자로 전달
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

##### B-4. 커스텀 추가/제외가 필요한 경우

표준 후보 외에 프로젝트별 커스텀 디렉토리(예: `config/`, `scripts/`, `db/migration/`)도 포함하고 싶다면 사용자에게 확인 후 `$Include.Add('config')` 형태로 추가한다. 반대로 표준 후보 중 일부를 빼야 하면 빌드 후 `$Include.Remove(...)` 로 제거한다.

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

```powershell
Set-Location $TargetDir

# gh 인증 확인
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh가 인증되지 않았습니다. 'gh auth login' 후 다시 실행하세요."
    exit 1
}

$RepoFull = (gh repo view --json nameWithOwner -q .nameWithOwner).Trim()
$Branch   = (git rev-parse --abbrev-ref HEAD).Trim()

Set-Location $BaseDir
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$OutFile = Join-Path $OutDir "PI_411_프로그램소스_$Company.zip"

gh api "repos/$RepoFull/zipball/$Branch" | Set-Content -Path $OutFile -Encoding Byte
```

> **인코딩 주의:** PowerShell 5.1에서는 `Set-Content -Encoding Byte`를 사용하고, PowerShell Core 7+에서는 `-AsByteStream` 으로 대체한다. 또는 `gh api ... > $OutFile` 리다이렉트는 PowerShell이 UTF-16으로 변환할 수 있으니 반드시 바이너리 모드로 저장한다.
> 권장 패턴(PS Core):
> ```powershell
> gh api "repos/$RepoFull/zipball/$Branch" -H "Accept: application/vnd.github.v3.raw" | Set-Content -Path $OutFile -AsByteStream
> ```

원격이 GitHub이 아니면 (예: GitLab/Bitbucket) 이 방식은 사용 불가. 자동으로 방식 A(`git archive`)로 폴백한다.

### 4단계 — 결과 검증

```powershell
Set-Location $BaseDir

# 파일 존재 및 크기
if (-not (Test-Path $OutFile)) {
    Write-Error "ZIP 파일이 생성되지 않음: $OutFile"
    exit 1
}

$SizeBytes = (Get-Item $OutFile).Length
if ($SizeBytes -eq 0) {
    Write-Error "ZIP 파일이 비어 있음: $OutFile"
    exit 1
}

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}
$SizeHuman = Format-FileSize $SizeBytes

# 내부 항목 수 — .NET ZipArchive 사용 (외부 unzip 명령 불필요)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($OutFile)
$Entries = $zip.Entries.Count
$zip.Dispose()

Write-Host "ZIP 크기: $SizeHuman ($SizeBytes bytes)"
Write-Host "포함 항목: $Entries 개"
```

- 파일 크기가 0이거나 항목 수가 0이면 실패로 간주, 사용자에게 보고하고 종료한다.
- `$SizeBytes -gt 100MB` (104857600 bytes 초과) 이면 완료 보고에 경고 메시지를 추가한다.

---

## 완료 체크리스트

- [ ] 사용자에게 디렉토리·고객사명·패키징 모드 받기 (AskUserQuestion)
- [ ] 디렉토리가 git 저장소임을 확인 (`git rev-parse --is-inside-work-tree` = true)
- [ ] 현재 브랜치/커밋/원격 URL/dirty 여부 수집
- [ ] dirty면 사용자에게 안내 후 동의받고 진행
- [ ] `output\04 구현(PI)\` 폴더 생성 (`New-Item -ItemType Directory -Force`)
- [ ] 브랜치명의 `/`를 `_`로 치환 (`$SafeBranch`)
- [ ] `handoff` 모드면 포함 경로 화이트리스트 빌드 + `src` 추적 검증
- [ ] `git archive --format=zip --prefix=... --output=... [-- pathspecs]` 실행
- [ ] zip 파일 크기 0 아님 (`Get-Item.Length`)
- [ ] zip 내부 항목 수 0 아님 (.NET `ZipArchive.Entries.Count`)

---

## 완료 보고 형식

```
✓ 프로그램 소스 ZIP 생성 완료 [PI_411_WIN]

대상 저장소: {디렉토리경로}
저장소명:    {RepoName}
브랜치:      {Branch}
HEAD 커밋:   {ShortSha} ({Subject})
원격 URL:    {Origin}
워킹 상태:   clean   (또는 "dirty: N개 변경 — zip 미포함")

패키징 모드: handoff (고객사 인계용)   또는 full (전체)
생성 방식:   git archive    (또는 "gh api zipball")
실행 환경:   Windows PowerShell {PSVersion}
ZIP 내부 prefix: {RepoName}-{Branch}/

[handoff 모드일 때만]
포함 경로:   src, build.xml, Jenkinsfile, ...   (실제 $Include 배열 나열)
제외 정책:   .claude\, .agents\, .settings\, lib-test\, DEV_DOC\, CLAUDE.md, AGENTS.md, .project, .classpath 등

출력 파일:   output\04 구현(PI)\PI_411_프로그램소스_{고객사명}.zip ({SizeHuman})
포함 항목:   {Entries}개
```

---

## 주의사항 (Windows 특화)

- **PowerShell 실행 정책:** 시스템 정책이 `Restricted`이면 스크립트 실행이 막힌다. 본 스킬은 항상 `-ExecutionPolicy Bypass` 를 명시하여 호출하며, 사용자가 별도로 `Set-ExecutionPolicy` 를 변경할 필요는 없다.
- **PowerShell 버전 호환성:** 기본 동봉되는 Windows PowerShell 5.1과 PowerShell Core 7+ 모두에서 동작해야 한다. `Set-Content` 의 `-Encoding Byte`(5.1)와 `-AsByteStream`(7+) 차이에 주의한다. 가능하면 분기 처리한다.
- **경로 공백 처리:** "output\04 구현(PI)" 처럼 공백·한글이 포함된 경로는 반드시 큰따옴표로 감싼다. `Join-Path` 사용을 권장한다.
- **한글 콘솔 출력 깨짐:** PowerShell 콘솔이 cp949인 경우 한글 출력이 깨질 수 있다. 보고 직전에 아래 한 줄을 실행하면 UTF-8로 강제할 수 있다.
  ```powershell
  [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
  ```
- **git/gh 설치 확인:** Windows에는 git이 기본 설치되어 있지 않으므로 사전에 Git for Windows 설치가 필요하다. 스킬 시작 시 `git --version`·`gh --version` 으로 한 번 확인한다.
- **uncommitted 변경 미포함:** `git archive`는 HEAD 기준이므로 워킹 디렉토리의 미커밋 변경(modified, untracked)은 zip에 포함되지 않는다. 이는 의도된 동작이며, 산출물의 재현 가능성을 보장하기 위함이다. 미커밋 변경까지 포함하려면 사용자가 먼저 커밋하거나 stash를 활용해야 한다.
- **`.git` 폴더 미포함:** 산출물에 git 메타데이터(커밋 히스토리, 원격 URL 등)를 넣지 않는다. 고객사 인계용 소스이므로 의도된 동작이다.
- **`.gitignore` 동작:** `git archive`는 git이 추적 중인 파일만 담으므로, `.gitignore`에 의해 무시되는 파일(`node_modules/`, `build/`, `target/` 등)은 zip에 포함되지 않는다. 빌드 산출물도 함께 보내야 한다면 별도로 빌드 후 zip에 추가해야 한다.
- **고객사명 처리:** 파일명에 그대로 사용. 한글/공백 가능. 슬래시(`/`, `\`)나 운영체제 예약 문자(`<>:"|?*`)는 자동으로 `_`로 치환한다.
- **gh 인증 누락:** 방식 B(gh api zipball)를 선택했는데 `gh auth status`가 실패하면 사용자에게 `gh auth login`을 먼저 실행하도록 안내한다.
- **대용량 저장소:** zip 파일이 100MB를 초과하면 결과 보고에 경고 메시지를 추가한다. 빌드 산출물(`build/`, `target/`, `node_modules/`, `lib-test/` 등)이 `.gitignore`에 빠져 추적되고 있을 가능성이 크니 점검하도록 안내한다.
  ```powershell
  git ls-files | ForEach-Object { ($_ -split '/')[0] } | Sort-Object -Unique
  ```
- **브랜치명에 슬래시(`/`) 포함:** `feature/spring-boot-migration` 같이 슬래시가 들어간 브랜치명은 `--prefix`에 그대로 쓰면 zip 안에 두 단계 폴더가 만들어진다. `$SafeBranch = $Branch -replace '/', '_'` 로 치환하여 한 단계 폴더로 유지한다.
- **GitHub 외부 저장소:** 방식 B(gh api)는 사용할 수 없다. 자동으로 방식 A(git archive)로 폴백한다.
- **submodule:** `git archive`는 기본적으로 submodule 내용을 포함하지 않는다. submodule이 있는 저장소면 사용자에게 안내한다.
- **`handoff` 모드 — 누락 항목 점검:** 표준 후보 외에 프로젝트별 커스텀 디렉토리(예: `config/`, `scripts/`, `db/`, `infra/`)가 있을 수 있다. 결과 보고 직전에 다음 명령과 `$Include` 배열을 대조해서 누락 항목이 있는지 사용자에게 한 번 확인한다.
  ```powershell
  git ls-files | ForEach-Object { ($_ -split '/')[0] } | Sort-Object -Unique
  ```
- **`handoff` 모드 — 표준 레이아웃 가정:** `src/` 디렉토리 추적이 핵심 가정이다. 멀티모듈 모노레포(예: `frontend/`, `backend/` 분리)에서는 `src` 후보가 비어 있을 수 있으므로, 그 경우 사용자에게 후보 디렉토리(`backend/src`, `frontend/src` 등)를 직접 확인받아 `$Include` 에 추가한다.
