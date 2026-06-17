---
title: ERP 인터페이스 (E2W) 코딩 컨벤션
description: ERP→WMS 수신(E2W) SIF 모듈 개발 시 패키지 구조·클래스 명명·예외 처리·테스트 패턴 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: interface
tags:
  - sif
  - erp
  - e2w
  - convention
---

# ERP 인터페이스 (E2W) 품목 등록 모듈 코딩 컨벤션

## 1. 패키지 구조

### 1.1 기본 패키지 구조
```
sif.erp.e2w.abc # 공통 모듈
sif.erp.e2w.{domain}.{type} # 업무별 모듈 (예: prod_reg, prod_mod, prod_del)
sif.erp.e2w.{domain}.{type}.bean # VO/Bean 클래스
sif.erp.e2w.{domain}.{type}.test # 테스트 클래스
```

### 1.2 패키지 명명 규칙
- **공통 모듈**: `sif.erp.e2w.abc`
- **등록 API**: `sif.erp.e2w.{domain}_reg` (예: prod_reg)
- **수정 API**: `sif.erp.e2w.{domain}_mod` (예: prod_mod)
- **삭제 API**: `sif.erp.e2w.{domain}_del` (예: prod_del)
- **조회 API**: `sif.erp.e2w.{domain}_sch` 또는 `{domain}_sts` (예: prod_sch)

## 2. 클래스 명명 규칙

### 2.1 공통 클래스
| 클래스명 | 설명 | 예시 |
|----------|------|------|
| `E2WAbcReq` | 공통 Request 추상 클래스 | `E2WAbcReq` |
| `E2WAbcRes` | 공통 Response 추상 클래스 | `E2WAbcRes` |
| `E2WAbcPool` | 상수 정의 클래스 | `E2WAbcPool` |
| `E2WAbcComp` | 공통 컴포넌트 | `E2WAbcComp` |
| `E2WAbcCompUtil` | 공통 유틸리티 | `E2WAbcCompUtil` |
| `E2WAbcAspect` | AOP 공통 처리 | `E2WAbcAspect` |
| `E2WAbcDao` | 공통 DAO | `E2WAbcDao` |
| `E2WAbcMapper` | 공통 MyBatis Mapper | `E2WAbcMapper` |

### 2.2 업무별 클래스
| 컴포넌트 | 접미사 | 예시 |
|----------|--------|------|
| Controller | `Controller` | `E2WProdRegController` |
| Comp (Service) | `Comp` | `E2WProdRegComp` |
| TxComp (트랜잭션) | `TxComp` | `E2WProdRegTxComp` |
| Dao | `Dao` | `E2WProdRegDao` |
| Mapper | `Mapper` | `E2WProdRegMapper` |
| Request Bean | `Req` | `E2WProdRegReq` |
| Response Bean | `Res` | `E2WProdRegRes` |

## 3. 상속 구조

### 3.1 Request/Response 상속 관계

> ⚠️ **제네릭 필수**: `E2WAbcReq`는 `E2WAbcReq<D extends E2WAbcProd>` 제네릭 클래스다.
> raw type(`extends E2WAbcReq`) 사용 시 `E2WAbcRequestBody<H extends E2WAbcReq<?>>` type bound 위반으로 **컴파일 깨짐**.

```
E2WAbcReq<D extends E2WAbcProd> (추상)
    ├── E2WProdRegReq extends E2WAbcReq<E2WProdRegProd>   (line item 있음 — 도메인 Prod 사용)
    └── E2WContRegReq extends E2WAbcReq<E2WAbcProd>       (line item 없음 — placeholder 사용)

E2WAbcRes
    └── E2WProdRegRes

E2WAbcRequestBody<H extends E2WAbcReq<?>> (SifRequest 구현)   ← <?> 필수, raw 금지

E2WAbcResponseBody<T extends E2WAbcRes> (SifResponse 구현)
```

### 3.2 E2WXxxReq 제네릭 패턴 — 2가지 케이스

| 케이스 | 상속 | 대상 |
|---|---|---|
| **line item 있는 Req** | `extends E2WAbcReq<E2W{도메인}{타입}Prod>` | 입고·출고·재고조정 등록 등 (prodList 포함) |
| **line item 없는 Req** | `extends E2WAbcReq<E2WAbcProd>` | 거래처·품목 메타 등록·수정·삭제 등 (헤더만) |

> 거래처/품목 도메인이라도 `E2WAbcCont` 같은 별도 base 클래스는 존재하지 않음.
> line item 없는 모든 Req는 `E2WAbcProd`를 placeholder로 사용한다.

