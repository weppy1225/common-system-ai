---
title: OMS 백엔드 레이어 작성 패턴 — OMS 고유 차이
description: oms-be 레이어(CompUtil·TxComp·Comp·Controller) 작성 시 common 공통 패턴과 다른 OMS 고유 차이분만 확인하는 참조 문서
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: backend
tags:
  - backend
  - oms
  - layer-pattern
  - txcomp
  - computil
related:
  - patterns/30-backend/be-layer-pattern.md
  - patterns/30-backend/40-guide/06-comp-writing-rules.md
  - patterns/30-backend/40-guide/07-computil-writing-rules.md
  - patterns/30-backend/40-guide/08-txcomp-writing-rules.md
last_verified: 2026-06-22
---

# OMS 백엔드 레이어 작성 패턴 — OMS 고유 차이

> 공통 골격(레이어 책임 분리·`@Transactional` 위치·메서드 네이밍·파일 처리 매트릭스·공통 예외/응답)은 common 문서와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 공통 레이어 구조 → [be-layer-pattern.md](../../30-backend/be-layer-pattern.md)
> 공통 레이어별 코드 템플릿 → [06-comp-writing-rules.md](../../30-backend/40-guide/06-comp-writing-rules.md), [07-computil-writing-rules.md](../../30-backend/40-guide/07-computil-writing-rules.md), [08-txcomp-writing-rules.md](../../30-backend/40-guide/08-txcomp-writing-rules.md)
> 전제(숨은 전제): OMS 는 전통 Spring(Spring Boot 아님) · MyBatis · 멀티DB(OMS=PostgreSQL, ERP=SQL Server). WMS 계열과 동일한 `fw/*` 프레임워크를 공유한다.

---

## 1. OMS 고유 차이 (vs common)

| 항목 | common(WMS) | OMS 고유 | 근거(OMS 실제) |
|---|---|---|---|
| InvenManager | TxComp 에서 재고 호출 | **OMS 에 InvenManager 없음** — 재고 로직은 모듈별 구현 | — |
| FileComp 파일 처리 매트릭스 | TxComp 작성규칙에 매트릭스 명시 | **OMS 적용 여부 미확인** — 파일 처리 시 해당 모듈 기존 코드 확인 | 미확인 |
| TX 메서드 접미사 | `TX`로 통일 | **모듈별 혼용** — `MYPG01C`=`updateMyPageTx`, `ODRG01`=`...TX`. 같은 모듈 기존 표기를 따른다 | `MYPG01CTxComp.updateMyPageTx`, `bc/od3000c/odrg01/` |
| Controller `@RequestMapping` | — | **첫 경로 변수는 사업장 `{bizSeq}`** | `@RequestMapping("/{bizSeq}/odrg01/orders")` |
| 채번 호출 위치 | TxComp 에서 호출 | OMS 는 `DocNoGenerator`/`SeqGenerator` 가 주로 **Dao 에 주입** → [oms-03-numbering-module.md](./oms-03-numbering-module.md) | `ODRG01Dao`, `ODED02Dao` |

OMS 레이어 개요·예외 흐름 라우팅: `oms-ai/02-백엔드-패턴.md`, 판단/금지패턴: `oms-ai/.claude/rules/oms-backend-convention.md`.

---

## 2. OMS 공유 프레임워크 유틸·상수 (확인됨)

OMS 는 WMS 계열과 동일한 `fw/*` 유틸을 공유한다(아래는 OMS 실제 경로로 확인됨).

```java
EmptyTool.empty(x) / EmptyTool.notEmpty(x)         // fw/tool/EmptyTool.java
TokenTool.getLoginUserId()                          // fw/auth/token/TokenTool.java
DateTool.now()                                      // fw/tool/DateTool.java
MsgTool.getMsg(key) / MsgTool.getMsgParam(key,..)   // fw/msg/MsgTool.java
log.info(FwPool.CONTROLLER_START_LOG / COMP_START_LOG / DAO_START_LOG)  // fw/constant/FwPool.java
StringPool.Y / StringPool.N                         // fw/constant/StringPool.java
```

