---
title: MDWH01 BE 구현 흐름 (서버 처리)
description: mdwh01 창고의 API별 백엔드 컴포넌트 시퀀스 다이어그램과 메뉴 고유 예외·이슈를 기술.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdwh01
domain: master
depends_on:
  - "70-knowledgebase/_common/be-architecture.md"
  - "70-knowledgebase/_common/be-exceptions.md"
  - "70-knowledgebase/mdwh01/mdwh01-05-api.md"
  - "70-knowledgebase/mdwh01/mdwh01-04-be-mapper-sql.md"
tags: [detail-design, backend, sequence, master]
---

# MDWH01 BE 구현 흐름 (서버 처리)

## 1. API별 시퀀스 다이어그램

### POST /{bizSeq}/mdwh01/whs — 창고 목록 조회

```
Controller          Comp              Dao             Mapper
    │                  │                │                │
    │─ postWhs() ─────>│                │                │
    │                  │─ searchWhs() ─>│                │
    │                  │                │─ searchWhs() ─>│
    │                  │                │<───────────────│ (창고 목록 반환)
    │                  │<──────────────-│                │
    │<─────────────────│ (response 반환)│                │
```

---

### PUT /{bizSeq}/mdwh01/whs — 창고 등록

```
Controller          Comp (@Transactional)       Dao                   Mapper
    │                  │                          │                      │
    │─ putWhs() ──────>│                          │                      │
    │                  │─ wh.setBizSeq(bizSeq)    │                      │
    │                  │─ checkDuplicateWhNm()    │                      │
    │                  │                          │─ checkDuplicate() ──>│
    │                  │                          │<─────────────────────│
    │                  │  [중복 존재] ──────────────────────────────→ ZinExistDataException
    │                  │─ 등록일시·등록자 설정     │                      │
    │                  │─ 기본 위치명 생성 (whNm+"BL")                   │
    │                  │─ insertWh() ────────────>│                      │
    │                  │                          │─ insertWh() ────────>│ (창고 저장, whSeq 반환)
    │                  │                          │─ insertbizWh() ─────>│ (사업장-창고 매핑)
    │                  │                          │─ insertDefaultLoc() >│ (기본 위치 생성, locSeq 반환)
    │                  │                          │─ updateDefLocBarcode>│ (바코드 생성·저장)
    │                  │  [1건 미만 저장] ────────────────────────────→ InsertFailException
    │                  │─ selectTplCenterBizSeq()>│                      │
    │                  │                          │─ selectTplCenter() ─>│ (위탁 사업장 목록 조회)
    │                  │                          │<─────────────────────│
    │                  │  loop [위탁 사업장 수만큼 반복]                  │
    │                  │─ insertbizWh() ─────────>│                      │
    │                  │                          │─ insertbizWh() ─────>│ (위탁 사업장-창고 매핑)
    │                  │                          │<─────────────────────│
    │                  │  end loop                │                      │
    │<─────────────────│ (procCnt 반환, 201 Created)                     │
```

---

### GET /{bizSeq}/mdwh01/whs/{whSeq} — 창고 단건 조회

```
Controller          Comp              Dao             Mapper
    │                  │                │                │
    │─ getWhs() ──────>│                │                │
    │                  │─ selectWh() ──>│                │
    │                  │                │─ selectWh() ──>│
    │                  │                │<───────────────│ (창고 단건 반환)
    │                  │<───────────────│                │
    │<─────────────────│ (wh 반환)      │                │
```

---

### PATCH /{bizSeq}/mdwh01/whs — 창고 수정

```
Controller          Comp              Dao                   Mapper
    │                  │                │                      │
    │─ patchWh() ─────>│                │                      │
    │                  │─ checkUpdateValidation()              │
    │                  │  ├─ checkDuplicateWhNm()              │
    │                  │  │              │─ checkDuplicate() ──>│
    │                  │  │  [중복] ──────────────────────────→ ZinExistDataException
    │                  │  ├─ checkHasFunc(wh) [처리기능 1개 이상]
    │                  │  │  [없음] ──────────────────────────→ ZinRequestParamValidException
    │                  │  └─ selectWhFuncCount()               │
    │                  │                │─ selectWhFuncCount() >│ (현재 다른 창고의 기능 개수 집계)
    │                  │                │<─────────────────────│
    │                  │  [사용 중지 처리]                      │
    │                  │    checkHasAllWhFunc() [기능별 창고 최소 1개 확인]
    │                  │  [기능 변경 처리]                      │
    │                  │    기능별 카운트 조정 후 checkHasAllWhFunc()
    │                  │  [조건 미충족] ────────────────────→ NotMeetConditionsException
    │                  │─ 수정일시·수정자·기본위치명 설정        │
    │                  │─ updateWh() ────────────>│            │
    │                  │                          │─ updateWh() ────────>│ (창고 정보 갱신)
    │                  │                          │─ updateDefaultLoc() >│ (기본 위치명 갱신)
    │                  │                          │─ updateIfWhId() ────>│ (IF창고ID 갱신)
    │                  │<───────────────          │                      │
    │<─────────────────│ (procCnt 반환)           │                      │
```

