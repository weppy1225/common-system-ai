---
name: PI-be-comp
description: 【BE Comp 개발】 CompUtil → TxComp → Comp → Controller 레이어 개발. Mapper·Dao 완료 후 비즈니스 레이어 구현. 일반 메뉴 기능 전용. /PI-be-comp {메뉴코드} 형식으로 실행한다. 사용자가 "Comp 만들어줘", "Controller 만들어줘", "비즈니스 레이어 만들어줘", "PI-be-comp 실행해줘", "dev-comp 실행해줘", "Comp TxComp Controller 개발해줘" 라고 말해도 이 스킬을 사용한다. Mapper와 Dao가 완료된 후 실행한다. SIF 인터페이스 개발은 별도 스킬을 사용한다.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# BE Comp 개발 [PI-be-comp]

다음 지시에 따라 **CompUtil → TxComp → Comp → Controller 레이어**를 개발한다.

> **일반 메뉴 기능 개발용** — SIF 인터페이스 개발은 별도 스킬 사용

## 전제 조건 확인 (BLOCKING)

개발 전 아래가 완료되어 있어야 한다:
- Mapper JUnit 테스트 통과 ✅
- Dao JUnit 테스트 통과 ✅

## 코드 작성 3대 원칙

### 1. 일관성 — 기존 코드와 패턴을 맞춘다
같은 도메인(패키지)의 기존 Comp 파일을 먼저 읽고,
메서드 구조·예외 처리 방식·변수명·로그 문구를 동일한 패턴으로 작성한다.

### 2. 가독성 — 코드가 문장처럼 읽혀야 한다

```java
// ✅ 각 단계가 한 줄로 읽힘 — "중복 확인 → SKU 초기화 → 이력 세팅 → 저장"
public Response insertProd(Prod prod) {
    checkDuplicateProdNo(prod);           // 품목번호 중복 확인
    resetSkuFieldsIfNotManaged(prod);     // SKU 미관리 시 관련 필드 초기화
    setRegisterAudit(prod);               // 등록 이력 세팅
    retCnt = prodTxComp.insertProdTx(prod);
}
```

### 3. CompUtil 분리 — 공통 유틸 로직은 CompUtil로 뺀다

---

## 실행 절차

### Step 1 — 문서 및 레퍼런스 확인

#### 1-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

#### 1-2. 산출물 및 가이드 읽기
1. `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md` 읽기
2. `DEV_DOC/ai-docs/20-backend/40-guide/06-comp-writing-rules.md` 읽기
4. `DEV_DOC/ai-docs/20-backend/40-guide/07-computil-writing-rules.md` 읽기
5. `DEV_DOC/ai-docs/20-backend/40-guide/08-txcomp-writing-rules.md` 읽기
6. `DEV_DOC/ai-docs/20-backend/40-guide/02-controller-writing-rules.md` 읽기
7. **같은 도메인의 기존 Comp 소스 읽기** (일관성 확보):
   - MDM: `src/main/java/be/md8000/mdpd01/MDPD01Comp.java`, `MDPD01CompUtil.java`, `MDPD01TxComp.java`
   - IW: `src/main/java/be/iw1000/iwrq01/IWRQ01Comp.java`, `IWRQ01TxComp.java`

---

### Step 2 — CompUtil 설계 (먼저 결정)

**CompUtil로 추출해야 하는 것:**

| 유형 | 기준 | 예시 |
|---|---|---|
| 복합 유효성 검증 | 조건이 3개 이상이거나 루프가 있는 검증 | `validatePrintLabel()` |
| DTO/객체 생성 | 필드 세팅이 3개 이상인 객체 조립 | `makeFileData()` |
| 비즈니스 상태 초기화 | 여러 필드를 한꺼번에 리셋하는 로직 | `resetSkuMngSku()` |
| 공통 audit 세팅 | 등록/수정 이력 컬럼 세팅 | `setRegisterAudit()`, `setModifyAudit()` |

**Comp에 남겨도 되는 것:** `checkDuplicate*()` — 1~2줄짜리 단순 중복 체크

---

### Step 3 — {메뉴코드}CompUtil.java 작성

