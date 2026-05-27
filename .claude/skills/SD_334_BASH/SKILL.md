---
name: SD_334_BASH
description: 【DB 관계도(ERD) HTML 생성 (WSL/Linux/Mac · 실DB)】 WSL·Linux·macOS(Bash) 환경에서 사용자가 지정한 백엔드 디렉토리의 `application-test.properties` 를 자동 탐색하여 PostgreSQL DB 접속정보를 파싱하고, `psql` (Linux 클라이언트) 또는 `psycopg2` 로 `pg_catalog` 에 직접 접속해 테이블·컬럼·FK를 추출한 뒤, 기존 `output/03 설계(SD)/SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용하여 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한 ERD 뷰어 HTML 파일을 생성한다. /SD_334_BASH 형식으로 실행하며 BE 경로·업체명은 실행 시 묻는다. 산출물은 `output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html` 단일 HTML 파일로 떨어지며 브라우저에서 바로 열어 노드 드래그·줌·검색·계층 레이아웃 토글이 가능하다. DB 관계도 작성, ERD HTML 생성·갱신, 테이블 관계 시각화, 산출물용 ERD 뷰어 만들기 요청 시 반드시 이 스킬을 사용한다. 사용자가 "DB 관계도 만들어줘", "ERD 뽑아줘", "ERD 갱신해줘", "SD_334_BASH 실행해줘" 라고 말해도 이 스킬을 사용한다. 단, 엑셀 형태의 테이블정의서가 필요하면 /SD_331_BASH 를 사용한다. Windows 환경에서는 기본 SD_334 스킬을 사용한다.
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# DB 관계도(ERD) HTML 자동 생성 (WSL/Linux/Mac · 실DB) [SD_334_BASH]

`{BE경로}/src/main/resource/prop/application-test.properties` 에서 PostgreSQL 접속정보를 파싱하고,
`psql` (Linux 클라이언트) 또는 `python3 + psycopg2` 로 `pg_catalog` 를 조회하여 테이블·컬럼·FK 데이터를 추출한 뒤,
기존 `output/03 설계(SD)/SD.211-ERD_*.html` 최신 파일을 템플릿으로 재사용해서
`output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html` ERD 뷰어 파일을 생성(또는 갱신)한다.

> **재사용 방식**: 기존 HTML 파일의 `const TABLES=[...]` 와 `const FKS=[...]` 두 섹션만 DB 최신 상태로 교체한다. 뷰어 코드(CSS·JS 함수·SVG 마커·`SUBGROUP_DEF`·`MAPPING_TBLS`)는 템플릿에서 그대로 유지된다.

> **WSL/Linux/macOS 전용**: Bash에서 직접 `psql` 또는 `python3` 을 호출한다.

---

## 사전 준비

### 인자 확정

1. **BE 경로** — 사용자에게 백엔드 프로젝트 루트를 묻는다. 예: `/mnt/c/zinide/workspace/wms-bnk-be`
2. **업체명** — 출력 파일명에 들어가는 식별자.

### 경로 정의 (동적)

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$DOC_ROOT")
REPO_NAME=$(basename "$DOC_ROOT")
if [[ "$REPO_NAME" =~ ^wms-(.+)-doc$ ]]; then PROJ_CODE="${BASH_REMATCH[1]}"; else PROJ_CODE="cloud"; fi
BE_ROOT="$WORKSPACE/wms-${PROJ_CODE}-be"

OUTPUT_DIR="$DOC_ROOT/output/03 설계(SD)"
```

---

## 실행 절차

### 1단계 — DB 접속정보 파싱

