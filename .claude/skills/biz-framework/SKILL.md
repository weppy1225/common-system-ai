---
name: biz-framework
description: WMS 재고처리(InvenManager)·문서번호채번(DocNoGenerator) 프레임워크 사용 패턴. 입고/출고/반품/이동/조정 확정 로직, 문서번호 생성 코드 작성 시 자동 로드.
user-invocable: false
---

# WMS 비즈니스 프레임워크 (thin loader)

> 자동 로드 트리거: InvenManager / DocNoGenerator 호출 코드 작성 시, 재고 증감·문서번호 채번이 필요한 TxComp 작성 시.
> 상세 호출 패턴·DTO 구성 예시는 `DEV_DOC/ai-docs/20-backend/40-guide/08-txcomp-writing-rules.md` 및 관련 가이드 참조.

## 로드 시점

- `/dev-inven-tx`, `/dev-all`, `/dev-comp` 실행 시 (입출고·재고 확정/취소 포함)
- TxComp에서 `wms_inven*` 테이블 관련 비즈니스 작성 시
- 입고/출고/반품/이동/조정 문서번호 채번이 필요한 경우
- 출고 예약(Hold/HoldCancel), 대기재고(PROC_WAIT) 처리 시

## 참조 문서 (필독 — SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| TxComp 작성 (InvenManager 호출 위치) | `DEV_DOC/ai-docs/20-backend/40-guide/08-txcomp-writing-rules.md` | TxComp |
| Comp 작성 (DocNoGenerator 단건 호출) | `DEV_DOC/ai-docs/20-backend/40-guide/06-comp-writing-rules.md` | Comp |
| CompUtil — 재고 DTO 초기화 | `DEV_DOC/ai-docs/20-backend/40-guide/07-computil-writing-rules.md` | CompUtil |
| 재고 테이블 스키마 | `DEV_DOC/ai-docs/10-database/90-schema/20-tables/wms_inven*.md` | DB 문서 |

## 판단 기준 요약 (rules/ 링크)

- `.claude/rules/biz-framework.md` — InvenManager 메서드 선택표 (iw/ow/im/ad/rt)
- `.claude/rules/biz-framework.md` — 호출 레이어 (InvenManager는 TxComp에서만)
- `.claude/rules/biz-framework.md` — DocNoGenerator 호출 레이어 (Comp 단건 / TxComp 동일 TX 필요 시)

## skill 고유 메모

> InvenManager 메서드 선택표 (iw/ow/im/ad/rt), InvenPool 상수, DocNoGenerator 형식, 금지 패턴:
> → `.claude/rules/biz-framework.md` 참조 (SSoT)
