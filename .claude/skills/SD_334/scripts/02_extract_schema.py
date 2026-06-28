#!/usr/bin/env python3
"""
SD_334 2단계 - DB 직접 접속하여 스키마 추출.

입력: deliverables/30-output/03 설계(SD)/tmp/db_target.json
출력: deliverables/30-output/03 설계(SD)/tmp/schema.json

driver별 카탈로그 조회로 다음 정보를 수집한다.
- 테이블 (logical/physical name, schema, comment)
- 테이블별 컬럼 (logical/physical name, data type, not null, default, comment)
- 테이블별 인덱스 (이름, 컬럼, PK 여부, Unique)
- 테이블별 제약조건 (이름, 종류, 정의)
- 테이블별 FK
- 테이블별 PK Side FK (이 테이블의 PK를 참조하는 다른 테이블의 FK)

옵션:
  --check-only   필요한 라이브러리만 import 시도 후 누락 출력 (DB 접속 없음)
"""

import json
import os
import sys
import datetime
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[4]
TMP_DIR = BASE_DIR / "deliverables/30-output/03 설계(SD)/tmp"
TARGET_FILE = TMP_DIR / "db_target.json"
SCHEMA_FILE = TMP_DIR / "schema.json"


REQUIRED_LIBS = {
    "postgresql": [("psycopg2", "psycopg2-binary")],
    "mysql": [("pymysql", "pymysql")],
    "mssql": [("pymssql", "pymssql")],
    "oracle": [("oracledb", "oracledb")],
}


def check_libs(driver):
    """driver에 필요한 Python 라이브러리 import 가능 여부 검사."""
    missing = []
    libs = REQUIRED_LIBS.get(driver, [])
    for module_name, pip_name in libs:
        try:
            __import__(module_name)
        except ImportError:
            missing.append({"module": module_name, "pip": pip_name})
    return missing


def cmd_check_only():
    """모든 driver의 라이브러리를 import 시도해서 누락 라이브러리를 출력."""
    print("[SD_334] 라이브러리 import 점검...")
    overall_missing = []
    for driver, libs in REQUIRED_LIBS.items():
        for module_name, pip_name in libs:
            try:
                __import__(module_name)
                print(f"  [OK]   {driver:12s} → {module_name}")
            except ImportError:
                print(f"  [MISS] {driver:12s} → {module_name} (pip: {pip_name})")
                overall_missing.append({"driver": driver, "module": module_name, "pip": pip_name})
    if overall_missing:
        print()
        print("누락된 라이브러리 설치:")
        seen = set()
        for m in overall_missing:
            if m["pip"] in seen:
                continue
            seen.add(m["pip"])
            print(f"  python3 -m pip install --user {m['pip']}")
    else:
        print("\n모든 driver 라이브러리 import OK.")
    sys.exit(0 if not overall_missing else 1)


def load_target():
    if not TARGET_FILE.exists():
        print(f"[SD_334] 접속정보 파일 없음: {TARGET_FILE}", file=sys.stderr)
        sys.exit(2)
    return json.loads(TARGET_FILE.read_text(encoding="utf-8"))


# ---------- driver별 connect ----------

def connect(target):
    driver = target["driver"]
    if driver == "postgresql":
        import psycopg2
        return psycopg2.connect(
            host=target["host"], port=target.get("port") or 5432,
            dbname=target["database"], user=target["user"], password=target["password"],
            connect_timeout=10,
        )
    if driver == "mysql":
        import pymysql
        return pymysql.connect(
            host=target["host"], port=int(target.get("port") or 3306),
            database=target["database"], user=target["user"], password=target["password"],
            charset="utf8mb4", connect_timeout=10,
        )
    if driver == "mssql":
        import pymssql
        return pymssql.connect(
            server=target["host"], port=int(target.get("port") or 1433),
            database=target["database"], user=target["user"], password=target["password"],
            timeout=10, login_timeout=10, charset="UTF-8",
        )
    if driver == "oracle":
        import oracledb
        # thin 모드 (기본)
        dsn = oracledb.makedsn(target["host"], int(target.get("port") or 1521), service_name=target["database"]) \
            if "/" not in (target.get("database") or "") else \
            oracledb.makedsn(target["host"], int(target.get("port") or 1521), sid=target["database"].split("/")[-1])
        return oracledb.connect(user=target["user"], password=target["password"], dsn=dsn)
    raise ValueError(f"지원하지 않는 driver: {driver}")


