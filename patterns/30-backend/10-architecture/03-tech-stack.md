---
title: 백엔드 기술 스택
description: 백엔드에서 사용하는 프레임워크·라이브러리·인프라 기술 스택을 참조할 때 사용
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: backend
tags:
  - tech-stack
  - spring
  - mybatis
  - postgresql
  - jwt
---

# 백엔드 기술 스택 (Backend Tech Stack)

## 1. 프레임워크 & 애플리케이션

### 1.1 Spring Framework
- spring-core, spring-context, spring-web, spring-webmvc
- 웹 애플리케이션 구조 및 DI 컨테이너

### 1.2 Spring Security
- spring-security-core, spring-security-web
- 인증 / 인가 처리

### 1.3 MyBatis
- mybatis, mybatis-spring
- ORM / SQL 매퍼

### 1.4 Quartz
- quartz
- 스케줄링 작업 관리

### 1.5 Ehcache
- ehcache
- 캐싱 솔루션

---

## 2. 데이터베이스 & Persistence

### 2.1 PostgreSQL
- postgresql-42.5.4.jar
- JDBC 드라이버

### 2.2 HikariCP
- HikariCP
- 고성능 커넥션 풀

### 2.3 Hibernate Validator
- hibernate-validator
- 데이터 유효성 검증

---

## 3. 클라우드 & 외부 서비스

### 3.1 Firebase
- firebase-admin
- Firebase 서비스 연동

### 3.2 Google Cloud
- google-cloud-core, google-cloud-storage, google-api-client
- GCP 서비스 활용

### 3.3 REST 클라이언트
- retrofit, okhttp
- 외부 REST API 호출

---

## 4. 파일 처리 & 문서 변환

### 4.1 Excel
- Apache POI: poi, poi-ooxml
- JXLS: jxls (템플릿 기반 리포트)

### 4.2 PDF
- PDFBox: pdfbox
- html2pdf

### 4.3 XML
- XmlBeans: xmlbeans

---

## 5. 로깅 & 모니터링

### 5.1 로깅 프레임워크
- Log4j2: log4j-api, log4j-core
- Logback: logback-classic, logback-core
- Slf4j: slf4j-api (추상화 레이어)

### 5.2 SQL 로그
- Log4jdbc: log4jdbc
- SQL 실행 로그 출력

### 5.3 모니터링
- Opencensus: opencensus-api
- 분산 트레이싱

---

## 6. 보안 & 암호화

### 6.1 JWT 인증
- jjwt-api, jjwt-impl (0.11.2)
- JWT Bearer Token 기반 인증 (STATELESS)
- API Key 인증 병행 (`fw/auth/apikey/`)

### 6.2 설정값 암호화
- Jasypt: jasypt
- 프로퍼티 파일 암호화

### 6.3 암호화 알고리즘
- BouncyCastle: bcprov
- 암호화 알고리즘 지원

---

## 7. JSON & 데이터 처리

### 7.1 JSON
- Jackson: jackson-core, jackson-databind (직렬화/역직렬화)
- Gson: gson, converter-gson

### 7.2 유틸리티
- Apache Commons: commons-lang, commons-io, commons-codec, beanutils, collections, fileupload
- Guava: guava
- Lombok: lombok (Getter/Setter/Builder 자동 생성)

### 7.3 템플릿 엔진
- Velocity Engine: velocity-engine-core (이메일·출력물 템플릿)

---

## 8. 기술 스택 특징 요약

| 영역 | 기술 |
|---|---|
| 웹 프레임워크 | Spring MVC |
| ORM | MyBatis + PostgreSQL |
| 인증/인가 | Spring Security + JWT + API Key |
| 클라우드 | Firebase + Google Cloud Storage |
| 문서 처리 | POI(Excel) + PDFBox(PDF) |
| 로깅 | Log4j2 + Logback + Log4jdbc |
| REST 클라이언트 | Retrofit + OkHttp |
| 스케줄링 | Quartz |
