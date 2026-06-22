---
title: 시스템 아키텍처
description: 전체 시스템 구성(3-Tier, UI/BIZ/DB 계층)과 레이어별 역할을 참조할 때 사용
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: backend
tags:
  - architecture
  - system
  - 3tier
  - vue3
  - spring
---

# 시스템 아키텍처 문서 (System Architecture Document)

## 1. 개요

본 문서는 전체 시스템 아키텍처를 시스템 구성 관점에서 정리한다.

본 시스템은 Vue3 + Spring 기반의 3-Tier 구조이며,
DB는 PostgreSQL을 사용하고 ERP와 연동되는 구조이다.

> 참고 다이어그램(시스템 구성): https://gist.github.com/weppy1225/97197ea9c5082dd905621870aa4cc77f

---

# 2. System Architecture (시스템 구성 관점)

## 2. 전체 구성 요약

```
[User Devices]
      ↓
[UI Layer - Vue3 / NGINX]
      ↓
[BIZ Layer - Spring / Tomcat]
      ↓
┌───────────────┬───────────────┬───────────────┐
[PostgreSQL] [ERP] [File Storage]
```

---

## 3. Layer 구성 상세

### 3.1 User Devices

* PC (일반 사용자)
* PC (관리자)
* PDA / 모바일 단말

---

### 3.2 UI Layer

* 기술 스택

* Vue3
* NGINX

* 구성

* Portal UI (PORT 80)
* Admin / Mobile UI (PORT 8080)

역할:

* 사용자 요청 수신
* API 호출
* 화면 렌더링

---

### 3.3 BIZ Layer

* PORT: 6270
* 기술:

* Spring Framework
* Java
* Tomcat

#### 주요 API

* 업무 도메인별 API (등록 / 조회 / 처리)
* 마스터(품목 / 거래처 등) API

역할:

* 비즈니스 로직 처리
* 트랜잭션 제어
* ERP 연동
* DB 접근

---

### 3.4 Database Layer

* DBMS: PostgreSQL
* PORT: 5432

역할:

* 업무 데이터 저장
* 트랜잭션 이력 관리
* 마스터 데이터 관리

---

### 3.5 Legacy Layer (ERP)

* ERP 시스템 연동
* PORT: 5432 (DB 직접 또는 인터페이스 방식)

역할:

* 회계 / 정산 데이터 연동
* 기준정보 동기화

---

### 3.6 File Layer

* PORT: 22 (SFTP)
* Excel Template
* 첨부 이미지

역할:

* 업로드 파일 관리
* 엑셀 템플릿 제공

---

# 3. 전체 아키텍처 통합 관점

## 4. 사용자 흐름

```
사용자 단말
↓
UI Layer (Web / Mobile)
↓
BIZ API
↓
PostgreSQL
↓
ERP 연동
```

---

# 4. 아키텍처 특징

### 4.1 3-Tier 구조

UI / Business / Database 계층 분리

### 4.2 ERP 연동 구조

Legacy 시스템과 인터페이스 가능

### 4.3 모바일 대응

PDA 등 모바일 단말 기반 실시간 처리

### 4.4 파일 관리 분리

템플릿 및 이미지 외부 저장

---

# 5. 기술 스택 정리

| 구분 | 기술 |
| ---------- | ----------------- |
| Frontend | Vue3 |
| Web Server | NGINX |
| Backend | Spring / Java |
| WAS | Tomcat |
| DB | PostgreSQL |
| 연동 | ERP |
| 파일 | SFTP |
| 단말 | PC / PDA / Mobile |

---
