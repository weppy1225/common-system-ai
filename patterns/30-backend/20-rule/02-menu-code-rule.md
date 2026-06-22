---
title: 메뉴코드 체계 및 개발 가이드
description: 신규 메뉴 개발 시 메뉴코드 채번·패키지 경로·API URL 규칙을 참조 (전체 메뉴 목록은 spec/{프로젝트}/_knowledge/menu-list.md)
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: rule
domain: backend
tags:
  - menu-code
  - package-path
  - api-url
  - quick-start
---

# 메뉴코드 체계 및 개발 가이드

> AI 코딩 보조(Claude)가 신규 메뉴/기능 개발 시 반드시 참고하는 문서

---

## 0. 신규 메뉴개발 Quick Start

신규 메뉴를 개발할 때는 아래 순서로 진행하세요.

1. `menu.md`에서 유사 메뉴를 먼저 찾습니다.
2. 메뉴코드 규칙(업무영역 4자리 + 타입 2자리, 모바일은 `M` 접미사)을 확인합니다.
3. Java 패키지 경로와 `@RequestMapping` URL 규칙을 맞춥니다.
4. 기본 파일 세트(Controller, Comp/TxComp, Dao, Mapper, Bean)를 생성합니다.
5. 소프트 삭제(`use_yn`, `del_yn`) 및 공통 규칙(`ResponseData`, `InvenManager`, `DocNoGenerator`)을 준수합니다.

### 신규 메뉴 개발 전 체크

- 기존 메뉴와 코드/역할이 중복되지 않는지 확인
- PC/모바일 여부에 맞는 패키지(`be/*`, `bm/*`) 선택
- 참조 메뉴(예: `IVAD01`, `IWPC01`, `IVPD01`, `IVAD01M`) 선정 후 구조 재사용
- API 리소스명은 복수형으로 정의 (예: `inwhs`, `ads`)

### 자주 하는 실수

- `@Transactional`을 Controller/Comp에 선언하는 경우 (반드시 TxComp에만 선언)
- 재고 증감을 SQL로 직접 처리하는 경우 (`fw/inven/InvenManager` 경유 필요)
- 문서번호를 직접 채번하는 경우 (`fw/doc_no/DocNoGenerator` 사용)

---

## 1. 메뉴코드 규칙

| 구분 | 형식 | 예시 |
|------|------|------|
| PC 메뉴 | `{4자리 약어}{2자리 타입번호}` | `IWPC01` |
| 모바일 메뉴 | `{4자리 약어}{2자리 타입번호}M` | `IWPC01M` |

### 주요 업무 약어

| 약어 | 업무 | 상위 패키지 |
|------|------|------------|
| IW | 입고 (Inbound Warehouse) | IW1000 |
| RT | 반품 (Return) | RT2000 |
| IV | 재고 (Inventory) | IV3000 / IV3100 / IV3200 |
| OW | 출고 (Outbound Warehouse) | OW5000 |
| DL | 송장/배송 (Delivery) | OW5000 |
| OB | 출하 (Outbound) | OW5000 |
| LD | 상차 (Loading) | OW5000 |
| SK | SKU·파렛트 작업 | IV3000 |
| ST | 재고실사 (Stock Take) | IV3200 |
| BR | 바코드 (Barcode) | IV3100 |
| MD | 기준정보 (Master Data) | MD8000 |
| SM | 시스템 (System Management) | SM9000 / MM9200 |
| MM | 운영관리 (Management) | MM9200 |
| SC | 스케줄러·보안 (Scheduler/Security) | MM9200 / SM9000 |
| AL | 알람 (Alarm) | SM9000 / CM9400 |
| IF | 인터페이스 관리 (Interface) | IF9100 |
| CM | 소통관리 (Communication) | CM9400 |
| LG | 로그 (Log) | SS9300 |

### 타입번호 구분

