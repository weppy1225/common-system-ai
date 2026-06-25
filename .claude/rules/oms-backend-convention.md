---
description: OMS 도메인 백엔드 코드 작성·수정 시 common 백엔드 컨벤션 대비 OMS 고유 판단 기준·금지만 적용. 고객사가 달라도 OMS 도메인이면 동일 규칙 적용. Controller/Comp/CompUtil/TxComp/Dao/Mapper 파일을 다룰 때 로딩한다.
paths:
  - "**/*Controller.java"
  - "**/*Comp.java"
  - "**/*CompUtil.java"
  - "**/*TxComp.java"
  - "**/*Dao.java"
  - "**/*Mapper.java"
---

# OMS 백엔드 개발 규칙 — OMS 고유 판단 기준

> 공통 골격은 [백엔드 컨벤션](./backend-convention.md) 과 동일하다. 이 문서는 **OMS 고유 판단 기준·금지만** 담는다. 상세 구현·코드 예시는 아래 patterns·소스를 본다.
> 전제: 전통 Spring(Boot 아님) · MyBatis · OMS=PostgreSQL + ERP=SQL Server 멀티DB.
> 고객사별 프로젝트 경로(`$PROJECT`, `$BE_DIR`) 도출 → `.claude/rules/repo-paths.md`.

## 상세는 어디에 (라우팅)

| 필요한 것 | 위치 |
|---|---|
| 레이어 코드 패턴(CompUtil/TxComp/Comp/Controller 예시·예외 흐름) | `spec/{$PROJECT}/_knowledge/patterns/be/01-layer-pattern.md` |
| 채번(DocNoGenerator/SeqGenerator) 상세 | `spec/{$PROJECT}/_knowledge/patterns/be/03-numbering-module.md` |
| 예외 클래스 실제 목록 | `{$BE_DIR}/src/.../fw/exception/`·`fw/exception/warn/` |
| 상수풀 정의값 | `{$BE_DIR}/src/.../fw/constant/{OMSPool,FwPool,StringPool}.java` |
| 도메인 코드값 의미 | `spec/{$PROJECT}/_knowledge/db-schema/90-common-code.md` |

## OMS 고유 판단 기준 (MUST / NEVER)

1. **프레임워크** — NEVER Spring Boot 어노테이션(`@SpringBootApplication`·`@EnableAutoConfiguration`). 전통 Spring(`WebApplicationInitializer` 부트스트랩). Lombok import 규칙은 common 강제 대신 OMS 기존 클래스 패턴을 따른다.

2. **CompUtil 생성** — 다음 중 1개 이상이면 CompUtil 로 분리: DTO 초기화(채번·문서번호·날짜), 이력 세팅(`setRegId`/`setRegDt`/`setModId`/`setModDt`) 3개 이상, 복합 검증, 상태 초기화. NEVER 이력 세팅을 Comp 에 직접 작성. (단순 조회 전용은 생략 가능)

3. **Comp vs TxComp** — DB Write(INSERT/UPDATE/DELETE) 포함 시 TxComp, 아니면 Comp. `@Transactional` 은 TxComp 전담(Comp/Controller/CompUtil 금지). ※ common 의 `wms_inven*`·InvenManager 조건은 OMS 무관(InvenManager 부재) — "DB Write 포함 여부"로만 판단.

4. **Controller HTTP/URL** — 같은 도메인 기존 Controller 패턴을 먼저 읽고 따른다(임의 결정 금지). 등록·수정 모두 **POST 우세**. `@RequestMapping` 첫 경로변수는 사업장 `{bizSeq}`(프론트 axios 자동 삽입).

5. **예외** — NEVER `RuntimeException` 직접 throw, NEVER `Zin*`/`ApiResponse`/`CommonResponse`/`BaseResponse` 등 신규 응답 클래스 생성. MUST `fw/exception/warn/` 기존 예외 + `fw/bean/ResponseData` 상속 사용. (흐름: Comp `result.setWarn/setSystemError` → `throw Response{Warn,Error}Exception` → `GlobalExceptionHandler` 변환)

6. **상수** — NEVER 도메인 코드값·문자열·숫자 리터럴 하드코딩. MUST `OMSPool`/`FwPool`/`StringPool` 을 먼저 확인, 없으면 해당 클래스 내 `private static final` 선언.

7. **채번** — NEVER 직접 SELECT/UPDATE 채번. MUST `fw.doc_no.DocNoGenerator`(문서번호)·`fw.seq.SeqGenerator`(시퀀스) 경유.

> common 과 동일(→ [backend-convention.md](./backend-convention.md)): JavaDoc, N+1(반복문 내 Dao 단건 호출) 금지, 대량 `<foreach>` 배치, 공통 자원(공용 테이블·프레임워크) 수정 전 영향 범위 분석.
