#!/usr/bin/env python3
"""
SD_333_WIN 2단계 - psycopg2로 PostgreSQL 에 접속해 DDL .sql 파일 생성.

사용법:
    python 02_extract_ddl.py <고객사명>

입력:  deliverables/30-output/03 설계(SD)/tmp/db_target.json
출력:  deliverables/30-output/03 설계(SD)/SD_333_DB_Schema(DDL)_{고객사명}_{YYMMDD}.sql

옵션:
    --check-only   psycopg2 import 만 검증하고 누락 시 안내 후 종료.

원본 명령: .claude/commands/SD_212_DDL.md (PSQL + pg_catalog 쿼리)
"""

import argparse
import datetime
import json
import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[4]
OUT_DIR = BASE_DIR / "output" / "03 설계(SD)"
TMP_DIR = OUT_DIR / "tmp"
TARGET_FILE = TMP_DIR / "db_target.json"

SAFE_NAME_RE = re.compile(r"[<>:\"|?*\\/]+")


def sanitize_filename(name: str) -> str:
    return SAFE_NAME_RE.sub("_", name).strip() or "고객사"


def check_only():
    try:
        import psycopg2  # noqa: F401
        print("[OK] psycopg2 import 가능")
        sys.exit(0)
    except ImportError:
        print("[MISS] psycopg2 (pip: psycopg2-binary)")
        print()
        print("설치 명령:")
        print("  python -m pip install --user psycopg2-binary")
        sys.exit(1)


# --- pg_catalog 쿼리 -----------------------------------------------------

SEQ_SQL = """
SELECT
    'CREATE SEQUENCE IF NOT EXISTS ' || quote_ident(sequence_name) ||
    E'\\n  INCREMENT BY ' || increment ||
    E'\\n  MINVALUE ' || minimum_value ||
    E'\\n  MAXVALUE ' || maximum_value ||
    E'\\n  START WITH ' || start_value ||
    CASE WHEN cycle_option='YES' THEN E'\\n  CYCLE' ELSE E'\\n  NO CYCLE' END ||
    E';\\n'
FROM information_schema.sequences
WHERE sequence_schema = %s
ORDER BY sequence_name;
"""

TBL_SQL = """
SELECT
    'CREATE TABLE ' || quote_ident(c.relname) || ' (' ||
    string_agg(
        E'\\n    ' || quote_ident(a.attname) || ' ' ||
        pg_catalog.format_type(a.atttypid, a.atttypmod) ||
        CASE WHEN ad.adbin IS NOT NULL
             THEN ' DEFAULT ' || pg_get_expr(ad.adbin, ad.adrelid) ELSE '' END ||
        CASE WHEN a.attnotnull THEN ' NOT NULL' ELSE '' END,
        ','
        ORDER BY a.attnum
    ) ||
    E'\\n);\\n'
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
LEFT JOIN pg_catalog.pg_attrdef ad ON ad.adrelid = c.oid AND ad.adnum = a.attnum
WHERE c.relkind = 'r' AND n.nspname = %s
GROUP BY c.relname, c.oid
ORDER BY c.relname;
"""

PK_SQL = """
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' PRIMARY KEY (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    E');\\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'p' AND ns.nspname = %s
ORDER BY tc.relname, con.conname;
"""

UQ_SQL = """
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' UNIQUE (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    E');\\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'u' AND ns.nspname = %s
ORDER BY tc.relname, con.conname;
"""

FK_SQL = """
SELECT
    'ALTER TABLE ' || quote_ident(tc.relname) ||
    E'\\n    ADD CONSTRAINT ' || quote_ident(con.conname) || ' FOREIGN KEY (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.conkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = tc.oid AND att.attnum = u.k) ||
    ') REFERENCES ' || quote_ident(fc.relname) || ' (' ||
    (SELECT string_agg(quote_ident(att.attname), ', ' ORDER BY u.i)
     FROM unnest(con.confkey) WITH ORDINALITY u(k,i)
     JOIN pg_attribute att ON att.attrelid = fc.oid AND att.attnum = u.k) ||
    ')' ||
    CASE con.confupdtype
        WHEN 'r' THEN ' ON UPDATE RESTRICT'
        WHEN 'c' THEN ' ON UPDATE CASCADE'
        WHEN 'n' THEN ' ON UPDATE SET NULL'
        ELSE '' END ||
    CASE con.confdeltype
        WHEN 'r' THEN ' ON DELETE RESTRICT'
        WHEN 'c' THEN ' ON DELETE CASCADE'
        WHEN 'n' THEN ' ON DELETE SET NULL'
        ELSE '' END ||
    E';\\n'
FROM pg_constraint con
JOIN pg_class tc ON tc.oid = con.conrelid
JOIN pg_class fc ON fc.oid = con.confrelid
JOIN pg_namespace ns ON ns.oid = tc.relnamespace
WHERE con.contype = 'f' AND ns.nspname = %s
ORDER BY tc.relname, con.conname;
"""

IDX_SQL = """
SELECT indexdef || E';\\n'
FROM pg_indexes
WHERE schemaname = %s
  AND indexname NOT IN (
      SELECT con.conname
      FROM pg_constraint con
      JOIN pg_namespace ns ON ns.oid = con.connamespace
      WHERE con.contype IN ('p','u') AND ns.nspname = %s
  )
ORDER BY tablename, indexname;
"""


