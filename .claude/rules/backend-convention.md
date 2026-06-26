---
description: 백엔드 레이어(Controller·Comp·TxComp·Dao·CompUtil) 및 VO·DTO·Bean 코드 작성·수정 시 적용. 패키지구조·어노테이션·네이밍·예외처리·ResponseData·@Transactional 배치·금지패턴을 정의한다.
paths:
  - "**/*Controller.java"
  - "**/*Comp.java"
  - "**/*TxComp.java"
  - "**/*Dao.java"
  - "**/*CompUtil.java"
---

# 백엔드 코딩 컨벤션

---

## 참조 문서 (SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| 레이어별 코딩 패턴 전체 (패키지구조·어노테이션·네이밍·금지패턴) | `patterns/30-backend/30-convention/01-coding-convention.md` | 전체 레이어 |
| Controller 작성 | `patterns/30-backend/40-guide/02-controller-writing-rules.md` | Controller |
| Dao 작성 | `patterns/30-backend/40-guide/03-dao-writing-rules.md` | Dao |
| Mapper.java 작성 | `patterns/30-backend/40-guide/04-mapper-writing-rules.md` | Mapper I/F |
| Comp 작성 | `patterns/30-backend/40-guide/06-comp-writing-rules.md` | Comp |
| CompUtil 작성 | `patterns/30-backend/40-guide/07-computil-writing-rules.md` | CompUtil |
| TxComp 작성 | `patterns/30-backend/40-guide/08-txcomp-writing-rules.md` | TxComp |

---

## §1 레이어별 완료 체크리스트 (JUnit 통과 조건)

각 레이어 개발 완료 기준 — SSoT 파일에서 확인.

## §2 CompUtil 생성 필요 여부

- 재고 DTO 초기화, 반복 변환 로직이 2개 이상 레이어에서 공유될 때 생성
- 단순 값 세팅은 Comp 내부 private 메서드로 처리

## §3 Comp vs TxComp 분리 기준

쓰기 트랜잭션(`@Transactional`)·`wms_inven*` 처리·복수 Mapper DML 묶음 → **TxComp**, 단순 CRUD·조회 전용·TxComp 오케스트레이션 → **Comp**.
판단 기준 정본(SoT) → `patterns/30-backend/30-convention/01-coding-convention.md §5`.

## §4 Controller HTTP 메서드·응답코드 매핑

메서드 분기 기준(BLOCKING) 정본(SoT) → `patterns/30-backend/20-rule/01-api-naming-rule.md §2.1`.
요약: 목록 조회=`POST`(검색조건 Body) · 단건 조회=`GET` · 단건 등록=`PUT`/수정=`PATCH`(JSON 단건) · 파일첨부(multipart)=`POST .../insert|update` · 삭제=`DELETE`. 성공 응답 200.

## §5 예외 클래스 선택 기준

커스텀 예외 클래스 카탈로그 정본(SoT) → `patterns/30-backend/30-convention/01-coding-convention.md §9.1` (목록을 여기에 중복 기재하지 않는다).
**SIF 연동 코드에서 `CompWarnException` 사용 금지** → `wms-sif-convention.md` 참조.

## §6 자주 잊는 import 목록

- `@RequiredArgsConstructor(onConstructor = @__(@Autowired))`
- `@Slf4j`
- `ResponseData` — 반드시 프레임워크 클래스 사용 (`fw.bean.ResponseData`)
- `EmptyTool` — null·빈 문자열·컬렉션 통합 검사 (`fw.tool.EmptyTool`)

## §7 금지 패턴

- `@Transactional`을 `Comp`에 붙이지 않는다 → TxComp에만 적용
- `wms_inven*` 테이블 직접 INSERT/UPDATE/DELETE 금지 → InvenManager 경유
- `System.out.println` 금지 → `log.info/warn/error` 사용
- `null` 직접 비교 금지 → `EmptyTool.empty()` / `EmptyTool.notEmpty()` 사용

---

## 상세 패턴 문서

레이어별 전체 코딩 패턴, 어노테이션, 네이밍, 예제 코드:
→ `patterns/30-backend/30-convention/01-coding-convention.md`
