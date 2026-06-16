---
title: 백엔드 코딩 컨벤션 — 헤더+상세 구조 메뉴
description: 헤더+상세 2단 구조·문서번호 채번·상태 관리가 포함된 메뉴(예:IWRQ01) 개발 시 적용할 코딩 컨벤션
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: backend
tags:
  - header-detail
  - doc-no
  - status-management
  - txcomp
  - excel-upload
related:
  - 10-src-pattern/30-backend/30-convention/01-coding-convention.md
last_verified: 2026-04-07
---

# 백엔드 코딩 컨벤션 — 헤더+상세 구조 메뉴 (Backend Coding Convention — Header+Detail Menu)

> `iwrq01` 메뉴 소스 분석을 기반으로 작성된 코딩 컨벤션입니다.
> **헤더(Header)+상세(Detail) 2단 구조**, **문서번호 채번**, **상태(Status) 관리**가 포함된 메뉴에 적용합니다.
> 단순 마스터성 메뉴는 `01-coding-convention.md`를 참고하세요.

| 메뉴코드 | 메뉴명 | 메뉴그룹 | 메뉴코드_인스턴스 | 메뉴그룹_인스턴스 | 헤더리소스 | 상세리소스 |
|----------|----------|----------|-------------------|-------------------|------------|-------------|
| IWRQ01 | 입고예정 | IW1000 | iwrq01 | iw1000 | Inwh | InwhProd |

---

## 1. 패키지 및 디렉터리 구조

```
be.{메뉴그룹_인스턴스}.{메뉴코드_인스턴스}/ ← 예: be.iw1000.iwrq01
├── {메뉴코드}Controller.java ← REST API 진입점
├── {메뉴코드}Comp.java ← 비즈니스 로직 (트랜잭션 제외)
├── {메뉴코드}TxComp.java ← @Transactional 전용
├── {메뉴코드}Dao.java ← DB 접근 (Mapper 위임)
├── {메뉴코드}Mapper.java ← MyBatis Mapper 인터페이스
├── {메뉴코드}CompUtil.java ← 메뉴 전용 유틸
├── bean/
│ ├── {메뉴코드}Response.java ← 응답 DTO
│ ├── {메뉴코드}Search.java ← 검색/조회 파라미터 DTO
│ ├── {메뉴코드}{헤더리소스}.java ← 헤더 도메인 DTO
│ ├── {메뉴코드}{상세리소스}.java ← 상세 도메인 DTO
│ └── {메뉴코드}Save{상세리소스}.java ← 상세 일괄저장 DTO
└── excel/
    ├── {메뉴코드}ExcelController.java
    ├── {메뉴코드}ExcelComp.java
    ├── {메뉴코드}ExcelTxComp.java
    ├── {메뉴코드}ExcelDao.java
    ├── {메뉴코드}ExcelMapper.java
    ├── {메뉴코드}ExcelCompUtil.java
    └── bean/
        └── {메뉴코드}Excel.java
```

**테스트 클래스**: `test/` 하위, 파일명 `ZTEST_` 접두사

---

## 2. 레이어 구조 및 책임

```
Controller → Comp (비즈니스) → TxComp (트랜잭션) → Dao → Mapper
```

| 레이어 | 클래스 접미사 | 역할 |
|---|---|---|
| REST API | `Controller` | HTTP 요청/응답, 파라미터 바인딩 |
| 비즈니스 | `Comp` | 상태 검증, 비즈니스 로직, 예외 처리 |
| 트랜잭션 | `TxComp` | `@Transactional` 메서드만 위치 |
| 데이터 접근 | `Dao` | Mapper 위임, 문서번호 채번 |
| 쿼리 | `Mapper` | MyBatis Mapper 인터페이스 |
| 유틸 | `CompUtil` | 데이터 가공, 알람 생성, 엑셀 변환 |

---

## 3. 클래스 어노테이션

### 3.1 Controller
```java
@Validated
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Slf4j
@RequestMapping("/{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s")
public class {메뉴코드}Controller {
    private final {메뉴코드}Comp {메뉴코드_인스턴스}Comp;
}
```

### 3.2 Comp (Service)
```java
@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Comp {
    private final {메뉴코드}TxComp  {메뉴코드_인스턴스}TxComp;
    private final {메뉴코드}Dao     {메뉴코드_인스턴스}Dao;
    private final {메뉴코드}CompUtil {메뉴코드_인스턴스}CompUtil;
}
```

### 3.3 TxComp
```java
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Slf4j
public class {메뉴코드}TxComp {
    private final {메뉴코드}Dao {메뉴코드_인스턴스}Dao;
}
```

