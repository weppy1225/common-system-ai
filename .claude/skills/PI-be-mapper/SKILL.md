---
name: PI-be-mapper
description: BE Mapper 레이어 개발 (Mapper.java + Mapper.xml, MyBatis 쿼리 + JUnit). "Mapper 만들어줘", "MyBatis 쿼리 작성해줘", "Mapper.xml 만들어줘", "Mapper 레이어 개발해줘" 요청 시 사용. /PI-be-mapper {메뉴코드}
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE Mapper 개발 [PI-be-mapper]

다음 지시에 따라 **Mapper 레이어(Mapper.java + Mapper.xml)**를 개발한다.

> **일반 메뉴 기능 개발용** — SIF 인터페이스 개발은 별도 스킬 사용

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`src/main/java/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)는 `$BE_DIR`(= 형제 `../wms-{code}-be`) 기준이다.

## 실행 절차

### Step 1 — 전제 문서 확인 (BLOCKING)

#### 1-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

#### 1-2. DB 문서 확인
`@db-doc-reader {관련 테이블명}` 를 호출해 컬럼·PK/FK 정보를 확인한다.

#### 1-3. 산출물 읽기
아래 파일을 읽는다. 읽지 않고 코드를 작성하는 것은 금지된다:
1. 현재 기능의 `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md`
2. `DEV_DOC/ai-docs/20-backend/40-guide/04-mapper-writing-rules.md` — Mapper 가이드
3. `.claude/rules/db-convention.md` — MyBatis 쿼리 규칙

### Step 2 — 레퍼런스 소스 탐색
도메인에 맞는 기존 Mapper 파일을 읽어 패턴 파악:
- MDM: `src/main/java/be/md8000/mdpd01/MDPD01Mapper.java` + `MDPD01Mapper.xml`
- IW: `src/main/java/be/iw1000/iwrq01/IWRQ01Mapper.java` + `IWRQ01Mapper.xml`
- 대상 패키지 없으면 가장 유사한 도메인 레퍼런스 참조

### Step 3 — Bean(DTO) 확인
`be/{그룹}/{메뉴코드}/bean/` 하위 DTO 파일이 있는지 확인.
없으면 api.md 기준으로 먼저 Bean을 작성한다.

### Step 4 — {메뉴코드}Mapper.java 작성

**규칙**:
- `@Repository` 어노테이션 필수
- 파라미터 2개 이상: `@Param` 명시
- 파라미터 1개(객체): `@Param` 생략 가능
- 메서드명: `search*s`, `select*`, `insert*`, `update*`, `delete*s`, `check*`, `get*`

```java
@Repository
public interface {메뉴코드}Mapper {
    List<{메뉴코드}Search> search{리소스}s({메뉴코드}Search search);
    {메뉴코드}{리소스} select{리소스}(@Param("bizSeq") Integer bizSeq, @Param("seq") Integer seq);
    int insert{리소스}({메뉴코드}{리소스} {리소스_소문자});
    int update{리소스}({메뉴코드}{리소스} {리소스_소문자});
    int delete{리소스}s(@Param("bizSeq") Integer bizSeq, @Param("seqs") List<Integer> seqs);
    List<ValidError> checkDuplicate{리소스}No(@Param("bizSeq") Integer bizSeq,
                                               @Param("seq")    Integer seq,
                                               @Param("nos")    List<String> nos);
}
```

### Step 5 — {메뉴코드}Mapper.xml 작성

**위치**: `{메뉴코드}Mapper.java`와 **같은 디렉토리**

**필수 규칙**:
```
✅ 첫 번째 줄 주석: /** {클래스명}.{메서드명} {설명} */
✅ WHERE절에 use_yn = 'Y' 또는 del_yn = 'N' 항상 포함
✅ 동적 조건: <if test="@fw.tool.EmptyTool@notEmpty(field)">
✅ LIKE 검색: ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{val}, '%')
✅ 소프트 삭제: UPDATE SET use_yn = 'N' (DELETE FROM 금지)
✅ namespace: 풀 패키지 경로 (예: be.md8000.mdpd01.MDPD01Mapper)
✅ parameterType: 풀 패키지 경로
✅ resultType: 풀 패키지 경로
```

**XML 템플릿**:
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="be.{그룹}.{메뉴코드}.{메뉴코드}Mapper">

    <select id="search{리소스}s"
            parameterType="be.{그룹}.{메뉴코드}.bean.{메뉴코드}Search"
            resultType="be.{그룹}.{메뉴코드}.bean.{메뉴코드}Search">
        /** {메뉴코드}Mapper.search{리소스}s {리소스} 목록 조회 */
        SELECT
              t.{pk_col}    AS {pk_camel}
            , t.biz_seq     AS bizSeq
            ...
        FROM {테이블명} t
        <where>
            AND t.use_yn = 'Y'
            <if test="@fw.tool.EmptyTool@notEmpty(bizSeq)">
            AND t.biz_seq = #{bizSeq}
            </if>
        </where>
        ORDER BY t.{pk_col} DESC
        <if test="@fw.tool.EmptyTool@notEmpty(pageSize)">
        LIMIT #{pageSize} OFFSET #{offset}
        </if>
    </select>

</mapper>
```

### Step 6 — JUnit 테스트 작성

`src/main/java/be/{그룹}/{메뉴코드}/test/ZTEST_{메뉴코드}MapperTest.java` 작성:
- `DEV_DOC/ai-docs/20-backend/50-test/02-test-coding-convention.md` 참조
- 각 Mapper 메서드별 테스트 케이스 작성

### Step 7 — JUnit 실행 (BLOCKING)

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}Mapper
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}Mapper*.xml'
```

- ✅ PASS → 다음 레이어 진행
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행
