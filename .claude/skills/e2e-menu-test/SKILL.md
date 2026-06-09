---
name: e2e-menu-test
description: WMS FE Vue 메뉴의 Playwright E2E 테스트를 실행한다. 스펙 파일이 없으면 playwright-spec 스킬로 먼저 생성한 뒤 실행. dev-fe-menu 로 메뉴 구현 완료 후 자동 연계되거나, 사용자가 "E2E 실행", "playwright 돌려줘", "테스트 실행", "스크린샷 찍어줘"를 요청할 때 사용. 입력: <업무군> <메뉴코드> (예: iv3000 stdc01).
model: claude-sonnet-4-6
---

# E2E 메뉴 테스트 실행

입력: `$ARGUMENTS`  
형식: `<업무군> <메뉴코드>` — 예: `iv3000 stdc01`

> **역할 분리**  
> - 스펙 파일 **생성**: `/playwright-spec` 스킬 (또는 `@playwright-spec-writer` 에이전트)  
> - 스펙 파일 **실행**: 이 스킬 (`/e2e-menu-test`)

---

## Phase 0 — 전제 조건 확인 (BLOCKING)

### 0-1. 인자 검증

인자 2개(업무군·메뉴코드) 미만이면 중단하고 재입력 요청.

### 0-2. 스펙 파일 확인 — 없으면 자동 생성

`e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js` 가 없으면 먼저 `/playwright-spec {업무군} {메뉴코드}` 로 생성한다.  
Vue 파일 자체가 없으면 중단 → "먼저 `/dev-fe-menu {업무군} {메뉴코드} {메뉴명}` 으로 화면을 구현해 주세요."

### 0-3. dev 서버 확인 (BLOCKING)

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173
```

- 200 → 정상. 계속 진행.
- 그 외 → **중단**. 사용자에게 다음 안내 후 대기:

```
dev 서버가 실행되지 않습니다.
터미널에서 먼저 실행해 주세요: npm run dev:dev
준비되면 다시 명령을 실행해 주세요.
```

**AI 가 npm run dev:dev 를 직접 실행하지 않는다.**

---

## Phase 1 — 메뉴 정보 수집

### 1-1. BE 산출물 읽기 (있으면)

다음 순서로 존재하는 파일만 읽는다:

1. `cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/output.md`
2. `cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/spec.md`

수집 대상:
- 메뉴명(한글)
- 리스트 조회 API URL (`POST /{메뉴코드}/{res}s`)
- 응답 루트 키 (`post{Resource}s`)
- 복합키 구성 (`{resourceSeq}`, `bizSeq`)

없으면 Vue 파일에서 axios 호출 패턴을 Grep으로 직접 파악한다:

```
Grep: axios.post\|axios.get — {메뉴코드}.vue
```

### 1-2. Vue 파일 분석

```
Grep: openPopup|editPopup — {메뉴코드}.vue
Grep: ZAuiGrid|ref.*Grid  — {메뉴코드}.vue
```

다음을 확정:
- 검색 버튼 텍스트 (보통 `'검색'`)
- 수정/조회 버튼 유무
- 팝업 컴포넌트명 (`{메뉴코드}Edt`)

---

## Phase 2 — Playwright 스펙 파일 생성

스펙 파일 생성은 `/playwright-spec` 스킬에 위임한다 — 이 스킬에서 중복 관리하지 않는다.

`e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js` 가 없을 경우 `/playwright-spec {업무군} {메뉴코드}` 를 호출해 생성한 뒤 Phase 3 으로 진행한다.

---

## 참고 패턴 — 팝업 열기/닫기

수정 팝업 테스트에서 수정 버튼을 찾는 패턴 (동작하지 않는 `??` fallback 대신):

```js
    test('[T3] 수정 팝업 열기 → 닫기', async ({ page }) => {
        await page.goto(MENU_URL);
        await page.waitForLoadState('networkidle');

        const searchBtn = page.getByRole('button', { name: '검색' });
        await searchBtn.click();
        await page.waitForTimeout(2_000);

        const firstCheck = page.locator(
            '.aui-grid-row input[type="checkbox"], [class*="check-column"] input'
        ).first();
        if (await firstCheck.isVisible()) {
            await firstCheck.check();
        }

        // Locator 는 항상 객체를 반환하므로 ?? 로 fallback 불가 — isVisible() 로 분기
        let editBtn = page.locator('.btn-mod, [class*="btn-mod"]').first();
        if (!await editBtn.isVisible()) {
            editBtn = page.getByRole('button', { name: /수정|조회/ }).first();
        }

        if (!await editBtn.isVisible()) {
            test.skip(true, '수정 버튼 없음 — 팝업 없는 메뉴');
            return;
        }
        await editBtn.click();

        // LayerPopup 열림 확인
        await expect(
            page.locator('.layer-popup, [class*="layer-popup"], .modal')
        ).toBeVisible({ timeout: 8_000 });

        await page.screenshot({ path: `e2e/{업무군}/{메뉴코드}/{메뉴코드}-popup.png`, fullPage: true });

        // 닫기 버튼 클릭
        await page.getByRole('button', { name: /닫기|취소|×|✕/ }).last().click();

        await expect(
            page.locator('.layer-popup, [class*="layer-popup"], .modal')
        ).not.toBeVisible({ timeout: 5_000 });
    });

});
```

---

## Phase 3 — Playwright 테스트 실행

```bash
cd /mnt/c/zinide/workspace/cloud-wms-fe
npx playwright test e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js --project=chromium --reporter=list
```

- timeout 기본값(`playwright.config.js`): 30초
- 실패 시 에러 로그와 스크린샷 경로를 캡처해 Phase 4 보고에 포함

### 실패 분류

| 유형 | 원인 | 처리 |
|---|---|---|
| `net::ERR_CONNECTION_REFUSED` | dev 서버 미실행 | Phase 0 에서 차단됐어야 함. 재확인 요청. |
| `locator...not visible` | DOM selector 불일치 | `.aui-grid-row` 셀렉터를 Vue 실제 DOM 에 맞게 조정 후 재실행. |
| `Test timeout` | 응답 느림 | `waitForTimeout` 값 1.5배 늘린 후 1회 재시도. |
| 로그인 실패 | 계정 오류 | `.auth-state.json` 삭제 후 재실행. |

재실행 최대 1회. 동일 오류 반복 시 자동 수정 중단 → 사용자 보고.

---

## Phase 4 — 결과 보고

```
## {메뉴코드_대문자} E2E 테스트 결과