def fetch_all(cur):
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description] if cur.description else []
    return [dict(zip(cols, row)) for row in rows]


# ---------- PostgreSQL ----------

def extract_postgresql(conn, target):
    schema = target.get("schema") or "public"
    cur = conn.cursor()

    # 테이블 목록
    cur.execute("""
        SELECT t.table_schema AS schema_name,
               t.table_name   AS physical_name,
               COALESCE(obj_description(c.oid), '') AS comment
          FROM information_schema.tables t
          JOIN pg_class c ON c.relname = t.table_name
          JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = t.table_schema
         WHERE t.table_type = 'BASE TABLE'
           AND t.table_schema = %s
         ORDER BY t.table_name
    """, (schema,))
    tables = []
    for r in fetch_all(cur):
        tables.append({
            "schema": r["schema_name"],
            "physical_name": r["physical_name"],
            "logical_name": r["comment"] or r["physical_name"],
            "comment": r["comment"],
            "columns": [], "indexes": [], "constraints": [], "fks": [], "fks_pk_side": [],
        })

    if not tables:
        return tables

    table_names = [t["physical_name"] for t in tables]
    by_name = {t["physical_name"]: t for t in tables}

    # 컬럼
    cur.execute("""
        SELECT c.table_name, c.column_name, c.ordinal_position,
               COALESCE(c.data_type, '') AS data_type,
               c.character_maximum_length AS char_len,
               c.numeric_precision, c.numeric_scale,
               c.is_nullable, c.column_default,
               COALESCE(pgd.description, '') AS comment
          FROM information_schema.columns c
          LEFT JOIN pg_class pc ON pc.relname = c.table_name
          LEFT JOIN pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = c.table_schema
          LEFT JOIN pg_description pgd ON pgd.objoid = pc.oid AND pgd.objsubid = c.ordinal_position
         WHERE c.table_schema = %s
           AND c.table_name = ANY(%s)
         ORDER BY c.table_name, c.ordinal_position
    """, (schema, table_names))
    for r in fetch_all(cur):
        t = by_name.get(r["table_name"])
        if not t:
            continue
        dt = _format_pg_type(r)
        t["columns"].append({
            "ordinal": r["ordinal_position"],
            "physical_name": r["column_name"],
            "logical_name": r["comment"] or r["column_name"],
            "data_type": dt,
            "not_null": r["is_nullable"] == "NO",
            "default": r["column_default"] or "",
            "comment": r["comment"] or "",
        })

    # 인덱스 + PK / Unique
    cur.execute("""
        SELECT t.relname AS table_name,
               i.relname AS index_name,
               ix.indisprimary AS is_pk,
               ix.indisunique  AS is_unique,
               array_to_string(array_agg(a.attname ORDER BY array_position(ix.indkey::int[], a.attnum::int)), ', ') AS column_list
          FROM pg_index ix
          JOIN pg_class i ON i.oid = ix.indexrelid
          JOIN pg_class t ON t.oid = ix.indrelid
          JOIN pg_namespace n ON n.oid = t.relnamespace AND n.nspname = %s
          JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
         WHERE t.relname = ANY(%s)
         GROUP BY t.relname, i.relname, ix.indisprimary, ix.indisunique
         ORDER BY t.relname, i.relname
    """, (schema, table_names))
    for r in fetch_all(cur):
        t = by_name.get(r["table_name"])
        if not t:
            continue
        t["indexes"].append({
            "name": r["index_name"],
            "columns": r["column_list"],
            "is_pk": bool(r["is_pk"]),
            "is_unique": bool(r["is_unique"]),
            "remark": "",
        })

    # 제약조건 (CHECK / PK / UNIQUE)
    cur.execute("""
        SELECT con.conname AS constraint_name,
               cl.relname  AS table_name,
               CASE con.contype
                    WHEN 'p' THEN 'PRIMARY KEY'
                    WHEN 'u' THEN 'UNIQUE'
                    WHEN 'c' THEN 'CHECK'
                    WHEN 'f' THEN 'FOREIGN KEY'
                    ELSE con.contype::text
               END AS constraint_type,
               pg_get_constraintdef(con.oid) AS definition
          FROM pg_constraint con
          JOIN pg_class cl ON cl.oid = con.conrelid
          JOIN pg_namespace n ON n.oid = cl.relnamespace AND n.nspname = %s
         WHERE cl.relname = ANY(%s)
         ORDER BY cl.relname, con.contype, con.conname
    """, (schema, table_names))
    for r in fetch_all(cur):
        t = by_name.get(r["table_name"])
        if not t:
            continue
        t["constraints"].append({
            "name": r["constraint_name"],
            "type": r["constraint_type"],
            "definition": r["definition"],
        })

    # FK (this table → others)
    cur.execute("""
        SELECT con.conname AS fk_name,
               cl.relname  AS table_name,
               array_to_string(array_agg(a.attname ORDER BY array_position(con.conkey, a.attnum::int)), ', ') AS column_list,
               (SELECT n2.nspname || '.' || cl2.relname FROM pg_class cl2 JOIN pg_namespace n2 ON n2.oid = cl2.relnamespace WHERE cl2.oid = con.confrelid) AS ref_table,
               (SELECT array_to_string(array_agg(att.attname ORDER BY array_position(con.confkey, att.attnum::int)), ', ')
                  FROM pg_attribute att WHERE att.attrelid = con.confrelid AND att.attnum = ANY(con.confkey)) AS ref_column_list
          FROM pg_constraint con
          JOIN pg_class cl ON cl.oid = con.conrelid
          JOIN pg_namespace n ON n.oid = cl.relnamespace AND n.nspname = %s
          JOIN pg_attribute a ON a.attrelid = con.conrelid AND a.attnum = ANY(con.conkey)
         WHERE con.contype = 'f'
           AND cl.relname = ANY(%s)
         GROUP BY con.oid, con.conname, cl.relname, con.confrelid, con.confkey
         ORDER BY cl.relname, con.conname
    """, (schema, table_names))
    for r in fetch_all(cur):
        t = by_name.get(r["table_name"])
        if not t:
            continue
        t["fks"].append({
            "name": r["fk_name"],
            "columns": r["column_list"],
            "ref_table": r["ref_table"],
            "ref_columns": r["ref_column_list"],
        })

    # FK (PK Side: 이 테이블을 참조하는 FK들)
    cur.execute("""
        SELECT con.conname AS fk_name,
               cl_src.relname AS src_table,
               array_to_string(array_agg(a.attname ORDER BY array_position(con.conkey, a.attnum::int)), ', ') AS column_list,
               cl_ref.relname AS ref_table,
               (SELECT array_to_string(array_agg(att.attname ORDER BY array_position(con.confkey, att.attnum::int)), ', ')
                  FROM pg_attribute att WHERE att.attrelid = con.confrelid AND att.attnum = ANY(con.confkey)) AS ref_column_list
          FROM pg_constraint con
          JOIN pg_class cl_src ON cl_src.oid = con.conrelid
          JOIN pg_class cl_ref ON cl_ref.oid = con.confrelid
          JOIN pg_namespace n ON n.oid = cl_ref.relnamespace AND n.nspname = %s
          JOIN pg_attribute a ON a.attrelid = con.conrelid AND a.attnum = ANY(con.conkey)
         WHERE con.contype = 'f'
           AND cl_ref.relname = ANY(%s)
         GROUP BY con.oid, con.conname, cl_src.relname, cl_ref.relname, con.confrelid, con.confkey
         ORDER BY cl_ref.relname, con.conname
    """, (schema, table_names))
    for r in fetch_all(cur):
        t = by_name.get(r["ref_table"])
        if not t:
            continue
        t["fks_pk_side"].append({
            "name": r["fk_name"],
            "columns": r["column_list"],
            "ref_table": r["src_table"],
            "ref_columns": r["ref_column_list"],
        })

    cur.close()
    return tables


