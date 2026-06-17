---
title: Mapper XML 작성규칙
description: MyBatis Mapper.xml 파일 헤더·SELECT/INSERT/UPDATE/DELETE·WHERE절·JOIN·DB 함수 등 실제 XML 코드 패턴을 작성 시 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: backend
tags:
  - mapper-xml
  - mybatis
  - sql
  - dynamic-sql
  - fn-concat
  - where-tag
  - foreach
related:
  - patterns/30-backend/40-guide/04-mapper-writing-rules.md
last_verified: 2026-04-07
---

# Mapper XML 작성규칙 (Mapper XML Writing Rule)

> 미확인: "80개 이상의 실제 Mapper.xml 파일 분석 기반"이라는 수치 근거는 현재 저장소에서 직접 확인하지 못했다. 2026-03-05 작성 문구만 유지한다.
>
> **규칙 참조**: 백엔드 일반 규칙(레이어/네이밍/예외)은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md),
> SQL 작성 규칙(MyBatis 패턴)은
> [patterns/20-database/30-convention/02-mybatis-convention.md](../../20-database/30-convention/02-mybatis-convention.md) 참조.
> 이 문서는 Mapper XML 작성 시 참고할 **실제 XML 코드 패턴·예시**를 기술합니다.

---

## 1. 파일 헤더 & Namespace

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="be.md8000.mdbz01.MDBZ01Mapper">
```

- namespace = Java 패키지 FQCN + Mapper 클래스명
- UTF-8 인코딩 반드시 명시
- 파일 위치: Mapper.java와 **동일 디렉터리**

---

## 2. SQL 주석

```xml
/* MDBZ01Mapper.searchBizs 사업장 검색 */
/* OWRQ01Mapper.searchOutwhProds 출고 품목 조회 (여러 건) */
/** SMST01Mapper.getMNOptions 사업장 시스템옵션 메뉴별설정 조회 */
```

**형식**: `/* {Mapper클래스명}.{메서드ID} {한글설명} */`

- SELECT/INSERT/UPDATE/DELETE 태그 **바로 다음 줄**에 위치
- 추가 정보는 괄호로: `(여러 건)`, `[수정]`, `[검색]`
- `/* */` 와 `/** */` 모두 사용, 혼용 허용

---

## 3. SELECT 패턴

### 3.1 기본 구조

```xml
<select id="searchBizs"
        parameterType="be.md8000.mdbz01.bean.MDBZ01Search"
        resultType="be.md8000.mdbz01.bean.MDBZ01Search">
    /* MDBZ01Mapper.searchBizs 사업장 검색 */
    SELECT MB.biz_seq    AS bizSeq
         , MB.biz_nm     AS bizNm
         , SCD.comm_d_nm AS whGroupNm     -- 공통코드 한글명 직접 매핑
      FROM MDM_BIZ MB
      LEFT JOIN SM_COMM_D SCD ON SCD.comm_d_cd = MB.biz_div_cd
                             AND SCD.comm_h_cd  = 'BIZ_DIV_CD'
                             AND SCD.biz_seq    = -1
     WHERE MB.use_yn = 'Y'
     ORDER BY MB.reg_dt
</select>
```

### 3.2 parameterType 규칙

| 파라미터 유형 | 선언 방식 |
|---|---|
| 단일 DTO | `be.md8000.mdbz01.bean.MDBZ01Search` (FQCN) |
| 리스트 | `java.util.ArrayList` |
| 기본형 | `Integer`, `String` |
| 파라미터 없음 | 속성 생략 |

### 3.3 resultType vs resultMap

- **resultType**: 대부분의 경우 사용. 컬럼 AS alias → camelCase 프로퍼티 자동 매핑
- **resultMap**: 중첩 컬렉션(`collection`)이 필요한 경우에만 사용

```xml
<!-- resultMap 예시 - 중첩 컬렉션 -->
<resultMap id="outwhPaperMap" type="be.ow5000.owrq01.abc.bean.OWRQ01OutwhPaper">
    <id column="label_paper_seq" property="labelTypeSeq"/>
    <collection property="docData" ofType="be.ow5000.owrq01.abc.bean.OWRQ01OutwhPaper$Req">
        <result column="outwh_seq" property="outwhSeq"/>
    </collection>
</resultMap>
```

### 3.4 컬럼 alias 규칙

- snake_case → camelCase 변환 (자동 매핑)
- 테이블 alias 항상 명시 (`MB.`, `MW.`, `MC.`)

```xml
SELECT MB.biz_seq      AS bizSeq
     , MW.wh_nm        AS whNm
     , SCD.comm_d_nm   AS whGroupNm    -- 공통코드 JOIN 시 한글명 직접 매핑