### 3.3 Bean 클래스 상속 구조
```
E2WAbcProd (line item 부모)
    ├── E2WProdRegProd, E2WIwRegProd, ... (line item 있는 도메인 전용 Prod)
    └── (line item 없는 Req는 E2WAbcProd 자체를 placeholder로 사용)

E2WAbcValidProd (품목 검증용)
E2WAbcValidCont (거래처 검증용)
E2WAbcTable (테이블 정보)
```

## 4. 메서드 명명 규칙

### 4.1 공통 메서드
| 접두사 | 설명 | 예시 |
|--------|------|------|
| `get` | 조회/Getter | `getInstance()`, `getTableInfo()` |
| `set` | Setter | `setViewOneLine()` |
| `is` | Boolean 반환 | `isEmpty()` |
| `check` | 유효성 검사 | `checkSifValids()`, `checkFormat()` |
| `valid` | 유효성 검증 (예외 발생) | `validData()`, `validRequest()` |
| `make` | 객체 생성 | `makeInsertBatchVO()` |
| `search` | DB 조회 | `searchCenterList()`, `searchProdList()` |
| `insert` | DB 등록 | `insertBatch()`, `insertProd()` |
| `update` | DB 수정 | `updateBatchEnd()` |
| `delete` | DB 삭제 | - |
| `handle` | 에러/성공 처리 | `handleError()`, `handleSuccess()` |
| `before` | 전처리 | `beforeProcess()` |
| `after` | 후처리 | `afterProcess()` |

### 4.2 업무 프로세스 메서드
| 메서드명 | 설명 |
|----------|------|
| `e2wProcess()` | 메인 비즈니스 로직 (AOP 대상) |
| `bizCheck()` | 업무 유효성 검사 |
| `bizProcess()` | 업무 로직 처리 |

## 5. 변수 명명 규칙

### 5.1 공통 접두사
| 접두사 | 설명 | 예시 |
|--------|------|------|
| `if` | 인터페이스 관련 | `ifKey`, `ifProdId`, `ifContId` |
| `biz` | 사업장 관련 | `bizSeq` |
| `req` | 요청 관련 | `reqList`, `reqCnt` |
| `res` | 응답 관련 | `resList`, `resCnt` |
| `err` | 에러 관련 | `errKey`, `errMsg` |
| `dup` | 중복 관련 | `dupIfKeySet` |
| `temp` | 임시 변수 | `tempList` |

### 5.2 Boolean 변수
- 긍정형 사용 (`isXxx` 형태 지양)
- 예: `ignore` (O), `isIgnore` (X)
- `useYn`, `mngYmdMngYn` 등의 DB 컬럼명과 일관성 유지

## 6. 상수 정의

### 6.1 E2WAbcPool 클래스
```java
public class E2WAbcPool {
    /** API 통신 성공 */
    public static final String HTTP_RESULT_SUCCESS = "OK";
    
    /** API ID 정의 */
    public static final String E2W_PROD_REG = "E2W_PROD_REG";
    
    /** Enum 정의 */
    public static enum API {
        E2W_PROD_REG("E2W_PROD_REG", "품목 등록 API", "mdm_prod", null, null);
        
        private String apiId;
        private String apiNm;
        // ...
    }
}
```

### 6.2 어노테이션 값 상수화
```java
@SifValid(ableValues = { StringPool.Y, StringPool.N })
private String useYn;
```

## 7. 예외 처리

### 7.1 예외 클래스 계층
```
RuntimeException
    ├── SifWarnException (비즈니스 경고)
    ├── SifDuplicateIfKeyException (중복 키)
    ├── SifFieldFormatException (데이터 형식)
    └── SifRequestFormatException (요청 형식)
```

### 7.2 에러 처리 패턴
```java
try {
    // 비즈니스 로직
} catch (SifWarnException e) {
    handleError(responseBody, requestHead, e.getMessage());
    reqIterator.remove(); // 제외 처리
} catch (Exception e) {
    log.error("시스템 에러", e);
    handleError(responseBody, requestHead, "시스템 내부 오류");
}
```

## 8. 로깅 규칙

### 8.1 Logger 사용
```java
private static final Logger log = LoggerFactory.getLogger(ClassName.class);
// 또는 @Slf4j 애노테이션 사용
```

### 8.2 로그 레벨
| 레벨 | 사용처 |
|------|--------|
| `ERROR` | 시스템 예외, 복구 불가능한 오류 |
| `WARN` | 비즈니스 예외, 복구 가능한 오류 |
| `INFO` | 주요 실행 흐름 (시작/종료) |
| `DEBUG` | 상세 디버깅 정보 |

### 8.3 로그 포맷
```java
// 시작/종료 로그
log.info(FwPool.COMP_START_LOG);
log.info(FwPool.COMP_END_LOG);

// 파라미터 포함
log.debug("처리 건수: {}", reqList.size());

// 에러 로그
log.error("에러 발생: {}", e.getMessage(), e);
```

