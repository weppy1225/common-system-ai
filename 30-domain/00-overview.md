---
title: 30-domain 지식베이스 인덱스
description: 메뉴별 지식베이스(기본설계·데이터모델·SQL·API·구현흐름)와 프로토타입 파일을 단일 보관
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
---

# 30-domain

메뉴 단위로 지식베이스 파일 세트와 프로토타입 산출물(wireframe, mock-data)을 함께 관리한다.

## 디렉토리 구조

```
30-domain/
├── 00-overview.md               # 이 파일 — 30-domain 전체 구조 설명
├── 10-md-index.md               # 실제 존재하는 메뉴 도메인 문서 인덱스 (현황 추적)
│
├── 20-src-index/                # 기존 프로젝트 소스코드 인덱스
├── 30-wms-business/             # WMS 업무 메뉴 지식베이스 (메인)
│   └── {메뉴코드}/              # 예: mdbz01, mdpr01
│       ├── {메뉴코드}-01-basic-design.md
│       ├── {메뉴코드}-02-ui.md
│       ├── {메뉴코드}-02-wireframe.html
│       ├── {메뉴코드}-02-mock-data.js
│       ├── {메뉴코드}-03-data-model.md
│       ├── {메뉴코드}-04-be-mapper-sql.md
│       ├── {메뉴코드}-05-api.md
│       ├── {메뉴코드}-06-be-flow.md
│       ├── {메뉴코드}-07-fe-flow.md
│       └── {메뉴코드}-99-issues.md
├── 40-issue/                    # 이슈 모음
├── 50-install-guide/            # 설치 가이드
└── 60-development-workflow/     # 개발 워크플로
```

> 실제 존재하는 메뉴 및 문서 현황: → `10-md-index.md`

## 파일 세트 구조 (메뉴별)

| 파일 | 내용 |
|---|---|
| `{코드}-01-basic-design.md` | 업무 정의·관리번호·흐름/요약 |
| `{코드}-02-ui.md` | 화면요건 (SD_310_UI 생성) |
| `{코드}-02-wireframe.html` | 프로토타입 HTML (SD_311 생성) |
| `{코드}-02-mock-data.js` | 테스트 데이터 JS (SD_311 생성) |
| `{코드}-03-data-model.md` | 테이블/컬럼/코드 규칙 |
| `{코드}-04-be-mapper-sql.md` | SQL 명세 |
| `{코드}-05-api.md` | API 명세 (FE/BE 공용 계약) |
| `{코드}-06-be-flow.md` | BE 구현 흐름 |
| `{코드}-07-fe-flow.md` | FE 구현 흐름 |
| `{코드}-99-issues.md` | 확인 필요 사항·불일치/결정 후보 |
