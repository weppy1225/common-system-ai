---
title: 백엔드 테스트 코딩 컨벤션
description: JUnit 테스트 클래스 구조·어노테이션·assert 패턴·엣지케이스 매트릭스 등 테스트 코드 작성 규칙
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: backend
tags:
  - test
  - junit
  - mockmvc
  - ztest
  - test-convention
  - edge-case
last_verified: 2026-04-09
---

# 백엔드 테스트 코딩 컨벤션 (Backend Test Coding Convention)

> `mdpd01` 메뉴 테스트 소스 분석을 기반으로 작성된 실제 코딩 컨벤션입니다.
> 신규 메뉴 개발 시 이 파일의 패턴을 반드시 준수하세요.

| 기준 소스 | 위치 |
|-----------|------|
| ZTEST_MDPD01Prod.java | be.md8000.mdpd01.test |
| ZTEST_MDPD01Controller.java | be.md8000.mdpd01.test |
| ZTEST_MDPD01Comp.java | be.md8000.mdpd01.test |
| ZTEST_MDPD01Dao.java | be.md8000.mdpd01.test |
| ZTEST_MDPD01Mapper.java | be.md8000.mdpd01.test |
| ZTEST_SUITE_MDPD01.java | be.md8000.mdpd01.test |

---

## 1. 패키지 및 파일 구조

```
be.{메뉴그룹_인스턴스}.{메뉴코드_인스턴스}.test/
├── ZTEST_{메뉴코드}Bean.java ← Bean(DTO) Validation 테스트
├── ZTEST_{메뉴코드}Controller.java ← Controller MockMvc 통합 테스트
├── ZTEST_{메뉴코드}Comp.java ← Comp 비즈니스 로직 통합 테스트
├── ZTEST_{메뉴코드}Dao.java ← Dao 통합 테스트 (실 DB)
├── ZTEST_{메뉴코드}Mapper.java ← Mapper 통합 테스트 (실 DB)
└── ZTEST_SUITE_{메뉴코드}.java ← 전체 테스트 Suite
```

**규칙**
- 패키지: 본 소스 패키지 하위 `.test` 서브패키지
- 파일명: `ZTEST_` 접두사 필수
- Suite 파일명: `ZTEST_SUITE_` 접두사

---

## 2. 상속 구조

각 테스트 클래스는 계층별 전용 부모 클래스를 상속합니다.

| 테스트 클래스 | 상속 부모 | 비고 |
|--------------|-----------|------|
| `ZTEST_{메뉴코드}Bean` | `ZTEST_ValidConfig` (WebMvcTest) | javax.validation 직접 실행 |
| `ZTEST_{메뉴코드}Controller` | `ZTEST_Controller` | MockMvc + Security |
| `ZTEST_{메뉴코드}Comp` | `ZTEST_Comp` | Spring 전체 컨텍스트 |
| `ZTEST_{메뉴코드}Dao` | `ZTEST_Dao` | Spring 전체 컨텍스트 |
| `ZTEST_{메뉴코드}Mapper` | `ZTEST_Mapper` | MyBatis SqlSession 직접 |

---

## 3. 클래스 어노테이션

### 3.1 Bean(DTO) Validation 테스트
```java
@WebMvcTest
@ContextConfiguration(classes = { ZTEST_ValidConfig.class })
@ActiveProfiles(resolver = ZTEST_ProfileResolver.class)
@Slf4j
public class ZTEST_{메뉴코드}Bean extends ZTEST_ValidConfig {

    @Autowired
    private Validator validatorInjected;

    @Autowired
    MessageSource messageSource;

    @BeforeAll
    public static void setUp() throws Exception {
        Locale.setDefault(Locale.getDefault());
    }
}
```

### 3.2 Controller 테스트
```java
@WebMvcTest
@ComponentScan(basePackageClasses = {메뉴코드}Controller.class,
        useDefaultFilters = false,
        includeFilters = {
                @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE,
                        value = { {메뉴코드}Controller.class }) })
@Import(HttpEncodingAutoConfiguration.class)
public class ZTEST_{메뉴코드}Controller extends ZTEST_Controller {

    private Integer bizSeq = 1;
    private String BASE_URL = String.format("/%d/{메뉴코드_인스턴스}/{리소스_소문자}s", bizSeq);

    @Autowired MockMvc mvc;
    @Autowired private WebApplicationContext context;

    @BeforeEach
    public void setUp() {
        mvc = MockMvcBuilders
                .webAppContextSetup(context)
                .addFilters(new CharacterEncodingFilter(StringPool.UTF_8, true))
                .apply(springSecurity())
                .build();
    }
}
```

