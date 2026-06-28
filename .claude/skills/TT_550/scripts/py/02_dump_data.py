#!/usr/bin/env python3
"""
TT_550 5단계 (PYTHON 모드) - psycopg2 로 SELECT 후 INSERT SQL 직렬화.

사용법:
    python 02_dump_data.py <db_target.json> <markers.json> <selected_groups.json> <output_dir> [고객사명]

출력: <output_dir>/{group_key}.sql (선택된 그룹마다)
      <output_dir>/tmp/dump_results.json (manifest 작성용 메타)
"""

import json
import sys
import datetime
import decimal
from pathlib import Path

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    print("ERROR: psycopg2 가 설치되어 있지 않습니다.", file=sys.stderr)
    sys.exit(2)


def escape_sql_string(s: str) -> str:
    return s.replace("'", "''")


def serialize_value(v, col_type: str) -> str:
    """Python 값 → SQL 리터럴 텍스트. col_type 은 information_schema.data_type."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int,)):
        return str(v)
    if isinstance(v, (float, decimal.Decimal)):
        return str(v)
    if isinstance(v, (bytes, bytearray, memoryview)):
        b = bytes(v)
        return f"'\\x{b.hex()}'::bytea"
    if isinstance(v, datetime.datetime):
        s = v.isoformat(sep=" ")
        return f"'{s}'::" + ("timestamptz" if v.tzinfo is not None else "timestamp")
    if isinstance(v, datetime.date):
        return f"'{v.isoformat()}'::date"
    if isinstance(v, datetime.time):
        return f"'{v.isoformat()}'::time"
    if isinstance(v, (dict, list)):
        s = json.dumps(v, ensure_ascii=False, default=str)
        cast = "::jsonb" if "json" in (col_type or "").lower() else "::json"
        return f"'{escape_sql_string(s)}'{cast}"
    if isinstance(v, str):
        # uuid/text/varchar 모두 텍스트로 처리. PostgreSQL 이 자동 캐스팅.
        return f"'{escape_sql_string(v)}'"
    # 기타: str() 후 안전하게
    return f"'{escape_sql_string(str(v))}'"


def main():
    if len(sys.argv) < 5:
        print("usage: 02_dump_data.py <db_target.json> <markers.json> <selected_groups.json> <output_dir> [customer]",
              file=sys.stderr)
        sys.exit(2)

    db = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    markers = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
    selected = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))
    output_dir = Path(sys.argv[4])
    customer = sys.argv[5] if len(sys.argv) > 5 else ""

    output_dir.mkdir(parents=True, exist_ok=True)
    schema = db.get("schema") or "public"

    selected_keys = set(selected.get("groups", []))
    target_groups = [g for g in markers["groups"] if g["group_key"] in selected_keys]
    if not target_groups:
        print("ERROR: 선택된 그룹이 없습니다.", file=sys.stderr)
        sys.exit(2)

    try:
        conn = psycopg2.connect(
            host=db["host"], port=int(db["port"]),
            dbname=db["database"], user=db["user"], password=db["password"],
            connect_timeout=10,
        )
    except Exception as e:
        print(f"ERROR: DB 연결 실패: {e}", file=sys.stderr)
        sys.exit(3)
    conn.autocommit = True

    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    pg_ver = markers.get("server_version", "")

    dump_results = []

    for g in target_groups:
        gk = g["group_key"]
        gdesc = g["group_desc"]
        insert_order = g.get("insert_order")
        delete_order = g.get("delete_order")
        if not insert_order:
            print(f"[TT_550] ⚠ {gk}: FK 순환 의존성으로 skip", file=sys.stderr)
            continue

        out_file = output_dir / f"{gk}.sql"
        lines = []
        lines.append("-- =============================================================")
        lines.append(f"-- TT_550: {gk} ({gdesc})")
        lines.append(f"-- 고객사:     {customer}")
        lines.append(f"-- 생성일시:   {now}")
        lines.append(f"-- 실행 모드:  PYTHON (psycopg2 {psycopg2.__version__})")
        lines.append(f"-- 원본 DB:   {db['host']}:{db['port']}/{db['database']} (schema={schema}, PG {pg_ver})")
        lines.append(f"-- 대상 테이블: {', '.join(insert_order)}")
        lines.append(f"-- 적용 방법: psql -h <host> -U <user> -d <db> -f {gk}.sql")
        lines.append("-- =============================================================")
        lines.append("SET client_encoding = 'UTF8';")
        lines.append("SET standard_conforming_strings = on;")
        lines.append("BEGIN;")
        lines.append("")
        lines.append("-- FK 역순 DELETE")
        for t in delete_order:
            lines.append(f'DELETE FROM "{schema}"."{t}";')
        lines.append("")
        lines.append("-- FK 정순 INSERT")

        row_counts = {}
        for t in insert_order:
            # 컬럼 정보 (타입 포함)
            cur = conn.cursor()
            cur.execute("""
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = %s AND table_name = %s
                ORDER BY ordinal_position
            """, (schema, t))
            col_info = cur.fetchall()
            cols = [c[0] for c in col_info]
            types = [c[1] for c in col_info]
            cur.close()

            if not cols:
                lines.append(f"-- {t}: 컬럼 정보 조회 실패 (skip)")
                row_counts[t] = 0
                continue

            quoted_cols = ", ".join(f'"{c}"' for c in cols)
            cur = conn.cursor()
            try:
                cur.execute(f'SELECT {quoted_cols} FROM "{schema}"."{t}"')
                rows = cur.fetchall()
            except Exception as e:
                print(f"[TT_550] ⚠ {t} SELECT 실패: {e}", file=sys.stderr)
                rows = []
            cur.close()

            row_counts[t] = len(rows)

            if not rows:
                lines.append(f"-- {t}: 0 rows")
                continue

            col_list = ",".join(f'"{c}"' for c in cols)
            for r in rows:
                vals = [serialize_value(v, types[i]) for i, v in enumerate(r)]
                lines.append(f'INSERT INTO "{schema}"."{t}" ({col_list}) VALUES ({",".join(vals)});')
            lines.append("")

        lines.append("COMMIT;")
        lines.append("")
        lines.append("-- 적용 후 검증")
        verify_parts = [
            f"SELECT '{t}' AS tbl, COUNT(*) FROM \"{schema}\".\"{t}\""
            for t in insert_order
        ]
        lines.append("\nUNION ALL\n".join(verify_parts) + ";")

        out_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
        size_kb = round(out_file.stat().st_size / 1024, 1)

        dump_results.append({
            "group_key": gk,
            "group_desc": gdesc,
            "sql_file": f"{gk}.sql",
            "file_size_kb": size_kb,
            "tables": [{"name": t, "rows": row_counts.get(t, 0)} for t in insert_order],
            "insert_order": insert_order,
            "delete_order": delete_order,
        })

        total_rows = sum(row_counts.values())
        print(f"[TT_550] ✓ [{gk}] {gdesc}: {total_rows} rows → {gk}.sql ({size_kb} KB)")

    # dump_results.json → manifest 작성용
    tmp_dir = output_dir / "tmp"
    tmp_dir.mkdir(parents=True, exist_ok=True)
    (tmp_dir / "dump_results.json").write_text(json.dumps({
        "dumps": dump_results,
        "generated_at": now,
        "mode": "PYTHON",
        "tool_versions": {"psycopg2": psycopg2.__version__},
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    conn.close()


if __name__ == "__main__":
    main()
