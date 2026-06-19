---
title: CompUtil 작성규칙
description: {MenuCode}CompUtil 클래스 선언·검증/변환/초기화/상태체크 메서드 패턴 코드 예시를 코드 작성 시 참조
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: backend
tags:
  - computil
  - helper
  - validation
  - dto-builder
  - make
related:
  - patterns/30-backend/40-guide/06-comp-writing-rules.md
last_verified: 2026-04-07
---

# CompUtil 작성규칙 (CompUtil Writing Rules)

> **규칙 참조**: 클래스 어노테이션·CompUtil 생성 판단 기준은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 CompUtil 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **클래스명**: `{메뉴코드}CompUtil`
- **역할**: Comp 계층의 헬퍼. DTO 초기화·이력 컬럼 세팅·복합 검증·데이터 가공·재사용 가능한 비즈니스 로직 모음
- **계층**: Comp / TxComp가 사용하는 유틸 컴포넌트 (`@Service`)

## 2. 클래스 선언 예시

```java
@Service
public class {메뉴코드}CompUtil {
    private static final Object EMPTY_OBJECT = new Object(); // null 비교용 더미
}
```

## 3. 메서드 유형별 코드 패턴

### 3.1 유효성 검증 (`is` / `validate`)

```java
/**
 * 라벨 용지 타입 코드 유효성 검사
 *
 * @param labelPaperTypeCd 검사할 코드값
 * @return 유효하면 true
 */
public boolean isValidCd(String labelPaperTypeCd) {
    boolean hasCd = false;
    WMSPool.labelPaperType[] labelPaperTypes = WMSPool.labelPaperType.values();

    for (WMSPool.labelPaperType labelPaperType : labelPaperTypes) {
        hasCd = labelPaperType.hasLabelPaperType(labelPaperTypeCd);
        if (hasCd) break;
    }
    return hasCd;
}

// 복합 검증 (성공: null, 실패: 에러메시지)
public String validatePrintLabel(List<{메뉴코드}Prod> printDataList,
                                 {메뉴코드}PrintLabel printLabel,
                                 String labelPaperTypeCd) {
    List<String> notDesignLabelList = new ArrayList<>();
    List<String> emptyBarcodeList   = new ArrayList<>();
    List<String> diffLabelList      = new ArrayList<>();

    // 검증 로직...

    if (!notDesignLabelList.isEmpty()) {
        return MsgTool.getMsgParam("message.md8000.mdpd01.NotExistLabelPaper", ...);
    }
    if (!emptyBarcodeList.isEmpty()) {
        return MsgTool.getMsgParam("message.md8000.mdpd01.NotExistBarcode", ...);
    }
    if (!diffLabelList.isEmpty()) {
        return MsgTool.getMsgParam("message.md8000.mdpd01.hasDiffLabelPapaer", ...);
    }
    return null;
}
```

### 3.2 데이터 변환/가공 (`make`)

```java
// 삭제용 FileDTO 생성
public FileDTO makeFileData({메뉴코드}Prod prod) {
    FileDTO fileData = new FileDTO();
    fileData.setBizSeq(prod.getBizSeq());
    fileData.setFileUuid(prod.getFileUuid());
    fileData.setFileDivCd(FileComp.PROD_IMG);
    fileData.setFileExtension(prod.getFileExtension());
    fileData.setDispNo(1);
    return fileData;
}

// 등록용 FileDTO 생성 (파일 포함)
public FileDTO makeFileData({메뉴코드}Prod putProd, MultipartFile file) {
    FileDTO fileData = new FileDTO();
    fileData.setBizSeq(putProd.getBizSeq());
    fileData.setFileUuid(putProd.getFileUuid());
    fileData.setFileExtension(putProd.getFileExtension());
    fileData.setFileDivCd(FileComp.PROD_IMG);
    fileData.setRegId(putProd.getRegId());
    fileData.setDispNo(1);
    fileData.setMultipartFile(file);
    return fileData;
}

// 응답 객체 빌드
public {메뉴코드}PrintLabel makePrintLabelRes(List<{메뉴코드}Prod> printDataList,
                                            {메뉴코드}PrintLabel printLabel) {
    String labelTypeDivCd = WMSPool.labelPaperType
        .getLabelDivCdForLabelType(printDataList.get(0).getLabelPaperTypeCd());

    printLabel.setLabelPaperDivCd(labelTypeDivCd);
    printLabel.setLabelPaperTypeCd(printDataList.get(0).getLabelPaperTypeCd());
    printLabel.setLabelTypeSeq(printDataList.get(0).getLabelPaperSeq());
    printLabel.setBarcodeType(printDataList.get(0).getBarcodeType());
    printLabel.setLabelData(printDataList);
    return printLabel;
}
```

### 3.3 컬럼 초기화 (`reset`)

```java
public void resetSkuMngSku({메뉴코드}Prod patchProd) {
    patchProd.setMngYmdMngYn(StringPool.N);
    patchProd.setEffMngYn(StringPool.N);
    patchProd.setEffBase(0);
    patchProd.setEffBaseUnitCd(WMSPool.EFF_BASE_DAYS);
    patchProd.setLotNoMngYn(StringPool.N);
    patchProd.setSku2MngYn(StringPool.N);
    patchProd.setPalletStackQty(1);
    patchProd.setPalletBottomQty(1);
}
```