def _format_pg_type(r):
    base = r.get("data_type", "")
    if r.get("char_len"):
        return f"{base}({r['char_len']})"
    if r.get("numeric_precision"):
        if r.get("numeric_scale"):
            return f"{base}({r['numeric_precision']},{r['numeric_scale']})"
        return f"{base}({r['numeric_precision']})"
    return base


# ---------- MySQL ----------

def extract_mysql(conn, target):
    schema = target["database"]
    cur = conn.cursor()

    cur.execute("""
        SELECT TABLE_NAME, TABLE_COMMENT
          FROM INFORMATION_SCHEMA.TABLES
         WHERE TABLE_SCHEMA = %s AND TABLE_TYPE = 'BASE TABLE'
         ORDER BY TABLE_NAME
    """, (schema,))
    tables = []
    for name, comment in cur.fetchall():
        tables.append({
            "schema": schema,
            "physical_name": name,
            "logical_name": comment or name,
            "comment": comment or "",
            "columns": [], "indexes": [], "constraints": [], "fks": [], "fks_pk_side": [],
        })
    if not tables:
        cur.close()
        return tables

    by_name = {t["physical_name"]: t for t in tables}
    names = list(by_name.keys())
    placeholders = ",".join(["%s"] * len(names))

    # 컬럼
    cur.execute(f"""
        SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE, IS_NULLABLE,
               COLUMN_DEFAULT, COLUMN_COMMENT
          FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = %s AND TABLE_NAME IN ({placeholders})
         ORDER BY TABLE_NAME, ORDINAL_POSITION
    """, (schema, *names))
    for tn, cn, op, ct, isn, cd, cm in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["columns"].append({
            "ordinal": op,
            "physical_name": cn,
            "logical_name": cm or cn,
            "data_type": ct,
            "not_null": isn == "NO",
            "default": cd if cd is not None else "",
            "comment": cm or "",
        })

    # 인덱스
    cur.execute(f"""
        SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE,
               GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR ', ') AS COLS
          FROM INFORMATION_SCHEMA.STATISTICS
         WHERE TABLE_SCHEMA = %s AND TABLE_NAME IN ({placeholders})
         GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE
         ORDER BY TABLE_NAME, INDEX_NAME
    """, (schema, *names))
    for tn, inm, nun, cols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["indexes"].append({
            "name": inm,
            "columns": cols,
            "is_pk": inm == "PRIMARY",
            "is_unique": (nun == 0),
            "remark": "",
        })

    # 제약조건 (PK, UNIQUE, CHECK, FK)
    cur.execute(f"""
        SELECT tc.TABLE_NAME, tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE,
               GROUP_CONCAT(kc.COLUMN_NAME ORDER BY kc.ORDINAL_POSITION SEPARATOR ', ') AS COLS
          FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
          LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kc
                 ON tc.CONSTRAINT_NAME = kc.CONSTRAINT_NAME
                AND tc.TABLE_NAME = kc.TABLE_NAME
                AND tc.TABLE_SCHEMA = kc.TABLE_SCHEMA
         WHERE tc.TABLE_SCHEMA = %s AND tc.TABLE_NAME IN ({placeholders})
         GROUP BY tc.TABLE_NAME, tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE
         ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_TYPE, tc.CONSTRAINT_NAME
    """, (schema, *names))
    for tn, cn, ct, cols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["constraints"].append({
            "name": cn,
            "type": ct,
            "definition": cols or "",
        })

    # FK
    cur.execute(f"""
        SELECT TABLE_NAME, CONSTRAINT_NAME,
               GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') AS COLS,
               REFERENCED_TABLE_SCHEMA, REFERENCED_TABLE_NAME,
               GROUP_CONCAT(REFERENCED_COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') AS REF_COLS
          FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
         WHERE TABLE_SCHEMA = %s AND TABLE_NAME IN ({placeholders})
           AND REFERENCED_TABLE_NAME IS NOT NULL
         GROUP BY TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_SCHEMA, REFERENCED_TABLE_NAME
         ORDER BY TABLE_NAME, CONSTRAINT_NAME
    """, (schema, *names))
    for tn, cn, cols, rs, rt, rcols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["fks"].append({
            "name": cn,
            "columns": cols,
            "ref_table": f"{rs}.{rt}" if rs else rt,
            "ref_columns": rcols,
        })

    # PK Side FK
    cur.execute(f"""
        SELECT REFERENCED_TABLE_NAME, CONSTRAINT_NAME, TABLE_NAME,
               GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') AS COLS,
               GROUP_CONCAT(REFERENCED_COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') AS REF_COLS
          FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
         WHERE REFERENCED_TABLE_SCHEMA = %s
           AND REFERENCED_TABLE_NAME IN ({placeholders})
         GROUP BY REFERENCED_TABLE_NAME, CONSTRAINT_NAME, TABLE_NAME
         ORDER BY REFERENCED_TABLE_NAME, CONSTRAINT_NAME
    """, (schema, *names))
    for ref_t, cn, src_t, cols, rcols in cur.fetchall():
        t = by_name.get(ref_t)
        if not t:
            continue
        t["fks_pk_side"].append({
            "name": cn,
            "columns": cols,
            "ref_table": src_t,
            "ref_columns": rcols,
        })

    cur.close()
    return tables


