---
title: 데이터베이스 레이어 코딩 컨벤션 (MyBatis)
description: WMS 프로젝트에서 Mapper.java와 Mapper.xml을 작성할 때 따라야 하는 MyBatis 구현 패턴 및 Dao 레이어 규칙
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: database
tags:
  - database
  - mybatis
  - mapper
  - dao
  - dynamic-sql
  - xml
related:
  - patterns/20-database/30-convention/01-sql-query-style.md
---

# 데이터베이스 레이어 코딩 컨벤션 (Database Layer Coding Convention)

> MyBatis 기반 Mapper / Dao 레이어 **구현 패턴 전용** 문서.
>
> **본 문서 범위**: Mapper.java 인터페이스, Mapper.xml 구현 패턴(동적 SQL, resultMap, foreach 등), Dao 레이어 구조.
> SQL 텍스트 서식(들여쓰기·정렬·anchor 규칙·대소문자)은
> [01-sql-query-style.md](./01-sql-query-style.md) 참조.

---

## 1. 레이어 구조

```
Controller
    └── Comp / TxComp
            └── Dao                ← DB 접근 단일 창구
                    └── Mapper.java
                            └── Mapper.xml  ← 실제 SQL
```

- **Dao**: Mapper를 단순 위임. 비즈니스 로직 없음. 복수 Mapper 조합은 Dao에서만.
- **Mapper.java**: 메서드 선언 인터페이스. `@Mapper` 어노테이션.
- **Mapper.xml**: 실제 SQL. `namespace`는 Mapper 풀 패키지명.

---

## 2. Mapper.java 파일 규칙

### 2.1 클래스 선언

```java
@Mapper
public interface XXXX01Mapper {
    // ...
}
```

### 2.2 메서드 네이밍

| 접두사 | 용도 | 반환 타입 |
|---|---|---|
| `search*s` | 목록 조회 (검색조건 객체) | `List<T>` |
| `select*` | 단건 조회 | `T` (null 가능) |
| `insert*` | 단건 등록 | `int` |
| `insert*s` | 다건 등록 (Bulk) | `int` |
| `update*` | 단건 수정 | `int` |
| `update*s` | 다건 수정 | `int` |
| `delete*` | 단건 소프트 삭제 | `int` |
| `delete*s` | 다건 소프트 삭제 | `int` |
| `check*` | 중복/존재 검증 조회 | `List<T>` or `int` |
| `get*` | 단일 값 조회 (count, seq 등) | `Integer` or `String` |

### 2.3 @Param 사용 기준

```java
// 파라미터 1개 (객체): @Param 생략 가능
List<XXXX01Item> searchItems(XXXX01Search search);

// 파라미터 2개 이상: 반드시 @Param 명시
XXXX01Item selectItem(@Param("bizSeq") Integer bizSeq, @Param("seq") Integer seq);

// List 파라미터: @Param 명시 (XML foreach collection명으로 사용)
int deleteItems(@Param("bizSeq") Integer bizSeq, @Param("seqs") List<Integer> seqs);
```

---

## 3. Mapper.xml 파일 규칙

### 3.1 기본 구조

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="be.{도메인패키지}.{메뉴코드}.{XXXX01Mapper}">
    <!-- SQL 선언 -->
</mapper>
```

- `namespace`: 반드시 **풀 패키지명** 사용 (단축명 금지)

### 3.2 SELECT 쿼리 패턴

> 쿼리 들여쓰기는 `01-sql-query-style.md`의 anchor 규칙을 따릅니다.
> anchor = SELECT indent + 6, 각 절의 마지막 글자가 anchor 열에 정렬됩니다.

```xml
/* XXXX01Mapper.searchItems  목록 조회 */
<select id="searchItems" parameterType="be.{패키지}.bean.XXXX01Search"
        resultType="be.{패키지}.bean.XXXX01Item">
        SELECT
               T.item_seq   AS itemSeq
             , T.item_nm    AS itemNm
             , T.use_yn     AS useYn
          FROM SOME_TABLE T
        <where>
               T.use_yn = 'Y'    /* MDM_* 테이블: use_yn = 'Y' */
               /* WMS_* 업무 테이블: del_yn 컬럼이 있으면 del_yn = 'N' 사용 */
            <if test="@fw.tool.EmptyTool@notEmpty(bizSeq)">
               AND T.biz_seq = #{bizSeq}
            </if>
            <if test="@fw.tool.EmptyTool@notEmpty(itemNm)">
               AND T.item_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{itemNm}, '%')
            </if>
        </where>
        <if test="@fw.tool.EmptyTool@notEmpty(pageSize)">
        LIMIT #{pageSize} OFFSET #{offset}
        </if>
