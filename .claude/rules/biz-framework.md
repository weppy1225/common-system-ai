---
description: 재고 증감(InvenManager iw/ow/im/ad/rt)·문서번호 채번(DocNoGenerator) 코드 작성 시 적용. 입고/출고/반품/이동/조정 확정, wms_inven* 처리, 출고예약·대기재고 로직을 TxComp 에서 구현할 때 참조한다.
paths:
  - "**/*TxComp.java"
---

# WMS 비즈니스 프레임워크 (InvenManager · DocNoGenerator)

---

## 참조 문서 (SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| TxComp 작성 (InvenManager 호출 위치) | `10-src-pattern/30-backend/40-guide/08-txcomp-writing-rules.md` | TxComp |
| Comp 작성 (DocNoGenerator 단건 호출) | `10-src-pattern/30-backend/40-guide/06-comp-writing-rules.md` | Comp |
| CompUtil — 재고 DTO 초기화 | `10-src-pattern/30-backend/40-guide/07-computil-writing-rules.md` | CompUtil |
| 재고 테이블 스키마 | psql `\d {테이블명}` 직접 조회 | DB 문서 |

---

## InvenManager 메서드 선택표

| 메서드 코드 | 의미 | 사용 시점 |
|---|---|---|
| `iw` | Inbound Write (입고) | 입고 확정 시 재고 증가 |
| `ow` | Outbound Write (출고) | 출고 확정 시 재고 감소 |
| `im` | Inventory Move (이동) | 창고 간·로케이션 간 이동 |
| `ad` | Adjustment (조정) | 실사 조정 |
| `rt` | Return (반품) | 반품 입고 시 재고 증가 |

**InvenManager는 TxComp에서만 호출한다.** Comp·Dao·Controller에서 직접 호출 금지.

---

## DocNoGenerator 호출 패턴

| 호출 레이어 | 조건 |
|---|---|
| `Comp` (단건) | 트랜잭션 불필요 또는 즉시 채번 가능한 경우 |
| `TxComp` (동일 TX) | 문서번호가 같은 트랜잭션 내에서 DML과 함께 사용되어야 하는 경우 |

---

## 재고 테이블 직접 조작 금지 (BLOCKING)

`wms_inven`, `wms_inven_hold`, `wms_inven_inout` 에 직접 INSERT/UPDATE/DELETE 금지.
모든 재고 증감·홀딩은 **InvenManager 경유** 필수.

---

## InvenPool 주요 상수

- `InvenPool.IW_TYPE_NORMAL` — 일반 입고
- `InvenPool.OW_TYPE_NORMAL` — 일반 출고
- `InvenPool.PROC_WAIT` — 대기재고 상태

---

## 금지 패턴

- `wms_inven*` 직접 DML → InvenManager 경유
- InvenManager를 Comp/Dao/Controller에서 직접 호출 → TxComp에서만
- DocNoGenerator 채번 결과를 검증 없이 사용 (null 체크 필수)
