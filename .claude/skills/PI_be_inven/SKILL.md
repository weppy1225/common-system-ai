---
name: PI_be_inven
description: BE 재고 확정 TxComp 개발 (InvenManager iw/ow/im/ad/rt 연동). /PI_be_inven {메뉴코드}
when_to_use: "입고 확정 만들어줘", "출고 확정 개발해줘", "재고 모듈 만들어줘", "InvenManager 연동해줘", "재고 증감 처리 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-opus-4-7
---

# BE 재고 모듈 개발 [PI_be_inven]

다음 지시에 따라 **입출고 확정 TxComp (InvenManager 연동)**를 개발한다.

## STEP 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`src/main/java/...`, `DEV_DOC/...`, `./gradlew`, `build/...`)는 `$BE_DIR`(= 형제 `../{프로젝트}-be`) 기준이다.

## 적용 대상

- **입고 확정** (IW): `InvenManager.iw(InvenDTO)` — 재고 증가
- **출고 확정** (OW/DL): `InvenManager.ow(InvenDTO)` — 재고 차감
- **반품 처리** (RT): `InvenManager.rt(InvenDTO)` — 반품 재고 증가
- **재고 조정** (IV): `InvenManager.ad(InvenDTO)` — 증감 조정

## 핵심 원칙 (절대 준수)

```
❌ wms_inven_holding 테이블 직접 UPDATE
❌ TxComp 외부에서 InvenManager 호출
✅ InvenManager.iw()/ow()/rt()/ad() 경유 — TxComp 내부에서만
✅ 문서번호: DocNoGenerator.getDocNo() 경유
```

## 실행 절차

### Step 1 — 문서 및 레퍼런스 확인 (BLOCKING)

#### 1-1. 레이어 현황 파악
`@code-layer-explorer {메뉴코드}` 를 호출해 기존 레이어 파일 목록을 확인한다.

#### 1-2. 산출물 및 가이드 읽기
1. `DEV_DOC/ai-docs/20-backend/80-spec/{기능폴더}/api.md` 읽기
2. `.claude/rules/biz-framework.md` — InvenManager/DocNoGenerator 사용 규칙
3. `DEV_DOC/ai-docs/10-database/00-database-overview.md` — 관련 테이블 확인
4. **레퍼런스 TxComp 소스**:
   - IW: `src/main/java/be/iw1000/iwrq01/` 하위 TxComp 파일
   - OW: `src/main/java/be/ow5000/` 하위 TxComp 파일
   - IV: `src/main/java/be/iv3100/` 하위 TxComp 파일
5. `src/main/java/fw/inven/bean/InvenDTO.java` — InvenDTO 필드 구조
6. `src/main/java/fw/inven/bean/InvenInoutVO.java` — 입출고 VO 필드
7. `src/main/java/fw/inven/bean/InvenVO.java` — 재고 VO 필드

### Step 2 — InvenDTO 구성 이해

```
InvenDTO
├── InvenInoutVO   ← 입출고 헤더 (문서번호, 업무구분, 거래처, 날짜 등)
├── InvenVO        ← 재고 위치 (로케이션, 팔레트, SKU 등)
└── InvenSkuVO     ← SKU 정보 (유통기한, LOT번호 등) — 필요시
```

### Step 3 — CompUtil에 InvenDTO 조립 메서드 추가

InvenDTO 조립은 CompUtil로 분리:

```java
/** 입고 확정용 InvenDTO 조립 */
public InvenDTO makeInvenDTOForConfirm({메뉴코드}{리소스} item) {
    InvenInoutVO invenInoutVO = new InvenInoutVO();
    invenInoutVO.setBizSeq(item.getBizSeq());
    invenInoutVO.setDocNo(item.getDocNo());
    invenInoutVO.setCenterSeq(item.getCenterSeq());
    invenInoutVO.setWhSeq(item.getWhSeq());
    invenInoutVO.setClientSeq(item.getClientSeq());
    invenInoutVO.setInoutQty(item.getConfirmQty());
    invenInoutVO.setRegId(TokenTool.getUserId());

    InvenVO invenVO = new InvenVO();
    invenVO.setBizSeq(item.getBizSeq());
    invenVO.setProdSeq(item.getProdSeq());
    invenVO.setLocSeq(item.getLocSeq());

    return new InvenDTO(invenInoutVO, invenVO);
}
```

