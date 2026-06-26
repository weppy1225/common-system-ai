---
title: WMS→ERP 송신 (W2E) 코딩 컨벤션
description: WMS→외부(ERP/OMS) 송신(W2E) SIF 모듈 개발 시 진입점 클래스 템플릿·Retrofit2 API 인터페이스·SifWms* 클래스 위치를 참조
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: interface
related:
  - spec/common-system/_knowledge/interface/convention/01-erp-to-wms.md
  - patterns/30-backend/40-guide/08-txcomp-writing-rules.md
tags:
  - sif
  - w2e
  - retrofit2
  - convention
---

# WMS→ERP 송신 (W2E) 코딩 컨벤션

> 이 문서는 W2E(WMS→ERP 송신) 코드 작성 패턴(진입점 템플릿·Retrofit2·클래스 위치·체크리스트)을 기술한다.
> 수신(E2W) 컨벤션은 [01-erp-to-wms.md](./01-erp-to-wms.md) 참조.

---

## 1. W2E 송신 진입점 클래스 템플릿

`SifWmsProcComp` 를 상속하고 `@PostConstruct` 에서 Retrofit2 서비스를 생성한다.

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

---

## 2. Retrofit2 API 인터페이스

`@POST` / `@PATCH` / `@PUT("{url}")` + `@Path(encoded = true)` + `@Body` 조합을 사용한다.

---

## 3. SifWms* 주요 클래스 위치

| 클래스 | 경로 |
|---|---|
| `SifPool` | `sif/abc/SifPool.java` (수정 금지) |
| `SifWmsPool` | `sif/wms/abc/SifWmsPool.java` |
| `SifWmsProcComp` | `sif/wms/proc/abc/SifWmsProcComp.java` |
| `SifWmsProcApiServiceUtil` | `sif/wms/proc/SifWmsProcApiServiceUtil.java` |
| `SifWmsLog` | `sif/wms/abc/SifWmsLog.java` |
| `@SifValid` | `sif/abc/annotation/` |

---

## 4. W2E 송신 작성 체크리스트

- [ ] `SifWmsProcComp` 상속 / `@PostConstruct` 에서 `createService()`
- [ ] `SifWmsPool.API.getEnum()` 으로 API ID 확보
- [ ] `apiData == null || use_yn = 'N'` early return
- [ ] RequestBody 는 `SifProcCompUtil` 로 분리
- [ ] `@SifValid` 필수값 검증, `result.getSucceed()` 체크