| 번호 | 의미 | 예시 |
|------|------|------|
| 01 | 기본 UI/기능 | `IWRQ01` 입고예정 기본 |
| 02 | 확장/변형 UI (다른 레이아웃 또는 추가기능) | `DLPC02` 송장처리(바코드) |
| 03 | 관리자용 / 특수기능 (예: 입고예정+처리 통합) | `IWRQ03` |

> 동일 약어에 여러 타입이 쌓이면 업체별 메뉴 설정만으로 재개발 없이 운영 가능.

---

## 2. Java 패키지 & API URL 매핑 규칙

### 패키지 경로 도출 규칙

```
PC:     src/main/java/be/{상위코드소문자}/{하위코드소문자}/
모바일: src/main/java/bm/{상위코드소문자}m/{하위코드소문자}m/
```

### API URL 도출 규칙

```
PC:     /{bizSeq}/{하위코드소문자}/{리소스명복수}
모바일: /bm/{하위코드소문자}/{리소스명복수}
```

> 리소스명은 해당 메뉴의 주요 엔티티를 소문자 복수형으로 표기.
> 예: IWPC01 → 입고(inwh) → `/inwhs` / IVAD01 → 재고조정(ad) → `/ads`

### 매핑 예시

| 메뉴코드 | Java 패키지 | `@RequestMapping` URL |
|----------|------------|----------------------|
| IWRQ01 | `be/iw1000/iwrq01` | `/{bizSeq}/iwrq01/inbizs` |
| IWPC01 | `be/iw1000/iwpc01` | `/{bizSeq}/iwpc01/inwhs` |
| IVAD01 | `be/iv3000/ivad01` | `/{bizSeq}/ivad01/ads` |
| IVAD01M | `bm/iv3000m/ivad01m` | `/bm/ivad01m/ads` |

---

## 3. 신규 메뉴 개발 가이드

### 메뉴코드 채번 방법

1. 프로젝트 메뉴 레지스트리(`spec/{프로젝트}/_knowledge/menu-list.md`)에서 적절한 **상위 메뉴** 확인
2. 동일 상위 메뉴 내 미사용 코드 채번 (기존 코드 중복 없이)
3. 새 업무 영역이면 기존 번호대에 맞춰 상위 메뉴부터 추가

### 신규 메뉴 파일 생성 체크리스트

```
bean/
  {코드}Search.java       — 검색조건 VO
  {코드}Response.java     — 응답 VO
  {코드}{도메인}.java     — 주요 엔티티 VO
{코드}Controller.java     — @RestController, @RequestMapping
{코드}Comp.java           — 비트랜잭션 비즈니스 로직 (조회·검증)
{코드}TxComp.java         — @Transactional 비즈니스 로직 (CUD)  ← 조회 전용이면 생략 가능
{코드}Dao.java            — Mapper 호출 DAO
{코드}Mapper.java         — MyBatis 매퍼 인터페이스
{코드}Mapper.xml          — MyBatis SQL (resources/mapper/be/{상위코드}/{하위코드}/ 권장)
```

### 레퍼런스 선택 기준

| 상황 | 참고 메뉴 | 특징 |
|------|----------|------|
| 헤더+품목 2단 구조 CRUD | `IVAD01` (재고조정) | 헤더/디테일 분리, 상태 처리 |
| 처리 흐름 + I/F 연동 | `IWPC01` (입고처리) | 상태 전이, 외부 IF 호출 패턴 |
| 단순 조회 전용 | `IVPD01` (재고조회) | 검색 파라미터 → 목록 반환 |
| 모바일 CRUD | `IVAD01M` (재고조정 모바일) | 모바일 레이어 패턴 |

---

## 4. 전체 메뉴 구조

전체 메뉴(상위/하위 코드·메뉴명·Java 패키지 경로·영문 키워드)는 **프로젝트마다 다른 확정 데이터**라 이 규칙에 박제하지 않는다 — 메뉴 추가·변경 시 곧바로 드리프트가 생기기 때문이다.

→ 프로젝트별 메뉴 레지스트리: **`spec/{프로젝트}/_knowledge/menu-list.md`** (PC·모바일 전체 메뉴 포함)
