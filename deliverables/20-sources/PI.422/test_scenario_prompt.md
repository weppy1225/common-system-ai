---
title: 통합테스트 시나리오 문서 작성 요청
description: TxComp 기반 통합테스트 시나리오 문서를 생성할 때 아키텍처 맥락, 분석 대상, 산출물 형식을 지시하는 프롬프트 문서.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
---

# 통합테스트 시나리오 문서 작성 요청

> 이 파일은 Claude CLI가 소스 코드를 분석하여 통합테스트 시나리오 문서를 작성하기 위한 컨텍스트 및 요청 사항입니다.

---

## 1. 프로젝트 개요

- **시스템**: 업무 시스템
- **기술 스택**: Spring / Java / Vue.js
- **목적**: 소스 코드 정적 분석을 기반으로 통합테스트 시나리오 문서 산출물 작성

---

## 2. 핵심 아키텍처 이해

### 2.1 TxComp 구조

- 모든 업무 트랜잭션은 `TxComp` 클래스에서 처리됨
- 네이밍 규칙: `{도메인코드}{순번}TxComp` (예: `IWPC01TxComp`)
- 트랜잭션 메서드 네이밍 규칙: `public *TX()` + `@Transactional` 어노테이션
- 총 80개 TxComp 존재

**도메인 코드 분류:**

| 접두어 | 도메인 | 예시 |
|---|---|---|
| IW | 입고 | IWPC01TxComp |
| OW / OB | 출고 | OWPC01TxComp, OBRQ01TxComp |
| RT | 반품 | RTPC01TxComp |
| IV | 재고 | IVAD01TxComp |
| MD | 기준정보 | MDCT01TxComp |
| SM | 시스템 | SMMG01TxComp |
| E2W | ERP→WMS 연동 IF | E2WIwRegTxComp |
| SIF | WMS→외부 연동 IF | IVAD01SifRegTxComp |
| BM (M접미어) | 모바일 | IWPC01MTxComp |

### 2.2 상태 코드 (WMSPool 상수)

| 상수명 | 값 | 의미 |
|---|---|---|
| STAND_BY | 11 | 대기 |
| READY | 22 | 준비 (출고 예약 완료) |
| PROCESSING | 55 | 처리중 (부분처리) |
| COMPLETION | 77 | 완료 |
| STOP | 99 | 중단 |

**정상 상태 전이:**
```
입고: STAND_BY(11) → PROCESSING(55) → COMPLETION(77)
출고: STAND_BY(11) → READY(22) → PROCESSING(55) → COMPLETION(77)
취소: 역방향 (77 → 55 → 11)
```

### 2.3 InvenManager (재고 처리 핵심)

모든 재고 증감/홀딩은 InvenManager를 통해서만 처리됨.

**오퍼레이션 코드:**

| 메서드 | 용도 | 주요 액션 |
|---|---|---|
| `iw()` | 입고 재고 처리 | PROC_INVEN (재고증가), PROC_CANCEL (재고감소) |
| `ow()` | 출고 재고 처리 | PROC_INVEN (재고차감), PROC_CANCEL (재고복원) |
| `ad()` | 재고 조정 | PROC_INVEN |
| `im()` | 재고 이동 | PROC_INVEN, PROC_WAIT |
| `ih()` | 예약재고 홀딩 | HOLD (홀딩), HOLD_CANCEL (홀딩해제) |
| `mr()` | 팔레트 병합 | - |
| `sc()` | 신규라벨 발행 | - |

---

## 3. 기분석 완료된 TxComp 내용

아래 4개는 이미 분석이 완료된 상태이므로, 시나리오 작성 시 참고하되 나머지 TxComp 분석에 집중할 것.

### 3.1 IWPC01TxComp (입고처리)

| 메서드 | 주요 로직 | InvenManager 호출 |
|---|---|---|
| `processInwhTX` | 입고처리 + 재고 증가 | `iw(PROC_INVEN)` |
| `cancelInwhsTX` | 입고취소 + 재고 감소 | `iw(PROC_CANCEL)` |
| `publishSkuTX` | SKU 라벨 발행 | - |
| `cancelPublishSkuTX` | SKU 발행 취소 | - |
| `forceConfirm` | 강제 확정 | - |

**호출 체인 (processInwhTX):**
```
invenManager.iw() → Dao.insertInwhTrans() → Dao.updateProcResultToProd() → updateInwhStatus()
```

