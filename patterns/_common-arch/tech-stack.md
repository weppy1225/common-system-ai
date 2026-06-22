---
title: 공통 기술 스택 / 레이어 아키텍처
description: common-system 전 메뉴에 공통 적용되는 BE/FE 기술 스택·레이어 아키텍처·데이터 모델 컬럼 타입 SoT(라이브 DB 직접 조회) 규칙. 메뉴별 상세설계에서 중복 기술하지 않고 이 문서를 참조한다.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: common
related:
  - "spec/common-system/mdbz01/mdbz01-06-be-flow.md"
  - "spec/common-system/mdbz01/mdbz01-07-fe-flow.md"
tags:
  - detail-design
  - tech-stack
  - architecture
  - common
---

# 공통 기술 스택 / 레이어 아키텍처

> common-system **모든 메뉴에 공통**으로 적용되는 기술 스택·아키텍처 규칙이다.
> 메뉴별 상세설계 문서(`{메뉴}-api.md`, `{메뉴}-data-model.md`, `{메뉴}-be-flow.md`, `{메뉴}-fe-flow.md`)는 이 문서를 참조하며 기술 스택을 반복 기술하지 않는다.
> 메뉴마다 달라지는 값(메뉴코드, 패키지, Bean/DTO 목록)만 각 메뉴 문서에 기재한다.

## 1. 백엔드 (BE)

| 항목 | 내용 |
|---|---|
| 언어/프레임워크 | Java 11 / Spring Boot 2.7.18 (Spring 5.3.x) |
| ORM | MyBatis 3.5.13 (Mapper XML 방식) |
| DB | PostgreSQL 15.2 (schema: public) |
| 트랜잭션 | `@Transactional`은 TxComp에만 선언 |
| 공통 응답 | `{메뉴}Response` (ResponseData 기반) |
| 패키지 규칙 | `be.{그룹}.{메뉴코드}` (예: `be.md8000.mdbz01`) |
| 로그인 정보 획득 | Controller에서 `TokenTool`로 획득 |

### 1-1. BE 레이어 구조

```
{메뉴}Controller  ── REST 엔드포인트, TokenTool로 로그인 정보 획득
      │
{메뉴}Comp        ── 검증·조회·예외 변환 (조회 전용 + 검증 후 TxComp 위임)
      │
{메뉴}TxComp      ── @Transactional, 다중 테이블 쓰기 트랜잭션
      │
{메뉴}CompUtil    ── DTO 초기화
      │
{메뉴}Dao         ── Mapper 위임 + 복수 Mapper 조합
      │
{메뉴}Mapper(.xml)── MyBatis 쿼리
```

> 각 메뉴의 구체적인 Bean(DTO) 목록과 Comp 메서드별 처리는 `{메뉴}-be-flow.md`에 기재한다.

## 2. 프론트엔드 (FE)

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

> 각 메뉴의 구체적인 `.vue` 파일 구성·함수 흐름은 `{메뉴}-fe-flow.md`에 기재한다.

> **FE 표현계층 Source of Truth (2갈래).** 설계문서(`{메뉴}-screen.md`·`{메뉴}-fe-flow.md`)는 화면 구조·컴포넌트·함수 흐름까지만 다룬다. 그 아래 표현 세부는 성격에 따라 SoT가 갈린다:
>
> | 종류 | SoT |
> |---|---|
> | **공통·재사용 룩** (버튼·그리드·검색영역·팝업·전역 레이아웃·색·폰트) | 프로토타입: `.claude/rules/*`(`area_btn`·`area_result_grid`·`area_multi_input_grid`·`area_search`·`common_ui`·`popup_*`) / 운영 Vue: 공통 컴포넌트 `ZBtn`·`ZCell`·`ZSelect`·`ZText`·`ZAuiGrid`·`LayerPopup` |
> | **페이지 고유 CSS** (해당 `.vue`만의 일회성 스타일) | 그 `{메뉴}.vue`의 `<style>` |
> | **i18n 메시지 키** (`$t('message.xxx')`) | locale 사전 `messages.*` |
> | **AUIGrid 설정 객체 전체** (renderer·event·styleFunction 등) | 그 `{메뉴}.vue` |
>
> → 공통 룩은 **위 규칙/컴포넌트가 SoT**이므로 메뉴마다 layout/button/table 류 규칙 문서를 새로 만들지 않는다. 페이지 고유 CSS·i18n 키·그리드 설정 객체만 해당 소스를 직접 참조한다. (BE 컬럼 타입 SoT가 라이브 DB인 것과 동일 원칙 → §3)

## 3. 데이터 모델 — 컬럼 타입 Source of Truth (전 메뉴 공통)

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
> ※ 테이블정의서·DDL·ERD **산출물**(`/SD_331·333·334`)은 같은 DB로부터 떠내는 **별개의 제출용 산출물**이다. "타입 확인"이 목적이면 위 DB 조회를 쓰고, "산출물 제출"이 목적일 때만 해당 스킬을 쓴다. (여기서 다루지 않음)