```java
@Component
public class {메뉴코드}CompUtil {

    public void setRegisterAudit({메뉴코드}{리소스} target) {
        target.setRegId(TokenTool.getUserId());
        target.setRegDt(DateTool.getNowTimestamp());
    }

    public void setModifyAudit({메뉴코드}{리소스} target) {
        target.setModId(TokenTool.getUserId());
        target.setModDt(DateTool.getNowTimestamp());
    }
}
```

---

### Step 4 — {메뉴코드}TxComp.java 작성

**규칙:**
- `@Transactional`은 이 레이어 메서드에만 — Comp/Controller에 절대 금지
- 메서드 접미사: `Tx`
- TxComp는 트랜잭션 경계만 담당

```java
@Service @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}TxComp {

    private final {메뉴코드}Dao {메뉴코드_인스턴스}Dao;

    @Transactional
    public int insert{리소스}Tx({메뉴코드}{리소스} put{리소스}) { ... }

    @Transactional
    public int update{리소스}Tx({메뉴코드}{리소스} patch{리소스}) { ... }

    @Transactional
    public int delete{리소스}sTx(Integer bizSeq, List<Integer> seqs) { ... }
}
```

---

### Step 5 — {메뉴코드}Comp.java 작성

**규칙:**
- `@Transactional` 절대 사용 금지
- try 블록 내부는 **3~6단계의 명확한 흐름**으로 작성

```java
@Service @Slf4j @RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class {메뉴코드}Comp {

    private final {메뉴코드}TxComp    {메뉴코드_인스턴스}TxComp;
    private final {메뉴코드}Dao       {메뉴코드_인스턴스}Dao;
    private final {메뉴코드}CompUtil  {메뉴코드_인스턴스}CompUtil;

    // try { 흐름(3~6줄) } catch(CompWarnException) { } catch(Exception) { } finally { result.setProcCnt(retCnt); }
}
```

---

### Step 6 — {메뉴코드}Controller.java 작성

```java
@Validated @RestController @RequiredArgsConstructor(onConstructor = @__(@Autowired)) @Slf4j
@RequestMapping("/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}s")
public class {메뉴코드}Controller {
    // GET (단건/팝업 조회), POST (목록 조회), PUT (등록, 201), PATCH (수정), DELETE (삭제)
    // log.info(FwPool.CONTROLLER_START_LOG) / CONTROLLER_END_LOG 포함
    // @Transactional 절대 없음
}
```

---

### Step 7 — 가독성 자가 검토 (BLOCKING — JUnit 작성 전 필수)

```
✅ Comp의 각 public 메서드 try 블록을 위에서 아래로 읽었을 때 한국어로 설명할 수 있는가?
✅ 3줄 이상의 인라인 로직 블록이 없는가?
✅ 복잡한 조건식이 CompUtil 메서드로 추출되었는가?
✅ 같은 도메인의 기존 Comp와 예외처리·로그 패턴이 동일한가?
✅ CompUtil 메서드명이 메서드 내부를 읽지 않아도 역할을 알 수 있는가?
```

---

### Step 8 — JUnit 테스트 작성 및 실행 (BLOCKING)

1. 테스트 클래스 작성 (`DEV_DOC/ai-docs/20-backend/50-test/02-test-coding-convention.md` 참조)
   - `ZTEST_{메뉴코드}CompUtil.java` (CompUtil 존재 시)
   - `ZTEST_{메뉴코드}Comp.java`
   - `ZTEST_{메뉴코드}Controller.java`

2. 레이어별 순차 실행 — 직전 단계 PASS 후 다음 진행

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}CompUtil'   # CompUtil 있는 경우
./gradlew test --tests '*.ZTEST_{메뉴코드}Comp'
./gradlew test --tests '*.ZTEST_{메뉴코드}Controller'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}*
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}*.xml'
```

---

### Step 9 — Controller 후 통합검증 + 코드 개선 (BLOCKING)

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

### Step 10 — 다음 단계 안내
통합검증 + simplify 회귀 통과 후 `/util-work-output` 스킬로 산출물 생성 안내
