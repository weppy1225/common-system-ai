# ============================================================
# SD.212 테이블정의서 자동 생성 스크립트
# - MD 파일 (cloud-wms-be/DEV_DOC) -> Excel 변환
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# 1. 환경 설정
# ------------------------------------------------------------
$repoRoot     = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$tableDir     = Join-Path $repoRoot "90-archive\cloud-wms-be\DEV_DOC\ai-docs\10-database\90-schema\20-tables"
$templatePath = Join-Path $repoRoot "deliverables\10-templates\03 설계(SD)\SD.212-테이블정의서.xlsx"
$outputDir    = Join-Path $repoRoot "deliverables\30-output\03 설계(SD)"
$outputPath   = Join-Path $outputDir "SD.212-테이블정의서_반다이남코_260506.xlsx"

if (-not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$GREEN = 11396999  # 헤더 배경색
$today = Get-Date -Format "yyyy-MM-dd"

# ------------------------------------------------------------
# 2. MD 파일 파싱 함수
# ------------------------------------------------------------
function Parse-TableMD {
  param([string]$FilePath)

  $content = Get-Content -LiteralPath $FilePath -Encoding UTF8
  $result = [ordered]@{
    PhysicalName = ""
    LogicalName  = ""
    Overview     = ""
    Columns      = New-Object System.Collections.ArrayList
    Indexes      = New-Object System.Collections.ArrayList
    FKs          = New-Object System.Collections.ArrayList
    RefBy        = New-Object System.Collections.ArrayList
    Sequences    = New-Object System.Collections.ArrayList
    ParseErrors  = New-Object System.Collections.ArrayList
  }

  if ($content.Count -eq 0) {
    [void]$result.ParseErrors.Add("empty file")
    return $result
  }

  # 첫 H1 라인 찾기 (선두 빈 줄 허용): # mdm_prod (MDM_품목)
  $firstLine = ""
  foreach ($l in $content) {
    if ($l -match '^#\s') { $firstLine = $l; break }
    if ($l.Trim() -ne "") { break }  # 빈 줄/공백은 건너뛰지만 첫 비공백 라인이 H1이 아니면 종료
  }
  if ($firstLine -match '^#\s+(\S+)\s*\((.+)\)\s*$') {
    $result.PhysicalName = $Matches[1].Trim()
    $result.LogicalName  = $Matches[2].Trim()
  } elseif ($firstLine -match '^#\s+(\S+)') {
    $result.PhysicalName = $Matches[1].Trim()
    $result.LogicalName  = $result.PhysicalName
  } else {
    [void]$result.ParseErrors.Add("first line not matched")
    # fallback: 파일명에서 추출
    $result.PhysicalName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $result.LogicalName  = $result.PhysicalName
  }

  $section = ""
  $overviewLines = New-Object System.Collections.ArrayList
  $inCodeBlock = $false

  foreach ($line in $content) {
    # 코드 블록 토글
    if ($line -match '^\s*```') {
      $inCodeBlock = -not $inCodeBlock
      continue
    }
    if ($inCodeBlock) { continue }

    # 블록쿼트는 무시 (코드값 설명표 등)
    if ($line -match '^\s*>') { continue }

    # 섹션 헤더 감지 (## 로 시작, 번호 무관, 키워드로 판단)
    if ($line -match '^##\s+(.+)$') {
      $title = $Matches[1].Trim()
      if     ($title -match '개요')              { $section = "overview" }
      elseif ($title -match '테이블\s*정의')     { $section = "columns" }
      elseif ($title -match '인덱스')            { $section = "indexes" }
      elseif ($title -match '시퀀스')            { $section = "sequences" }
      elseif ($title -match 'FK\s*관계')         { $section = "fks" }
      elseif ($title -match '참조됨')            { $section = "refby" }
      elseif ($title -match '참조하는\s*테이블') { $section = "refby" }
      else                                        { $section = "other" }
      continue
    }
    # 서브섹션 (### 등)도 다음 ## 까지 현재 섹션에 머무름
    if ($line -match '^###') { continue }
    if ($line -match '^#[^#]') { continue }  # h1은 첫줄 처리

    # 마크다운 표 파싱
    if ($line -match '^\s*\|') {
      $trim = $line.Trim()
      # 구분선
      if ($trim -match '^\|[-\s:|]+\|?$') { continue }

      # 셀 분리: 양쪽 끝 | 제거 후 split
      $inner = $trim
      if ($inner.StartsWith("|")) { $inner = $inner.Substring(1) }
      if ($inner.EndsWith("|"))   { $inner = $inner.Substring(0, $inner.Length - 1) }
      $cells = $inner -split '\|' | ForEach-Object { $_.Trim() }

      if ($section -eq "columns" -and $cells.Count -ge 6) {
        # 헤더행 건너뜀
        if ($cells[0] -eq "PK/FK" -or $cells[1] -eq "컬럼명") { continue }
        [void]$result.Columns.Add([ordered]@{
          PKFK     = $cells[0]
          Physical = $cells[1]
          DataType = $cells[2]
          Nullable = $cells[3]
          Default  = $cells[4]
          Logical  = $cells[5]
        })
      }
      elseif ($section -eq "indexes" -and $cells.Count -ge 2) {
        if ($cells[0] -match '^인덱스') { continue }
        [void]$result.Indexes.Add([ordered]@{
          Name    = $cells[0]
          Columns = if ($cells.Count -gt 1) { $cells[1] } else { "" }
          Unique  = if ($cells.Count -gt 2) { $cells[2] } else { "" }
          PK      = if ($cells.Count -gt 3) { $cells[3] } else { "" }
        })
      }
      elseif ($section -eq "sequences" -and $cells.Count -ge 2) {
        if ($cells[0] -eq "컬럼" -or $cells[1] -match '^시퀀스') { continue }
        [void]$result.Sequences.Add([ordered]@{
          Column   = $cells[0]
          Sequence = $cells[1]
        })
      }
      elseif ($section -eq "fks" -and $cells.Count -ge 3) {
        if ($cells[0] -match '^FK\s*컬럼') { continue }
        [void]$result.FKs.Add([ordered]@{
          Column   = $cells[0]
          RefTable = $cells[1]
          RefCol   = $cells[2]
          Const    = if ($cells.Count -gt 3) { $cells[3] } else { "" }
        })
      }
      elseif ($section -eq "refby" -and $cells.Count -ge 2) {
        if ($cells[0] -match '^참조\s*테이블') { continue }
        [void]$result.RefBy.Add([ordered]@{
          Table  = $cells[0]
          Column = if ($cells.Count -gt 1) { $cells[1] } else { "" }
        })
      }
      continue
    }

    if ($section -eq "overview" -and $line.Trim() -ne "") {
      [void]$overviewLines.Add($line.Trim())
    }
  }

  $ovStr = ($overviewLines -join " ")
  if ($ovStr.Length -gt 500) { $ovStr = $ovStr.Substring(0, 500) }
  $result.Overview = $ovStr
  return $result
}

# ------------------------------------------------------------
# 3. MD 파일 전체 파싱
# ------------------------------------------------------------
Write-Host "[1/4] MD 파일 파싱 시작..."

$allFiles = Get-ChildItem -LiteralPath $tableDir -Filter "*.md"
Write-Host "  - 발견된 MD 파일: $($allFiles.Count)개"

$mdFiles = $allFiles | Sort-Object @{Expression = {
  $n = $_.BaseName
  switch -Wildcard ($n) {
    "mdm_*" { "1_$n"; break }
    "sif_*" { "2_$n"; break }
    "sm_*"  { "3_$n"; break }
    "wes_*" { "4_$n"; break }
    "wms_*" { "5_$n"; break }
    default { "9_$n" }
  }
}}

$tables     = New-Object System.Collections.ArrayList
$parseErrors = New-Object System.Collections.ArrayList

foreach ($f in $mdFiles) {
  try {
    $t = Parse-TableMD -FilePath $f.FullName
    [void]$tables.Add($t)
    if ($t.ParseErrors.Count -gt 0) {
      [void]$parseErrors.Add(@{File = $f.Name; Errors = ($t.ParseErrors -join "; ")})
    }
  } catch {
    [void]$parseErrors.Add(@{File = $f.Name; Errors = $_.Exception.Message})
    # 빈 컨테이너로 추가
    [void]$tables.Add([ordered]@{
      PhysicalName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
      LogicalName  = ""
      Overview     = "(파싱 실패: $($_.Exception.Message))"
      Columns      = New-Object System.Collections.ArrayList
      Indexes      = New-Object System.Collections.ArrayList
      FKs          = New-Object System.Collections.ArrayList
      RefBy        = New-Object System.Collections.ArrayList
      Sequences    = New-Object System.Collections.ArrayList
      ParseErrors  = New-Object System.Collections.ArrayList
    })
  }
}

Write-Host "  - 파싱 완료: $($tables.Count)개"
if ($parseErrors.Count -gt 0) {
  Write-Host "  - 파싱 경고: $($parseErrors.Count)개" -ForegroundColor Yellow
}

# ------------------------------------------------------------
# 4. Excel 파일 복사 및 열기
# ------------------------------------------------------------
Write-Host "[2/4] 템플릿 복사 및 Excel 열기..."

Copy-Item -LiteralPath $templatePath -Destination $outputPath -Force

$excel = $null
$wb    = $null
try {
  $excel = New-Object -ComObject Excel.Application
  $excel.Visible       = $false
  $excel.DisplayAlerts = $false

  $wb = $excel.Workbooks.Open($outputPath)
  # 성능 최적화: 워크북 오픈 후 설정
  try { $excel.ScreenUpdating = $false } catch { }
  try { $excel.Calculation = -4135 } catch { }  # xlCalculationManual

  # ------------------------------------------------------------
  # 5. 기존 시트 정리 (Table List만 유지)
  # ------------------------------------------------------------
  Write-Host "[3/4] 기존 시트 정리..."

  # Table List 시트 인스턴스 확보
  $tlSheet = $null
  foreach ($s in $wb.Sheets) {
    if ($s.Name -eq "Table List") { $tlSheet = $s; break }
  }
  if ($null -eq $tlSheet) {
    throw "Table List 시트를 찾을 수 없습니다."
  }

  # Table List 외 시트 모두 삭제 (역순으로)
  $deleteList = @()
  for ($i = $wb.Sheets.Count; $i -ge 1; $i--) {
    $s = $wb.Sheets.Item($i)
    if ($s.Name -ne "Table List") { $deleteList += $s }
  }
  foreach ($s in $deleteList) { $s.Delete() | Out-Null }
  Write-Host "  - 기존 시트 삭제 완료 (Table List만 유지)"

  # Table List 데이터 영역 정리 - 병합 해제 + Clear
  $usedLast = [int]$tlSheet.UsedRange.Rows.Count
  if ($usedLast -lt 3) { $usedLast = 3 }
  # 충분히 넓은 영역까지 정리 (테이블 수 + 여유)
  $clearLast = [Math]::Max($usedLast, $tables.Count + 100)
  $clearRange = $tlSheet.Range(
    $tlSheet.Cells.Item(3, 1),
    $tlSheet.Cells.Item($clearLast, 26)  # A:Z
  )
  try { $clearRange.UnMerge() | Out-Null } catch { }
  $clearRange.Clear() | Out-Null

  # ------------------------------------------------------------
  # 6. Table List 작성
  # ------------------------------------------------------------
  Write-Host "  - Table List 갱신..."

  for ($i = 0; $i -lt $tables.Count; $i++) {
    $t   = $tables[$i]
    $row = $i + 3
    try {
      $tlSheet.Cells.Item($row, 1).Value2 = [int]($i + 1)
      $tlSheet.Cells.Item($row, 2).Value2 = [string]$t.LogicalName
      $tlSheet.Cells.Item($row, 3).Value2 = [string]("[public].[" + $t.PhysicalName + "]")
      $tlSheet.Cells.Item($row, 4).Value2 = [string]$t.Overview
    } catch {
      Write-Host "  WARN row=$row physical=$($t.PhysicalName) err=$($_.Exception.Message)"
      throw
    }
  }

  # ------------------------------------------------------------
  # 7. 테이블별 시트 생성
  # ------------------------------------------------------------
  Write-Host "[4/4] 테이블별 시트 생성..."

  $usedNames = @{ "Table List" = $true }

  function Get-UniqueSheetName {
    param([string]$Base)
    $clean = $Base -replace '[:\\/?*\[\]]', '_'
    if ($clean.Length -gt 31) { $clean = $clean.Substring(0, 31) }
    if (-not $usedNames.ContainsKey($clean)) {
      $usedNames[$clean] = $true
      return $clean
    }
    # 중복 처리
    for ($n = 1; $n -le 99; $n++) {
      $suffix = "_$n"
      $maxLen = 31 - $suffix.Length
      $base2 = if ($clean.Length -gt $maxLen) { $clean.Substring(0, $maxLen) } else { $clean }
      $cand = "$base2$suffix"
      if (-not $usedNames.ContainsKey($cand)) {
        $usedNames[$cand] = $true
        return $cand
      }
    }
    throw "Cannot generate unique sheet name for $Base"
  }

  $progressEvery = 5
  $createdCount = 0

  foreach ($t in $tables) {
    # 시트 추가 (마지막 위치에)
    $ws = $wb.Sheets.Add([System.Reflection.Missing]::Value, $wb.Sheets.Item($wb.Sheets.Count))
    $sheetName = Get-UniqueSheetName -Base $t.PhysicalName
    $ws.Name = $sheetName

    # ----- Table info 섹션 -----
    $ws.Cells.Item(1, 1).Value2 = "Table info"
    $ws.Cells.Item(1, 1).Font.Bold = $true

    # 레이블/값 배치 (실제 템플릿: 레이블 B열, 값 C열, 우측 레이블 E열, 값 F열)
    $infoRows = @(
      @(2, "System Name",         "CLOUD_WMS",        "Author",      "이택"),
      @(3, "Sub-system Name",     "",                  "Created On",  $today),
      @(4, "Schema Name",         "public",            "Modified On", $today),
      @(5, "Logical Table Name",  $t.LogicalName,      "RDBMS",       "PostgreSQL"),
      @(6, "Physical Table Name", $t.PhysicalName,     "",            "")
    )
    foreach ($r in $infoRows) {
      $row = [int]$r[0]
      $ws.Cells.Item($row, 2).Value2 = [string]$r[1]
      $ws.Cells.Item($row, 3).Value2 = [string]$r[2]
      if ($r[3] -ne "") {
        $ws.Cells.Item($row, 5).Value2 = [string]$r[3]
        $ws.Cells.Item($row, 6).Value2 = [string]$r[4]
      }
      # 레이블 셀 배경색 (B열, E열)
      $ws.Cells.Item($row, 2).Interior.Color = $GREEN
      if ($r[3] -ne "") {
        $ws.Cells.Item($row, 5).Interior.Color = $GREEN
      }
    }

    # Remark (R7) - 전체 폭 사용
    $ws.Cells.Item(7, 2).Value2 = "Remark"
    $ws.Cells.Item(7, 2).Interior.Color = $GREEN
    $ws.Cells.Item(7, 3).Value2 = [string]$t.Overview
    # 병합 (C7:G7)
    $remarkRange = $ws.Range($ws.Cells.Item(7, 3), $ws.Cells.Item(7, 7))
    $remarkRange.Merge() | Out-Null

    # ----- Column info 섹션 -----
    $ws.Cells.Item(12, 1).Value2 = "Column info"
    $ws.Cells.Item(12, 1).Font.Bold = $true

    # 헤더 (R13)
    $colHeaders = @("No", "Logical Name", "Physical Name", "Data Type", "Not Null", "Default", "Remark")
    for ($i = 0; $i -lt $colHeaders.Count; $i++) {
      $ws.Cells.Item(13, $i + 1).Value2 = $colHeaders[$i]
    }
    $hdrRange = $ws.Range($ws.Cells.Item(13, 1), $ws.Cells.Item(13, 7))
    $hdrRange.Interior.Color = $GREEN
    $hdrRange.Font.Bold = $true

    # 컬럼 데이터 - 셀별로 직접 쓰기 (안정성 우선)
    $dataRow = 14
    for ($ci = 0; $ci -lt $t.Columns.Count; $ci++) {
      $col = $t.Columns[$ci]
      $notNull = if ($col.Nullable -eq "N") { "Y" } else { "N" }
      $remark  = if ($col.PKFK -ne "") { [string]$col.PKFK } else { "" }
      $r = $dataRow + $ci
      $ws.Cells.Item($r, 1).Value2 = [int]($ci + 1)
      $ws.Cells.Item($r, 2).Value2 = [string]$col.Logical
      $ws.Cells.Item($r, 3).Value2 = [string]$col.Physical
      $ws.Cells.Item($r, 4).Value2 = [string]$col.DataType
      $ws.Cells.Item($r, 5).Value2 = [string]$notNull
      $ws.Cells.Item($r, 6).Value2 = [string]$col.Default
      $ws.Cells.Item($r, 7).Value2 = [string]$remark
    }
    $dataRow += $t.Columns.Count

    $dataRow += 2  # 빈 행 2개

    # ----- Index info -----
    if ($t.Indexes.Count -gt 0) {
      $ws.Cells.Item($dataRow, 1).Value2 = "Index info"
      $ws.Cells.Item($dataRow, 1).Font.Bold = $true
      $dataRow++

      $idxHdr = @("No", "Index Name", "Column List", "", "Unique", "PK", "")
      for ($i = 0; $i -lt $idxHdr.Count; $i++) {
        $ws.Cells.Item($dataRow, $i + 1).Value2 = $idxHdr[$i]
      }
      $r = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, 7))
      $r.Interior.Color = $GREEN
      $r.Font.Bold = $true
      $dataRow++

      $idxNo = 1
      foreach ($idx in $t.Indexes) {
        $ws.Cells.Item($dataRow, 1).Value2 = [int]$idxNo
        $ws.Cells.Item($dataRow, 2).Value2 = [string]$idx.Name
        $ws.Cells.Item($dataRow, 3).Value2 = [string]$idx.Columns
        $ws.Cells.Item($dataRow, 5).Value2 = [string]$idx.Unique
        $ws.Cells.Item($dataRow, 6).Value2 = [string]$idx.PK
        $idxNo++
        $dataRow++
      }
      $dataRow += 2
    }

    # ----- Sequence info -----
    if ($t.Sequences.Count -gt 0) {
      $ws.Cells.Item($dataRow, 1).Value2 = "Sequence info"
      $ws.Cells.Item($dataRow, 1).Font.Bold = $true
      $dataRow++

      $seqHdr = @("No", "Column", "Sequence Name", "", "", "", "")
      for ($i = 0; $i -lt $seqHdr.Count; $i++) {
        $ws.Cells.Item($dataRow, $i + 1).Value2 = $seqHdr[$i]
      }
      $r = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, 7))
      $r.Interior.Color = $GREEN
      $r.Font.Bold = $true
      $dataRow++

      $sNo = 1
      foreach ($sq in $t.Sequences) {
        $ws.Cells.Item($dataRow, 1).Value2 = [int]$sNo
        $ws.Cells.Item($dataRow, 2).Value2 = [string]$sq.Column
        $ws.Cells.Item($dataRow, 3).Value2 = [string]$sq.Sequence
        $sNo++
        $dataRow++
      }
      $dataRow += 2
    }

    # ----- FK info -----
    if ($t.FKs.Count -gt 0) {
      $ws.Cells.Item($dataRow, 1).Value2 = "FK info"
      $ws.Cells.Item($dataRow, 1).Font.Bold = $true
      $dataRow++

      $fkHdr = @("No", "FK Column", "Ref Table", "", "Ref Column", "", "Constraint")
      for ($i = 0; $i -lt $fkHdr.Count; $i++) {
        $ws.Cells.Item($dataRow, $i + 1).Value2 = $fkHdr[$i]
      }
      $r = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, 7))
      $r.Interior.Color = $GREEN
      $r.Font.Bold = $true
      $dataRow++

      $fkNo = 1
      foreach ($fk in $t.FKs) {
        $ws.Cells.Item($dataRow, 1).Value2 = [int]$fkNo
        $ws.Cells.Item($dataRow, 2).Value2 = [string]$fk.Column
        $ws.Cells.Item($dataRow, 3).Value2 = [string]$fk.RefTable
        $ws.Cells.Item($dataRow, 5).Value2 = [string]$fk.RefCol
        $ws.Cells.Item($dataRow, 7).Value2 = [string]$fk.Const
        $fkNo++
        $dataRow++
      }
      $dataRow += 2
    }

    # ----- FK info (PK Side) - 참조됨 -----
    if ($t.RefBy.Count -gt 0) {
      $ws.Cells.Item($dataRow, 1).Value2 = "FK info (PK Side)"
      $ws.Cells.Item($dataRow, 1).Font.Bold = $true
      $dataRow++

      $refHdr = @("No", "Ref Table", "Ref Column", "", "", "", "")
      for ($i = 0; $i -lt $refHdr.Count; $i++) {
        $ws.Cells.Item($dataRow, $i + 1).Value2 = $refHdr[$i]
      }
      $r = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, 7))
      $r.Interior.Color = $GREEN
      $r.Font.Bold = $true
      $dataRow++

      $refNo = 1
      foreach ($ref in $t.RefBy) {
        $ws.Cells.Item($dataRow, 1).Value2 = [int]$refNo
        $ws.Cells.Item($dataRow, 2).Value2 = [string]$ref.Table
        $ws.Cells.Item($dataRow, 3).Value2 = [string]$ref.Column
        $refNo++
        $dataRow++
      }
    }

    # 컬럼 너비 자동 조정 (대략적으로)
    $ws.Columns.Item(1).ColumnWidth = 5    # No
    $ws.Columns.Item(2).ColumnWidth = 28   # Logical
    $ws.Columns.Item(3).ColumnWidth = 30   # Physical
    $ws.Columns.Item(4).ColumnWidth = 20   # Data Type
    $ws.Columns.Item(5).ColumnWidth = 10   # Not Null
    $ws.Columns.Item(6).ColumnWidth = 22   # Default
    $ws.Columns.Item(7).ColumnWidth = 32   # Remark

    $createdCount++
    if ($createdCount % $progressEvery -eq 0) {
      Write-Host "  - 진행: $createdCount / $($tables.Count)"
    }
  }

  Write-Host "  - 시트 생성 완료: $createdCount개"

  # ------------------------------------------------------------
  # 8. 저장
  # ------------------------------------------------------------
  Write-Host "저장 중..."
  try { $excel.Calculation = -4105 } catch { }  # xlCalculationAutomatic
  $wb.Save()
  Write-Host "저장 완료: $outputPath"

}
catch {
  Write-Host "오류 발생: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host $_.ScriptStackTrace -ForegroundColor Red
  throw
}
finally {
  if ($null -ne $wb) {
    try { $wb.Close($false) | Out-Null } catch {}
  }
  if ($null -ne $excel) {
    try { $excel.Quit() } catch {}
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
  }
  [GC]::Collect()
  [GC]::WaitForPendingFinalizers()
}

