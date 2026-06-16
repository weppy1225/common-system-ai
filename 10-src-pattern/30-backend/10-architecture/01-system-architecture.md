---
title: 시스템 아키텍처
description: WMS 전체 시스템 구성(3-Tier, UI/BIZ/DB 계층)과 사용자 관점 아키텍처를 참조할 때 사용
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
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

본 문서는 WMS(Warehouse Management System)의 전체 아키텍처를 다음 두 가지 관점에서 정리한다.

1. **시스템 구성 아키텍처 (System Architecture)**
Mermaid Diagram
https://gist.github.com/weppy1225/97197ea9c5082dd905621870aa4cc77f
2. **사용자 관점 아키텍처 (User Perspective Architecture)**
Mermaid Diagram
https://gist.github.com/weppy1225/78d04448c7a57d054092a23fbaa42820

본 시스템은 Vue3 + Spring 기반의 3-Tier 구조이며,
DB는 PostgreSQL을 사용하고 ERP와 연동되는 구조이다.

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

### 3.1 1 User Devices

* PC (일반 사용자)
* PC (관리자)
* PDA (물류팀)

---

### 3.2 2 UI Layer

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

### 3.3 3 BIZ Layer

* PORT: 6270
* 기술:

* Spring Framework
* Java
* Tomcat

### 3.4 주요 API

* 입고 API (Inbound)
* 재고 API (Inventory)
* 출고 API (Outbound)
* 품목 / 거래처 API

역할:

* 비즈니스 로직 처리
* 트랜잭션 제어
* ERP 연동
* DB 접근

---

### 3.5 4 Database Layer

* DBMS: PostgreSQL
* PORT: 5432

역할:

* 재고 데이터 저장
* 입출고 이력 관리
* 마스터 데이터 관리

---

### 3.6 5 Legacy Layer (ERP)

* ERP 시스템 연동
* PORT: 5432 (DB 직접 또는 인터페이스 방식)

역할:

* 회계 / 정산 데이터 연동
* 기준정보 동기화

---

### 3.7 6 File Layer

* PORT: 22 (SFTP)
* Excel Template
* 품목 이미지

역할:

* 업로드 파일 관리
* 라벨/엑셀 템플릿 제공

---

# 3. User Perspective Architecture (사용자 관점)

## 4. 사용자 접점 구성

### 4.1 1 WMS Service

* 도메인: `wms.zin.co.kr`
* 기능:

* 입고
* 출고
* 재고관리

### 4.2 2 WMS Portal

* 도메인: `portal.wms.zin.co.kr`
* 기능:

* 서비스 소개
* 요금제 안내
* 창고 중계
* 매뉴얼 제공

---

## 5. 사용자 단말

* PC
* Tablet
* Cell phone
* PDA

---

## 6. WMS APP

* 패키지명: `com.zin.cloud.wms`
* 기능:

* 입고 처리
* 출고 처리
* 이동 처리

설치 대상:

* 물류팀 PDA
* 스마트폰

---

## 7. 출력 장비 (Label Output H/W)

* Lazer Printer

* Location Label
* 입고 / 출고 지시서

* Label Printer

* Box Label
* Pallet Label

* Portable Printer

* Box / Pallet Label

---

## 8. 바코드 스캔 장비 (Barcode Scan H/W)

* 휴대폰 + 카메라
* 휴대폰 + Bluetooth Scanner
* Zebra PDA
* Honeywell PDA

---

# 4. 전체 아키텍처 통합 관점

## 9. 사용자 흐름

```
사용자 단말
↓
WMS Service (Web / App)
↓
BIZ API
↓
PostgreSQL
↓
ERP 연동
```

---

## 10. 물류 실무 흐름

1. PDA에서 입고 처리
2. 바코드 스캔
3. DB 재고 반영
4. 라벨 출력
5. ERP 인터페이스 반영

---

# 5. 아키텍처 특징

### 10.1 3-Tier 구조

UI / Business / Database 계층 분리

### 10.2 ERP 연동 구조

Legacy 시스템과 인터페이스 가능

### 10.3 모바일 물류 최적화

PDA 기반 실시간 처리

### 10.4 파일 관리 분리

템플릿 및 이미지 외부 저장

---

# 6. 기술 스택 정리

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