공통 예외 클래스 중 OMS 실제 존재 확인: `fw/exception/warn/ZinNotFoundException.java`, `fw/exception/warn/AlreadyProcessException.java`.

---

## 3. OMS 실제 코드 예 (모듈코드 구체값)

### 3.1 CompUtil make* 네이밍 (ODRG01)

근거: `bc/od3000c/odrg01/ODRG01CompUtil.java` — `makeOrderSeachData`, `makeInsertOrderData`, `makeInsertOrderProdData`, `makeUpdateOrderData`.

MUST: `setRegId`/`setRegDt`/`setModId`/`setModDt` 등 이력 세팅은 **CompUtil 에서** 한다(Comp 직접 작성 금지).

```java
public void makeInsertOrderData(ODRG01Order order) {
    order.setRegId(TokenTool.getLoginUserId());
    order.setRegDt(DateTool.now());
    // 상태·기본값 초기화 ...
}
```

### 3.2 TxComp 실제 예 (MYPG01C)

근거: `bc/co1000c/mypg01c/MYPG01CTxComp.java`. 이 모듈은 접미사 `Tx`(소문자) 사용.

```java
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class MYPG01CTxComp {
    private final MYPG01CDao mypg01cDao;

    @Transactional
    public void updateMyPageTx(MYPG01CUser user) {
        if (EmptyTool.notEmpty(user.getPassword())) {
            user.setPwdUpdDate(DateTool.now());
            mypg01cDao.updateMyPage(user);
            user.setRegId(TokenTool.getLoginUserId());
            user.setRegDt(DateTool.now());
            mypg01cDao.insertPwdHistory(user);
        }
        mypg01cDao.updateMyPageEmail(user);
        mypg01cDao.updateCont(user);
    }
}
```

### 3.3 Comp 예외 흐름 (ODRG01)

근거: `bc/od3000c/odrg01/`.

```java
public ODRG01Response getDeliveryDates(int contSeq) {
    ODRG01Response result = new ODRG01Response();
    try {
        result.setDeliveryDates(odrg01Dao.selectDeliveryDates(contSeq));
    } catch (CompWarnException e) {
        result.setWarn(e);
        throw new ResponseWarnException(e, result);
    } catch (Exception e) {
        result.setSystemError(e);
        throw new ResponseErrorException(e, result);
    }
    return result;
}
```

### 3.4 Controller `{bizSeq}` 경로 (ODRG01)

규칙(MUST/NEVER) → `.claude/rules/oms-backend-convention.md §4`

```java
@Validated @RestController @Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping("/{bizSeq}/odrg01/orders")
public class ODRG01Controller {
    private final ODRG01Comp odrg01Comp;

    @GetMapping("/{contSeq}/deliverydate")
    public ResponseEntity<ODRG01Response> getDeliveryDates(@PathVariable Integer contSeq) {
        log.info(FwPool.CONTROLLER_START_LOG);
        ODRG01Response response = odrg01Comp.getDeliveryDates(contSeq);
        log.info(FwPool.CONTROLLER_END_LOG);
        return ResponseEntity.ok(response);
    }
}
```

### 3.5 TxComp 결과 검증 (다건 부분 성공 방지)

```java
int retCnt = dao.updateOrder(order);
if (retCnt == 0) {
    throw new ZinNotFoundException(MsgTool.getMsgParam("message.warn.NotFoundWithParam", order.getOrderSeq()));
}
if (retCnt < seqs.size()) {
    throw new AlreadyProcessException(MsgTool.getMsg("message.warn.AlreadyProcess"));
}
```

NEVER: TxComp 트랜잭션 내부에서 외부 호출(SIF/HTTP/파일 원격) — 트랜잭션 점유 최소화(→ `.claude/rules/oms-backend-convention.md §3`).
