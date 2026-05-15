---
name: TT_551
description: 【DB 이관 스크립트 실행 (Windows 전용, PowerShell)】 Windows 네이티브 PowerShell 환경에서 `C:\zinide\workspace\cloud-wms-doc\input\TT.551\` 폴더의 PowerShell 마이그레이션 스크립트(`migrate_V0_create_db.ps1` ~ `migrate_V10_functions.ps1` / `migrate_all.ps1`)를 인수(V0~V10 또는 all)에 따라 실행하여 test DB(`wms-cloud-test`) → dev DB(`wms-cloud-dev`) 의 DB 이관을 수행한다. `/TT_551` 또는 `/TT_551 V3` 형식으로 실행하며 인수가 없으면 `all` 로 간주해 V0~V10 전체를 순서대로 실행한다. 각 PowerShell 스크립트는 STEP 1~3 출력을 콘솔에 남기며, 실패 시 exitcode와 오류 메시지를 그대로 사용자에게 보여주고 중단한다. DB 이관 스크립트 실행, 공통코드/사업장/센터/창고/메뉴/사용자 이관, 전체 이관 실행, 함수·프로시저 재생성 요청 시 반드시 이 스킬을 사용한다. 사용자가 "TT_551 실행해줘", "DB 이관 스크립트 실행해줘", "이관 실행 V3", "migrate V5 실행", "V2 이관해줘", "공통코드 이관", "사업장 이관 실행", "전체 이관 실행", "migrate all 실행", "이관 스크립트 실행해줘" 라고 말해도 이 스킬을 사용한다. PowerShell `.ps1` 기반이므로 WSL2/Linux/macOS에서는 동작하지 않는다.
allowed-tools: Bash
---

# DB 이관 스크립트 실행 (Windows 전용, PowerShell) [TT_551]

test DB(`wms-cloud-test`) → dev DB(`wms-cloud-dev`) 의 데이터 이관을 PowerShell + `psql.exe` 기반 `.ps1` 스크립트로 수행한다.

> **실행 환경**: Windows 네이티브 PowerShell 5.1 이상 또는 PowerShell Core(pwsh) 7+. WSL/Git Bash 불필요.
>
> **스크립트 베이스 경로**: `C:\zinide\workspace\cloud-wms-doc\input\TT.551\`
>
> **호출 패턴**: Bash 도구에서 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<.ps1 경로>"` 로 호출한다.

---

## 입력 받기

`$ARGUMENTS` 로 전달된 값을 그대로 사용한다.

| 입력 | 설명 |
|---|---|
| 인수 (선택) | `V0` ~ `V10` 또는 `all`. 없거나 빈 문자열이면 `all` 로 간주. 표에 없는 값이면 안내 후 종료. |

---

## 스크립트 매핑표

| 인수 | 실행 PowerShell 스크립트 | 대상 | 주요 동작 |
|---|---|---|---|
| 없음 / `all` | `migrate_all.ps1` | V0~V10 전체 순서 실행 | |
| `V0` | `migrate_V0_create_db.ps1` | TO DB 데이터베이스 생성 | `wms-cloud-dev` DROP → CREATE |
| `V1` | `migrate_V1_schema.ps1` | DDL 적용 | 시퀀스 선생성 + `V1__create_schema.sql` 실행 |
| `V2` | `migrate_V2_code.ps1` | 공통코드 | `sm_comm_h`, `sm_comm_d` |
| `V3` | `migrate_V3_biz.ps1` | 사업장 | `mdm_biz`, `mdm_biz_biz` |
| `V4` | `migrate_V4_center.ps1` | 센터 | `mdm_center`, `mdm_biz_center` |
| `V5` | `migrate_V5_warehouse.ps1` | 창고 | `mdm_wh`, `mdm_biz_wh` |
| `V6` | `migrate_V6_location.ps1` | 위치(로케이션) | `mdm_loc` |
| `V7` | `migrate_V7_config.ps1` | 시스템파라미터 | `sm_biz_config`, `sm_opt_config`, `sm_dlv_config`, `sm_ob_proc_opt_config`, `sm_prod_opt_config` |
| `V8` | `migrate_V8_menu.ps1` | 메뉴 | `sm_group`, `sm_menu`, `sm_menu_group`, `sm_menu_opt_config` |
| `V9` | `migrate_V9_user.ps1` | 사용자 | `mdm_user`, `mdm_user_biz`, `mdm_user_center` |
| `V10` | `migrate_V10_functions.ps1` | 함수/프로시저 | `cloud-wms-be/DEV_DOC/sql/postgres/` 의 `fn_*.sql`, `sp_*.sql` |

