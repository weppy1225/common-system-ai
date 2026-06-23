---
description: oms-be(전통 Spring + MyBatis) 백엔드 코드 작성·수정 시 common 백엔드 컨벤션 대비 OMS 고유 차이(전통 Spring·멀티DB·OMSPool 상수·fw/exception·POST 우세·채번·InvenManager 부재)만 적용. Controller/Comp/CompUtil/TxComp/Dao/Mapper 파일을 다룰 때 로딩한다.
paths:
  - "**/*Controller.java"
  - "**/*Comp.java"
  - "**/*CompUtil.java"
  - "**/*TxComp.java"
  - "**/*Dao.java"
  - "**/*Mapper.java"
---

# OMS 백엔드 개발 규칙 — OMS 고유 차이

> 공통 골격은 [백엔드 컨벤션](./backend-convention.md) 와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 전제: 전통 Spring(Boot 아님) · MyBatis · OMS=PostgreSQL + ERP=SQL Server 멀티DB.
> 상세 코드 패턴(클래스 템플릿·예외 흐름·DTO)은 → `oms-ai/02-백엔드-패턴.md`. 도메인 코드값·명명 접미어는 → `oms-ai/04-도메인-코드값.md`.

전제(숨은 전제 명시): oms-be 는 **Spring Boot 가 아니다.** 전통 Spring + Tomcat WAR(Ant 빌드) + MyBatis + PostgreSQL(OMS) / SQL Server(ERP) 멀티 DB.

---

## OMS 고유 차이 (vs common)

### 1. 프레임워크 — 전통 Spring(Boot 아님)

NEVER: Spring Boot 어노테이션(`@SpringBootApplication`, `@EnableAutoConfiguration`) 사용.
근거: `oms-be/src/main/java/fw/config/ApplicationInitializer.java`(`WebApplicationInitializer` 부트스트랩). 트랜잭션 활성화 = `DBConfig @EnableTransactionManagement`(→ `02-백엔드-패턴.md §2.3`).

> common 은 Lombok(`@RequiredArgsConstructor(onConstructor = @__(@Autowired))`, `@Slf4j`) 전제이나, OMS 는 위 import 규칙을 common 과 동일하게 강제하지 않는다 — OMS 기존 클래스 패턴을 우선 확인한다.

### 2. 모듈 접두어·CompUtil 생성 판단 (OMS 기준)

MUST: 한 기능 모듈은 모듈코드(예: `ODRG01`) 접두어를 공유하는 클래스 세트로 구성한다.
근거: `oms-be/src/main/java/bc/od3000c/odrg01/`.

MUST: 다음 중 하나 이상 해당 시 CompUtil 을 생성해 분리한다.
- DTO 초기화 로직(seq 채번, 문서번호 세팅, 날짜 세팅)
- 이력 세팅(`setRegId`/`setRegDt`/`setModId`/`setModDt`) 3개 이상
- 복합 검증(조건 2개 이상 AND, 또는 DB 조회 후 검증)
- 상태 초기화 코드

CompUtil 생략 가능(단순 조회 전용 한정): Comp 메서드가 Dao 호출 1~2줄 + result 세팅뿐인 경우.
NEVER: CompUtil 없이 `setRegId`/`setRegDt` 등 이력 세팅을 Comp 에 직접 작성.

> common 은 CompUtil 을 "2개 이상 레이어 공유 시 생성"으로 본다. OMS 는 위 4개 판단 기준을 우선한다.

### 3. Comp vs TxComp 분리 기준 (OMS 기준 — wms_inven/InvenManager 무관)

| 구분 | 사용 조건 |
|---|---|
| Comp | 조회, 단순 검증, DB Write 가 없는 비즈니스 로직 |
| TxComp | INSERT / UPDATE / DELETE 가 1개 이상 포함된 경우 |
| TxComp 필수 | 다중 테이블 Write, 문서번호 채번 + Insert 동시 |

> common 의 TxComp 조건(`wms_inven*` 처리·InvenManager 호출)은 OMS 에 적용하지 않는다 — OMS 는 "DB Write 포함 여부"로 판단한다.

### 4. Controller HTTP 메서드·URL 규칙 — POST 우세 + bizSeq

MUST: 신규 API 의 HTTP 메서드·URL 은 **같은 도메인 기존 Controller 를 먼저 읽고 동일 패턴**을 따른다. 임의 결정 금지.

관측(근거: `grep @*Mapping oms-be/src/main` — POST 226 / GET 66 / PATCH 45 / PUT 24 / DELETE 13, + `oms-fe/CLAUDE.md` URL 패턴):

| 작업 | 관측된 패턴 |
|---|---|
| 목록 조회(검색조건 body) | `POST /{bizSeq}/{모듈}/{리소스}` |
| 단건/상세 조회 | `GET /{bizSeq}/{모듈}/{리소스}/{seq}` |
| 등록 | `POST .../insert` |
| 수정 | `POST .../update` 또는 `PATCH` |
| 삭제 | `DELETE` |
| 엑셀 일괄 등록 | `PUT .../excel` |

MUST: `@RequestMapping` 경로 첫 변수는 사업장 `{bizSeq}`(사업장별 데이터 격리). 프론트 axios 가 자동 삽입한다(→ `03-프론트엔드-패턴.md §5`).

