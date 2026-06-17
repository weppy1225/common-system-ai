---
title: 메뉴별 설계 문서 인덱스
description: spec/ 디렉토리 내 실제 존재하는 메뉴별 설계 문서 인덱스. 어떤 메뉴에 어떤 문서가 있는지 빠르게 파악할 때 사용. 검증용 wireframe은 prototype/ 참조.
status: active
version: 3.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
last_verified: 2026-06-17
tags:
  - index
  - spec
---

# 메뉴별 설계 문서 인덱스

`spec/{메뉴}/` 아래 실제 존재하는 설계 문서 목록이다. 검증용 화면(wireframe·mock)은 `prototype/{메뉴}/`에 있다.

## 문서 유형 범례 (spec/{메뉴}/)

| 파일 접미사 | 내용 | 생성 |
|---|---|---|
| `-00-domain.md` | 업무지식·노하우 (WHY) | **사람 전용 (스킬 금지)** |
| `-01-basic-design.md` | 기본설계 (업무정의·시나리오) | 수동 |
| `-02-ui.md` | 화면요건 (레이아웃·항목) | `/SD_310_UI` |
| `-03-data-model.md` | DB 설계 (테이블·관계) | `/SD-db` |
| `-04-be-mapper-sql.md` | 쿼리 명세 | `/PI-be-mapper` 참조 |
| `-05-api.md` | API 명세 ★허브 | `/SD-api` |
| `-06-be-flow.md` | BE 흐름 | 수동 |
| `-07-fe-flow.md` | FE 흐름 | 수동 |
| `-99-issues.md` | 설계 미결·하드코딩 등 | 수동 |

> 검증 화면(prototype/{메뉴}/): `{메뉴}-wireframe.html`(`/SD_311`) · `{메뉴}-mock-data.js`(`/SD_311`) · 모바일 `prototype/mobile/`(`/SD_312`)
> 정본: 메뉴별 DB·API 설계 정본은 `/SD-db`·`/SD-api`. `/SD_331`~`/SD_334`는 실DB 기준 별도 추출 산출물.

## 메뉴별 문서 현황

| 메뉴코드 | 메뉴명 | spec 문서 | prototype |
|---|---|---|---|
| `mdbz01` | (확인필요) | 9 (`spec/mdbz01/`) | - |
| `mdpr01` | 사은품관리 | 2 (`spec/mdpr01/`) | PC wireframe (`prototype/mdpr01/`) |

## 전체 문서 목록

### mdbz01 (`spec/mdbz01/`)
- `mdbz01-00-domain.md` — 업무지식 (사람 전용, 미작성)
- `mdbz01-01-basic-design.md` ~ `mdbz01-07-fe-flow.md` — 기본설계·UI·DB·SQL·API·BE흐름·FE흐름
- `mdbz01-99-issues.md` — 설계 미결사항

### mdpr01 (`spec/mdpr01/`)
- `mdpr01-00-domain.md` — 업무지식 (사람 전용, 미작성)
- `mdpr01-02-ui.md` — 화면요건
- (검증 화면: `prototype/mdpr01/mdpr01-wireframe.html` + `mdpr01-mock-data.js`)
