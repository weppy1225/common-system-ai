---
name: PI_be_all
description: BE 전체 레이어 일괄 개발 (Mapper→Dao→TxComp→Comp→Controller, 각 레이어 JUnit 통과 후 진행). /PI_be_all {메뉴코드}
when_to_use: "BE 전체 개발", "백엔드 전부 만들어줘", "전 레이어 개발", "백엔드 코드 다 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE 전체 개발 [PI_be_all]

다음 지시에 따라 **Mapper → Dao → CompUtil → TxComp → Comp → Controller** 전 레이어를 한 번에 개발한다.

> **일반 메뉴 기능 개발용** — SIF 인터페이스 개발은 별도 스킬 사용
> 개별 스킬(`/PI_be_mapper`, `/PI_be_dao`, `/PI_be_comp`)을 순차 통합한 명령어다.
> 각 레이어 JUnit 테스트 통과는 여전히 BLOCKING 조건이다 — 실패 시 수정 후 재실행.

---

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`src/main/java/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)는 `$BE_DIR`(= 형제 `../{프로젝트}-be`) 기준이다. 생성 코드는 `$BE_DIR/src/...` 에 떨어진다.

---

## Phase 0 — 전제 문서 확인 (BLOCKING)

아래 순서로 수행한다. 생략 금지.

### 0-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

### 0-2. DB 문서 확인
`@db-doc-reader {관련 테이블명}` 를 호출해 컬럼·PK/FK 정보를 확인한다.

### 0-3. 산출물 읽기
1. `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md` — 기능 명세

---

## Phase 1 — 레퍼런스 소스 탐색

도메인에 맞는 기존 소스를 읽어 패턴 파악:

| 도메인 | 레퍼런스 경로 |
|---|---|
| MDM | `src/main/java/be/md8000/mdpd01/` — Mapper, Dao, CompUtil, TxComp, Comp, Controller |
| IW  | `src/main/java/be/iw1000/iwrq01/` — 동일 |
| 기타 | 가장 유사한 도메인 선택 |

해당 패키지의 **Comp, CompUtil, TxComp, Controller** 모두 읽는다.
새 방식 임의 도입 금지 — 기존 패턴을 그대로 따른다.

---

## Phase 2 — Bean(DTO) 확인 및 작성

`be/{그룹}/{메뉴코드}/bean/` 하위 파일 확인:
- 파일이 있으면: 필드가 api.md와 일치하는지 확인 후 필요시 보완
- 파일이 없으면: api.md 기준으로 아래 Bean 파일 먼저 작성

| 파일명 | 용도 |
|---|---|
| `{메뉴코드}Search.java` | 검색 조건 + 목록 결과 행 |
| `{메뉴코드}{리소스}.java` | 단건 조회 / 등록·수정 요청 VO |
| `{메뉴코드}Response.java` | API 응답 DTO (ResponseData 상속) |

---

## Phase 3 — Mapper 레이어 개발

### 3-1. {메뉴코드}Mapper.java 작성

```
- @Repository 필수
- 파라미터 2개 이상: @Param 명시
- 메서드명: search*s, select*, insert*, update*, delete*s, check*, get*
```

### 3-2. {메뉴코드}Mapper.xml 작성

위치: Mapper.java와 **같은 디렉토리**

```
✅ 첫 번째 줄 주석: /** {클래스명}.{메서드명} {설명} */
✅ namespace: 풀 패키지 경로 (예: be.md8000.mdpd01.MDPD01Mapper)
✅ parameterType / resultType: 풀 패키지 경로
✅ WHERE절 use_yn = 'Y' (또는 del_yn = 'N') 항상 포함
✅ 동적 조건: <if test="@fw.tool.EmptyTool@notEmpty(field)">
✅ LIKE: ${@fw.config.DBConfig@DB_PREFIX}FN_CONCAT('%', #{val}, '%')
✅ 소프트 삭제: UPDATE SET use_yn = 'N' (DELETE FROM 금지)
✅ PK INSERT: NEXTVAL('{테이블명}_seq')
✅ INSERT: use_yn = 'Y', reg_dt = NOW() 하드코딩
✅ UPDATE: mod_id = #{modId}, mod_dt = NOW() 포함
```

### 3-3. JUnit 테스트 작성 및 실행 ✅ BLOCKING

`src/main/java/be/{그룹}/{메뉴코드}/test/ZTEST_{메뉴코드}Mapper.java` 작성
- `DEV_DOC/ai-docs/20-backend/50-test/02-test-coding-convention.md` 참조

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}*
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}Mapper*.xml'
```

- ✅ PASS → Phase 4 진행
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행

---

## Phase 4 — Dao 레이어 개발

### 4-1. {메뉴코드}Dao.java 작성

```java
@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Dao {

    private final {메뉴코드}Mapper {메뉴코드_인스턴스}Mapper;

    /** 메서드별 log.info(FwPool.DAO_START_LOG) / DAO_END_LOG 포함 */
    /** Mapper 1:1 위임 — 비즈니스 로직 없음 */
}
```

### 4-2. JUnit 테스트 작성 및 실행 ✅ BLOCKING

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Dao'
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}Dao*.xml'
```

- ✅ PASS → Phase 5 진행
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행

---

## Phase 5 — CompUtil 설계 및 작성

### 5-1. CompUtil 추출 대상 먼저 결정

아래 유형에 해당하면 CompUtil 메서드로 추출한다:

| 유형 | 기준 | 예시 |
|---|---|---|
| 복합 유효성 검증 | 조건 3개 이상 또는 루프 포함 | `validateXxx()` |
| DTO/객체 필드 세팅 | 필드 세팅 3개 이상 | `makeXxx()` |
| 비즈니스 상태 초기화 | 여러 필드 한꺼번에 리셋 | `resetXxx()` |
| 공통 audit 세팅 | 등록/수정 이력 컬럼 세팅 | `setRegisterAudit()`, `setModifyAudit()` |
| 조건 분기 계산 | switch/if 분기 값 계산 | `getXxxByType()` |

### 5-2. {메뉴코드}CompUtil.java 작성

```java
@Service
public class {메뉴코드}CompUtil {
    public void setRegisterAudit({메뉴코드}{리소스} target) { ... }
    public void setModifyAudit({메뉴코드}{리소스} target) { ... }
    // api.md 기반 추가 유틸 메서드
}
```

### 5-3. JUnit 테스트 작성 및 실행 ✅ BLOCKING

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}CompUtil'
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}CompUtil*.xml'
```

