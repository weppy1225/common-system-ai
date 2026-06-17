---
title: cloud-wms-ai 레포 전체 디렉토리 구조 및 영역 역할
description: 레포 최상위 디렉토리 구조, 각 영역의 역할, 메뉴별 산출 위치와 경계 규칙. 프롬프트 개정·문서 생성/재생성의 기준 문서. (2026-06 재설계 적용)
status: active
version: 2.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: common
applies_to:
  - "**"
last_verified: 2026-06-17
---

# cloud-wms-ai 레포 전체 디렉토리 구조

WMS AI 프레임워크 허브 레포. 화면설계·지식베이스·소스패턴·산출물·BE/FE 자동화 스킬의 단일 허브.

> 재설계 배경·결정 근거·이전 매핑: → `_archive/STRUCTURE-TARGET.md`(결정안), `_archive/MIGRATION-PLAN.md`(이전 기록).

---

## 최상위 구조

```
cloud-wms-ai\   (현 cloud-wms-doc)
├── .claude\
│   ├── skills\        # 슬래시 커맨드 (개발 자동화 + 산출물 자동화)
│   └── rules\         # 항상 적용되는 UI·문서·코딩 규칙
├── knowledgebase\    # 메뉴 횡단 공통 배경지식 (AI가 읽는 도서관)
├── spec\             # 메뉴별 설계 정본 (마크다운)
├── prototype\        # 검증용 화면 (공용 셸 + 메뉴별 wireframe)
├── patterns\         # 소스코드 패턴 (HOW)
└── deliverables\     # 고객 제출 산출물
```

| 폴더 | 역할 | 읽는 사람 | 매체 |
|---|---|---|---|
| `knowledgebase/` | 이 프로젝트가 어떻게 돌아가나 (공통 배경) | AI·개발자 | 마크다운 |
| `spec/` | 이 메뉴를 왜·무엇·어떻게 설계했나 | AI·개발자 | 마크다운 |
| `prototype/` | 화면이 이렇게 생겼다 (검증용) | PL·PM·고객 | 실행 HTML/JS |
| `patterns/` | 코드는 이 패턴으로 짜라 | AI·개발자 | 마크다운 |
| `deliverables/` | 고객 제출 문서 | 고객 | 문서·엑셀·PPT |

원칙: **최상위는 역할 이름(번호 없음)**. 번호는 순서가 있는 `knowledgebase/`·`spec/{메뉴}/` 안에서만 쓴다.

---

## knowledgebase/ (번호 = 읽는 순서)

```
knowledgebase/
├── 00-overview.md       개요
├── 10-domain/           메뉴 횡단 공통 업무규칙·용어·엔티티 관계 (WHY, 사람 작성)
├── 20-md-index.md       MD 문서 색인 (문서 위치)
├── 30-src-index/        소스코드 색인 (코드 위치 — 실제 코드는 BE/FE 레포)
├── 40-install-guide/    설치·셋업
├── 50-dev-workflow/     개발 워크플로우
└── menu-list.md         메뉴 레지스트리
```

---

## spec/{메뉴}/ (파일 순서 = 읽는 순서)

```
spec/{메뉴}/
├── {메뉴}-00-domain.md         업무지식 WHY — 사람 전용, 자동화 스킬 생성·수정 금지
├── {메뉴}-01-basic-design.md   기본설계
├── {메뉴}-02-ui.md             화면요건            〔/SD_310_UI〕
├── {메뉴}-03-data-model.md     DB 설계             〔/SD_db〕
├── {메뉴}-04-be-mapper-sql.md  쿼리 명세
├── {메뉴}-05-api.md            API 명세 ★허브      〔/SD_api〕
├── {메뉴}-06-be-flow.md        BE 흐름
├── {메뉴}-07-fe-flow.md        FE 흐름
└── {메뉴}-99-issues.md         설계 미결·하드코딩 등
```

---

## prototype/ (PC=`{메뉴}`, 모바일=`{메뉴}m`)

```
prototype/
├── _common/             PC 공용 셸 (index, 메뉴, 팝업, wms-ui.css, wms-common.js)
├── _common-m/           모바일 공용 셸 (menu·main·mobile.css·ui-standard·assets·common/_template)
├── {메뉴}/              PC 검증물 — {메뉴}-wireframe.html + {메뉴}-mock-data.js   〔/SD_311〕
└── {메뉴}m/             모바일 검증물 — {메뉴}m-wireframe.html + {메뉴}m-mock-data.js  〔/SD_312〕
```

---

## 경계 규칙 (BLOCKING)

1. 메뉴별 설계·업무지식·미결은 모두 `spec/{메뉴}/` (마크다운), 검증 화면은 `prototype/{메뉴}/` (실행 HTML).
2. `{메뉴}-00-domain.md`는 **사람 전용**. 자동화 스킬은 01~07만 생성/갱신한다.
3. AS-IS 정본은 **소스 코드**. 역공학 요약 문서를 저장하지 않는다(위치는 `30-src-index`). `KB_100`=레거시 소스를 `spec/` 초안(draft)으로 역공학(00-domain 제외), `KB_200`=`spec/`↔라이브 소스 드리프트 검증.
4. `knowledgebase/`는 메뉴 횡단 공통 지식만. 메뉴 고유 지식은 `spec/`.