### 3.4 상태 체크 (`chk`) — Function 리스트 패턴

```java
public String chkUpdWesSndYn({메뉴코드}Prod oldProd, {메뉴코드}Prod newProd) {
    List<Function<{메뉴코드}Prod, Object>> fncList = new ArrayList<>();

    fncList.add({메뉴코드}Prod::getProdNm);
    fncList.add({메뉴코드}Prod::getNetWeight);
    fncList.add({메뉴코드}Prod::getProdBarcode);
    fncList.add({메뉴코드}Prod::getInQtyPack);
    fncList.add({메뉴코드}Prod::getUnitCd);
    fncList.add({메뉴코드}Prod::getLenX);
    fncList.add({메뉴코드}Prod::getLenY);
    fncList.add({메뉴코드}Prod::getLenZ);

    for (Function<{메뉴코드}Prod, Object> fnc : fncList) {
        Object o1 = fnc.apply(oldProd) != null ? fnc.apply(oldProd) : EMPTY_OBJECT;
        Object o2 = fnc.apply(newProd) != null ? fnc.apply(newProd) : EMPTY_OBJECT;
        if (!o1.equals(o2)) {
            return StringPool.N; // 변경 발생 → WES 재전송 필요
        }
    }
    return null;
}
```

## 4. 메서드 명명 규칙

| 접두사 | 용도 | 예시 |
|--------|------|------|
| `is` | boolean 반환 검증 | `isValidCd()` |
| `make` | DTO/객체 생성 | `makeFileData()`, `makePrintLabelRes()` |
| `makeInsertXxx` / `makeUpdateXxx` | 등록·수정용 DTO 조립 (이력 컬럼 세팅 포함) | `makeInsertProd()` |
| `reset` | 값 초기화 | `resetSkuMngSku()` |
| `validate` | 복합 검증 (에러 메시지 반환) | `validatePrintLabel()` |
| `chk` | 상태 체크 (Y/N/null) | `chkUpdWesSndYn()` |
| `get` | 값 조회/계산 | `getBarcodeValueByLabelType()` |

> `chk` 접두사는 CompUtil 내부의 상태 비교 헬퍼에 한해 허용한다. 일반 공개 검증 메서드 네이밍은 컨벤션 §8의 `check` / `validate` 기준을 따른다.

## 5. null 안전 처리 패턴

```java
// null을 더미 객체로 대체하여 비교: null/null 과 값/null 비교를 동일 루프로 처리하기 위함
Object o1 = fnc.apply(oldProd) != null ? fnc.apply(oldProd) : EMPTY_OBJECT;
Object o2 = fnc.apply(newProd) != null ? fnc.apply(newProd) : EMPTY_OBJECT;

// EmptyTool 사용
if (EmptyTool.empty(barcodeValue)) {
    return tmpProd.getProdNm();
}
```

## 6. switch 분기 예시

```java
private String getBarcodeValueByLabelType({메뉴코드}Prod prod, String labelPaperTypeCd) {
    switch (labelPaperTypeCd) {
    case WMSPool.LABEL_TYPE_PROD_BOX:
        return prod.getParentBarcode();
    case WMSPool.LABEL_TYPE_PROD_GOODS:
        return prod.getProdBarcode();
    default:
        return prod.getProdNo();
    }
}
```

## 7. 자주 쓰는 상수

```java
StringPool.Y / StringPool.N / StringPool.COMMA
WMSPool.EFF_BASE_DAYS
WMSPool.LABEL_TYPE_PROD_BOX / LABEL_TYPE_PROD_GOODS
WMSPool.labelPaperType.values()
FileComp.PROD_IMG
```

## 8. 메서드 책임 분리 예시

```java
// 외부 노출
public {메뉴코드}PrintLabel makePrintLabelRes(...) { ... }

// 내부 전용 (private)
private String makePrintLabelProd(...) { ... }
private String getBarcodeValueByLabelType(...) { ... }
```

## 9. 반환값 규칙 표

| 메서드 유형 | 반환값 규칙 | 예시 |
|------------|------------|------|
| 단순 검증 | `true`/`false` | `isValidCd()` |
| 복합 검증 | `null`(성공) / 에러메시지(실패) | `validatePrintLabel()` |
| 상태 체크 | `"Y"`/`"N"`/`null` | `chkUpdWesSndYn()` |
| 객체 생성 | 새로 생성한 객체 | `makeFileData()` |
| 데이터 변환 | 변환된 객체 | `makePrintLabelRes()` |

## 10. 에러 메시지 처리 예시

```java
// 단일 메시지
MsgTool.getMsg("message.md8000.mdpd01.NotExistLabelPaper")

// 파라미터 포함
MsgTool.getMsgParam(
    "message.md8000.mdpd01.NotExistLabelPaper",
    StringUtil.join(notDesignLabelList, StringPool.COMMA)
)
```
