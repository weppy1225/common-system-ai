---
name: PI_fe_all
description: FE 목록 화면 + 팝업 전체 생성 (기본 `{메뉴코드}.vue` + `{메뉴코드}Edt.vue`, 변형 `Sch`/`Set`/업무별 팝업 포함). /PI_fe_all {메뉴코드}
when_to_use: "FE 전체 개발해줘", "목록이랑 팝업 다 만들어줘", "FE 화면 처음부터 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# FE 전체 화면 개발 (목록+팝업) [PI_fe_all]

BE spec.md 기반으로 목록 화면과 팝업 컴포넌트를 한 번에 생성한다. 기본형은 `{메뉴코드}.vue` + `{메뉴코드}Edt.vue`이며, 실제 FE 표본처럼 `mdbz01Sch.vue`(검색), `mdbz01Set.vue`(설정), `Ivst01Proc`/`Ivst01Cancel`/`Ivst01ProcCancel`/`Ivst01ReqInvenMove` 같은 업무별 다중 팝업 조합도 허용한다.

## 사용법

```
/PI_fe_all {메뉴코드}
예: /PI_fe_all mdct01
```

## 실행 절차

### STEP 1. 레포 경로 결정 (BLOCKING)

스킬은 AI 허브(`wms-{code}-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 `$FE_DIR`(생성 대상 FE 레포)와 `$BE_DIR`(spec 읽기 대상 BE 레포)를 결정한다.
- FE 코드 생성: `$FE_DIR/src/views/...` — 작업 시작 시 **`cd "$FE_DIR"`** 하면 본문의 `src/views/...`·`ai-docs/...` 상대경로가 그대로 동작한다.
- BE spec 읽기: `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/` (읽기 전용)

### STEP 2. BE spec 파일 확인

경로: `$BE_DIR/DEV_DOC/ai-docs/20-backend/80-spec/{메뉴코드}/`

우선순위:
1. `{YYYYMMDD}_output.md` (날짜 최신 파일)
2. `output.md`
3. `spec.md`

파일이 없으면 사용자에게 BE spec 파일 경로를 직접 묻는다.

### STEP 3. spec 파싱

spec에서 추출:
- 업무군 코드 (예: `rt2000`, `md8000`) — `ai-docs/20-frontend/00-frontend-ai-entry.md` 업무군 맵 또는 spec 내 라우트 경로 참조
- 리소스명 (camelCase, 예: `cont`, `return`)
- API URL 목록 (리스트/단건/등록/수정/삭제)
- 응답 네이밍 (`postXxx`, `xxx`)
- 복합키 순서 (`{resourceSeq}/{bizSeq}`)
- 사용 공통코드 (`commHCd` 목록)
- 검색 조건 필드
- 그리드 컬럼 필드
- 팝업 폼 필드

### STEP 4. 목록 화면 생성 (`{메뉴코드}.vue`)

`ai-docs/20-frontend/30-convention/10-vue-file-template.md` §1 스켈레톤 기준.

**구성 요소:**
- `SearchSection` + `ZCellBox` 검색 영역 (spec 검색 조건 기준)
- `ContentSection` + `ZAuiGrid` 결과 그리드 (spec 컬럼 기준)
- 실제 FE 파일 확인 후 팝업 컴포넌트 import 및 ref 연결
- 기본형: `{메뉴코드}Edt`
- 변형형: `{메뉴코드}Sch`(검색 팝업), `{메뉴코드}Set`(설정 팝업)
- 다중 업무 팝업형: `Ivst01Edt`, `Ivst01Proc`, `Ivst01Cancel`, `Ivst01ProcCancel`, `Ivst01ReqInvenMove`처럼 한 화면에 여러 팝업을 병렬 연결 가능

**코드 규칙 (`02-fe-code-rule.md` 준수):**
- 리스트 조회: `axios.post(url, searchObj.value)` → `res.data.post{Resources}`
- `errorSwal`, `successSwal`, `confirmSwal`, `noSelectSwal`, `oneSelectSwal` 사용
- `regBizSeq` URL 하드코딩 금지 (zAxios 인터셉터 자동 처리)
- `vfn_` 접두사: view 로컬 함수, `lfn_` 접두사: 모듈 내부 함수
- import 순서: `3rd > 컴포넌트 > 팝업 > store > gfn > 변수선언`
- `onActivated`에서 bizSeq 변경 감지
- `searchRef({ ...initXxxObj.deepCopy() })` 패턴

**생성 파일:** `src/views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue`

### STEP 5. 팝업 컴포넌트 생성 (`{메뉴코드}Edt.vue` 등)

`ai-docs/20-frontend/30-convention/10-vue-file-template.md` §2 스켈레톤 기준.

**구성 요소:**
- `LayerPopup` 컴포넌트 (title + code props)
- `ZCellBox` + `ZCell` 폼 영역 (spec 팝업 필드 기준)
- 등록 / 수정 모드 전환 (`isUpdate` computed)
- 유효성 검증 (`gfn_useValid`)
- 실제 FE 확인 결과에 따라 `{메뉴코드}Edt` 단일 팝업이 아니라 `{메뉴코드}Sch`, `{메뉴코드}Set`, `Proc`, `Cancel`, `ProcCancel` 같은 업무별 보조 팝업으로 분리 가능

**코드 규칙:**
- 등록: `axios.put(url, payload)` → `successSwal` + emit + closePopup
- 수정: `axios.patch(url, payload)` → `successSwal` + emit + closePopup
- PK 필드는 수정 모드에서 `disabled`
- `defineExpose({ openPopup })`
- `closeCallback`에 `vfn_resetPopup` 연결

**생성 파일:** `src/views/be/{업무군}/{메뉴코드}/{실제확인한팝업파일명}.vue`

### STEP 6. 메뉴 문서 생성

`ai-docs/20-frontend/60-menus/_template.md` 복사 후 채움:
- §2 화면구성: 검색조건·그리드·팝업 항목
- §3 API 매핑: spec의 API 목록 그대로
- §9 BE 동기화: 오늘 날짜 + BE spec 원본 경로

**생성 파일:** `ai-docs/20-frontend/60-menus/{업무군}/{메뉴코드}/menu.md`

### STEP 7. 자기 검증

`ai-docs/20-frontend/70-prompts/76-verify-menu-contract.md` 절차로 정합성 확인:
- HTTP 메서드 규약 (POST=리스트, GET=단건, PUT=등록, PATCH=수정, DELETE=삭제)
- URL 경로 — `regBizSeq` 포함 여부
- 복합키 순서 (`{resourceSeq}/{bizSeq}`)
- 응답 네이밍 (`res.data.post{Resource}s`, `res.data.{resource}`)

### STEP 8. 완료 보고

```
생성 파일:
  src/views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue
  src/views/be/{업무군}/{메뉴코드}/{실제확인한팝업파일명}.vue
  ai-docs/20-frontend/60-menus/{업무군}/{메뉴코드}/menu.md

API 연결:
  리스트: POST /{메뉴코드}/{리소스}s
  단건:   GET  /{메뉴코드}/{리소스}s/{seq}/{bizSeq}
  등록:   PUT  /{메뉴코드}/{리소스}s
  수정:   PATCH /{메뉴코드}/{리소스}s/{seq}/{bizSeq}

후속 수동 작업:
  - router.js 에 라우트 등록
  - 메뉴 DB 등록
```

## 주의사항

- BE spec에 없는 정보는 추측 말고 `// TODO:` 주석으로 표시
- `regBizSeq` URL 포함 금지
- 라우터 등록·메뉴 DB는 이 스킬 범위 밖
- BE 저장소(`$BE_DIR`) 파일은 읽기만 함, 수정 금지
- 영어 주석 금지 — 한글 유지
