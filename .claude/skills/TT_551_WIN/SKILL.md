---
name: TT_551_WIN
description: 【DB 이관 스크립트 실행 (Windows 전용)】 Windows 네이티브 PowerShell 환경에서 `input/TT.551/` 폴더의 PowerShell 마이그레이션 스크립트를 인수(V0~V10 또는 all)에 따라 실행합니다. `/TT_551_WIN` 또는 `/TT_551_WIN V3` 형식으로 실행합니다. 사용자가 "TT_551_WIN 실행해줘", "윈도우에서 DB 이관 스크립트 실행해줘", "이관 스크립트 실행해줘 V3", "migrate V5 윈도우에서 실행", "DB 이관 실행", "V2 이관해줘", "공통코드 이관", "사업장 이관 실행", "전체 이관 실행", "migrate all 실행" 라고 말하면 반드시 이 스킬을 사용합니다.
allowed-tools: Bash
---

# DB 이관 스크립트 실행 (Windows 전용) [TT_551_WIN]

`input/TT.551/` 폴더에 있는 PowerShell 마이그레이션 스크립트를 인수에 따라 실행한다.

> **실행 환경:** Windows 네이티브 PowerShell 5.1 이상. WSL·Git Bash 불필요.
> **Bash 도구 실행 패턴:**
> ```
> powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\{스크립트명}"
> ```

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
2. Bash 도구로 해당 스크립트를 실행한다.
3. 실행 결과(STEP 출력 등)를 그대로 사용자에게 보여준다.
4. 오류 발생 시 exitcode와 오류 메시지를 출력하고 중단한다.
5. 성공 시 "이관 완료. test/dev 건수를 확인하세요." 를 안내한다.

---

## 실행 예시

### 전체 실행 (인수 없음 또는 all)
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_all.ps1"
```

### V3 (사업장) 만 실행
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_V3_biz.ps1"
```

### V10 (함수/프로시저) 만 실행
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_V10_functions.ps1"
```
