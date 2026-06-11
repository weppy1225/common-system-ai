---
title: 도메인 지식베이스 문서 인덱스
description: 30-domain/ 디렉토리 내 실제 존재하는 메뉴별 지식베이스 문서 인덱스. 어떤 메뉴에 어떤 설계 문서가 있는지 빠르게 파악할 때 사용.
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
last_verified: 2026-06-11
tags:
  - index
  - domain
  - knowledge-base
---

# 도메인 지식베이스 문서 인덱스

`30-domain/30-wms-business/` 아래 실제 존재하는 메뉴별 지식베이스 문서 목록이다.

## 문서 유형 범례

| 파일 접미사 | 내용 | 생성 스킬 |
|---|---|---|
| `-01-basic-design.md` | 기본설계 (업무정의·시나리오·업무규칙) | 수동 작성 |
| `-02-ui.md` | 화면요건 (레이아웃·항목·업무규칙) | `/SD_310_UI` |
| `-02-wireframe.html` | 프로토타입 HTML | `/SD_311` |
| `-02-mock-data.js` | 프로토타입 테스트 데이터 | `/SD_311` |
| `-03-data-model.md` | DB 설계 (테이블·관계) | `/SD-db` |
| `-04-be-mapper-sql.md` | 쿼리 명세 (복잡 SQL) | `/PI-be-mapper` 참조 |
| `-05-api.md` | API 명세 (엔드포인트·DTO) ★허브 | `/SD-api` |
| `-06-be-flow.md` | BE 흐름 (시퀀스·예외) | 수동 작성 |
| `-07-fe-flow.md` | FE 흐름 (함수 시퀀스) | 수동 작성 |
| `-99-issues.md` | 이슈 레지스터 | 수동 작성 |

## 메뉴별 문서 현황

| 메뉴코드 | 메뉴명 | 보유 문서 수 | 경로 |
|---|---|---|---|
| `mdbz01` | 사업장 | 8 | `30-domain/30-wms-business/mdbz01/` |
| `mdpr01` | 사은품관리 | 3 | `30-domain/30-wms-business/mdpr01/` |

## 전체 문서 목록

### mdbz01

- `mdbz01-01-basic-design.md` — 기본설계 (업무정의·시나리오·업무규칙)
- `mdbz01-02-ui.md` — 화면요건 (레이아웃·항목·업무규칙)
- `mdbz01-03-data-model.md` — DB 설계 (테이블·관계)
- `mdbz01-04-be-mapper-sql.md` — 쿼리 명세 (복잡 SQL)
- `mdbz01-05-api.md` — API 명세 (엔드포인트·DTO) ★허브
- `mdbz01-06-be-flow.md` — BE 흐름 (시퀀스·예외)
- `mdbz01-07-fe-flow.md` — FE 흐름 (함수 시퀀스)
- `mdbz01-99-issues.md` — 이슈 레지스터

### mdpr01

- `mdpr01-02-mock-data.js` — 프로토타입 테스트 데이터
- `mdpr01-02-ui.md` — 화면요건 (레이아웃·항목·업무규칙)
- `mdpr01-02-wireframe.html` — 프로토타입 HTML

## 공통 문서

메뉴 폴더 밖에서 실제 확인된 공통 문서는 아래 2건이다.

- `30-domain/00-overview.md`
- `30-domain/10-md-index.md`
