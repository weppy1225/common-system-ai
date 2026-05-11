---
name: SD_334
description: 【DB 관계도(ERD) HTML 생성】 사용자가 지정한 디렉토리의 DB 설정 파일을 자동 스캔해 실제 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 직접 접속하고, 시스템 카탈로그에서 테이블·컬럼·FK를 추출하여 vis-network 기반의 인터랙티브 DB 관계도(ERD) HTML 파일을 자동 생성합니다. /SD_334 형식으로 실행하며 디렉토리·고객사명은 실행 시 묻습니다. 산출물은 단일 HTML 파일로 떨어지며 브라우저에서 바로 열어 노드 드래그·줌·검색·계층 레이아웃 토글이 가능합니다. DB 관계도 작성, ERD HTML 생성, 테이블 관계 시각화, 산출물용 DB 관계도 만들기 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "DB 관계도 만들어줘", "ERD 뽑아줘", "테이블 관계 시각화", "DB 다이어그램 HTML로", "SD_334 실행해줘", "관계도 산출물 만들어줘" 라고 말해도 이 스킬을 사용합니다. 단, 사용자가 엑셀 형태의 테이블정의서를 원하면 /SD_331, 정적 ERD 뷰어가 이미 있으면 /SD_211 쪽이 맞을 수 있으니 산출물 형식(HTML 관계도/엑셀/뷰어)을 먼저 확인해 분기합니다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 관계도 HTML 자동 생성 (실 DB 접속) [SD_334]

대상 디렉토리: **$ARGUMENTS**

`$ARGUMENTS` 디렉토리에서 DB 접속 설정 파일을 자동 스캔하고, 검출된 DB(PostgreSQL/MySQL/MariaDB/MSSQL/Oracle)에 **직접 접속**하여 시스템 카탈로그(information_schema/pg_catalog/sys.\*/user_\*)에서 테이블·컬럼·FK를 추출한 뒤,
**vis-network** 기반 인터랙티브 ER 다이어그램 HTML을
`output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html` 파일로 생성한다.

> 같은 DB를 보는 다른 산출물:
> - `/SD_331` — 동일 추출 로직으로 SD.212-테이블정의서 **엑셀** 생성
> - `/SD_211` — 정적 ERD 뷰어 생성
> 이 스킬(`/SD_334`)은 **단일 HTML 파일 하나**로 떨어지며 브라우저에서 바로 열어 노드 드래그·줌·검색·계층 레이아웃 전환이 가능한 인터랙티브 관계도를 만든다.

> **클라이언트 도구 불필요**: psql/mysql/sqlcmd/sqlplus 같은 OS 클라이언트가 설치되지 않은 환경을 가정한다. Python 라이브러리(psycopg2-binary / pymysql / pymssql / oracledb)만으로 직접 접속한다. 라이브러리는 필요할 때 `pip install --user`로 자동 설치한다.

> **CDN 의존**: 결과 HTML은 `vis-network` JS를 jsDelivr CDN에서 로드한다. 오프라인 환경에서 사용해야 한다면 사용자에게 안내한다.

---

## 사전 준비

### 인자 확정

`$ARGUMENTS`가 비어 있으면 사용자에게 디렉토리 경로를 물어본다. 비어 있지 않더라도 경로가 존재하지 않으면 다시 물어본다.

추가로 **고객사명**을 사용자에게 묻는다. 이미 동일 워크스페이스에서 다른 SD/PI 산출물을 만들 때 사용된 이름이 있으면 그것을 기본값으로 제시한다. 고객사명은 출력 파일명(`SD_334_DB관계도_{고객사명}.html`)에 그대로 들어가므로 윈도우 파일명에서 사용 불가능한 문자(`\ / : * ? " < > |`)는 스크립트가 자동으로 `_`로 치환한다.

### 경로 정의

```
BASE       = /mnt/c/zinide/workspace/cloud-wms-doc
OUTPUT_DIR = output/03 설계(SD)
TMP_DIR    = output/03 설계(SD)/tmp
SCRIPTS    = .claude/skills/SD_334/scripts
OUT_FILE   = output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html
```

`OUTPUT_DIR`과 `TMP_DIR`이 없으면 생성한다.

---

## 단계별 워크플로우

각 단계는 Bash로 스크립트를 실행하고, 그 결과 JSON을 다음 단계가 읽는 방식으로 진행된다. 각 단계 완료 후 다음 단계로 진행하기 전에 산출물(`tmp/*.json`)이 존재하는지 확인한다.

