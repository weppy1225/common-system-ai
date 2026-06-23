---
title: OMS 채번 공통모듈 — OMS 고유 차이
description: oms-be 문서번호(DocNoGenerator)·DB 시퀀스(SeqGenerator) 채번 시 common 업무번호 규칙과 다른 OMS 고유 차이분만 확인하는 참조 문서
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: database
tags:
  - backend
  - oms
  - doc-no
  - sequence
  - SeqGenerator
related:
  - patterns/20-database/20-rule/03-numbering-rule.md
  - patterns/20-database/20-rule/04-sequence-creation-rule.md
last_verified: 2026-06-22
---

# OMS 채번 공통모듈 — OMS 고유 차이

> 공통 골격(`DocNoGenerator` 동작·`DocNoBean` 필드·단건/다건 호출·내부 재시도·`mdm_doc_no` 정책)은 common 문서와 동일하다. 이 문서는 **OMS 고유 차이분만** 담는다.
> 공통 업무번호 규칙·DocNoGenerator → [03-numbering-rule.md](../../20-database/20-rule/03-numbering-rule.md)
> 공통 시퀀스 생성 규칙 → [04-sequence-creation-rule.md](../../20-database/20-rule/04-sequence-creation-rule.md)
> 전제(숨은 전제): OMS=PostgreSQL · MyBatis. "채번은 공통 모듈을 경유" 판단 규칙 → `oms-ai/.claude/rules/oms-backend-convention.md`.

---

## 1. OMS 고유 차이 (vs common)

| 항목 | common(WMS) | OMS 고유 | 근거(OMS 실제) |
|---|---|---|---|
| 문서번호 prefix | 업무별 고정 prefix 표(IW/OW/RT 등) | **`inoutTypeCd`(수불유형 코드)를 prefix 로 사용** — 고정표 없음, 업무별 Dao에서 실제 값 확인 | `DocNoBean.inoutTypeCd` |
| 월 단위 문서번호 | 없음 | **`getDocNoYm`** — `baseYmd`를 `yyyyMM`로 사용 | `fw/doc_no/DocNoGenerator#getDocNoYm` |
| `seqLen` 기본값 | 4 | **없으면 `OMSPool.REQ_NO_SEQ_LEN`** | `DocNoBean.seqLen` |
| DB 시퀀스 채번 | 명시 안 됨 | **`fw.seq.SeqGenerator` + `SeqEnum` + `sp_nextval`** 별도 모듈 | `fw/seq/` |
| 호출 레이어 | Dao 주입 | OMS 도 주로 Dao 주입(`ODRG01Dao` 등). 채번+write 동일 트랜잭션 필요 시 TxComp 위치 검토 | `ODRG01Dao`, `ODED02Dao` |

---

## 2. 문서번호 DocNoGenerator — OMS 고유 부분

핵심 파일: `oms-be/src/main/java/fw/doc_no/{DocNoGenerator,DocNoBean,DocNoDao}.java`, `fw/doc_no/DocNoMapper.xml`.

### 2.1 OMS DocNoBean 필드 차이

근거: `DocNoBean.java`.

| 필드 | 필수 | OMS 고유 의미 |
|---|---|---|
| `inoutTypeCd` | O | **문서번호 prefix 로 쓰이는 수불유형 코드** (WMS 의 고정 prefix 표와 달리 코드값으로 결정) |
| `baseYmd` | O | 기준일. `getDocNo()`=`yyMMdd`, `getDocNoYm()`=`yyyyMM` |
| `seqLen` | 선택 | 없으면 **`OMSPool.REQ_NO_SEQ_LEN`** |
| `incCnt` | 선택 | 한 번에 확보할 번호 개수. 없거나 1 미만이면 1 |
| `crntSeq` | 내부 | generator 가 세팅하는 현재 번호 |

### 2.2 포맷 (OMS 실제)

```java
// getDocNo()  — yyMMdd 기반
return inoutTypeCd + docNoYmd.substring(2) + DocNoUtil.convertSeq(crntSeq, seqLength);

// getDocNoYm() — yyyyMM 기반 (OMS 고유, common 에 없음)
return inoutTypeCd + yyyyMM + DocNoUtil.convertSeq(crntSeq, seqLength);
```

### 2.3 단건 호출 예

근거: `bc/od3000c/odrg01/ODRG01Dao.java`, `be/rt4000/rtst01/RTST01Dao.java`, `bc/od3000c/odst01c/cxl/ODST01CxlDao.java`.

```java
DocNoBean bean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq)
        .inoutTypeCd(inoutTypeCd)
        .baseYmd(baseYmd)
        .build();

docNoGenerator.getDocNo(bean);
return bean.getDocNo();
```