# ------------------------------------------------------------
# 9. 결과 요약
# ------------------------------------------------------------
Write-Host ""
Write-Host "===== 결과 요약 ====="
$fi = Get-Item -LiteralPath $outputPath
Write-Host "출력 파일 : $($fi.FullName)"
Write-Host "파일 크기 : $([math]::Round($fi.Length / 1KB, 1)) KB"
Write-Host "총 시트 수: $($tables.Count + 1) (Table List 포함)"
Write-Host "테이블 수 : $($tables.Count)"

# 그룹별 통계
$grp = @{ "mdm" = 0; "sif" = 0; "sm" = 0; "wes" = 0; "wms" = 0; "etc" = 0 }
foreach ($t in $tables) {
  $n = $t.PhysicalName
  if     ($n -like "mdm_*") { $grp["mdm"]++ }
  elseif ($n -like "sif_*") { $grp["sif"]++ }
  elseif ($n -like "sm_*")  { $grp["sm"]++ }
  elseif ($n -like "wes_*") { $grp["wes"]++ }
  elseif ($n -like "wms_*") { $grp["wms"]++ }
  else                       { $grp["etc"]++ }
}
Write-Host ""
Write-Host "그룹별 시트 수:"
foreach ($k in @("mdm","sif","sm","wes","wms","etc")) {
  Write-Host ("  - {0,-4} : {1}개" -f $k, $grp[$k])
}

if ($parseErrors.Count -gt 0) {
  Write-Host ""
  Write-Host "파싱 경고 ($($parseErrors.Count)건):" -ForegroundColor Yellow
  foreach ($pe in $parseErrors) {
    Write-Host ("  - {0}: {1}" -f $pe.File, $pe.Errors)
  }
} else {
  Write-Host ""
  Write-Host "파싱 오류 없음"
}
