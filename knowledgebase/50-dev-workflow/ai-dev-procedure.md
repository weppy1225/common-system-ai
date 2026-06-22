---
title: AI 개발 절차 (BE / FE)
description: AI 에이전트(Claude Code)가 WMS BE·FE 개발을 수행할 때 따르는 단계별 절차. 코드 생성 → 단위테스트 → 기동 → 통합테스트 순서를 정의한다.
status: active
version: 1.0.0
wms_meta: true
repo_role: ai-hub
agent_usage: instruction
domain: common
tags:
  - procedure
  - be
  - fe
  - junit
  - bruno
  - vitest
  - mockoon
  - playwright
related:
  - patterns/30-backend/be-layer-pattern.md
  - .claude/rules/backend-convention.md
  - .claude/rules/db-convention.md
last_verified: 2026-06-10
---

# AI 개발 절차 (BE / FE)

AI 에이전트가 신규 메뉴를 개발할 때 준수하는 단계별 절차를 정의한다.  
BE와 FE 각각 **코드 개발 → 단위테스트 → 기동/목업 → 통합테스트** 4단계로 구성된다.

---

## 전제 조건 (개발 착수 전 완료 상태)

| 산출물 | 위치 | 생성 스킬 |
|---|---|---|
| 화면요건 (`*-02-ui.md`) | `spec/{메뉴코드}/` | `/SD_310_UI` |
| DB 설계 (`db.md`) | `spec/{메뉴코드}/` | `/SD_db` |
| DB 반영 완료 (test/dev) | PostgreSQL | `/SD_db_apply` |
| API 명세 (`api.md`) | `spec/{메뉴코드}/` | `/SD_api` |

> 위 4가지 산출물이 갖춰진 뒤 BE 개발을 시작한다. FE 개발은 BE spec.md가 추가로 필요하다.

---

## BE 개발 절차

```
[1] 코드 개발        →  [2] JUnit 단위테스트  →  [3] Boot Run 기동  →  [4] Bruno 통합테스트
Mapper → Dao           레이어별 순차 실행       애플리케이션 정상        REST API 전체
→ TxComp → Comp         (실패 시 즉시 수정)      기동 여부 확인           시나리오 검증
→ Controller
```

### [1] 코드 개발

레이어 개발 순서는 **의존 방향과 반대** 방향(하위 → 상위)으로 진행한다.

| 순서 | 레이어 | 생성 파일 | 스킬 |
|---|---|---|---|
| 1 | Mapper | `{메뉴코드}Mapper.java` + `{메뉴코드}Mapper.xml` | `/PI_be_mapper` |
| 2 | Dao | `{메뉴코드}Dao.java` | `/PI_be_dao` |
| 3 | CompUtil *(선택)* | `{메뉴코드}CompUtil.java` | `/PI_be_comp` 내 포함 |
| 4 | TxComp *(선택)* | `{메뉴코드}TxComp.java` | `/PI_be_comp` 내 포함 |
| 5 | Comp | `{메뉴코드}Comp.java` | `/PI_be_comp` |
| 6 | Controller | `{메뉴코드}Controller.java` | `/PI_be_comp` 내 포함 |

> 전체 레이어 일괄 개발 시 `/PI_be_all {메뉴코드}` 사용.  
> 재고 처리(입출고 확정) 포함 시 `/PI_be_inven {메뉴코드}` 추가 실행.

**DB 스키마 직접 확인 (BLOCKING)**

컬럼명·자료형·제약조건·FK 관계는 문서(db.md·ai-docs)만 보고 추정하지 않는다.  
코드 작성 전 반드시 **psql로 실제 DB를 조회**하여 근거를 확보한 뒤 사용한다.

```powershell
# DB 접속 (접속 정보는 application-dev.properties 참조)
psql -h {DB_HOST} -p {DB_PORT} -U {DB_USER} -d {DB_NAME}
```

| 확인 목적 | psql 명령 |
|---|---|
| 테이블 컬럼 목록·자료형·NOT NULL 확인 | `\d {테이블명}` |
| 컬럼 상세 (기본값·시퀀스 포함) | `\d+ {테이블명}` |
| FK(외래키) 관계 확인 | `\d+ {테이블명}` → Foreign-key constraints 섹션 |
| 인덱스 목록 | `\di {테이블명}*` |
| 유니크 제약 확인 | `SELECT * FROM information_schema.table_constraints WHERE table_name='{테이블명}';` |
| 실제 공통코드 값 확인 | `SELECT comm_cd, comm_nm FROM sm_comm_d WHERE comm_grp_cd='{그룹코드}' AND use_yn='Y';` |
| 시퀀스 현재값·증가값 확인 | `SELECT * FROM pg_sequences WHERE sequencename='{시퀀스명}';` |
| 참조 테이블 전체 관계 조회 | `SELECT tc.table_name, kcu.column_name, ccu.table_name AS foreign_table, ccu.column_name AS foreign_column FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name=kcu.constraint_name JOIN information_schema.referential_constraints rc ON tc.constraint_name=rc.constraint_name JOIN information_schema.constraint_column_usage ccu ON rc.unique_constraint_name=ccu.constraint_name WHERE tc.constraint_type='FOREIGN KEY' AND tc.table_name='{테이블명}';` |

