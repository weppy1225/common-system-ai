---
title: 백엔드 코딩 컨벤션
description: Controller·Comp·TxComp·Dao·Mapper·Bean 레이어 작성 시 적용할 어노테이션·네이밍·예외처리·이력컬럼 규칙
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: instruction
domain: backend
tags:
  - coding-convention
  - controller
  - comp
  - dao
  - mapper
  - bean
  - annotation
related:
  - patterns/30-backend/40-guide/02-controller-writing-rules.md
  - patterns/30-backend/40-guide/06-comp-writing-rules.md
  - patterns/30-backend/40-guide/08-txcomp-writing-rules.md
  - patterns/30-backend/40-guide/03-dao-writing-rules.md
  - patterns/30-backend/40-guide/04-mapper-writing-rules.md
  - patterns/30-backend/40-guide/05-mapper-xml-writing-rules.md
  - patterns/30-backend/40-guide/07-computil-writing-rules.md
last_verified: 2026-04-07
---

# 백엔드 코딩 컨벤션 (Backend Coding Convention)

> `mdpd01` 메뉴 소스 분석을 기반으로 작성된 실제 코딩 컨벤션입니다.
> 신규 메뉴 개발 시 이 파일의 패턴(규칙·표·네이밍·금지 패턴)을 반드시 준수하세요.
>
> **이 문서의 역할**: 레이어 공통 규칙·표·네이밍·금지 패턴 등 *판단 기준*만 기술합니다.
> 레이어별 **실제 코드 작성 패턴(템플릿/예제)** 은 `40-guide/` 하위 가이드 문서를 참조하세요.

| 메뉴코드 | 메뉴명 | 메뉴그룹 | 메뉴코드_인스턴스 | 메뉴그룹_인스턴스 | 리소스 | 리소스_소문자 |
|----------|--------|----------|-------------------|-------------------|--------|---------------|
| MDPD01 | 품목 | MD8000 | mdpd01 | md8000 | Prod | prod |

---

## 1. 패키지 및 디렉터리 구조

```
be.{메뉴그룹_인스턴스}.{메뉴코드_인스턴스}/ ← 예: be.md8000.mdpd01
├── {메뉴코드}Controller.java ← REST API 진입점
├── {메뉴코드}Comp.java ← 비즈니스 로직 (트랜잭션 제외)
├── {메뉴코드}TxComp.java ← @Transactional 전용
├── {메뉴코드}Dao.java ← DB 접근 (Mapper 위임)
├── {메뉴코드}Mapper.java ← MyBatis Mapper 인터페이스
├── {메뉴코드}CompUtil.java ← 메뉴 전용 유틸
├── bean/
│ ├── {메뉴코드}Response.java ← 응답 DTO
│ ├── {메뉴코드}Search.java ← 검색/조회 파라미터 DTO
│ ├── {메뉴코드}{리소스}.java ← 도메인 DTO (Request 겸용)
│ └── {메뉴코드}PrintLabel.java ← 기능별 특수 DTO
└── excel/
    ├── {메뉴코드}ExcelController.java
    ├── {메뉴코드}ExcelComp.java
    ├── {메뉴코드}ExcelTxComp.java
    ├── {메뉴코드}ExcelDao.java
    ├── {메뉴코드}ExcelMapper.java
    ├── {메뉴코드}ExcelCompUtil.java
    └── bean/
        └── {메뉴코드}Excel.java
```

**팝업(Popup) 전용 Controller**: 파일명에 `P` 추가
- 예: `MDPDP01Controller` → URL prefix: `/{bizSeq}/mdpdp01/prods`

**테스트 클래스**: `test/` 하위, 파일명 `ZTEST_` 접두사

---

## 2. 레이어 구조 및 책임

```
Controller → Comp (비즈니스) → TxComp (트랜잭션) → Dao → Mapper
```

