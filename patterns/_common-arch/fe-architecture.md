---
title: WMS FE 공통 아키텍처 (Vue 구조·함수 네이밍·공통 패턴)
description: 모든 메뉴에 공통으로 적용되는 FE Vue 파일 구조, 함수 네이밍 규칙, 공통 컴포넌트 패턴. 07-fe-flow 작성 시 참조.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: reference
domain: common
---

# WMS FE 공통 아키텍처

모든 메뉴에 동일하게 적용되는 F/W 기반 FE 패턴이다.
메뉴별 `07-fe-flow.md`에는 이 패턴을 반복하지 않고 API별 시퀀스와 메뉴 고유 구현 포인트만 기술한다.

## Vue 파일 구성 패턴

| 파일 유형 | 네이밍 패턴 | 역할 |
|---|---|---|
| 메인 화면 | `{MENU}.vue` | 검색 조건 + 결과 그리드 |
| 등록·수정 팝업 | `{MENU}Edt.vue` | 단건 등록·수정 폼 |
| 조회 팝업 | `{MENU}Sch.vue` | 검색·선택 전용 팝업 |

## 함수 네이밍 규칙

| 접두사 | 의미 | 예시 |
|---|---|---|
| `vfn_` | 외부 호출 가능 공개 함수 (부모·팝업에서 emit으로 호출) | `vfn_search`, `vfn_save` |
| `lfn_` | 파일 내부 전용 로컬 함수 | `lfn_gridCellClick`, `lfn_initForm` |
| `onMounted` | Vue 라이프사이클 초기화 | 초기 조회·그리드 설정 |

## 공통 컴포넌트

| 컴포넌트 | UI 기능 |
|---|---|
| `ZAuiGrid` | 데이터 그리드 |
| `ZSelect` | 드롭다운 선택 |
| `ZCodeMulti` | 다중 선택 |
| `ZText` | 텍스트 입력 |
| `ZRadio` | 라디오 버튼 |
| `LayerPopup` | 팝업 래퍼 |
| `zAxios` | API 호출 인터셉터 (prefix 자동 처리) |

## 공통 흐름 패턴

### 조회
```
onMounted / 조회 버튼 클릭
  → lfn_validate (조건 검증)
  → zAxios GET
  → 그리드 데이터 바인딩
```

### 저장 (등록·수정 팝업)
```
저장 버튼 클릭
  → lfn_validate (필수값 검증)
  → zAxios POST / PUT
  → 팝업 닫기 + emit('vfn_search') → 부모 그리드 갱신
```

### 팝업 연동
```
부모 화면: LayerPopup ref → open()
팝업 화면: 선택 완료 → emit('callback', data)
부모 화면: callback 수신 → 필드 값 세팅
```
