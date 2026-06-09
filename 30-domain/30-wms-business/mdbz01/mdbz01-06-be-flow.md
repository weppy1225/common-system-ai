---
title: MDBZ01 BE 구현 흐름 (서버 처리)
description: mdbz01 사업장의 백엔드 업무별 시퀀스 다이어그램, 예외 처리 목록, 기술 이슈.
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: spec
menu_code: mdbz01
domain: master
depends_on:
  - "30-domain/_common/be-layer-pattern.md"
  - "30-domain/mdbz01-v2/mdbz01-05-api.md"
  - "30-domain/mdbz01-v2/mdbz01-03-data-model.md"
  - "30-domain/mdbz01-v2/mdbz01-04-be-mapper-sql.md"
tags: [detail-design, backend, sequence, master]
---

# MDBZ01 BE 구현 흐름 (서버 처리)

## 1. 컴포넌트 구성

> 공통 레이어 역할 정의 → [_common/be-layer-pattern.md](../_common/be-layer-pattern.md)

| 클래스명 | MDBZ01 특이사항 |
|---|---|
| `MDBZ01Controller` | `@RequestMapping("/{bizSeq}/mdbz01/bizs")`. `/tpl` 경로에 GET/POST/PUT/PATCH 4개 메서드 공존 — HTTP 메서드로만 구분 |
| `MDBZ01Comp` | 사업장 저장 시 multipart 파일 처리 분기 포함. 물류대행 관련 일부 검증 블록이 현재 주석 처리 상태 |
| `MDBZ01TxComp` | `saveBizCenterTX` 하나의 메서드에 insert·update·delete 3가지 경로가 모두 포함되어 있음 |
| `MDBZ01Dao` | `insertBizCenter` SQL이 자사 센터 등록과 위탁 신청 두 경로 모두에서 공유됨 |

---

## 2. 업무 목록

| 업무명 | HTTP + 경로 |
|---|---|
| 수정 가능 사업장 목록 조회 | `GET /{bizSeq}/mdbz01/bizs/editable/bizs/{regBizSeq}` |
| 사업장 단건 조회 | `GET /{bizSeq}/mdbz01/bizs/{selectedBizSeq}` |
| 사업장 수정 | `POST /{bizSeq}/mdbz01/bizs` |
| 물류센터 목록 조회 | `GET /{bizSeq}/mdbz01/bizs/{selectedBizSeq}/centers` |
| 물류센터 저장 (등록·수정·삭제) | `PUT /{bizSeq}/mdbz01/bizs/centers` |
| 대행의뢰신청업체 조회 | `GET /{bizSeq}/mdbz01/bizs/{selCenterSeq}/tplReq` |
| 의뢰 수락/거절 | `PATCH /{bizSeq}/mdbz01/bizs/{selBizSeq}/tplReq` |
| 대행센터지정 팝업 조회 | `GET /{bizSeq}/mdbz01/bizs/tpl` |
| 대행센터지정 수정 | `PATCH /{bizSeq}/mdbz01/bizs/tpl` |
| 물류대행업체 검색 (팝업) | `POST /{bizSeq}/mdbz01/bizs/tpl` |
| 대행 의뢰 신청 | `PUT /{bizSeq}/mdbz01/bizs/tpl` |
| 의뢰 취소 (의뢰자) | `PATCH /{bizSeq}/mdbz01/bizs/cancel` |

---

## 3. 업무별 시퀀스 다이어그램

### 3-1. 수정 가능 사업장 목록 조회

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: searchEditableBizs(regBizSeq, authTypeCd, userId)
    Comp->>D: searchEditableBizs()
    D-->>Comp: bizList
    Comp-->>C: bizList
```

### 3-2. 사업장 단건 조회

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: selectBiz(bizSeq)
    Comp->>D: selectBiz(bizSeq)
    D-->>Comp: biz 객체
    Comp->>Comp: logoFileSeq 있으면 파일 경로를 URL로 변환
    Comp-->>C: biz 객체
```

### 3-3. 사업장 수정

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: updateBiz(bizObj, file)
    Comp->>D: selectBiz(bizSeq)
    D-->>Comp: existBiz
    Comp->>TX: updateBizTX(bizObj, file, existBiz)
    alt 새 파일 있으면
        TX->>TX: 기존 파일 삭제 후 신규 파일 업로드
    else 기존 파일 있고 새 파일 없으면
        TX->>TX: 기존 파일 삭제
    end
    TX->>D: updateBiz(bizObj)
    D-->>TX: procCnt
    TX-->>Comp: procCnt
    Comp-->>C: procCnt
```

### 3-4. 물류센터 목록 조회

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: selectBizCenter(bizSeq, regBizSeq)
    Comp->>D: selectBizCenter()
    D-->>Comp: bizCenter 목록
    Comp-->>C: bizCenter 목록
```

