---
title: 환경 사실 — kyochon-oms (OMS)
description: kyochon-oms(OMS) 워크스페이스의 환경 사실 값(배포 식별자·호스트·DB·FTP·외부연동). 키 의미·🔒 규칙·점검 grep 은 SET_ENV_USAGE.md 참조. 비밀값은 BE properties(ENC) 포인터만.
status: active
version: 1.1.0
author: ShinHyunKyu
repo_role: ai-hub
project: kyochon-oms
domain: oms
agent_usage: reference
related:
  - SET_ENV_USAGE.md
  - spec/kyochon-oms/_knowledge/_meta.md
  - spec/common-system/_knowledge/install-guide/02-context-name-rename-map.md
tags:
  - environment
  - porting
  - deploy
  - oms
---

# 환경 사실 — kyochon-oms (OMS)

> 키 의미·🔒 규칙·점검 grep·새 프로젝트 만드는 법 → [`SET_ENV_USAGE.md`](./SET_ENV_USAGE.md). 이 파일은 **값만** 담는다.
> 채움 2026-06-24: `kyochon-oms-be/src/main/resource/prop/application-test.properties` · `build.xml` · `logback.xml` · `.project` · `kyochon-oms-fe/.env` 근거. (비밀값 제외)
>
> 🚨 **OMS 는 운영 중 + 추가 개발 단계다.** 이 파일은 **환경 사실 기록 전용**이며, BE/FE 소스·설정을 바꾸는 근거가 아니다. 아래 ⚠️ 는 **관찰 기록일 뿐 조치 지시가 아니다** — 운영 영향이 있으므로 변경은 담당자가 별도 판단한다(클로드는 BE/FE 파일을 건드리지 않는다).

```env
# --- 정체성 ---
PROJECT=kyochon-oms          # 워크스페이스 폴더명 도출
DOMAIN=oms
BE_NAME=kyochon-oms-be       # 레포 폴더명
FE_NAME=kyochon-oms-fe
APP_NAME=oms-be              # ⚠️ 빌드/배포 식별자 ① — 레포 폴더명과 다름! (.project<name>, build.xml war.name)
# --- 배포 식별자 4종 ---
DEPLOY_CONTEXT_PATH=/oms-be              # auth-login.md + logback + WAR명 (properties 에 context-path 없음 — 전통 Spring)
WAR_NAME=oms-be.war                      # build.xml war.name (Ant 빌드)
RESOURCES_FOLDER=oms-be-resources        # ftp.uploadRootPath=/home/kyo_ext/WEB_BASE/oms-be-resources
LOG_DIR=D:/logs/oms-be                   # (+ qrtz: D:/logs/oms-be-qrtz)
# --- 호스트·오리진 (FE .env — ⚠️ 비고 1 불일치 주의) ---
FE_API_ORIGIN_LOCAL=http://localhost:8080/wms-be       # ⚠️ /wms-be (BE 컨텍스트는 /oms-be)
FE_API_ORIGIN_TEST=http://168.126.28.62:6270/wms-be    # ⚠️ 동일 불일치
FE_API_ORIGIN_PROD=https://wms.zin.co.kr:6260/wms-be   # ⚠️ 동일 불일치
# --- DB (멀티DB / 🔒 포인터) ---
DB_TYPE=postgresql + sqlserver           # OMS=PostgreSQL / ERP=SQL Server(databaseName=NEOE)
DB_HOST=🔒  DB_PORT=🔒  DB_NAME=🔒  DB_USER=🔒  DB_PASSWORD=🔒   # → BE application-{profile}.properties (db.url)
ERP_DB=🔒                                # SQL Server, @OutDbLink (db.erp.*)
# --- FTP / 외부연동 ---
FTP_HOST=🔒  FTP_USER=🔒  FTP_PASSWORD=🔒   # test 는 ftp.use=false
FTP_UPLOAD_ROOT=/home/kyo_ext/WEB_BASE/oms-be-resources
APIKEY_HEADER=OMS-APIKey                  # OMS 자체 (WMS 연동 호출 시 WMS-APIKey)
WMS_INTEGRATION=wms-kyochon-be            # OMS→WMS 연동 (wms.base.url, host 🔒 BE properties)
MFA_PROVIDER=ideatec @ mfa.kyochon.com/iop   # apikey 🔒
DELIVERY_API=CJ대한통운 (dlvcj.url)
REDMINE_PROJECT_KEY=<미확인>
# --- 브랜드 ---
CUSTOMER_NAME=교촌
SYSTEM_DISPLAY_NAME=<미확정 — FE VITE_APP_NAME=cloud (WMS 템플릿 잔재 의심, 비고 1)>
```

## 비고 (⚠️ = 관찰 기록 — 조치 지시 아님, 운영 중이라 변경은 담당자 판단)

1. **⚠️ FE↔BE 컨텍스트 표기 차이 (관찰)** — BE 컨텍스트·WAR = **`/oms-be`** 인데, `kyochon-oms-fe/.env` 의 `VITE_API_ORIGIN*` 는 **`/wms-be`** + WMS 호스트(`wms.zin.co.kr:6260`·`168.126.28.62:6270`)로 보인다. 운영 중 정상 동작 중이므로 prod 빌드는 다른 경로(빌드변수·별도 .env)를 쓸 가능성이 있다 — **단정하지 않고 기록만**. (FE `.env` 단일 파일, `VITE_WEB_APP_LEVEL=test`) 확인이 필요하면 담당자가 판단.
2. **⚠️ 빌드 식별자 ≠ 레포 폴더명 (관찰)** — 빌드/배포 식별자 ① = `oms-be`, 레포 폴더명은 `kyochon-oms-be`. 향후 `context-name-rename-map.md`(OMS편) 작성 시 참고.
3. **⚠️ 평문 비밀값 (관찰)** — `application-test.properties` 에 DB 비번(OMS·ERP)·`jwt.secret`·`apikey.secret`·`aes.key`·`ftp.password`·`firebase.key`·`mfa.ideatec.apikey` 가 평문으로 보인다. `oms-security.md` 기준 민감. **이 파일엔 값을 옮기지 않았고**, 처리 여부는 BE 담당자 판단(클로드는 변경하지 않음).
4. **멀티DB** — OMS(PostgreSQL) + ERP(SQL Server, DB명 `NEOE`). ERP 매퍼는 `@OutDbLink` 라우팅(`oms-db-convention.md`).
5. **빌드** — Ant WAR(`build.xml`, WMS 의 Gradle 과 다름). `mainTarget` 이 빌드 후 FTP(`WAR` 디렉토리)로 전송.
6. **외부연동** — ERP(NEOE), WMS(`wms-kyochon-be`), MFA(ideatec/kyochon), CJ대한통운 택배.
