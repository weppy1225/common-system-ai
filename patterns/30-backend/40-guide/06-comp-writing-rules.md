---
title: Comp 작성규칙
description: {MenuCode}Comp 클래스 선언·CRUD 메서드 패턴·유효성 검증·TxComp 호출 코드 예시를 코드 작성 시 참조
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: backend
tags:
  - comp
  - business-logic
  - exception-handling
  - txcomp
  - validation
related:
  - patterns/30-backend/30-convention/01-coding-convention.md
  - patterns/30-backend/40-guide/08-txcomp-writing-rules.md
last_verified: 2026-04-07
---

# Comp 작성규칙 ({MenuCode}Comp Writing Rules)

> **규칙 참조**: 클래스 어노테이션·예외 처리·메서드 네이밍·이력 컬럼 등 일반 규칙은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 Comp 레이어 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **클래스명**: `{메뉴코드}Comp`
- **역할**: 비즈니스 로직 처리, 유효성 검증, 예외 변환, 트랜잭션 위임(TxComp 호출)
- **계층**: Controller → **Comp** → TxComp / Dao

## 2. 클래스 선언 예시

```java
@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Comp {
    private final {메뉴코드}TxComp   {메뉴코드_인스턴스}TxComp;
    private final {메뉴코드}Dao      {메뉴코드_인스턴스}Dao;
    private final {메뉴코드}CompUtil {메뉴코드_인스턴스}CompUtil;
}
```

### 주요 import 예시

```java
import fw.bean.ResponseData;            // {메뉴코드}Response 상위
import fw.bean.BaseParam;                // {메뉴코드}Search 상위
import fw.exception.CompWarnException;
import fw.exception.ResponseWarnException;
import fw.exception.ResponseErrorException;
```

## 3. 메서드 공통 구조 템플릿

```java
/**
 * 한 줄 설명
 *
 * @param param 파라미터 설명
 * @return 처리 결과
 */
public {메뉴코드}Response methodName(파라미터...) {
    log.info(FwPool.COMP_START_LOG);

    {메뉴코드}Response result = new {메뉴코드}Response();
    int retCnt = 0;

    try {
        // 1. 유효성 검증 (CompUtil 또는 Dao 호출)
        validateSomething();

        // 2. 비즈니스 로직 / TxComp 호출
        retCnt = {메뉴코드_인스턴스}TxComp.methodNameTx(...);

        // 3. 결과 세팅
        result.setXxx(...);

    } catch (CompWarnException e) {
        log.error("methodName warn~~~", e);
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        log.error("methodName error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    } finally {
        result.setProcCnt(retCnt);
    }

    log.info(FwPool.COMP_END_LOG);
    return result;
}
```

> **규칙**: try 블록은 가급적 5줄 이내로 유지한다. 복잡한 로직은 CompUtil 또는 private 메서드로 분리한다.

## 4. CRUD 패턴 예시

### 4.1 검색

```java
public {메뉴코드}Response search{리소스}s({메뉴코드}Search search) {
    log.info(FwPool.COMP_START_LOG);

    {메뉴코드}Response result = new {메뉴코드}Response();
    List<{메뉴코드}Search> rtnList = new ArrayList<>();
    try {
        rtnList = {메뉴코드_인스턴스}Dao.search{리소스}s(search);
    } catch (Exception e) {
        log.error("search{리소스}s error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    }
    result.setPost{리소스}s(rtnList);

    log.info(FwPool.COMP_END_LOG);
    return result;
}
```

### 4.2 등록

```java
public {메뉴코드}Response insert{리소스}({메뉴코드}{리소스} put{리소스}, MultipartFile file) {
    {메뉴코드}Response result = new {메뉴코드}Response();
    int retCnt = 0;
    try {
        // 1. 중복 체크
        checkDuplicate{리소스}No(put{리소스}.getBizSeq(), null, put{리소스}.get{리소스}No());

        // 2. 공통 필드 세팅 (CompUtil 위임 권장)
        put{리소스}.setRegId(TokenTool.getLoginUserId());
        put{리소스}.setRegDt(DateTool.now());

        // 3. 트랜잭션 처리 위임
        retCnt = {메뉴코드_인스턴스}TxComp.insert{리소스}Tx(put{리소스}, file);

    } catch (CompWarnException e) {
        log.error("insert{리소스} warn~~~", e);
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        log.error("insert{리소스} error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    } finally {
        result.setProcCnt(retCnt);
    }
    return result;
}
```

### 4.3 수정

```java
public {메뉴코드}Response update{리소스}({메뉴코드}{리소스} patch{리소스}, MultipartFile file) {
    // ... try 블록 ...
    {메뉴코드}{리소스} ex{리소스} = {메뉴코드_인스턴스}Dao.select{리소스}(...);

    String errMsg = validateUpdate{리소스}(patch{리소스}, ex{리소스});
    if (EmptyTool.notEmpty(errMsg)) {
        throw new NotMeetConditionsException(errMsg);
    }

    retCnt = {메뉴코드_인스턴스}TxComp.update{리소스}TX(patch{리소스}, file, ex{리소스}.getFileSeq());
    // ...
}
```

