---
name: SD-db-apply
description: db.md의 DDL을 psql로 test/dev DB에 반영 (Windows/WSL/Linux 자동 감지). /SD-db-apply {메뉴코드}
when_to_use: "DB 반영해줘", "DDL 실행해줘", "db.md DDL 적용해줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# DB 설계사항 반영 [SD-db-apply]

**db.md의 DDL을 test 서버에 반영하고 DB 문서를 최신화**한다.

## 목적

설계 확정된 DDL SQL을 psql로 실행하고, 관련 DB 문서를 자동으로 최신화하여
수동 문서 작업을 없앤다.

---

## 전제 조건

- `db.md`가 존재하고 섹션 6(DDL SQL)이 작성된 상태
- 사용자가 db.md 내용을 검토 완료한 상태

---

## Step 0 — 레포 경로 결정 (BLOCKING)

`.claude/rules/repo-paths.md` 규칙으로 `$BE_DIR`(BE 레포)를 결정한 뒤 **`cd "$BE_DIR"` 후 진행**한다.
이 스킬 본문의 모든 상대경로(`DEV_DOC/...`, `src/main/resource/...`, `db.md`, `{기능폴더}/...`)는 `$BE_DIR`(= 형제 `../wms-{code}-be`) 기준이다.

---

## Step 1 — 변경 이력 확인

`DEV_DOC/ai-docs/10-database/01-database-change-history.md` 를 읽어
현재 기능 테이블 중 **이미 테스트반영일이 기입된 항목은 제외**한다.

> 파일이 없으면 생성한다.

---

## Step 2 — DDL SQL 추출

아래 순서로 DDL을 찾는다:

1. 현재 기능 폴더의 `db.md` 섹션 6 (우선)
2. 없으면 `{기능폴더}/{기능명}_ddl.sql` 파일

섹션별로 분리:
- 시퀀스 SQL
- 테이블 CREATE SQL
- 인덱스 SQL
- 공통코드 INSERT SQL (있는 경우)
- 기존 테이블 컬럼 추가 ALTER SQL (있는 경우)

---

## Step 3 — DB 접속 정보 로드

`src/main/resource/prop/application-dev.properties` 파일에서 파싱:

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
- `db.md` 섹션 6의 **DOWN SQL**을 사용자에게 보여주고 롤백 여부 확인
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

#### 6-a. 변경 이력 업데이트

`DEV_DOC/ai-docs/10-database/01-database-change-history.md`에 테스트반영일 기입:

```markdown
| {테이블명} | {변경 내용} | {YYYY-MM-DD} | - |
```

#### 6-b. 테이블 컬럼 명세 문서 생성/업데이트

경로: `DEV_DOC/ai-docs/10-database/90-schema/20-tables/`

**신규 테이블**: `{테이블명}.md` 신규 생성

**기존 테이블 컬럼 추가**: 기존 `{테이블명}.md` 컬럼 명세 표에 추가된 컬럼 행 삽입

#### 6-c. 공통코드 문서 업데이트

신규 공통코드가 있는 경우 `DEV_DOC/ai-docs/10-database/90-schema/30-data/01-common-code.md` 업데이트

#### 6-d. 시퀀스/테이블/도메인 그룹/DB 개요 문서 업데이트

신규 테이블/시퀀스인 경우 관련 문서 자동 업데이트:
- `DEV_DOC/ai-docs/10-database/10-architecture/07-sequence.md`
- `DEV_DOC/ai-docs/10-database/10-architecture/02-table-list.md`
- `DEV_DOC/ai-docs/10-database/90-schema/10-group/{도메인}-tables.md`
- `DEV_DOC/ai-docs/10-database/00-database-overview.md`

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
- `db.md` 섹션 7 체크리스트에서 해당 항목 체크
- `/PI-be-mapper`로 Mapper 레이어 개발 시작 안내