---

## Phase 6 — TxComp 레이어 개발

```java
@Service @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}TxComp {
    @Transactional   // ← 이 레이어에만 선언
    public int insert{리소스}Tx({메뉴코드}{리소스} put{리소스}) { ... }
    // Comp/Controller에서 @Transactional 절대 금지
}
```

---

## Phase 7 — Comp 레이어 개발

### 코드 가독성 3대 원칙 (필수)

```java
// ✅ 흐름이 읽히는 구조
public Response insertItem(Item item) {
    checkDuplicateItemNo(item);               // 번호 중복 확인
    itemCompUtil.setRegisterAudit(item);      // 등록 이력 세팅
    retCnt = itemTxComp.insertItemTx(item);   // 저장
}
```

### 7-1. {메뉴코드}Comp.java 작성

- try 블록은 3~6줄의 흐름(문장)으로만 구성
- `@Transactional` 절대 사용 금지

### 7-2. 가독성 자가 검토 (BLOCKING — Controller 진행 전 필수)

```
✅ Comp의 각 public 메서드 try 블록을 위에서 아래로 읽었을 때 한국어로 설명 가능한가?
✅ 3줄 이상의 인라인 로직 블록이 없는가?
✅ 복잡한 조건식이 CompUtil 메서드로 추출되었는가?
✅ 같은 도메인의 기존 Comp와 예외처리·로그 패턴이 동일한가?
```

---

## Phase 8 — Controller 레이어 개발

```java
@Validated @RestController @Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping("/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}s")
public class {메뉴코드}Controller {
    // GET (단건/팝업 조회), POST (목록 조회), PUT (등록, 201), PATCH (수정), DELETE (삭제)
    // @Transactional 절대 없음
}
```

---

## Phase 9 — 전 레이어 JUnit 회귀 테스트 ✅ BLOCKING

### 9-1. 레이어별 순차 실행

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}Mapper'
./gradlew test --tests '*.ZTEST_{메뉴코드}Dao'
./gradlew test --tests '*.ZTEST_{메뉴코드}CompUtil'   # CompUtil 있는 경우
./gradlew test --tests '*.ZTEST_{메뉴코드}Comp'
./gradlew test --tests '*.ZTEST_{메뉴코드}Controller'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}*
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}*.xml'
```

각 단계 ✅ PASS 후 다음 진행. ❌ FAIL 시 원인 분석 → 코드 수정 → 재실행.

### 9-2. Suite 회귀 실행 (권장)

```bash
./gradlew test --tests '*.ZTEST_SUITE_{메뉴코드}'
```

### 9-3. Controller 후 통합검증 + 코드 개선 (BLOCKING)

```bash
# JWT 발급
TOKEN=$(curl -s -D - -X POST http://localhost:18081/wms-be/login \
  -H "Content-Type: application/json" -H "User-Agent: Mozilla/5.0" \
  -d '{"userId":"zintest","password":"1111"}' \
  2>&1 | grep -i "authorization:" | tr -d '\r' | awk '{print $2}')

# 신규 Controller 모든 엔드포인트 curl 검증
```

```
# 코드 개선
/simplify
```

> ❌ JUnit 통과만 보고하고 통합검증을 생략하면 작업 미완료 — 보고 무효

---

## Phase 10 — 완료 보고

모든 테스트 통과 후:
1. 완료된 파일 목록과 각 파일 경로를 출력한다
2. `/util-work-output` 스킬로 FE용 산출물 생성 안내
