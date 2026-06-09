---
title: BE 레이어 공통 패턴
description: WMS BE 전 메뉴에 공통 적용되는 Controller-Comp-TxComp-Dao 레이어 구조와 역할. 메뉴별 06-be-flow.md에서 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
last_updated: "2026-06-09"
tags: [backend, pattern, common, architecture]
---

# BE 레이어 공통 패턴

## 1. 레이어 구성

| 레이어 | 명명 규칙 | 역할 |
|---|---|---|
| Controller | `{메뉴코드}Controller` | HTTP 요청 수신·경로 매핑, 토큰에서 로그인 사용자 정보 추출 후 Comp에 위임 |
| Comp | `{메뉴코드}Comp` | 비즈니스 규칙 검증(필수값·존재 여부), 예외 변환, TxComp 또는 Dao 호출 조합 |
| TxComp | `{메뉴코드}TxComp` | `@Transactional` 경계 관리. 파일 업로드·다건 Insert/Update/Delete를 단일 트랜잭션으로 처리 |
| Dao | `{메뉴코드}Dao` | MyBatis Mapper 호출 래퍼. 단일 SQL 실행 또는 복합 SQL 묶음 실행 |

> 메서드명 접미사 `TX`는 해당 메서드에 `@Transactional`이 선언됨을 의미한다.

## 2. 호출 원칙

- Controller → Comp → (TxComp) → Dao 방향으로만 호출한다.
- Comp는 조회성 Dao를 직접 호출할 수 있으나, 쓰기 트랜잭션은 반드시 TxComp를 경유한다.
- TxComp는 Dao를 직접 주입받아 사용한다. (Spring DI 기준)

## 3. 공통 예외 클래스

| 예외 | 의미 |
|---|---|
| `ZinBadRequestException` | 요청 파라미터 오류 (필수값 누락, 형식 오류) |
| `ZinExistDataException` | 중복 데이터 존재 |
| `AlreadyProcessException` | 이미 처리된 건 / 대상 없음 |
| `NotMeetConditionsException` | 업무 조건 미충족 (예: 사용 센터 0개) |
| `ResponseErrorException` | 시스템 오류 |

## 4. 공통 응답 패턴

| 응답 필드 | 사용 시점 |
|---|---|
| `procCnt` | 단건 저장·수정·삭제 응답 |
| `succeed` | 복수 건 일괄 저장 응답 |
| 데이터 키 (예: `biz`, `bizCenter`, `bizList`) | 조회 응답 |
