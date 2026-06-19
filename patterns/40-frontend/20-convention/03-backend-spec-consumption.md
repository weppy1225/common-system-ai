---
title: BE 스펙 소비(Consume) 컨벤션
description: FE AI가 BE spec 산출물을 직접 읽고 코드와 메뉴 문서에 반영할 때 따르는 단일 소스. BE 스펙 원천 경로, 우선순위, 직접 소비 정책, 메뉴 작업 확인 순서를 정의한다.
status: active
version: 1.0.0
wms_meta: true
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
  - patterns/30-backend/90-api/
---

# BE 스펙 소비(Consume) 컨벤션

FE AI 가 BE 레포 spec 산출물을 직접 읽고, 코드와 메뉴 문서에 반영할 때 따르는 **단일 소스**.
BE-FE 런타임 계약(HTTP 메서드·응답 네이밍·복합키 등)은 `patterns/40-frontend/10-architecture/02-be-fe-contract.md` 에 있고, 이 문서는 그 계약을 **어떤 문서에서 어떻게 끌어오는가** 를 정의한다.

## 1. BE 스펙 원천(source of truth)

BE 저장소: `$BE_DIR/DEV_DOC/ai-docs/`

| 내용 | 경로 |
| --- | --- |
| 메뉴 스펙 (초안/설계) | `20-backend/80-spec/{menu-lower}/spec.md` |
| 메뉴 개발 산출물 (최종) | `20-backend/80-spec/{menu-lower}/{YYYYMMDD}_output.md` |
| 날짜 없는 개발 산출물 | `20-backend/80-spec/{menu-lower}/output.md` |
| FE 소비용 API 상세 | `patterns/30-backend/90-api/20-detail/{menu-lower}-{method}-{res}.md` |
| 도메인별 API 요약 | `patterns/30-backend/90-api/10-domain/{domain}-api.md` |
| 전체 API 목록 | `patterns/30-backend/90-api/00-backend-api-overview.md` |
| 테이블 명세 | `patterns/30-backend/` (DB 스키마) |

우선순위 (같은 메뉴에서 여러 문서가 있을 때):
1. `{YYYYMMDD}_output.md` — 개발 완료 산출물. **가장 최신/정확**.
2. `output.md` — 날짜형 output 이 없을 때 사용.
3. `spec.md` — 초안. output 이 없으면 사용.
4. `patterns/30-backend/90-api/20-detail/*.md` — API 단위 상세. 80-spec 만으로 부족할 때 보조 참고.

## 2. 네이밍 규칙

- **폴더명**: 소문자 (`stdc01`, `mdct01`). BE 와 FE 양쪽 동일.
- **문서 내 메뉴코드**: 대문자 (`STDC01`).
- **Interface ID**: `{MENU}_{METHOD}_{RES}` (예: `STDC01_POST_STSETS`, `MDCT01_PUT_CONTS`).
- **FE URL**: `regBizSeq` 는 `zAxios` 인터셉터가 자동 prepend. FE 코드/문서에 **직접 포함 금지** (`02-be-fe-contract.md` §1 참조).
  - BE 문서: `POST /{bizSeq}/stdc01/stsets`
  - FE 문서/코드: `POST /stdc01/stsets`

## 3. 직접 소비 정책

FE 저장소에 BE 스펙 캐시 산출물을 만들지 않는다.

- API 목록, Request/Response, 복합키, 공통코드는 매번 `$BE_DIR/.../80-spec/{menu}/` 에서 직접 확인한다.
- FE 메뉴 문서(`spec/{메뉴코드}/`)에는 FE 소비에 필요한 매핑과 최근 동기화 날짜만 기록한다.
- FE 문서와 BE 80-spec 이 충돌하면 **BE 80-spec 우선**.
- BE 원본 문서 자체가 틀린 경우 FE 에서 추측 보정하지 말고 BE 저장소에서 산출물을 재생성한다.

## 4. 응답 네이밍 (요약)

`02-be-fe-contract.md` §3 과 동일. 중복 서술 금지, 여기서는 체크리스트만:

- 리스트 조회 응답: `res.data.post{Resource}s` (예: `res.data.postConts`, `res.data.postStsets`).
- 단건 조회 응답: `res.data.{resource}` — 소문자 리소스 키 (`res.data.cont`, `res.data.wh`).
- 에러: `error.response.data.message` — `errorSwal(error)` 가 처리.
- 성공 메시지: `res.data` (string) — `successSwal(res.data)`.

## 5. 메뉴 작업 시 확인 순서

FE 에서 메뉴를 건드릴 때:

1. `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{menu-lower}/` 존재 여부 확인.
2. 최신 `{YYYYMMDD}_output.md`, 없으면 `output.md`, 없으면 `spec.md` 를 읽는다.
3. 필요하면 `patterns/30-backend/90-api/20-detail/{menu-lower}-*.md` 를 보조 참고한다.
4. 작업 완료 후 `spec/{메뉴코드}/` 의 API 매핑표를 80-spec 기준으로 갱신한다.

## 6. 안 하는 것

- BE 원본 문서 편집. BE 포맷을 고치고 싶으면 BE 저장소에서 해결.
- BE 스펙 캐시 산출물 생성.
- `regBizSeq` 를 URL 하드코딩 (zAxios 가 붙임).