> **추정 금지 항목** — 아래 항목은 반드시 psql로 확인 후 코드에 사용한다.
> - 컬럼명 (스네이크케이스 철자, 축약어)
> - `_cd` 컬럼의 허용 공통코드 값
> - NOT NULL / DEFAULT 값 여부
> - FK 참조 테이블·컬럼명
> - 시퀀스명 (`{테이블명}_seq` 가정 금지)

**컨벤션 참조**
- 레이어 패턴: `patterns/30-backend/be-layer-pattern.md`
- 코딩 컨벤션: `.claude/rules/backend-convention.md`
- MyBatis 쿼리: `.claude/rules/db-convention.md`
- 재고 프레임워크: `.claude/rules/biz-framework.md`

**코드 개발 완료 기준**
- 각 레이어 파일이 컴파일 오류 없이 빌드됨
- `be-layer-pattern.md` §완료 체크리스트 통과
- Mapper XML의 모든 SQL이 `api.md` 기능명세와 1:1 대응
- 사용된 컬럼명·제약조건이 psql 조회 결과와 일치함

---

### [2] JUnit 단위테스트

레이어별 JUnit 테스트 클래스를 작성하고 **Gradle 테스트**로 검증한다.

#### 테스트 파일 위치

```
common-system-be/
└── src/test/java/
    └── {패키지}/
        └── {메뉴그룹}/
            └── {메뉴코드}/
                ├── {메뉴코드}MapperTest.java
                ├── {메뉴코드}DaoTest.java
                ├── {메뉴코드}CompTest.java
                └── {메뉴코드}ControllerTest.java
```

#### 실행 명령

```powershell
# Windows (PowerShell) — common-system-be 디렉토리에서 실행
cd C:\zinide\workspace\common-system-be

# 특정 메뉴 테스트만 실행
.\gradlew test --tests "*.{메뉴코드}*" --info

# 전체 테스트 실행
.\gradlew test
```

#### 스킬 사용

```
/PI_test_be {메뉴코드}
```

#### 단위테스트 완료 기준

- [ ] 모든 `@Test` 메서드 GREEN
- [ ] 실제 DB(test 서버)에 접속하여 실행됨 (Mock DB 사용 금지)
- [ ] 목록 조회, 단건 조회, 등록, 수정, 삭제 시나리오 각 1건 이상 커버
- [ ] 예외 케이스(필수값 누락, 중복 등) 테스트 포함

---

### [3] Boot Run 기동

단위테스트 통과 후 Spring Boot 애플리케이션을 기동하여 **실행 가능 상태**를 확인한다.

#### 기동 명령

```powershell
# common-system-be 디렉토리에서 실행
.\gradlew bootRun

# 또는 특정 프로파일 지정
.\gradlew bootRun --args='--spring.profiles.active=dev'
```

#### 기동 완료 확인

- 로그에서 `Started Application in X.XXX seconds` 확인
- `http://localhost:{port}/actuator/health` → `{"status":"UP"}` 응답
- 예외 스택 트레이스 없음

#### Boot Run 완료 기준

- [ ] 애플리케이션 정상 기동 (포트 오류·Bean 주입 오류 없음)
- [ ] 새로 추가한 Controller URL 매핑이 로그에 노출됨
- [ ] DB 커넥션 풀 정상 (HikariCP 초기화 로그 확인)

---

### [4] Bruno 통합테스트

Bruno CLI를 사용하여 REST API 전체 시나리오를 자동 검증한다.

#### Bruno 컬렉션 위치

```
common-system-be/
└── src/test/bruno/
    └── {메뉴그룹}/
        └── {메뉴코드}/
            ├── 01-목록조회.bru
            ├── 02-단건조회.bru
            ├── 03-등록.bru
            ├── 04-수정.bru
            └── 05-삭제.bru
```

#### 환경 파일

```
common-system-be/
└── src/test/bruno/
    └── environments/
        ├── local.bru
        └── dev.bru
```

#### 실행 명령

```powershell
# Bruno CLI — 특정 메뉴 컬렉션 실행
bru run "src/test/bruno/{메뉴그룹}/{메뉴코드}" --env local

# 결과 리포트 파일 출력
bru run "src/test/bruno/{메뉴그룹}/{메뉴코드}" --env local --reporter-json results.json
```

