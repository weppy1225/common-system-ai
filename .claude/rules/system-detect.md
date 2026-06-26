---
description: 개발(BE/FE 코드 작성·수정, 메뉴 설계) 시작 시 대상 시스템(WMS·OMS 등)을 자동 판별하는 규칙. 허브(ai-kb=common-system-ai) 프레임워크 수정과 구분한다. *.java/*.vue/*Mapper.xml 또는 spec 설계 문서를 다룰 때 로딩한다.
paths:
  - "**/*.java"
  - "**/*.vue"
  - "**/*Mapper.xml"
  - "spec/**/*.md"
---

# 개발 대상 시스템 자동 판별

> 이 규칙은 BE/FE 코드·메뉴 설계 파일을 다룰 때 **lazy 로딩**된다. 로딩되면 작업 전에 **대상 시스템을 먼저 판별**한다. 추정하지 않는다.
> 숨은 전제: 허브(`common-system-ai`)는 모든 시스템 공통이라 허브명으로는 시스템을 못 정한다. 시스템 정체성은 **함께 열린 BE/FE 레포**에서 도출한다.

## 0. 작업 종류 먼저 구분 (BLOCKING)

| 작업 | 대상 파일(예) | 시스템 판별 |
|---|---|---|
| BE/FE 코드 개발·메뉴 설계 | `*-be`/`*-fe` 소스(`*.java`·`*.vue`·`*Mapper.xml`), `spec/{프로젝트}/{메뉴}/` | **필요** → §1~§3 수행 |
| 허브(ai-kb) 자체 수정 | `patterns/`·`.claude/`·루트 문서(`CLAUDE.md`·`STRUCTURE.md`) | **불필요** — 시스템 무관 프레임워크 유지보수 |

> `spec/`·`prototype/` 는 허브 레포 안에 있지만 **시스템별 산출물**이므로 판별 대상이다. `patterns/`·`.claude/`(도메인 룰 `{system}-*` 제외) 는 시스템 무관 프레임워크다.

## 1. 판별 신호 (우선순위)

| 순위 | 신호 | 비고 |
|---|---|---|
| 1 | `--add-dir` 로 추가된 디렉토리 중 `*-be`/`*-fe` 레포 | 가장 강한 신호 |
| 2 | 허브의 부모(워크스페이스) 폴더 형제 디렉토리 중 `*-be`/`*-fe` | add-dir 신호가 없을 때 |

## 2. 판별 절차

1. 위 신호에서 `*-be`/`*-fe` 레포명을 찾는다. (예: `kyochon-oms-be`, `kyochon-oms-fe`)
2. 접미어 `-be`/`-fe` 를 떼어 **시스템 베이스명**을 만든다. (예: `kyochon-oms`)
3. 베이스명을 `spec/*/_knowledge/_meta.md` 의 `project`(하이픈↔언더스코어 정규화)와 대조해 **프로젝트·도메인**을 확정한다. (예: `kyochon-oms` → `spec/kyochon-oms/`, `project=kyochon-oms`, `domain=oms`)

## 3. 확정 후 컨텍스트 고정

| 확정값 | 사용 경로/규칙 |
|---|---|
| 화면설계·검증 | `spec/{프로젝트}/`, `prototype/{프로젝트}/` |
| ② 도메인 표준 | 도메인 룰 `.claude/rules/{system}-*` 확인 후 작업 (OMS=`oms-*`, WMS=`wms-*`). 도메인 개념·실데이터는 기준 프로젝트의 ③(`spec/{프로젝트}/_knowledge/`) |
| 시스템별 규칙 | 해당 시스템 `.claude/rules/{system}-*` (OMS=`oms-*`) |
| BE/FE 코드 경로 | `repo-paths.md` 의 `$BE_DIR`/`$FE_DIR` (= 판별된 `*-be`/`*-fe`) |

## 4. 실패·충돌 (추정 금지)

- `*-be`/`*-fe` 신호가 **없으면** 사용자에게 어느 시스템인지 묻는다.
- 서로 다른 시스템의 `-be`/`-fe` 가 **둘 이상** 잡히면(예: `kyochon-oms-be` + `bnk-wms-be`) 사용자에게 확인한다.
- 베이스명에 대응하는 `spec/*/_knowledge/_meta.md` 가 **없으면** 새 프로젝트로 보고, `_meta.md` 신규 생성 여부를 사용자에게 확인한다.

> 우선순위(충돌 시): spec `{프로젝트}` 는 **본 절차(BE/FE 레포 베이스명 + `_meta.md` 대조)** 가 `repo-paths.md` 의 워크스페이스 폴더명 도출보다 **우선**한다. 워크스페이스가 `workspace-{프로젝트}` 규약을 따르지 않을 수 있기 때문이다(예: 현재 `kyochon_workspace`). `repo-paths.md` 는 BE/FE **디렉토리 경로**(`$BE_DIR`/`$FE_DIR`, `*-be`/`*-fe` find 폴백 포함) 확정에만 사용한다.