### 3.4 Dao
```java
@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Dao {
    private final {메뉴코드}Mapper    {메뉴코드_인스턴스}Mapper;
    private final DocNoGenerator      docNoGenerator;   // 문서번호 채번
}
```

### 3.5 Mapper
```java
@Repository
public interface {메뉴코드}Mapper { }
```

### 3.6 CompUtil
```java
@Service
public class {메뉴코드}CompUtil { }
```

### 3.7 DTO (Bean)
```java
@Getter @Setter
public class {메뉴코드}Response extends ResponseData { }

@Getter @Setter
public class {메뉴코드}Search extends BaseParam { }

@Getter @Setter
public class {메뉴코드}{헤더리소스} extends BaseParam { }

@Getter @Setter
public class {메뉴코드}{상세리소스} extends BaseParam implements Serializable { }
```

---

## 4. Controller 패턴

### 4.1 URL 설계 — 헤더+상세 구조

```
POST /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s ← 헤더 목록 조회
PUT /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s ← 헤더 등록
GET /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s/{헤더seq} ← 헤더 단건 조회
PATCH /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s ← 헤더 수정
DELETE /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s ← 헤더 삭제
GET /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s/{헤더seq}/{상세리소스_소문자}s ← 상세 목록 조회
POST /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s/{헤더seq}/{상세리소스_소문자}s ← 상세 일괄저장
PUT /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s/excel ← 엑셀 일괄 등록
POST /{bizSeq}/{메뉴코드_인스턴스}/{헤더리소스_소문자}s/excel/valid ← 엑셀 유효성 검사
```

> **규칙**: 헤더+상세 구조에서는 `PUT` = 등록, `PATCH` = 수정 (REST 표준 준수).
> 교차 참조: 단순 마스터(`mdpd01`)는 [01-coding-convention.md](01-coding-convention.md) §4처럼 `POST /insert`, `POST /update`를 사용한다. 메뉴 구조별 규칙이 다르므로 혼용하지 않는다.

### 4.2 메서드 패턴
```java
// 헤더 목록 조회
@PostMapping
public ResponseEntity<{메뉴코드}Response> search{헤더리소스}s(
        @PathVariable Integer bizSeq,
        @RequestBody {메뉴코드}Search search) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.search{헤더리소스}s(search));
}

// 헤더 등록 (문서번호 자동 채번)
@PutMapping
public ResponseEntity<{메뉴코드}Response> insert{헤더리소스}(
        @PathVariable Integer bizSeq,
        @Valid @RequestBody {메뉴코드}{헤더리소스} put{헤더리소스}) {
    return ResponseEntity.status(HttpStatus.CREATED)
                         .body({메뉴코드_인스턴스}Comp.insert{헤더리소스}(put{헤더리소스}));
}

// 헤더 단건 조회
@GetMapping("{헤더seq}")
public ResponseEntity<{메뉴코드}Response> select{헤더리소스}(
        @PathVariable Integer bizSeq,
        @PathVariable Integer {헤더seq}) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.select{헤더리소스}({헤더seq}));
}

// 헤더 수정
@PatchMapping
public ResponseEntity<{메뉴코드}Response> update{헤더리소스}(
        @PathVariable Integer bizSeq,
        @Valid @RequestBody {메뉴코드}{헤더리소스} patch{헤더리소스}) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.update{헤더리소스}(patch{헤더리소스}));
}

// 헤더 삭제
@DeleteMapping
public ResponseEntity<{메뉴코드}Response> delete{헤더리소스}s(
        @PathVariable Integer bizSeq,
        @RequestParam Integer[] {헤더seq}s) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.delete{헤더리소스}s({헤더seq}s));
}

// 상세 목록 조회
@GetMapping("{헤더seq}/{상세리소스_소문자}s")
public ResponseEntity<{메뉴코드}Response> search{상세리소스}s(
        @PathVariable Integer {헤더seq}) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.search{상세리소스}s({헤더seq}));
}

// 상세 일괄저장 (등록+수정+삭제 동시 처리)
@PostMapping("{헤더seq}/{상세리소스_소문자}s")
public ResponseEntity<{메뉴코드}Response> save{상세리소스}s(
        @PathVariable Integer {헤더seq},
        @Valid @RequestBody {메뉴코드}Save{상세리소스} save{상세리소스}) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.save{상세리소스}s({헤더seq}, save{상세리소스}));
}
```

---

## 5. Comp (비즈니스) 패턴

