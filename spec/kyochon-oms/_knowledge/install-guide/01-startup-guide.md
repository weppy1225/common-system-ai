---
title: OMS 기동·빌드·배포 방법 (OMS 고유 차이)
description: oms-be(Ant→WAR→Tomcat 9)와 oms-fe(Vite) 로컬 기동·빌드·Jenkins 배포에서 common(Gradle/Spring Boot) 대비 OMS 고유 차이만 확인할 때 연다.
status: active
version: 1.0.0
project: oms-ai
agent_usage: reference
related:
  - knowledgebase/40-install-guide/deploy/deploy-guide.md
tags:
  - 기동
  - 빌드
  - 배포
---

# OMS 기동·빌드·배포 방법 — OMS 고유 차이

> 공통 골격(빌드→Tomcat 9 WAR 배포→기동 로그 확인 일반 절차)은 [common 문서](../../../../knowledgebase/40-install-guide/deploy/deploy-guide.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.

## 1. OMS 고유 차이 (vs common) 요약

| 항목 | common | OMS 고유 |
| ---- | ------ | -------- |
| BE 빌드 도구 | Gradle (`./gradlew bootWar`) | **Ant** (`ant mainTarget`) |
| BE 프레임워크 | Spring Boot (`WmsApplication`) | 전통 Spring + `WebApplicationInitializer`(`web.xml` 없음) |
| 프로파일 미지정 시 | 기동 실패(`IllegalStateException`) | `spring.profiles.active` + `spring.profiles.solution` 둘 다 사용 |
| 멀티 DB | 단일 DB | **OMS=PostgreSQL + ERP=SQL Server 동시** |
| FE 앱 분기 | 단일 빌드 | **한 레포 두 UI 시스템** — 쇼핑몰(`/bc`, e-commerce 스타일, AUIGrid 미사용) vs 관리자(`/be`, WMS식 AUIGrid). mode=환경+앱종류(`VITE_OMS_YN`). → §3.0 |

---

## 2. 백엔드(oms-be) — Ant WAR 빌드

MUST: 백엔드는 Maven/Gradle이 아니라 **Ant**로 WAR를 만든다.
근거: `oms-be/build.xml`

| target | 동작 | 근거 |
| ------ | ---- | ---- |
| `compile` | `src/main/java` 컴파일 → `build/classes`. `ZTEST*`, `WithMock*` 제외. `dist`/`*.xml`/`*.vm`/`*.properties` 복사 | `build.xml` compile target |
| `war` | `build/classes` + `WEB-INF/lib` → `oms-be.war` | `build.xml` war target |
| `mainTarget` (기본) | `compile` + `war` 실행 | `build.xml` mainTarget |

```bash
ant mainTarget   # → oms-be.war 생성
```

전제: `SERVER_LIB_DIR` 환경변수가 Tomcat lib 경로를 가리켜야 컴파일 classpath가 완성된다.
근거: `build.xml` 의 `<property name="server-lib.dir" location="${env.SERVER_LIB_DIR}" />`

### 2.1 부트스트랩 구조 (web.xml 없음)

MUST: `web.xml`이 없다. `ApplicationInitializer`(`WebApplicationInitializer` 구현체)가 서블릿 컨텍스트를 코드로 등록한다.
근거: `oms-be/src/main/java/fw/config/ApplicationInitializer.java`

등록 순서(`onStartup`):
1. `AppConfig` (ComponentScan, MapperScan, MessageSource)
2. `JasyptConfig` (프로퍼티 암호화)
3. `DBConfig`(OMS/PostgreSQL), `DBConfigErp`(ERP/SQL Server)
4. `SecurityConfig`, `WebMvcConfig`, `JwtConfig`
5. `FtpConfig`, `SpringAsyncConfig`, `QuartzConfig`
6. 필터: `DelegatingFilterProxy`, `CharacterEncodingFilter(UTF-8)`
7. `DispatcherServlet`

미확인: `EhCacheConfig` 등록은 `ApplicationInitializer`에서 주석 처리되어 있다(현재 비활성).

### 2.2 프로파일 (환경 분리)

| 프로파일 | 프로퍼티 파일 |
| -------- | ------------- |
| dev | `src/main/resource/prop/application-dev.properties` |
| test | `src/main/resource/prop/application-test.properties` |
| prod | `src/main/resource/prop/application-prod.properties` |

근거: `AppConfig` 의 `@PropertySource("classpath:/prop/application-${spring.profiles.active}.properties")`

OMS 고유: 프로퍼티는 `spring.profiles.active`, 솔루션/서비스 구분은 `spring.profiles.solution` 시스템 프로퍼티로 결정.
근거: `OMSPool.java` static 블록의 `System.getProperty("spring.profiles.solution")`

### 2.3 로컬 기동 (IDE + Tomcat)

미확인: 로컬에서는 IDE(Eclipse/STS 등)의 Tomcat 9 서버에 프로젝트를 올려 기동하는 방식으로 보인다(전용 로컬 실행 스크립트 없음). 정확한 IDE 설정은 팀 확인 필요.

리소스 마운트: Tomcat `context.xml`에서 외부 리소스 폴더를 `/resources`로 마운트한다.
근거: `oms-be/DEV_DOC/context.xml`
```xml
<Resources allowLinking="false">
    <PostResources readOnly="false"
                   className="org.apache.catalina.webresources.DirResourceSet"
                   base="C:\zinide\workspace\oms-be-resources"
                   webAppMount="/resources"/>
</Resources>
```

---

## 3. 프론트엔드(oms-fe) — mode = 환경 + 앱 종류

### 3.0 OMS = 한 레포, 두 UI 시스템 (쇼핑몰 vs 관리자) — SSoT

MUST: oms-fe 한 코드베이스는 **UI 패러다임이 다른 두 시스템**을 빌드한다. 신규 화면 작성 전 어느 시스템(모드)에 속하는지 먼저 정한다. 두 시스템은 컴포넌트·레이아웃·화면 스타일이 다르다.
근거(실제 코드 확인): `oms-fe/src/router/index.js`(`isOms = VITE_OMS_YN === 'Y'`), `src/views/{bc,be,bm}/`, `src/layout/OmsLayout.vue` vs `src/layout/index.vue`(`BeLayout`).

| 시스템 | 모드·경로 | `VITE_OMS_YN` | 레이아웃 | UI 스타일 | AUIGrid |
|---|---|---|---|---|---|
| **쇼핑몰(가맹점)** | `/bc` (+모바일 `/bm`) | `Y` | `OmsLayout`(OmsHeader/OmsFooter, dashboard.css·style.css) | **실제 인터넷 쇼핑사이트 스타일** (구매·장바구니·주문하기·주문완료·주문내역 플로우) | **미사용**(`grep -rl auigrid src/views/bc` = 0건) |
| **관리자(Admin)** | `/be` | `N` | `BeLayout`(`src/layout/index.vue`) | **WMS식 관리자 그리드 화면** (검색조건 + AUIGrid 목록 + 등록/수정 팝업) | **사용**(`src/views/be` 69개 파일) |

핵심 구분 규칙:

| 강도 | 규칙 | 이유 |
|---|---|---|
| MUST | `/bc`(쇼핑몰) 화면은 AUIGrid를 쓰지 않는다. 쇼핑 UI(상품카드·장바구니·주문폼)로 작성 | `/bc`는 그리드가 아닌 e-commerce 스토어프론트. 실제 0건 사용 |
| MUST | `/be`(관리자) 화면은 WMS식 패턴(검색조건 + `ZAuiGrid` 목록 + 팝업)을 따른다 | 관리자 화면 일관성 |
| MUST | 신규 화면은 **같은 모드의 기존 메뉴 화면을 먼저 읽고** 동일 패턴을 따른다 | 두 시스템 스타일 혼용 방지 |

> ⚠️ 쇼핑몰 도메인은 **두 모드에 나뉘어** 존재한다(혼동 주의):
> - `/bc/sh7000c`(쇼핑몰, 구매측): `구매`·`장바구니`·`주문하기`·`주문완료`·`주문내역` — e-commerce 스토어프론트. 근거 `src/router/modules/bc/sh7000c.js`(`title: '쇼핑몰'`).
> - `/be/sh7000`(쇼핑몰관리, 관리자측): `상품`·`제작업체`·`제작업체확인`·`쇼핑몰단가이력`·`현황조회`·`동의서조회` — AUIGrid 관리자. 근거 `src/router/modules/be/sh7000.js`(`title: '쇼핑몰관리'`).
>
> 모바일(`/bm`)은 PDA용 별도 모드다(상세 → §3 mode 표). 라우터 export 분기·메뉴 등록 절차는 → `knowledgebase/domains/oms/patterns/fe/01-router-menu-register.md`.

### 3.1 mode = 환경 + 앱 종류

MUST: mode가 곧 환경이자 앱 종류(OMS 가맹점 vs Admin)를 결정한다.
근거: `oms-fe/package.json` scripts, `oms-fe/.env.*`

| 명령 | mode | 앱 종류 (`VITE_OMS_YN`) |
| ---- | ---- | ----------------------- |
| `npm run dev:dev` | dev | OMS 가맹점 (Y) |
| `npm run dev:dev-admin` | dev-admin | Admin 관리자 (N) |
| `npm run dev:test` | test | OMS 가맹점 (Y) |
| `npm run dev:test-admin` | test-admin | Admin 관리자 (N) |
| `npm run dev:prod` | prod | OMS 가맹점 (Y) |
| `npm run dev:prod-admin` | prod-admin | Admin 관리자 (N) |

모든 dev 스크립트는 `vite --host`로 실행되어 LAN에서 접근 가능하다.
미확인: 개발 서버 포트는 Vite 기본값(5173)으로 추정. `vite.config.js`에 별도 server.port 설정은 확인되지 않음.

### 3.2 빌드 (mode별 산출물 경로 분리)

| 명령 | mode | 산출물 경로 |
| ---- | ---- | ----------- |
| `npm run build:dev` | dev | `build/dev/dist/` |
| `npm run build:dev-admin` | dev-admin | `build/dev-admin/dist/` |
| `npm run build:test` | test | `build/test/dist/` |
| `npm run build:prod` | prod | `build/prod/dist/` |

근거: `vite.config.js` 의 `const buildRoot = \`build/${mode}/dist\`` + `build.outDir`

### 3.3 테스트·린트

| 명령 | 동작 |
| ---- | ---- |
| `npm run test:unit` | Vitest (`--environment jsdom --root vitest/`) |
| `npm run test:e2e` | Playwright |
| `npm run lint` | ESLint (`.vue,.js,.jsx,.cjs,.mjs` 자동 수정) |

---

## 4. Jenkins 배포 (OMS 경로·서비스명)

### 4.1 백엔드 배포 파이프라인

근거: `oms-be/Jenkinsfile`(운영), `oms-be/Jenkinsfile-test`(테스트)

| 항목 | 운영(Jenkinsfile) | 테스트(Jenkinsfile-test) |
| ---- | ----------------- | ------------------------ |
| 브랜치 | `main` | `test-deploy` |
| Tomcat 경로 | `D:/WAS/Tomcat-9.0.75_CLOUD_OMS` | `D:/WAS/Tomcat-9.0.75_CLOUD_OMS_TEST` |
| WAS 경로 | `D:/WEB_BASE/CLOUD_OMS_BE` | `D:/WEB_BASE/CLOUD_OMS_TEST` |
| Tomcat 서비스 | `tomcat9-CLOUD-OMS` | `tomcat9-CLOUD-OMS-TEST` |
| JDK / Ant | JDK11 / Ant1.10 | JDK11 / Ant1.10 |

파이프라인 단계: Checkout → Backup(`D:/WEB_BASE_BACKUP/...` 에 `YYYYMMDD_HHmm` 폴더로 백업) → Build(`ant mainTarget`) → Stop(Tomcat 서비스 중지) → Deploy(WAR 배치) → Start(서비스 시작).

### 4.2 프론트엔드 배포

근거: `oms-fe/jenkinsfile`, `oms-fe/jenkinsfile-test` (소문자 파일명)
미확인: 프론트 Jenkinsfile 상세 단계는 본 조사에서 미확인. 필요 시 해당 파일 직접 확인.
