---
title: spec 문서 구성 규약 (메뉴별 설계 문서)
description: spec/{프로젝트}/{메뉴}/ 설계 문서의 접미사별 의미·생성 스킬 규약. 실제 전체 파일 인벤토리는 20-md-index.html(파일 지도) 참조.
status: active
version: 4.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: common
last_verified: 2026-06-18
tags:
  - index
  - spec
---

# spec 문서 구성 규약

`spec/{프로젝트}/{메뉴}/` 한 메뉴의 설계 문서는 아래 접미사 체계를 따른다. **번호 순서 = 읽는 순서**(왜→무엇→설계→흐름→미결).

## 문서 유형 (접미사 → 역할 → 생성)

| 접미사 | 내용 | 생성 |
|---|---|---|
| `-00-domain.md` | 업무지식·노하우 (WHY) | **사람 전용 (스킬 금지)** |
| `-01-basic-design.md` | 기본설계 (업무정의·시나리오) | 수동 |
| `-02-ui.md` | 화면요건 (레이아웃·항목) | `/SD_310_UI` |
| `-03-data-model.md` | DB 설계 (테이블·관계) | `/SD_db` |
| `-04-be-mapper-sql.md` | 쿼리 명세 | `/PI_be_mapper` 참조 |
| `-05-api.md` | API 명세 ★허브 | `/SD_api` |
| `-06-be-flow.md` | BE 흐름 | 수동 |
| `-07-fe-flow.md` | FE 흐름 | 수동 |
| `-99-issues.md` | 설계 미결·하드코딩 등 | 수동 |

> 검증 화면(`prototype/{메뉴}/`): `{메뉴}-wireframe.html`(`/SD_311`) · `{메뉴}-mock-data.js`(`/SD_311`) · 모바일 `prototype/{메뉴}m/`(`/SD_312`)
> 정본: 메뉴별 DB·API 설계 정본은 `/SD_db`·`/SD_api`. `/SD_331`~`/SD_334`는 실DB 기준 별도 추출 산출물.

## 실제 파일 인벤토리

전체 메뉴·파일 목록(전 영역 트리·역할·검색)은 → **`20-md-index.html`** (파일 지도).
재생성: `python scripts/gen-md-map.py`. 특정 메뉴 파일은 `spec/{프로젝트}/{메뉴}/` 직접 확인.