### 5.1 헤더 등록 — 문서번호 채번 포함
```java
public {메뉴코드}Response insert{헤더리소스}({메뉴코드}{헤더리소스} put{헤더리소스}) {
    {메뉴코드}Response result = new {메뉴코드}Response();
    int retCnt = 0;
    try {
        // 1. 이력 컬럼 세팅
        put{헤더리소스}.setRegId(TokenTool.getLoginUserId());
        put{헤더리소스}.setRegDt(DateTool.now());

        // 2. CompUtil로 insert용 데이터 가공 (문서번호는 Dao에서 채번)
        {메뉴코드}{헤더리소스} insertData = {메뉴코드_인스턴스}CompUtil.makeInsert{헤더리소스}(put{헤더리소스});

        // 3. DB insert (Dao 내부에서 DocNoGenerator 호출)
        retCnt = {메뉴코드_인스턴스}Dao.insert{헤더리소스}(insertData);

    } catch (CompWarnException e) {
        log.error("{메뉴코드} insert{헤더리소스} warn~~~", e);
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        log.error("{메뉴코드} insert{헤더리소스} error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    } finally {
        result.setProcCnt(retCnt);
    }
    return result;
}
```

### 5.2 헤더 수정/삭제 — 상태 검증 필수
```java
public {메뉴코드}Response update{헤더리소스}({메뉴코드}{헤더리소스} patch{헤더리소스}) {
    {메뉴코드}Response result = new {메뉴코드}Response();
    int retCnt = 0;
    try {
        // 상태 검증: STAND_BY 상태에서만 수정 허용
        validate{헤더리소스}Status(new Integer[]{patch{헤더리소스}.get{헤더리소스}Seq()}, WMSPool.STAND_BY);

        patch{헤더리소스}.setModId(TokenTool.getLoginUserId());
        patch{헤더리소스}.setModDt(DateTool.now());

        retCnt = {메뉴코드_인스턴스}Dao.update{헤더리소스}(patch{헤더리소스});

    } catch (CompWarnException e) {
        log.error("{메뉴코드} update{헤더리소스} warn~~~", e);
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        log.error("{메뉴코드} update{헤더리소스} error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    } finally {
        result.setProcCnt(retCnt);
    }
    return result;
}

// 상태 검증 메서드
private void validate{헤더리소스}Status(Integer[] {헤더seq}s, String expectStatus) {
    List<{메뉴코드}{헤더리소스}> notMatched = {메뉴코드_인스턴스}Dao.check{헤더리소스}Status({헤더seq}s, expectStatus);
    if (!notMatched.isEmpty()) {
        String {헤더리소스_소문자}Nos = notMatched.stream()
                .map({메뉴코드}{헤더리소스}::get{헤더리소스}No)
                .collect(Collectors.joining(", "));
        throw new AlreadyProcessException(
            MsgTool.getMsgParam("message.{메뉴그룹_인스턴스}.NotMatchedStatus", {헤더리소스_소문자}Nos));
    }
}
```

### 5.3 상세 일괄저장 — 단일 TX에서 Insert+Update+Delete
```java
public {메뉴코드}Response save{상세리소스}s(Integer {헤더seq}, {메뉴코드}Save{상세리소스} save{상세리소스}) {
    {메뉴코드}Response result = new {메뉴코드}Response();
    int retCnt = 0;
    try {
        // 1. 헤더 상태 검증
        validate{헤더리소스}StatusFor{상세리소스}s({헤더seq});

        // 2. 라벨발행 여부 체크 (발행된 상세는 수정 불가)
        validateIssuedLabel({헤더seq}, save{상세리소스});

        // 3. 데이터 가공 (이력, 계산 등)
        {메뉴코드}Save{상세리소스} saveData = {메뉴코드_인스턴스}CompUtil.makeSave{상세리소스}Data({헤더seq}, save{상세리소스});

        // 4. TxComp 호출 (insert+update+delete 단일 TX)
        retCnt = {메뉴코드_인스턴스}TxComp.save{상세리소스}sTX(saveData);

    } catch (CompWarnException e) {
        log.error("{메뉴코드} save{상세리소스}s warn~~~", e);
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        log.error("{메뉴코드} save{상세리소스}s error~~~", e);
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    } finally {
        result.setProcCnt(retCnt);
    }
    return result;
}
```

---

## 6. TxComp (@Transactional) 패턴

