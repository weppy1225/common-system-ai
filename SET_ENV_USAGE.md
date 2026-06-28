---
title: 환경 사실 — 사용법·키 사전
description: SET_ENV.{프로젝트}.md(워크스페이스별 환경 사실 값)를 어떻게 읽고/채우는지와 각 키의 의미를 설명하는 가이드. 실제 값은 담지 않는다(값은 SET_ENV.{프로젝트}.md). 비밀값은 BE properties(ENC) 포인터만.
status: active
version: 4.0.0
author: ShinHyunKyu
last_modified_by: ShinHyunKyu
repo_role: ai-hub
agent_usage: reference
related:
  - SET_ENV.common-system.md
  - SET_ENV.kyochon-oms.md
  - .claude/rules/repo-paths.md
  - spec/common-system/_knowledge/install-guide/02-context-name-rename-map.md
  - .claude/rules/oms-security.md
  - PORTING.md
tags:
  - environment
  - porting
  - rebranding
  - deploy
  - config
---

# SET_ENV_USAGE — 사용법·키 사전

> **이 파일은 가이드다(값 없음).** 워크스페이스(= 고객 프로젝트)마다 달라지는, 폴더명에서 도출되지 않는 **환경 사실의 실제 값은 `SET_ENV.{프로젝트}.md`** 에 있다(`PORTING.md §06` 의 "흩어두면 진짜 지뢰").
>
> **왜 프로젝트별 파일인가.** 허브(`common-system-ai`)는 **모든 워크스페이스가 같은 git 레포를 클론**해 쓴다(`PORTING.md §01`). 그래서 `.env` 처럼 워크스페이스마다 다른 값을 한 파일에 못 넣는다. 대신 `spec/{프로젝트}`·`prototype/{프로젝트}` 처럼 **프로젝트별 파일 `SET_ENV.{프로젝트}.md`** 로 나눈다.

## 1. 사용법

1. **AI(읽기)**: `repo-paths.md` STEP 0 에서 `PROJECT`(워크스페이스 폴더명 도출)를 구한 뒤 **`SET_ENV.${PROJECT}.md` 를 읽는다.**
   - `workspace-common-system` → `SET_ENV.common-system.md`
   - `workspace-kyochon-oms` → `SET_ENV.kyochon-oms.md`
   - `workspace-hbbio-wms` → `SET_ENV.hbbio-wms.md`
2. **새 고객사(추가)**: **기존 `SET_ENV.{프로젝트}.md` 하나를 복사**해 `SET_ENV.{새프로젝트}.md` 로 만들고 값만 그 환경 값으로 바꾼다. (별도 템플릿 파일 없음 — 기존 파일이 곧 본보기)
3. **🔒 = 비밀값.** 어느 파일에도 **절대 적지 않는다.** 값은 BE `application-{profile}.properties`(가능하면 `ENC(...)` Jasypt)에만 두고, `SET_ENV.{프로젝트}.md` 엔 "어디 있는지" 포인터만.
4. 실 DB 호스트·계정 등 민감값을 굳이 채워야 하면 그 변형 파일은 **반드시 `.gitignore`** 한다(`oms-security.md`).

> 검증: 커밋 전 `grep -nE "(password|secret|token|jdbc:|api[_-]?key)\s*[:=]" SET_ENV.*.md` → 실값이 잡히면 안 된다.

## 2. 키 의미 사전 (프로젝트 무관 — 공통)

| 키 | 의미 | 출처 / 변경 위치 |
|---|---|---|
| `PROJECT`·`DOMAIN`·`BE_NAME`·`FE_NAME` | 정체성 (**도출값** — override 금지) | `repo-paths.md` 가 워크스페이스 폴더명에서 런타임 도출 |
| `APP_NAME` | 빌드/배포 식별자 ① (레포 폴더명과 다를 수 있음) | `.project` `<name>`, gradle `rootProject.name` / Ant `war.name` |
| `DEPLOY_CONTEXT_PATH` ② | URL prefix (FE↔BE·ERP) | BE `application-{dev,test}.properties` `context-path`, FE `.env.* VITE_API_ORIGIN` |
| `WAR_NAME` ③ | 빌드 산출물명 = Tomcat 컨텍스트 | BE 빌드설정(gradle `archiveFileName` / OMS=Ant `build.xml`), `Jenkinsfile*` |
| `RESOURCES_FOLDER` ④ | FTP 자원 폴더명 | BE `ftp.uploadRootPath` |
| `LOG_DIR` ④ | 로그 디렉토리 | BE `logback.xml` `LOG_DIR` |
| `*_HOST_*`·`FE_API_ORIGIN_*`·`RESOURCE_ORIGIN` | 서버 호스트·포트·오리진 | FE `.env.*`, 인프라(nginx) |
| `DB_*`·`ERP_DB` 🔒 | DB 접속 (호스트·포트·DB명·계정·비번) | BE properties — **포인터만** |
| `FTP_*` 🔒 | FTP 접속 | BE properties `ftp.*` |
| `REDMINE_*` | 이슈 추적 키/규칙 | `PI_issue_mod`·`PI_time_reg` 스킬 |
| `ERP_*`·`WMS_INTEGRATION`·`BIZ_SEQ_RULE` 등 | 외부연동(ERP/SIF/WMS)·사업장 | BE 연동코드, `spec/{PROJECT}/_knowledge/` |
| `CUSTOMER_NAME`·`SYSTEM_DISPLAY_NAME`·`LOGO_ASSET` | 산출물 표기·브랜드 | 매뉴얼·프로토타입 `_common/` |

> 배포 식별자 ①~④ 의 **변경 파일 전체 맵** → `spec/common-system/_knowledge/install-guide/02-context-name-rename-map.md`.

## 부록 — 이식 시 빠른 점검 (grep)

```bash
# 비밀 누출 스캔 (값 파일 대상)
grep -nE "(password|secret|token|jdbc:|api[_-]?key)\s*[:=]" SET_ENV.*.md
# 고정값 잔재 (허브가 {프로젝트} 대신 옛 이름을 박았는지)
git grep -n "common-system-be\|common-system-fe\|workspace-common-system"
```