| 레이어 | 클래스 접미사 | 역할 | 작성 가이드 |
|---|---|---|---|
| REST API | `Controller` | HTTP 요청/응답, 파라미터 바인딩 | [02-controller-writing-rules.md](../40-guide/02-controller-writing-rules.md) |
| 비즈니스 | `Comp` | 유효성 검사, 비즈니스 로직, 예외 처리 | [06-comp-writing-rules.md](../40-guide/06-comp-writing-rules.md) |
| 트랜잭션 | `TxComp` | `@Transactional` 메서드만 위치 | [08-txcomp-writing-rules.md](../40-guide/08-txcomp-writing-rules.md) |
| 데이터 접근 | `Dao` | Mapper 위임, 로깅 | [03-dao-writing-rules.md](../40-guide/03-dao-writing-rules.md) |
| 쿼리 | `Mapper` | MyBatis Mapper 인터페이스 | [04-mapper-writing-rules.md](../40-guide/04-mapper-writing-rules.md) |
| Mapper XML | `Mapper.xml` | SQL 매핑 (별도 파일) | [05-mapper-xml-writing-rules.md](../40-guide/05-mapper-xml-writing-rules.md) |
| 유틸 | `CompUtil` | 메뉴 전용 헬퍼 메서드 | [07-computil-writing-rules.md](../40-guide/07-computil-writing-rules.md) |

> 기존 코드에 `Comp` 직접 `@Transactional`, Controller `@Validated` 누락, JavaDoc `@author`/`@version` 잔존이 있더라도 규칙 예외가 아니다. 모두 미준수 레거시로 보고 신규/수정 코드에 동일 규칙을 적용한다.

---

## 3. 클래스 어노테이션 규칙

| 클래스 | 필수 어노테이션 |
|---|---|
| Controller | `@Validated`, `@RestController`, `@RequiredArgsConstructor(onConstructor = @__(@Autowired))`, `@Slf4j`, `@RequestMapping(...)` |
| Comp | `@Service`, `@Slf4j`, `@RequiredArgsConstructor(onConstructor = @__(@Autowired))` |
| TxComp | `@Service`, `@Slf4j`, `@RequiredArgsConstructor(onConstructor = @__(@Autowired))` |
| Dao | `@Repository`, `@Slf4j`, `@RequiredArgsConstructor(onConstructor = @__(@Autowired))` |
| Mapper | `@Mapper` (인터페이스) |
| CompUtil | `@Service` |
| DTO (Bean) | `@Getter`, `@Setter` (Response: extends `ResponseData`, Search: extends `BaseParam`, Domain: implements `Serializable`) |

> **DI 규칙**: 생성자 주입만 사용. `@Autowired` 필드 주입 금지.
> **레이어별 상세 코드 템플릿**: 위 §2 표의 가이드 문서 링크 참조.

---

## 4. Controller URL 설계 규칙

```
GET    /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}        ← 단건 조회 (팝업 등)
GET    /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/{seq}  ← 단건 상세 조회
POST   /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}        ← 목록 조회 (검색조건 body)
POST   /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/insert ← 단건 등록
POST   /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/update ← 단건 수정
DELETE /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}        ← 단건/다건 삭제
PUT    /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/excel  ← 엑셀 일괄 등록
POST   /{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/excel/valid ← 엑셀 유효성 검사
```

> Controller 메서드 시그니처·`@RequestBody`/`@PathVariable`/`@RequestPart` 등 어노테이션 사용 패턴은
> [40-guide/02-controller-writing-rules.md](../40-guide/02-controller-writing-rules.md) 참조.

---

## 5. Comp / TxComp 책임 분리 규칙

- 쓰기 트랜잭션(`@Transactional`)·`wms_inven*` 처리·복수 Mapper DML 묶음 → **TxComp**
- 단순 CRUD·조회 전용·TxComp 호출 오케스트레이션 → **Comp**
- `@Transactional`은 TxComp 메서드에만 선언 (Comp/Dao/Controller 금지)

> 코드 작성 패턴: [40-guide/06-comp-writing-rules.md](../40-guide/06-comp-writing-rules.md), [40-guide/08-txcomp-writing-rules.md](../40-guide/08-txcomp-writing-rules.md) 참조.

---

## 6. Dao / Mapper 규칙

- Dao: Mapper 단순 위임 + 로깅 + (필요 시) 복수 Mapper 조합. 비즈니스 검증 금지.
- Mapper: 인터페이스. `@Param` 사용 기준 → [02-mybatis-convention.md §2.3](../../20-database/30-convention/02-mybatis-convention.md) 참조.