### 6.1 상세 일괄저장 TX — Insert+Update+Delete 통합
```java
@Transactional
public int save{상세리소스}sTX({메뉴코드}Save{상세리소스} saveData) {
    int rtnCnt = 0;
    if (EmptyTool.notEmpty(saveData.getInsertList())) {
        rtnCnt += {메뉴코드_인스턴스}Dao.insert{상세리소스}s(saveData.getInsertList());
    }
    if (EmptyTool.notEmpty(saveData.getUpdateList())) {
        rtnCnt += {메뉴코드_인스턴스}Dao.update{상세리소스}s(saveData.getUpdateList());
    }
    if (EmptyTool.notEmpty(saveData.getDeleteList())) {
        Long[] deleteSeqs = saveData.getDeleteList().stream()
                .map({메뉴코드}{상세리소스}::get{상세리소스}Seq)
                .toArray(Long[]::new);
        rtnCnt += {메뉴코드_인스턴스}Dao.delete{상세리소스}s(deleteSeqs);
    }
    return rtnCnt;
}
```

### 6.2 헤더 삭제 TX — 상세 먼저 삭제 후 헤더 삭제
```java
@Transactional
public int delete{헤더리소스}TX(Integer[] {헤더seq}s) {
    // 반드시 상세(자식) 먼저 삭제
    {메뉴코드_인스턴스}Dao.delete{상세리소스}For{헤더리소스}Seqs({헤더seq}s);
    // 헤더(부모) 삭제
    return {메뉴코드_인스턴스}Dao.delete{헤더리소스}s({헤더seq}s);
}
```

> **규칙**: `@Transactional`은 반드시 TxComp에서만 사용. Comp에서 직접 사용 금지.

---

## 7. Dao 패턴 — 문서번호 채번

```java
// 헤더 등록: DB insert 전 문서번호 채번
public int insert{헤더리소스}({메뉴코드}{헤더리소스} put{헤더리소스}) {
    // 문서번호 채번
    DocNoBean bean = DocNoBean.docNoPubBuilder()
            .bizSeq(put{헤더리소스}.getBizSeq())
            .inoutTypeCd(InvenPool.IW)          // 수불 유형 코드
            .baseYmd(put{헤더리소스}.getReqYmd())
            .build();
    docNoGenerator.getDocNo(bean);
    put{헤더리소스}.set{헤더리소스}No(bean.getDocNo());

    return {메뉴코드_인스턴스}Mapper.insert{헤더리소스}(put{헤더리소스});
}
```

---

## 8. Mapper 패턴

```java
@Repository
public interface {메뉴코드}Mapper {

    // 헤더 목록 조회
    List<{메뉴코드}Search> search{헤더리소스}s({메뉴코드}Search search);

    // 헤더 등록/수정/삭제
    int insert{헤더리소스}({메뉴코드}{헤더리소스} put{헤더리소스});
    int update{헤더리소스}({메뉴코드}{헤더리소스} patch{헤더리소스});
    int delete{헤더리소스}s(@Param("{헤더seq}s") Integer[] {헤더seq}s);

    // 헤더 상태 검증
    List<{메뉴코드}{헤더리소스}> check{헤더리소스}Status(
            @Param("{헤더seq}s")    Integer[] {헤더seq}s,
            @Param("expectStatus") String expectStatus);

    // 상세 목록 조회
    List<{메뉴코드}{상세리소스}> search{상세리소스}s(Integer {헤더seq});

    // 상세 등록/수정/삭제 (List 배치)
    int insert{상세리소스}s(List<{메뉴코드}{상세리소스}> insertList);
    int update{상세리소스}s(List<{메뉴코드}{상세리소스}> updateList);
    int delete{상세리소스}s(@Param("{상세seq}s") Long[] {상세seq}s);

    // 헤더 삭제 시 연계 상세 삭제
    int delete{상세리소스}For{헤더리소스}Seqs(@Param("{헤더seq}s") Integer[] {헤더seq}s);

    // 라벨발행 체크
    List<String> searchIssued{상세리소스}Nos(
            @Param("{헤더seq}")         Integer {헤더seq},
            @Param("{상세seq}List")     List<Long> {상세seq}List);
}
```

---

## 9. DTO (Bean) 패턴

### 9.1 Save{상세리소스} — 일괄저장 전용 DTO
```java
@Getter
@Setter
public class {메뉴코드}Save{상세리소스} {
    private List<{메뉴코드}{상세리소스}> insertList;   // 신규 등록 목록
    private List<{메뉴코드}{상세리소스}> updateList;   // 수정 목록
    private List<{메뉴코드}{상세리소스}> deleteList;   // 삭제 목록
}
```