주의: `inoutTypeCd`, `baseYmd`, `bizSeq`는 업무별 기존 Dao에서 어떤 값을 쓰는지 확인 후 맞춘다. 이름만 보고 prefix 를 만들지 않는다.

### 2.4 다건·월단위 호출 예

근거: `be/rt4000/rtst01/excel/RTST01ExcelDao.java`, `be/st5000/adst01/ADST01Dao.java`.

```java
DocNoBean bean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq).inoutTypeCd(inoutTypeCd).baseYmd(baseYmd)
        .incCnt(count)
        .build();

docNoGenerator.getDocNo(bean);
List<String> docNoList = bean.getDocNoList();
```

월 단위는 `docNoGenerator.getDocNoYm(bean)` 호출 후 `bean.getDocNoYm()` 또는 `bean.getDocNoYmList()` 사용.

---

## 3. DB 시퀀스 SeqGenerator (OMS 고유, common 에 없음)

핵심 파일: `oms-be/src/main/java/fw/seq/{SeqGenerator,SeqEnum,SeqDao}.java`, `fw/seq/SeqMapper.xml`.

### 3.1 API

```java
List<Integer> getIntSeqs(SeqEnum seqEnum, Integer cnt)
List<Long>    getLongSeqs(SeqEnum seqEnum, Integer cnt)
```

`SeqGenerator`는 `seqEnum.getSeqNm()`을 구해 `SeqDao`로 넘긴다. `seqNm`이 비어 있으면 빈 리스트 반환, `cnt`가 `null`이거나 0 이하이면 0 처리.

`SeqMapper`의 PostgreSQL 현재 구현:

```sql
SELECT * FROM sp_nextval(#{seqNm}, #{cnt})
```

`sp_nextval` 내부 주석 기준 실제 sequence 이름은 `p_seq_name || '_seq'` 형태다.

### 3.2 SeqEnum

근거: `SeqEnum.java`.

| enum | seqNm |
|---|---|
| `MDM_CONT` | `mdm_cont` |
| `MDM_PROD` | `mdm_prod` |
| `OMS_ORDER` | `OMS_ORDER` |
| `OMS_ORDER_PROD` | `OMS_ORDER_PROD` |

신규 enum 추가 전 실제 DB sequence 존재 여부를 먼저 확인한다. `SeqEnum.SEQ_SUFFIX`는 현재 빈 문자열이고, DB 함수가 `_seq`를 붙인다.

### 3.3 사용 예

근거: `be/od3000/oded02/ODED02Dao.java`.

```java
List<Long> prodSeqList = seqGenerator.getLongSeqs(SeqEnum.OMS_ORDER_PROD, prodListSize);
```

반복 insert 에서 각 row마다 `nextval` 을 호출하지 않고, 필요한 개수만큼 한 번에 받아 DTO 에 배분한다.

---

## 4. Mapper 직접 nextval 관측 (OMS 실제)

검색 근거상 일부 Mapper XML 에 직접 `nextval('oms_order_prod_seq')`가 남아 있다.

예: `bc/od3000c/odrg01/ODRG01Mapper.xml`, `bc/od3000c/odrg02/ODRG02Mapper.xml`, `bc/od3000c/odst01c/ODST01CMapper.xml`, `be/od3000/odst01/ODST01Mapper.xml`, `be/od3000/odst01/excel/ODST01ExcelMapper.xml`.

| 상황 | 권장 |
|---|---|
| Java 에서 여러 DTO 에 seq 세팅 | `SeqGenerator.getIntSeqs/getLongSeqs` |
| 단일 insert SQL 내부에서만 PK 필요 + 기존 같은 Mapper 가 직접 `nextval` 사용 | 같은 모듈 기존 패턴 우선, 영향 범위 확인 |
| 문서번호가 필요한 업무 번호 | `DocNoGenerator` |

---

## 5. OMS 채번 체크리스트

- 업무 번호이면 `DocNoGenerator`, PK·FK 시퀀스이면 `SeqGenerator` 인지 먼저 구분한다.
- `inoutTypeCd`, `baseYmd`, `bizSeq`는 같은 도메인 기존 Dao 에서 실제 값을 확인한다(prefix 추정 금지).
- 다건 문서번호는 `incCnt` 세팅 후 `getDocNoList()` / `getDocNoYmList()` 사용.
- 다건 PK 는 `SeqGenerator` 로 필요한 개수를 한 번에 받는다.
- 신규 `SeqEnum` 추가 전 DB sequence 와 `sp_nextval` 호출 가능 여부 확인.
- `MDM_DOC_NO`, `sp_nextval`, sequence 이름을 직접 조작하는 코드를 새로 만들지 않는다.
