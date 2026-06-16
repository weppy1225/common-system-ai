# 신규 백엔드 API 추가 절차 (New Backend API Addition Procedure)

## 1. 메뉴코드/패키지 결정

먼저 메뉴코드를 결정합니다. 기존 패턴을 따라야 합니다.

```
시스템구분:P
메뉴그룹:MD8000
메뉴그룹명:기준정보
메뉴코드: frgt01
메뉴명: 사은품관리
리소스: freegift
패키지: be.md8000.frgt01
URL prefix: /{bizSeq}/mdfg01/freegifts
```

| 메뉴코드 | 메뉴명 | 메뉴그룹 | 메뉴코드_인스턴스 | 메뉴그룹_인스턴스 | 리소스 | 리소스_소문자 |
|----------|--------|----------|-------------------|-------------------|--------|---------------|
| MDPD01 | 품목 | MD8000 | mdpd01 | md8000 | Prod | prod |


## 2. URL 패턴 규칙 요약

| Interface ID | HTTP 메서드 | URL | 용도 |
|-------------|-------------|------------------------------|--------------------------|
| {메뉴코드}_POST_{리소스}S | POST | `/{bizSeq}/{메뉴코드}/{리소스}s` | 목록 조회 (검색조건 Body) |
| {메뉴코드}_POST_INSERT | POST | `/{bizSeq}/{메뉴코드}/{리소스}/insert`| 단건 등록(등록정보 Body) |
| {메뉴코드}_GET_{리소스} | GET | `/{bizSeq}/{메뉴코드}/{리소스}/{리소스seq}`| 단건 등록 |
| {메뉴코드}_POST_UPDATE | POST | `/{bizSeq}/{메뉴코드}/{리소스}/update` | 단건 수정(수정정보 Body) |
| {메뉴코드}_DELETE_{리소스}S | DELETE | `/{bizSeq}/{메뉴코드}/{리소스}s` | 삭제 (Body로 seq 목록) |

---

## 3. 디렉터리 및 파일 구조 생성

CODING_CONVENTION.md 기준 레이어 구조:

```
src/main/java/be/{메뉴그룹}/{메뉴코드}/
├── {메뉴코드}Controller.java ← HTTP 요청/응답
├── {메뉴코드}Comp.java ← 비즈니스 로직
├── {메뉴코드}TxComp.java ← @Transactional 전용
├── {메뉴코드}Dao.java ← Mapper 위임
├── {메뉴코드}Mapper.java ← MyBatis 인터페이스
├── {메뉴코드}Mapper.xml ← SQL 쿼리 (Mapper.java와 같은 위치)
└── bean/
    ├── {메뉴코드}Response.java   ← 응답 DTO
    ├── {메뉴코드}Search.java     ← 조회 파라미터 DTO
    └── {메뉴코드}{리소스}.java   ← 도메인 DTO
```

> **참고**: TxComp는 쓰기(등록/수정/삭제) 없는 순수 조회 API라면 생략 가능

---

## 4. 각 클래스 구현 순서

### 4.1 Step 1 — Bean (DTO) 먼저 작성

#### 4.1.1 Search.java (조회 파라미터)

```java
@Getter @Setter
public class RCST01Search implements Serializable {
    private Integer bizSeq;
    private String whSeq;
    private String prodNm;
    // 필요한 검색 조건 필드
}
```

#### 4.1.2 도메인 Bean.java (등록/수정 요청 + 조회 결과 겸용)

```java
@Getter @Setter
public class RCST01Stock implements Serializable {
    private Integer stockSeq;
    private Integer bizSeq;
    private String prodNm;
    private String regId;
    private Timestamp regDt;
    // ...
}
```

#### 4.1.3 Response.java (응답 래퍼)

```java
@Getter @Setter
public class RCST01Response extends ResponseData {
    private List<RCST01Stock> stockList;
    private RCST01Stock stock;
}
```

---

### 4.2 Step 2 — Mapper 인터페이스 작성

```java
@Repository
public interface RCST01Mapper {
    List<RCST01Stock> searchStocks(RCST01Search search);
    RCST01Stock selectStock(Integer stockSeq);
    int insertStock(RCST01Stock stock);
    int updateStock(RCST01Stock stock);
}
```

---

### 4.3 Step 3 — Mapper.xml (SQL) 작성

RCST01Mapper.xml (Mapper.java와 같은 디렉터리에 위치)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="be.rc3000.rcst01.RCST01Mapper">

    <select id="searchStocks"
            parameterType="be.rc3000.rcst01.bean.RCST01Search"
            resultType="be.rc3000.rcst01.bean.RCST01Stock">
        /** RCST01Mapper.searchStocks 재고목록조회 */
        SELECT
              IS.stock_seq   AS stockSeq
            , IS.biz_seq     AS bizSeq
            , MP.prod_nm     AS prodNm
        FROM INV_STOCK IS
        JOIN MDM_PROD MP ON IS.prod_seq = MP.prod_seq
        <where>
            AND IS.use_yn = 'Y'
            <if test="@fw.tool.EmptyTool@notEmpty(bizSeq)">
            AND IS.biz_seq = #{bizSeq}
            </if>
            <if test="@fw.tool.EmptyTool@notEmpty(prodNm)">
            AND MP.prod_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{prodNm}, '%')
            </if>
        </where>
        ORDER BY IS.stock_seq DESC
    </select>