```bash
PROP_FILE="${BE_PATH}/src/main/resource/prop/application-test.properties"
if [ ! -f "$PROP_FILE" ]; then echo "DB 설정 파일 없음: $PROP_FILE"; exit 1; fi

DB_URL=$(grep -m1 'db\.url' "$PROP_FILE" | cut -d'=' -f2- | sed 's/jdbc:log4jdbc://; s/jdbc://')
DB_HOST=$(echo "$DB_URL" | grep -oP '(?<=postgresql://)([^:/]+)' )
DB_PORT=$(echo "$DB_URL" | grep -oP '(?<=:)(\d+)(?=/)' | head -1)
DB_NAME=$(echo "$DB_URL" | grep -oP '(?<=/)[^/?]+' | head -1)
DB_USER=$(grep -m1 'db\.username' "$PROP_FILE" | cut -d'=' -f2-)
DB_PASS=$(grep -m1 'db\.password' "$PROP_FILE" | cut -d'=' -f2-)
```

### 2단계 — TABLES / FKS 추출

`psql` 이 있는 경우 직접 사용, 없으면 `python3 + psycopg2` 로 폴백한다.

**psql 방식:**

```bash
export PGPASSWORD="$DB_PASS"
PSQL_CMD="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -A"

TABLES_JS=$($PSQL_CMD -c "
SELECT '{\"id\":\"' || c.relname || '\",\"phys\":\"' || c.relname || '\",\"logi\":\"' ||
  replace(replace(COALESCE(d.description, c.relname), chr(10), ' '), '\"', '\\\"') ||
  '\",\"grp\":\"' ||
  CASE
    WHEN c.relname LIKE 'wms_%' THEN 'wms'
    WHEN c.relname LIKE 'mdm_%' THEN 'mdm'
    WHEN c.relname LIKE 'sm_%'  THEN 'sm'
    WHEN c.relname LIKE 'sif_%' THEN 'sif'
    WHEN c.relname LIKE 'wes_%' THEN 'wes'
    ELSE 'sm'
  END || '\",\"x\":0,\"y\":0,\"cols\":[' ||
  (SELECT string_agg(
    '{\"pkfk\":\"' ||
    CASE
      WHEN EXISTS(SELECT 1 FROM pg_constraint pk WHERE pk.conrelid=c.oid AND pk.contype='p' AND a.attnum=ANY(pk.conkey))
       AND EXISTS(SELECT 1 FROM pg_constraint fk WHERE fk.conrelid=c.oid AND fk.contype='f' AND a.attnum=ANY(fk.conkey))
      THEN 'PK FK'
      WHEN EXISTS(SELECT 1 FROM pg_constraint pk WHERE pk.conrelid=c.oid AND pk.contype='p' AND a.attnum=ANY(pk.conkey))
      THEN 'PK'
      WHEN EXISTS(SELECT 1 FROM pg_constraint fk WHERE fk.conrelid=c.oid AND fk.contype='f' AND a.attnum=ANY(fk.conkey))
      THEN 'FK'
      ELSE ''
    END ||
    '\",\"phys\":\"' || a.attname ||
    '\",\"type\":\"' || pg_catalog.format_type(a.atttypid, a.atttypmod) ||
    '\",\"nn\":\"'   || CASE WHEN a.attnotnull THEN 'N' ELSE 'Y' END ||
    '\",\"logi\":\"' || replace(replace(COALESCE(d2.description, a.attname), chr(10), ' '), '\"', '\\\"') ||
    '\"}',
    ',' ORDER BY a.attnum
  )
  FROM pg_attribute a
  LEFT JOIN pg_description d2 ON d2.objoid = c.oid AND d2.objsubid = a.attnum
  WHERE a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
  ) || ']}'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_description d ON d.objoid = c.oid AND d.objsubid = 0
WHERE c.relkind = 'r' AND n.nspname = 'public'
ORDER BY c.relname;" | grep -v '^$')

FKS_JS=$($PSQL_CMD -c "
SELECT '{\"ft\":\"' || tc.relname ||
  '\",\"fc\":\"' || a_from.attname ||
  '\",\"tt\":\"' || pc.relname ||
  '\",\"tc\":\"' || a_to.attname || '\"}'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_class pc ON pc.oid = con.confrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
JOIN LATERAL unnest(con.conkey, con.confkey) AS u(fk_col, pk_col) ON true
JOIN pg_attribute a_from ON a_from.attrelid = tc.oid AND a_from.attnum = u.fk_col
JOIN pg_attribute a_to   ON a_to.attrelid   = pc.oid AND a_to.attnum   = u.pk_col
WHERE con.contype = 'f' AND ns.nspname = 'public'
ORDER BY tc.relname, con.conname, u.fk_col;" | grep -v '^$')
```