</select>
```

### 3.3 INSERT 쿼리 패턴

```xml
/* XXXX01Mapper.insertItem  단건 등록 */
<insert id="insertItem" parameterType="be.{패키지}.bean.XXXX01Item">
    INSERT INTO SOME_TABLE
    ( item_seq, biz_seq, item_nm, use_yn, reg_id, reg_dt )
    VALUES
    ( NEXTVAL('some_table_seq'), #{bizSeq}, #{itemNm}, 'Y', #{regId}, NOW() )
</insert>
```

### 3.4 UPDATE 쿼리 패턴

```xml
/* XXXX01Mapper.updateItem  단건 수정 */
<update id="updateItem" parameterType="be.{패키지}.bean.XXXX01Item">
    UPDATE SOME_TABLE
       SET item_nm = #{itemNm}
         , mod_id  = #{modId}
         , mod_dt  = NOW()
     WHERE item_seq = #{itemSeq}
       AND use_yn   = 'Y'
</update>
```

### 3.5 DELETE 패턴

> | 테이블 유형 | 방식 |
> |---|---|
> | `MDM_*` 기준정보 | 논리삭제 — `UPDATE SET use_yn = 'N'` |
> | `WMS_*` 업무 | `del_yn` 컬럼이 있으면 논리삭제 — `UPDATE SET del_yn = 'Y'` |
> | 삭제 플래그 없는 매핑·처리 테이블 | 기존 소스/스키마 확인 후 물리삭제 — `DELETE FROM` |

```xml
<!-- MDM_* 기준정보: 논리삭제 -->
/* XXXX01Mapper.deleteItem  논리삭제 */
<update id="deleteItem" parameterType="be.{패키지}.bean.XXXX01Item">
    UPDATE SOME_TABLE
       SET use_yn = 'N'
         , mod_id = #{modId}
         , mod_dt = NOW()
     WHERE item_seq = #{itemSeq}
       AND use_yn   = 'Y'
</update>

<!-- 삭제 플래그 없는 매핑·처리 테이블: 물리삭제 -->
/* XXXX01Mapper.deleteItem  물리삭제 */
<delete id="deleteItem" parameterType="be.{패키지}.bean.XXXX01Item">
    DELETE FROM SOME_TABLE
     WHERE item_seq = #{itemSeq}
</delete>
```

---

## 4. Dao 파일 규칙

### 4.1 클래스 선언

```java
@Repository
@RequiredArgsConstructor
public class XXXX01Dao {

    private final XXXX01Mapper mapper;

    public List<XXXX01Item> searchItems(XXXX01Search search) {
        return mapper.searchItems(search);
    }

    public int insertItem(XXXX01Item item) {
        return mapper.insertItem(item);
    }
}
```

### 4.2 Dao 작성 원칙

- Mapper 단순 위임 — 비즈니스 로직 없음
- 복수 Mapper를 조합해야 하는 경우에만 Dao에서 처리
- `@Transactional` 사용 금지 (TxComp 레이어 담당)

---

## 5. resultType vs resultMap 선택

| 상황 | 선택 |
|---|---|
| 단일 테이블, 컬럼명 = camelCase 매핑 | `resultType` |
| JOIN 결과, 중첩 객체, 1:N 매핑 | `resultMap` |
| AS 별칭으로 camelCase 매핑 가능 | `resultType` + AS 별칭 |

---

## 6. 자주 하는 실수

```
❌ <if test="field != null">                  → EmptyTool 미사용
✅ <if test="@fw.tool.EmptyTool@notEmpty(field)">

❌ LIKE '%' || #{val} || '%'                  → PostgreSQL 직접 문법
✅ LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{val}, '%')

❌ WHERE 1=1 AND ...                          → 레거시 패턴
✅ <where> ... </where>

❌ namespace="XXXX01Mapper"                   → 단축 패키지명
✅ namespace="be.iw1000.iwrq01.IWRQ01Mapper" → 풀 패키지명 필수

❌ resultType="XXXX01Item"                    → 단축명
✅ resultType="be.iw1000.iwrq01.bean.XXXX01Item"

❌ MDM_* 테이블에 DELETE FROM 사용            → 논리삭제 위반
✅ MDM_* 테이블: UPDATE SET use_yn = 'N'     → 논리삭제
✅ WMS_* del_yn 테이블: UPDATE SET del_yn = 'Y' → 논리삭제
✅ 삭제 플래그 없는 매핑·처리 테이블: DELETE FROM 테이블명 WHERE → 물리삭제

