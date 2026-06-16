---
title: 메뉴코드 체계 및 개발 가이드
description: 신규 메뉴 개발 시 메뉴코드 채번·패키지 경로·API URL 규칙과 전체 메뉴 구조를 참조
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
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

1. 아래 전체 메뉴 구조에서 적절한 **상위 메뉴** 확인
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

## 4. PC 전체 메뉴 구조

| 상위코드 | 상위메뉴명 | 하위코드 | 하위메뉴명 | Java 패키지 경로 | 영문 키워드 |
|---------|-----------|---------|-----------|----------------|------------|
| **IW1000** | **입고관리** | | | `be/iw1000/` | Inbound Warehouse |
| | | IWRQ01 | 입고예정 | `be/iw1000/iwrq01` | Inwh Request |
| | | IWPC01 | 입고처리 | `be/iw1000/iwpc01` | Inwh Process |
| | | IWSC01 | 입고현황 | `be/iw1000/iwsc01` | Inwh Status Condition |
| | | IWLB01 | 라벨품목 | `be/iw1000/iwlb01` | Inwh Label |
| **RT2000** | **반품관리** | | | `be/rt2000/` | Return |
| | | RTRQ01 | 반품예정 | `be/rt2000/rtrq01` | Return Request |
| | | RTPC01 | 반품처리 | `be/rt2000/rtpc01` | Return Process |
| **IV3000** | **재고관리** | | | `be/iv3000/` | Inventory Management |
| | | IVMV01 | 재고이동 | `be/iv3000/ivmv01` | Inventory Move |
| | | IVMVRQ01 | 재고이동요청 | `be/iv3000/ivmvrq01` | Inventory Move Request |
| | | IVAD01 | 재고조정 | `be/iv3000/ivad01` | Inventory Adjust |
| | | IVEXRQ01 | 예외출고 | `be/iv3000/ivexrq01` | Inventory Exception Request |
| | | IVSK01 | SKU변경 | `be/iv3000/ivsk01` | SKU Change |
| | | SKSP01 | 파렛트분할 | `be/iv3000/sksp01` | Pallet Split |
| | | SKMG01 | 파렛트병합 | `be/iv3000/skmg01` | Pallet Merge |
| | | IVST01 | 세트작업 | `be/iv3000/ivst01` | Inventory Set |
| **IV3100** | **재고조회** | | | `be/iv3100/` | Inventory View |
| | | IVPD01 | 재고조회(품목별) | `be/iv3100/ivpd01` | Inventory Product |
| | | IVWH01 | 재고조회(창고별) | `be/iv3100/ivwh01` | Inventory Warehouse |
| | | IVPR01 | 재고조회(기간별) | `be/iv3100/ivpr01` | Inventory Period |
| | | IVIO01 | 수불조회 | `be/iv3100/ivio01` | Inventory In/Out |
| | | IVMC01 | 재고마감 | `be/iv3100/ivmc01` | Inventory Month Close |
| | | SKHT01 | SKU이력조회 | `be/iv3100/skht01` | SKU History |
| **IV3200** | **재고실사** | | | `be/iv3200/` | Stock Take |
| | | STSC01 | 재고실사일정등록 | `be/iv3200/stsc01` | Stock Take Schedule |
| | | STRG01 | 실사재고등록 | `be/iv3200/strg01` | Stock Take Register |
| | | STCP01 | 재고실사비교 | `be/iv3200/stcp01` | Stock Take Compare |
| **OW5000** | **출고관리** | | | `be/ow5000/` | Outbound |
| | | OBRQ01 | 출하예정 | `be/ow5000/obrq01` | Outbound Request |
| | | DLPB01 | 송장발행 | `be/ow5000/dlpb01` | Delivery Publish |
| | | DLPBWE01 | 송장발행(WES) | `be/ow5000/dlpbwe01` | Delivery Publish WES |
| | | OWRB01 | 출고지시 | `be/ow5000/owrq01/owrb01` | Outwh Request B2B |
| | | OWRC01 | 출고지시(송장) | `be/ow5000/owrq01/owrc01` | Outwh Request B2B Invoice |
| | | OWPC01 | 출고처리 | `be/ow5000/owpc01` | Outwh Process |
| | | DLPC01 | 송장처리 | `be/ow5000/dlpc01` | Delivery Process |
| | | DLPC02 | 송장처리(바코드) | `be/ow5000/dlpc02` | Delivery Process Barcode |
| | | DLPCWE01 | 송장처리(WES) | `be/ow5000/dlpcwe01` | Delivery Process WES |
| | | DLCX01 | 송장처리취소 | `be/ow5000/dlcx01` | Delivery Process Cancel |
| | | LDPC01 | 상차처리 | `be/ow5000/ldpc01` | Loading Process |
| | | OBPC01 | 출하처리 | `be/ow5000/obpc01` | Outbound Process |
| | | OBCX01 | 출하처리취소 | `be/ow5000/obcx01` | Outbound Process Cancel |
| | | OBSC01 | 출하현황 | `be/ow5000/obsc01` | Outbound Status Condition |
| **MD8000** | **기준정보** | | | `be/md8000/` | Master Data |
| | | MDBZ01 | 사업장 | `be/md8000/mdbz01` | Master Biz |
| | | MDWH01 | 창고 | `be/md8000/mdwh01` | Master Warehouse |
| | | MDLC01 | 위치(로케이션) | `be/md8000/mdlc01` | Master Location |
| | | MDCT01 | 거래처 | `be/md8000/mdct01` | Master Contractor |
| | | MDPD01 | 품목 | `be/md8000/mdpd01` | Master Product |
| | | MDCP01 | 업체품목 | `be/md8000/mdcp01` | Master Contractor Product |
| | | MDSP01 | 화주 | `be/md8000/mdsp01` | Master Shipper |
| | | MDST01 | 세트구성 | `be/md8000/mdst01` | Master Set Config |
| | | MDUS01 | 사용자 | `be/md8000/mdus01` | Master User |
| | | MDCR01 | 차량 | `be/md8000/mdcr01` | Master Car |
| **SM9000** | **시스템설정** | | | `be/sm9000/` | System Management |
| | | SMMG01 | 권한그룹 | `be/sm9000/smmg01` | System Manager Group |
| | | USCD01 | 사용자코드 | `be/sm9000/uscd01` | User Code |
| | | ALSH01 | 알람조회 | `be/sm9000/alsh01` | Alarm Search |
| | | MNST01 | 메뉴별설정 | `be/sm9000/mnst01` | Menu Setting |
| | | OBST01 | 출하설정 | `be/sm9000/obst01` | Outbound Setting |
| | | PDST01 | 품목설정 | `be/sm9000/pdst01` | Product Setting |
| | | LPST01 | 출력물설정 | `be/sm9000/lpst01` | Label Print Setting |
| | | SCST01 | 보안설정 | `be/sm9000/scst01` | Security Setting |
| | | SMST01 | SSE전송 | `be/sm9000/smst01` | System SSE |
| **MM9200** | **운영관리** | | | `be/mm9200/` | Management |
| | | SMCC01 | 공통코드 | `be/mm9200/smcc01` | System Common Code |
| | | SMMN01 | 메뉴관리 | `be/mm9200/smmn01` | System Menu Management |
| | | SCRG01 | 스케줄러 | `be/mm9200/scrg01` | Scheduler Register |
| | | SCCH01 | 스케줄러변경이력 | `be/mm9200/scch01` | Scheduler Change History |
| | | SCEX01 | 스케줄러실행이력 | `be/mm9200/scex01` | Scheduler Execution |
| | | MDLP01 | 출력물관리 | `be/mm9200/mdlp01` | Label Paper Management |
| **IF9100** | **IF관리** | | | `be/if9100/` | Interface |
| | | IFST01 | I/F설정 | `be/if9100/ifst01` | IF Setting |
| | | DVST01 | 택배사설정 | `be/if9100/dvst01` | Delivery Setting |
| | | IFBH01 | I/F처리이력 | `be/if9100/ifbh01` | IF Batch History |
| **CM9400** | **소통관리** | | | `be/cm9400/` | Communication |
| | | ALST01 | 알람설정 | `be/cm9400/alst01` | Alarm Setting |
| **SS9300** | **시스템현황** | | | `be/ss9300/` | System Status |
| | | LGAP01 | API로그 | `be/ss9300/lgap01` | Log API |
| | | LGCO01 | 접근로그 | `be/ss9300/lgco01` | Log Connection |
| | | LGER01 | 에러로그 | `be/ss9300/lger01` | Log Error |
| | | LGMN01 | 메뉴로그 | `be/ss9300/lgmn01` | Log Menu |
| | | SMBD01 | 고객문의 | `be/ss9300/smbd01` | Board |