---

## 실행 절차

### 1단계 — 인수 결정

- `$ARGUMENTS` 가 비어있거나 `all` → `migrate_all.ps1`
- `$ARGUMENTS` 가 `V0` ~ `V10` 중 하나 → 표에서 해당 스크립트 선택
- 그 외 값 → `"유효한 인수는 V0~V10 또는 all 입니다."` 안내 후 종료

### 2단계 — PowerShell 스크립트 실행

선택된 스크립트를 Bash 도구로 호출한다.

```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\{선택된_스크립트}"
```

예시:

#### 전체 실행 (인수 없음 또는 `all`)
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_all.ps1"
```

#### `V3` (사업장) 만 실행
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_V3_biz.ps1"
```

#### `V10` (함수/프로시저) 만 실행
```bash
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\zinide\workspace\cloud-wms-doc\input\TT.551\migrate_V10_functions.ps1"
```

### 3단계 — 결과 처리

- 각 PowerShell 스크립트가 출력하는 `STEP 1 ~ STEP 3` 메시지를 **그대로** 사용자에게 보여준다.
- 정상 종료(exitcode 0) → `"이관 완료. test/dev 건수를 확인하세요."` 안내.
- 비정상 종료(exitcode ≠ 0) → exitcode 와 오류 메시지를 출력하고 즉시 중단한다.

---

## 스크립트 폴더 구조

```
C:\zinide\workspace\cloud-wms-doc\input\TT.551\
├── migrate_all.ps1                  # 전체 (V0 → V10)
├── migrate_V0_create_db.ps1         # TO DB 생성
├── migrate_V1_schema.ps1            # DDL
├── migrate_V2_code.ps1              # 공통코드
├── migrate_V3_biz.ps1               # 사업장
├── migrate_V4_center.ps1            # 센터
├── migrate_V5_warehouse.ps1         # 창고
├── migrate_V6_location.ps1          # 위치(로케이션)
├── migrate_V7_config.ps1            # 시스템파라미터
├── migrate_V8_menu.ps1              # 메뉴
├── migrate_V9_user.ps1              # 사용자
└── migrate_V10_functions.ps1        # 함수/프로시저
```

> **이 스킬은 `.ps1` 파일들을 호출만 한다.** DB 접속정보(`FROM_*` / `TO_*`)와 SQL 로직은 각 `.ps1` 안에 들어있다. 접속정보를 바꾸려면 해당 `.ps1` 의 변수를 수정한다.

---

## 출력

- DB 직접 변경 (별도 산출물 파일 없음)
- 콘솔에 STEP 출력 + 이관 건수 보고

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 검증 (V0~V10 / all / 빈 값)
- [ ] 매핑표에서 실행할 `.ps1` 결정
- [ ] `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` 호출
- [ ] STEP 출력 사용자에게 그대로 표시
- [ ] exitcode 확인 (0 = 성공, ≠0 = 실패)
- [ ] 성공 시 `"이관 완료. test/dev 건수를 확인하세요."` 안내

---

## 주의사항

- **Windows 전용**: PowerShell `.ps1` 호출 기반. WSL/Linux/macOS 에서는 동작하지 않는다.
- **PowerShell 실행 정책**: 호출 시 항상 `-ExecutionPolicy Bypass` 를 붙여 정책 영향을 받지 않게 한다.
- **인터랙티브 입력 금지**: `-NoProfile` 로 프로필 로드 차단, 스크립트가 사용자 입력을 요구하지 않도록 작성되어 있어야 한다.
- **순서 보장**: `all` 실행 시 V0 → V1 → ... → V10 순으로 수행. 중간 실패 시 그 지점에서 중단되며 이후 단계는 수행되지 않는다.
- **재실행 안전성**: 각 `.ps1` 은 멱등하게 작성되어 있다고 가정한다(테이블 DELETE → COPY/INSERT 방식). V0 재실행은 DB DROP 을 동반하므로 **운영 환경에서는 호출 금지**.