> 1·2단계의 스크립트는 `/SD_331`과 동일한 로직(라벨만 `[SD_334]`)이므로, schema 추출 결과 포맷도 SD_331과 동일하다.

---

### 1단계 — 디렉토리 스캔으로 DB 접속정보 후보 추출

**스크립트**: `scripts/01_scan_config.py`

**입력**: 사용자 지정 디렉토리 경로
**출력**: `output/03 설계(SD)/tmp/db_candidates.json`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 .claude/skills/SD_334/scripts/01_scan_config.py "{디렉토리경로}"
```

스크립트는 디렉토리(하위 포함)에서 다음 패턴의 파일을 찾아 DB 접속정보 후보를 모은다.

| 패턴 | 추출 키 |
|---|---|
| `*.env`, `.env*` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DATABASE_URL`, `DB_DRIVER` 등 |
| `application.yml` / `application.yaml` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `application.properties` (Spring) | `spring.datasource.url/username/password/driver-class-name` |
| `database.yml` (Rails) | `adapter`, `host`, `port`, `database`, `username`, `password` |
| `settings.py` (Django) | `DATABASES['default']` |
| `knexfile.js` / `knexfile.ts` | `client`, `connection` |
| `appsettings*.json` (.NET) | `ConnectionStrings.*` |
| `web.config` (.NET) | `<connectionStrings>` |
| `config.json` / `db.config.json` / `database.json` 등 일반 JSON | host/port/database/user/password 키 자동 인식 |
| `docker-compose.yml` / `docker-compose.yaml` | `services.*.environment` (POSTGRES_USER 등) |
| `prisma/schema.prisma` | `datasource db { url = ... }` |

**중복 후보 제거 규칙**: `(driver, host, port, database)` 조합이 동일하면 같은 후보로 간주한다. user/password는 더 풍부한 쪽을 채택한다.

---

### 2단계 — 사용자 확인 및 누락 정보 보강

스크립트가 만든 `db_candidates.json`을 Read 툴로 읽어 후보 목록을 확인한다.

1. **후보가 0개**: AskUserQuestion으로 DB 종류와 접속정보(host, port, database, user, password)를 직접 입력 받아 가상의 후보 1개를 만든다.
2. **후보가 1개**: 사용자에게 해당 정보로 진행할지, password가 누락되었으면 password를 입력할지 묻는다.
3. **후보가 2개 이상**: AskUserQuestion으로 어떤 후보를 사용할지 선택 받는다.

선택된 후보의 password가 비어 있다면 **AskUserQuestion으로 password를 별도 질문한다.**
> 보안: 비밀번호는 화면에 그대로 표시되므로, 사용자가 직접 입력하기 전에 "쉘 히스토리·로그에 남을 수 있다"는 점을 안내한다.

확정된 접속정보를 `output/03 설계(SD)/tmp/db_target.json`로 저장한다.

```json
{
  "driver": "postgresql",
  "host": "localhost",
  "port": 5432,
  "database": "wms_db",
  "user": "wms",
  "password": "...",
  "schema": "public"
}
```

> `driver` 값은 `postgresql` / `mysql` / `mssql` / `oracle` 중 하나로 정규화한다. (`mariadb` → `mysql`, `postgres` → `postgresql`, `sqlserver` / `mssql` 모두 → `mssql`)

> `schema`는 PostgreSQL/MSSQL에서 의미가 있다. 없으면 PostgreSQL은 `public`, MSSQL은 `dbo`, MySQL은 database 자체, Oracle은 사용자명 대문자.

---

### 3단계 — 의존성 확인 및 자동 설치

선택된 driver에 대응하는 Python 라이브러리가 import 가능한지 점검하고, 없으면 자동 설치한다.

| driver | Python 라이브러리 | 설치 명령 |
|---|---|---|
| postgresql | psycopg2 | `python3 -m pip install --user psycopg2-binary` |
| mysql | pymysql | `python3 -m pip install --user pymysql` |
| mssql | pymssql | `python3 -m pip install --user pymssql` |
| oracle | oracledb | `python3 -m pip install --user oracledb` |

> openpyxl 등 엑셀 라이브러리는 이 스킬에서는 필요하지 않다.

자동 점검:

```bash
python3 .claude/skills/SD_334/scripts/02_extract_schema.py --check-only
```

`--check-only`는 import 시도만 수행하고 누락된 라이브러리 목록을 출력한다. 누락된 라이브러리를 `pip install --user`로 설치한 뒤 다시 `--check-only`로 검증한다.

---

### 4단계 — DB 접속 및 스키마 추출

**스크립트**: `scripts/02_extract_schema.py`
**입력**: `output/03 설계(SD)/tmp/db_target.json`
**출력**: `output/03 설계(SD)/tmp/schema.json`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 .claude/skills/SD_334/scripts/02_extract_schema.py
```

스크립트가 driver별로 적절한 카탈로그(`information_schema`, `pg_catalog`, `sys.*`, `user_*`)를 조회해 다음 정보를 수집한다.

- 테이블 목록 (logical/physical name, schema, comment)
- 테이블별 컬럼 (logical/physical name, data type, not null, default, comment)
- 테이블별 인덱스 (이름, 컬럼 목록, **PK 여부**, Unique 여부) — HTML에서 PK 컬럼 마킹에 사용
- 테이블별 **FK 제약조건** — HTML 엣지 생성에 사용
- 테이블별 PK Side FK (참조 받는 쪽)

**관계 추정 정책**: 이 스킬은 **DB에 정의된 FK 제약조건만** 사용해 엣지를 그린다. 컬럼명 기반 휴리스틱 추정은 하지 않는다. FK가 거의 없는 레거시 스키마에서는 관계도가 비어 보일 수 있는데, 이 경우 사용자에게 "DB에 FK 제약이 적어 관계도가 비어 보일 수 있다"고 안내한다.

연결 실패·권한 부족 시 명확한 에러 메시지(시도한 쿼리, 응답 메시지)를 출력하고 종료한다.

---

### 5단계 — 인터랙티브 HTML 생성

**스크립트**: `scripts/03_generate_html.py`
**입력**: `output/03 설계(SD)/tmp/schema.json`, 사용자가 입력한 고객사명
**출력**: `output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html`

```bash
cd /mnt/c/zinide/workspace/cloud-wms-doc && \
python3 .claude/skills/SD_334/scripts/03_generate_html.py "{고객사명}"
```

스크립트가 하는 일:

1. `schema.json`에서 테이블 목록을 읽는다.
2. 각 테이블의 PK 컬럼 집합과 FK 컬럼 집합을 만든다 (PK는 인덱스 `is_pk`로, FK는 `fks[].columns`로).
3. 테이블마다 **vis-network 노드** 1개를 만든다. 노드 라벨은 multi-line 텍스트로 다음과 같이 구성된다.

   ```
   <b>물리테이블명</b>
   <i>논리테이블명</i>
   ──────────────────────────
   🔑   id : BIGINT *
   🔗   customer_id : BIGINT *
        name : VARCHAR(100)
   ```

   - `🔑` PK / `🔗` FK / `*` NOT NULL
4. FK 제약조건마다 **엣지** 1개를 만든다 (`from = 자식 테이블, to = 부모 테이블, 화살표 방향 = to`). 엣지 hover 시 `테이블.(컬럼) → 부모테이블.(부모컬럼)`이 툴팁으로 노출된다.
5. 노드/엣지 데이터를 JSON으로 직렬화해 단일 HTML 템플릿에 삽입한다.
6. 결과 HTML 한 파일로 저장. CDN(`vis-network@9.x`)에서 라이브러리 로드.

#### HTML이 제공하는 인터랙션

- **사이드바 검색**: 물리/논리명으로 즉시 필터링. 클릭하면 해당 노드로 포커싱.
- **드래그 + 줌**: 마우스/휠/터치패드.
- **레이아웃 전환**: 물리 시뮬레이션 / 계층(좌→우) / 계층(위→아래).
- **물리 ON/OFF 토글**: 노드 위치 고정.
- **전체보기 버튼**: 다이어그램 전체가 화면에 들어오도록 fit.
- **범례**: 🔑 PK · 🔗 FK · `*` NOT NULL · 박스=테이블 · 화살표=FK.
- **테이블 통계**: 사이드바 각 항목 아래 "컬럼 N · FK→ N · ←FK N".

#### 파일명 안전 처리

`{고객사명}`에 윈도우 파일명에서 사용 불가능한 문자(`\ / : * ? " < > |`)가 있으면 스크립트가 `_`로 치환한다.