dev 서버: http://localhost:5173 ✅
테스트 파일: e2e/{업무군}/{메뉴코드}/{메뉴코드}.spec.js

| 테스트 | 결과 | 비고 |
|---|---|---|
| [T1] 화면 접근 및 초기 렌더링 | ✅ PASS / ❌ FAIL | |
| [T2] 검색 → 그리드 로딩 | ✅ PASS / ❌ FAIL | row N건 |
| [T3] 수정 팝업 열기/닫기 | ✅ PASS / ⏭ SKIP / ❌ FAIL | |

스크린샷:
- e2e/{업무군}/{메뉴코드}/{메뉴코드}-screen.png
- e2e/{업무군}/{메뉴코드}/{메뉴코드}-search.png
- e2e/{업무군}/{메뉴코드}/{메뉴코드}-popup.png (팝업 있는 경우)

실패 항목:
(실패가 있는 경우에만 에러 메시지 + 라인 첨부)
```

---

## 주의

- `npm run dev:dev` 는 AI 가 직접 실행하지 않는다. 반드시 사용자가 미리 띄운 서버를 사용.
- `.auth-state.json` 은 `e2e/` 에 저장. `.gitignore` 에 이미 있거나 없으면 추가 권고.
- `e2e/*.spec.js` 가 누적되어도 `playwright.config.js` 의 `testDir: './e2e'` 설정으로 모두 인식됨. 메뉴별로 `npx playwright test e2e/{메뉴코드}.spec.js` 로 개별 실행 가능.
- DOM 셀렉터(`'.aui-grid-row'`)는 AUIGrid 버전에 따라 다를 수 있음. 실패 시 브라우저 개발자도구로 실제 class 확인 후 수정.
- 쓰기 API(PUT/PATCH/DELETE) 는 자동 테스트하지 않는다 — 실데이터 오염 방지.