### Step 4 — DocNoGenerator 호출 (필요 시)

```java
// Comp에서 호출 — 문서번호 채번 후 TxComp에 전달
String docNo = docNoGenerator.getDocNo(bizSeq, inoutTypeCd, baseYmd);
item.setDocNo(docNo);
```

> DocNoGenerator는 TxComp 내부가 아닌 **Comp에서 미리 채번** 후 전달

### Step 5 — {메뉴코드}TxComp — 확정 메서드 작성

**입고 확정 예시**:
```java
@Transactional
public int confirm{리소스}Tx({메뉴코드}{리소스} item) {
    log.info(FwPool.COMP_START_LOG);

    // 1. 입고 상태 업데이트 (확정으로 변경)
    item.setInwStatCd(WMSPool.INW_STAT_CONFIRM);
    {메뉴코드_인스턴스}Dao.updateConfirmStatus(item);

    // 2. 재고 증가 (InvenManager 경유 — 직접 수정 절대 금지)
    InvenDTO invenDTO = {메뉴코드_인스턴스}CompUtil.makeInvenDTOForConfirm(item);
    invenManager.iw(invenDTO);   // 입고: iw / 출고: ow / 반품: rt / 조정: ad

    log.info(FwPool.COMP_END_LOG);
    return 1;
}
```

**다건 확정 (리스트) 예시**:
```java
@Transactional
public int confirm{리소스}sTx(List<{메뉴코드}{리소스}> items) {
    log.info(FwPool.COMP_START_LOG);
    int retCnt = 0;
    for ({메뉴코드}{리소스} item : items) {
        item.setInwStatCd(WMSPool.INW_STAT_CONFIRM);
        {메뉴코드_인스턴스}Dao.updateConfirmStatus(item);
        InvenDTO invenDTO = {메뉴코드_인스턴스}CompUtil.makeInvenDTOForConfirm(item);
        invenManager.iw(invenDTO);
        retCnt++;
    }
    log.info(FwPool.COMP_END_LOG);
    return retCnt;
}
```

### Step 6 — {메뉴코드}Comp — 확정 메서드 작성

```java
/** 입고 확정
 * 흐름: 상태 검증 → 문서번호 채번 → 확정 처리(재고 반영)
 */
public {메뉴코드}Response confirm{리소스}(Integer bizSeq, List<Integer> seqs) {
    ...
    List<{메뉴코드}{리소스}> items = {메뉴코드_인스턴스}Dao.select{리소스}sForConfirm(bizSeq, seqs);
    checkAllItemsConfirmable(items);
    String docNo = docNoGenerator.getDocNo(bizSeq, WMSPool.INOUT_TYPE_IW, DateTool.getToday());
    items.forEach(item -> item.setDocNo(docNo));
    retCnt = {메뉴코드_인스턴스}TxComp.confirm{리소스}sTx(items);
    ...
}
```

### Step 7 — 주의사항 체크

```
✅ InvenManager는 반드시 @Transactional TxComp 안에서만 호출
✅ DocNoGenerator.getDocNo()는 Comp에서 호출 후 TxComp에 전달
✅ 상태코드 값은 DEV_DOC/ai-docs/10-database/90-schema/30-data/01-common-code.md에서 확인
✅ InvenDTO 조립은 CompUtil 메서드로 분리
✅ 다건 처리는 단건 확정 로직을 루프로 반복 (트랜잭션은 전체를 하나로)
```

### Step 8 — JUnit 작성 및 통과 (BLOCKING)

```bash
./gradlew test --tests '*.ZTEST_{메뉴코드}TxComp'
# Ant 환경: ant test -Dtest.pattern=ZTEST_{메뉴코드}TxComp
# 결과 확인: find build/test-results/test -name 'TEST-*ZTEST_{메뉴코드}TxComp*.xml'
```

- ✅ PASS → 완료
- ❌ FAIL → 에러 메시지 기반으로 원인 분석 후 코드 수정, 재실행
- 재고 처리 실패 시 wms_inven 직접 조회로 데이터 상태 확인 권장
