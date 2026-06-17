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

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`src/main/java/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)는 `$BE_DIR`(= 형제 `../wms-{code}-be`) 기준이다.

## 전제 조건 확인 (BLOCKING)

- 메인 레이어(Mapper/Dao/Comp) 완료 또는 별도 엑셀 기능 개발 확인
- `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md`에 엑셀 업로드 API 포함 여부 확인

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
1. `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md` 읽기
2. `DEV_DOC/ai-docs/10-database/90-schema/20-tables/{테이블명}.md` — 컬럼 명세
3. **레퍼런스 소스** (실제 코드 패턴 파악):
   - `src/main/java/be/iv3000/ivad01/excel/` — Excel 전체 패키지
   - `src/main/java/be/iv3000/ivad01/excel/bean/IVAD01Excel.java` — Bean 패턴
   - `src/main/java/be/iv3000/ivad01/excel/IVAD01ExcelComp.java` — Comp 패턴

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
