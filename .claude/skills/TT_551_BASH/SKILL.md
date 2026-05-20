---
name: TT_551_BASH
description: 【DB 이관 스크립트 실행 (WSL/Linux, powershell.exe 경유)】 WSL·Linux 환경에서 `input/TT.551/` 폴더의 PowerShell 마이그레이션 스크립트를 `powershell.exe` 경유로 실행합니다. `/TT_551_BASH` 또는 `/TT_551_BASH V3` 형식으로 실행합니다. WSL에서 DB 이관 스크립트 실행, 공통코드/사업장/센터/창고/메뉴/사용자 이관, 전체 이관 실행, 함수·프로시저 재생성 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "TT_551_BASH 실행해줘", "WSL에서 DB 이관 스크립트 실행해줘", "WSL에서 이관 실행 V3", "WSL에서 migrate V5 실행", "WSL 이관해줘" 라고 말해도 이 스킬을 사용합니다. Windows 네이티브 환경에서는 TT_551 스킬을 사용합니다.
allowed-tools: Bash
---

# DB 이관 스크립트 실행 (WSL/Linux) [TT_551_BASH]

WSL(Windows Subsystem for Linux) 환경에서 `input/TT.551/` 폴더에 있는 PowerShell 마이그레이션 스크립트를 `powershell.exe`(Windows 호스트의 PowerShell)를 경유하여 실행한다.

> **실행 환경:** WSL2 · Linux. `powershell.exe` 가 WSL PATH에서 접근 가능해야 한다.
> (일반적으로 WSL2 에서는 `powershell.exe` 또는 `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` 로 호출 가능)

## 경로 동적 감지

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
# WSL에서 Windows 경로로 변환: /mnt/c/foo/bar -> C:\foo\bar
WIN_DOC_ROOT=$(wslpath -w "$DOC_ROOT")
SCRIPT_DIR="${WIN_DOC_ROOT}\\input\\TT.551"
```

---

## 스크립트 매핑표

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

## 실행 절차

1. `$ARGUMENTS` 를 확인하여 위 표에서 실행할 스크립트를 결정한다.
   - 인수가 없거나 `all` 이면 `migrate_all.ps1`
   - `V0` ~ `V10` 이면 해당 스크립트
   - 표에 없는 값이면 "유효한 인수는 V0~V10 또는 all 입니다." 를 안내하고 종료
2. Bash 도구로 `powershell.exe` 를 통해 해당 스크립트를 실행한다.
3. 실행 결과(STEP 출력 등)를 그대로 사용자에게 보여준다.
4. 오류 발생 시 exitcode와 오류 메시지를 출력하고 중단한다.
5. 성공 시 "이관 완료. test/dev 건수를 확인하세요." 를 안내한다.

---

## 실행 예시

WSL 환경에서 `powershell.exe`를 통해 Windows 경로의 `.ps1` 스크립트를 실행한다.

### 경로 감지 공통 변수

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WIN_DOC_ROOT=$(wslpath -w "$DOC_ROOT")
SCRIPT_DIR="${WIN_DOC_ROOT}\\input\\TT.551"
```

### 전체 실행 (인수 없음 또는 all)

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_all.ps1"
```

### V3 (사업장) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V3_biz.ps1"
```

### V10 (함수/프로시저) 만 실행

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${SCRIPT_DIR}\\migrate_V10_functions.ps1"
```

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 검증 (V0~V10 / all / 빈 값)
- [ ] `wslpath -w` 로 WSL 경로를 Windows 경로로 변환
- [ ] 매핑표에서 실행할 `.ps1` 결정
- [ ] `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` 호출
- [ ] STEP 출력 사용자에게 그대로 표시
- [ ] exitcode 확인 (0 = 성공, ≠0 = 실패)
- [ ] 성공 시 `"이관 완료. test/dev 건수를 확인하세요."` 안내

---

## 주의사항

- **WSL2 전용**: WSL2 에서는 `powershell.exe` 가 Windows 호스트의 PowerShell을 가리키므로 정상 작동한다. WSL1 에서는 동작하지 않을 수 있다.
- **`wslpath` 필수**: WSL 경로(`/mnt/c/...`)를 Windows 경로(`C:\...`)로 변환해야 `powershell.exe`가 파일을 찾을 수 있다.
- **`powershell.exe` 위치**: WSL PATH에 없으면 `/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe` 로 절대 경로를 지정한다.
- **PowerShell 실행 정책**: 호출 시 항상 `-ExecutionPolicy Bypass` 를 붙여 정책 영향을 받지 않게 한다.
- **순서 보장**: `all` 실행 시 V0 → V1 → ... → V10 순으로 수행. 중간 실패 시 그 지점에서 중단되며 이후 단계는 수행되지 않는다.
- **재실행 안전성**: 각 `.ps1` 은 멱등하게 작성되어 있다고 가정한다(테이블 DELETE → COPY/INSERT 방식). V0 재실행은 DB DROP 을 동반하므로 **운영 환경에서는 호출 금지**.
- **순수 Linux/macOS**: `powershell.exe` 자체가 없는 순수 Linux/macOS 환경에서는 이 스킬을 사용할 수 없다. 그 경우 PowerShell Core(`pwsh`)를 설치하거나, `.ps1` 스크립트를 Bash로 직접 재구현해야 한다.