> common 은 등록=POST·수정=PUT/PATCH 매핑이나, OMS 는 등록·수정 모두 **POST 가 우세**하므로 OMS 기존 Controller 관측값을 우선한다.
> 미확인: WMS 계열 일부 문서는 "등록=PUT(201)/수정=PATCH" 컨벤션을 쓰나, OMS 는 POST 가 우세하므로 **OMS 기존 Controller 관측값을 우선**한다.

### 5. 예외 클래스 — fw/exception/warn/ 사용 (Zin* 예외 아님)

NEVER: `RuntimeException` 직접 throw.
MUST: `fw/exception/warn/` 하위 기존 예외 중 가장 가까운 것을 사용한다.
근거(실제 존재 확인): `fw/exception/`(`CompWarnException`, `CompErrorException`, `CompInfoException`, `ResponseWarnException`, `ResponseErrorException`), `fw/exception/warn/`(`AlreadyProcessException`, `NotEnoughInventoryException`, `InsertFailException`, `NotMeetConditionsException`, `InvalidAuthTypeException` 등 다수).

예외 흐름(상세 → `02-백엔드-패턴.md §4`): Comp 에서 `result.setWarn(e)` / `result.setSystemError(e)` 후 `throw new ResponseWarnException(e, result)` / `ResponseErrorException(e, result)` → `GlobalExceptionHandler`(`@RestControllerAdvice`)가 `ResponseData` HTTP 응답으로 변환.

NEVER: `ApiResponse<T>`, `CommonResponse`, `BaseResponse` 등 신규 응답 클래스 생성. → `fw/bean/ResponseData` 상속 사용.

> common 의 `ZinNotFoundException`/`ZinBadRequestException`/`ZinExistDataException` 은 OMS 에 적용하지 않는다 — OMS 는 위 `fw/exception/warn/` 예외 세트를 사용한다.

### 6. 상수풀 — OMSPool / FwPool / StringPool

MUST: 문자열·숫자 리터럴을 직접 쓰기 전에 아래 상수풀을 먼저 확인하고 정의된 상수를 사용한다.
근거(실제 존재 확인): `fw/constant/OMSPool.java`, `fw/constant/FwPool.java`, `fw/constant/StringPool.java`, `sif/abc/SifPool.java`(+`SifErpPool`/`SifOmsPool`/`SifTmsPool`).

| 클래스 | 패키지 | 주요 내용 |
|---|---|---|
| `OMSPool` | `fw.constant.OMSPool` | 주문 상태코드(`OD_STS_CD_*`), 비즈 구분(`OD`/`DO`/`RT`/`AD`/`DP`), 배송유형(`DELIVERY_TYPE_CD_*`), 시스템구분(`SYSTEM_DIV_CD_*`) 등 OMS 도메인 상수 |
| `FwPool` | `fw.constant.FwPool` | 레이어 로그 구분자(`CONTROLLER_START_LOG` 등), 디바이스 타입 |
| `StringPool` | `fw.constant.StringPool` | 공통 문자열(`EMPTY`, `Y`/`N` 등) |

NEVER: `OMSPool` 등에 정의된 도메인 코드값(`"33"`, `"OMS"`, `"100"` 등)을 리터럴로 하드코딩. 상세 코드값 → `04-도메인-코드값.md`.
SHOULD: 상수풀에 없는 값은 해당 클래스 내 `private static final` 선언 후 사용.

### 7. 채번 — DocNoGenerator / SeqGenerator (InvenManager 부재)

MUST: 채번은 전용 컴포넌트를 경유한다. 직접 SELECT/UPDATE 로 채번하지 않는다.
근거(실제 존재 확인): `fw/doc_no/DocNoGenerator.java`, `fw/seq/SeqGenerator.java`.

| 채번 종류 | 컴포넌트 | 호출 레이어 |
|---|---|---|
| 문서번호 | `fw.doc_no.DocNoGenerator` | Comp(단건) 또는 TxComp(DB Write 동일 트랜잭션 시) |
| 시퀀스 | `fw.seq.SeqGenerator` | 동일 |

> 미확인: WMS 의 `InvenManager`(재고 증감 경유) 는 oms-be 에 **존재하지 않는다**(`find -iname "*InvenManager*"` 0건). OMS 재고 관련 로직은 모듈별 구현이므로 WMS InvenManager 규칙(common §3·§7 의 `wms_inven*` 직접 DML 금지)을 적용하지 않는다.

### 8. OMS 금지 패턴 요약 (common 과 다른 것만)

- Spring Boot 어노테이션(`@SpringBootApplication`, `@EnableAutoConfiguration`) 사용 (§1)
- `@Transactional` 을 Comp / Controller / CompUtil 에 추가 — TxComp 전담 (§3)
- CompUtil 없이 `setRegId`/`setRegDt` 를 Comp 에 직접 작성 (§2)
- `RuntimeException` 직접 throw, `Zin*`/`ApiResponse<T>`/`CommonResponse` 등 신규 클래스 생성 → `fw/exception/warn/` + `ResponseData` 사용 (§5)
- `OMSPool`/`FwPool`/`StringPool` 정의값을 리터럴 하드코딩 (§6)
- 채번을 직접 SELECT/UPDATE 로 구현 → `DocNoGenerator`/`SeqGenerator` 경유 (§7)

> 아래는 common 과 동일하므로 [백엔드 컨벤션](./backend-convention.md) 을 따른다: JavaDoc 규칙, N+1(반복문 내 Dao 단건 호출) 금지, 대량 `<foreach>` 배치, 공통 자원(공용 테이블·프레임워크) 수정 전 영향 범위 분석.