## 9. 유효성 검사

### 9.1 @SifValid 어노테이션 속성
| 속성 | 설명 | 예시 |
|------|------|------|
| `isCheckEmpty` | Null 허용 여부 (true=필수) | `@SifValid` (기본값 true) |
| `isCheckDate` | 날짜 형식 검사 | `@SifValid(isCheckDate = true)` |
| `ableValues` | 허용 값 목록 | `@SifValid(ableValues = {"Y", "N"})` |
| `length` | 길이 검사 | `@SifValid(length = 10)` |

### 9.2 유효성 검사 순서
1. `checkSifValids()`: @SifValid 어노테이션 기반 검사
2. `checkFormat()`: DB 컬럼 타입/크기 기반 검사
3. 업무 규칙 검사 (`checkRegisterdIfProdId()` 등)

## 10. 배치 이력 관리

### 10.1 배치 상태 코드
```java
String IF_STATUS_RUNNING = "RUN"; // 진행중
String IF_STATUS_SUCCESS = "OK"; // 성공
String IF_STATUS_ERROR = "NG"; // 실패
```

### 10.2 처리 결과 코드
```java
String BIZ_PROCESS_SUCCESS = "OK"; // 성공
String BIZ_PROCESS_ERROR = "NG"; // 실패
String BIZ_PROCESS_ERROR_EXCEPT = "NG-EXCEPT"; // 제외
```

## 11. 테스트 코드 규칙

### 11.1 테스트 클래스 명명
- `ZTEST_{TargetClass}` 형식 사용
- 예: `ZTEST_E2WProdRegComp`, `ZTEST_E2WProdRegDao`

### 11.2 테스트 메서드 명명
```java
@Test
@DisplayName("품목 등록 - 성공")
public void test_rcvSifProd_insert_success()

@Test
@DisplayName("품목 등록 - 중복 오류")
public void test_rcvSifProd_duplicate_prodNo()
```

### 11.3 테스트 어노테이션
```java
@Order(10) // 실행 순서
@DisplayName("설명")
@WithMockCustomUser(regBizSeq = 10, loginUserId = "testuser")
@Transactional // 실제 DB 영향 확인시 주석 처리
```

## 12. 주석 규칙

### 12.1 클래스 주석
```java
/**
* 품목 정보 I/F 수신 컴포넌트
*
* <pre>
* ERP → WMS 품목 등록 인터페이스 처리
* 1. 배치 이력 등록
* 2. 데이터 유효성 검사
* 3. 업무 로직 처리
* 4. 배치 이력 업데이트
* </pre>
*
* @author yskim
* @version 1.0
*/
```

### 12.2 메서드 주석
```java
/**
* 품목 정보 I/F 수신
*
* @param requestBody 요청 데이터 (E2WAbcRequestBody<E2WProdRegReq>)
* @param responseBody 응답 데이터 (E2WAbcResponseBody<E2WProdRegRes>)
*/
public void e2wProcess(E2WAbcRequestBody<E2WProdRegReq> requestBody,
                      E2WAbcResponseBody<E2WProdRegRes> responseBody)
```

### 12.3 복잡한 로직 주석
```java
// 1. 에러가 있는 헤더만 필터링
// 2. 에러 키(String) 추출
// 3. 콤마로 연결
return responseBody.getResList().stream()
    .filter(header -> E2WAbcPool.BIZ_PROCESS_ERROR.equals(header.getResult()))
    .map(E2WAbcRes::getErrKey)
    .collect(Collectors.joining(StringPool.COMMA));
```

## 13. 포맷팅 규칙

### 13.1 Import 순서
1. java 패키지
2. javax 패키지
3. org.springframework
4. fw 패키지 (프레임워크)
5. sif 패키지 (프로젝트)
6. lombok
7. static import

### 13.2 공백 및 들여쓰기
- 들여쓰기: 4 spaces (tab 사용 금지)
- 중괄호 스타일: K&R 스타일 (줄바꿈 후 열기)
- 메서드 간: 1줄 공백
- import 간: 그룹별 1줄 공백

## 14. 제네릭 명명 규칙

| 문자 | 의미 |
|------|------|
| `H` | Header (요청 헤더) |
| `D` | Detail (상세 품목) |
| `T` | Type (응답 타입) |
| `S` | Response (응답) |
| `H extends E2WAbcReq<?>` | 요청 헤더 제네릭 |

예시:
```java
public <H extends E2WAbcReq<?>, S extends E2WAbcRes> void checkDupIf(
    E2WAbcRequestBody<H> requestBody, 
    E2WAbcResponseBody<S> responseBody)
```