### 3.2 OWPC01TxComp (출고처리)

| 메서드 | 주요 로직 | InvenManager 호출 |
|---|---|---|
| `processOutwhTransTX` | 출고처리 + 재고 감소 | `ih(HOLD_CANCEL)` → `im(PROC_WAIT/PROC_INVEN)` |
| `cancelOutwhTransTX` | 단순 출고 취소 | `ih(HOLD)` → `im(PROC_INVEN)` |
| `cancelOutwhProcsWithOthersTX` | 복합 취소 (이동/병합/신규라벨) | `im()` → `mr()` → `sc()` |

### 3.3 IVAD01TxComp (재고조정)

| 메서드 | 주요 로직 | InvenManager 호출 |
|---|---|---|
| `processInvenAdTX` | 신규/기존 재고 조정 | `ad(PROC_INVEN)` |
| `processReceiveAdTX` | IF 수신 재고조정 | `ad(PROC_INVEN)` |
| `deleteAdTransTX` | 조정처리 삭제 | - |
| `processStAdTX` | 상태변경 조정 | `ad(PROC_INVEN)` |

### 3.4 OBRQ01TxComp (출고예약)

| 메서드 | 주요 로직 | InvenManager 호출 |
|---|---|---|
| `holdingAndUpdateOutbiz` | 예약재고 등록 → 상태 READY | `ih(HOLD)` |
| `cancelHoldingAndUpdateOutbiz` | 예약재고 취소 → 상태 STAND_BY | `ih(HOLD_CANCEL)` |
| `stopOutbizTX` | 출하 중단 + 예약재고 원복 | `ih(HOLD_CANCEL)` |

---

## 4. 분석 요청 사항

### 4.1 분석 대상 파일

아래 패턴에 해당하는 **모든 TxComp 파일**을 분석할 것:

```
**/TxComp/*.java
**/*TxComp.java
```

**우선순위:**
1. BE 업무 TxComp (iw, ow, rt, iv, md, sm 도메인) — 41개
2. E2W 연동 TxComp — 19개
3. SIF 연동 TxComp — 8개
4. 모바일 MTxComp — 3개

### 4.2 각 TxComp별 추출해야 할 정보

각 TxComp 파일에 대해 다음을 추출할 것:

```
① public *TX() 메서드 목록
② 각 메서드의 InvenManager 호출 패턴 (iw/ow/ad/im/ih + PROC_INVEN/PROC_CANCEL/HOLD/HOLD_CANCEL)
③ 상태 전이 로직 (WMSPool 상수 기준)
④ 주요 Dao 호출 (insert/update/delete 위주)
⑤ 조건 분기 로직 (if-else 주요 분기점)
⑥ 예외 처리 로직 (throw, catch 구간)
⑦ 연관 TxComp 호출 여부 (TxComp 간 의존성)
```

### 4.3 특히 집중 분석이 필요한 영역

**① 재고 정합성 관련**
- InvenManager 호출 전후 재고 수량 변화
- HOLD / HOLD_CANCEL 쌍이 올바르게 처리되는지
- 취소 시 재고 원복 로직의 완전성

**② ERP 연동 (E2W) 관련**
- ERP 데이터 수신 → WMS 등록 간 필드 매핑
- 중복 수신 처리 로직 유무
- 오류 발생 시 롤백 처리

**③ 상태 전이 예외 케이스**
- 허용되지 않는 상태에서의 처리 시도
- 부분처리(PROCESSING) 상태에서 재처리
- 강제확정(forceConfirm) 후 취소 시도

**④ 복합 트랜잭션**
- `cancelOutwhProcsWithOthersTX` 처럼 여러 InvenManager를 연속 호출하는 케이스
- 중간 실패 시 롤백 범위

---

## 5. 산출물 형식 요청

### 5.1 문서 구조

각 도메인별로 아래 구조로 작성할 것:

