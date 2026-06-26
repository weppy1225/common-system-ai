---
title: 배포 컨텍스트·앱 이름 식별자 변경 위치 맵 (WMS)
description: WMS BE/FE의 배포 컨텍스트 경로·WAR명·앱 이름(예 wms-be → common-system-be)을 다시 바꿀 때 어디를 고쳐야 하는지 한 곳에 정리한 체크리스트. 리네임·리브랜딩 작업 시 참조.
status: active
version: 1.0.0
author: ShinHyunKyu
repo_role: ai-hub
agent_usage: reference
applies_to:
  - spec/common-system/_knowledge/install-guide/
tags:
  - deploy
  - context-path
  - rename
  - rebranding
---

# 배포 컨텍스트·앱 이름 식별자 변경 위치 맵 (WMS)

> WMS BE/FE의 "앱 이름·배포 컨텍스트"를 또 바꿔야 할 때 **빠뜨리지 않도록** 모든 위치를 모아둔 체크리스트.
> 최근 변경: `wms-be` / `/wms-be` → **`common-system-be` / `/common-system-be`** (2026-06-24).
> 식별자는 **서로 다른 4종**이며 갈래마다 영향 범위가 다르다. 한 갈래만 바꾸면 배포가 깨진다.

## 0. 식별자 4종 (혼동 주의)

| 식별자 | 현재 값 | 의미 |
|---|---|---|
| ① 프로젝트명 | `common-system-be` | Gradle `rootProject.name`, Eclipse `.project` name |
| ② 배포 컨텍스트 경로 | `/common-system-be` | URL prefix. FE↔BE·ERP 통신 경로 |
| ③ WAR 파일명 | `common-system-be.war` | 빌드 산출물명 = 외부 Tomcat 컨텍스트 |
| ④ 관련 저장소/로그 이름 | `common-system-be-resources`, `common-system-be`(로그) | FTP 폴더·로그 파일/디렉토리 (②와 별개) |

## 1. BE 레포 (`common-system-be`) — 변경 위치

| 파일 | 항목 | 식별자 |
|---|---|---|
| `settings.gradle` | `rootProject.name` | ① |
| `.project` | `<name>` | ① |
| `.settings/org.eclipse.wst.common.component` | `deploy-name`, `context-root` | ②③ (Eclipse Run-on-Server) |
| `build.gradle` | `bootWar { archiveFileName }` (+ 주석 2곳) | ③ |
| `src/main/resource/prop/application-dev.properties` | `server.servlet.context-path` (+ 주석) | ② |
| `src/main/resource/prop/application-test.properties` | `server.servlet.context-path` (+ 주석) | ② |
| `application-prod.properties` | context-path 없음 — **prod는 WAR명(③)이 곧 컨텍스트** | ② |
| `Jenkinsfile` / `Jenkinsfile-test` | `*.war`/`*.zip` 파일명 (copy/archive/rename/unzip/del) | ③ (안 바꾸면 CI가 `build/libs/*.war` 못 찾아 실패) |
| `application-{dev,test,prod}.properties` | `ftp.path`, `ftp.uploadRootPath` = `...-resources` | ④ FTP |
| `src/main/resource/logback.xml` | `LOG_DIR`, `LOG_PATH_NAME`, `fileNamePattern`, `QRTZ_LOG_DIR`, `QRTZ_LOG_PATH_NAME` (`D:/logs/...`, `*.log`, `*-qrtz`) | ④ 로그 |
| `src/main/java/fw/ws/WebSocketBrokerConfig.java` | 주석의 ws URL | ② (주석만) |
| `src/test/java/.../ZTEST_*.java` (6개: LGAP01 Comp/Controller/Dao/Mapper, fw/log/test LogDao/LogMapper) | `menuUrl` fixture URL | ② (테스트 데이터) |

> 참고: `ApikeyProvider`·`TokenAuthenticationFilter` 등은 `request.getContextPath()` **동적 사용** → 코드 수정 불필요.

## 2. FE 레포 (`common-system-fe`) — 변경 위치

| 파일 | 항목 | 식별자 |
|---|---|---|
| `.env.dev` / `.env.test` / `.env.prod` | `VITE_API_ORIGIN=.../{컨텍스트}` | ② (FE→BE 호출 origin) |
| `src/views/be/if9100/ifst01/ifstTab/ifst01TabRegApi.vue` | 화면 표시용 안내 URL | ② (표시) |

> **정적자산 base**(`vite.config.js`의 `base = ${VITE_ASSET_CONTEXT_PATH}/`): `VITE_ASSET_CONTEXT_PATH`가 `.env`에 미정의 → 현재 base=`/`. BE `src/main/webapp/dist/`의 `/wms-be/view/...`는 **과거 빌드 잔재**이며 FE 재빌드 시 갱신된다(수동 편집 대상 아님).
> `mock/mockoon.json`의 `name`은 표시 라벨(경로 아님) — 런타임 무관.

## 3. 레포 밖 (수동 — git으로 못 바꿈, ②③④와 lockstep 필요)

| 대상 | 내용 |
|---|---|
| Tomcat 배포 | 외부 Tomcat의 `${WAS_PATH}`/컨텍스트 디렉토리. Jenkins가 `tmp_unzip → WEB-INF` 복사 |
| nginx/리버스 프록시 | `wms.zin.co.kr:6260` / `168.126.28.62:6270` 의 `/{컨텍스트}` 매핑 |
| ERP 외부연동(SIF) | ERP 측 `/{컨텍스트}/{bizSeq}/sif/e2w/...` 엔드포인트 설정 |
| 빌드서버 config-overrides | `D:\config-overrides\CLOUD_WMS_TEST\` (Jenkins가 prop·xml 덮어쓰기) |
| FTP 서버 폴더 | `/WEB_BASE/{...}-resources` 실제 폴더명 (④) |
| 로그 서버 폴더 | `D:/logs/{...}` 실제 디렉토리 (④) |

## 4. OMS 대칭 참고

OMS(`kyochon-oms-be`)는 자체 컨텍스트를 가진다(현재 별도 값). 동일 갈래(①~④)를 OMS 레포 기준으로 적용한다. 시스템마다 컨텍스트가 다르므로 이 맵은 **WMS 기준**이다.