### 3.3 Comp 테스트
```java
@Slf4j
public class ZTEST_{메뉴코드}Comp extends ZTEST_Comp {

    @Autowired
    {메뉴코드}Comp comp;
}
```

### 3.4 Dao 테스트
```java
public class ZTEST_{메뉴코드}Dao extends ZTEST_Dao {

    @Autowired
    {메뉴코드}Dao dao;
}
```

### 3.5 Mapper 테스트
```java
public class ZTEST_{메뉴코드}Mapper extends ZTEST_Mapper {

    {메뉴코드}Mapper mapper;

    @BeforeEach
    public void beforeEach() throws Exception {
        mapper = session.getMapper({메뉴코드}Mapper.class);
    }
}
```

### 3.6 Suite
```java
@Suite
@SelectClasses({
        ZTEST_{메뉴코드}Bean.class,
        ZTEST_{메뉴코드}Controller.class,
        ZTEST_{메뉴코드}Comp.class,
        ZTEST_{메뉴코드}Dao.class,
        ZTEST_{메뉴코드}Mapper.class,
})
@SuiteDisplayName("ZTEST_SUITE_{메뉴코드}")
public class ZTEST_SUITE_{메뉴코드} { }
```

---

## 4. 테스트 메서드 어노테이션 규칙

```java
@Order(10) // 실행 순서 (아래 5번 순서 체계 참고)
@DisplayName("품목 등록_성공") // "기능명_시나리오" 형식
@Test
@Transactional // DB 변경(INSERT/UPDATE/DELETE)이 있는 테스트에만 선언 (조회 제외)
@Rollback      // 명시성을 위해 @Transactional과 함께 선언 권장 (기본값 true)
@WithMockUser  // Controller 테스트에서 인증 필요 시
public void test_{동사}{리소스}() { }
```

**메서드명 규칙**: `test_` 접두사 + 동사 + 리소스명 + (옵션) 시나리오

```java
test_insertProd() // 정상 케이스
test_insertProdDuplicate() // 비즈니스 예외 케이스
test_updateProdFail() // 실패 케이스
test_deleteProdsAllFail() // 전체 실패
test_deleteProdsPartFail() // 일부 실패
```

---

## 5. @Order 순서 체계

| Order 범위 | 대응 CRUD | 비고 |
|-----------|-----------|------|
| 10 ~ 19 | INSERT | 10: 정상, 11~: 예외 케이스 |
| 20 ~ 29 | SELECT | 20: 목록, 21~: 단건/특수 조회 |
| 30 ~ 39 | UPDATE | 30: 정상, 31~: 예외 케이스 |
| 40 ~ 49 | DELETE | 40: 정상, 41~: 예외 케이스 |
| 50 ~ 59 | 기타 기능 | 엑셀, 라벨 등 |

---

## 6. assert 패턴

### 6.1 Comp / Dao 공통
```java
// 등록/수정/삭제 건수 검증
assertEquals(1, rtnRes.getProcCnt());
assertEquals(prodSeqs.size(), rtnRes.getProcCnt());

// 조회 결과 null 여부
assertNotNull(rtnRes.getPostProds());
assertNotNull(rtnRes.getProd());

// 건수 > 0
assertTrue(retList.size() > 0);
assertTrue(rtnRes.getProcCnt() > 0);

// 예외 발생 검증 — CompWarnException (비즈니스 경고)
assertThrows(CompWarnException.class, () -> comp.insertProd(makeMockBean(), null));

// 예외 발생 검증 — 일반 Exception
assertThrows(Exception.class, () -> comp.deleteProds(bizSeq, prodSeqs));
```