### 3단계 — 템플릿 로드 및 교체

```bash
DOC_ROOT=$(git rev-parse --show-toplevel)
OUTPUT_DIR="$DOC_ROOT/output/03 설계(SD)"
YYMMDD=$(date '+%y%m%d')
SAFE_NAME=$(echo "$업체명" | tr '\\/:*?"<>|' '_')
OUT_FILE="$OUTPUT_DIR/SD.211-ERD_${SAFE_NAME}_${YYMMDD}.html"

# 최신 ERD 파일을 템플릿으로 사용
TEMPLATE=$(ls -t "$OUTPUT_DIR"/SD.211-ERD_*.html 2>/dev/null | head -1)
if [ -z "$TEMPLATE" ]; then echo "ERD 템플릿 파일 없음. output/03 설계(SD)/SD.211-ERD_*.html 파일이 최소 1개 필요합니다."; exit 1; fi

HTML=$(cat "$TEMPLATE")

# Python으로 교체 (문자열 포함 특수문자 처리를 위해)
python3 - <<PYEOF
import re, sys

html = open("$TEMPLATE", encoding='utf-8').read()
tables_js = 'const TABLES=[' + ','.join("""${TABLES_JS}""".strip().split('\n')) + '];'
fks_js    = 'const FKS=['    + ','.join("""${FKS_JS}""".strip().split('\n'))    + '];'

# TABLES 교체
start = html.index('const TABLES=[')
end   = html.index('];', start) + 2
html  = html[:start] + tables_js + html[end:]

# FKS 교체
start = html.index('const FKS=[')
end   = html.index('];', start) + 2
html  = html[:start] + fks_js + html[end:]

# 제목 교체
html = re.sub(r'<title>ERD - [^<]+</title>', '<title>ERD - $SAFE_NAME WMS ($YYMMDD)</title>', html)
html = re.sub(r'ERD Viewer · [^<]+', 'ERD Viewer · $SAFE_NAME WMS', html)

with open("$OUT_FILE", 'w', encoding='utf-8') as f:
    f.write(html)

print(f"출력: $OUT_FILE")
PYEOF
```

---

## 완료 체크리스트

- [ ] BE 경로 확정 및 `application-test.properties` 존재 확인
- [ ] DB 접속정보 파싱 완료 (host / port / dbname / user)
- [ ] DB 연결 성공 (`psql` 또는 `psycopg2`)
- [ ] TABLES 추출 완료
- [ ] FKS 추출 완료
- [ ] 템플릿 파일 확인 (`SD.211-ERD_*.html` 최신 파일 존재)
- [ ] `const TABLES=[...]` 교체 완료
- [ ] `const FKS=[...]` 교체 완료
- [ ] 제목·헤더 업체명 교체 완료
- [ ] 출력 파일 경로·파일명 규칙 준수

---

## 완료 보고 형식

```
✓ ERD 뷰어 생성 완료 [SD_334_BASH]

업체명  : {업체명}
DB      : {host}:{port}/{dbname}
템플릿  : SD.211-ERD_{이전업체}_{이전날짜}.html
출력파일: output/03 설계(SD)/SD.211-ERD_{업체명}_{YYMMDD}.html
파일크기: {N} KB

데이터 현황:
  - 테이블 : N 건
  - FK 관계 : N 건
```
