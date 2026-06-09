---
name: backend-convention
description: WMS 백엔드 코딩 컨벤션. Controller·Comp·TxComp·Dao·CompUtil 레이어 코드 작성 시 자동 로드. 예외처리, ResponseData 구성, DTO 패턴, Lombok 사용법 포함.
user-invocable: false
---

# WMS 백엔드 코딩 컨벤션 (thin loader)

> 자동 로드 트리거: Controller / Comp / TxComp / Dao / CompUtil / Bean(VO·DTO) 코드 작성·수정 시.
> 상세 코드 패턴은 `DEV_DOC/ai-docs/20-backend/40-guide/` 를 SSoT로 참조. 이 파일은 진입점 + 핵심 요약만 담는다.

## 로드 시점

- `/dev-all`, `/dev-mapper`, `/dev-dao`, `/dev-comp`, `/dev-excel`, `/dev-inven-tx` 커맨드 실행 시
- 기존 Controller/Comp/TxComp/Dao/CompUtil 파일 수정 요청 시
- 신규 DTO·VO·Bean 작성 시 (Lombok / Audit 필드 패턴 필요)
- 예외 throw 패턴, `ResponseData` 구성이 필요한 순간
- `@Transactional` 레이어 배치(특히 TxComp vs Comp) 판단 필요 시

## 참조 문서 (필독 — SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| Controller 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/02-controller-writing-rules.md` | Controller |
| Dao 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/03-dao-writing-rules.md` | Dao |
| Mapper.java 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/04-mapper-writing-rules.md` | Mapper I/F |
| Comp 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/06-comp-writing-rules.md` | Comp |
| CompUtil 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/07-computil-writing-rules.md` | CompUtil |
| TxComp 작성 | `DEV_DOC/ai-docs/20-backend/40-guide/08-txcomp-writing-rules.md` | TxComp |

## 판단 기준 요약 (rules/ 링크)

- `.claude/rules/backend-convention.md` §1 — 레이어별 완료 체크리스트 (JUnit 통과 조건)
- `.claude/rules/backend-convention.md` §2 — CompUtil 생성 필요 여부
- `.claude/rules/backend-convention.md` §3 — Comp vs TxComp 분리 기준
- `.claude/rules/backend-convention.md` §4 — Controller HTTP 메서드·응답코드 매핑
- `.claude/rules/backend-convention.md` §5 — 예외 클래스 선택 기준
- `.claude/rules/backend-convention.md` §7 — 금지 패턴 (Comp에 `@Transactional` 등)

## skill 고유 메모

> - 자주 잊는 import 목록: `.claude/rules/backend-convention.md §6` 참조
> - 예외 클래스 후보·선택 우선순위: `.claude/rules/backend-convention.md §5` 참조
> - HTTP 메서드 ↔ 응답코드 표: `.claude/rules/backend-convention.md §4` 참조