> Dao·Mapper·Mapper XML 작성 가이드는
> [40-guide/03-dao-writing-rules.md](../40-guide/03-dao-writing-rules.md),
> [40-guide/04-mapper-writing-rules.md](../40-guide/04-mapper-writing-rules.md),
> [40-guide/05-mapper-xml-writing-rules.md](../40-guide/05-mapper-xml-writing-rules.md) 참조.

---

## 7. DTO (Bean) 패턴 규칙

| DTO 종류 | 상위 클래스 | 사용처 |
|---|---|---|
| `{메뉴코드}Response` | `extends ResponseData` | 모든 API 응답 (목록·단건·처리건수 포함, `fw.bean.ResponseData`의 `succeed`·`procCnt` 공통 필드 재사용) |
| `{메뉴코드}Search` | `extends BaseParam` | 목록 조회 파라미터 (조회 결과 필드도 동일 클래스 재사용) |
| `{메뉴코드}{리소스}` | `implements Serializable` | 등록/수정 Request 겸 도메인 객체 |
| `{메뉴코드}Excel` | `extends ExcelBaseParam` | 엑셀 업로드 데이터 |

**Bean Validation 어노테이션**: `@NotBlank`, `@Pattern(regexp = "[YN]")`, `@Min`, `@Max` 등 표준 사용.
**이력 컬럼**: `regId`, `regDt`, `modId`, `modDt` 필드는 자동 세팅 대상이며 입력값으로 받지 않음. Comp/CompUtil에서 `TokenTool.getLoginUserId()`, `DateTool.now()`로 채운 뒤 하위 레이어로 전달한다.

> 신규 응답 클래스 생성 금지 — `ResponseData` 사용. (`ApiResponse<T>`, `CommonResponse` 등 금지)

---

## 8. 메서드 네이밍 규칙

| 접두사 | 용도 | 예시 |
|---|---|---|
| `search` | 목록 조회 (검색조건 포함) | `search{리소스}s()` |
| `select` | 단건 조회 | `select{리소스}()` |
| `insert` | 단건 등록 | `insert{리소스}()` |
| `update` | 단건 수정 | `update{리소스}()` |
| `delete` | 삭제 | `delete{리소스}s()` |
| `check` | 유효성/중복 체크 | `checkDuplicate{리소스}No()`, `check{리소스}SeqInOtherTbl()` |
| `get` | 내부 데이터 추출 | `get{리소스}FileUuids()` |
| `validate` | 복합 유효성 검사 | `validateUpdate{리소스}()` |
| `make` | 데이터 가공/빌드 | `makeFileData()` |
| `save` | 외부 저장 연동 | `saveLabelPaperTo{리소스}()` |
| `print` | 출력/라벨 처리 | `printLabels()` |

**트랜잭션 메서드 접미사**: `Tx` 또는 `TX` — `insert{리소스}Tx()`, `update{리소스}TX()`, `delete{리소스}sTX()`

---

## 9. 예외 처리 규칙

### 9.1 사용 가능한 커스텀 예외

> 실제 BE 소스 기준 공통 예외: `ZinRequestParamValidException`, `ZinExistDataException`, `ZinNotFoundException`, `NotMeetConditionsException`, `AlreadyProcessException`, `ResponseErrorException`.
> 업무 검증 실패는 `CompWarnException`, 시스템 오류는 `ResponseErrorException`을 사용한다.

### 9.2 예외 처리 원칙

- `RuntimeException` 직접 throw 금지 — 위 목록에서 가장 가까운 예외 사용.
- Comp 메서드의 try 블록은 가급적 5줄 이내로 유지한다. 복잡한 검증·세팅 로직은 CompUtil 또는 private 메서드로 분리한다.
- Comp catch 블록 표준 패턴: `CompWarnException` → `ResponseWarnException`, `Exception` → `ResponseErrorException`.

> Comp 예외 처리 코드 템플릿은 [40-guide/06-comp-writing-rules.md](../40-guide/06-comp-writing-rules.md) 참조.

---

## 10. 공통 유틸 사용 표

