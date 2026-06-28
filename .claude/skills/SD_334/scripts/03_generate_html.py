#!/usr/bin/env python3
"""
SD_334 3단계 - schema.json → vis-network 인터랙티브 DB 관계도 HTML 생성.

사용법:
    python3 03_generate_html.py <고객사명>

입력:
    deliverables/30-output/03 설계(SD)/tmp/schema.json

출력:
    deliverables/30-output/03 설계(SD)/SD_334_DB관계도_{고객사명}.html
"""

import json
import sys
import datetime
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[4]
TMP_DIR = BASE_DIR / "deliverables/30-output/03 설계(SD)/tmp"
OUTPUT_DIR = BASE_DIR / "deliverables/30-output/03 설계(SD)"
SCHEMA_FILE = TMP_DIR / "schema.json"


def load_schema():
    if not SCHEMA_FILE.exists():
        print(f"[SD_334] schema.json 파일 없음: {SCHEMA_FILE}", file=sys.stderr)
        sys.exit(2)
    return json.loads(SCHEMA_FILE.read_text(encoding="utf-8"))


def parse_cols(s):
    """SD_331/334가 'col_a, col_b' 형태로 만든 컬럼 문자열을 리스트로 분해."""
    if not s:
        return []
    return [c.strip() for c in s.split(",") if c.strip()]


def normalize_ref(name):
    """ref_table 값에서 schema prefix(예: 'public.mdm_biz')를 제거해 'mdm_biz'로 정규화."""
    if not name:
        return name
    # 따옴표 제거 ("public"."mdm_biz" 같은 케이스)
    s = name.replace('"', '').strip()
    if "." in s:
        s = s.split(".")[-1]
    return s


def safe_filename(s):
    """파일명에 사용 불가능한 문자 제거."""
    return re.sub(r'[\\/:*?"<>|]', "_", s).strip()


def build_nodes_edges(schema):
    tables = schema.get("tables", [])
    physical_names = {t.get("physical_name") for t in tables}
    nodes = []
    edges = []

    for t in tables:
        phys = t.get("physical_name")
        logical = t.get("logical_name") or phys

        pk_cols = set()
        for idx in t.get("indexes", []):
            if idx.get("is_pk"):
                for c in parse_cols(idx.get("columns", "")):
                    pk_cols.add(c)

        fk_cols = set()
        for fk in t.get("fks", []):
            for c in parse_cols(fk.get("columns", "")):
                fk_cols.add(c)

        # vis-network 라벨 (multi: 'html' 모드, <b>/<i>만 지원, \n 줄바꿈)
        lines = []
        if logical and logical != phys:
            lines.append(f"<b>{phys}</b>")
            lines.append(f"<i>{logical}</i>")
        else:
            lines.append(f"<b>{phys}</b>")
        lines.append("─" * 26)

        for col in t.get("columns", []):
            cname = col.get("physical_name", "")
            ctype = col.get("data_type", "")
            if cname in pk_cols and cname in fk_cols:
                mark = "🔑🔗"
            elif cname in pk_cols:
                mark = "🔑  "
            elif cname in fk_cols:
                mark = "🔗  "
            else:
                mark = "    "
            nn = " *" if col.get("not_null") else ""
            lines.append(f"{mark} {cname} : {ctype}{nn}")

        label = "\n".join(lines)
        # 컬럼 폭 결정용 가장 긴 줄 길이 (대략적인 박스 폭)
        max_len = max((len(ln) for ln in lines), default=20)

        nodes.append({
            "id": phys,
            "label": label,
            "title": logical + (f" — {t.get('comment')}" if t.get("comment") else ""),
            "group": t.get("schema") or "default",
            "physical_name": phys,
            "logical_name": logical,
            "comment": t.get("comment") or "",
            "max_label_len": max_len,
            "col_count": len(t.get("columns", [])),
            "fk_out": len(t.get("fks", [])),
            "fk_in": len(t.get("fks_pk_side", [])),
        })

        # 엣지: 이 테이블에서 나가는 FK
        for fk in t.get("fks", []):
            ref = normalize_ref(fk.get("ref_table"))
            if not ref or ref not in physical_names:
                # 참조 테이블이 schema 추출 범위 밖이면 스킵 (스키마 미일치 등)
                continue
            cols = fk.get("columns") or ""
            ref_cols = fk.get("ref_columns") or ""
            edges.append({
                "from": phys,
                "to": ref,
                "arrows": "to",
                "label": "",
                "title": f"{fk.get('name', 'FK')}\n{phys}.({cols}) → {ref}.({ref_cols})",
                "fk_name": fk.get("name", ""),
                "src_cols": cols,
                "ref_cols": ref_cols,
            })

    return nodes, edges


