---
title: OMS BE 로그인·인증 가이드
description: kyochon-oms-be의 로그인 API, JWT 토큰 구조, curl·JUnit 테스트 인증 방법을 다룬다. API 테스트·스크립트 작성 전 반드시 참조한다.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
project: kyochon_oms
domain: oms
tags:
  - auth
  - login
  - jwt
  - curl
  - api-test
last_verified: 2026-06-23
---

# OMS BE 로그인·인증 가이드

## 1. 전제 — 로컬 서버 정보

| 항목 | 값 |
|---|---|
| 로컬 BE 기동 URL | `http://localhost:8080/oms-be` |
| 컨텍스트 경로 | `/oms-be` |
| API 경로 패턴 | `/{bizSeq}/{메뉴코드}/...` (인증 필요) |
| 테스트용 bizSeq | `1` |
| 테스트 계정 | `tec01` / `1111` (authTypeCd=`B`, regBizSeq=1) |

---

## 2. 로그인 API

### 2-1. 엔드포인트

```
POST /oms-be/login
```

- 인증 불필요(permit all)
- `User-Agent` 헤더 필수(없으면 Spring 바인딩 오류)

### 2-2. 요청

```json
{
  "userId": "tec01",
  "password": "1111"
}
```

헤더:
```
Content-Type: application/json
User-Agent: pc
```

### 2-3. 응답

**응답 헤더** (토큰이 여기에 있음):

| 헤더 이름 | 값 예시 | 설명 |
|---|---|---|
| `Authorization` | `eyJhbGciOiJIUzI1NiJ9...` | 액세스 토큰 (JWT, grantType 없이 토큰만) |
| `grant-type` | `Bearer` | grantType 고정값 |
| `refresh-token` | `eyJhbGciOiJIUzI1NiJ9...` | 리프레시 토큰 |

**응답 바디** (일부):
```json
{
  "succeed": true,
  "userInfo": {
    "userId": "tec01",
    "userNm": "...",
    "authTypeCd": "B",
    "regBizSeq": 1
  }
}
```

### 2-4. 2단계 로그인 (check-user → login)

브라우저는 2단계로 동작한다. API 테스트에서는 `/login` 직접 호출로 충분하다.

```
POST /oms-be/check-user  → ID/PW 확인만 (토큰 미발급)
POST /oms-be/login       → 실제 로그인 + 토큰 발급
```

---

## 3. JWT 인증 — 핵심 규칙

### 3-1. 요청 헤더 형식

```
MUST: Authorization: Bearer{ACCESS_TOKEN}
```

- `grantType = "Bearer"` (하드코딩, 공백 없음)
- `Bearer` + 토큰을 **공백 없이** 바로 붙인다.
- ❌ 잘못된 예: `Authorization: Bearer eyJhbG...` (공백 있음)
- ✅ 올바른 예: `Authorization: BearereyJhbG...`

**이유**: `TokenAuthenticationFilter.getAccessToken()`이 `bearerToken.startsWith("Bearer")` 확인 후 `substring(6)`으로 파싱한다. "Bearer"가 6글자이므로 인덱스 6부터가 토큰 본문이다.

```java
// fw/filter/TokenAuthenticationFilter.java
String bearerToken = request.getHeader("Authorization");
if (bearerToken.startsWith("Bearer")) {     // "Bearer"(6자)로 시작하면
    return bearerToken.substring(6);        // 인덱스 6 이후 = 토큰 본문
}
```

### 3-2. 로그인 응답 헤더 vs 요청 헤더 차이

| 구분 | Authorization 헤더 값 |
|---|---|
| 로그인 응답(서버→클라이언트) | `{토큰만}` (grantType 없음) |
| API 요청(클라이언트→서버) | `Bearer{토큰}` (grantType 붙임, 공백 없음) |

---

## 4. curl 테스트 — 표준 절차

### 4-1. 로그인 + 토큰 추출

