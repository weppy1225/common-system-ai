---
title: 백엔드 프로젝트 라이브러리 목록
description: cloud-wms-be에서 사용하는 모든 JAR 라이브러리와 버전 정보를 참조할 때 사용
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: backend
tags:
  - library
  - dependency
  - jar
  - spring
  - mybatis
---

# 백엔드 프로젝트 라이브러리 목록 (Backend Project Library List)

## 1. 핵심 프레임워크
- **Spring Framework**: 5.3.18
- spring-core-5.3.18.jar
- spring-context-5.3.18.jar
- spring-context-support-5.3.18.jar
- spring-beans-5.3.18.jar
- spring-aop-5.3.18.jar
- spring-expression-5.3.18.jar
- spring-jcl-5.3.18.jar

## 2. Spring MVC
- spring-web-5.3.18.jar
- spring-webmvc-5.3.18.jar
- spring-websocket-5.3.18.jar

## 3. Spring Security (5.6.3)
- spring-security-core-5.6.3.jar
- spring-security-config-5.6.3.jar
- spring-security-web-5.6.3.jar
- spring-security-crypto-5.6.3.jar

## 4. 데이터베이스 연동
### 4.1 JDBC 및 트랜잭션
- spring-jdbc-5.3.18.jar
- spring-tx-5.3.18.jar
- spring-messaging-5.3.18.jar

### 4.2 MyBatis
- mybatis-3.5.13.jar
- mybatis-spring-2.1.1.jar

### 4.3 PostgreSQL
- postgresql-42.5.4.jar

### 4.4 커넥션 풀
- HikariCP-5.1.0.jar

## 5. 로깅
- slf4j-api-1.7.5.jar
- logback-classic-1.2.6.jar
- logback-core-1.2.6.jar
- log4j-api-2.20.0.jar
- log4j-core-2.20.0.jar
- log4jdbc-log4j2-jdbc4.1-1.16.jar
- log4jdbc4-1.2.jar

## 6. 유틸리티
### 6.1 Apache Commons
- commons-lang-2.6.jar
- commons-lang3-3.8.jar
- commons-codec-1.16.1.jar
- commons-io-2.11.0.jar
- commons-beanutils-1.9.4.jar
- commons-collections4-4.4.jar
- commons-compress-1.21.jar
- commons-fileupload-1.3.1.jar
- commons-logging-1.3.2.jar
- commons-net-3.6.jar

### 6.2 Google 라이브러리
- guava-31.0.1-jre.jar
- gson-2.13.2.jar
- jsr305-3.0.2.jar
- failureaccess-1.0.2.jar
- j2objc-annotations-3.0.0.jar

## 7. JSON 처리
- jackson-core-2.14.1.jar
- jackson-databind-2.14.1.jar
- jackson-annotations-2.14.1.jar
- json-20160810.jar

## 8. 보안 및 인증
### 8.1 JWT
- jjwt-api-0.11.2.jar
- jjwt-impl-0.11.2.jar
- jjwt-jackson-0.11.2.jar

### 8.2 Firebase
- firebase-admin-9.3.0.jar
- google-api-client-2.4.0.jar
- google-api-client-gson-2.4.0.jar
- google-http-client-1.44.2.jar
- google-http-client-gson-1.44.2.jar
- google-http-client-jackson2-1.44.2.jar
- google-auth-library-oauth2-http-1.23.0.jar
- google-auth-library-credentials-1.23.0.jar
- google-oauth-client-1.35.0.jar
- threetenabp-1.4.6-sources.jar

## 9. 클라우드 스토리지
- google-cloud-storage-2.36.1.jar
- google-cloud-core-2.38.0.jar
- google-cloud-core-http-2.38.0.jar
- api-common-2.38.0.jar

## 10. 문서 처리
### 10.1 Apache PDFBox
- pdfbox-2.0.24.jar

### 10.2 iText7 (HTML→PDF 변환)
- html2pdf-3.0.3.jar
- styled-xml-parser-7.1.14.jar
- kernel-7.1.14.jar
- layout-7.1.14.jar
- io-7.1.14.jar

### 10.3 Excel
- poi-5.2.3.jar
- poi-ooxml-5.2.3.jar
- poi-ooxml-full-5.2.3.jar
- xmlbeans-5.2.1.jar
- jxls-2.6.0.jar

### 10.4 바코드 (ZXing)
- javase-3.3.0.jar
- core-3.3.0.jar

## 11. 스케줄링
- quartz-2.3.2.jar

## 12. 이메일
- javax.mail-1.6.2.jar

## 13. HTTP 클라이언트
### 13.1 Retrofit
- retrofit-2.6.0.jar
- okhttp-3.11.0.jar
- okio-1.16.0.jar
- logging-interceptor-3.11.0.jar
- converter-gson-2.6.2.jar

### 13.2 Apache HttpClient
- httpclient-4.5.14.jar
- httpcore-4.4.16.jar

## 14. 유효성 검사
- validation-api-2.0.1.Final.jar
- hibernate-validator-6.0.17.Final.jar
- javax.el-3.0.1-b08.jar

## 15. 성능 모니터링
- opencensus-api-0.31.1.jar
- opencensus-contrib-http-util-0.31.1.jar
- grpc-context-1.27.2.jar

## 16. 개발 도구
- lombok-1.18.38.jar
- jasypt-1.9.2.jar (암호화)
- jasypt-spring31-1.9.3.jar
- ant-1.10.12.jar
- velocity-engine-core-2.3.jar

## 17. 기타
- cache-api-1.1.1.jar
- ehcache-3.8.1.jar
- classmate-1.3.4.jar
- jaxb-api-2.3.1.jar
- jaxb-runtime-2.3.1.jar
- istack-commons-runtime-3.0.7.jar
- jboss-logging-3.3.2.Final.jar
- aspectjweaver-1.8.9.jar
- activation-1.1.jar
- jodd-util-6.0.0.jar
- auto-value-annotations-1.10.4.jar
- bcprov-jdk18on-1.78.1.jar

## 18. 주요 특징
1. **Spring 5.3.18** 기반의 MVC 구조
2. **Spring Security 5.6.3** 적용
3. **MyBatis + PostgreSQL** 조합
4. **Firebase Admin SDK** 포함
5. **JWT** 인증 처리
6. **Quartz** 스케줄러
7. **Logback + Log4j2** 로깅 체계
8. **Apache POI**를 통한 Excel 처리
9. **PDFBox**를 통한 PDF 처리
10. **Retrofit2** HTTP 클라이언트
