---
title: 환경 사실 — common-system (WMS)
description: common-system(WMS) 워크스페이스의 환경 사실 값(배포 식별자·호스트·DB·FTP). 키 의미·🔒 규칙·점검 grep 은 SET_ENV_USAGE.md 참조. 비밀값은 BE properties(ENC) 포인터만.
status: active
version: 1.0.0
author: ShinHyunKyu
repo_role: ai-hub
project: common-system
domain: wms
agent_usage: reference
related:
  - SET_ENV_USAGE.md
tags:
  - environment
  - porting
  - deploy
  - wms
---

# 환경 사실 — common-system (WMS)

> 키 의미·🔒 규칙·점검 grep·새 프로젝트 만드는 법 → [`SET_ENV_USAGE.md`](./SET_ENV_USAGE.md). 이 파일은 **값만** 담는다.
> 1차 채움 2026-06-24 (BE `application-{test,prod}.properties` · FE `.env.*` · `settings.gradle` · `logback.xml` 근거).

```env
# --- 정체성 (도출값, 참고용) ---
PROJECT=common-system
DOMAIN=wms
BE_NAME=common-system-be
FE_NAME=common-system-fe
# --- 배포 식별자 4종 ---
DEPLOY_CONTEXT_PATH=/common-system-be        # prod 는 WAR명이 곧 컨텍스트(properties 에 없음)
WAR_NAME=common-system-be.war                # Gradle bootWar
RESOURCES_FOLDER=common-system-be-resources  # /WEB_BASE/common-system-be-resources
LOG_DIR=D:/logs/common-system-be             # (+ qrtz: D:/logs/common-system-be-qrtz)
# --- 호스트·오리진 ---
BE_HOST_TEST=168.126.28.62:6270
BE_HOST_PROD=wms.zin.co.kr:6260
FE_API_ORIGIN_DEV=http://localhost:8080/common-system-be
FE_API_ORIGIN_TEST=http://168.126.28.62:6270/common-system-be
FE_API_ORIGIN_PROD=https://wms.zin.co.kr:6260/common-system-be
RESOURCE_ORIGIN=https://wms.zin.co.kr:6261/resources
# --- DB (단일 PostgreSQL / 🔒 포인터) ---
DB_TYPE=postgresql
DB_HOST=🔒  DB_PORT=🔒  DB_NAME=🔒  DB_USER=🔒   # → BE application-{profile}.properties (db.url)
DB_PASSWORD=🔒  # prod=ENC / ⚠️ test 평문 — BE 레포 별도 조치
# --- FTP / 레드마인 / 외부연동 ---
FTP_HOST=🔒  FTP_USER=🔒  FTP_PASSWORD=🔒  # ⚠️ 현재 평문
FTP_UPLOAD_ROOT=/WEB_BASE/common-system-be-resources
REDMINE_PROJECT_KEY=<미확인>
ERP_ENDPOINT=<…/common-system-be/{bizSeq}/sif/e2w/… — 인프라/ERP>
# --- 브랜드 ---
CUSTOMER_NAME=<공통 템플릿>
SYSTEM_DISPLAY_NAME=Cloud WMS                # FE VITE_APP_NAME=cloud
```

## 비고

- **prod 컨텍스트**: `application-prod.properties` 에 `context-path` 없음 — WAR명(`common-system-be.war`)이 곧 Tomcat 컨텍스트.
- ⚠️ **평문 비밀값**: `jwt.secret`·`apikey.secret`·`aes.key`·`ftp.password` 가 test/prod properties 에 평문(DB만 prod ENC). → BE 레포에서 Jasypt 암호화 권고(`oms-security.md`).