# ---------- MSSQL ----------

def extract_mssql(conn, target):
    schema = target.get("schema") or "dbo"
    cur = conn.cursor()

    cur.execute("""
        SELECT s.name AS schema_name,
               t.name AS table_name,
               ISNULL(ep.value, '') AS comment
          FROM sys.tables t
          JOIN sys.schemas s ON s.schema_id = t.schema_id
     LEFT JOIN sys.extended_properties ep
            ON ep.major_id = t.object_id AND ep.minor_id = 0
           AND ep.name = 'MS_Description'
         WHERE s.name = %s
         ORDER BY t.name
    """, (schema,))
    tables = []
    for sn, tn, cm in cur.fetchall():
        tables.append({
            "schema": sn,
            "physical_name": tn,
            "logical_name": cm or tn,
            "comment": cm or "",
            "columns": [], "indexes": [], "constraints": [], "fks": [], "fks_pk_side": [],
        })
    if not tables:
        cur.close()
        return tables

    by_name = {t["physical_name"]: t for t in tables}
    names = list(by_name.keys())
    placeholders = ",".join(["%s"] * len(names))

    # 컬럼
    cur.execute(f"""
        SELECT t.name AS table_name, c.column_id, c.name AS column_name,
               TYPE_NAME(c.user_type_id) AS data_type,
               c.max_length, c.precision, c.scale, c.is_nullable,
               OBJECT_DEFINITION(c.default_object_id) AS default_def,
               ISNULL(ep.value, '') AS comment
          FROM sys.tables t
          JOIN sys.schemas s ON s.schema_id = t.schema_id
          JOIN sys.columns c ON c.object_id = t.object_id
     LEFT JOIN sys.extended_properties ep
            ON ep.major_id = t.object_id AND ep.minor_id = c.column_id
           AND ep.name = 'MS_Description'
         WHERE s.name = %s AND t.name IN ({placeholders})
         ORDER BY t.name, c.column_id
    """, (schema, *names))
    for tn, oid, cn, dt, ml, pr, sc, isn, dd, cm in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        type_str = _format_mssql_type(dt, ml, pr, sc)
        t["columns"].append({
            "ordinal": oid,
            "physical_name": cn,
            "logical_name": cm or cn,
            "data_type": type_str,
            "not_null": not bool(isn),
            "default": dd or "",
            "comment": cm or "",
        })

    # 인덱스
    cur.execute(f"""
        SELECT t.name AS table_name, i.name AS index_name, i.is_primary_key, i.is_unique,
               STUFF((
                   SELECT ', ' + c.name
                     FROM sys.index_columns ic
                     JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                    WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
                    ORDER BY ic.key_ordinal
                    FOR XML PATH('')
               ), 1, 2, '') AS column_list
          FROM sys.indexes i
          JOIN sys.tables t ON t.object_id = i.object_id
          JOIN sys.schemas s ON s.schema_id = t.schema_id
         WHERE i.type_desc IN ('CLUSTERED','NONCLUSTERED','UNIQUE','UNIQUE CLUSTERED')
           AND s.name = %s AND t.name IN ({placeholders})
         ORDER BY t.name, i.name
    """, (schema, *names))
    for tn, inm, ispk, isuniq, cols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["indexes"].append({
            "name": inm or "",
            "columns": cols or "",
            "is_pk": bool(ispk),
            "is_unique": bool(isuniq),
            "remark": "",
        })

    # 제약조건
    cur.execute(f"""
        SELECT t.name AS table_name, kc.name AS constraint_name, kc.type_desc AS type_desc, NULL AS def_text
          FROM sys.key_constraints kc
          JOIN sys.tables t ON t.object_id = kc.parent_object_id
          JOIN sys.schemas s ON s.schema_id = t.schema_id
         WHERE s.name = %s AND t.name IN ({placeholders})
        UNION ALL
        SELECT t.name AS table_name, ck.name AS constraint_name, 'CHECK' AS type_desc, ck.definition AS def_text
          FROM sys.check_constraints ck
          JOIN sys.tables t ON t.object_id = ck.parent_object_id
          JOIN sys.schemas s ON s.schema_id = t.schema_id
         WHERE s.name = %s AND t.name IN ({placeholders})
    """, (schema, *names, schema, *names))
    for tn, cn, td, dd in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["constraints"].append({
            "name": cn,
            "type": td,
            "definition": dd or "",
        })

    # FK
    cur.execute(f"""
        SELECT t.name AS table_name, fk.name AS fk_name,
               STUFF((
                   SELECT ', ' + c.name
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
                    WHERE fkc.constraint_object_id = fk.object_id
                    ORDER BY fkc.constraint_column_id
                    FOR XML PATH('')
               ), 1, 2, '') AS column_list,
               (s2.name + '.' + rt.name) AS ref_table,
               STUFF((
                   SELECT ', ' + rc.name
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
                    WHERE fkc.constraint_object_id = fk.object_id
                    ORDER BY fkc.constraint_column_id
                    FOR XML PATH('')
               ), 1, 2, '') AS ref_column_list
          FROM sys.foreign_keys fk
          JOIN sys.tables t ON t.object_id = fk.parent_object_id
          JOIN sys.schemas s ON s.schema_id = t.schema_id
          JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
          JOIN sys.schemas s2 ON s2.schema_id = rt.schema_id
         WHERE s.name = %s AND t.name IN ({placeholders})
         ORDER BY t.name, fk.name
    """, (schema, *names))
    for tn, fnm, cols, rt, rcols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["fks"].append({
            "name": fnm or "",
            "columns": cols or "",
            "ref_table": rt or "",
            "ref_columns": rcols or "",
        })

    # PK Side FK
    cur.execute(f"""
        SELECT rt.name AS ref_table, fk.name AS fk_name, t.name AS src_table,
               STUFF((
                   SELECT ', ' + c.name
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
                    WHERE fkc.constraint_object_id = fk.object_id
                    ORDER BY fkc.constraint_column_id
                    FOR XML PATH('')
               ), 1, 2, '') AS column_list,
               STUFF((
                   SELECT ', ' + rc.name
                     FROM sys.foreign_key_columns fkc
                     JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
                    WHERE fkc.constraint_object_id = fk.object_id
                    ORDER BY fkc.constraint_column_id
                    FOR XML PATH('')
               ), 1, 2, '') AS ref_column_list
          FROM sys.foreign_keys fk
          JOIN sys.tables t ON t.object_id = fk.parent_object_id
          JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
          JOIN sys.schemas s ON s.schema_id = rt.schema_id
         WHERE s.name = %s AND rt.name IN ({placeholders})
         ORDER BY rt.name, fk.name
    """, (schema, *names))
    for rtn, fnm, stn, cols, rcols in cur.fetchall():
        t = by_name.get(rtn)
        if not t:
            continue
        t["fks_pk_side"].append({
            "name": fnm or "",
            "columns": cols or "",
            "ref_table": stn or "",
            "ref_columns": rcols or "",
        })

    cur.close()
    return tables


