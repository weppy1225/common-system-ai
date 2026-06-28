---
title: 시스템 아키텍처 / 기술 스택 (공통)
description: common-system 전 메뉴에 공통 적용되는 시스템 구성(3-Tier)·BE/FE 기술 스택·주요 라이브러리·데이터 모델 컬럼타입 SoT 규칙. 메뉴별 상세설계(be-flow·fe-flow·data-model)는 이 문서를 참조하고 스택을 반복 기술하지 않는다. 정확한 의존성·버전 SoT는 BE 레포 build.gradle.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: common
related:
  - "patterns/30-backend/be-layer-pattern.md"
  - "patterns/40-frontend/00-overview.md"
tags:
  - architecture
  - tech-stack
  - 3tier
  - spring
  - vue3
  - common
---

# 시스템 아키텍처 / 기술 스택 (공통)

> common-system **모든 메뉴에 공통**으로 적용되는 시스템 구성·기술 스택 규칙이다.
> 메뉴별 상세설계(`{메뉴}-be-flow.md`·`{메뉴}-fe-flow.md`·`{메뉴}-data-model.md`)는 이 문서를 참조하며 스택을 반복 기술하지 않는다. 메뉴마다 달라지는 값(메뉴코드·패키지·Bean/DTO 목록)만 각 메뉴 문서에 기재한다.
> **정확한 의존성·버전의 Source of Truth 는 BE 레포 `build.gradle`** 이다. 본 문서의 버전표는 요약이며, 충돌 시 `build.gradle` 이 우선한다.

## 1. 시스템 구성 (3-Tier)

Vue3 + Spring Boot 기반 3-Tier 구조. DB는 PostgreSQL, ERP와 연동된다.

```
[User Devices]  PC(사용자)·PC(관리자)·PDA/모바일
      │
      ▼
[UI Layer]      Vue3 / NGINX
                 - Portal UI (PORT 80)
                 - Admin / Mobile UI (PORT 8080)
      │  (API 호출)
      ▼
[BIZ Layer]     Spring Boot / 내장 Tomcat (PORT 6270)
                 - 업무 도메인별 API (등록·조회·처리), 마스터 API
                 - 비즈니스 로직·트랜잭션 제어·ERP 연동·DB 접근
      │
      ├──────────────┬───────────────────────┐
      ▼              ▼                       ▼
[PostgreSQL]     [ERP (Legacy)]          [File Storage]
 PORT 5432        회계·정산 연동           PORT 22 (SFTP)
 업무·이력·마스터  기준정보 동기화          엑셀 템플릿·첨부 이미지
```

| 계층 | 기술 | 역할 |
|---|---|---|
| UI | Vue3 / NGINX | 요청 수신·API 호출·화면 렌더링 |
| BIZ | Spring Boot / Java / 내장 Tomcat | 비즈니스 로직·트랜잭션·ERP 연동·DB 접근 |
| DB | PostgreSQL | 업무·트랜잭션 이력·마스터 데이터 |
| Legacy | ERP | 회계/정산 연동, 기준정보 동기화 |
| File | SFTP | 업로드 파일·엑셀 템플릿 |

## 2. 백엔드 (BE)

| 항목 | 내용 |
|---|---|
| 언어/프레임워크 | Java 11 / **Spring Boot 2.7.18** (Spring Framework 5.3.x) |
| 빌드/실행 | Gradle (`bootWar`), 내장 Tomcat (`./gradlew bootRun`) |
| ORM | MyBatis 3.5.13 (Mapper XML 방식, `mybatis-spring-boot-starter` 미사용 — `SqlSessionTemplate` 수동 듀얼 관리) |
| DB | PostgreSQL 15.2 (schema: `public`) |
| DB 마이그레이션 | Flyway 9.16.3 |
| 트랜잭션 | `@Transactional`은 TxComp에만 선언 |
| 공통 응답 | `{메뉴}Response` (`ResponseData` 기반) |
| 패키지 규칙 | `be.{그룹}.{메뉴코드}` (예: `be.md8000.mdbz01`) |
| 로그인 정보 획득 | Controller에서 `TokenTool`로 획득 |

> **BE 레이어 구조**(Controller→Comp→TxComp→Dao→Mapper)와 클래스별 역할·호출 원칙·공통 예외/응답은 → [`30-backend/be-layer-pattern.md`](./30-backend/be-layer-pattern.md). (여기서 반복하지 않는다.)

## 3. 주요 라이브러리 & 버전

> **전체 의존성·정확한 버전 SoT = `$BE_DIR/build.gradle`.** 대부분의 버전은 Spring Boot BOM 이 관리하며(명시 핀이 없으면 Boot 2.7.18 BOM 기준), 아래는 **명시적으로 핀하거나 업무상 중요한 항목**만 추린 요약이다. 수기 JAR 전수 목록은 build.gradle 과 영구 drift 되므로 두지 않는다.

