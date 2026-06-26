---
name: SD_db
description: 화면설계 기반 DB 변경사항 도출 + {메뉴코드}-03-data-model.md(DDL SQL 포함) 작성. /SD_db {메뉴코드}
when_to_use: "DB 설계해줘", "데이터모델 만들어줘", "테이블 설계해줘", "DB 변경사항 정리해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Glob, Grep, Bash
model: claude-opus-4-7
---

# DB 설계 [SD_db]

다음 지시에 따라 **DB 설계 문서(`{메뉴코드}-03-data-model.md`)**를 작성한다.

## 목적

화면설계 파일을 기반으로 DB 변경사항(테이블 추가/컬럼 추가/공통코드 추가)을 도출하고
**변경 중심의 간결한 설계 문서**를 작성하여 검토 → DB 반영(`/SD_db_apply`) → 개발 흐름을 지원한다.

---

## 전제 조건

- 메뉴 설계 폴더(`$AI_DIR/spec/$PROJECT/{메뉴코드}/`)에
  화면설계 파일(`{메뉴코드}-02-ui.md`, wireframe HTML 등)이 준비된 상태
- API 명세(`-05-api.md`)는 없어도 진행 가능 (DB 설계가 먼저 작성됨)

---

## 레포 경로 도출 (자동)

