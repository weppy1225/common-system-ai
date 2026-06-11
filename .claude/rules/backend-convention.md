---
description: WMS 백엔드 레이어(Controller·Comp·TxComp·Dao·CompUtil) 및 VO·DTO·Bean 코드 작성·수정 시 적용. 패키지구조·어노테이션·네이밍·예외처리·ResponseData·@Transactional 배치·금지패턴을 정의한다.
globs: ["**/*Controller.java", "**/*Comp.java", "**/*TxComp.java", "**/*Dao.java", "**/*CompUtil.java"]
alwaysApply: false
---

# WMS 백엔드 코딩 컨벤션

Controller·Comp·TxComp·Dao·CompUtil / VO·DTO·Bean 코드 작성·수정 시 반드시 참조한다.

---

## 적용 시점

- `/PI-be-all`, `/PI-be-mapper`, `/PI-be-dao`, `/PI-be-comp`, `/PI-be-excel`, `/PI-be-inven` 실행 시
- 기존 Controller/Comp/TxComp/Dao/CompUtil 파일 수정 요청 시
- 신규 DTO·VO·Bean 작성 시 (Lombok / Audit 필드 패턴 필요)
- 예외 throw 패턴, `ResponseData` 구성이 필요한 순간
- `@Transactional` 레이어 배치(특히 TxComp vs Comp) 판단 필요 시

---

## 참조 문서 (SSoT)

| 주제 | 문서 | 적용 레이어 |
|---|---|---|
| 레이어별 코딩 패턴 전체 (패키지구조·어노테이션·네이밍·금지패턴) | `10-src-pattern/30-backend/30-convention/01-coding-convention.md` | 전체 레이어 |
| Controller 작성 | `10-src-pattern/30-backend/40-guide/02-controller-writing-rules.md` | Controller |
| Dao 작성 | `10-src-pattern/30-backend/40-guide/03-dao-writing-rules.md` | Dao |
| Mapper.java 작성 | `10-src-pattern/30-backend/40-guide/04-mapper-writing-rules.md` | Mapper I/F |
| Comp 작성 | `10-src-pattern/30-backend/40-guide/06-comp-writing-rules.md` | Comp |
| CompUtil 작성 | `10-src-pattern/30-backend/40-guide/07-computil-writing-rules.md` | CompUtil |
| TxComp 작성 | `10-src-pattern/30-backend/40-guide/08-txcomp-writing-rules.md` | TxComp |

---

## §1 레이어별 완료 체크리스트 (JUnit 통과 조건)

각 레이어 개발 완료 기준 — SSoT 파일에서 확인.

## §2 CompUtil 생성 필요 여부

- 재고 DTO 초기화, 반복 변환 로직이 2개 이상 레이어에서 공유될 때 생성
- 단순 값 세팅은 Comp 내부 private 메서드로 처리

## §3 Comp vs TxComp 분리 기준

| 레이어 | 조건 |
|---|---|
| `TxComp` | `wms_inven*` 테이블 처리, InvenManager 호출, 복수 Mapper DML이 하나의 트랜잭션이어야 하는 경우 |
| `Comp` | 단순 CRUD, 조회 전용, TxComp를 호출하는 오케스트레이터 |

## §4 Controller HTTP 메서드·응답코드 매핑

| 작업 | HTTP 메서드 | 성공 응답코드 |
|---|---|---|
| 목록 조회 | `POST` | 200 |
| 단건 조회 | `POST` 또는 `GET` | 200 |
| 등록 | `POST` | 200 |
| 수정 | `PUT` 또는 `PATCH` | 200 |
| 삭제(소프트) | `DELETE` 또는 `PUT` | 200 |

## §5 예외 클래스 선택 기준

| 예외 클래스 | 사용 조건 |
|---|---|
| `CompWarnException` | 업무 검증 실패 (사용자에게 경고 표시) |
| `CompException` | 시스템 오류, 복구 불가 상황 |
| `DataNotFoundException` | 조회 결과 없음 |

**SIF 연동 코드에서 `CompWarnException` 사용 금지** → `sif-convention.md` 참조.

## §6 자주 잊는 import 목록

- `@RequiredArgsConstructor(onConstructor = @__(@Autowired))`
- `@Slf4j`
- `ResponseData` — 반드시 프레임워크 클래스 사용 (`com.zin.wms.common.data.ResponseData`)
- `EmptyTool` — null·빈 문자열·컬렉션 통합 검사 (`fw.tool.EmptyTool`)

## §7 금지 패턴

- `@Transactional`을 `Comp`에 붙이지 않는다 → TxComp에만 적용
- `wms_inven*` 테이블 직접 INSERT/UPDATE/DELETE 금지 → InvenManager 경유
- `System.out.println` 금지 → `log.info/warn/error` 사용
- `null` 직접 비교 금지 → `EmptyTool.empty()` / `EmptyTool.notEmpty()` 사용

---

## 상세 패턴 문서

레이어별 전체 코딩 패턴, 어노테이션, 네이밍, 예제 코드:
→ `10-src-pattern/30-backend/30-convention/01-coding-convention.md`
