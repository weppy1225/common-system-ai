#!/usr/bin/env python3
"""
TT_550 6단계 - manifest.json 작성 (TT_551_WIN 입력용).

사용법:
    python 03_write_manifest.py <db_target.json> <markers.json> <dump_results.json> <output_dir> <customer> [mode.json]

출력: <output_dir>/manifest.json (tmp 정리 후에도 보존)

manifest 에는 비밀번호·사용자명을 포함하지 않는다 (host/database/schema 까지만).
"""

import json
import sys
import datetime
import platform
from pathlib import Path


def main():
    if len(sys.argv) < 6:
        print("usage: 03_write_manifest.py <db_target.json> <markers.json> <dump_results.json> <output_dir> <customer> [mode.json]",
              file=sys.stderr)
        sys.exit(2)

    db = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    markers = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
    dump_results = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))
    output_dir = Path(sys.argv[4])
    customer = sys.argv[5]
    mode_info = {}
    if len(sys.argv) > 6 and Path(sys.argv[6]).exists():
        try:
            mode_info = json.loads(Path(sys.argv[6]).read_text(encoding="utf-8"))
        except Exception:
            mode_info = {}

    # 마커 측 그룹·테이블 desc 조회용 인덱스
    group_descs = {g["group_key"]: g for g in markers.get("groups", [])}
    table_descs = {}
    for g in markers.get("groups", []):
        for t in g["tables"]:
            table_descs[(g["group_key"], t["name"])] = t.get("desc", "")

    # dump_results 의 실제 row count 와 결합
    groups_out = []
    for d in dump_results.get("dumps", []):
        gk = d["group_key"]
        g_meta = group_descs.get(gk, {})
        tables_out = []
        for t in d.get("tables", []):
            desc = table_descs.get((gk, t["name"]), "")
            tables_out.append({
                "name": t["name"],
                "desc": desc,
                "rows": t["rows"],
            })
        groups_out.append({
            "group_key": gk,
            "group_desc": d.get("group_desc") or g_meta.get("group_desc", ""),
            "sql_file": d["sql_file"],
            "file_size_kb": d.get("file_size_kb"),
            "tables": tables_out,
            "insert_order": d.get("insert_order"),
            "delete_order": d.get("delete_order"),
        })

    now = datetime.datetime.now().astimezone().isoformat(timespec="seconds")

    manifest = {
        "skill": "TT_550",
        "version": "1",
        "generated_at": now,
        "mode": dump_results.get("mode", mode_info.get("mode", "PYTHON")),
        "tool_versions": {
            "python": mode_info.get("python_version") or platform.python_version(),
            "psycopg2": dump_results.get("tool_versions", {}).get("psycopg2"),
            "pg_dump": mode_info.get("pg_dump_version"),
            "psql": mode_info.get("psql_version"),
        },
        "customer": customer,
        "source_db": {
            "host": db.get("host"),
            "port": int(db.get("port") or 5432),
            "database": db.get("database"),
            "schema": db.get("schema") or "public",
            "pg_version": markers.get("server_version", ""),
        },
        "groups": groups_out,
        "warnings": markers.get("warnings", {}),
        "applied_to_target_db": None,
    }

    out_file = output_dir / "manifest.json"
    out_file.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[TT_550] manifest.json 작성 완료: {out_file}")


if __name__ == "__main__":
    main()
