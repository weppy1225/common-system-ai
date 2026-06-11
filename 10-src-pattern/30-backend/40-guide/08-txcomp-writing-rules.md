---
title: TxComp 작성규칙
description: {MenuCode}TxComp 클래스 선언·@Transactional 메서드 패턴·파일 처리 매트릭스·InvenManager 호출 코드 예시를 작성 시 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: backend
tags:
  - txcomp
  - transactional
  - file-handling
  - inven-manager
  - docno
related:
  - 10-src-pattern/30-backend/40-guide/06-comp-writing-rules.md
last_verified: 2026-04-07
---

# TxComp 작성규칙 (TxComp Writing Rules)

> **규칙 참조**: `@Transactional` 사용 위치·Comp/TxComp 분리 기준·예외 처리 일반 규칙은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 TxComp 레이어 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **클래스명**: `{메뉴코드}TxComp`
- **역할**: 트랜잭션 경계, DB Write 메서드, 파일 처리 통합
- **계층**: Comp → **TxComp** → Dao
- **트랜잭션**: TxComp 메서드 레벨 `@Transactional`만 허용 (클래스 레벨 및 Comp/Dao/Controller 선언 금지). 기존 코드에 다른 레이어 선언이 남아 있으면 미준수 레거시로 보고, 해당 업무 수정 시 TxComp로 이동한다.

## 2. 클래스 선언 예시

```java
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Slf4j
public class {메뉴코드}TxComp {
    private final {메뉴코드}Dao      {메뉴코드_인스턴스}Dao;
    private final {메뉴코드}CompUtil {메뉴코드_인스턴스}CompUtil;
    private final FileComp           fileComp;
}
```

### 주요 import

```java
import fw.exception.warn.ZinNotFoundException;
import fw.exception.warn.AlreadyProcessException;
```

## 3. 메서드 작성 패턴

### 3.1 등록 (insert{리소스}TX)

```java
/**
 * {리소스} 등록 트랜잭션 (파일 업로드 + DB 저장)
 *
 * @param put{리소스} 등록 요청 DTO
 * @param file       첨부 파일 (없으면 null)
 * @return 처리 건수
 */
@Transactional
public int insert{리소스}TX({메뉴코드}{리소스} put{리소스}, MultipartFile file) {
    // 1. 파일 처리
    if (EmptyTool.notEmpty(file)) {
        FileDTO fileData = {메뉴코드_인스턴스}CompUtil.makeFileData(put{리소스}, file);
        FileResponse rtnData = fileComp.uploadFile(fileData);
        put{리소스}.setFileSeq(rtnData.getFile().getFileSeq());
    }

    // 2. DB 등록
    return {메뉴코드_인스턴스}Dao.insert{리소스}(put{리소스});
}
```

### 3.2 수정 (update{리소스}TX) — 파일 처리 매트릭스

| newFile | patch{리소스}.getFileSeq() | ex{리소스}FileSeq | 처리 |
|---------|------------------------|-----------|------|
| NULL | NULL | NULL | 단순 DB 수정 |
| NULL | 값 있음 | 값 있음 | 단순 DB 수정 |
| NULL | NULL | 값 있음 | 파일 삭제 + file_seq 초기화 |
| 값 있음 | NULL | NULL | 파일 추가 + file_seq 설정 |
| 값 있음 | NULL | 값 있음 | 기존 삭제 + 신규 추가 |
| 값 있음 | 값 있음 | 값 있음 | 기존 삭제 + 신규 추가 |

```java
@Transactional
public int update{리소스}TX({메뉴코드}{리소스} patch{리소스},
                          MultipartFile newFile,
                           Integer ex{리소스}FileSeq) {

    if (EmptyTool.notEmpty(newFile)) {
        if (EmptyTool.notEmpty(ex{리소스}FileSeq)) {
            fileComp.deleteFileProdImg(patch{리소스}.getBizSeq(), ex{리소스}FileSeq);
        }
        this.addFile(patch{리소스}, newFile);
    } else {
        if (EmptyTool.empty(patch{리소스}.getFileSeq()) && EmptyTool.notEmpty(ex{리소스}FileSeq)) {
            fileComp.deleteFileProdImg(patch{리소스}.getBizSeq(), ex{리소스}FileSeq);
            patch{리소스}.setFileSeq(null);
        }
    }

    int retCnt = {메뉴코드_인스턴스}Dao.update{리소스}(patch{리소스});

    if (retCnt == 0) {
        throw new ZinNotFoundException(
            MsgTool.getMsgParam("message.warn.NotFoundWithParam", patch{리소스}.get{리소스}Seq())
        );
    }
    return retCnt;
}
```

### 3.3 삭제 (delete{리소스}sTX)

