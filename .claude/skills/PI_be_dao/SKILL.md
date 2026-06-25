---
name: PI_be_dao
description: BE Dao 레이어 개발 (Mapper 위임·조합 + JUnit 검증). Mapper 완료 후 실행. /PI_be_dao {메뉴코드}
when_to_use: "Dao 만들어줘", "Dao 레이어 개발해줘", "DAO 클래스 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE DAO 개발 [PI_be_dao]

다음 지시에 따라 **Dao 레이어**를 개발한다.

> **일반 메뉴 기능 개발용** — SIF 인터페이스 개발은 별도 스킬 사용

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(AI 허브)·`$BE_DIR`(BE 레포)를 결정한다.
- **BE 코드 생성·테스트 실행**: `cd "$BE_DIR"` 후 진행 — `src/main/java/...`, `./gradlew`, `build/...` 는 `$BE_DIR` 기준
- **가이드 문서·설계 문서 읽기**: `$AI_DIR/patterns/...`, `$AI_DIR/spec/$PROJECT/...` 절대경로 사용 (DEV_DOC/ai-docs 사용 금지)

## 전제 조건 확인 (BLOCKING)

Dao 개발 전 아래가 완료되어 있어야 한다:
- Mapper.java + Mapper.xml 작성 완료
- Mapper JUnit 테스트 **통과** 완료

완료되지 않았으면 `/PI_be_mapper` 먼저 실행 안내.

## 실행 절차

### Step 1 — 문서 및 레퍼런스 확인

#### 1-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

#### 1-2. DB 문서 확인
`@db-doc-reader {관련 테이블명}` 를 호출해 컬럼·PK/FK 정보를 확인한다.

#### 1-3. 산출물 및 가이드 읽기
1. `$AI_DIR/patterns/30-backend/40-guide/03-dao-writing-rules.md` 읽기
2. `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md` 읽기 (없으면 `-06-be-flow.md` 참조)
3. 레퍼런스 Dao 파일 읽기: `$BE_DIR/src/main/java/be/` 하위에서 같은 그룹 또는 유사 도메인의 `*Dao.java` 1개 탐색해 읽기

### Step 2 — 기존 Mapper 파일 확인
`src/main/java/be/{그룹}/{메뉴코드}/{메뉴코드}Mapper.java`를 읽어 메서드 목록 파악

### Step 3 — {메뉴코드}Dao.java 작성

**규칙**:
- `@Repository`, `@Slf4j`, `@RequiredArgsConstructor(onConstructor = @__(@Autowired))` 필수
- 모든 메서드 시작: `log.info(FwPool.DAO_START_LOG)`
- 모든 메서드 종료: `log.info(FwPool.DAO_END_LOG)`
- Mapper 1:1 위임이 기본 (추가 로직은 최소화)

**템플릿**:
```java
@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Dao {

    private final {메뉴코드}Mapper {메뉴코드_인스턴스}Mapper;

    /** 목록 조회 */
    public List<{메뉴코드}Search> search{리소스}s({메뉴코드}Search search) {
        log.info(FwPool.DAO_START_LOG);
        List<{메뉴코드}Search> retList = {메뉴코드_인스턴스}Mapper.search{리소스}s(search);
        log.info(FwPool.DAO_END_LOG);
        return retList;
    }

    /** 단건 조회 */
    public {메뉴코드}{리소스} select{리소스}(Integer bizSeq, Integer seq) {
        log.info(FwPool.DAO_START_LOG);
        {메뉴코드}{리소스} ret = {메뉴코드_인스턴스}Mapper.select{리소스}(bizSeq, seq);
        log.info(FwPool.DAO_END_LOG);
        return ret;
    }

    /** 등록 */
    public int insert{리소스}({메뉴코드}{리소스} {리소스_소문자}) {
        log.info(FwPool.DAO_START_LOG);
        int cnt = {메뉴코드_인스턴스}Mapper.insert{리소스}({리소스_소문자});
        log.info(FwPool.DAO_END_LOG);
        return cnt;
    }

    /** 수정 */
    public int update{리소스}({메뉴코드}{리소스} {리소스_소문자}) {
        log.info(FwPool.DAO_START_LOG);
        int cnt = {메뉴코드_인스턴스}Mapper.update{리소스}({리소스_소문자});
        log.info(FwPool.DAO_END_LOG);
        return cnt;
    }

    /** 삭제 (소프트) */
    public int delete{리소스}s(Integer bizSeq, List<Integer> seqs) {
        log.info(FwPool.DAO_START_LOG);
        int cnt = {메뉴코드_인스턴스}Mapper.delete{리소스}s(bizSeq, seqs);
        log.info(FwPool.DAO_END_LOG);
        return cnt;
    }
}
```

### Step 4 — JUnit 테스트 작성

`src/main/java/be/{그룹}/{메뉴코드}/test/ZTEST_{메뉴코드}Dao.java` 작성:
- `$AI_DIR/patterns/30-backend/50-test/02-test-coding-convention.md` 참조

### Step 5 — JUnit 실행 (BLOCKING)

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Dao'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}Dao
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}Dao*.xml'
```

- ✅ PASS → 다음 레이어 진행
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행

### Step 6 — 다음 단계 안내
Dao 테스트 통과 후 `/PI_be_comp` 스킬로 Comp/TxComp 레이어 개발 안내
