---
name: TT_551
description: input/TT.551/ 폴더의 PowerShell 마이그레이션 스크립트 실행 (V0~V10 또는 all). /TT_551 [V번호|all]
when_to_use: "DB 이관 스크립트 실행해줘", "이관 실행 V3", "전체 이관 실행", "migrate all 실행" 요청 시 사용.
argument-hint: "[V번호|all]"
disable-model-invocation: true
allowed-tools: Bash, PowerShell
---

# DB 이관 스크립트 실행 (Windows/WSL/Linux 통합) [TT_551]

`input/TT.551/` 폴더에 있는 PowerShell 마이그레이션 스크립트를 인수에 따라 실행한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1+ 또는 WSL2 (Windows 호스트의 `powershell.exe` 가 PATH에서 접근 가능해야 함).
> 순수 Linux/macOS 환경(`powershell.exe` 자체가 없는 경우) 에서는 PowerShell Core(`pwsh`)를 설치하거나 `.ps1` 스크립트를 Bash로 재구현해야 한다.

---

## OS 분기 — 가장 먼저 실행

```
- Windows 네이티브 (PowerShell): $env:OS == 'Windows_NT' && uname 명령 없음
  → [Windows 섹션] — Windows 경로 직접 사용, `powershell.exe` 호출.
- WSL / Linux + powershell.exe (Bash): uname 존재 (Linux) && wslpath 또는 powershell.exe 사용 가능
  → [Bash 섹션] — `wslpath -w` 로 경로 변환 후 `powershell.exe` 호출.
```

> 두 섹션 모두 동일한 `.ps1` 스크립트를 실행한다. 차이는 경로 변환(WSL의 `/mnt/c/...` → Windows `C:\...`) 여부 뿐이다.

---

## 스크립트 매핑표 (공통)

| 인수 | 실행 스크립트 | 대상 |
|---|---|---|
| 없음 또는 `all` | `migrate_all.ps1` | 전체 실행 |
| `V0` | `migrate_V0_create_db.ps1` | TO DB 데이터베이스 생성 |
| `V1` | `migrate_V1_schema.ps1` | DDL 적용 |
| `V2` | `migrate_V2_code.ps1` | 공통코드 |
| `V3` | `migrate_V3_biz.ps1` | 사업장 |
| `V4` | `migrate_V4_center.ps1` | 센터 |
| `V5` | `migrate_V5_warehouse.ps1` | 창고 |
| `V6` | `migrate_V6_location.ps1` | 위치(로케이션) |
| `V7` | `migrate_V7_config.ps1` | 시스템파라미터 |
| `V8` | `migrate_V8_menu.ps1` | 메뉴 |
| `V9` | `migrate_V9_user.ps1` | 사용자 |
| `V10` | `migrate_V10_functions.ps1` | 함수/프로시저 |

---

## 실행 절차 (공통)

1. `$ARGUMENTS` 를 확인하여 위 표에서 실행할 스크립트를 결정한다.
   - 인수가 없거나 `all` 이면 `migrate_all.ps1`
   - `V0` ~ `V10` 이면 해당 스크립트
   - 표에 없는 값이면 "유효한 인수는 V0~V10 또는 all 입니다." 를 안내하고 종료
2. 해당 OS 섹션의 블록으로 스크립트를 실행한다.
3. 실행 결과(STEP 출력 등)를 그대로 사용자에게 보여준다.
4. 오류 발생 시 exitcode와 오류 메시지를 출력하고 중단한다.
5. 성공 시 "이관 완료. test/dev 건수를 확인하세요." 를 안내한다.

---

# === Windows 섹션 (PowerShell) ===

### W-0) 경로 동적 감지

```bash
DOCROOT=$(powershell.exe -NoProfile -Command "(git rev-parse --show-toplevel) -replace '/', '\'")
SCRIPT_DIR="${DOCROOT}\\input\\TT.551"
```

또는 PowerShell 도구로:

```powershell
$DocRoot = (git rev-parse --show-toplevel) -replace '/', '\'
$ScriptDir = Join-Path $DocRoot "input\TT.551"
```

### W-1) 전체 실행 (인수 없음 또는 all)

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_all.ps1"
```

### W-2) V3 (사업장) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V3_biz.ps1"
```

### W-3) V10 (함수/프로시저) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V10_functions.ps1"
```

---

# === Bash 섹션 (WSL/Linux + powershell.exe) ===

### B-0) 경로 감지 (WSL 경로 → Windows 경로 변환)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WIN_DOC_ROOT=$(wslpath -w "$DOC_ROOT")
SCRIPT_DIR="${WIN_DOC_ROOT}\\input\\TT.551"
```

### B-1) 전체 실행 (인수 없음 또는 all)

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_all.ps1"
```

### B-2) V3 (사업장) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V3_biz.ps1"
```

### B-3) V10 (함수/프로시저) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V10_functions.ps1"
```

> `powershell.exe` 가 WSL PATH에 없으면 절대경로 사용:
> `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

---

## 완료 체크리스트 (공통)

- [ ] `$ARGUMENTS` 검증 (V0~V10 / all / 빈 값)
- [ ] 매핑표에서 실행할 `.ps1` 결정
- [ ] (Bash 섹션의 경우) `wslpath -w` 로 WSL 경로를 Windows 경로로 변환
- [ ] `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` 호출
- [ ] STEP 출력 사용자에게 그대로 표시
- [ ] exitcode 확인 (0 = 성공, ≠0 = 실패)
- [ ] 성공 시 `"이관 완료. test/dev 건수를 확인하세요."` 안내

---

## 주의사항 (공통)

- **PowerShell 실행 정책**: 호출 시 항상 `-ExecutionPolicy Bypass` 를 붙여 정책 영향을 받지 않게 한다.
- **인터랙티브 입력 금지**: `-NoProfile` 로 프로필 로드 차단, 스크립트가 사용자 입력을 요구하지 않도록 작성되어 있어야 한다.
- **순서 보장**: `all` 실행 시 V0 → V1 → ... → V10 순으로 수행. 중간 실패 시 그 지점에서 중단되며 이후 단계는 수행되지 않는다.
- **재실행 안전성**: 각 `.ps1` 은 멱등하게 작성되어 있다고 가정한다(테이블 DELETE → COPY/INSERT 방식). V0 재실행은 DB DROP 을 동반하므로 **운영 환경에서는 호출 금지**.

### Windows 특화

- PowerShell 5.1+ 가 기본. 별도 변환 없이 Windows 경로 직접 사용.

### WSL/Linux 특화

- **WSL2 권장**: WSL2 에서는 `powershell.exe` 가 Windows 호스트의 PowerShell을 가리키므로 정상 작동. WSL1 에서는 동작하지 않을 수 있다.
- **`wslpath` 필수**: WSL 경로(`/mnt/c/...`)를 Windows 경로(`C:\...`)로 변환해야 `powershell.exe`가 파일을 찾을 수 있다.
- **순수 Linux/macOS 미지원**: `powershell.exe` 자체가 없는 환경에서는 PowerShell Core(`pwsh`) 설치 또는 `.ps1` 의 Bash 재구현 필요.
