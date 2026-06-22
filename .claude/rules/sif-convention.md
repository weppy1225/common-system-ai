---
description: SIF 외부연동(ERP/OMS/WES/DLV) 코드 작성·수정 시 적용. sif/ 하위 E2W(수신)·W2E(송신) 개발, Retrofit2 API 인터페이스, SIF 전용 예외, sif_* 이력 테이블 처리 패턴을 정의한다.
paths:
  - "**/sif/**"
---

# WMS SIF 외부연동 컨벤션 (ERP/OMS/WES/DLV)

## 참조 문서 (SSoT)

| 주제 | 문서 |
|---|---|
| E2W(ERP→WMS 수신) 코드 컨벤션·클래스 명명·예외·테스트 | `patterns/50-interface/10-convention/01-erp-to-wms-convention.md` |
| W2E(WMS→ERP 송신) 코드 템플릿·Retrofit2·SifWms* 클래스 위치 | `patterns/50-interface/10-convention/02-wms-to-erp-convention.md` |
| 현재 IF 명세 | `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md` |
| `sif_*` 테이블 스키마 | `patterns/20-database/00-overview.md` |
| TxComp 기본 패턴 | `patterns/30-backend/40-guide/08-txcomp-writing-rules.md` |

> 이 문서는 SIF 개발의 **판단 기준**(방향별 패키지·레이어 구성·예외 선택·BLOCKING 규칙)만 담는다.
> **실제 코드 템플릿**(W2E 진입점·Retrofit2·클래스 위치)은 위 표의 패턴 문서를 참조한다.

---

## 연동 방향별 패키지

| 방향 | 경로 |
|---|---|
| ERP → WMS 수신 | `sif/erp/e2w/` |
| WMS → ERP 송신 | `sif/erp/w2e/` 또는 `sif/wms/proc/biz/{메뉴코드}/` |
| OMS → WMS 수신 | `sif/oms/rcv/` |
| WMS → OMS 송신 | `sif/wms/proc/biz/{메뉴코드}/` |
| WES ↔ WMS | `sif/wes/{vendor}/biz/{rcv|snd}/` |
| WMS → DLV | `sif/dlv/{vendor}/biz/` |

---

## 레이어 구성 판단

| 레이어 | 생성 조건 |
|---|---|
| `SifMapper.java + xml` | `sif_*` 이력 테이블 조회/저장이 있는 경우 |
| `SifDao` | Mapper가 있으면 항상 |
| `SifTxComp` | 내부 WMS 처리(InvenManager 등) 포함 시 |
| `SifComp` | 비즈니스 검증 + SifTxComp 호출 |
| `SifController` | E2W — REST로 외부에서 직접 호출 |
| `SifScheduler` | W2E — 배치/주기 송신 |

---

## SIF 전용 예외 (`CompWarnException` 금지)

`SifApiConnectionException` / `SifRequestFormatException` / `SifResponseFormatException`
/ `SifAlreadyProcessException` / `SifDuplicateIfKeyException` / `SifWarnException`

필수값 검증은 Bean 필드에 `@SifValid` 부여 후 `super.checkNull(bean)` 일괄 검증.

---

## 주요 상수

```
SifPool.IF_TARGET_WMS / OMS / ERP / DLV / WES
SifWmsPool.PROC_TYPE_PROCESS = "PROCESS"
SifWmsPool.PROC_TYPE_CANCEL  = "CANCEL"
```

---

## E2W/W2E 핵심 체크리스트

**W2E 송신**: → `patterns/50-interface/10-convention/02-wms-to-erp-convention.md §4` 참조

**E2W 수신:**
- [ ] 수신 데이터 `sif_*` 이력 INSERT
- [ ] 중복 수신 방어 (IF 고유키 기준)
- [ ] 내부 WMS 처리는 TxComp로 분리
- [ ] 성공/실패 시 `if_stat_cd` 갱신, 실패 시 알람

---

## SIF 핵심 규칙 (BLOCKING)

1. 모든 외부 연동은 `sif_*` 이력 테이블 기록
2. 멱등성 — 동일 IF 재수신 시 중복 처리 방지
3. 실패 시 `if_stat_cd` 업데이트 → 재처리 가능 설계
4. 송신 전 IF 비활성(`use_yn='N'`) 체크 필수
5. SIF 예외만 사용 (`CompWarnException` 금지)
6. API Key / 접속정보 코드 하드코딩 금지 → `application-{profile}.properties`

---

## 주요 클래스 위치

→ `patterns/50-interface/10-convention/02-wms-to-erp-convention.md §3` 참조 (SifPool·SifWmsPool·SifWmsProcComp 등).
