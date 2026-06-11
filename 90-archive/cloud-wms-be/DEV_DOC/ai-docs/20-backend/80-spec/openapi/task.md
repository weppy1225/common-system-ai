---
title: springdoc-openapi 적용 작업 목록
description: springdoc-openapi 라이브러리 적용으로 OpenAPI JSON 자동 생성 및 프로파일별 노출 제어
status: draft
wms_meta: true
project: cloud-wms-be
agent_usage: task
tags:
  - openapi
  - springdoc
  - swagger
---

# springdoc-openapi 적용 작업 목록

## 목표

- Spring Boot 코드 기반으로 OpenAPI 3.0 스펙 JSON 자동 생성 (`/v3/api-docs`)
- `dev` / `test` 환경에서만 노출, `prod` 환경에서는 완전 차단
- 코딩 에이전트가 서버 기동 후 코드 탐색 없이 API 스펙을 조회할 수 있도록 함

---

## 체크리스트

### 1. 의존성 추가 (`build.gradle`)

- [x] `springdoc-openapi-ui:1.7.0` 의존성 추가
  ```groovy
  // build.gradle dependencies 블록
  implementation 'org.springdoc:springdoc-openapi-ui:1.7.0'
  ```
  > Spring Boot 2.7.x 호환 버전: `1.7.x` (2.x는 Spring Boot 3.x 전용)

---

### 2. 프로파일별 노출 설정 (properties)

- [x] `application-dev.properties` — 활성화
  ```properties
  springdoc.api-docs.enabled=true
  springdoc.swagger-ui.enabled=true
  springdoc.swagger-ui.path=/swagger-ui.html
  ```

- [x] `application-test.properties` — api-docs만 활성화, UI 비활성화
  ```properties
  springdoc.api-docs.enabled=true
  springdoc.swagger-ui.enabled=false
  ```

- [x] `application-prod.properties` — 완전 비활성화
  ```properties
  springdoc.api-docs.enabled=false
  springdoc.swagger-ui.enabled=false
  ```

---

### 3. Security 인증 우회 설정 (`FwPool.java`)

- [x] `FwPool.permitAllArray`에 springdoc 엔드포인트 추가
  ```java
  // 현재
  public static final String[] permitAllArray = new String[] {
      "/signup/**", "/login", "/view/**", "/endpoint/**",
      "/pub/**", "/sub/**", "/api/sse/**", "/health"
  };

  // 변경 후
  public static final String[] permitAllArray = new String[] {
      "/signup/**", "/login", "/view/**", "/endpoint/**",
      "/pub/**", "/sub/**", "/api/sse/**", "/health",
      "/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html"
  };
  ```
  > `prod`에서는 `springdoc.api-docs.enabled=false`로 엔드포인트 자체가 등록되지 않으므로
  > permitAll 배열에 포함해도 보안 문제 없음

---

### 4. OpenApiConfig 클래스 작성 (`fw/config/OpenApiConfig.java`)

- [x] `OpenAPI` Bean 등록 — API 메타정보(title, version, description) 설정
  ```java
  @Configuration
  @ConditionalOnProperty(name = "springdoc.api-docs.enabled", havingValue = "true")
  public class OpenApiConfig {

      @Bean
      public OpenAPI openAPI() {
          return new OpenAPI()
              .info(new Info()
                  .title("WMS API")
                  .version("1.0.0")
                  .description("WMS 백엔드 REST API 명세"));
      }
  }
  ```

---

### 5. 빌드 및 동작 검증

- [x] `./gradlew clean build -x test` — 컴파일 에러 없음 확인
- [x] `./gradlew bootRun` (dev 프로파일) 기동
- [x] `GET http://localhost:{port}/wms-be/v3/api-docs` 응답 확인
  - `200 OK` + JSON 반환 → 정상 ✅
- [x] `GET http://localhost:{port}/wms-be/swagger-ui.html` 브라우저 접근 확인
- [ ] `application-prod.properties` 기준 기동 시 `/v3/api-docs` → `404` 확인

---

### 6. 컨텍스트 경로 주의사항

> `application-dev.properties`에 `server.servlet.context-path=/wms-be` 설정됨.
> 실제 접근 URL:
> - `/wms-be/v3/api-docs`
> - `/wms-be/swagger-ui.html`
> - `/wms-be/swagger-ui/index.html`

---

## 참조

- Spring Boot 버전: `2.7.18`
- springdoc-openapi 호환 버전: `1.7.x` ([호환표](https://springdoc.org/#what-is-the-compatibility-matrix-of-springdoc-openapi-with-spring-boot))
- Security 설정 파일: `src/main/java/fw/config/SecurityConfig.java`
- permitAll 배열: `src/main/java/fw/constant/FwPool.java:46`
- 프로파일 properties: `src/main/resource/prop/`
