---
title: 업무번호 생성 규칙
description: WMS 입고/출고/반품 등 업무번호를 채번할 때 규칙과 DocNoGenerator 사용법을 확인할 때 읽는다
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: rule
domain: database
tags:
  - database
  - numbering
  - DocNoGenerator
  - business-number
  - sequence
---

# 업무번호 생성 규칙 (Numbering Rule)

## 1. 개요

WMS 시스템에서 사용하는 업무번호는 다음 목표를 만족하도록 설계한다.

* **전역 유일성 (Global Unique)**
* **시간 기반 정렬 가능**
* **대량 트랜잭션 처리 가능**
* **업무 유형 식별 가능**

기본 구성 규칙

```
Prefix(2) + YYMMDD(6) + Sequence(4)
```

| 구성요소 | 자리수 | 설명 |
|---------|--------|------|
| Prefix | 2 | 업무 유형 식별 코드 (IW, OW, IB 등) |
| YY | 2 | 연도 2자리 (예: 2026년 → 26) |
| MM | 2 | 월 2자리 (01~12) |
| DD | 2 | 일 2자리 (01~31) |
| Sequence | 4 | 일자별 순번 (0001~9999) |

> 업무번호의 날짜는 **YY(2자리 연도)** 사용 — DB 날짜 컬럼의 YYYYMMDD(8자리)와 다름. 번호 길이 최소화를 위한 의도적 설계.

### 채번 방식

업무번호의 순번(4자리)은 **DB Sequence가 아닌 `mdm_doc_no` 테이블의 `next_seq`로 관리**한다.

| 항목 | 설명 |
|------|------|
| 채번 테이블 | `mdm_doc_no` |
| 복합 PK | `biz_seq` + `inout_type_cd` + `base_ymd` |
| 순번 컬럼 | `next_seq` — 해당 일자 최초 채번 시 1, 이후 +1씩 증가 |
| 공통 모듈 | `fw/doc_no/DocNoGenerator.getDocNo(param)` |

> ❌ `mdm_doc_no` 테이블 직접 SELECT/UPDATE 금지
> ✅ 반드시 `DocNoGenerator.getDocNo(param)` 경유 — 동시성 제어(SELECT FOR UPDATE) 및 채번 로직 내장

예

```
OW2603090001
```

---

## 2. 업무번호 규칙

| column | 업무명 | Prefix | 규칙 | 예시 |
| --------- | ------ | ------ | -------------------- | ------------ |
| inbiz_no | 입하번호 | IB | IB + YYMMDD + SEQ(4) | IB2603090001 |
| inwh_no | 입고번호 | IW | IW + YYMMDD + SEQ(4) | IW2603090001 |
| return_no | 반품번호 | RT | RT + YYMMDD + SEQ(4) | RT2603090001 |
| ad_no | 재고조정번호 | AD | AD + YYMMDD + SEQ(4) | AD2603090001 |
| etc_no | 예외출고번호 | EX | EX + YYMMDD + SEQ(4) | EX2603090001 |
| rp_no | 품목전환번호 | RP | RP + YYMMDD + SEQ(4) | RP2603090001 |
| st_no | 세트작업번호 | ST | ST + YYMMDD + SEQ(4) | ST2603090001 |
| mv_no | 재고이동번호 | IM | IM + YYMMDD + SEQ(4) | IM2603090001 |
| outbiz_no | 출하번호 | OB | OB + YYMMDD + SEQ(4) | OB2603090001 |
| outwh_no | 출고번호 | OW | OW + YYMMDD + SEQ(4) | OW2603090001 |
| load_no | 상차번호 | LD | LD + YYMMDD + SEQ(4) | LD2603090001 |

---

## 3. 처리 묶음 번호

처리 묶음 번호는 배치 또는 트랜잭션 단위를 식별하기 위한 번호이다.

구성 규칙

```
YYMMDD + HHMMSS + MS
```

| column | 업무명 | 규칙 | 예시 |
| -------------- | ------ | -------------- | --------------- |
| proc_bundle_no | 처리묶음번호 | YYMMDDHHMMSSMS | 260309081523125 |

구성 설명

| 항목 | 자리수 | 설명 |
| --- | --- | ------ |
| 연월일 | 6 | YYMMDD |
| 시분초 | 6 | HHMMSS |
| 밀리초 | 3 | MS |

---