---

### DELETE /{bizSeq}/mdwh01/whs — 창고 삭제

```
Controller          Comp (@Transactional)       Dao                   Mapper
    │                  │                          │                      │
    │─ deleteWhs() ───>│                          │                      │
    │                  │─ checkDeleteValidation()  │                      │
    │                  │  ├─ checkIsUsedWh()        │                      │
    │                  │  │                         │─ checkIsUsedWh() ───>│ (수불 이력 조회)
    │                  │  │                         │<─────────────────────│
    │                  │  │  [이력 있음] ────────────────────────────────→ ZinExistDataException
    │                  │  └─ loop [선택 창고 수만큼 반복]                  │
    │                  │       selectWhFuncCount()  │                      │
    │                  │                           │─ selectWhFuncCount() >│
    │                  │                           │<─────────────────────│
    │                  │       checkHasAllWhFunc() [기능별 창고 최소 1개 확인]
    │                  │       [조건 미충족] ──────────────────────────→ NotMeetConditionsException
    │                  │  end loop                  │                      │
    │                  │─ deleteWhs() ──────────────>│                     │
    │                  │                            │─ deleteLocs() ──────>│ (위치 삭제)
    │                  │                            │─ deleteBizWhs() ────>│ (사업장-창고 매핑 삭제)
    │                  │                            │─ deleteWhs() ───────>│ (창고 삭제)
    │                  │                            │<─────────────────────│
    │                  │  [0건 삭제] ──────────────────────────────────→ ZinNotFoundException
    │                  │  [삭제 건수 != 요청 건수] ────────────────────→ AlreadyProcessException
    │<─────────────────│ (procCnt 반환)              │                     │
```

## 2. 예외 처리 목록 (메뉴 고유)

| 조건 | 예외 클래스 | 메시지 키 |
|---|---|---|
| 동일 센터 내 창고명 중복 | ZinExistDataException | message.md8000.mdwh01.DuplicateWhNm |
| 처리기능 1개 미만 | ZinRequestParamValidException | message.md8000.mdwh01.NeedWarehouseFunctions |
| 기능별 마지막 창고 삭제/비활성 시도 | NotMeetConditionsException | message.md8000.mdwh01.ExistUnspecifedWhFunction |
| 수불 이력이 있는 창고 삭제 시도 | ZinExistDataException | message.md8000.mdwh01.UsedWhSeq |
| 창고 등록 결과 0건 | InsertFailException | message.error.InsertFail |
| 삭제 결과 0건 (대상 없음) | ZinNotFoundException | message.warn.NotFound |
| 삭제 건수 불일치 (이미 처리됨) | AlreadyProcessException | message.warn.AlreadyProcess |

## 3. 기술 이슈

### 3-1. 물리 DELETE 사용

창고 삭제 시 소프트 삭제(use_yn = 'N')가 아닌 물리 DELETE가 사용된다. 창고, 위치, 사업장-창고 매핑 모두 물리 삭제된다. 재고 수불 이력 유무로 삭제를 차단하나, 재고 이력 외 다른 참조(예: 재고 테이블의 현재 재고)가 존재하는 경우 정합성 문제가 발생할 수 있다. 자세한 내용은 99-issues 참조.

### 3-2. 삭제 건수 판별 로직의 잠재적 문제

`deleteWhs` 메서드에서 `deleteBizWhs` 건수가 `whs.size()`보다 작으면 `deleteWhs`를 호출하지 않고 bizCnt를 반환한다. 사업장-창고 매핑이 없는 창고(매핑 누락 케이스)가 있을 경우 창고 본 테이블이 삭제되지 않는 상황이 발생할 수 있다. 자세한 내용은 99-issues 참조.

### 3-3. 위탁 사업장 창고 매핑 시 N+1 반복 DML

창고 등록 시 위탁 사업장 수만큼 `insertbizWh`가 반복 호출된다. 위탁 사업장이 많은 경우 DB 부하가 증가할 수 있다.
