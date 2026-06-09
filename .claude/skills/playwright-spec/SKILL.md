---
name: playwright-spec
description: WMS FE Vue 메뉴의 Playwright E2E 테스트 스펙 파일을 생성한다. 성공(Happy Path)·엣지(Edge)·실패(Failure)·동시성(Concurrency) 4가지 케이스를 포함. dev-fe-menu 완료 후 자동 연계되거나, 사용자가 "테스트 코드 작성", "E2E 스펙 만들어줘", "playwright 케이스 추가"를 요청할 때 사용. 실행(playwright test 명령)은 포함하지 않는다 — 실행은 e2e-menu-test 스킬이 담당.
model: claude-sonnet-4-6
---

# Playwright 스펙 생성

입력: `$ARGUMENTS`  
형식: `<업무군> <메뉴코드>` — 예: `iv3000 stdc01`

> 이 스킬은 **파일 생성만** 담당한다. 실행은 `/e2e-menu-test` 가 맡는다.  
> 분석이 많으므로 `@playwright-spec-writer` 에이전트에 위임하여 메인 컨텍스트를 보호한다.

---

## 실행 절차

### Step 1 — 인자 검증

- 인자 2개 미만이면 재입력 요청.
- Vue 파일(`src/views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue`) 존재 확인. 없으면 중단.

### Step 2 — 에이전트 위임

```
@playwright-spec-writer {업무군} {메뉴코드} [{메뉴명}]
```

에이전트가 담당하는 작업:
- Vue + BE 산출물 분석
- 4가지 카테고리별 케이스 설계
- `e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js` 생성

### Step 3 — 결과 확인

`e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js` 가 생성됐는지 확인. 없으면 에이전트 에러를 보고.

### Step 4 — 보고

```
테스트 스펙 생성 완료
파일: e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js

케이스 구성:
  [H] 성공    — 화면 접근, 검색, 팝업 흐름
  [E] 엣지    — 0건 결과, 초기화, 경계값
  [F] 실패    — validation, swal 오류, 네트워크 차단
  [C] 동시성  — 연속 클릭, 더블클릭, 팝업 반복

실행:
  npx playwright test e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js --project=chromium
  또는 /e2e-menu-test {업무군} {메뉴코드}
```

---

## 4가지 케이스 설계 기준

### [H] 성공 케이스 — 정상 흐름

| 케이스 | 검증 포인트 |
|---|---|
| H1 화면 접근 | SearchSection 렌더링, 스크린샷 |
| H2 검색 실행 | 그리드 row > 0 또는 no-data 메시지 |
| H3 팝업 열기 | LayerPopup visible, 필드 렌더링 |
| H4 팝업 닫기 | LayerPopup hidden, 부모 재조회 |

### [E] 엣지 케이스 — 경계값·특수 상황

| 케이스 | 검증 포인트 |
|---|---|
| E1 0건 결과 | 존재하지 않는 검색어 → 빈 그리드 |
| E2 초기화 | 초기화 버튼 → 폼 리셋 확인 |
| E3 긴 텍스트 | 200자+ 입력 → maxlength 또는 절단 |
| E4 공백 입력 | 스페이스만 입력 → 빈 값으로 처리 |
| E5 비즈니스 규칙 | spec.md §6 기반 경계값 (재고 0, 날짜 역전 등) |

### [F] 실패 케이스 — 오류 처리

| 케이스 | 검증 포인트 |
|---|---|
| F1 미선택 수정 | noSelectSwal → `.swal2-popup` 노출 |
| F2 복수 선택 수정 | oneSelectSwal → `.swal2-popup` 노출 |
| F3 필수 누락 저장 | validation 오류 class 적용, 저장 안 됨 |
| F4 삭제 취소 | confirmSwal 취소 → 데이터 유지 |
| F5 네트워크 오류 | `page.route` abort → errorSwal 노출 |

### [C] 동시성 케이스 — 경쟁 조건

| 케이스 | 검증 포인트 |
|---|---|
| C1 검색 연속 클릭 | 3회 연속 → 그리드 정상 상태 유지 |
| C2 저장 버튼 확인 | 저장 버튼 렌더링 확인, 실제 클릭 금지 |
| C3 팝업 반복 | 열기/닫기 3회 → console 오류 없음 |
| C4 탭 전환 복귀 | `onActivated` bizSeq 갱신 확인 |

---

## 주의

- 쓰기 API(PUT/PATCH/DELETE) 는 자동 실행 안 함 — 실데이터 오염 방지.
- `page.route` 를 사용한 네트워크 차단은 `page.unrouteAll()` 로 반드시 해제.
- `.swal2-popup` 셀렉터는 SweetAlert2 기준. 버전이 다르면 DevTools 확인 필요.
- `e2e/.auth-state.json` 없으면 `node .claude/skills/e2e-menu-test/scripts/gen-auth-setup.js` 실행.
