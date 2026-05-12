#!/usr/bin/env python3
"""
TT_551_WIN 2단계 - manifest.json + 사용자 입력을 fill_data.json 으로 합치기.

사용법:
    python 01_load_inputs.py <input_dir> <output_fill_data_json> <user_inputs_json>

input_dir : TT_550 출력 폴더 (manifest.json 있어야 함)
user_inputs_json : { "author": "...", "plan_date": "YYYY-MM-DD",
                    "precondition": "...", "rollback": "...", "generated_at": "..." }

출력: fill_data.json (SKILL.md 의 스키마 참조)
"""

import json
import sys
import datetime
from pathlib import Path


def main():
    if len(sys.argv) < 4:
        print("usage: 01_load_inputs.py <input_dir> <output_fill_data_json> <user_inputs_json>", file=sys.stderr)
        sys.exit(2)

    input_dir = Path(sys.argv[1])
    out_file = Path(sys.argv[2])
    user_inputs = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))

    manifest_file = input_dir / "manifest.json"
    if not manifest_file.exists():
        print(f"ERROR: manifest.json 이 없습니다: {manifest_file}", file=sys.stderr)
        print("       먼저 /TT_550_WIN 을 실행해주세요.", file=sys.stderr)
        sys.exit(2)

    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))

    # 집계
    group_count = len(manifest.get("groups", []))
    table_count = sum(len(g.get("tables", [])) for g in manifest.get("groups", []))
    row_count_total = sum(t.get("rows", 0) for g in manifest.get("groups", []) for t in g.get("tables", []))

    # 경고 메시지
    unmarked = manifest.get("warnings", {}).get("unmarked_master_tables", [])
    warnings_text = ", ".join(unmarked) if unmarked else "(없음)"

    src = manifest.get("source_db", {})

    # generated_at: 사용자 미지정 시 현재 시각
    generated_at = user_inputs.get("generated_at") or datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    scalars = {
        "customer": manifest.get("customer", ""),
        "author": user_inputs.get("author", ""),
        "generated_at": generated_at,
        "plan_date": user_inputs.get("plan_date", ""),
        "source_host": src.get("host", ""),
        "source_db": src.get("database", ""),
        "source_schema": src.get("schema", ""),
        "source_pg_version": src.get("pg_version", ""),
        "group_count": group_count,
        "table_count": table_count,
        "row_count_total": row_count_total,
        "precondition": user_inputs.get("precondition", ""),
        "rollback": user_inputs.get("rollback", ""),
        "warnings": warnings_text,
    }

    # 그룹 표 행
    rows_groups = []
    for i, g in enumerate(manifest.get("groups", []), 1):
        row_sum = sum(t.get("rows", 0) for t in g.get("tables", []))
        rows_groups.append({
            "no": i,
            "group_key": g.get("group_key", ""),
            "group_desc": g.get("group_desc", ""),
            "table_count": len(g.get("tables", [])),
            "row_sum": row_sum,
            "sql_file": g.get("sql_file", ""),
            "file_size_kb": g.get("file_size_kb", 0),
        })

    # 테이블 표 행 (FK 정순)
    rows_tables = []
    no = 0
    for g in manifest.get("groups", []):
        insert_order = g.get("insert_order") or [t.get("name") for t in g.get("tables", [])]
        # FK 부모 매핑 (이 그룹 안에서만)
        tables_by_name = {t["name"]: t for t in g.get("tables", [])}
        # 단순 FK 부모: insert_order 앞 테이블 중 자신을 가리키는 것 (정확하진 않지만 표시용)
        # 더 정확하게 하려면 manifest 에 fk_edges 가 필요 → 현재 manifest 에는 없음.
        # 임시: 같은 그룹의 직전 테이블을 부모로 표시 (가독성 목적)
        for apply_order, tname in enumerate(insert_order, 1):
            t = tables_by_name.get(tname, {"name": tname, "desc": "", "rows": 0})
            no += 1
            fk_parent = ""
            if apply_order > 1 and insert_order[apply_order - 2]:
                fk_parent = insert_order[apply_order - 2]
            rows_tables.append({
                "no": no,
                "group_desc": g.get("group_desc", ""),
                "table_name": t.get("name", tname),
                "table_desc": t.get("desc", ""),
                "rows": t.get("rows", 0),
                "fk_parent": fk_parent,
                "sql_file": g.get("sql_file", ""),
                "apply_order": apply_order,
            })

    fill_data = {
        "scalars": scalars,
        "rows": {
            "groups": rows_groups,
            "tables": rows_tables,
        },
        "_meta": {
            "input_dir": str(input_dir),
            "manifest_path": str(manifest_file),
            "loaded_at": datetime.datetime.now().isoformat(timespec="seconds"),
        },
    }

    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(fill_data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[TT_551_WIN] fill_data.json 작성: {out_file}")
    print(f"  고객사:  {scalars['customer']}")
    print(f"  그룹:    {group_count}")
    print(f"  테이블:  {table_count}")
    print(f"  rows:    {row_count_total}")


if __name__ == "__main__":
    main()
