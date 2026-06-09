---
name: PI-test-fe
description: 【FE 단위 테스트 실행 (Windows/WSL/Linux/Mac 통합)】 npm run test:unit 을 실행하고 결과를 보고합니다. 실패 시 오류 원인을 분석하고 수정 방향을 제시합니다. 실행 환경(Windows/WSL/Linux/macOS)을 자동 감지하여 적절한 방식으로 실행합니다. /PI-test-fe 형식으로 실행합니다. "FE 테스트 실행해줘", "unit test 돌려줘", "vitest 실행해줘", "PI-test-fe 실행해줘", "WSL에서 FE 테스트 실행해줘", "리눅스에서 unit test 돌려줘", "bash로 프론트 테스트 해줘" 라고 말하면 이 스킬을 사용합니다.
user-invocable: true
allowed-tools: Read, Bash, Grep
model: claude-sonnet-4-6
---

# FE 단위 테스트 실행 [PI-test-fe]

`npm run test:unit` 을 실행하고 결과를 분석·보고한다.

## 사용법

```
/PI-test-fe
또는
/PI-test-fe {메뉴코드}    (특정 메뉴 테스트만 실행)
```

---

## STEP 1. FE 프로젝트 경로 및 환경 확인

`package.json`에 `test:unit` 스크립트가 있는지 확인한다.

```bash
ls package.json 2>/dev/null || echo "package.json 없음 — 올바른 FE 프로젝트 경로로 이동 필요"
grep '"test' package.json
```

`test:unit` 스크립트가 없으면 `npx vitest --run` 명령어를 직접 사용한다.

---

## STEP 2. 테스트 실행

`--run` 플래그를 항상 사용한다 (watch 모드 비활성화, CI 환경과 동일하게 1회 실행 후 종료).

**전체 테스트:**
```bash
npm run test:unit -- --run --reporter=verbose 2>&1
```

**특정 메뉴 테스트만:**
```bash
npm run test:unit -- --run --reporter=verbose {메뉴코드} 2>&1
```

> WSL2에서 Windows 경로(`/mnt/c/...`)의 `node_modules`는 성능이 느릴 수 있다.
> 빠른 실행이 필요하면 WSL 홈 디렉토리(`~/projects/...`)에 프로젝트를 복사해서 실행한다.
> `node_modules`가 없으면 `npm install` 먼저 실행한다.

---

## STEP 3. 결과 분석 및 보고

**통과 시:**
```
테스트 결과: 전체 통과
  - 통과: {N}건
  - 실패: 0건
  - 건너뜀: {N}건
  - 실행 시간: {N}ms
```

**실패 시:**
각 실패 항목에 대해:

```
실패 항목: {테스트 파일} > {테스트명}
  원인: {에러 메시지 요약}
  위치: {파일경로}:{라인번호}
  수정 방향: {간략한 수정 제안}
```

**주요 오류 패턴 분석:**

| 오류 타입 | 원인 | 수정 방향 |
|---|---|---|
| `Cannot find module` | import 경로 오류 | import 경로 확인, alias 설정 확인 |
| `ReferenceError: xxx is not defined` | 전역 변수/함수 미정의 | vitest setup 파일에 글로벌 mock 추가 필요 |
| `TypeError: xxx is not a function` | mock 설정 오류 | vi.fn() 또는 vi.mock() 점검 |
| `Expected ... to equal ...` | 로직 오류 | 기댓값과 실제값 비교 후 수정 |
| `[Vue warn]` | Vue 컴포넌트 경고 | props/emits 정의 확인 |
| `EACCES` | 파일 권한 오류 (WSL) | `chmod +x node_modules/.bin/vitest` |

---

## STEP 4. 요약 보고

```
FE 단위 테스트 결과 요약
========================
전체: {통과}/{전체}건 통과
실패: {N}건

실패 목록:
  1. {파일명} > {테스트명}: {원인 한 줄}
  2. ...

권장 후속 조치:
  - [수정 필요] {파일경로}: {수정 내용}
  - ...
```

---

## 참고

- 테스트 파일 위치: `vitest/` 디렉토리 (package.json의 `--root vitest` 옵션)
- vitest 설정: `vitest.config.js` 또는 `vite.config.js`의 `test` 섹션
- 전역 mock: `vitest/setup.js` 파일 확인
- e2e 테스트는 이 스킬 범위 밖 (별도 Playwright 환경 필요)
