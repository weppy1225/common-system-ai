---
title: Dao 작성규칙
description: {MenuCode}Dao 클래스 선언·CRUD 메서드 패턴·반환 타입 규칙·EmptyTool 활용 코드 예시를 코드 작성 시 참조
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: backend
tags:
  - dao
  - mapper
  - crud
  - logging
  - emptytool
related:
  - patterns/30-backend/30-convention/01-coding-convention.md
  - patterns/30-backend/40-guide/04-mapper-writing-rules.md
last_verified: 2026-04-07
---

# Dao 작성규칙 ({MenuCode}Dao Writing Rules)

> **규칙 참조**: 클래스 어노테이션·메서드 네이밍·예외 처리 등 일반 규칙은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 Dao 레이어 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **클래스명**: `{메뉴코드}Dao`
- **역할**: 데이터 접근 계층, MyBatis Mapper 위임 + 로깅
- **계층**: TxComp → **Dao** → Mapper

## 2. 클래스 선언 예시

```java
@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Dao {
    private final {메뉴코드}Mapper mapper;
}
```

## 3. 메서드 기본 구조

```java
/**
 * 한 줄 설명
 *
 * @param param 파라미터 설명
 * @return 반환값 설명
 */
public 반환타입 methodName(파라미터...) {
    log.info(FwPool.DAO_START_LOG);

    반환타입 result = mapper.methodName(파라미터);

    log.info(FwPool.DAO_END_LOG);
    return result;
}
```

## 4. CRUD 패턴 예시

### 4.1 조회 (SELECT)

```java
// 단일 조회
public {메뉴코드}Prod selectProd(Integer loginBizSeq, Integer prodSeq) {
    log.info(FwPool.DAO_START_LOG);
    {메뉴코드}Prod retProd = mapper.selectProd(loginBizSeq, prodSeq);
    log.info(FwPool.DAO_END_LOG);
    return retProd;  // null 가능
}

// 목록 조회
public List<{메뉴코드}Search> searchProds({메뉴코드}Search searchProd) {
    log.info(FwPool.DAO_START_LOG);
    List<{메뉴코드}Search> retList = mapper.searchProds(searchProd);
    log.info(FwPool.DAO_END_LOG);
    return retList;  // 빈 리스트 가능
}

// 존재 여부
public boolean checkProd(Integer prodSeq) {
    log.info(FwPool.DAO_START_LOG);
    boolean result = mapper.checkProd(prodSeq);
    log.info(FwPool.DAO_END_LOG);
    return result;
}
```

### 4.2 등록 (INSERT) — 복수 Mapper 조합 예

```java
public int insertProd({메뉴코드}Prod insertProd) {
    log.info(FwPool.DAO_START_LOG);

    int retCnt = mapper.insertProd(insertProd);
    retCnt += mapper.insertBizProd(insertProd); // 사업장 매핑 동시 등록

    log.info(FwPool.DAO_END_LOG);
    return retCnt;
}
```

### 4.3 수정 (UPDATE) — 복수 테이블 동시 갱신

```java
public int updateProd({메뉴코드}Prod updateProd) {
    log.info(FwPool.DAO_START_LOG);

    int retCnt = mapper.updateProd(updateProd);
    mapper.updateBizProd(updateProd);

    log.info(FwPool.DAO_END_LOG);
    return retCnt;
}
```

### 4.4 삭제 (DELETE) — 복수 Mapper 조합

```java
// ❌ 잘못된 예: Dao에서 참조 무결성·상태 검증 같은 비즈니스 규칙을 판단하지 않는다.
// Dao는 복수 Mapper 단순 조합만 허용한다.
public int deleteProds(Integer bizSeq, List<Integer> prodSeqs) {
    log.info(FwPool.DAO_START_LOG);
    int retCnt = 0;

    retCnt = mapper.deleteBizProds(bizSeq, prodSeqs);
    if (EmptyTool.notEmpty(prodSeqs)) {
        mapper.deleteProds(bizSeq, prodSeqs);
    }

    log.info(FwPool.DAO_END_LOG);
    return retCnt;
}
```

### 4.5 중복 체크

```java
public List<ValidError> checkDuplicateProdNo(Integer bizSeq, Integer prodSeq, List<String> prodNos) {
    log.info(FwPool.DAO_START_LOG);
    List<ValidError> retErrorList = mapper.checkDuplicateProdNo(bizSeq, prodSeq, prodNos);
    log.info(FwPool.DAO_END_LOG);
    return retErrorList;
}
```

## 5. 반환 타입 규칙

| 반환 타입 | 규칙 | 예시 |
|-----------|------|------|
| `List<T>` | null 반환 금지, 빈 리스트 반환 | `searchProds()` |
| `T` (단일 객체) | null 가능 (상위에서 처리) | `selectProd()` |
| `int` | 처리 건수 (0 이상) | `insertProd()`, `updateProd()`, `deleteProds()` |
| `boolean` | true/false | `checkProd()` |
| `List<ValidError>` | 중복 항목만 포함, 없으면 빈 리스트 | `checkDuplicateProdNo()` |

## 6. EmptyTool 활용 예

```java
// 조회 결과 필터링
if (EmptyTool.notEmpty(searchProds)) {
    prodSeqs.removeAll(searchProds);
}

// 삭제 조건 체크
if (EmptyTool.notEmpty(prodSeqs)) {
    mapper.deleteProds(bizSeq, prodSeqs);
}
```

## 7. Mapper 호출 시 파라미터 전달

```java
// 단일 파라미터: @Param 생략 가능
mapper.selectProd(search);

// 다중 파라미터: Mapper 측 @Param 선언 필수, Dao는 순서대로 전달
mapper.selectProd(loginBizSeq, prodSeq);
mapper.checkDuplicateProdNo(bizSeq, prodSeq, prodNos);
```

> `@Param` 사용 규칙은 컨벤션 §6 및 [04-mapper-writing-rules.md](04-mapper-writing-rules.md) §3 참조.

## 8. 계층별 데이터 흐름

```
Controller → Comp → TxComp → Dao → Mapper(MyBatis) → DB
```

## 9. 작성 시 주의사항

1. **null 반환 금지**: List 반환 메서드는 항상 빈 리스트. 상위 계층이 null 분기 없이 순회·후처리할 수 있어야 한다.
2. **예외 전파**: Dao는 예외를 잡지 않고 상위로 전파. 예외 변환 책임은 Comp에 있다.
3. **트랜잭션 경계**: TxComp에서 관리, Dao는 단순 실행. 동일 SQL 조합도 트랜잭션 판단은 Dao가 하지 않는다.
4. **비즈니스 로직 금지**: 복잡한 규칙은 Comp 계층에서 처리. Dao는 DB 접근과 결과 반환에 집중한다.
5. **로깅 필수**: 메서드 시작/종료에 `FwPool.DAO_START_LOG` / `DAO_END_LOG`