def _format_mssql_type(name, max_len, prec, scale):
    if not name:
        return ""
    n = name.lower()
    if n in ("nvarchar", "nchar"):
        # nvarchar는 max_len이 byte 단위. char 단위로 환산.
        if max_len == -1:
            return f"{name}(max)"
        return f"{name}({max_len // 2})"
    if n in ("varchar", "char", "varbinary", "binary"):
        if max_len == -1:
            return f"{name}(max)"
        return f"{name}({max_len})"
    if n in ("decimal", "numeric"):
        return f"{name}({prec},{scale})"
    if n in ("float",) and prec:
        return f"{name}({prec})"
    return name


# ---------- Oracle ----------

def extract_oracle(conn, target):
    owner = (target.get("schema") or target.get("user") or "").upper()
    cur = conn.cursor()

    cur.execute("""
        SELECT t.table_name, NVL(tc.comments, '') AS comments
          FROM all_tables t
     LEFT JOIN all_tab_comments tc
            ON tc.owner = t.owner AND tc.table_name = t.table_name AND tc.table_type = 'TABLE'
         WHERE t.owner = :owner
         ORDER BY t.table_name
    """, owner=owner)
    tables = []
    for tn, cm in cur.fetchall():
        tables.append({
            "schema": owner,
            "physical_name": tn,
            "logical_name": cm or tn,
            "comment": cm or "",
            "columns": [], "indexes": [], "constraints": [], "fks": [], "fks_pk_side": [],
        })
    if not tables:
        cur.close()
        return tables

    by_name = {t["physical_name"]: t for t in tables}
    names = list(by_name.keys())

    # 컬럼
    cur.execute("""
        SELECT c.table_name, c.column_id, c.column_name, c.data_type,
               c.data_length, c.data_precision, c.data_scale, c.nullable, c.data_default,
               NVL(cc.comments, '') AS comments
          FROM all_tab_columns c
     LEFT JOIN all_col_comments cc
            ON cc.owner = c.owner AND cc.table_name = c.table_name AND cc.column_name = c.column_name
         WHERE c.owner = :owner
         ORDER BY c.table_name, c.column_id
    """, owner=owner)
    for tn, oid, cn, dt, dl, dp, ds, nullable, dd, cm in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        type_str = _format_oracle_type(dt, dl, dp, ds)
        # data_default는 LONG 타입이라 oracledb가 자동 처리해주지만 string 처리
        default = ""
        if dd is not None:
            try:
                default = str(dd).strip()
            except Exception:
                default = ""
        t["columns"].append({
            "ordinal": oid,
            "physical_name": cn,
            "logical_name": cm or cn,
            "data_type": type_str,
            "not_null": nullable == "N",
            "default": default,
            "comment": cm or "",
        })

    # 인덱스
    cur.execute("""
        SELECT i.table_name, i.index_name, i.uniqueness,
               LISTAGG(ic.column_name, ', ') WITHIN GROUP (ORDER BY ic.column_position) AS column_list
          FROM all_indexes i
          JOIN all_ind_columns ic
            ON ic.index_owner = i.owner AND ic.index_name = i.index_name
         WHERE i.owner = :owner
         GROUP BY i.table_name, i.index_name, i.uniqueness
         ORDER BY i.table_name, i.index_name
    """, owner=owner)
    pk_index_names = set()
    for tn, inm, uniq, cols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["indexes"].append({
            "name": inm,
            "columns": cols,
            "is_pk": False,
            "is_unique": uniq == "UNIQUE",
            "remark": "",
        })

    # PK / UQ 제약조건으로 인덱스의 is_pk 보정
    cur.execute("""
        SELECT c.table_name, c.constraint_name, c.constraint_type, c.search_condition,
               LISTAGG(cc.column_name, ', ') WITHIN GROUP (ORDER BY cc.position) AS column_list,
               c.r_constraint_name
          FROM all_constraints c
     LEFT JOIN all_cons_columns cc
            ON cc.owner = c.owner AND cc.constraint_name = c.constraint_name
         WHERE c.owner = :owner
         GROUP BY c.table_name, c.constraint_name, c.constraint_type, c.search_condition, c.r_constraint_name
         ORDER BY c.table_name, c.constraint_type, c.constraint_name
    """, owner=owner)
    pk_by_table = {}
    constraints_rows = cur.fetchall()
    for tn, cn, ct, sc, cols, rcn in constraints_rows:
        t = by_name.get(tn)
        if not t:
            continue
        type_map = {"P": "PRIMARY KEY", "U": "UNIQUE", "C": "CHECK", "R": "FOREIGN KEY"}
        type_name = type_map.get(ct, ct)
        if ct == "P":
            pk_by_table[tn] = cn
        if ct == "R":
            continue  # FK는 별도 쿼리로 처리
        defn = ""
        if ct == "C" and sc:
            defn = str(sc)
        elif cols:
            defn = cols
        t["constraints"].append({
            "name": cn,
            "type": type_name,
            "definition": defn,
        })

    # 인덱스의 is_pk 보정: 제약조건 이름으로 매칭
    for t in tables:
        pk_name = pk_by_table.get(t["physical_name"])
        if pk_name:
            for idx in t["indexes"]:
                if idx["name"] == pk_name:
                    idx["is_pk"] = True

    # FK (this → others)
    cur.execute("""
        SELECT c.table_name, c.constraint_name,
               LISTAGG(cc.column_name, ', ') WITHIN GROUP (ORDER BY cc.position) AS column_list,
               r.table_name AS ref_table,
               LISTAGG(rc.column_name, ', ') WITHIN GROUP (ORDER BY rc.position) AS ref_column_list
          FROM all_constraints c
     LEFT JOIN all_cons_columns cc
            ON cc.owner = c.owner AND cc.constraint_name = c.constraint_name
     LEFT JOIN all_constraints r
            ON r.owner = c.r_owner AND r.constraint_name = c.r_constraint_name
     LEFT JOIN all_cons_columns rc
            ON rc.owner = r.owner AND rc.constraint_name = r.constraint_name
         WHERE c.owner = :owner AND c.constraint_type = 'R'
         GROUP BY c.table_name, c.constraint_name, r.table_name
         ORDER BY c.table_name, c.constraint_name
    """, owner=owner)
    for tn, cn, cols, rt, rcols in cur.fetchall():
        t = by_name.get(tn)
        if not t:
            continue
        t["fks"].append({
            "name": cn,
            "columns": cols or "",
            "ref_table": rt or "",
            "ref_columns": rcols or "",
        })

    # PK Side FK
    cur.execute("""
        SELECT r.table_name AS ref_table, c.constraint_name, c.table_name AS src_table,
               LISTAGG(cc.column_name, ', ') WITHIN GROUP (ORDER BY cc.position) AS column_list,
               LISTAGG(rc.column_name, ', ') WITHIN GROUP (ORDER BY rc.position) AS ref_column_list
          FROM all_constraints c
          JOIN all_constraints r
            ON r.owner = c.r_owner AND r.constraint_name = c.r_constraint_name
     LEFT JOIN all_cons_columns cc
            ON cc.owner = c.owner AND cc.constraint_name = c.constraint_name
     LEFT JOIN all_cons_columns rc
            ON rc.owner = r.owner AND rc.constraint_name = r.constraint_name
         WHERE r.owner = :owner AND c.constraint_type = 'R'
         GROUP BY r.table_name, c.constraint_name, c.table_name
         ORDER BY r.table_name, c.constraint_name
    """, owner=owner)
    for rtn, cn, stn, cols, rcols in cur.fetchall():
        t = by_name.get(rtn)
        if not t:
            continue
        t["fks_pk_side"].append({
            "name": cn,
            "columns": cols or "",
            "ref_table": stn or "",
            "ref_columns": rcols or "",
        })

    cur.close()
    return tables