### 6.2 Controller (MockMvc)
```java
// 성공 응답
actions.andExpect(status().isOk())
       .andExpect(content().string(containsString("Success")));

// 등록 성공
actions.andExpect(status().isCreated())
       .andExpect(content().string(containsString("Success")));

// Validation 실패
actions.andExpect(status().isBadRequest())
       .andExpect(content().string(containsString("에러")))
       .andDo(print());

// 비즈니스 오류
actions.andExpect(status().isInternalServerError())
       .andExpect(content().string(containsString("특정키워드")));
```

### 6.3 Bean(DTO) Validation
```java
Set<ConstraintViolation<{Bean}>> validate = validatorInjected.validate(bean);
Iterator<ConstraintViolation<{Bean}>> iterator = validate.iterator();
// validate.size() 로 오류 건수 확인
// iterator로 각 오류 메시지 log.debug 출력
```

---

## 7. MockMvc 요청 패턴

```java
// PUT — 등록
mvc.perform(put(BASE_URL)
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .characterEncoding(StringPool.UTF_8)
        .content(JsonTool.toJson(request)));

// POST — 목록 조회
mvc.perform(post(BASE_URL)
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .content(JsonTool.toJson(request)));

// GET — 단건 조회 (토큰 헤더 포함)
mvc.perform(get(BASE_URL + StringPool.SLASH + seq)
        .headers(generateTokenHeader()));

// PATCH — 수정
mvc.perform(patch(BASE_URL)
        .with(csrf())
        .contentType(MediaType.APPLICATION_JSON)
        .content(JsonTool.toJson(request)));

// DELETE — QueryParam 방식
mvc.perform(delete(BASE_URL)
        .param("{리소스_소문자}Seqs", new String[]{"1", "2"})
        .with(csrf()));
```

---

## 8. Mock 데이터 생성 패턴

테스트 데이터는 반드시 **private 메서드**로 분리합니다.

```java
// 정상 등록용
private {Bean} makeMockInsertBean() { ... }

// 중복 케이스
private {Bean} makeMockInsertBeanDuplicate() { ... }

// 정상 수정용
private {Bean} makeMockUpdateBean() { ... }

// 수정 실패용 (DB에 없는 SEQ)
private {Bean} makeMockUpdateBeanFail() { ... }

// 중복 수정용
private {Bean} makeMockUpdateBeanDuplicate() { ... }

// 검색 조건용
private {SearchBean} makeMockSearchBean() { ... }
```

**공통 상수 사용**
```java
rtnBean.setRegId(TEST_ID); // 부모 클래스에 정의된 테스트 사용자 ID
rtnBean.setRegDt(DateTool.now());
rtnBean.setModId(TEST_ID);
rtnBean.setModDt(DateTool.now());
```

---

## 9. import 패키지 규칙

| 용도 | 패키지 |
|------|--------|
| Validation 어노테이션 | `javax.validation.constraints.*` |
| Validation 실행 | `javax.validation.ConstraintViolation`, `javax.validation.Validator` |
| JUnit 5 | `org.junit.jupiter.api.*` |
| Spring Test | `org.springframework.test.web.servlet.*` |
| Spring Security Test | `org.springframework.security.test.*` |
| Assertions | `org.junit.jupiter.api.Assertions.*` (static import) |
| MockMvc Builders | `org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*` (static import) |
| MockMvc Matchers | `org.springframework.test.web.servlet.result.MockMvcResultMatchers.*` (static import) |
| Hamcrest | `org.hamcrest.Matchers.containsString` (static import) |

> **javax vs jakarta**: 이 프로젝트는 `javax.validation` 을 사용합니다. `jakarta.validation` 사용 금지.
> 버전 근거: `../cloud-wms-be/build.gradle` 기준 `org.springframework.boot` `2.7.18`, 테스트는 `useJUnitPlatform()`으로 JUnit 5를 사용한다.

---

## 10. @Transactional / @Rollback 사용 규칙

### 10-1. 레이어별 적용 기준

