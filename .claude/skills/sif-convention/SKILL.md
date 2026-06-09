---
name: sif-convention
description: WMS SIF 외부연동(ERP/OMS/WES/DLV) 개발 컨벤션. 수신(E2W/RCV)·송신(W2E/SND) 코드 패턴, 판단 기준, 체크리스트 포함.
user-invocable: false
---

# WMS SIF 외부연동 컨벤션 (thin loader)

> 자동 로드 트리거: `sif/` 하위 코드 작성·수정, E2W(수신)/W2E(송신) 개발, Retrofit2 API 인터페이스 구성 시.
> 40-guide에 SIF 전용 문서가 아직 없으므로, 이 파일이 현행 SSoT. 향후 `DEV_DOC/ai-docs/30-interface/` 로 이관 예정.

## 로드 시점

- `/dev-if-all`, `/dev-if-mapper`, `/dev-if-dao`, `/dev-if-comp` 실행 시
- `sif/erp/`, `sif/oms/`, `sif/wes/`, `sif/dlv/`, `sif/wms/proc/biz/` 하위 파일 작성·수정 시
- SifProcComp / SifProcApi / SifController / SifScheduler 신규 작성 시
- `@SifValid`, `SifApiConnectionException` 등 SIF 전용 예외 사용 시

## 참조 문서 (필독)

| 주제 | 문서 |
|---|---|
| IF 연동 규칙 개요 | `DEV_DOC/ai-docs/30-interface/20-rule/00-interface-rule-overview.md` |
| E2W(ERP→WMS) 컨벤션 | `DEV_DOC/ai-docs/30-interface/30-convention/02-erp-to-wms-convention.md` |
| 현재 IF 명세 | `DEV_DOC/ai-docs/30-interface/80-spec/{IF폴더}/design-spec.md` |
| `sif_*` 테이블 스키마 | `DEV_DOC/ai-docs/10-database/00-database-overview.md` |
| TxComp 기본 패턴 | `DEV_DOC/ai-docs/20-backend/40-guide/08-txcomp-writing-rules.md` |

## 판단 기준 요약

### 연동 방향별 패키지

| 방향 | 경로 |
|---|---|
| ERP → WMS 수신 | `sif/erp/e2w/` |
| WMS → ERP 송신 | `sif/erp/w2e/` 또는 `sif/wms/proc/biz/{메뉴코드}/` |
| OMS → WMS 수신 | `sif/oms/rcv/` |
| WMS → OMS 송신 | `sif/wms/proc/biz/{메뉴코드}/` |
| WES ↔ WMS | `sif/wes/{vendor}/biz/{rcv|snd}/` |
| WMS → DLV | `sif/dlv/{vendor}/biz/` |

### 레이어 구성 판단

| 레이어 | 생성 조건 |
|---|---|
| `SifMapper.java + xml` | `sif_*` 이력 테이블 조회/저장이 있는 경우 |
| `SifDao` | Mapper가 있으면 항상 |
| `SifTxComp` | 내부 WMS 처리(InvenManager 등) 포함 시 |
| `SifComp` | 비즈니스 검증 + SifTxComp 호출 |
| `SifController` | E2W — REST로 외부에서 직접 호출 |
| `SifScheduler` | W2E — 배치/주기 송신 |

## skill 고유 메모

### W2E 송신 진입점 템플릿 (핵심만)

```java
@Service @RequiredArgsConstructor(onConstructor = @__(@Autowired)) @Slf4j
public class XXPC01SifProcComp extends SifWmsProcComp {
    XXPC01SifProcApi xxpc01SifProcApi;
    private final SifWmsPool.API procApi = SifWmsPool.API.getEnum(SifWmsPool.W2O_XX_PROC);

    @PostConstruct
    private void postConstruct() {
        xxpc01SifProcApi = SifWmsProcApiServiceUtil.createService(XXPC01SifProcApi.class);
    }

    public ResponseData sendSifXxProcs(Integer bizSeq, List<XXPC01XxTran> data, String userId, String userNm) {
        SifWmsTable apiData = super.getProcApiUrl(bizSeq, procApi.getApiId());
        if (EmptyTool.empty(apiData) || StringPool.N.equals(apiData.getUseYn())) {
            log.warn("IF 비활성 또는 설정 없음"); return new ResponseData();
        }
        SifWmsProcRequest<XXPC01SifProcXx> body =
            new XXPC01SifProcCompUtil().makeRequestBody(bizSeq, SifWmsPool.PROC_TYPE_PROCESS, data, userId, userNm);
        return sendXxIf(procApi, apiData, bizSeq, body);
    }
}
```

Retrofit2 API 인터페이스는 `@POST/@PATCH/@PUT("{url}") + @Path(encoded=true) + @Body` 조합 사용.

### SIF 전용 예외 (`CompWarnException` 금지)

`SifApiConnectionException` / `SifRequestFormatException` / `SifResponseFormatException` / `SifAlreadyProcessException` / `SifDuplicateIfKeyException` / `SifWarnException`

필수값 검증은 Bean 필드에 `@SifValid` 부여 후 `super.checkNull(bean)` 일괄 검증.

### 주요 상수

```
SifPool.IF_TARGET_WMS / OMS / ERP / DLV / WES
SifWmsPool.PROC_TYPE_PROCESS = "PROCESS"
SifWmsPool.PROC_TYPE_CANCEL  = "CANCEL"
```

### E2W/W2E 핵심 체크리스트

W2E 송신:
- [ ] `SifWmsProcComp` 상속 / `@PostConstruct`에서 `createService()`
- [ ] `SifWmsPool.API.getEnum()` 으로 API ID 확보
- [ ] `apiData == null || use_yn='N'` early return
- [ ] RequestBody는 `SifProcCompUtil`로 분리
- [ ] `@SifValid` 필수값 검증, `result.getSucceed()` 체크

E2W 수신:
- [ ] 수신 데이터 `sif_*` 이력 INSERT
- [ ] 중복 수신 방어 (IF 고유키 기준)
- [ ] 내부 WMS 처리는 TxComp로 분리
- [ ] 성공/실패 시 `if_stat_cd` 갱신, 실패 시 알람

### SIF 핵심 규칙 (BLOCKING)

1. 모든 외부 연동은 `sif_*` 이력 테이블 기록
2. 멱등성 — 동일 IF 재수신 시 중복 처리 방지
3. 실패 시 `if_stat_cd` 업데이트 → 재처리 가능 설계
4. 송신 전 IF 비활성(`use_yn='N'`) 체크 필수
5. SIF 예외만 사용 (`CompWarnException` 금지)
6. API Key / 접속정보 코드 하드코딩 금지 → `application-{profile}.properties`

### 주요 클래스 위치

| 클래스 | 경로 |
|---|---|
| `SifPool` | `sif/abc/SifPool.java` (수정 금지) |
| `SifWmsPool` | `sif/wms/SifWmsPool.java` |
| `SifWmsProcComp` | `sif/wms/proc/SifWmsProcComp.java` |
| `SifWmsProcApiServiceUtil` | `sif/wms/proc/SifWmsProcApiServiceUtil.java` |
| `SifWmsLog` | `sif/wms/SifWmsLog.java` |
| `@SifValid` | `sif/abc/annotation/` |