❌ JOIN 테이블 use_yn 체크 누락
✅ LEFT JOIN MDM_PROD MP ON T.prod_seq = MP.prod_seq AND MP.use_yn = 'Y'
```

---

## 7. MyBatis 동적 쿼리 태그

### 7.1 `<if>` — 단순 옵션 조건

```xml
<if test="@fw.tool.EmptyTool@notEmpty( estMngYmd )">
AND WIS.mng_ymd = #{estMngYmd}
</if>
```

> `field != null` 직접 비교 금지 — 반드시 `@fw.tool.EmptyTool@notEmpty(field)` 사용.

### 7.2 `<choose>` / `<when>` / `<otherwise>` — 분기 조건

```xml
<choose>
    <when test="outwhDivCd == 'locMng'">
        <choose>
            <when test="@fw.constant.StringPool@NONE.equals( outwhDivId )">
               AND ML.loc_mng_nm IS NULL
            </when>
            <otherwise>
               AND ML.loc_mng_nm = #{outwhDivId}
            </otherwise>
        </choose>
    </when>
    <when test="outwhDivCd == 'wh'">
       AND WI.wh_seq = CAST(#{outwhDivId} AS INTEGER)
    </when>
</choose>
```

### 7.3 `<where>` — 동적 WHERE 절

동적 조건만으로 WHERE가 구성되거나 공통 `<include refid>`와 조합할 때 사용. `WHERE 1=1` 패턴 금지.

```xml
<where>
    <include refid="be.comm.CommonSqlMapper.getAuthCenterBiz"/>
    AND WO.outwh_seq IN (<foreach collection="list" item="entry" separator=",">#{entry}</foreach>)
</where>
```

### 7.4 `<foreach>` — IN절 / Bulk 처리

**단순 IN절:**
```xml
AND WI.prod_seq IN (<foreach collection="list" item="item" separator=",">#{item}</foreach>)
```

**복합 조건 OR IN절:**
```xml
AND (<foreach collection="list" item="item" separator="OR">
        ( WI.prod_seq = #{item.prodSeq} AND WI.wh_seq = #{item.whSeq} AND WI.loc_seq = #{item.locSeq} )
    </foreach>
    )
```

**Bulk INSERT VALUES 반복:**
```xml
VALUES
<foreach collection="list" item="item" separator=", ">
( #{item.bizSeq}, #{item.centerSeq}, #{item.reqSeq}, #{item.reqProdSeq}
, #{item.prodSeq}, #{item.whSeq}, #{item.locSeq}
, #{item.sku1}, #{item.sku2}
, #{item.mngYmd}, #{item.expYmd}, #{item.lotNo}, #{item.reqQty} )
</foreach>
```

**UNION ALL 반복:**
```xml
<foreach collection="list" item="item" separator="UNION ALL">
SELECT #{item.outwhAssignSeq} AS outwhAssignSeq
     , #{item.reqQty}         AS reqQty
</foreach>
```

> `@Param("seqs") List<Integer> seqs`로 전달한 경우 `collection="seqs"`로 일치시킬 것.

### 7.5 `<include refid="">` — 공통 SQL 재사용

```xml
<include refid="be.comm.CommonSqlMapper.getAuthCenterBiz"/>
<include refid="be.comm.CommonSqlMapper.getDocInfo"/>
```

### 7.6 OGNL 정적 메서드 / 필드 참조

```xml
<!-- 정적 메서드 호출 -->
@fw.tool.EmptyTool@notEmpty( estMngYmd )
@fw.constant.StringPool@NONE.equals( outwhDivId )

<!-- 정적 필드 참조 (DB 함수 prefix 동적 주입) -->
${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{item.regDt})
${@fw.config.DBConfig@DB_PREFIX}FN_GET_YMD()
${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{itemNm}, '%')
```

> `${}` 표현식은 DB 벤더별 prefix를 동적으로 주입하는 용도로만 사용.
> 일반 파라미터는 반드시 `#{}` 사용 (SQL 인젝션 방지).

---

## 8. resultMap 정의

- `<id>` 태그로 PK 매핑
- `<result>` 태그로 일반 컬럼 매핑
- `<collection>` 태그로 1:N 관계 매핑 (`ofType`으로 내부 클래스 지정)
- 단일 테이블이고 AS 별칭으로 camelCase 매핑이 가능하면 `resultType` 우선 사용

```xml
<resultMap id="searchOutwhForOrderPapaersMap" type="be.ow5000.owrq01.abc.bean.OWRQ01OutwhPaper">
    <id column="label_paper_seq" property="labelTypeSeq"/>
    <result column="label_paper_div_cd" property="labelPaperDivCd"/>
    <collection property="docData" ofType="be.ow5000.owrq01.abc.bean.OWRQ01OutwhPaper$Req">
        <result column="outwh_seq"   property="outwhSeq"/>
        <result column="outwh_no"    property="outwhNo"/>
        <result column="req_ymd"     property="reqYmd"/>
    </collection>
</resultMap>
```

---

## 9. 참조

- SQL 텍스트 서식 (들여쓰기·anchor 규칙·대소문자): → [01-sql-query-style.md](./01-sql-query-style.md)