### 3-5. 물류센터 저장 (등록·수정·삭제)

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: saveBizCenter(saveObj)
    Comp->>Comp: 위탁 센터 주소/전화번호 필수 검증
    alt 검증 실패
        Comp-->>C: ZinBadRequestException
    end
    Comp->>TX: saveBizCenterTX(saveObj)

    opt insertList 있으면
        loop insertList 각 건
            TX->>D: checkDuplicateCenterNm()
            D-->>TX: result
            alt 중복이면
                TX-->>C: ZinExistDataException
            end
            TX->>D: insertCenter()
            D-->>TX: centerSeq (auto-key)
            TX->>D: insertBizCenter()
            TX->>D: insertCenterAutorityToSuper()
            TX->>D: searchWhTemplate()
            D-->>TX: 템플릿 창고 목록
            loop 템플릿 창고 N건
                TX->>D: insertDefaultWh()
                TX->>D: insertbizWh()
                TX->>D: insertDefaultLoc()
            end
        end
    end

    opt updateList 있으면
        loop updateList 각 건
            TX->>D: checkDuplicateCenterNm()
            D-->>TX: result
            alt 중복이면
                TX-->>C: AlreadyProcessException
            end
            TX->>D: checkExistTplBizCenter()
            D-->>TX: result
            alt 위탁 관계 있으면
                TX-->>C: AlreadyProcessException
            end
            TX->>D: updateCenter()
            D-->>TX: updateCnt
            alt updateCnt = 0
                TX-->>C: AlreadyProcessException
            end
        end
    end

    opt deleteList 있으면
        TX->>D: checkExistUserCenter()
        D-->>TX: result
        alt 사용자 권한 존재
            TX-->>C: AlreadyProcessException
        end
        TX->>D: checkExistTplBizCenter()
        D-->>TX: result
        alt 위탁 관계 있으면
            TX-->>C: AlreadyProcessException
        end
        TX->>D: checkExistCenterWh()
        D-->>TX: result
        alt 창고 있으면
            TX-->>C: AlreadyProcessException
        end
        loop deleteList 각 건
            TX->>D: deleteCenter()
            TX->>D: deleteUserCenter()
        end
    end

    TX->>D: 사용 센터 존재 확인
    D-->>TX: result
    alt 사용 센터 0개
        TX-->>C: NotMeetConditionsException
    end
    TX-->>Comp: succeed
    Comp-->>C: succeed
```

### 3-6. 대행의뢰신청업체 조회

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: selectReqBizCenter(centerSeq)
    Comp->>D: selectReqBizCenter()
    D-->>Comp: bizCenter 목록
    Comp-->>C: bizCenter 목록
```

### 3-7. 의뢰 수락/거절

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: respTplCenter(centerObj)
    Comp->>D: checkExistBizCenter(bizSeq, centerSeq)
    D-->>Comp: result
    alt 레코드 없으면
        Comp-->>C: AlreadyProcessException
    end
    Comp->>Comp: cfmYn 미처리면 Y로 세팅
    Comp->>TX: respTplCenterTX(centerObj)
    TX->>D: respTplCenter() [cfm_yn / use_yn 갱신]
    TX->>D: updateBizBiz() [use_yn 재계산]
    opt 수락(useYn=Y)이면
        TX->>D: insertBizWh() [의뢰 사업장에 창고 접근 권한 부여]
    end
    TX-->>Comp: procCnt
    Comp-->>C: procCnt
```

### 3-8. 대행센터지정 팝업 조회

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: selectTplBizCenter(bizSeq)
    Comp->>D: selectTplBizCenter()
    D-->>Comp: bizCenter 목록
    Comp-->>C: bizCenter 목록
```

### 3-9. 대행센터지정 수정

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: update3plCenter(saveObj)
    Comp->>TX: update3plCenterTX(updateList)
    loop updateList N건
        TX->>D: updateTplCenter()
    end
    TX-->>Comp: procCnt
    Comp-->>C: procCnt
```

### 3-10. 물류대행업체 검색 (팝업)

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant D as Dao
    C->>Comp: searchTplBizCenter(searchObj)
    Comp->>D: searchTplBizCenter()
    D-->>Comp: bizCenter 목록 (reqSts 포함)
    Comp-->>C: bizCenter 목록
```

### 3-11. 대행 의뢰 신청

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: reqTplCenter(reqObj)
    Comp->>TX: reqTplCenterTX(checkedList, bizSeq, note)
    loop checkedList N건
        TX->>D: checkExistBizBiz(bizSeq, regBizSeq)
        D-->>TX: result
        alt BizBiz 없으면
            TX->>D: insertBizBiz()
        end
        TX->>D: checkExistBizCenter(bizSeq, centerSeq)
        D-->>TX: result (ACCEPT/REQUEST/DENIED/없음)
        alt ACCEPT 또는 REQUEST 상태
            TX-->>C: AlreadyProcessException
        else DENIED 상태
            TX->>D: deleteBizCenter() [기존 거절 의뢰 초기화]
            TX->>D: insertBizCenter() [재신청]
        else 신규
            TX->>D: insertBizCenter()
        end
    end
    TX-->>Comp: procCnt
    Comp-->>C: procCnt