```
# {도메인명} 통합테스트 시나리오

## 개요
- 관련 TxComp 목록
- 상태 전이도

## 시나리오 목록

### TC-{도메인}-001: {시나리오명}

| 항목 | 내용 |
|---|---|
| 테스트 ID | TC-IW-001 |
| 대상 메서드 | processInwhTX |
| 테스트 유형 | 정상 / 예외 / 경계값 |
| 사전 조건 | - 입고 헤더 존재 (상태: STAND_BY) |
|            | - SKU 라벨 발행 완료 |
| 실행 절차 | 1. processInwhTX 호출 |
|           | 2. 처리수량 = 요청수량 |
| 기대 결과 | - 재고 증가 확인 |
|           | - 입고 품목 상태: COMPLETION(77) |
|           | - 입고 헤더 상태: COMPLETION(77) |
|           | - 입고처리 내역 기록 확인 |
| 검증 포인트 | DB: WMS_INVEN 수량 변화 |
|             | DB: WMS_INWH_DTL 상태코드 |
| 비고 | InvenManager.iw(PROC_INVEN) 호출 확인 |
```

### 5.2 시나리오 유형별 작성 기준

**정상 케이스 (Happy Path)**
- 최소 1개: 전체 플로우 완주
- 부분처리 케이스 포함 (처리수량 < 요청수량)

**예외 케이스 (Exception)**
- 허용되지 않는 상태에서 처리 시도
- 필수값 누락
- 재고 부족 (출고 시)
- ERP 중복 수신 (E2W)

**경계값 케이스 (Boundary)**
- 처리수량 = 0
- 처리수량 = 요청수량 (정확히 완료)
- 처리수량 > 요청수량 (초과 처리)

**상태 전이 케이스**
- 정방향: STAND_BY → PROCESSING → COMPLETION
- 역방향(취소): COMPLETION → PROCESSING → STAND_BY
- 불가 전이: COMPLETION 상태에서 재처리 시도

### 5.3 도메인간 연계 시나리오

아래 연계 플로우에 대한 E2E 시나리오도 반드시 포함할 것:

```
① 입고 전체 플로우
   E2WIwRegTxComp (ERP입고등록) 
   → IWPC01TxComp.publishSkuTX (라벨발행)
   → IWPC01TxComp.processInwhTX (입고처리)
   → 재고 증가 확인

② 출고 전체 플로우
   E2WObRegTxComp (ERP출고등록)
   → OBRQ01TxComp.holdingAndUpdateOutbiz (출고예약)
   → OWPC01TxComp.processOutwhTransTX (출고처리)
   → 재고 차감 확인

③ 재고조정 플로우
   IVAD01TxComp.processInvenAdTX (재고조정)
   → 재고 증감 확인
   → SIF 연동 확인 (IVAD01SifRegTxComp)

④ 입고→출고 재고 정합성 검증
   입고처리 후 가용재고 증가
   → 출고예약 후 가용재고 감소 (홀딩)
   → 출고처리 후 실재고 차감
   → 전 구간 재고 수치 정합성 확인
```

---

## 6. 주의사항

1. **재고 정합성이 최우선**: 모든 시나리오에서 InvenManager 호출 전후 재고 수량 검증 포인트 반드시 포함
2. **E2W 연동은 별도 챕터**: ERP→WMS 구간은 필드 매핑, 중복 수신, 오류 처리 시나리오 필수
3. **상태 전이 불가 케이스 명시**: 어떤 상태에서 어떤 처리가 불가한지 표로 정리
4. **TxComp 간 의존성 명시**: 단독 호출 불가 케이스 (선행 TxComp 필요) 반드시 표기
5. **Private 메서드 내부 로직**: 외부에서 확인 불가한 로직은 `[확인필요]` 태그 표기

---

## 7. 참고: 기분석 결과 시나리오 초안

이미 도출된 시나리오 예시 (보완하여 사용할 것):

```
TC-IW-001: 정상 입고 처리
TC-IW-002: 부분 입고 처리 (처리수량 < 요청수량)
TC-IW-003: 입고 취소 (COMPLETION → STAND_BY)
TC-OB-001: 출고 예약 등록
TC-OB-002: 출고 예약 취소
TC-OB-003: 출하 중단
TC-OW-001: 출고 처리
TC-OW-002: 단순 출고 취소
TC-OW-003: 복합 출고 취소 (이동/병합/신규라벨)
TC-IV-001: 신규 재고 조정
TC-IV-002: IF 수신 재고 조정
TC-IV-003: 상태변경 조정
```

---

> **작업 완료 후**: 도메인별 시나리오 문서를 Markdown 형식으로 출력하거나, 지정 경로에 파일로 저장할 것.
