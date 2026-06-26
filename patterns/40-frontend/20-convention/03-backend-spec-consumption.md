---
title: BE 스펙 소비(Consume) 컨벤션
description: FE AI가 BE spec 산출물을 직접 읽고 코드와 메뉴 문서에 반영할 때 따르는 단일 소스. BE 스펙 원천 경로, 우선순위, 직접 소비 정책, 메뉴 작업 확인 순서를 정의한다.
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: frontend
tags:
  - backend-spec
  - api-consumption
  - workflow
  - source-of-truth
source_of_truth: true
related:
  - patterns/40-frontend/10-architecture/02-be-fe-contract.md
  - spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md
---

# BE 스펙 소비(Consume) 컨벤션

FE AI 가 BE 레포 spec 산출물을 직접 읽고, 코드와 메뉴 문서에 반영할 때 따르는 **단일 소스**.
BE-FE 런타임 계약(HTTP 메서드·응답 네이밍·복합키 등)은 `patterns/40-frontend/10-architecture/02-be-fe-contract.md` 에 있고, 이 문서는 그 계약을 **어떤 문서에서 어떻게 끌어오는가** 를 정의한다.

## 1. BE 스펙 원천(source of truth)

원천: AI 허브 `spec/{프로젝트}/{메뉴코드}/` 의 메뉴별 설계 정본.

| 내용 | 경로 |
| --- | --- |
| API 명세 (메서드·URL·Request/Response·복합키) | `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md` |
| BE 처리 흐름 | `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-06-be-flow.md` |
| DB 설계 (테이블·컬럼) | `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-03-data-model.md` |
| 프로젝트 DB 스키마 (실 테이블) | `spec/{프로젝트}/_knowledge/db-schema/` |

우선순위 (같은 메뉴에서 여러 문서가 있을 때):
1. `{메뉴코드}-05-api.md` — API 명세 정본. **가장 정확** (`/SD_api` 산출물).
2. `{메뉴코드}-06-be-flow.md` — API 명세가 없거나 부족할 때 BE 흐름에서 보강.
3. `{메뉴코드}-03-data-model.md` · `_knowledge/db-schema/` — 필드·타입·복합키 확인.

## 2. 네이밍 규칙

- **폴더명**: 소문자 (`stdc01`, `mdct01`). BE 와 FE 양쪽 동일.
- **문서 내 메뉴코드**: 대문자 (`STDC01`).
- **Interface ID**: `{MENU}_{METHOD}_{RES}` (예: `STDC01_POST_STSETS`, `MDCT01_PUT_CONTS`).
- **FE URL**: `regBizSeq` 는 `zAxios` 인터셉터가 자동 prepend. FE 코드/문서에 **직접 포함 금지** (`02-be-fe-contract.md` §1 참조).
  - BE 문서: `POST /{bizSeq}/stdc01/stsets`
  - FE 문서/코드: `POST /stdc01/stsets`

## 3. 직접 소비 정책

FE 코드에 API 스펙을 임의 복제·캐시하지 않는다.

- API 목록, Request/Response, 복합키, 공통코드는 매번 `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md` 에서 직접 확인한다.
- FE 흐름 문서(`spec/{프로젝트}/{메뉴코드}/{메뉴코드}-07-fe-flow.md`)에는 FE 소비에 필요한 매핑과 최근 동기화 날짜만 기록한다.
- FE 코드와 `-05-api.md` 가 충돌하면 **`-05-api.md` 우선**.
- API 명세 자체가 틀린 경우 FE 에서 추측 보정하지 말고 `/SD_api` 로 `-05-api.md` 를 재생성한다.

## 4. 응답 네이밍

응답 필드 네이밍(`res.data.post{Resource}s`·`res.data.{resource}`·성공 메시지)은 → [`02-be-fe-contract.md §3`](../10-architecture/02-be-fe-contract.md), 에러 처리(`error.response.data.message`·`errorSwal`)는 같은 문서 `§5`. 여기엔 중복 기재하지 않는다.

## 5. 메뉴 작업 시 확인 순서

FE 에서 메뉴를 건드릴 때:

1. `spec/{프로젝트}/{메뉴코드}/{메뉴코드}-05-api.md` 존재 여부 확인.
2. 있으면 그 파일로 API 목록·Request·Response·복합키를 확인한다.
3. 없거나 부족하면 `{메뉴코드}-06-be-flow.md`·`{메뉴코드}-03-data-model.md` 를 보조 참고한다.
4. 작업 완료 후 `{메뉴코드}-07-fe-flow.md` 의 FE 매핑·동기화 날짜를 `-05-api.md` 기준으로 갱신한다.

## 6. 안 하는 것

- FE 작업 중 `-05-api.md` 임의 편집. 명세 수정은 `/SD_api` 로 재생성한다.
- FE 코드에 API 스펙 캐시 산출물 생성.
- `regBizSeq` 를 URL 하드코딩 (zAxios 가 붙임).