```

### 3-12. 의뢰 취소 (의뢰자)

```mermaid
sequenceDiagram
    participant C as Controller
    participant Comp
    participant TX as TxComp
    participant D as Dao
    C->>Comp: cancelRequest(centerObj)
    Comp->>D: checkExistBizCenter(bizSeq, centerSeq)
    D-->>Comp: result
    alt 레코드 없으면
        Comp-->>C: AlreadyProcessException(이미 처리됨)
    end
    Comp->>D: checkExistBizCenter() [상태 재확인]
    D-->>Comp: status
    alt REQUEST 상태 아니면
        Comp-->>C: AlreadyProcessException(이미 처리됨)
    end
    Comp->>TX: cancelRequestTX(bizSeq, centerSeq)
    TX->>D: cancelRequest() [물리 DELETE]
    TX-->>Comp: result
    Comp-->>C: result
```

---

## 4. 예외 처리 목록

| 발생 조건 | 예외 클래스 | 응답 메시지 |
|---|---|---|
| 위탁 센터 등록·수정 시 주소·주소상세·전화번호 누락 | `ZinBadRequestException` | 주소, 주소상세, 전화번호는 필수입니다 |
| 센터 등록 시 사업장 내 센터명 중복 | `ZinExistDataException` | 센터명이 중복됩니다 |
| 센터 수정 시 사업장 내 센터명 중복 | `AlreadyProcessException` | 센터명이 중복됩니다 |
| 센터 수정·삭제 시 위탁 업체 연결됨 | `AlreadyProcessException` | 위탁업체가 존재합니다 |
| 센터 삭제 시 사용자 권한 잔존 | `AlreadyProcessException` | 권한센터가 존재합니다 |
| 센터 삭제 시 창고 잔존 | `AlreadyProcessException` | 창고를 먼저 삭제해주세요 |
| 센터 저장 후 사용 중인 센터 0개 | `NotMeetConditionsException` | 하나 이상의 센터가 사용되어야 합니다 |
| 센터 수정 결과 0건 | `AlreadyProcessException` | 데이터가 존재하지 않습니다 |
| 의뢰 수락/거절 시 대상 미존재 | `AlreadyProcessException` | 요청하신 데이터를 찾을 수 없습니다 |
| 의뢰 취소 시 대상 미존재 | `AlreadyProcessException` | 이미 처리되었습니다 |
| 의뢰 취소 시 이미 ACCEPT 또는 DENIED | `AlreadyProcessException` | 이미 처리되었습니다 |
| 대행 의뢰 신청 시 ACCEPT 또는 REQUEST 상태 | `AlreadyProcessException` | 이미 처리되었습니다 |
| Dao·파일 처리 중 시스템 오류 | `ResponseErrorException` | 시스템 에러 |

---

## 5. 기술 이슈

### 이슈 1. 물류대행(위탁) 기능 일부 주석 처리

`updateBiz` 로직에서 물류대행 여부 변경 시 전체 센터의 위탁 여부를 미사용으로 일괄 업데이트하는 코드가 주석 처리됨. Comp의 위탁 업체 존재 검증 블록도 비활성화 상태. 코드가 완전히 삭제되지 않고 주석으로 남아 향후 요건 변경 시 의도 파악이 어려울 수 있음.

### 이슈 2. cancelRequest에서 checkExistBizCenter 이중 호출

`cancelRequest` 내부에서 동일 쿼리를 연속으로 두 번 호출함. 첫 번째는 존재 확인, 두 번째는 상태(REQUEST 여부) 확인 목적. 불필요한 DB 조회이며 두 호출 사이 상태 변경 시 결과 불일치 가능성 있음.

### 이슈 3. 센터 등록 시 창고 자동 생성 — 템플릿 미존재 엣지케이스

`saveBizCenterTX` 트랜잭션 내에서 창고 템플릿을 조회하고 루프를 돌며 기본 창고를 생성함. 창고 템플릿 데이터가 없는 환경에서는 루프가 실행되지 않아 창고 없이 센터만 등록되는 상황이 발생할 수 있음.

### 이슈 4. TxComp가 조회성 Dao를 직접 호출하는 구조

`MDBZ01TxComp`가 `MDBZ01Dao`를 직접 주입받아 조회와 쓰기를 모두 처리함. `saveBizCenterTX` 하나의 메서드에 삽입·수정·삭제·검증 로직이 집중되어 유지보수 시 영향 범위 파악이 어려움.
