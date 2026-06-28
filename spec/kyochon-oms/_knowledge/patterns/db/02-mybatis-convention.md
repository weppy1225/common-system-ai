---
description: oms-be Mapper.java/Mapper.xml MyBatis 구현 패턴 중 OMS 고유 차이분(@Repository 어노테이션·풀패키지 namespace bc.co1000c.mypg01c·EmptyTool/DBConfig/StringPool OGNL·FN_ 함수). Mapper 작성 시 공통 패턴과 함께 적용한다.
---

# MyBatis 레이어 코딩 컨벤션 — OMS 고유 차이

> 공통 MyBatis 골격(레이어 구조·메서드 네이밍 접두사·@Param 기준·Mapper.xml 기본구조·동적쿼리 태그·resultMap·자주하는 실수)은 [common 문서](../../../../../patterns/20-database/30-convention/02-mybatis-convention.md)와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.

근거(OMS 실제 적용 확인): `oms-be/src/main/java/bc/co1000c/mypg01c/MYPG01CMapper.xml`, `fw/tool/EmptyTool.java`, `fw/config/DBConfig.java`, `fw/constant/StringPool.java`.

---

## 1. OMS 고유 차이 (vs common)

| 항목 | common 일반 | OMS 고유 |
|---|---|---|
| Mapper.java 어노테이션 | `@Mapper` | **`@Repository`(OMS)** 또는 `@Mapper` |
| namespace 풀패키지 예시 | `be.{도메인}.{메뉴코드}.{XXXX01Mapper}` | `bc.co1000c.mypg01c.MYPG01CMapper` |
| parameterType/resultType 풀패키지 예시 | `be.{패키지}.bean.XXXX01...` | `bc.co1000c.mypg01c.bean.MYPG01CSearch` / `MYPG01CUser` |
| DB 함수 prefix | (PostgreSQL 직접 함수 또는 `${DB_PREFIX}`) | `${@fw.config.DBConfig@DB_PREFIX}` 동적 주입(ERP=SQL Server 멀티 DB 대응) — 필수 |
| 판단기준·금지패턴 SSoT | (common 문서 내) | `.claude/rules/oms-db-convention.md` |

---

## 2. OMS Mapper.xml 기본 구조 (풀패키지 namespace)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="bc.co1000c.mypg01c.MYPG01CMapper">
    <!-- SQL 선언 -->
</mapper>
```

MUST: `namespace`·`resultType`·`parameterType` 는 **풀 패키지명**(`bc.co1000c.mypg01c...`) 사용. 단축명 금지.

---

## 3. OMS SELECT/INSERT/UPDATE — DB_PREFIX 함수 (OMS 실제)

근거(OMS 실제 `MYPG01CMapper.xml`): `${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(...)`, `FN_CONCAT(...)` 사용 확인.

```xml
<select id="searchUsers" parameterType="bc.co1000c.mypg01c.bean.MYPG01CSearch"
        resultType="bc.co1000c.mypg01c.bean.MYPG01CUser">
        /* MYPG01CMapper.searchUsers 사용자 목록 [검색] */
        SELECT
               MU.user_id   AS userId
             , MU.user_nm   AS userNm
          FROM MDM_USER MU
        <where>
               MU.use_yn = 'Y'
            <if test="@fw.tool.EmptyTool@notEmpty(userNm)">
               AND MU.user_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{userNm}, '%')
            </if>
        </where>
</select>
```

```xml
<insert id="insertPwdHistory" parameterType="bc.co1000c.mypg01c.bean.MYPG01CUser">
    /* MYPG01CMapper.insertPwdHistory 비밀번호 변경 이력 저장 */
    INSERT INTO SM_USER_PWD_HISTORY
    ( user_id, password, reg_id, reg_dt )
    VALUES
    ( #{userId}, #{prePassword}, #{regId}, ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{regDt}) )
</insert>
```

---

## 4. OMS OGNL 정적 메서드·필드 참조 (OMS 핵심)

OMS 전용 정적 참조 — 풀 패키지 식별자를 정확히 사용한다.

```xml
<!-- 정적 메서드 -->
@fw.tool.EmptyTool@notEmpty( estMngYmd )
@fw.constant.StringPool@NONE.equals( divId )
<!-- 정적 필드: DB 벤더 prefix 동적 주입 (PostgreSQL/SQL Server 멀티 DB 대응) -->
${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{regDt})
${@fw.config.DBConfig@DB_PREFIX}FN_GET_YMD()
${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{userNm}, '%')
```

MUST: `${}` 는 DB prefix·정적 치환 전용. 일반 파라미터는 반드시 `#{}`(SQL 인젝션 방지).
근거: `${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(...)` 는 OMS `MYPG01CMapper.xml` 에서 실제 사용 확인.

---

## 5. OMS 자주 하는 실수 (NEVER → MUST)

> 동적 조건 null 체크(`field != null` 금지 → `EmptyTool.notEmpty`)·LIKE 후방 일치 규칙 → `.claude/rules/oms-db-convention.md §3·§7`

```
❌ namespace="MYPG01CMapper"             → ✅ namespace="bc.co1000c.mypg01c.MYPG01CMapper"(풀 패키지명)
❌ resultType="MYPG01CUser"              → ✅ resultType="bc.co1000c.mypg01c.bean.MYPG01CUser"
```