---

### 6단계 — 임시 파일 정리 (필수)

HTML이 정상 생성되어 5단계가 성공한 직후, 비밀번호 노출을 막기 위해 `tmp/` 폴더를 **반드시** 삭제한다.

```bash
rm -rf "/mnt/c/zinide/workspace/cloud-wms-doc/output/03 설계(SD)/tmp"
```

- `tmp/db_target.json`에는 DB 비밀번호가 평문으로 저장되므로 보관하지 않는다.
- 5단계가 실패한 경우(HTML 생성 실패)에는 디버깅을 위해 `tmp/` 폴더를 남겨두고, 사용자에게 원인을 보고한 뒤 작업이 완료되거나 사용자가 포기하는 시점에 동일 명령으로 삭제한다.
- 삭제 결과(성공/실패)를 사용자에게 한 줄로 보고한다.

---

## 완료 체크리스트

- [ ] `$ARGUMENTS` 또는 사용자 입력으로 디렉토리 확정
- [ ] 사용자에게 고객사명 확인
- [ ] `tmp/db_candidates.json` 생성 (스캔 결과)
- [ ] 사용자가 후보 1개 확정 (`tmp/db_target.json` 저장)
- [ ] 누락된 password 확인 후 보강
- [ ] 필요한 Python 라이브러리 import 가능 (`--check-only` 통과)
- [ ] DB 연결 성공 및 `tmp/schema.json` 생성
- [ ] 출력 파일 `output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html` 생성
- [ ] 브라우저에서 열어 노드/엣지가 보이는지(또는 FK가 없으면 노드만이라도 보이는지) 확인 권장
- [ ] **`output/03 설계(SD)/tmp/` 폴더 삭제 완료** (비밀번호 노출 방지)

---

## 완료 보고 형식

```
✓ DB 관계도 HTML 생성 완료 [SD_334]

대상 디렉토리: {디렉토리경로}
고객사:        {고객사명}
DB:            {driver} {host}:{port}/{database} (schema={schema})
출력파일:      output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html

수집 통계:
  - 테이블:     N개
  - 컬럼:       N개
  - FK 엣지:    N개

스캔된 설정 파일: {파일 목록}
임시 파일 정리:   tmp/ 삭제 완료

브라우저에서 위 HTML 파일을 열어 확인하세요. (vis-network는 jsDelivr CDN에서 로드됩니다.)
```

---

## 주의사항

- **비밀번호 노출**: AskUserQuestion으로 받은 비밀번호는 `tmp/db_target.json`에 평문으로 저장된다. **6단계에서 `tmp/` 폴더를 자동 삭제**하므로 별도 안내 없이 정리되지만, 작업이 비정상 종료되어 폴더가 남아 있으면 즉시 수동 삭제한다.
- **FK 없는 스키마**: 레거시·일부 ORM 환경처럼 FK 제약을 설정하지 않은 DB에서는 엣지가 거의 없거나 0개가 된다. 사용자가 의외라 느낄 수 있으므로 완료 보고에 FK 개수를 명시하고, 0개이면 "DB에 FK 제약이 정의되어 있지 않아 관계선이 그려지지 않았다"는 점을 한 줄 보강한다.
- **대형 DB 보호**: 테이블이 200개를 넘으면 vis-network 물리 시뮬레이션이 무거워져 초기 렌더링이 느릴 수 있다. 사용자에게 "처음 열 때 안정화에 몇 초 걸린다"는 점과, 사이드바에서 계층 레이아웃으로 전환하면 빨라진다는 점을 안내한다.
- **CDN 의존**: 결과 HTML은 `https://cdn.jsdelivr.net`에서 vis-network을 로드한다. 폐쇄망 등 인터넷이 차단된 환경에서는 사용자가 별도로 vis-network을 로컬에 두고 `<script src="...">`를 수정해야 한다.
- **라벨에 HTML 태그 직접 입력 금지**: vis-network 노드 라벨은 `<b>`/`<i>`만 지원하며, `<script>` 등 임의 HTML은 의미가 없다. 컬럼 코멘트에 HTML 비슷한 문자가 들어 있으면 그대로 텍스트로 표시된다.
- **권한 부족**: 시스템 카탈로그 조회 권한이 없으면 일부 정보(예: comment, FK)가 누락될 수 있다. 누락되면 빈 값으로 두고 나머지를 채운다.
