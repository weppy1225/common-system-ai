#!/usr/bin/env python3
"""
TT_550_WIN 3단계 (PYTHON 모드) - @migrate: 마커 + FK 의존성 수집.

사용법:
    python 01_collect_markers.py <db_target.json> <markers.json>

입력 db_target.json 스키마:
    { "host","port","database","user","password","schema" }

출력 markers.json 스키마: SKILL.md 참조.

요구사항: psycopg2 (PYTHON 모드 전용).
"""

import json
import sys
from pathlib import Path
from collections import defaultdict, deque

try:
    import psycopg2
    import psycopg2.extras
except ImportError:
    print("ERROR: psycopg2 가 설치되어 있지 않습니다.", file=sys.stderr)
    print("       pip install --user psycopg2-binary", file=sys.stderr)
    sys.exit(2)


MARKER_PREFIX = "@migrate:"


def topo_sort(table_names, edges):
    """edges: [{'child','parent'}], 반환: insert_order(parent→child). 순환 시 None."""
    in_degree = {t: 0 for t in table_names}
    graph = defaultdict(list)
    for e in edges:
        c, p = e["child"], e["parent"]
        if c == p:
            continue  # self FK
        graph[p].append(c)
        in_degree[c] += 1

    queue = deque([t for t in table_names if in_degree[t] == 0])
    order = []
    while queue:
        t = queue.popleft()
        order.append(t)
        for nxt in graph[t]:
            in_degree[nxt] -= 1
            if in_degree[nxt] == 0:
                queue.append(nxt)
    if len(order) != len(table_names):
        return None
    return order


def main():
    if len(sys.argv) < 3:
        print("usage: 01_collect_markers.py <db_target.json> <markers.json>", file=sys.stderr)
        sys.exit(2)
    target_file = Path(sys.argv[1])
    out_file = Path(sys.argv[2])
    if not target_file.exists():
        print(f"ERROR: db_target.json 없음: {target_file}", file=sys.stderr)
        sys.exit(2)

    db = json.loads(target_file.read_text(encoding="utf-8"))
    schema = db.get("schema") or "public"

    try:
        conn = psycopg2.connect(
            host=db["host"], port=int(db["port"]),
            dbname=db["database"],
            user=db["user"], password=db["password"],
            connect_timeout=10,
        )
    except Exception as e:
        print(f"ERROR: DB 연결 실패: {e}", file=sys.stderr)
        sys.exit(3)

    conn.autocommit = True
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    # 서버 버전
    cur.execute("SHOW server_version")
    server_version = cur.fetchone()[0]

    # 1) @migrate: 마커 수집
    cur.execute(r"""
        SELECT
            c.relname                                                            AS table_name,
            obj_description(c.oid, 'pg_class')                                   AS comment,
            substring(obj_description(c.oid, 'pg_class') FROM '@migrate:(\S+)')  AS group_key,
            trim(substring(obj_description(c.oid, 'pg_class') FROM '@migrate:\S+\s+(.*)$'))
                                                                                 AS table_desc,
            c.reltuples::bigint                                                  AS approx_rows
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = %s
          AND c.relkind = 'r'
          AND obj_description(c.oid, 'pg_class') LIKE %s
        ORDER BY group_key, table_name
    """, (schema, MARKER_PREFIX + "%"))

    rows = cur.fetchall()

    groups = {}
    for r in rows:
        gk = r["group_key"]
        if not gk:
            continue
        if gk not in groups:
            groups[gk] = {
                "group_key": gk,
                "group_desc": "",
                "tables": [],
                "fk_edges": [],
                "insert_order": [],
                "delete_order": [],
            }
        groups[gk]["tables"].append({
            "name": r["table_name"],
            "desc": (r["table_desc"] or "").strip(),
            "approx_rows": int(r["approx_rows"] or 0),
        })

    # 그룹 desc 추정: 첫 테이블 desc 의 첫 토큰 (예: "공통코드 헤더" → "공통코드")
    for gk, g in groups.items():
        first_desc = g["tables"][0]["desc"] if g["tables"] else ""
        if first_desc:
            tokens = first_desc.split()
            g["group_desc"] = tokens[0] if tokens else gk
        else:
            g["group_desc"] = gk

    # 2) 그룹별 FK 의존성 → insert_order / delete_order
    for gk, g in groups.items():
        table_names = [t["name"] for t in g["tables"]]
        if len(table_names) <= 1:
            g["insert_order"] = list(table_names)
            g["delete_order"] = list(reversed(table_names))
            continue

        cur.execute("""
            SELECT
                conrelid::regclass::text  AS child,
                confrelid::regclass::text AS parent
            FROM pg_constraint
            WHERE contype = 'f'
              AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = %s)
              AND conrelid::regclass::text  = ANY(%s)
              AND confrelid::regclass::text = ANY(%s)
        """, (schema, table_names, table_names))

        edges = []
        for row in cur.fetchall():
            child = row["child"].split(".")[-1].strip('"')
            parent = row["parent"].split(".")[-1].strip('"')
            edges.append({"child": child, "parent": parent})
        g["fk_edges"] = edges

        order = topo_sort(table_names, edges)
        if order is None:
            g["insert_order"] = None
            g["delete_order"] = None
            print(f"[TT_550_WIN] ⚠ {gk}: FK 순환 의존성 감지 — 적용 순서를 수동 결정 필요", file=sys.stderr)
        else:
            g["insert_order"] = order
            g["delete_order"] = list(reversed(order))

    # 3) 마커 없는 sm_/mdm_ 테이블 (경고용)
    cur.execute(r"""
        SELECT c.relname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = %s
          AND c.relkind = 'r'
          AND (c.relname LIKE 'sm\_%' ESCAPE '\' OR c.relname LIKE 'mdm\_%' ESCAPE '\')
          AND (obj_description(c.oid, 'pg_class') IS NULL
               OR obj_description(c.oid, 'pg_class') NOT LIKE %s)
        ORDER BY c.relname
    """, (schema, MARKER_PREFIX + "%"))
    unmarked = [r[0] for r in cur.fetchall()]

    result = {
        "schema": schema,
        "server_version": server_version,
        "groups": list(groups.values()),
        "warnings": {
            "unmarked_master_tables": unmarked,
        },
    }

    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")

    total_tables = sum(len(g["tables"]) for g in groups.values())
    print(f"[TT_550_WIN] 마커 스캔 완료: {len(groups)} 그룹 / {total_tables} 테이블 → {out_file}")
    for gk, g in sorted(groups.items()):
        rows_approx = sum(t["approx_rows"] for t in g["tables"])
        print(f"  [{gk}] {g['group_desc']}  ({len(g['tables'])} tables, ~{rows_approx} rows)")
    if unmarked:
        print(f"[TT_550_WIN] ⚠ 마커 없는 sm_/mdm_ 테이블 {len(unmarked)}개 (혹시 누락?): {', '.join(unmarked[:5])}{' ...' if len(unmarked) > 5 else ''}")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