스킬은 AI 허브(`common-system-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(허브 = CWD, 입력 화면설계·출력 데이터모델 보유)와 `$PROJECT` 를 결정한다. (DB 접속·반영은 `/SD_db_apply` 담당이라 이 스킬은 BE 레포를 건드리지 않는다.)

```bash
# .claude/rules/repo-paths.md 참조 — AI_DIR(허브, CWD)
AI_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# 허브 spec/prototype 는 프로젝트 층 아래 — 프로젝트명은 워크스페이스 폴더명에서 도출 (→ repo-paths.md)
PROJECT=$(basename "$(dirname "$AI_DIR")"); PROJECT=${PROJECT#workspace-}

# ui.md는 허브($AI_DIR)의 spec/$PROJECT/, wireframe·mock은 prototype/$PROJECT/ 에 위치
UI_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md"

# 산출물 DB 설계 문서 (허브 spec) — 이 스킬의 출력 대상
DB_MD="$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md"

# wireframe: PC / PDA 모바일 자동 분기 (PC=prototype/$PROJECT/{메뉴코드}/, PDA=prototype/$PROJECT/{메뉴코드}m/)
if [ -f "$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html" ]; then
  # PC 화면
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html"
  MOCK_DATA="$AI_DIR/prototype/$PROJECT/{메뉴코드}/{메뉴코드}-mock-data.js"
else
  # PDA 모바일 화면 — prototype/$PROJECT/{메뉴코드}m/
  WIREFRAME="$AI_DIR/prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-wireframe.html"
  MOCK_DATA="$AI_DIR/prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-mock-data.js"
fi
```

> 산출물 `{메뉴코드}-03-data-model.md` 는 **허브** `$AI_DIR/spec/$PROJECT/{메뉴코드}/` 에 쓴다(BE 레포 아님). DB 규칙 문서는 `$AI_DIR/patterns/20-database/`·`$AI_DIR/spec/$PROJECT/_knowledge/db-schema/` 에서 읽는다.
> `spec/$PROJECT/{메뉴코드}/` 폴더가 없으면 사용자에게 경로를 직접 묻는다.

---

## 실행 절차

### Step 1 — 화면설계 파일 로드 (BLOCKING)

아래 경로에서 파일을 찾아 모두 읽는다 (위 "프로젝트 경로 도출"에서 구한 변수 사용):

- `$UI_MD` (`spec/$PROJECT/{메뉴코드}/{메뉴코드}-02-ui.md`) — UI 설계서 (화면 구성, 필드 목록, 업무 흐름)
- `$WIREFRAME` — 화면 프로토타입 (PC: `prototype/$PROJECT/{메뉴코드}/{메뉴코드}-wireframe.html` / PDA: `prototype/$PROJECT/{메뉴코드}m/{메뉴코드}m-wireframe.html`)
- `$MOCK_DATA` — 목업 데이터 (있는 경우)

추가로 기존 설계 문서도 확인:
- `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-01-basic-design.md`·`-05-api.md` — 기본설계·API 명세 (이미 존재하는 경우)

> 화면설계 파일이 없으면 사용자에게 파일 위치를 확인 후 진행한다.

화면설계 파일로부터 아래 항목을 도출한다:
- 필요한 테이블 목록 및 역할
- 각 테이블의 컬럼 후보 (필드명, 타입, 필수여부)
- 상태코드 등 코드성 컬럼 식별

### Step 2 — DB 규칙 문서 로드 (BLOCKING)

아래 문서를 **모두** 읽은 후 Step 3으로 진행한다:

1. `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/00-tables-overview.md` — 전체 테이블 목록
2. `$AI_DIR/patterns/20-database/10-domain-and-types.md` — 컬럼 도메인 타입 규칙
3. `$AI_DIR/patterns/20-database/20-rule/04-sequence-creation-rule.md` — 시퀀스 생성 규칙
4. `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/90-common-code.md` — 기존 공통코드 목록
5. Step 1에서 도출된 테이블이 기존 테이블인 경우:
   `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/0X-*-tables.md` (도메인 그룹) + 실 스키마 psql 확인
   (신규 테이블은 문서 없음 — 화면설계로부터 도출)

> **실 DB 접속**: psql 직접 실행이 필요할 때는 `/DB_PSQL` 스킬 절차를 따른다 (접속 정보 → `$BE_DIR/src/main/resource/prop/application-{ENV}.properties` 파싱 → Bash `psql` 실행).

### Step 3 — 테이블 신규/기존 판정

`00-tables-overview.md` 및 `0X-*-tables.md` 테이블 목록과 대조하여 각 테이블을 판정한다:

| 판정 | 조건 |
|------|------|
| **기존** | `00-tables-overview.md` 그룹표에 등재 |
| **신규** | `00-tables-overview.md` 에 없음 |
| **기존+컬럼추가** | 등재돼 있으나 필요 컬럼이 실 스키마(psql)에 없음 |

### Step 3-A — 불확실 컬럼 의도 확인 (BLOCKING — AskUserQuestion 필수)

**트리거 조건**: 아래 조건을 **모두** 만족하는 필드가 1개라도 있으면 Step 4로 넘어가기 전에 반드시 사용자에게 묻는다.

| 조건 | 설명 |
|---|---|
| FE(Vue) 또는 BE Param bean에 해당 필드가 존재 | 화면에서 전송하거나 서버가 수신하는 필드 |
| DB 테이블에 해당 컬럼이 없음 | psql 실 스키마 확인 결과 |
| Mapper SQL(INSERT/UPDATE)에도 포함되지 않음 | Mapper.xml 에 해당 컬럼 없음 |

이 조건에 해당하면 **"컬럼 추가가 필요하다"고 단방향 추론 금지**. 아래와 같이 묻는다.

```
AskUserQuestion(
  질문: "{테이블명}.{컬럼후보} 컬럼이 없습니다. {필드명}(은)는 FE에서 전송되지만 현재 DB·SQL에 저장 로직이 없습니다. 의도를 확인해 주세요.",
  옵션:
    - "컬럼 추가 필요" → DDL 작성 대상에 포함
    - "의도적 미저장 (다른 시점에 입력)" → DDL 없음, 문서에 이슈로만 기재
    - "확인 후 결정 (지금은 보류)" → DDL 없음, ⚠️ 미확인으로 기재
)
```

**확인 대상 예시:**
- Vue에서 `extraRequest` 전송 → BE Param에 `reqNote` 존재 → `shop_cart` 테이블에 `req_note` 없음 → Mapper INSERT에도 없음 → **반드시 묻는다**
- 반대로, 컬럼이 실제 DB에 존재하거나 SQL에 포함되어 있으면 이 단계를 건너뛴다

---

### Step 4 — 공통코드 현황 파악

`90-common-code.md` 를 기준으로:
- `_cd` 접미사 컬럼 식별 → 기존 코드그룹 확인
- 기존에 없는 코드그룹 → 신규 INSERT SQL 작성 (sm_comm_h + sm_comm_d)

### Step 5 — 컬럼 도메인 타입 결정

`patterns/20-database/10-domain-and-types.md` 기준으로 각 컬럼의 도메인 분류와 데이터 타입을 결정한다.

**seq 타입 규칙 (엄수)**:
- **헤더(H) 테이블 seq**: `int4` 고정
- **자식(D1~Dn) 테이블 seq**: `bigint` 고정
- FK로 참조하는 부모 seq는 부모 테이블과 동일 타입 사용

**PostgreSQL 타입 전략**:
- PK 시퀀스: `int4` / `bigint` + `nextval` (UUID 사용 금지 — 기존 규칙 통일)
- 문자열: 길이 제한 있으면 `varchar(n)`, 제한 없으면 `text`
- 날짜(8자리): `varchar(8)` YYYYMMDD 고정
- 일시: `timestamp` (타임존 불필요 — 서버 단일 타임존 운영)
- 코드값(`_cd`): `varchar(n)` — `sm_code` 참조
- 금액/수량: 소수점 없으면 `int4`/`bigint`, 있으면 `numeric(p,s)`

**인덱스 설계 기준**:
- 단일 컬럼 조회 빈도 높음 → 단순 인덱스
- 복합 조건 조회 → 복합 인덱스 (선택도 높은 컬럼을 앞에)
- 특정 조건 행만 인덱싱 필요 → Partial 인덱스 (`WHERE` 절 포함)

**PostgreSQL 컬럼 확인 SQL 예시** (`/DB_PSQL` 스킬로 실행):
```sql
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND lower(table_name) = lower('{테이블명}')
ORDER BY ordinal_position;
```

### Step 6 — 데이터모델 문서 작성

`$DB_MD` (`$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md`) 파일을 아래 템플릿으로 작성한다.

**frontmatter `author` 필드 (MUST — 추정 금지)**:
파일 작성 전 반드시 아래를 실행하고 그 결과를 `author`에 기입한다. 추정·하드코딩 금지.

```bash
git config user.name   # 이 값을 author 필드에 사용
```

**작성 원칙:**
- **변경/추가 사항 중심** — 기존 테이블을 그대로 사용하는 경우 컬럼 명세를 나열하지 않는다
- **DDL이 핵심** — 검토자가 DDL SQL만 보고도 변경 범위를 파악할 수 있도록 한다
- 기존 테이블에 변경이 없으면 "사용 테이블" 목록만 남기고 상세는 생략한다

---

## {메뉴코드}-03-data-model.md 템플릿

```markdown
# {기능명} DB 설계

> 작성일: {YYYY-MM-DD} | 상태: 초안
> 참조 화면설계: {메뉴코드}-02-ui.md
> 검토자: {이름} | 승인일자: {YYYY-MM-DD} | 승인여부: [ ] 승인대기 / [x] 승인완료

---

## 1. 변경 요약

| 구분 | 대상 | 내용 |
|------|------|------|
| {신규테이블/컬럼추가/공통코드/변경없음} | `{테이블명 또는 코드그룹}` | {한줄 설명} |

> 변경이 없는 경우: "기존 테이블 그대로 사용 — DDL 없음" 으로 표기하고 섹션 2~4만 작성

---

## 2. 사용 테이블

| 테이블명 | 판정 | 비고 |
|----------|------|------|
| `{테이블명}` | 기존/신규/기존+컬럼추가 | {역할 또는 변경 내용 한줄} |

---

## 3. 신규 테이블 명세

> 신규 테이블이 없으면 이 섹션 생략

### {테이블명} ({H/D1/D2})

> 역할: {테이블 역할 설명}
> seq 타입: **{int4/bigint}** — {헤더/자식} 테이블

| 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|--------|-----------|------|--------|------|
| `{pk_컬럼}` | int4/bigint | NOT NULL | nextval('{테이블명}_seq') | PK |
| `biz_seq` | int4 | NOT NULL | | 사업장ID |
| `{컬럼명}` | {타입} | {NULL/NOT NULL} | {기본값} | {설명} |
| `use_yn` | char(1) | NOT NULL | 'Y' | 사용여부 |
| `reg_id` | varchar(100) | NOT NULL | | 등록자 |
| `reg_dt` | timestamp | NOT NULL | now() | 등록일시 |
| `mod_id` | varchar(100) | | | 수정자 |
| `mod_dt` | timestamp | | | 수정일시 |

---

## 4. 기존 테이블 컬럼 추가

> 컬럼 추가가 없으면 이 섹션 생략

### {테이블명}

| 추가 컬럼명 | 데이터 타입 | NULL | 기본값 | 설명 |
|------------|-----------|------|--------|------|
| `{컬럼명}` | {타입} | {NULL/NOT NULL} | {기본값} | {설명} |

---

## 5. 공통코드

> 공통코드 변경이 없으면 이 섹션 생략

### 신규 코드그룹

| 코드그룹(comm_h_cd) | 설명 | 코드값 목록 |
|--------------------|------|-----------|
| `{NEW_COMM_H_CD}` | {설명} | {코드값1}({설명}), {코드값2}({설명}) |

---

## 6. DDL SQL

> **실행 순서대로 기술. 이 섹션만으로 DB 반영 가능하도록 작성.**
> 변경사항이 없으면 "DDL 없음" 표기

### UP SQL (적용)

### DOWN SQL (롤백)

---

## 7. 체크리스트

- [ ] 검토자 확인 및 서명 (검토자: __________ / 일자: __________)
- [ ] DOWN SQL 작성 완료 (롤백 시나리오 확인)
- [ ] `/SD_db_apply` 실행하여 test 서버 반영 완료
```

---

### Step 7 — 확인 요청

`{메뉴코드}-03-data-model.md` 작성 완료 후:
1. 사용자에게 내용 검토 요청 (특히 섹션 6 DDL SQL)
2. 확인 완료 시 `/SD_db_apply`로 DB 반영 안내
3. DB 반영 완료 후 `/SD_api`로 기능 명세서 작성 안내