```java
@Transactional
public int delete{리소스}sTX(Integer bizSeq, List<Integer> {리소스}Seqs) {

    // 1. 파일 정보 조회
    List<{메뉴코드}{리소스}> searchFileList =
        {메뉴코드_인스턴스}Dao.get{리소스}FileUuids({리소스}Seqs);

    // 2. 파일 삭제
    if (EmptyTool.notEmpty(searchFileList)) {
        List<FileDTO> deleteFileList = new ArrayList<>();
        for ({메뉴코드}{리소스} deleteFile : searchFileList) {
            deleteFileList.add({메뉴코드_인스턴스}CompUtil.makeFileData(deleteFile));
        }
        fileComp.deleteFile(bizSeq, deleteFileList);
    }

    // 3. DB 삭제
    int retCnt = {메뉴코드_인스턴스}Dao.delete{리소스}s(bizSeq, {리소스}Seqs);

    // 4. 결과 검증
    if (retCnt == 0 || retCnt < {리소스}Seqs.size()) {
        throw new AlreadyProcessException(MsgTool.getMsg("message.warn.AlreadyProcess"));
    }
    return retCnt;
}
```

## 4. 파일 처리 헬퍼 예시

### 4.1 파일 업로드

```java
private Integer addFile({메뉴코드}{리소스} patch{리소스}, MultipartFile file) {
    log.info(FwPool.COMP_START_LOG);

    FileDTO fileData = {메뉴코드_인스턴스}CompUtil.makeFileData(patch{리소스}, file);
    FileResponse rtnData = fileComp.uploadFile(fileData);

    Integer fileSeq = rtnData.getFile().getFileSeq();
    patch{리소스}.setFileSeq(fileSeq);

    log.info(FwPool.COMP_END_LOG);
    return fileSeq;
}
```

### 4.2 파일 삭제

```java
// 단일
fileComp.deleteFileProdImg(patch{리소스}.getBizSeq(), exFileSeq);

// 다건
List<FileDTO> deleteFileList = new ArrayList<>();
for ({메뉴코드}{리소스} deleteFile : searchFileList) {
    deleteFileList.add({메뉴코드_인스턴스}CompUtil.makeFileData(deleteFile));
}
fileComp.deleteFile(bizSeq, deleteFileList);
```

## 5. 결과 검증 패턴

| 상황 | 예외 | 메시지 키 |
|------|------|-----------|
| 수정할 데이터 없음 | `ZinNotFoundException` | `message.warn.NotFoundWithParam` |
| 삭제 실패 / 부분 삭제 | `AlreadyProcessException` | `message.warn.AlreadyProcess` |

```java
if (retCnt == 0) {
    throw new ZinNotFoundException(
        MsgTool.getMsgParam("message.warn.NotFoundWithParam", patch{리소스}.get{리소스}Seq())
    );
}

if (retCnt == 0 || retCnt < {리소스}Seqs.size()) {
    throw new AlreadyProcessException(MsgTool.getMsg("message.warn.AlreadyProcess"));
}
```

## 6. EmptyTool / CompUtil 활용 예

```java
EmptyTool.notEmpty(file)
EmptyTool.notEmpty(exFileSeq)
EmptyTool.empty(patch{리소스}.getFileSeq())
EmptyTool.notEmpty(searchFileList)

{메뉴코드_인스턴스}CompUtil.makeFileData(put{리소스}, file)
{메뉴코드_인스턴스}CompUtil.makeFileData(deleteFile)
```

## 7. 로깅 예시

```java
log.info(FwPool.COMP_START_LOG);
// 로직
log.info(FwPool.COMP_END_LOG);
```

## 8. 메서드 시그니처 패턴

```java
// 등록
int insert{리소스}TX({메뉴코드}{리소스} put{리소스}, MultipartFile file)

// 수정
int update{리소스}TX({메뉴코드}{리소스} patch{리소스},
                   MultipartFile newFile,
                   Integer ex{리소스}FileSeq)

// 삭제
int delete{리소스}sTX(Integer bizSeq, List<Integer> {리소스}Seqs)
```

> **트랜잭션 메서드 접미사**: 기본 예시는 `TX`로 통일한다. 기존 메뉴가 `Tx`를 이미 사용 중이면 메뉴 단위 일관성을 우선한다. 컨벤션 §8 참조.

## 9. 컴포넌트 협력 관계

```
{메뉴코드}Comp (비즈니스)
    ↓
{메뉴코드}TxComp (트랜잭션) ← → FileComp (파일)
    ↓
{메뉴코드}Dao (DB)
```

## 10. 주의사항

1. **파일과 DB는 동일 트랜잭션**: 파일 업로드 성공 → DB 저장, 실패 시 전체 롤백
2. **부분 성공 방지**: 다건 삭제는 모두 성공 또는 모두 실패
3. **메서드 단위 `@Transactional`**: 클래스 레벨 및 Comp/Dao/Controller 선언 금지. 기존 미준수 코드는 수정 대상 파일 작업 시 TxComp 메서드로 이동한다.
4. **InvenManager / DocNoGenerator 호출은 TxComp에서만**: 상세는
   `.claude/rules/biz-framework.md` 참조
