---
title: WMS BE 공통 아키텍처 (레이어 구조)
description: 모든 메뉴에 공통으로 적용되는 BE 레이어 구조 및 클래스 역할. 06-be-flow 작성 시 참조.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: common
---

# WMS BE 공통 아키텍처

모든 메뉴에 동일하게 적용되는 F/W 기반 레이어 구조다.
메뉴별 `06-be-flow.md`에는 이 구조를 반복하지 않고 업무별 시퀀스만 기술한다.

## 레이어 구조

```
HTTP Request
    │
    ▼
Controller        — 요청 수신·응답 반환. 업무 로직 없음.
    │
    ▼
Comp              — 업무 로직 중심. 조회·검증·분기 처리.
    │
    ▼
TxComp            — 트랜잭션 경계. @Transactional 선언.
    │                INSERT / UPDATE / DELETE 는 여기서만 실행.
    ▼
Dao               — DB 접근. Mapper 인터페이스 호출.
    │
    ▼
Mapper.xml        — SQL 정의 (MyBatis)
```

## 클래스별 역할

| 클래스 | 역할 |
|---|---|
| `{MENU}Controller` | REST 엔드포인트 선언. `@RequestMapping` 기준 라우팅. 인증·권한 체크는 F/W 인터셉터가 처리. |
| `{MENU}Comp` | 핵심 업무 로직. 입력 검증, 조건 분기, 다른 Comp 조합 호출. `@Transactional` 없음. |
| `{MENU}TxComp` | DML 전용. 메서드명 접미사 `TX`는 `@Transactional` 선언을 의미. |
| `{MENU}Dao` | Mapper 인터페이스 구현체. SQL 호출만 담당. |
| `{MENU}CompUtil` | Comp 공통 유틸. 있는 메뉴만 존재. |
| `bean/*.java` | 요청·응답·내부 전달 VO. |

## 공통 규칙

- Comp에서 직접 DML 금지 — 반드시 TxComp 경유
- Controller에서 업무 로직 금지 — Comp 위임
- 트랜잭션은 TxComp 메서드 단위로 관리
- 예외는 F/W 공통 예외 클래스로 throw → Controller가 에러 응답으로 변환