### 4.4 삭제

```java
public {메뉴코드}Response delete{리소스}s(Integer bizSeq, List<Integer> {리소스}Seqs) {
    // ... try 블록 ...
    for (Integer {리소스}Seq : {리소스}Seqs) {
        {메뉴코드}{리소스} checkResult =
            {메뉴코드_인스턴스}Dao.check{리소스}SeqInOtherTbl(bizSeq, {리소스}Seq);
        if (checkResult != null) {
            String errMsg = /* 미확인: 실제 MsgTool 키는 메뉴 소스에서 확인 후 적용 */ "참조 데이터가 존재합니다.";
            throw new NotMeetConditionsException(errMsg);
        }
    }
    retCnt = {메뉴코드_인스턴스}TxComp.delete{리소스}sTX(bizSeq, {리소스}Seqs);
    // ...
}
```

## 5. 유효성 검증 패턴

### 5.1 중복 체크

```java
private void checkDuplicate{리소스}No(Integer bizSeq, Integer seq, String no) {
    List<ValidError> dupList = {메뉴코드_인스턴스}Dao.checkDuplicate{리소스}No(
        bizSeq, seq, Collections.singletonList(no)
    );
    if (!dupList.isEmpty()) {
        String errMsg = /* 미확인: 실제 MsgTool 키는 메뉴 소스에서 확인 후 적용 */ "중복 데이터가 존재합니다.";
        throw new ZinExistDataException(errMsg);
    }
}
```

### 5.2 참조 무결성 체크

```java
private String checkProdLabelAndProc({메뉴코드}{리소스} existProd, {메뉴코드}{리소스} updateProd) {
    if (existProd.getProdNo().equals(updateProd.getProdNo())) {
        return null;
    }
    boolean isAlreadyProc = {메뉴코드_인스턴스}Dao.checkProdLabelAndProc(prodSeq);
    return isAlreadyProc
        ? MsgTool.getMsg("message.{메뉴그룹_인스턴스}.{메뉴코드_인스턴스}.ExistInoutOrLabel")
        : null;
}
```

## 6. 데이터 가공 예시

### 6.1 파일 경로 → URL 변환

```java
if (EmptyTool.notEmpty(rtn{리소스}.getFileSeq())) {
    rtn{리소스}.setFilePath(FileTool.changeFilePathToUrl(
        rtn{리소스}.getFilePath(),
        rtn{리소스}.getFileUuid(),
        rtn{리소스}.getFileExtension()
    ));
}
```

### 6.2 이력 컬럼 세팅 (CompUtil 위임 권장)

```java
put{리소스}.setRegId(TokenTool.getLoginUserId());
put{리소스}.setRegDt(DateTool.now());
patch{리소스}.setModId(TokenTool.getLoginUserId());
patch{리소스}.setModDt(DateTool.now());
```

> 3개 이상 반복되거나 다른 초기화 로직이 있으면 `{메뉴코드}CompUtil.makeInsert{리소스}()` 등으로 분리.

## 7. 응답 객체 사용 예

| 메서드 | 용도 | 사용처 |
|--------|------|---------|
| `setPost{리소스}s()` | 검색 결과 목록 | 검색 |
| `set{리소스}()` | 단건 조회 결과 | 단건 조회 |
| `setProcCnt()` | 처리 건수 | insert/update/delete |
| `setWarn()` | 경고 예외 | catch(CompWarnException) |
| `setSystemError()` | 시스템 예외 | catch(Exception) |

## 8. TxComp 호출 예

```java
// 단일 트랜잭션
retCnt = {메뉴코드_인스턴스}TxComp.insert{리소스}Tx(put{리소스}, file);

// 파일 포함 트랜잭션
retCnt = {메뉴코드_인스턴스}TxComp.update{리소스}TX(patch{리소스}, file, ex{리소스}.getFileSeq());

// 다건 삭제 트랜잭션
retCnt = {메뉴코드_인스턴스}TxComp.delete{리소스}sTX(bizSeq, {리소스}Seqs);
```

## 9. 자주 쓰는 유틸 호출

```java
EmptyTool.empty(obj) / EmptyTool.notEmpty(obj)
MsgTool.getMsg("message.code")
MsgTool.getMsgParam("message.code", param)
DateTool.now() / DateTool.getYmd()
TokenTool.getLoginUserId() / TokenTool.getRegBizSeq()
```

## 10. 검증 실패 시 throw 예시

```java
throw new ZinNotFoundException(MsgTool.getMsg("message.warn.NotFound"));
throw new ZinExistDataException(errMsg);
throw new NotMeetConditionsException(errMsg);
```

## 11. 로깅 예시

```java
log.info(FwPool.COMP_START_LOG);
log.info(FwPool.COMP_END_LOG);
log.error("methodName warn~~~", e);   // CompWarnException
log.error("methodName error~~~", e);  // Exception
```