| 레이어 | 조회 테스트 | DB 변경 테스트 (INSERT/UPDATE/DELETE) | 비고 |
|--------|------------|--------------------------------------|------|
| **Mapper** | `@Test` 만 | `@Test` 만 | `ZTEST_Mapper` 부모가 SqlSession을 직접 관리 → `@Transactional` 선언 시 오히려 충돌 가능 |
| **Dao** | `@Test` 만 | `@Test` + `@Transactional` + `@Rollback` | Spring 컨텍스트 사용, 테스트 후 자동 롤백 보장 |
| **CompUtil** | `@Test` 만 | `@Test` + `@Transactional` + `@Rollback` | 유틸 메서드가 DB 변경 포함 시 |
| **Comp** | `@Test` 만 | `@Test` + `@Transactional` + `@Rollback` | Comp → TxComp 호출 시 테스트 트랜잭션 안에 묶임 |
| **Controller** | `@Test` 만 | `@Test` 만 (MockMvc는 별도 처리) | MockMvc 요청은 별도 서블릿 컨텍스트 — 테스트 메서드 `@Transactional` 이 DB까지 전파되지 않음 |

---

## 11. 테스트 비활성화 — 회피 금지 원칙

### 11-1. 회피 목적 비활성화 금지 (BLOCKING)

테스트가 **실패한다는 이유로** 다음 행위를 하면 안 된다:

- `@Test` 메서드 삭제
- `@Test` 또는 `@Disabled` 추가로 주석 처리
- `assertEquals` → `assertNotNull` / `assertTrue(true)` 약화
- `try { assertX(); } catch (Throwable e) {}` 로 실패 삼킴
- 버그가 있는 실제값에 맞춰 기대값 변경
- 경계값/예외 입력을 정상값으로 단순화

실패는 거의 항상 프로덕션 코드의 결함을 드러낸 것이다. **테스트가 아닌 코드를 고친다.**

---

## 12. 테스트 케이스 작성 가이드 — 엣지/예외/경계값 (BLOCKING)

### 12-1. CRUD 메서드별 필수 케이스 매트릭스

#### INSERT 메서드 — 최소 4건

| # | 케이스 | 검증 포인트 |
|---|---|---|
| 1 | **정상 등록** | `procCnt=1`, PK 채번 확인 |
| 2 | **필수 필드 누락** | `ZinRequestParamValidException` 또는 검증 예외 |
| 3 | **중복 PK / 유니크 키 충돌** | `ZinExistDataException` |
| 4 | **참조 무결성 위반** (FK 없는 값) | `InsertFailException` 또는 SQL 예외 |

#### UPDATE 메서드 — 최소 4건

| # | 케이스 | 검증 포인트 |
|---|---|---|
| 1 | **정상 수정** | `procCnt=1`, 변경 후 값 재조회 검증 |
| 2 | **존재하지 않는 PK** | `ZinNotFoundException` |
| 3 | **`use_yn='N'` (논리삭제된 행)** | `ZinNotFoundException` |
| 4 | **다른 사업장(`bizSeq`)의 데이터 접근 시도** | `ZinNotFoundException` 또는 권한 예외 |

#### DELETE 메서드 — 최소 4건

| # | 케이스 | 검증 포인트 |
|---|---|---|
| 1 | **정상 삭제** | `use_yn='N'` 변경 확인 |
| 2 | **존재하지 않는 seqs** | `procCnt=0` 또는 예외 |
| 3 | **이미 사용 중인 데이터** | `NotMeetConditionsException` 또는 `AlreadyProcessException` |
| 4 | **빈 리스트 / null 입력** | `ZinRequestParamValidException` |

#### SELECT (목록) 메서드 — 최소 5건

| # | 케이스 | 검증 포인트 |
|---|---|---|
| 1 | **결과 다건** | size > 0, 정렬 순서 확인 |
| 2 | **결과 0건** (없는 검색어) | size == 0, NPE 없음 |
| 3 | **검색 조건 — 빈 문자열 / null** | 전체 결과 반환 |
| 4 | **LIKE 검색 — 특수문자(`%`, `_`) 입력** | escape 처리 확인 |
| 5 | **페이징 경계** — `offset=0`, `pageSize=1`, 마지막 페이지 | 모두 정상 동작 |

---

*최초 작성: 2026-03-05 | 기준 메뉴: `be.md8000.mdpd01.test`*
*§11 정정·§12 추가: 2026-04-09 — 테스트 회피 금지 + 엣지/예외 케이스 가이드*