</mapper>
```

> **규칙**: 첫 번째 주석 `/** {Mapper클래스명}.{메서드명} 설명 */` 필수

---

### 4.4 Step 4 — Dao 작성

```java
@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RCST01Dao {

    private final RCST01Mapper rcst01Mapper;

    public List<RCST01Stock> searchStocks(RCST01Search search) {
        log.info(FwPool.DAO_START_LOG);
        List<RCST01Stock> retList = rcst01Mapper.searchStocks(search);
        log.info(FwPool.DAO_END_LOG);
        return retList;
    }
}
```

---

### 4.5 Step 5 — TxComp 작성 (쓰기 작업 있을 때)

```java
@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RCST01TxComp {

    private final RCST01Dao rcst01Dao;

    @Transactional
    public int insertStockTx(RCST01Stock stock) {
        log.info(FwPool.COMP_START_LOG);
        int retCnt = rcst01Dao.insertStock(stock);
        log.info(FwPool.COMP_END_LOG);
        return retCnt;
    }
}
```

---

### 4.6 Step 6 — Comp 작성 (비즈니스 로직)

```java
@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RCST01Comp {

    private final RCST01TxComp rcst01TxComp;
    private final RCST01Dao    rcst01Dao;

    public RCST01Response searchStocks(RCST01Search search) {
        log.info(FwPool.COMP_START_LOG);

        RCST01Response result = new RCST01Response();
        List<RCST01Stock> retList = Collections.emptyList();
        try {
            retList = rcst01Dao.searchStocks(search);
        } catch (Exception e) {
            log.error("RCST01 searchStocks error~~~", e);
            result.setSystemError(e);
            throw new ResponseErrorException(e, result);
        }
        result.setStockList(retList);

        log.info(FwPool.COMP_END_LOG);
        return result;
    }

    public RCST01Response insertStock(RCST01Stock stock) {
        log.info(FwPool.COMP_START_LOG);

        RCST01Response result = new RCST01Response();
        int retCnt = 0;
        try {
            // 이력 컬럼 세팅 (Controller에서 하지 않음)
            stock.setRegId(TokenTool.getLoginUserId());
            stock.setRegDt(DateTool.now());

            retCnt = rcst01TxComp.insertStockTx(stock);
        } catch (CompWarnException e) {
            log.error("RCST01 insertStock warn~~~", e);
            result.setWarn(e);
            throw new ResponseWarnException(e, result);
        } catch (Exception e) {
            log.error("RCST01 insertStock error~~~", e);
            result.setSystemError(e);
            throw new ResponseErrorException(e, result);
        } finally {
            result.setProcCnt(retCnt);
        }

        log.info(FwPool.COMP_END_LOG);
        return result;
    }
}
```

---

### 4.7 Step 7 — Controller 작성

```java
@Validated
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Slf4j
@RequestMapping("/{bizSeq}/rcst01/stocks")
public class RCST01Controller {

    private final RCST01Comp rcst01Comp;

    // 목록 조회
    @PostMapping
    public ResponseEntity<RCST01Response> postStocks(@RequestBody RCST01Search req) {
        log.info(FwPool.CONTROLLER_START_LOG);
        GsonTool.printBean(req);

        RCST01Response response = rcst01Comp.searchStocks(req);

        log.info(FwPool.CONTROLLER_END_LOG);
        return ResponseEntity.ok(response);
    }

    // 등록
    @PostMapping("/insert")
    public ResponseEntity<RCST01Response> postStock(@RequestBody RCST01Stock req) {
        log.info(FwPool.CONTROLLER_START_LOG);
        GsonTool.printBean(req);

        RCST01Response response = rcst01Comp.insertStock(req);

        log.info(FwPool.CONTROLLER_END_LOG);
        return ResponseEntity.ok(response);
    }
}
```

---

## 5. URL 패턴 규칙 요약

| HTTP 메서드 | URL | 용도 |
|-------------|------------------------------|--------------------------|
| POST | `/{bizSeq}/rcst01/stocks` | 목록 조회 (검색조건 Body) |
| POST /insert | `/{bizSeq}/rcst01/stocks/insert` | 단건 등록 |
| POST /update | `/{bizSeq}/rcst01/stocks/update` | 단건 수정 |
| DELETE | `/{bizSeq}/rcst01/stocks` | 삭제 (QueryParam으로 seq 목록) |


Interface ID	Method	URL	설명
MDPD01_POST_PRODS	POST	/{bizSeq}/mdpd01/prods	품목 목록 조회
MDPD01_POST_INSERT	POST	/{bizSeq}/mdpd01/prods/insert	품목 등록
MDPD01_GET_PROD	GET	/{bizSeq}/mdpd01/prods/{prodSeq}	품목 단건 조회
MDPD01_POST_UPDATE	POST	/{bizSeq}/mdpd01/prods/update	품목 수정
MDPD01_DELETE_PRODS	DELETE	/{bizSeq}/mdpd01/prods	품목 삭제
---

## 6. 핵심 규칙 체크리스트

- [ ] `@Transactional`은 TxComp에만 사용
- [ ] 이력컬럼(regId, regDt, modId, modDt)은 Comp에서 세팅
- [ ] 삭제 정책 준수 — MDM_* 기준정보: `use_yn='N'` 논리삭제 / WMS_* 업무: `DELETE FROM` 물리삭제 (예외 시 기존 소스 따름)
- [ ] MDM_* 조회 쿼리에 `AND xx.use_yn = 'Y'` 조건 반드시 포함 (WMS_*는 물리삭제이므로 필터 불필요)
- [ ] HTTP 메서드: 단순 마스터 — `POST /insert`(등록), `POST /update`(수정) / 헤더+상세 구조 — `PUT`(등록), `PATCH`(수정)
- [ ] Response 클래스는 `ResponseData`를 상속
- [ ] Mapper.xml은 Mapper.java와 같은 디렉터리에 위치
- [ ] SQL 첫 줄에 `/** {클래스명}.{메서드명} 설명 */` 주석 필수