def render_html(schema, nodes, edges, customer):
    db = schema.get("db", {}) or {}
    tables = schema.get("tables", [])
    table_count = len(tables)
    col_count = sum(len(t.get("columns", [])) for t in tables)
    fk_count = len(edges)
    today = datetime.date.today().isoformat()

    nodes_json = json.dumps(nodes, ensure_ascii=False)
    edges_json = json.dumps(edges, ensure_ascii=False)

    db_label = (
        f"{db.get('driver', '')} · "
        f"{db.get('host', '')}:{db.get('port', '')}/"
        f"{db.get('database', '')}"
    )
    if db.get("schema"):
        db_label += f" (schema={db['schema']})"

    return (
        TEMPLATE
        .replace("__CUSTOMER__", html_escape(customer))
        .replace("__DB_LABEL__", html_escape(db_label))
        .replace("__TABLE_COUNT__", str(table_count))
        .replace("__COL_COUNT__", str(col_count))
        .replace("__FK_COUNT__", str(fk_count))
        .replace("__TODAY__", today)
        .replace("__NODES_JSON__", nodes_json)
        .replace("__EDGES_JSON__", edges_json)
    )


def html_escape(s):
    return (
        str(s)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


TEMPLATE = r"""<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>DB 관계도 - __CUSTOMER__</title>
<script src="https://cdn.jsdelivr.net/npm/vis-network@9.1.9/standalone/umd/vis-network.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { height: 100%; font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; font-size: 13px; color: #1f2937; background: #f3f4f6; }
  body { display: flex; flex-direction: column; height: 100vh; overflow: hidden; }
  header {
    background: #304a6e; color: #fff; padding: 10px 16px;
    display: flex; align-items: center; gap: 16px; flex-shrink: 0;
    border-bottom: 1px solid #1f3554;
  }
  header h1 { font-size: 16px; font-weight: 700; }
  header .stats { display: flex; gap: 14px; font-size: 12px; opacity: 0.9; margin-left: auto; }
  header .stats span b { font-weight: 700; color: #ffe48a; }
  header .meta { font-size: 12px; opacity: 0.8; }
  main { flex: 1; display: flex; min-height: 0; }
  aside {
    width: 280px; background: #fff; border-right: 1px solid #e5e7eb;
    display: flex; flex-direction: column; flex-shrink: 0;
  }
  aside .search { padding: 10px; border-bottom: 1px solid #e5e7eb; }
  aside .search input {
    width: 100%; height: 30px; padding: 0 10px;
    border: 1px solid #d1d5db; border-radius: 4px; font-size: 13px;
  }
  aside .search input:focus { outline: none; border-color: #7aa2c8; box-shadow: 0 0 0 2px rgba(122,162,200,0.15); }
  aside .table-list { flex: 1; overflow-y: auto; }
  aside .table-list .item {
    padding: 7px 12px; border-bottom: 1px solid #f3f4f6; cursor: pointer;
    font-size: 12px; line-height: 1.4;
  }
  aside .table-list .item:hover { background: #eff6ff; }
  aside .table-list .item.active { background: #dbeafe; }
  aside .table-list .item .phys { font-weight: 600; color: #111827; }
  aside .table-list .item .logical { color: #6b7280; font-size: 11px; margin-top: 2px; }
  aside .table-list .item .meta { color: #9ca3af; font-size: 11px; margin-top: 2px; }
  aside footer {
    padding: 10px 12px; border-top: 1px solid #e5e7eb; background: #f9fafb;
    font-size: 11px; color: #6b7280; line-height: 1.6;
  }
  #network-wrap { flex: 1; position: relative; min-height: 0; }
  #network { width: 100%; height: 100%; background: #fafafa; }
  .controls {
    position: absolute; top: 10px; right: 10px; z-index: 10;
    background: #fff; border: 1px solid #e5e7eb; border-radius: 6px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    padding: 6px; display: flex; gap: 4px; align-items: center;
  }
  .controls button, .controls select {
    height: 26px; padding: 0 10px; border: 1px solid #d1d5db; background: #fff;
    border-radius: 4px; font-size: 12px; cursor: pointer; color: #374151;
  }
  .controls button:hover { background: #f9fafb; border-color: #9ca3af; color: #111827; }
  .controls .label { font-size: 11px; color: #6b7280; margin: 0 2px 0 6px; }
  .legend {
    position: absolute; bottom: 10px; left: 10px; z-index: 10;
    background: rgba(255,255,255,0.95); border: 1px solid #e5e7eb;
    border-radius: 6px; padding: 8px 12px; font-size: 11px; line-height: 1.7;
    box-shadow: 0 2px 6px rgba(0,0,0,0.06);
  }
  .legend b { color: #304a6e; font-size: 12px; }
  .empty {
    text-align: center; color: #9ca3af; padding: 30px 12px; font-size: 12px;
  }
</style>
</head>
<body>
<header>
  <h1>DB 관계도 — __CUSTOMER__</h1>
  <div class="meta">__DB_LABEL__ · 기준일 __TODAY__</div>
  <div class="stats">
    <span>테이블 <b>__TABLE_COUNT__</b></span>
    <span>컬럼 <b>__COL_COUNT__</b></span>
    <span>FK <b>__FK_COUNT__</b></span>
  </div>
</header>
<main>
  <aside>
    <div class="search">
      <input type="text" id="q" placeholder="테이블 검색 (물리명/논리명)">
    </div>
    <div class="table-list" id="tableList"></div>
    <footer>
      🔑 PK · 🔗 FK · 별표(*) NOT NULL<br>
      노드 클릭: 관련 테이블 강조<br>
      더블클릭: 화면 중앙으로 이동
    </footer>
  </aside>
  <div id="network-wrap">
    <div class="controls">
      <button id="btnFit">전체보기</button>
      <span class="label">레이아웃</span>
      <select id="layout">
        <option value="physics">물리 시뮬레이션</option>
        <option value="hierarchical-LR">계층 (좌→우)</option>
        <option value="hierarchical-UD">계층 (위→아래)</option>
      </select>
      <button id="btnPhysicsToggle">물리 정지</button>
    </div>
    <div class="legend">
      <b>범례</b><br>
      ● 박스 = 테이블<br>
      → 화살표 = FK 참조<br>
      🔑 PK · 🔗 FK · * NOT NULL
    </div>
    <div id="network"></div>
  </div>
</main>
<script>
const RAW_NODES = __NODES_JSON__;
const RAW_EDGES = __EDGES_JSON__;

// FK 인접 테이블 인덱스
const adjacency = {};
RAW_NODES.forEach(n => { adjacency[n.id] = new Set(); });
RAW_EDGES.forEach(e => {
  if (adjacency[e.from]) adjacency[e.from].add(e.to);
  if (adjacency[e.to]) adjacency[e.to].add(e.from);
});

// vis-network 노드 데이터
const nodes = new vis.DataSet(RAW_NODES.map(n => ({
  id: n.id,
  label: n.label,
  title: n.title || n.physical_name,
  shape: 'box',
  font: {
    multi: 'html',
    face: 'Consolas, "D2Coding", "Malgun Gothic", monospace',
    size: 12,
    align: 'left',
    color: '#1f2937',
  },
  color: {
    background: '#ffffff',
    border: '#304a6e',
    highlight: { background: '#fff7e0', border: '#b8860b' },
    hover: { background: '#eff6ff', border: '#3a6ea5' },
  },
  borderWidth: 1.5,
  borderWidthSelected: 2.5,
  margin: 10,
  widthConstraint: { minimum: 180 },
  // custom 프로퍼티 (검색용)
  _phys: n.physical_name,
  _logical: n.logical_name,
})));

const edges = new vis.DataSet(RAW_EDGES.map((e, idx) => ({
  id: 'e' + idx,
  from: e.from, to: e.to, arrows: e.arrows || 'to',
  title: e.title,
  color: { color: '#94a3b8', highlight: '#b8860b', hover: '#3a6ea5' },
  smooth: { type: 'cubicBezier', forceDirection: 'horizontal', roundness: 0.4 },
  font: { size: 10, color: '#475569', strokeWidth: 0 },
})));

const container = document.getElementById('network');
const data = { nodes, edges };
const baseOptions = {
  interaction: { hover: true, navigationButtons: false, keyboard: true, multiselect: true, tooltipDelay: 120 },
  physics: {
    enabled: true,
    solver: 'forceAtlas2Based',
    forceAtlas2Based: { gravitationalConstant: -80, springLength: 200, avoidOverlap: 0.6 },
    stabilization: { iterations: 250 },
  },
  layout: { improvedLayout: true },
  edges: { arrows: { to: { enabled: true, scaleFactor: 0.6 } } },
  nodes: { shapeProperties: { interpolation: false } },
};
const network = new vis.Network(container, data, baseOptions);

// 안정화 후 한번 fit
network.once('stabilizationIterationsDone', () => network.fit({ animation: { duration: 400 } }));

// 사이드바 테이블 리스트
const tableList = document.getElementById('tableList');
function renderList(filter) {
  const f = (filter || '').trim().toLowerCase();
  tableList.innerHTML = '';
  const items = RAW_NODES
    .filter(n => !f || n.physical_name.toLowerCase().includes(f) || (n.logical_name || '').toLowerCase().includes(f))
    .sort((a, b) => a.physical_name.localeCompare(b.physical_name));
  if (items.length === 0) {
    tableList.innerHTML = '<div class="empty">검색 결과가 없습니다.</div>';
    return;
  }
  items.forEach(n => {
    const div = document.createElement('div');
    div.className = 'item';
    div.dataset.id = n.physical_name;
    const meta = `컬럼 ${n.col_count} · FK→ ${n.fk_out} · ←FK ${n.fk_in}`;
    const phys = escapeHtml(n.physical_name);
    const logical = (n.logical_name && n.logical_name !== n.physical_name)
      ? `<div class="logical">${escapeHtml(n.logical_name)}</div>` : '';
    div.innerHTML = `<div class="phys">${phys}</div>${logical}<div class="meta">${meta}</div>`;
    div.addEventListener('click', () => focusNode(n.physical_name));
    tableList.appendChild(div);
  });
}
function escapeHtml(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function focusNode(id) {
  network.selectNodes([id]);
  network.focus(id, { scale: 1.0, animation: { duration: 400 } });
  document.querySelectorAll('aside .item').forEach(el => {
    el.classList.toggle('active', el.dataset.id === id);
  });
}

document.getElementById('q').addEventListener('input', e => renderList(e.target.value));
renderList('');

// 노드 클릭 → 사이드바 동기화 + 인접 강조
network.on('click', params => {
  if (params.nodes.length === 0) return;
  const id = params.nodes[0];
  document.querySelectorAll('aside .item').forEach(el => {
    el.classList.toggle('active', el.dataset.id === id);
    if (el.dataset.id === id) el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  });
});

// 컨트롤
document.getElementById('btnFit').addEventListener('click', () => {
  network.fit({ animation: { duration: 400 } });
});

let physicsOn = true;
const btnPhysics = document.getElementById('btnPhysicsToggle');
btnPhysics.addEventListener('click', () => {
  physicsOn = !physicsOn;
  network.setOptions({ physics: { enabled: physicsOn } });
  btnPhysics.textContent = physicsOn ? '물리 정지' : '물리 시작';
});

document.getElementById('layout').addEventListener('change', e => {
  const v = e.target.value;
  if (v === 'physics') {
    network.setOptions({
      layout: { hierarchical: false, improvedLayout: true },
      physics: { enabled: true, solver: 'forceAtlas2Based' },
    });
    physicsOn = true;
    btnPhysics.textContent = '물리 정지';
  } else {
    const direction = v === 'hierarchical-LR' ? 'LR' : 'UD';
    network.setOptions({
      layout: { hierarchical: { enabled: true, direction, sortMethod: 'directed', nodeSpacing: 220, levelSeparation: 260 } },
      physics: { enabled: false },
    });
    physicsOn = false;
    btnPhysics.textContent = '물리 시작';
  }
  setTimeout(() => network.fit({ animation: { duration: 400 } }), 100);
});
</script>
</body>
</html>
"""


def main():
    if len(sys.argv) < 2 or not sys.argv[1].strip():
        print("[SD_334] 사용법: python3 03_generate_html.py <고객사명>", file=sys.stderr)
        sys.exit(2)
    customer = sys.argv[1].strip()
    customer_safe = safe_filename(customer)

    schema = load_schema()
    nodes, edges = build_nodes_edges(schema)
    html = render_html(schema, nodes, edges, customer)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUTPUT_DIR / f"SD_334_DB관계도_{customer_safe}.html"
    out_path.write_text(html, encoding="utf-8")

    print(f"[SD_334] HTML 생성 완료: {out_path}")
    print(f"  테이블: {len(nodes)}개")
    print(f"  FK 엣지: {len(edges)}개")


if __name__ == "__main__":
    main()
