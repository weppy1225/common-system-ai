---
title: BE 레이어 공통 패턴
description: BE 전 메뉴에 공통 적용되는 Controller-Comp-TxComp-Dao 레이어 구조와 역할. 메뉴별 06-be-flow.md에서 참조.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: reference
domain: common
last_verified: "2026-06-09"
tags:
  - backend
  - pattern
  - common
  - architecture
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

- Controller → Comp → (TxComp) → Dao 방향으로만 호출한다. 요청/응답 변환과 비즈니스 규칙의 책임이 섞이지 않도록 분리한다.
- Comp는 조회성 Dao를 직접 호출할 수 있으나, 쓰기 트랜잭션은 반드시 TxComp를 경유한다. 기존 코드에 Comp 직접 `@Transactional` 선언이 남아 있더라도 미준수 레거시로 보고, 신규/수정 코드에서는 TxComp로 이동한다.
- TxComp는 Dao를 직접 주입받아 사용한다. (Spring DI 기준) 트랜잭션 경계 안에서 DB 변경을 한곳에 모으기 위함이다.

## 3. 공통 예외 클래스

| 예외 | 의미 |
|---|---|
| `ZinBadRequestException` | 잘못된 요청 데이터 |
| `ZinRequestParamValidException` | 요청 파라미터 검증 실패 |
| `ZinExistDataException` | 중복 데이터 존재 |
| `ZinNotFoundException` | 조회 결과 없음 / 처리 대상 없음 |
| `AlreadyProcessException` | 상태 불일치, 이미 처리됨 |
| `NotMeetConditionsException` | 업무 조건 미충족 |
| `ResponseErrorException` | 시스템 오류 |

> 출처: `$BE_DIR/src/main/java/fw/exception/warn/*.java`, `$BE_DIR/src/main/java/fw/exception/ResponseErrorException.java`

## 4. 공통 응답 패턴

| 응답 필드 | 사용 시점 |
|---|---|
| `procCnt` | 저장·수정·삭제 처리 건수 |
| `succeed` | 성공/실패 여부 |
| `swalTitle`, `swalText`, `swalType` | 화면 메시지 표시용 공통 필드 |
| 데이터 키 (예: `biz`, `bizCenter`, `bizList`) | 조회 응답 |

> 출처: `$BE_DIR/src/main/java/fw/bean/ResponseData.java`