#### 스킬 사용

```
/PI_test_be {메뉴코드}
```

> `/PI_test_be` 스킬은 JUnit([2]) + Bruno([4])를 순차 실행한다.

#### Bruno 통합테스트 완료 기준

- [ ] 전체 `.bru` 파일 PASS (실패 0건)
- [ ] 목록 조회 → 등록 → 단건 조회 → 수정 → 삭제 순서 시나리오 정상 동작
- [ ] HTTP 응답코드 200, 응답 바디의 `succeed: true` 또는 `procCnt > 0` 확인
- [ ] 등록 후 목록 재조회 시 신규 데이터 포함 확인

---

## FE 개발 절차

```
[1] 코드 개발        →  [2] Vitest 단위테스트  →  [3] Mockoon 테스트  →  [4] Playwright E2E
{메뉴코드}.vue             컴포넌트 로직·렌더링      BE 없이 Mock API로      실제 브라우저에서
{메뉴코드}Edt.vue          독립 검증               FE 동작 완전성 검증      전체 시나리오 검증
```

### [1] 코드 개발

#### 사전 필요 산출물

| 산출물 | 위치 |
|---|---|
| BE spec.md (API 명세 + VO/DTO) | `spec/{메뉴코드}/{메뉴코드}-05-api.md` |
| 화면요건 ui.md | `spec/{메뉴코드}/{메뉴코드}-02-ui.md` |
| 프로토타입 wireframe.html | `spec/{메뉴코드}/{메뉴코드}-02-wireframe.html` |

#### 생성 파일 및 위치

```
common-system-fe/
└── src/views/
    └── {메뉴그룹}/
        └── {메뉴코드}/
            ├── {메뉴코드}.vue         # 목록 화면 (검색조건 + 결과그리드)
            └── {메뉴코드}Edt.vue      # 등록/수정 팝업
```

#### 스킬 사용

| 상황 | 스킬 |
|---|---|
| 목록 + 팝업 동시 개발 | `/PI_fe_all {메뉴코드}` |
| 목록 화면만 | `/PI_fe_list {메뉴코드}` |
| 등록/수정 팝업만 | `/PI_fe_edit {메뉴코드}` |

#### 코드 개발 완료 기준

- [ ] TypeScript/ESLint 오류 없음 (`npm run lint`)
- [ ] spec.md의 모든 API 엔드포인트가 컴포넌트에 연결됨
- [ ] ui.md의 검색조건·그리드·팝업 항목이 모두 구현됨

---

### [2] Vitest 단위테스트

Vue 컴포넌트의 **렌더링·이벤트·상태 변화**를 브라우저 없이 검증한다.

#### 테스트 파일 위치

```
common-system-fe/
└── src/views/
    └── {메뉴그룹}/
        └── {메뉴코드}/
            └── __tests__/
                ├── {메뉴코드}.spec.ts
                └── {메뉴코드}Edt.spec.ts
```

#### 실행 명령

```powershell
# common-system-fe 디렉토리에서 실행
cd C:\zinide\workspace\common-system-fe

# 특정 메뉴 테스트만 실행
npm run test:unit -- {메뉴코드}

# 전체 테스트 실행
npm run test:unit

# Watch 모드
npm run test:unit -- --watch
```

#### 스킬 사용

```
/PI_test_fe
```

#### Vitest 완료 기준

- [ ] 전체 `*.spec.ts` PASS
- [ ] 컴포넌트 마운트 성공 (렌더링 오류 없음)
- [ ] 검색 버튼 클릭 → API 호출 함수 실행 확인
- [ ] 팝업 열기/닫기 동작 확인
- [ ] 폼 유효성 검증 로직 통과·실패 케이스 커버

---

### [3] Mockoon 테스트

**BE 서버 없이** Mockoon으로 API를 목업하여 FE 화면의 동작 완전성을 검증한다.  
실제 BE 연동 전에 FE 독립 개발 단계에서 수행한다.

#### Mockoon 환경 파일 위치

```
common-system-fe/
└── src/test/mockoon/
    └── {메뉴그룹}/
        └── {메뉴코드}-mock.json       # Mockoon 환경 설정 파일
```

#### Mockoon 서버 기동

```powershell
# Mockoon CLI 전역 설치 (최초 1회)
npm install -g @mockoon/cli

# 특정 메뉴 Mock 서버 기동 (포트는 환경 파일에 정의)
mockoon-cli start --data "src/test/mockoon/{메뉴그룹}/{메뉴코드}-mock.json"
```

#### FE 환경 변수 전환