---

## 5. 모바일 전체 메뉴 구조

> ⚠️ 모바일 패키지명은 실제 `src/main/java/bm/` 디렉토리 기준 (메뉴코드와 다를 수 있음)

| 상위코드 | 상위메뉴명 | 하위코드 | 하위메뉴명 | Java 패키지 경로 | 영문 키워드 |
|---------|-----------|---------|-----------|----------------|------------|
| **IW1000M** | **[입고관리]** | | | `bm/iw1000m/` | Inbound Mobile |
| | | IWPC01M | 입고처리 | `bm/iw1000m/iwpc01m` | Inwh Process Mobile |
| **RT2000M** | **[반품관리]** | | | `bm/rt2000m/` | Return Mobile |
| | | RTPC01M | 반품처리 | `bm/rt2000m/rtpc01m` | Return Process Mobile |
| **IV3000M** | **[재고관리]** | | | `bm/iv3000m/` | Inventory Mobile |
| | | IVAD01M | 재고조정 | `bm/iv3000m/ivad01m` | Inventory Adjust Mobile |
| | | IVMV01M | 재고이동 | `bm/iv3000m/ivmv01m` | Inventory Move Mobile |
| | | IVMVRQ01M | 재고이동요청 | `bm/iv3000m/ivmvrq01m` | Inventory Move Request Mobile |
| | | SKSP01M | 파렛트분할 | `bm/iv3000m/sksp01m` | Pallet Split Mobile |
| | | SKMG01M | 파렛트병합 | `bm/iv3000m/skmg01m` | Pallet Merge Mobile |
| **IV3100M** | **[재고조회]** | | | `bm/iv3100m/` | Inventory View Mobile |
| | | BRSC01M | 재고조회 | `bm/iv3100m/brsc01m` | Barcode Status Condition Mobile |
| **IV3200M** | **[재고실사]** | | | `bm/iv3200m/` | Stock Take Mobile |
| | | STSC01M | 재고실사일정 | `bm/iv3200m/stsc01m` | Stock Take Schedule Mobile |
| | | STRG01M | 실사재고등록 | `bm/iv3200m/strg01m` | Stock Take Register Mobile |
| **OW5000M** | **[출고관리]** | | | `bm/ow5000m/` | Outbound Mobile |
| | | OWPC01M | 출고처리 | `bm/ow5000m/owpc01m` | Outwh Process Mobile |
| | | DLPC01M | 송장처리 | `bm/ow5000m/dlpc01m` | Delivery Process Mobile |
| | | LDPC01M | 상차처리 | `bm/ow5000m/ldpc01m` | Loading Process Mobile |
| | | OBRQ01M | 출하예정 | `bm/ow5000m/obrq01m` | Outbound Request Mobile |
| | | OBPC01M | 출하처리 | `bm/ow5000m/obpc01m` | Outbound Process Mobile |
| **MD8000M** | **[기준정보]** | | | `bm/md8000m/` | Master Data Mobile |
| | | MDBZ01M | 사업장 | `bm/md8000m/mdbz01m` | Master Biz Mobile |
| **SM9000M** | **[시스템설정]** | | | `bm/sm9000m/` | System Mobile |
| | | ALSH01M | 알람조회 | `bm/sm9000m/alsh01m` | Alarm Search Mobile |
| | | ALST01M | 알람설정 | `bm/sm9000m/alst01m` | Alarm Setting Mobile |
| | | SMST01M | 설정 | `bm/sm9000m/smst01m` | System Setting Mobile |
