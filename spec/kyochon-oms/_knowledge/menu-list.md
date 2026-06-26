---
title: kyochon-oms 메뉴코드 목록
description: kyochon-oms 전체 메뉴코드·메뉴명·상위그룹 레지스트리. 메뉴 단위 스킬(KB_100/KB_200 등)이 메뉴 정보를 조회할 때 사용.
status: draft
version: 0.1.0
repo_role: ai-hub
agent_usage: reference
project: kyochon-oms
domain: common
tags:
  - menu-list
  - oms
---

# kyochon-oms 메뉴코드 목록

> 상태: **스캐폴드(미작성)**. 실 메뉴는 추정하지 않는다.
> 채우는 방법: `kyochon-oms-be` 컨트롤러(`src/main/java`)와 `kyochon-oms-fe` 라우터를 스캔해 실제 메뉴코드를 확정한 뒤 아래 표를 채운다.
> 정렬·기준은 `spec/common-system/_knowledge/menu-list.md` 를 참고한다.

| No | 구분 | 상위코드 | 상위메뉴 | 메뉴코드 | 메뉴명 | 설계 | 프로토 |
|---|---|---|---|---|---|---|---|
| | | | | | | − | − |

## 컬럼 기준

**설계** — `spec/kyochon-oms/{메뉴코드}/` 설계 문서

| 값 | 의미 |
|---|---|
| ✓ | 01~07 설계 문서 완비 |
| △ | 일부만 작성 (00-domain·02-ui 등) |
| − | 없음 |

**프로토** — `prototype/kyochon-oms/{메뉴코드}/` 검증 화면 (모바일은 `{메뉴코드}m`)

| 값 | 의미 |
|---|---|
| ✓ | wireframe 존재 |
| − | 없음 |

> 두 컬럼은 실제 폴더 존재 기준이며, 산출물 추가 시 갱신한다.