```
# .env.mockoon (Mockoon 테스트용)
VITE_API_BASE_URL=http://localhost:3001

# .env.development (실제 BE 연동)
VITE_API_BASE_URL=http://localhost:8080
```

#### Mockoon 테스트 실행

```powershell
# Mockoon 서버 기동 후 FE dev 서버 기동
npm run dev -- --mode mockoon
```

#### Mockoon 테스트 완료 기준

- [ ] 목록 조회 → Mock 데이터 정상 렌더링
- [ ] 등록 팝업 → 저장 → 성공 토스트 메시지 표시
- [ ] 수정 팝업 → 기존 데이터 로드 → 수정 저장 정상
- [ ] 삭제 → 확인 다이얼로그 → 삭제 후 목록 갱신
- [ ] 에러 케이스 (400/500 Mock 응답) 처리 확인

---

### [4] Playwright E2E 테스트

실제 브라우저에서 **전체 사용자 시나리오**를 자동 실행하여 최종 품질을 검증한다.

#### 테스트 스펙 파일 위치

```
common-system-fe/
└── src/test/e2e/
    └── {메뉴그룹}/
        └── {메뉴코드}.spec.ts         # Playwright 스펙 파일
```

#### 스펙 파일 생성 (없는 경우)

```
/playwright-spec {메뉴그룹} {메뉴코드}
```

4가지 케이스를 자동 생성한다:

| 케이스 | 내용 |
|---|---|
| Happy Path | 정상 흐름 (조회 → 등록 → 수정 → 삭제) |
| Edge Case | 경계값, 빈 목록, 최대 입력값 |
| Failure | 필수값 누락, API 오류 응답 처리 |
| Concurrency | 동시 요청 / 연속 클릭 방어 |

#### 실행 명령

```powershell
# common-system-fe 디렉토리에서 실행
cd C:\zinide\workspace\common-system-fe

# 특정 메뉴 E2E 테스트 실행
npx playwright test "src/test/e2e/{메뉴그룹}/{메뉴코드}.spec.ts"

# UI 모드 (디버깅용)
npx playwright test --ui

# 특정 브라우저 지정
npx playwright test --project=chromium
```

#### 스킬 사용

```
/e2e-menu-test {메뉴그룹} {메뉴코드}
```

> `/e2e-menu-test` 스킬은 스펙 파일이 없으면 `/playwright-spec`을 먼저 호출하여 자동 생성한다.

#### Playwright 테스트 완료 기준

- [ ] Happy Path 시나리오 전체 PASS
- [ ] 화면 스크린샷 이상 없음 (레이아웃 깨짐·데이터 미표시 없음)
- [ ] 팝업 열기/닫기, 검색 팝업(거래처/품목) 연동 정상
- [ ] 페이지네이션, 그리드 행 선택, 다중 패널 연동 정상
- [ ] Edge/Failure 케이스에서 사용자 알림(토스트/다이얼로그) 정상 표시

---

## 전체 절차 요약

### BE

```
/SD_db {메뉴코드}          # DB 설계
/SD_db_apply {메뉴코드}    # DB 반영
/SD_api {메뉴코드}         # API 명세
         ↓
/PI_be_all {메뉴코드}      # [1] 코드 개발 (전 레이어)
         ↓
/PI_test_be {메뉴코드}     # [2] JUnit 단위테스트
         ↓
.\gradlew bootRun          # [3] Boot Run 기동 확인
         ↓
/PI_test_be {메뉴코드}     # [4] Bruno 통합테스트 (스킬 내 포함)
```

### FE

```
/PI_fe_all {메뉴코드}      # [1] 코드 개발 (목록 + 팝업)
         ↓
/PI_test_fe                # [2] Vitest 단위테스트
         ↓
mockoon-cli start ...      # [3] Mockoon 기동 후 수동 확인
         ↓
/e2e-menu-test {메뉴그룹} {메뉴코드}   # [4] Playwright E2E
```

---

## 단계 간 Gate 조건

| 진입 단계 | 이전 단계 완료 조건 |
|---|---|
| BE [2] JUnit | BE [1] 코드 빌드 성공 |
| BE [3] Boot Run | BE [2] JUnit 전체 GREEN |
| BE [4] Bruno | BE [3] 애플리케이션 기동 확인 |
| FE [2] Vitest | FE [1] lint 오류 없음 |
| FE [3] Mockoon | FE [2] Vitest 전체 PASS |
| FE [4] Playwright | BE [4] Bruno 통과 + FE [3] Mockoon 정상 |

> Gate 조건 미충족 시 이전 단계로 되돌아가 원인을 수정한 뒤 재진행한다.  
> AI 에이전트는 테스트 실패 시 원인 분석 → 코드 수정 → 재테스트를 자동으로 반복한다.
