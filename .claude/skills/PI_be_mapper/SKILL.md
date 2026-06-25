---
name: PI_be_mapper
description: BE Mapper 레이어 개발 (Mapper.java + Mapper.xml, MyBatis 쿼리 + JUnit). /PI_be_mapper {메뉴코드}
when_to_use: "Mapper 만들어줘", "MyBatis 쿼리 작성해줘", "Mapper.xml 만들어줘", "Mapper 레이어 개발해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE Mapper 개발 [PI_be_mapper]

다음 지시에 따라 **Mapper 레이어(Mapper.java + Mapper.xml)**를 개발한다.

> **일반 메뉴 기능 개발용** — SIF 인터페이스 개발은 별도 스킬 사용

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(AI 허브)·`$BE_DIR`(BE 레포)를 결정한다.
- **BE 코드 생성·테스트 실행**: `cd "$BE_DIR"` 후 진행 — `src/main/java/...`, `./gradlew`, `build/...` 는 `$BE_DIR` 기준
- **가이드 문서·설계 문서 읽기**: `$AI_DIR/patterns/...`, `$AI_DIR/spec/$PROJECT/...` 절대경로 사용 (DEV_DOC/ai-docs 사용 금지)

## 실행 절차

### Step 1 — 전제 문서 확인 (BLOCKING)

#### 1-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

#### 1-2. DB 문서 확인
`$AI_DIR/spec/$PROJECT/_knowledge/db-schema/` 에서 관련 테이블 구조를 확인한다.
파일에 없는 상세 컬럼은 `/DB_PSQL` 스킬로 실 DB를 직접 조회한다.

#### 1-3. 산출물 읽기
아래 파일을 읽는다. 읽지 않고 코드를 작성하는 것은 금지된다:
1. `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md` — API·기능 명세 (없으면 `-06-be-flow.md` 참조)
2. `$AI_DIR/patterns/30-backend/40-guide/04-mapper-writing-rules.md` — Mapper 가이드
3. 시스템별 DB 컨벤션 규칙 (OMS: `.claude/rules/oms-db-convention.md`)

### Step 2 — 레퍼런스 소스 탐색

작업 대상과 같은 그룹 패키지(`$BE_DIR/src/main/java/be/{그룹}/`)에서 기존 Mapper 파일을 Glob으로 탐색해 패턴을 파악한다.
같은 그룹 내 Mapper가 없으면 `$BE_DIR/src/main/java/be/` 하위에서 가장 유사한 도메인의 Mapper를 탐색한다.
- 탐색: `Glob("$BE_DIR/src/main/java/be/**/*Mapper.java")` 로 후보 목록 확인 후 1개 선택해 읽기
- `*Mapper.java` + `*Mapper.xml` 쌍을 함께 읽는다

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
✅ 기본 삭제정책: 마스터/이력성 데이터는 소프트 삭제 우선 (`use_yn = 'N'` 또는 `del_yn = 'Y'`)
✅ 예외 삭제정책: 교차/매핑/신청 테이블은 업무 의미가 연결 해제인 경우 `DELETE FROM` 허용
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
- `$AI_DIR/patterns/30-backend/50-test/02-test-coding-convention.md` 참조
- 각 Mapper 메서드별 테스트 케이스 작성

### Step 7 — JUnit 실행 (BLOCKING)

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}Mapper
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}Mapper*.xml'
```

- ✅ PASS → 다음 레이어 진행
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행
