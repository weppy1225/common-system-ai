---
name: SD_db_apply
description: {메뉴코드}-03-data-model.md 의 DDL을 psql로 test/dev DB에 반영하고 DB 문서를 최신화 (Windows/WSL/Linux 자동 감지). /SD_db_apply {메뉴코드}
when_to_use: "DB 반영해줘", "DDL 실행해줘", "데이터모델 DDL 적용해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# DB 설계사항 반영 [SD_db_apply]

**`{메뉴코드}-03-data-model.md` 의 DDL을 test 서버에 반영하고 DB 문서를 최신화**한다.

## 목적

설계 확정된 DDL SQL을 psql로 실행하고, 관련 DB 문서를 자동으로 최신화하여
수동 문서 작업을 없앤다.

---

## 전제 조건

- `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md` 가 존재하고 섹션 6(DDL SQL)이 작성된 상태
- 사용자가 해당 문서 내용을 검토 완료한 상태

---

## Step 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(허브, CWD)·`$BE_DIR`(형제 `../{프로젝트}-be`)·`$PROJECT` 를 도출한다. 이 스킬은 **허브와 BE 를 함께 다루므로 `cd` 하지 않고** 경로를 변수로 명시한다.

| 대상 | 위치 |
|---|---|
| 설계 DDL 정본·DB 문서(변경이력·스키마) | `$AI_DIR/spec/$PROJECT/...` (허브) |
| DB 접속 정보(properties) | `$BE_DIR/src/main/resource/prop/...` (BE 레포) |

---

## Step 1 — 변경 이력 확인

`$AI_DIR/spec/$PROJECT/_knowledge/db-schema/00-database-deploy-history.md` 를 읽어
현재 기능 테이블 중 **이미 테스트반영일이 기입된 항목은 제외**한다.

> 파일이 없으면 생성한다(변경 이력 표 헤더: `| 반영일시 | 메뉴코드 | 테이블/시퀀스 | 변경 내용 | 테스트반영일 | 운영반영일 |`).

---

## Step 2 — DDL SQL 추출

아래 순서로 DDL을 찾는다:

1. `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-03-data-model.md` 섹션 6 (DDL SQL) (우선)
2. 없으면 `$AI_DIR/spec/$PROJECT/{메뉴코드}/` 의 `*_ddl.sql` 파일

섹션별로 분리:
- 시퀀스 SQL
- 테이블 CREATE SQL
- 인덱스 SQL
- 공통코드 INSERT SQL (있는 경우)
- 기존 테이블 컬럼 추가 ALTER SQL (있는 경우)

---

## Step 3 — DB 접속 정보 로드

`$BE_DIR/src/main/resource/prop/application-dev.properties` 파일에서 파싱:

```
spring.datasource.url=jdbc:postgresql://{host}:{port}/{database}
spring.datasource.username={user}
spring.datasource.password={password}
```

또는 환경변수 `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` 사용 (설정된 경우 우선).

> ⚠️ prod 환경 properties는 절대 읽지 않는다. test/dev 환경만 대상.

---

## Step 4 — psql 경로 감지 및 실행

**반드시 사용자에게 실행할 SQL을 먼저 보여주고 확인을 받은 후 실행한다.**

### psql 경로 자동 감지

```bash
PSQL=$(command -v psql 2>/dev/null || command -v /usr/bin/psql 2>/dev/null || echo "NOT_FOUND")
echo "psql 경로: $PSQL"
```

- Windows: `psql` (PATH에 등록된 psql.exe)
- Linux/WSL/macOS: `psql` 또는 `/usr/bin/psql`

psql을 찾지 못한 경우 사용자에게 설치 또는 경로 확인을 요청한다.

### 실행 순서

1. 시퀀스 생성
2. 테이블 CREATE (또는 ALTER로 컬럼 추가)
3. 인덱스 생성
4. 공통코드 INSERT

```bash
$PSQL -h {host} -p {port} -U {user} -d {database} -c "{DDL SQL}"
```

> Linux/WSL 환경에서는 경로 구분자로 `/` 를 사용한다.

오류 발생 시:
- 즉시 중단
- 오류 메시지와 원인 분석 결과를 사용자에게 보고
- `{메뉴코드}-03-data-model.md` 섹션 6의 **DOWN SQL**을 사용자에게 보여주고 롤백 여부 확인
- 롤백 승인 시 DOWN SQL 실행 (역순)
- 수정 후 재실행 여부를 사용자에게 확인

---

## Step 5 — 반영 후 검증 쿼리 실행

psql 실행 성공 후 아래 쿼리로 반영 내용을 검증하고 결과를 사용자에게 보여준다.

```bash
$PSQL -h {host} -p {port} -U {user} -d {database} -c "
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND lower(table_name) = lower('{테이블명}')
ORDER BY ordinal_position;
"
```

> 검증 결과가 설계서와 다르면 즉시 사용자에게 보고 후 DOWN SQL 롤백 여부 확인

---

## Step 6 — 성공 시 문서 자동 최신화

psql 실행 성공 후 아래 문서를 자동으로 업데이트한다.

> 모든 갱신 대상은 허브 `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/` 하위다.

#### 6-a. 변경·반영 이력 업데이트

`$AI_DIR/spec/$PROJECT/_knowledge/db-schema/00-database-deploy-history.md` "변경 이력" 표에 행 추가(시퀀스도 1행):

```markdown
| {YYYY-MM-DD HH:mm} | {메뉴코드} | {테이블/시퀀스명} | {변경 내용} | {YYYY-MM-DD} | - |
```

#### 6-b. 테이블 목록 문서 업데이트

대상: `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/0X-{도메인}-tables.md` (테이블 접두어로 도메인 그룹 파일 선택; 불명확하면 `00-tables-overview.md` 의 그룹 표로 판정)

**신규 테이블**: 해당 그룹 파일의 "테이블 목록" 표에 행 추가 (`| {테이블명} | {설명} |`). 그룹 파일이 없으면 `00-tables-overview.md` 목록에 추가.

**기존 테이블 컬럼 추가**: 컬럼 단위 명세는 신 구조에서 별도 파일로 두지 않는다(실 스키마 psql 이 SoT). 변경 사실은 6-a 변경이력으로 기록한다.

#### 6-c. 공통코드 문서 업데이트

신규 공통코드가 있는 경우 `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/90-common-code.md` 업데이트

#### 6-d. 테이블 개요 문서 업데이트

신규 테이블/시퀀스인 경우 `$AI_DIR/spec/$PROJECT/_knowledge/db-schema/00-tables-overview.md` 의 도메인 그룹 표·테이블 수를 갱신한다. (신 구조엔 별도 sequence/table-list 문서가 없다 — 시퀀스는 6-a 변경이력에 기록.)

---

## 주의사항

```
✅ test/dev 환경만 반영 (application-dev.properties 기준)
❌ prod 환경 DDL 실행 금지 — 운영 반영은 변경 이력 문서만 생성하고 수동으로 진행
✅ 실행 전 SQL 사용자 확인 필수
✅ 오류 시 즉시 중단 + 보고
✅ 성공 후 반드시 문서 최신화
```

---

## 완료 후 안내

DB 반영 및 문서 최신화 완료 후:
- `{메뉴코드}-03-data-model.md` 섹션 7 체크리스트에서 해당 항목 체크
- `/PI_be_mapper`로 Mapper 레이어 개발 시작 안내