| 유틸 클래스 | 용도 |
|---|---|
| `TokenTool.getLoginUserId()` | 현재 로그인 사용자 ID 조회 |
| `TokenTool.getBizSeq()` / `getRegBizSeq()` | 현재 로그인 사업장 SEQ 조회 |
| `DateTool.now()` | 현재 일시 |
| `DateTool.getYmd()` | 오늘 일자 (YYYYMMDD) |
| `EmptyTool.isEmpty(obj)` / `notEmpty(obj)` | null/빈값 체크 |
| `MsgTool.getMsg("key")` / `getMsgParam("key", ...)` | 다국어 메시지 조회 (`fw.msg.MsgTool`) |
| `FileTool.changeFilePathToUrl(path)` | 파일 경로 → URL 변환 |
| `GsonTool.toJson(obj)` / `printBean(obj)` | 로그용 JSON 직렬화 |
| `FormatTool.toDispString(val)` | 표시 포맷 변환 |

---

## 11. 이력 컬럼 세팅 규칙

| 컬럼 | 세팅 위치 | 값 |
|---|---|---|
| `regId`, `regDt` | Comp (insert 흐름) | `TokenTool.getLoginUserId()`, `DateTool.now()` |
| `modId`, `modDt` | Comp (update 흐름) | `TokenTool.getLoginUserId()`, `DateTool.now()` |

> **규칙**: 이력 컬럼은 Comp(또는 CompUtil)에서 세팅 후 TxComp으로 전달. Controller에서 직접 세팅 금지.
> 이력 컬럼 세팅 항목이 3개 이상이거나 반복되는 경우 CompUtil의 `makeInsertXxx`/`makeUpdateXxx`로 분리.

---

## 12. 삭제 규칙

| 테이블 유형 | 삭제 방식 |
|---|---|
| `MDM_*` 기준정보 | 논리삭제 — `use_yn = 'N'` |
| `WMS_*` 업무 | 물리삭제 — `DELETE FROM` (예외 시 기존 소스 따름) |

> Mapper XML 측 삭제 패턴은 [40-guide/05-mapper-xml-writing-rules.md](../40-guide/05-mapper-xml-writing-rules.md) §6.2, §7 참조.

---

## 13. 엑셀 처리 패턴

```
ExcelController → ExcelComp (검증/가공) → ExcelTxComp (@Transactional) → ExcelDao → ExcelMapper
```

- 검증 흐름: 프레임워크 1차 검증(`excelComp.validate`) → 비즈니스 2차 검증(중복·존재 여부)
- 등록 흐름: `ExcelTxComp`에서 `@Transactional` 일괄 INSERT

---

## 14. 로깅 규칙

- 클래스 레벨에 `@Slf4j` 사용 (Lombok)
- 레벨 기준:
  - `log.debug()` → 개발 디버그용 (파라미터 등 상세값)
  - `log.info()` → 주요 처리 흐름 (`FwPool.CONTROLLER_START_LOG` 등)
  - `log.warn()` → 비즈니스 경고
  - `log.error("... warn~~~", e)` → `CompWarnException` 캐치 시
  - `log.error("... error~~~", e)` → `Exception` 캐치 시

---

## 15. Enum 패턴

- 메뉴 전용 코드 Enum (DB 코드값이 아닌 로직 분기용) 작성 가능.
- `from(String code)` 정적 팩토리 메서드 권장 — 매칭 실패 시 `IllegalArgumentException`.

---

## 16. 중첩 클래스 (Static Inner Class) 패턴

복합 응답 DTO에 종속된 하위 객체는 static inner class로 정의 가능. 외부에서 사용하지 않는 내부 처리용 필드는 `@JsonIgnore`/`@JsonIgnoreProperties`로 응답 제외.

---

## 17. 금지 패턴 (MUST/NEVER)

- `@Transactional`을 Comp/Dao/Controller에 선언 → TxComp 메서드에만
- `wms_inven*` 직접 INSERT/UPDATE/DELETE → InvenManager 경유
- `null` 직접 비교 → `EmptyTool.empty()` / `notEmpty()`
- `System.out.println` → `log.*`
- 신규 응답 클래스 생성 → `ResponseData` 사용

> DB·쿼리 금지 패턴(소프트삭제·`WHERE 1=1`·`FN_CONCAT` 등)은 [02-mybatis-convention.md §6](../../20-database/30-convention/02-mybatis-convention.md) 참조.

---

*최초 작성: 2026-03-03 | 기준 메뉴: `be.md8000.mdpd01`*