| 영역 | 라이브러리 | 버전 | 비고 |
|---|---|---|---|
| 프레임워크 | Spring Boot | 2.7.18 | spring-boot-starter-web/security/validation/aop/quartz/websocket/cache/jdbc |
| 언어 | Java | 11 | `sourceCompatibility = 11` |
| ORM | MyBatis / mybatis-spring | 3.5.13 / 2.1.1 | 자동구성 충돌 방지 위해 starter 미사용 |
| DB 드라이버 | PostgreSQL JDBC | Boot BOM 관리 | `runtimeOnly 'org.postgresql:postgresql'` |
| 커넥션풀 | HikariCP | Boot BOM 관리 | starter-jdbc 포함 |
| DB 마이그레이션 | Flyway | 9.16.3 | Boot 기본 8.x → ext override |
| 인증 | jjwt (api/impl/jackson) | 0.11.2 | JWT Bearer(STATELESS) + API Key 병행 |
| 설정 암호화 | jasypt-spring-boot-starter | 3.0.5 | `ENC(...)` 복호화 |
| 클라우드 | firebase-admin | 9.3.0 | + Google Cloud Storage |
| 문서 | Apache POI(poi-ooxml) / PDFBox·html2pdf | 5.2.3 / — | 엑셀·PDF |
| HTTP 클라이언트 | Retrofit / OkHttp | 2.6.x | 외부 REST 연동 |
| 스케줄링 | Quartz | 2.3.x | starter-quartz |
| 로깅 | Logback + Log4j2 + Log4jdbc | Boot BOM 관리 | SQL 로그 포함 |

## 4. 프론트엔드 (FE)

| 항목 | 내용 |
|---|---|
| 프레임워크 | Vue 3 (`<script setup>` Composition API) |
| 상태관리 | Pinia (`loginStore`, 메뉴별 store) |
| 통신 | axios (zAxios 인터셉터가 `regBizSeq` 자동 prepend) |
| 그리드 | AUIGrid 래퍼 컴포넌트 `ZAuiGrid` |
| 공통 컴포넌트 | `ZText`, `ZSelect`, `ZCell`, `ZCellBox`, `ZBtn`, `ZBtnProc`, `LayerPopup` |
| 다국어 | vue-i18n (`$t`, `t`) |
| 검증 | vuelidate (`required` 등) |
| 주소검색 | `useAddress` (다음 우편번호 팝업) |
| 상수 | `zConstant.js` / `wmsConstant` (리터럴 하드코딩 금지) |

> **FE 상세 패턴·컴포넌트 SoT** = [`patterns/40-frontend/00-overview.md`](./40-frontend/00-overview.md). 각 메뉴의 `.vue` 구성·함수 흐름은 `{메뉴}-fe-flow.md`에 기재한다.
>
> **FE 표현계층 Source of Truth (2갈래).** 설계문서(`{메뉴}-screen.md`·`{메뉴}-fe-flow.md`)는 화면 구조·컴포넌트·함수 흐름까지만 다룬다. 그 아래 표현 세부는 성격에 따라 SoT가 갈린다:
>
> | 종류 | SoT |
> |---|---|
> | **공통·재사용 룩** (버튼·그리드·검색영역·팝업·전역 레이아웃·색·폰트) | 프로토타입: `patterns/10-screen-design/10-web/01~07`(상세 구현 SSoT) — `.claude/rules/*`(`area_btn`·`area_result_grid`·`area_multi_input_grid`·`area_search`·`common_ui`·`popup_*`)는 HTML 작업 시 자동 트리거되는 얇은 rule로 이 패턴 문서를 가리킨다 / 운영 Vue: 공통 컴포넌트 `ZBtn`·`ZCell`·`ZSelect`·`ZText`·`ZAuiGrid`·`LayerPopup` |
> | **페이지 고유 CSS** (해당 `.vue`만의 일회성 스타일) | 그 `{메뉴}.vue`의 `<style>` |
> | **i18n 메시지 키** (`$t('message.xxx')`) | locale 사전 `messages.*` |
> | **AUIGrid 설정 객체 전체** (renderer·event·styleFunction 등) | 그 `{메뉴}.vue` |
>
> → 공통 룩은 **위 패턴 문서/컴포넌트가 SoT**이므로 메뉴마다 layout/button/table 류 규칙 문서를 새로 만들지 않는다. 페이지 고유 CSS·i18n 키·그리드 설정 객체만 해당 소스를 직접 참조한다.

## 5. 데이터 모델 — 컬럼 타입 Source of Truth (전 메뉴 공통)

> 각 메뉴 `{메뉴}-data-model.md`는 **업무-테이블 매핑·관계·상태값 의미**만 다룬다. **컬럼 단위 타입·길이·NN·default의 정답(Source of Truth)은 살아있는 DB**이며, 정적 산출물(테이블정의서 xlsx 등)은 생성 시점 스냅샷이라 최신이 아닐 수 있다. 정확한 값이 필요하면 **DB를 직접 조회**한다.

- **DB:** PostgreSQL, schema `public`.
- **접속 정보 위치:** `$BE_DIR/src/main/resource/prop/application-{dev|test|prod}.properties`. **비밀정보는 문서에 적지 않고 이 파일에서 읽는다.**

**확인 방법 — DB 직접 조회 (`information_schema`):** 메뉴별 테이블 목록만 `IN (...)`에 넣어 조회한다.
```sql
SELECT table_name, column_name, data_type, character_maximum_length, is_nullable, column_default
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name IN ( /* {메뉴}-data-model.md §1 의 물리 테이블 목록 */ )
 ORDER BY table_name, ordinal_position;
```

> 테이블에 없는 **파생 필드**(SQL `CASE`/`COUNT` 산출)의 타입은 `{메뉴}-be-mapper-sql.md`의 SQL에서 확인한다. (DB 조회 + mapper-sql = 전 필드 커버)
>
> ※ 테이블정의서·DDL·ERD **산출물**(`/SD_331·333·334`)은 같은 DB로부터 떠내는 **별개의 제출용 산출물**이다. "타입 확인"이 목적이면 위 DB 조회를 쓰고, "산출물 제출"이 목적일 때만 해당 스킬을 쓴다.