def _format_oracle_type(name, dl, dp, ds):
    if not name:
        return ""
    n = name.upper()
    if n in ("VARCHAR2", "NVARCHAR2", "VARCHAR", "CHAR", "NCHAR", "RAW"):
        return f"{name}({dl})"
    if n == "NUMBER":
        if dp is not None and ds is not None and ds > 0:
            return f"NUMBER({dp},{ds})"
        if dp is not None:
            return f"NUMBER({dp})"
        return "NUMBER"
    if n in ("DATE", "TIMESTAMP", "CLOB", "BLOB"):
        return name
    return name


# ---------- 메인 ----------

EXTRACTORS = {
    "postgresql": extract_postgresql,
    "mysql": extract_mysql,
    "mssql": extract_mssql,
    "oracle": extract_oracle,
}


def main():
    args = sys.argv[1:]
    if "--check-only" in args:
        cmd_check_only()

    target = load_target()
    driver = target.get("driver")
    if driver not in EXTRACTORS:
        print(f"[SD_334] 지원하지 않는 driver: {driver}", file=sys.stderr)
        sys.exit(2)

    missing = check_libs(driver)
    if missing:
        print(f"[SD_334] 라이브러리 누락:", file=sys.stderr)
        for m in missing:
            print(f"  - {m['module']} (pip: {m['pip']})", file=sys.stderr)
        print(f"\n설치 후 재시도: python3 -m pip install --user " + " ".join(m['pip'] for m in missing), file=sys.stderr)
        sys.exit(2)

    print(f"[SD_334] DB 연결 시도: {driver} {target.get('host')}:{target.get('port')}/{target.get('database')}")
    try:
        conn = connect(target)
    except Exception as e:
        print(f"[SD_334] 연결 실패: {e}", file=sys.stderr)
        sys.exit(3)

    try:
        extractor = EXTRACTORS[driver]
        tables = extractor(conn, target)
    except Exception as e:
        print(f"[SD_334] 스키마 추출 중 오류: {e}", file=sys.stderr)
        raise
    finally:
        try:
            conn.close()
        except Exception:
            pass

    payload = {
        "extracted_at": datetime.datetime.now().isoformat(timespec="seconds"),
        "db": {
            "driver": driver,
            "host": target.get("host"),
            "port": target.get("port"),
            "database": target.get("database"),
            "schema": target.get("schema"),
        },
        "tables": tables,
    }

    TMP_DIR.mkdir(parents=True, exist_ok=True)
    SCHEMA_FILE.write_text(json.dumps(payload, ensure_ascii=False, indent=2, default=str), encoding="utf-8")

    print(f"[SD_334] 추출 완료: {SCHEMA_FILE}")
    print(f"  테이블: {len(tables)}개")
    total_cols = sum(len(t["columns"]) for t in tables)
    total_idx = sum(len(t["indexes"]) for t in tables)
    total_con = sum(len(t["constraints"]) for t in tables)
    total_fk = sum(len(t["fks"]) for t in tables)
    print(f"  컬럼: {total_cols}개, 인덱스: {total_idx}개, 제약조건: {total_con}개, FK: {total_fk}개")


if __name__ == "__main__":
    main()