```

---

## 4. WHERE 절 패턴

### 4.1 규칙 요약

| 규칙 | 코드 |
|---|---|
| null/빈값 체크 | `@fw.tool.EmptyTool@notEmpty( 변수 )` |
| LIKE 검색 | `${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{nm}, '%')` |
| 날짜 범위 | `<![CDATA[ AND col >= #{fr} ]]>` |
| IN 절 | `<foreach ... open="(" close=")" separator=", ">` |
| IF-ELSE | `<choose><when>...</when><otherwise>...</otherwise></choose>` |

### 4.2 \<where\> 태그 (동적 조건)

```xml
<where>
    AND WI.use_yn = 'Y'
    <if test="@fw.tool.EmptyTool@notEmpty( bizSeq )">
    AND WI.biz_seq = #{bizSeq}
    </if>
    <if test="@fw.tool.EmptyTool@notEmpty( prodNm )">
    AND MP.prod_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{prodNm}, '%')
    </if>
    <if test="@fw.tool.EmptyTool@notEmpty( ymdFr )">
    <![CDATA[ AND WI.proc_ymd >= #{ymdFr} ]]>
    </if>
    <if test="@fw.tool.EmptyTool@notEmpty( contDivCds )">
    AND MC.cont_div_cd IN
    <foreach collection="contDivCds" item="entry" open="(" close=")" separator=", ">
        #{entry}
    </foreach>
    </if>
</where>
```

> **규칙**: 동적 조건이 있으면 반드시 `<where>` 태그 사용. null/빈값 체크는 반드시 `@fw.tool.EmptyTool@notEmpty()` 사용.

### 4.3 LIKE 검색

```xml
AND MB.biz_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{bizNm}, '%')

-- 복합 컬럼 LIKE
AND (MC.addr || ' ' || MC.addr_dtl) LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{addr}, '%')

-- 바코드/명칭 OR 검색
AND (ML.loc_barcode = #{locBarcode} OR ML.loc_nm LIKE ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%',#{locBarcode},'%'))
```

> **규칙**: LIKE는 반드시 `FN_CONCAT()` 사용. 직접 `||` 연결 금지.

### 4.4 날짜 범위 조건 (CDATA)

```xml
<if test="@fw.tool.EmptyTool@notEmpty(mngYmdFr)">
<![CDATA[ AND WIS.mng_ymd >= #{mngYmdFr} ]]>
</if>
<if test="@fw.tool.EmptyTool@notEmpty(mngYmdTo)">
<![CDATA[ AND WIS.mng_ymd <= #{mngYmdTo} ]]>
</if>
```

> **규칙**: `<`, `>`, `>=`, `<=` 연산자는 반드시 `<![CDATA[ ... ]]>` 감싸기.

### 4.5 IN 절 (\<foreach\>)

```xml
-- 배열 파라미터 IN
AND MC.cont_div_cd IN
<foreach collection="contDivCds" index="index" item="entry" open="(" close=")" separator=", ">
    #{entry}
</foreach>

-- 객체 리스트 IN
WHERE cont_seq IN
<foreach collection="list" index="index" item="item" open="(" close=")" separator=", ">
    #{item.contSeq}
</foreach>
```

### 4.6 choose / when / otherwise

```xml
<choose>
    <when test='@fw.constant.WMSPool@AUTH_TYPE_SUPER.equals(loginAuthTypeCd)'>
        AND WIM.biz_seq IN (SELECT biz_seq FROM MDM_BIZ_BIZ)
    </when>
    <when test='@fw.constant.WMSPool@AUTH_TYPE_CENTER.equals(loginAuthTypeCd)'>
        AND WIM.center_seq IN (SELECT center_seq FROM MDM_USER_CENTER)
    </when>
    <otherwise>
        AND WIM.biz_seq IN (SELECT biz_seq FROM MDM_USER_BIZ)
    </otherwise>
</choose>
```

---

## 5. INSERT 패턴

### 5.1 단건 등록 (useGeneratedKeys)

```xml
<insert id="insertBiz"
        parameterType="be.md8000.mdbz01.bean.MDBZ01Biz"
        useGeneratedKeys="true"
        keyProperty="bizSeq">
    /* MDBZ01Mapper.insertBiz 사업장 등록 */
    INSERT INTO MDM_BIZ
    (
          biz_nm
        , biz_nm_short
        , use_yn
        , reg_id
        , reg_dt
    )
    VALUES
    (
          #{bizNm}
        , #{bizNmShort}
        , #{useYn}
        , #{regId}
        , ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{regDt})
    )
</insert>
```

- PK 자동증가: `useGeneratedKeys="true"` + `keyProperty="시퀀스프로퍼티명"`
- 일시(timestamp) 컬럼: 반드시 `FN_GET_DT(#{regDt})` 사용
- 컬럼 목록과 VALUES 줄 맞춤 (가독성)

### 5.2 일괄 등록 (foreach)

```xml
<insert id="insertOutwhAssigns" parameterType="java.util.ArrayList">
    /* OWRQ01Mapper.insertOutwhAssigns 출고지시 지정데이터 일괄 등록 */
    INSERT INTO WMS_OUTWH_ASSIGN
    ( biz_seq, center_seq, req_seq, prod_seq, wh_seq, reg_id, reg_dt )
    VALUES
    <foreach collection="list" item="item" separator=", ">
    ( #{item.bizSeq}, #{item.centerSeq}, #{item.reqSeq}, #{item.prodSeq},
      #{item.whSeq}, #{item.regId}, ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{item.regDt}) )
    </foreach>
</insert>
```

### 5.3 INSERT 후 직전 PK 참조 (FN_CURRVAL)

```xml
-- 헤더 INSERT 후 자동 생성된 PK를 상세에서 참조
INSERT INTO WMS_RETURN_PROD
SELECT (
    SELECT ${@fw.config.DBConfig@DB_PREFIX}FN_CURRVAL('wms_return')
) AS return_seq
, #{detail.prodSeq}, #{detail.reqQty} ...
```

---

## 6. UPDATE 패턴

### 6.1 기본 UPDATE

```xml
<update id="updateBiz" parameterType="be.md8000.mdbz01.bean.MDBZ01Biz">
    /* MDBZ01Mapper.updateBiz 사업장 수정 */
    UPDATE MDM_BIZ
       SET biz_nm       = #{bizNm}
         , biz_nm_short = #{bizNmShort}
         , use_yn       = #{useYn}
         , mod_id       = #{modId}
         , mod_dt       = ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{modDt})
     WHERE biz_seq = #{bizSeq}
</update>
```

### 6.2 삭제 패턴

> 삭제 기준 SSoT는 [01-coding-convention.md](../30-convention/01-coding-convention.md) §12를 우선 참조한다.
>
> | 테이블 유형 | 삭제 방식 | 메서드 태그 |
> |---|---|---|
> | `MDM_*` 기준정보 | 논리삭제(소프트삭제) — `UPDATE SET use_yn = 'N'` | `<update>` |
> | `WMS_*` 업무 | `del_yn` 컬럼이 있으면 논리삭제 — `UPDATE SET del_yn = 'Y'` | `<update>` |
> | 삭제 플래그 없는 매핑·처리 테이블 | 기존 소스/스키마 확인 후 물리삭제 — `DELETE FROM` | `<delete>` |

```xml
<!-- MDM_* 기준정보 테이블: 논리삭제(소프트삭제) -->
<update id="deleteBiz" parameterType="be.md8000.mdbz01.bean.MDBZ01Biz">
    /* MDBZ01Mapper.deleteBiz 사업장 삭제 */
    UPDATE MDM_BIZ
       SET use_yn = 'N'
         , mod_id = #{modId}
         , mod_dt = ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{modDt})
     WHERE biz_seq = #{bizSeq}
</update>

<!-- 삭제 플래그 없는 매핑·처리 테이블: 물리삭제 -->
<delete id="deleteOutwh" parameterType="be.ow5000.owxx01.bean.OWXX01Outwh">
    /* OWXX01Mapper.deleteOutwh 출고 삭제 */
    DELETE FROM WMS_OUTWH
     WHERE outwh_seq = #{outwhSeq}
</delete>
```

### 6.3 일괄 UPDATE (FROM + foreach)

```xml
<update id="updateOutwhAssigns" parameterType="java.util.ArrayList">
    /* OWRQ01Mapper.updateOutwhAssigns 출고지시 지정데이터 일괄 수정 */
    UPDATE WMS_OUTWH_ASSIGN
       SET req_qty = req_qty + ASSIGN.reqQty
         , mod_id  = ASSIGN.modId
         , mod_dt  = ASSIGN.modDt
      FROM (
             SELECT outwhAssignSeq, SUM(reqQty) AS reqQty, MAX(modId) AS modId, MAX(modDt) AS modDt
               FROM (
                    <foreach collection="list" item="item" separator="UNION ALL">
                    SELECT #{item.outwhAssignSeq} AS outwhAssignSeq
                         , #{item.reqQty}         AS reqQty
                         , #{item.modId}          AS modId
                         , ${@fw.config.DBConfig@DB_PREFIX}FN_GET_DT(#{item.modDt}) AS modDt
                    </foreach>
                   ) A
              GROUP BY outwhAssignSeq
           ) ASSIGN
     WHERE WMS_OUTWH_ASSIGN.outwh_assign_seq = ASSIGN.outwhAssignSeq
</update>
```

---

## 7. DELETE 패턴

물리 DELETE는 극소수다. 대부분 논리삭제(소프트삭제, UPDATE) 패턴을 사용한다.

```xml
<!-- 물리 DELETE (use_yn/del_yn 컬럼 없는 순수 매핑 테이블에만 허용) -->
<delete id="deleteUserBiz">
    /* SMXX01Mapper.deleteUserBiz 사용자 사업장 권한 삭제 */
    DELETE FROM MDM_USER_BIZ
     WHERE user_id = #{userId}
       AND biz_seq = #{bizSeq}
</delete>
```

---

## 8. JOIN 규칙

### 8.1 테이블 alias 네이밍

| 테이블 | alias |
|---|---|
| MDM_BIZ | MB |
| MDM_WH | MW |
| MDM_CENTER | MC |
| MDM_LOC | ML |
| MDM_PROD | MP |
| MDM_CONT | MCN |
| SM_COMM_D | SCD |
| SM_COMM_H | SCH |
| SM_FILE | SF |

- 동일 테이블 복수 JOIN: `MW1`, `MW2` 또는 의미 있는 alias 사용

### 8.2 공통코드(SM_COMM_D) JOIN 패턴

```xml
LEFT JOIN SM_COMM_D SCD ON SCD.comm_d_cd = MW.wh_group_cd
                       AND SCD.comm_h_cd  = 'WH_GROUP_CD'
                       AND SCD.biz_seq    = -1
```

- `comm_h_cd`: 코드 분류 (대문자 상수)
- `biz_seq = -1`: 시스템 공통코드 (전사 공용)

---

## 9. 프로젝트 전용 DB 함수

| 함수 | 용도 | 예시 |
|---|---|---|
| `FN_GET_DT(#{dt})` | timestamp 저장 | `${...}FN_GET_DT(#{regDt})` |
| `FN_GET_YMD()` | 오늘 날짜 YYYYMMDD | `${...}FN_GET_YMD()` |
| `FN_CONCAT(a, b, c)` | 문자열 연결 (LIKE용) | `${...}FN_CONCAT('%', #{nm}, '%')` |
| `FN_CURRVAL('테이블')` | 직전 INSERT PK 조회 | `${...}FN_CURRVAL('wms_return')` |

**prefix 전체**: `${@fw.config.DBConfig@DB_PREFIX}`

---

## 10. \<sql\> Fragment 재사용

```xml
<!-- 정의 -->
<sql id="getAuthBizSeqs">
    SELECT biz_seq FROM MDM_USER_BIZ WHERE user_id = #{userId}
</sql>

<!-- 같은 파일 내 참조 -->
<include refid="getAuthBizSeqs"/>

<!-- 다른 Mapper 참조 -->
<include refid="be.sm9000.smst01.SMST01Mapper.getAuthBizSeqs"/>

<!-- 공통 Mapper 참조 -->
<include refid="be.comm.CommonSqlMapper.getAuthCenterBiz"/>
<include refid="be.comm.CommonSqlMapper.getAuthCenterBizInInven"/>
```

---

## 11. 삭제 필터 규칙

모든 SELECT 쿼리에 반드시 포함:

| 테이블 유형 | 필수 조건 |
|---|---|
| MDM_* (기준정보) | `AND XX.use_yn = 'Y'` |
| WMS_* (업무) | `del_yn` 컬럼이 있으면 `AND XX.del_yn = 'N'` |
| 삭제 플래그 없는 매핑·처리 테이블 | 실제 스키마와 기존 Mapper 패턴 확인 |

```xml
-- 기준정보 테이블 (MDM_*): 논리삭제 필터 필수
WHERE MB.use_yn = 'Y'

-- 업무 테이블 (WMS_*): del_yn 컬럼이 있으면 삭제 필터 필수
WHERE WI.del_yn = 'N'
```

---

## 12. 자주 쓰는 패턴 모음

### 12.1 COALESCE 기본값

```xml
VALUES (
    #{bizNm}
  , COALESCE(#{inYn}, 'N')
  , #{regId}
)
```

### 12.2 조건부 JOIN

```xml
<if test="@fw.tool.EmptyTool@notEmpty( outwhSeqList )">
    LEFT JOIN WMS_OUTBIZ_OUTWH WOO ON WOO.outbiz_seq = WOP.outbiz_seq
</if>
```

### 12.3 CASE WHEN 상태 변환

```xml
CASE WHEN MBC.cfm_yn = 'Y' AND MBC.use_yn = 'Y' THEN 'ACCEPT'
     WHEN MBC.cfm_yn = 'Y' AND MBC.use_yn = 'N' THEN 'DENIED'
     WHEN MBC.cfm_yn = 'N' AND MBC.use_yn = 'N' THEN 'REQUEST'
END AS statusCd
```

### 12.4 OR 복합 조건 foreach

```xml
AND (
<foreach collection="list" item="item" separator="OR">
    ( WI.prod_seq = #{item.prodSeq} AND WI.wh_seq = #{item.whSeq} )
</foreach>
)
```
