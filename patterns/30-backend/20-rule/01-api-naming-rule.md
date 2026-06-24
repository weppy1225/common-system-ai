---
title: API 네이밍 규칙
description: API URL 생성 규칙(HTTP 메서드·인터페이스 ID·URL 패턴)을 코드 작성 또는 API 설계 시 참조. 메뉴코드 체계는 02-menu-code-rule.md 참조.
status: active
version: 1.1.0
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

/{bizSeq}는 SaaS를 지원하기 위한 테넌트(Tenant)는 하나의 고객 조직을 의미합니다.
API생성시 {bizSeq}를 변경하지 말고 그대로 사용합니다.

| Interface ID | HTTP 메서드 | URL | 용도 |
|-------------|------------|-----|------|
| {메뉴코드}_POST_{리소스}S | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 목록 조회 (검색조건 Body) |
| {메뉴코드}_POST_INSERT | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/insert | 단건 등록 (등록정보 Body) |
| {메뉴코드}_GET_{리소스} | GET | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/{seq} | 단건 조회 |
| {메뉴코드}_POST_UPDATE | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/update | 단건 수정 (수정정보 Body) |
| {메뉴코드}_DELETE_{리소스}S | DELETE | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}s | 삭제 (삭제정보 Body, seq 목록) |
| {메뉴코드}_PUT_{리소스}_EXCEL | PUT | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/excel | 엑셀 일괄 등록 |
| {메뉴코드}_POST_{리소스}_EXCEL_VALID | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/excel/valid | 엑셀 업로드 유효성 검사 |
| {메뉴코드}_POST_{리소스}_SAVE | POST | /{bizSeq}/{메뉴코드_소문자}/{리소스_소문자}/save | 일괄 저장 (등록·수정·삭제 한 번에 처리, Body에 변경 목록 포함) |

### Save API 사용 시 주의사항

- **`/save` API를 사용하는 리소스에는 별도 DELETE API를 만들지 않는다.**
- `/save`는 등록(insert), 수정(update), 삭제(delete)를 단일 요청으로 처리하므로 독립적인 DELETE API가 불필요하다.
- 주로 헤더-디테일 구조의 디테일 목록, 또는 그리드에서 행 단위로 추가/수정/삭제가 발생하는 경우에 적용한다.
- Body에는 각 행의 변경 구분자(`rowStatus`: `C`=등록, `U`=수정, `D`=삭제)를 포함한다.

## 3. 업무절차

1. 개발해야 되는 API의 업무를 확인한다.
2. 업무의 명칭을 5자 이내로 정의한다.
3. 업무의 명칭을 메뉴명으로 사용한다.
4. 업무의 명칭을 영어단어로 인식할 수 있는 단어를 선정하여 리소스로 확정한다.
5. 메뉴명을 참고하여 메뉴코드를 생성하고 메뉴그룹을 확인한다.

중요 업무진행시 DB와의 일관성을 위해 Technical Leader와 협의한다.