```bash
BASE="http://localhost:8080/oms-be"

# 로그인
curl -sS -D /tmp/oms_hdr.txt -X POST "$BASE/login" \
  -H "Content-Type: application/json" -H "User-Agent: pc" \
  -d '{"userId":"tec01","password":"1111"}' \
  -o /tmp/oms_login.json -w "login HTTP %{http_code}\n"

# 토큰 추출 + Bearer 조합 (공백 없이)
TOKEN=$(grep -i '^Authorization:' /tmp/oms_hdr.txt | head -1 \
  | sed 's/^[Aa]uthorization:[[:space:]]*//' | tr -d '\r\n')
AUTH="Bearer${TOKEN}"
```

### 4-2. 인증 필요 API 호출 패턴

```bash
curl -sS -X POST "$BASE/1/{메뉴코드}/list" \
  -H "Content-Type: application/json" \
  -H "User-Agent: pc" \
  -H "Authorization: ${AUTH}" \
  -d '{...검색조건...}' \
  -w "HTTP %{http_code}\n"
```

### 4-3. SHST01 현황조회 예시 (검증 완료)

```bash
# 검색조건 없음 (전체)
curl -sS -X POST "$BASE/1/shst01/list" \
  -H "Content-Type: application/json" -H "User-Agent: pc" \
  -H "Authorization: ${AUTH}" \
  -d '{}' -w "HTTP %{http_code}\n"

# 날짜 범위 지정
curl -sS -X POST "$BASE/1/shst01/list" \
  -H "Content-Type: application/json" -H "User-Agent: pc" \
  -H "Authorization: ${AUTH}" \
  -d '{"orderDtFrom":"20250101","orderDtTo":"20261231"}' \
  -w "HTTP %{http_code}\n"
```

---

## 5. JUnit 테스트 인증

JUnit(Spring 컨텍스트) 테스트에서는 **실제 JWT 토큰 없이** 모의 인증을 사용한다.

### 5-1. @WithMockCustomUser (Comp/Controller 계층)

```java
@Test
@WithMockCustomUser   // ← 이 어노테이션만 붙이면 인증 통과
@Transactional
public void test_xxx() { ... }
```

기본값: `loginUserId="JUNIT"`, `authTypeCd=SUPER`, `regBizSeq=1`

### 5-2. 레이어별 인증 필요 여부

| 레이어 | 인증 어노테이션 | 이유 |
|---|---|---|
| Mapper | 불필요 | Spring 컨텍스트 없이 MyBatis 직접 |
| Dao | 불필요 | `ZTEST_Dao` 베이스, SecurityContext 없어도 동작 |
| Comp | `@WithMockCustomUser` 필요 | SecurityContext에서 로그인 사용자 조회하는 경우 있음 |
| Controller | `@WithMockCustomUser` 필요 | Security 필터 통과 필요 |

---

## 6. 토큰 설정값 (application-dev.properties)

| 설정 키 | 값 | 설명 |
|---|---|---|
| `jwt.header` | `Authorization` | 요청/응답 헤더 이름 |
| `jwt.accessExpirationMilliseconds` | `3600000` | 액세스 토큰 만료: 1시간 |
| `jwt.refreshExpirationMilliseconds` | `1209600000` | 리프레시 토큰 만료: 14일 |
| grantType (하드코딩) | `Bearer` | 공백 없음, `TokenProvider.java:50` |

### JWT 클레임 구조

```json
{
  "sub": "tec01",
  "jti": "uuid",
  "userNm": "...",
  "bizSeq": 1,
  "authTypeCd": "B",
  "ifEmpNo": "-",
  "exp": 1782181758
}
```

---

## 7. 인증 인터셉터 — 동작 흐름

```
요청 헤더 Authorization 존재?
  ├─ YES → startsWith("Bearer") ?
  │         YES → substring(6) = 토큰 본문 → JWT 검증 → SecurityContext 설정
  │         NO  → accessToken = null
  └─ NO  → apikey 헤더 존재?
             YES → API 키 검증
             NO  → permitAllArray URL인지 확인
                    NO → 401 {"message":"키가 존재하지 않습니다."}
```

관련 파일: `fw/filter/TokenAuthenticationFilter.java`

---

## 8. 인증 불필요 URL (permitAll)

| 경로 | 설명 |
|---|---|
| `POST /oms-be/login` | 로그인 |
| `POST /oms-be/check-user` | 1차 사용자 확인 |
| `GET /oms-be/logout/{userId}` | 로그아웃 |