def run_section(cur, sql, params):
    cur.execute(sql, params)
    rows = cur.fetchall()
    return [r[0] for r in rows if r and r[0] is not None]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("customer", nargs="?", help="고객사명")
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args()

    if args.check_only:
        check_only()

    if not args.customer:
        print("[SD_333_WIN] 고객사명을 인자로 전달해야 합니다.", file=sys.stderr)
        sys.exit(2)

    customer = sanitize_filename(args.customer)

    try:
        import psycopg2
    except ImportError:
        print("[SD_333_WIN] psycopg2 가 설치되지 않았습니다.", file=sys.stderr)
        print("  python -m pip install --user psycopg2-binary", file=sys.stderr)
        sys.exit(1)

    if not TARGET_FILE.exists():
        print(f"[SD_333_WIN] 접속정보 파일이 없습니다: {TARGET_FILE}", file=sys.stderr)
        sys.exit(2)
    target = json.loads(TARGET_FILE.read_text(encoding="utf-8"))

    driver = (target.get("driver") or "").lower()
    if driver != "postgresql":
        print(f"[SD_333_WIN] PostgreSQL 전용 스킬입니다. driver={driver}", file=sys.stderr)
        sys.exit(2)

    host = target.get("host")
    port = int(target.get("port") or 5432)
    database = target.get("database")
    user = target.get("user")
    password = target.get("password")
    schema = target.get("schema") or "public"

    if not (host and database and user):
        print("[SD_333_WIN] host / database / user 가 모두 필요합니다.", file=sys.stderr)
        sys.exit(2)

    print(f"[SD_333_WIN] 접속: postgresql {host}:{port}/{database} (schema={schema}, user={user})")

    try:
        conn = psycopg2.connect(
            host=host, port=port, dbname=database,
            user=user, password=password, connect_timeout=10,
        )
    except Exception as e:
        print(f"[SD_333_WIN] 연결 실패: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version_str = cur.fetchone()[0]
    except Exception as e:
        print(f"[SD_333_WIN] 버전 조회 실패: {e}", file=sys.stderr)
        version_str = "unknown"

    # SQL 본문 누적
    out = []
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    out.append("-- ============================================================")
    out.append(f"-- Database  : {database}")
    out.append(f"-- Server    : {host}:{port}")
    out.append(f"-- Schema    : {schema}")
    out.append(f"-- Customer  : {customer}")
    out.append(f"-- Generated : {now}")
    out.append(f"-- Version   : {version_str}")
    out.append(f"-- Generator : SD_333_WIN (psycopg2 + pg_catalog)")
    out.append("-- ============================================================")
    out.append("")
    out.append("SET statement_timeout = 0;")
    out.append("SET lock_timeout = 0;")
    out.append("SET client_encoding = 'UTF8';")
    out.append("SET standard_conforming_strings = on;")
    out.append("")

    stats = {"SEQUENCE": 0, "TABLE": 0, "PK": 0, "UQ": 0, "FK": 0, "INDEX": 0}

    sections = [
        ("1. SEQUENCES",                "SEQUENCE", SEQ_SQL, (schema,)),
        ("2. TABLES",                   "TABLE",    TBL_SQL, (schema,)),
        ("3. PRIMARY KEY CONSTRAINTS",  "PK",       PK_SQL,  (schema,)),
        ("4. UNIQUE CONSTRAINTS",       "UQ",       UQ_SQL,  (schema,)),
        ("5. FOREIGN KEY CONSTRAINTS",  "FK",       FK_SQL,  (schema,)),
        ("6. INDEXES",                  "INDEX",    IDX_SQL, (schema, schema)),
    ]

    for title, key, sql, params in sections:
        out.append("-- ============================================================")
        out.append(f"-- {title}")
        out.append("-- ============================================================")
        try:
            cur = conn.cursor()
            stmts = run_section(cur, sql, params)
            for s in stmts:
                out.append(s)
            stats[key] = len(stmts)
            print(f"  [{key:8s}] {len(stmts):>5d} 건")
        except Exception as e:
            print(f"[SD_333_WIN] {title} 추출 실패: {e}", file=sys.stderr)
            out.append(f"-- ERROR: {e}")
        out.append("")

    conn.close()

    # 파일 저장
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    yymmdd = datetime.date.today().strftime("%y%m%d")
    out_file = OUT_DIR / f"SD_333_DB_Schema(DDL)_{customer}_{yymmdd}.sql"
    text = "\n".join(out)
    out_file.write_text(text, encoding="utf-8")

    size_kb = round(out_file.stat().st_size / 1024, 1)
    line_count = text.count("\n") + 1

    print()
    print("✓ DB Schema DDL 생성 완료 [SD_333_WIN]")
    print()
    print(f"고객사   : {customer}")
    print(f"DB       : postgresql {host}:{port}/{database} (schema={schema})")
    print(f"Version  : {version_str}")
    print()
    print("DDL 현황:")
    print(f"  - SEQUENCE    : {stats['SEQUENCE']} 건")
    print(f"  - TABLE       : {stats['TABLE']} 건")
    print(f"  - PRIMARY KEY : {stats['PK']} 건")
    print(f"  - UNIQUE      : {stats['UQ']} 건")
    print(f"  - FOREIGN KEY : {stats['FK']} 건")
    print(f"  - INDEX       : {stats['INDEX']} 건")
    print()
    print(f"출력 파일: {out_file}")
    print(f"파일 크기: {size_kb} KB ({line_count} 라인)")


if __name__ == "__main__":
    main()
