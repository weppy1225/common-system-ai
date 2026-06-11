---
title: Mapper 작성규칙
description: {MenuCode}Mapper 인터페이스 선언·@Param 사용 패턴·메서드 시그니처·반환 타입 코드 예시를 작성 시 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: backend
tags:
  - mapper
  - mybatis
  - param
  - interface
related:
  - 10-src-pattern/30-backend/40-guide/05-mapper-xml-writing-rules.md
  - 10-src-pattern/30-backend/40-guide/03-dao-writing-rules.md
last_verified: 2026-04-07
---

# Mapper 작성규칙 ({MenuCode}Mapper Writing Rules)

> **규칙 참조**: 메서드 네이밍·`@Param` 일반 규칙은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 Mapper 인터페이스 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **인터페이스명**: `{메뉴코드}Mapper`
- **역할**: MyBatis 매퍼 인터페이스. SQL 실행 명세, 파라미터/결과 매핑
- **계층**: Dao → **Mapper** → SQL (Mapper XML)

## 2. 인터페이스 선언 예시

```java
@Repository
public interface {메뉴코드}Mapper {
    // 메서드 선언
}
```

## 3. @Param 사용 패턴

### 3.1 단일 파라미터 (생략 가능)

```java
int searchExistInven(Integer prodSeq);

// VO/DTO 객체 단일 파라미터도 생략 가능
List<{메뉴코드}Search> searchProds({메뉴코드}Search searchProd);
int insertProd({메뉴코드}Prod insertProd);
```

### 3.2 다중 파라미터 (모두 @Param 필수)

```java
{메뉴코드}Prod selectProd(
    @Param("loginBizSeq") Integer loginBizSeq,
    @Param("prodSeq")     Integer prodSeq
);

int deleteProds(
    @Param("bizSeq")   Integer bizSeq,
    @Param("prodSeqs") List<Integer> prodSeqs
);
```

### 3.3 Collection 파라미터 (항상 @Param)

```java
List<ValidError> checkDuplicateProdNo(
    @Param("bizSeq")   Integer bizSeq,
    @Param("prodSeq")  Integer prodSeq,
    @Param("prodNos")  List<String> prodNos       // List는 @Param 필수
);

List<ValidError> checkCommCd(@Param("excelData") List<{메뉴코드}Prod> excelData);
```

## 4. 메서드 시그니처 예시

### 4.1 CRUD 메서드

```java
/** {리소스} 등록 */
int insertProd({메뉴코드}Prod insertProd);

/**
 * {리소스} 목록 조회
 *
 * @param searchProd 검색 조건
 * @return 조회 결과 목록
 */
List<{메뉴코드}Search> searchProds({메뉴코드}Search searchProd);

/**
 * {리소스} 단건 조회
 *
 * @param loginBizSeq 사업장 seq
 * @param prodSeq     품목 seq
 * @return 품목 정보 (없으면 null)
 */
{메뉴코드}Prod selectProd(@Param("loginBizSeq") Integer loginBizSeq,
                         @Param("prodSeq") Integer prodSeq);

/** {리소스} 수정 */
int updateProd({메뉴코드}Prod updateProd);

/**
 * {리소스} 소프트 삭제
 *
 * @param bizSeq   사업장 seq
 * @param prodSeqs 삭제 대상 seq 목록
 * @return 처리 건수
 */
int deleteProds(@Param("bizSeq") Integer bizSeq,
                @Param("prodSeqs") List<Integer> prodSeqs);
```

### 4.2 검증/체크 메서드

```java
// 중복 체크
List<ValidError> checkDuplicateProdNo(@Param("bizSeq") Integer bizSeq,
                                      @Param("prodSeq") Integer prodSeq,
                                      @Param("prodNos") List<String> prodNos);

// 타 테이블 참조 체크
{메뉴코드}Prod checkProdSeqInOtherTbl(@Param("bizSeq") Integer bizSeq,
                                     @Param("prodSeq") Integer prodSeq);

// 이력 존재 체크
boolean checkProdLabelAndProc(Integer prodSeq);

// 재고 존재 체크
int searchExistInven(Integer prodSeq);
```

## 5. 반환 타입 가이드

| 반환 타입 | 설명 | 예시 메서드 |
|-----------|------|-------------|
| `List<T>` | 여러 건 조회 (null 금지) | `searchProds` |
| `T` | 단일 객체 (없으면 null) | `selectProd` |
| `int` | 처리 건수 (INSERT/UPDATE/DELETE) | `insertProd` |
| `boolean` | 존재 여부 | `checkProd` |
| `List<ValidError>` | 검증 오류 목록 | `checkDuplicateProdNo` |

## 6. SQL 매핑 (XML 연동) 예시

```xml
<!-- 메서드명과 SQL ID 일치 -->
<select id="searchProds" parameterType="be.{...}.bean.{메뉴코드}Search"
                         resultType="be.{...}.bean.{메뉴코드}Search">
    <!-- 예시 테이블: mdm_prod -->
    SELECT * FROM mdm_prod WHERE ...
</select>

<!-- @Param 이름으로 파라미터 참조 -->
<select id="selectProd" resultType="be.{...}.bean.{메뉴코드}Prod">
    SELECT * FROM mdm_prod
    WHERE biz_seq = #{loginBizSeq} AND prod_seq = #{prodSeq}
</select>

<!-- Collection 파라미터는 foreach 사용 -->
<delete id="deleteProds">
    DELETE FROM mdm_prod
    WHERE prod_seq IN
    <foreach collection="prodSeqs" item="item" open="(" separator="," close=")">
        #{item}
    </foreach>
</delete>
```

> Mapper XML 상세 패턴은 [05-mapper-xml-writing-rules.md](05-mapper-xml-writing-rules.md) 참조.

## 7. 메서드 설계 원칙

- **단일 책임**: 하나의 메서드는 하나의 SQL 작업만 수행. XML의 SQL ID와 1:1 대응이 유지되어야 추적이 쉽다.
- **VO/DTO 그룹화**: 관련 파라미터는 객체로 묶어 전달. 파라미터명이 늘어날수록 `@Param` 누락 위험이 커진다.
- **Collection 일괄 처리**: 다건 처리에는 List 활용. XML `<foreach>`와 짝을 맞추기 쉽다.
- **반환값**: 빈 컬렉션 선호, 처리 건수는 항상 int. 상위 계층이 결과 건수를 그대로 판단한다.

## 8. 작성 시 주의사항

1. **@Param 남용 금지**: 단일 파라미터는 생략
2. **Collection 파라미터**: 항상 `@Param` 필수
3. **boolean 반환**: MyBatis가 0/1을 자동 변환
4. **List 반환**: 결과 없으면 빈 리스트 반환 (MyBatis 기본 동작)
5. **메서드 오버로딩 지양**: 유사 기능은 파라미터로 구분
