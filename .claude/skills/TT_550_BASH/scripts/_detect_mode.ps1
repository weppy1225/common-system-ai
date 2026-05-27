# TT_550 0단계 - 실행 모드 자동 감지
# Python+psycopg2 우선 / pg_dump+psql 폴백
# 결과: mode.json 파일 (PYTHON / POWERSHELL / ERROR)
#
# 사용법:
#   .\_detect_mode.ps1 [-ModeFile <출력 경로>]
#
# 종료 코드:
#   0  = 감지 성공 (모드와 도구 경로가 mode.json 에 기록됨)
#   1  = 둘 다 사용 불가 (Python 자체 없음 또는 psycopg2/pg 모두 없음)

param(
    [string]$ModeFile = ""
)

$ErrorActionPreference = "Continue"
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
try { chcp 65001 | Out-Null } catch {}

# 1) Python 자체 체크 (_scan_config.py 실행에 필요)
$pyExe = $null
$pyVer = $null
foreach ($cmd in @("python", "py -3")) {
    try {
        $out = (& cmd /c "$cmd --version" 2>&1) | Out-String
        if ($LASTEXITCODE -eq 0 -and $out -match "Python") {
            $pyExe = $cmd
            $pyVer = ($out.Trim() -replace "Python\s+","")
            break
        }
    } catch {}
}

if (-not $pyExe) {
    Write-Host "ERROR: Python 이 설치되어 있지 않습니다." -ForegroundColor Red
    Write-Host "  TT_550 은 BE 경로 스캔에 Python (표준 라이브러리) 이 필요합니다." -ForegroundColor Red
    Write-Host "  https://www.python.org/downloads/ 에서 설치하세요."
    exit 1
}

# 2) psycopg2 체크 (PYTHON 모드 가능 여부)
$pycopgOk = $false
$pycopgVer = $null
& cmd /c "$pyExe -c `"import psycopg2; print(psycopg2.__version__)`"" 2>$null | ForEach-Object {
    if ($_ -match "^\d+\.\d+") {
        $pycopgOk = $true
        $pycopgVer = $_.Trim()
    }
}
if (-not $pycopgOk) {
    # python-c 출력이 stderr로 갔을 수도 있으므로 한 번 더 시도
    $tmpOut = & cmd /c "$pyExe -c `"import psycopg2; print(psycopg2.__version__)`"" 2>&1
    if ($LASTEXITCODE -eq 0 -and $tmpOut) {
        $pycopgOk = $true
        $pycopgVer = ($tmpOut | Out-String).Trim()
    }
}

# 3) pg_dump / psql 체크 (POWERSHELL 모드 가능 여부)
$PG_BIN = $null
try {
    $PG_BIN = (Get-Item "C:\Program Files\PostgreSQL\*\bin" -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending | Select-Object -First 1).FullName
} catch {}

$pgDump = $null
$psql = $null
if ($PG_BIN -and (Test-Path "$PG_BIN\pg_dump.exe")) {
    $pgDump = "$PG_BIN\pg_dump.exe"
    $psql = "$PG_BIN\psql.exe"
}
if (-not $pgDump) {
    $cmd = Get-Command pg_dump -ErrorAction SilentlyContinue
    if ($cmd) { $pgDump = $cmd.Source }
}
if (-not $psql) {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($cmd) { $psql = $cmd.Source }
}

$pgDumpVer = $null
$psqlVer = $null
if ($pgDump) {
    try { $pgDumpVer = (& $pgDump --version 2>$null | Out-String).Trim() } catch {}
}
if ($psql) {
    try { $psqlVer = (& $psql --version 2>$null | Out-String).Trim() } catch {}
}
$pgOk = ($pgDump -and $psql)

# 4) 모드 결정
$mode = $null
if ($pycopgOk) {
    $mode = "PYTHON"
} elseif ($pgOk) {
    $mode = "POWERSHELL"
} else {
    Write-Host "ERROR: TT_550 실행을 위해 다음 중 하나가 필요합니다:" -ForegroundColor Red
    Write-Host "  [A] Python + psycopg2-binary  (권장)" -ForegroundColor Yellow
    Write-Host "      → $pyExe -m pip install --user psycopg2-binary"
    Write-Host "  [B] PostgreSQL 클라이언트 (psql.exe + pg_dump.exe)" -ForegroundColor Yellow
    Write-Host "      → https://www.postgresql.org/download/windows/"
    exit 1
}

$result = [pscustomobject]@{
    mode = $mode
    python = $pyExe
    python_version = $pyVer
    has_psycopg2 = $pycopgOk
    psycopg2_version = $pycopgVer
    pg_bin = $PG_BIN
    pg_dump = $pgDump
    pg_dump_version = $pgDumpVer
    psql = $psql
    psql_version = $psqlVer
    detected_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz")
}

if ($ModeFile) {
    $dir = Split-Path $ModeFile -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $result | ConvertTo-Json -Depth 4 | Out-File -Encoding UTF8 -FilePath $ModeFile
}

Write-Host "[TT_550] 실행 모드: $mode" -ForegroundColor Cyan
Write-Host "  Python:     $pyExe ($pyVer)"
if ($pycopgOk) { Write-Host "  psycopg2:   $pycopgVer" }
if ($pgOk)     { Write-Host "  pg_dump:    $pgDumpVer" }
if ($pgOk)     { Write-Host "  psql:       $psqlVer" }

return $result