## 4. 그룹 출고 번호

여러 출고건을 하나의 그룹으로 묶기 위한 번호이다.

구성 규칙

```
OW + YYMMDD + Sequence(4)
```

| column | 업무명 | 규칙 | 예시 |
| -------------- | ------ | -------------------- | ------------ |
| group_outwh_no | 그룹출고번호 | OW + YYMMDD + SEQ(4) | OW2602270002 |

---

## 5. 순번(next_seq) 정책

`mdm_doc_no.next_seq` 는 다음 정책을 따른다.

* 사업장(`biz_seq`) + 수불유형(`inout_type_cd`) + 기준일자(`base_ymd`) 조합별로 독립 관리
* 일자 기준 증가 — 날짜가 바뀌면 새 행으로 1부터 재시작
* 4자리 zero-pad 고정 (0001~9999)
* 최초 채번 시 INSERT, 이후 UPDATE(+1) — `ON CONFLICT` 방식으로 원자적 처리

예

```
0001
0002
0003
...
9999
```

---

## 6. 번호 생성 예시

예시 데이터

```
IB2603090001
IW2603090001
RT2603090001
AD2603090001
EX2603090001
RP2603090001
ST2603090001
IM2603090001
OB2603090001
OW2603090001
LD2603090001
```

---

## 7. 번호 생성 방식 — DocNoGenerator

업무번호는 **애플리케이션 공통 모듈**이 생성한다. DB에서 직접 채번하지 않는다.

### 메서드 시그니처

```java
// fw/doc_no/DocNoGenerator.java
public DocNoBean getDocNo(DocNoBean param)
```

### DocNoBean 필드 (@NonNull 필드는 필수)

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `bizSeq` | `Integer` | ✅ | 사업장 SEQ |
| `inoutTypeCd` | `String` | ✅ | 수불유형코드 (InvenPool 상수 사용) |
| `baseYmd` | `String` | ✅ | 기준일자 YYYYMMDD |
| `incCnt` | `Integer` | - | 다건 발행 시 발행 수량 (단건이면 생략) |
| `seqLen` | `Integer` | - | 순번 자릿수 (기본값: 4) |

### 호출 패턴 — 단건

```java
// Dao 레이어에서 호출 (주입: @RequiredArgsConstructor)
private final DocNoGenerator docNoGenerator;

DocNoBean bean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq)
        .inoutTypeCd(InvenPool.OW)   // InvenPool 상수 필수 ("OW" 직접 사용 금지)
        .baseYmd(reqYmd)             // YYYYMMDD 형식
        .build();

docNoGenerator.getDocNo(bean);

String outwhNo = bean.getDocNo();   // → "OW2603090001"
```

### 호출 패턴 — 다건

```java
DocNoBean bean = DocNoBean.docNoPubBuilder()
        .bizSeq(bizSeq)
        .inoutTypeCd(InvenPool.IW)
        .baseYmd(reqYmd)
        .incCnt(items.size())        // 발행 수량 지정
        .build();

docNoGenerator.getDocNo(bean);

List<String> docNoList = bean.getDocNoList();   // → ["IW2603090001", "IW2603090002", ...]
```

### 내부 처리 흐름

```
1. mdm_doc_no WHERE biz_seq=? AND inout_type_cd=? AND base_ymd=? SELECT FOR UPDATE (동시성 제어)
2. 행 없음 → INSERT next_seq=1 / 있음 → UPDATE next_seq = next_seq + incCnt
3. inout_type_cd(2) + baseYmd.substring(2)(6) + LPAD(crntSeq, 4, '0') 조합 반환
4. DuplicateKeyException / 낙관적 락 실패 시 최대 5회 재시도
```

생성 결과 예

```
OW2603090001
```

---

## 8. 정렬 특성

본 번호 체계는 문자열 정렬 시 생성 순서를 유지한다.

예

```
OW2603090001
OW2603090002
OW2603090003
```

---

## 9. 운영 주의사항

* 동일 사업장 + 수불유형 + 날짜 기준 최대 9999건 생성 가능
* 중복 방지 및 동시성 제어는 `DocNoGenerator` 내부의 `SELECT FOR UPDATE` 로 처리 — 직접 채번 금지
* 번호는 생성 후 변경 불가
* 업무번호 컬럼(`inwh_no`, `outwh_no` 등)에 UNIQUE Index 적용 권장