그 외 모든 `/{bizSeq}/...` 경로는 인증 필요.

---

## 9. 중복 로그인 방지 (jti 기반)

### 9-1. 동작 원리

로그인 시마다 `UUID.randomUUID()`로 새 jti를 생성해 JWT의 `setId(uuid)`에 삽입하고, DB의 `MDM_USER.last_access_jti` 컬럼에 저장한다. 이후 모든 요청마다 토큰의 jti와 DB 저장값을 비교해 중복 로그인을 차단한다.

```
로그인(POST /login)
  → UUID 생성 → JWT.setId(uuid)  ← JWT claim "jti"
  → MDM_USER.last_access_jti = uuid  UPDATE

이후 API 요청마다 (TokenAuthenticationFilter):
  → JWT 파싱 → claims.getId() == DB의 last_access_jti ?
        일치 → 정상 통과
        불일치 → AnotherLoginException → 응답 {"exception":"AnotherLoginException"}
```

### 9-2. 적용 대상 조건

**두 조건을 모두 충족할 때만** 중복 로그인 체크가 동작한다.

| 조건 | 코드 |
|---|---|
| JWT claim `ifEmpNo`가 비어있지 않아야 함 | `EmptyTool.notEmpty(claims.get("ifEmpNo"))` |
| 요청 URL이 `/logout/*` 가 아니어야 함 | 로그아웃 중에는 체크 안 함 |

> `EmptyTool.empty(String)`은 `null` 또는 `""`(빈 문자열)만 empty로 판단한다. `"-"`는 **notEmpty** → 체크 대상이다.
> tec01의 `ifEmpNo = "-"` 이므로 중복 로그인 체크가 **활성화된다**.

### 9-3. 체크 흐름 (TokenAuthenticationFilter.java:114-136)

```java
// 1. JWT에서 클레임 파싱
Claims claims = tokenProvider.parseClaims(accessToken);

// 2. ifEmpNo 있고, 로그아웃 URL 아니면 체크
if (EmptyTool.notEmpty(claims.get("ifEmpNo")) && !url.matches("/logout/*")) {

    // 3. DB에서 마지막 로그인 jti 조회
    String lastLoginJti = loginDao.selectLastLoginTokenId(claims.getSubject()); // userId

    // 4. 토큰 jti와 DB jti 비교
    if (EmptyTool.notEmpty(lastLoginJti) && !lastLoginJti.equals(claims.getId())) {
        // 다른 기기에서 로그인한 상태 → 현재 요청 차단
        response.put("exception", "AnotherLoginException");
        throw new AnotherLoginException("다른곳에서 로그인 하였습니다.");
    }
}
```

### 9-4. DB 컬럼

| 테이블 | 컬럼 | 설명 |
|---|---|---|
| `MDM_USER` | `last_access_jti` | 마지막 로그인 액세스 토큰의 UUID(jti) |
| `MDM_USER` | `user_id` | WHERE 조건 (JWT `sub` claim) |

관련 SQL (`fw/login/LoginMapper.xml`):
```sql
-- 로그인 시 저장
UPDATE MDM_USER SET last_access_jti = #{tokenId}, mod_id = #{userId}, mod_dt = ... WHERE user_id = #{userId}

-- 요청마다 조회
SELECT last_access_jti FROM MDM_USER WHERE user_id = #{userId}
```

### 9-5. 중복 로그인 차단 응답

```json
{"exception": "AnotherLoginException"}
```

FE는 이 `exception` 값을 보고 "다른 기기에서 로그인되었습니다" 팝업을 표시한다.

### 9-6. JWT jti 생성 위치

```java
// fw/auth/token/TokenProvider.java:61-63
String uuid = UUID.randomUUID().toString();
String accessToken = generateAccessToken(authentication, uuid);

// generateAccessToken 내부
Jwts.builder()
    .setSubject(userId)
    .setId(uuid)          // ← JWT "jti" claim = UUID
    ...
```

---

## 10. 로그아웃

```bash
curl -sS -X GET "$BASE/logout/tec01" \
  -H "User-Agent: pc" \
  -H "Authorization: ${AUTH}" \
  -w "HTTP %{http_code}\n"
```