### 9.2 헤더 DTO
```java
@Getter @Setter
public class {메뉴코드}{헤더리소스} extends BaseParam {
    private Integer[] {헤더seq}s;
    private Integer {헤더seq};
    private String  {헤더리소스_소문자}No;               // 문서번호 (채번)

    @NotNull
    private Integer bizSeq;

    @NotNull
    private Integer centerSeq;

    @NotBlank
    private String {헤더리소스_소문자}TypeCd;            // 유형 코드

    private String {헤더리소스_소문자}StsCd;             // 상태 코드

    @Pattern(regexp = "(19|20)\\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])")
    private String reqYmd;                               // 예정일자 YYYYMMDD

    private Integer contSeq;
    private String  note;
    private String  delYn;

    // 이력
    private String regId;
    private String regDt;
    private String modId;
    private String modDt;
}
```

### 9.3 상세 DTO — `implements Serializable`
```java
@Getter @Setter
public class {메뉴코드}{상세리소스} extends BaseParam implements Serializable {
    private static final long serialVersionUID = /* 직접 생성 */L;

    private Long    {상세seq};                           // PK (bigint → Long 필수)
    private Integer {헤더seq};                           // FK

    @NotNull
    private Integer prodSeq;

    @NotNull
    @Min(value = 0)
    private Double reqQty;

    @Pattern(regexp = "(19|20)\\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])")
    private String mngYmd;

    @Pattern(regexp = "(19|20)\\d{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])")
    private String expYmd;

    private String delYn;

    // 품목 표시용 (조회 시 JOIN)
    private String prodNo;
    private String prodNm;
    private String unitCd;
}
```

---

## 10. 상태(Status) 관리 패턴

### 10.1 상태 코드 상수
```java
// fw.constant.WMSPool 사용
WMSPool.STAND_BY   // "11" - 예정 상태 (수정/삭제 가능)
WMSPool.PROCESSING // "55" - 처리 상태
WMSPool.COMPLETION // "77" - 확정 상태
```

> 출처: `../cloud-wms-be/src/main/java/fw/constant/WMSPool.java`
>
> 미확인: `WMSPool.CONFIRMED` 상수와 값 `"20"`은 `../cloud-wms-be`에서 확인되지 않았다. `iwrq01` 소스에서는 `WMSPool.STAND_BY`만 직접 사용한다.

---

## 11. 문서번호 채번 패턴

```java
// 단건 채번
DocNoBean bean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq)
        .inoutTypeCd(InvenPool.IW)        // IW: 입고 / OW: 출고 / MW: 재고이동 등
        .baseYmd(reqYmd)
        .build();
docNoGenerator.getDocNo(bean);
String docNo = bean.getDocNo();

// 다건 채번 (엑셀 일괄)
DocNoBean batchBean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq)
        .inoutTypeCd(InvenPool.IW)
        .baseYmd(reqYmd)
        .incCnt(count)                    // 채번 개수
        .build();
docNoGenerator.getDocNo(batchBean);
List<String> docNoList = batchBean.getDocNoList();
```

> **규칙**: 문서번호 채번은 반드시 Dao에서 처리. Comp/Controller에서 직접 호출 금지.
> 출처: `../cloud-wms-be/src/main/java/be/iw1000/iwrq01/IWRQ01Dao.java`
>
> 미확인: 예시 `"IW20260101001"` 자체는 `DocNoGenerator` 출력값을 직접 확인하지 못했으므로 형식 예시로 단정하지 않는다. 실제 조합 근거는 `IWRQ01Dao.getInwhNo()`의 `InvenPool.IW`, `baseYmd`, `incCnt` 호출이다.

---

## 12. mdpd01 vs iwrq01 주요 차이점 요약

| 항목 | mdpd01 (마스터) | iwrq01 (헤더+상세) |
|---|---|---|
| 구조 | 단일 테이블 | 헤더 + 상세 2단 |
| 등록 HTTP | `POST /insert` | `PUT` |
| 수정 HTTP | `POST /update` | `PATCH` |
| 문서번호 | 없음 | `DocNoGenerator` 채번 |
| 상태 관리 | 없음 | `WMSPool.STAND_BY` 체크 |
| 라벨발행 체크 | 있음 (CompUtil) | 있음 (Comp) |
| 상세 저장 | 개별 insert/update | Save DTO로 통합 TX |
| 삭제 TX | 파일 정리 + 삭제 | 상세 먼저 → 헤더 삭제 |
| 엑셀 그룹핑 | 없음 | 헤더 기준 그룹핑 후 변환 |
| 알람 생성 | 없음 | 엑셀 등록 후 `makeReqAlarm` |
| CompUtil 역할 | 파일 데이터 가공 | 상세 데이터 가공 + 알람 + 엑셀 변환 |

---

*최초 작성: 2026-03-03 | 기준 메뉴: `be.iw1000.iwrq01`*
