---
title: API 네이밍 규칙
description: API URL 생성 규칙(HTTP 메서드·인터페이스 ID·URL 패턴)을 코드 작성 또는 API 설계 시 참조. 메뉴코드 체계는 02-menu-code-rule.md 참조.
status: active
version: 1.2.0
author: ShinHyunKyu
last_modified_by: ShinHyunKyu
repo_role: ai-hub
agent_usage: rule
domain: backend
tags:
  - api-naming
  - url-convention
  - rest
---

# API 네이밍 규칙 (API Naming Rule)

## 1. 시스템 구분

| 시스템구분 | 설명 |
|-----------|------|
| P | WEB (백오피스 관리자) |
| M | Mobile (모바일 웹) |

> **메뉴코드 체계·메뉴그룹·업무약어·코드 생성규칙의 SoT는 → [`02-menu-code-rule.md`](./02-menu-code-rule.md).** 본 문서는 **메뉴코드가 정해진 뒤의 API 네이밍**만 다룬다. (아래 규칙의 `{메뉴코드}`는 02에서 채번한 값을 그대로 사용)

## 2. API 생성규칙

`/{bizSeq}` 는 SaaS 멀티테넌트(하나의 고객 조직)를 의미한다. API 생성 시 `{bizSeq}` 를 변경하지 말고 그대로 사용한다.

> 표기 규약: `{리소스_소문자}s` = 리소스 복수형으로, `@RequestMapping` 의 base 경로다(예: `conts`·`inbizs`·`prods`). 단건·복수건·하위행위 API 모두 이 base 경로에 매달린다.

### 2.1 메서드 분기 기준 (BLOCKING — 신규 개발은 이 기준을 따른다)

| 요청 형태 | 메서드·경로 |
|---|---|
| 단건 — JSON 본문 | 등록 `PUT` · 수정 `PATCH` (base 경로) |
| 단건 — **파일첨부(multipart)** | 등록 `POST .../insert` · 수정 `POST .../update` |
| **복수건 일괄**(추가+수정+삭제 동시) | `POST .../{상세리소스}` 또는 `.../save` + `{메뉴}Save*` Bean |
| 복수건 — 엑셀 등록 | `PUT .../excel` (검증은 `POST .../excel/valid`) |
| 단건/복수건 삭제 | `DELETE` (base 경로) |

> 일반 REST 관례와 다르게 **목록 조회=`POST`**(검색조건을 Body 로 전송), **단건 등록=`PUT` / 단건 수정=`PATCH`** 를 표준으로 한다. FE `zAxios` 규약과 일치 → [02-be-fe-contract.md](../../40-frontend/10-architecture/02-be-fe-contract.md).

### 2.2 인터페이스 ID · URL

| Interface ID | HTTP 메서드 | URL | 용도 |
|-------------|------------|-----|------|
| {메뉴코드}_POST_{리소스}S | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 목록 조회 (검색조건 Body) |
| {메뉴코드}_GET_{리소스} | GET | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s/{seq} | 단건 조회 (복합키는 `{리소스}Seq/{bizSeq}` 순) |
| {메뉴코드}_PUT_{리소스} | PUT | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 단건 등록 (JSON 단건 Body) |
| {메뉴코드}_PATCH_{리소스} | PATCH | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 단건 수정 (JSON 단건 Body) |
| {메뉴코드}_DELETE_{리소스}S | DELETE | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 삭제 (seq 목록/Body) |
| {메뉴코드}_POST_INSERT | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s/insert | 단건 등록 — **파일첨부(multipart)** 시 |
| {메뉴코드}_POST_UPDATE | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s/update | 단건 수정 — **파일첨부(multipart)** 시 |
| {메뉴코드}_POST_{상세}_SAVE | POST | /{bizSeq}/{메뉴코드_소문자}/{상세리소스} (또는 `.../save`) | 복수건 일괄 (헤더-상세/그리드) |
| {메뉴코드}_PUT_{리소스}_EXCEL | PUT | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s/excel | 엑셀 일괄 등록 (`List<Excel>` Body) |
| {메뉴코드}_POST_{리소스}_EXCEL_VALID | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s/excel/valid | 엑셀 업로드 유효성 검사 |

> ⚠️ 일부 레거시 메뉴(예: `MDCP01`)는 파일이 없는데도 `POST .../insert`·`/update` 를 쓴다(메서드명은 `put*`/`patch*`). 이는 과거 패턴이며, **신규 개발은 §2.1 분기 기준(단건 JSON = `PUT`/`PATCH`)을 따른다.**

### 2.3 복수건 일괄 저장 (Save) 규약

- 헤더-상세 구조의 상세 목록, 또는 그리드에서 행 단위 추가/수정/삭제가 **동시에** 발생하면 **`POST` 단일 요청**으로 일괄 처리한다.
- 본문은 **`{메뉴코드}Save{리소스}` Bean 하나**이며, 그 안에 변경 구분 List 3개를 담는다:
  - `insertList` (추가) · `updateList` (수정) · `deleteList` (삭제)
- 일괄 저장 리소스에는 **별도 DELETE API를 만들지 않는다** (삭제는 `deleteList` 로 처리).

> 실제 예: `IWRQ01SaveInwhProd`(입고 상세)·`SMCC01SaveCommH/D`(공통코드 헤더+상세)·`OBRQ01SaveOutbizProd`(출고)·`IVMV01SaveInvenMoveTran`(재고이동) 등. (구 `rowStatus` C/U/D 단일 목록 방식이 아니라 **3개 분리 List** 가 실제 규약이다.)

## 3. 업무절차

1. 개발해야 되는 API의 업무를 확인한다.
2. 업무의 명칭을 5자 이내로 정의한다.
3. 업무의 명칭을 메뉴명으로 사용한다.
4. 업무의 명칭을 영어단어로 인식할 수 있는 단어를 선정하여 리소스로 확정한다.
5. 메뉴명을 참고하여 메뉴코드를 생성하고 메뉴그룹을 확인한다.

중요 업무진행시 DB와의 일관성을 위해 Technical Leader와 협의한다.
