---
name: PI_be_excel
description: BE 엑셀 업로드 서브패키지 개발 (ExcelUpload Controller·서비스 + JUnit). 메인 레이어 완료 후 실행. /PI_be_excel {메뉴코드}
when_to_use: "엑셀 업로드 만들어줘", "엑셀 일괄등록 만들어줘", "ExcelComp 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE 엑셀 업로드 개발 [PI_be_excel]

다음 지시에 따라 **엑셀 업로드 서브패키지**를 개발한다.

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(AI 허브)·`$BE_DIR`(BE 레포)를 결정한다.
- **BE 코드 생성·테스트 실행**: `cd "$BE_DIR"` 후 진행 — `src/main/java/...`, `./gradlew`, `build/...` 는 `$BE_DIR` 기준
- **가이드 문서·설계 문서 읽기**: `$AI_DIR/patterns/...`, `$AI_DIR/spec/$PROJECT/...` 절대경로 사용 (DEV_DOC/ai-docs 사용 금지)

## 전제 조건 확인 (BLOCKING)

- 메인 레이어(Mapper/Dao/Comp) 완료 또는 별도 엑셀 기능 개발 확인
- `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md`에 엑셀 업로드 API 포함 여부 확인

## 엑셀 패키지 구조

```
be/{그룹}/{메뉴코드}/excel/
├── {메뉴코드}ExcelController.java   ← PUT /excel (파일 업로드)
├── {메뉴코드}ExcelComp.java         ← 유효성 검사 + 저장 분기
├── {메뉴코드}ExcelTxComp.java       ← @Transactional 일괄 등록
├── {메뉴코드}ExcelDao.java          ← 배치 Mapper 위임
├── {메뉴코드}ExcelMapper.java       ← MyBatis 인터페이스
├── {메뉴코드}ExcelMapper.xml        ← 배치 INSERT SQL
├── {메뉴코드}ExcelCompUtil.java     ← 엑셀 전용 유틸 (세팅, 가공)
└── bean/
    └── {메뉴코드}Excel.java         ← ExcelBaseParam 상속, @ExcelCommCd
```

## 실행 절차

### Step 1 — 문서 및 레퍼런스 확인
1. `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md` 읽기 (없으면 `-06-be-flow.md` 참조)
2. 컬럼 명세: `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/` 에서 관련 테이블 확인. 없으면 `/DB_PSQL` 스킬로 실 DB를 직접 조회한다.
3. **레퍼런스 소스** (실제 코드 패턴 파악): `Glob("$BE_DIR/src/main/java/be/**/excel/*ExcelComp.java")` 로 기존 ExcelComp 후보를 탐색해 1개 선택 후 해당 패키지 전체를 읽는다.

### Step 2 — {메뉴코드}Excel.java 작성 (Bean)

**규칙**:
- `ExcelBaseParam` 상속
- 엑셀 컬럼 순서에 맞게 필드 선언
- 코드값 컬럼: `@ExcelCommCd("코드그룹ID")` 어노테이션
- 필수값 컬럼: `@SifValid` 또는 `@NotBlank`

```java
@Getter @Setter
public class {메뉴코드}Excel extends ExcelBaseParam {
    private String {no_camel};       // 코드 (필수)
    private String {nm_camel};       // 이름 (필수)
    @ExcelCommCd("{코드그룹ID}")
    private String {cd_camel};       // 코드값 컬럼
    private String useYn;            // 사용여부 (Y/N)
    private Integer bizSeq;          // 처리용 내부 필드
}
```

### Step 3 — {메뉴코드}ExcelMapper.java + XML 작성

**Mapper 인터페이스**:
```java
@Repository
public interface {메뉴코드}ExcelMapper {
    int insert{리소스}All(@Param("list") List<{메뉴코드}Excel> list);
}
```

**XML — 배치 INSERT**:
```xml
<insert id="insert{리소스}All" parameterType="java.util.List">
    /** {메뉴코드}ExcelMapper.insert{리소스}All 엑셀 일괄 등록 */
    INSERT INTO {테이블명} ({pk_col}, biz_seq, {no_col}, {nm_col}, use_yn, reg_id, reg_dt)
    VALUES
    <foreach collection="list" item="item" separator=",">
    (nextval('{시퀀스명}'), #{item.bizSeq}, #{item.{no_camel}}, #{item.{nm_camel}}, #{item.useYn}, #{item.regId}, now())
    </foreach>
</insert>
```

### Step 4 — {메뉴코드}ExcelDao.java 작성

```java
@Repository @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}ExcelDao {
    private final {메뉴코드}ExcelMapper {메뉴코드_인스턴스}ExcelMapper;

    public int insert{리소스}All(List<{메뉴코드}Excel> list) {
        log.info(FwPool.DAO_START_LOG);
        int cnt = {메뉴코드_인스턴스}ExcelMapper.insert{리소스}All(list);
        log.info(FwPool.DAO_END_LOG);
        return cnt;
    }
}
```

### Step 5 — {메뉴코드}ExcelCompUtil.java 작성

```java
@Component @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}ExcelCompUtil {

    public void setExcelListContext(Integer bizSeq, List<{메뉴코드}Excel> excelList) {
        String regId = TokenTool.getUserId();
        excelList.forEach(item -> { item.setBizSeq(bizSeq); item.setRegId(regId); });
    }

    public List<{메뉴코드}Excel> checkDuplicateInList(List<{메뉴코드}Excel> validList) {
        // 코드 기준 중복 감지 → errMsg 세팅
        ...
    }
}
```

### Step 6 — {메뉴코드}ExcelTxComp.java 작성

```java
@Service @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}ExcelTxComp {
    private final {메뉴코드}ExcelDao {메뉴코드_인스턴스}ExcelDao;

    @Transactional
    public int insert{리소스}ByExcelTx(List<{메뉴코드}Excel> insertList) { ... }
}
```

### Step 7 — {메뉴코드}ExcelComp.java 작성

흐름: **컨텍스트 세팅 → 공통 유효성 → 비즈니스 유효성 → 내부 중복 체크 → 에러 반환 or 저장**

### Step 8 — {메뉴코드}ExcelController.java 작성

```java
@Validated @RestController @RequiredArgsConstructor(onConstructor = @__(@Autowired)) @Slf4j
@RequestMapping("/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}s")
public class {메뉴코드}ExcelController {
    /** 엑셀 유효성 검사 */
    @PostMapping("/excel/valid")
    public ResponseEntity<{메뉴코드}Response> validExcel(...) { ... }

    /** 엑셀 일괄 등록 */
    @PutMapping("/excel")
    public ResponseEntity<{메뉴코드}Response> insert{리소스}ByExcel(...) { ... }
}
```

### Step 9 — JUnit 작성 및 통과 (BLOCKING)

`ZTEST_{메뉴코드}ExcelComp.java` 작성

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}ExcelComp'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}ExcelComp
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}ExcelComp*.xml' | xargs grep -E 'testcase|failure|error'
```

- BUILD SUCCESSFUL → 완료
- BUILD FAILED → 실패 분석 → 코드 수정 → 재실행
