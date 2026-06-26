#!/usr/bin/env python3
"""
[SD_332] 1단계 — DB 접속정보 스캔

지정 디렉토리(하위 포함)에서 다음 파일을 인식하여 DB 접속 후보를 추출한다.
  - application*.properties (Spring, 커스텀 db.* 키 모두 지원)
  - application*.yml / .yaml (Spring)
  - *.env / .env.* (DB_*, DATABASE_URL)

JDBC URL의 wrapper prefix(log4jdbc, p6spy 등)는 제거한다.
프로파일 우선순위: local > dev > default > 그 외.

사용법:
  python3 01_scan_db_config.py "{디렉토리경로}"

출력:
  deliverables/30-output/04 구현(PI)/tmp/db_candidates.json
  {
    "scanned_files": [...],
    "candidates": [
      {
        "profile": "local",
        "source_file": "...",
        "driver": "postgresql",
        "host": "localhost",
        "port": 5433,
        "database": "wms_local",
        "schema": "public",
        "user": "wms_local_sa",
        "password": "local1234",
        "raw_url": "jdbc:log4jdbc:postgresql://localhost:5433/wms_local"
      }
    ],
    "recommended_index": 0
  }
"""

from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any
from urllib.parse import parse_qsl, urlparse

BASE = Path(__file__).resolve().parents[4]
TMP_DIR = BASE / "deliverables" / "30-output" / "04 구현(PI)" / "tmp"
OUT_FILE = TMP_DIR / "db_candidates.json"

PROFILE_PRIORITY = {"local": 0, "dev": 1, "default": 2}  # 그 외는 9


# ---------------------------------------------------------------------------
# JDBC URL 파싱
# ---------------------------------------------------------------------------

DRIVER_DEFAULT_PORTS = {
    "postgresql": 5432,
    "mysql": 3306,
    "mssql": 1433,
}

def normalize_driver(name: str) -> str | None:
    if not name:
        return None
    n = name.lower()
    if "postgres" in n:
        return "postgresql"
    if "mariadb" in n or "mysql" in n:
        return "mysql"
    if "sqlserver" in n or "mssql" in n or "microsoft" in n:
        return "mssql"
    return None


def parse_jdbc_url(url: str) -> dict[str, Any]:
    """
    예시:
      jdbc:log4jdbc:postgresql://localhost:5433/wms_local
      jdbc:postgresql://localhost:5432/wms_local?currentSchema=public
      jdbc:mysql://db.example.com:3306/wms?useSSL=false
      jdbc:sqlserver://srv:1433;databaseName=wms;encrypt=true
    """
    if not url:
        return {}
    s = url.strip()
    if not s.lower().startswith("jdbc:"):
        return {}
    body = s[5:]  # strip "jdbc:"

    # wrapper prefix 제거 (log4jdbc, p6spy 등)
    while True:
        m = re.match(r"^([a-zA-Z0-9_]+):", body)
        if not m:
            break
        head = m.group(1).lower()
        if head in ("log4jdbc", "p6spy"):
            body = body[m.end():]
            continue
        break

    # driver 추출
    m = re.match(r"^([a-zA-Z0-9_]+):(.*)$", body)
    if not m:
        return {}
    driver_token, rest = m.group(1), m.group(2)
    driver = normalize_driver(driver_token)
    if driver is None:
        return {"raw_url": url}

    # SQL Server 의 'jdbc:sqlserver://host:port;databaseName=...' 처리
    if driver == "mssql":
        host = ""
        port = DRIVER_DEFAULT_PORTS["mssql"]
        database = ""
        schema = ""
        # rest는 보통 //host[:port][;k=v;...] 형식
        if rest.startswith("//"):
            rest = rest[2:]
        # 최초 ';' 이전을 host:port, 이후를 query
        head, _, query = rest.partition(";")
        host_part, _, port_part = head.partition(":")
        host = host_part
        if port_part.isdigit():
            port = int(port_part)
        if query:
            for kv in query.split(";"):
                if "=" not in kv:
                    continue
                k, v = kv.split("=", 1)
                k = k.strip().lower()
                v = v.strip()
                if k in ("databasename", "database"):
                    database = v
                elif k in ("currentschema", "schema"):
                    schema = v
        return {
            "driver": driver,
            "host": host,
            "port": port,
            "database": database,
            "schema": schema or "dbo",
            "raw_url": url,
        }

    # postgres / mysql 표준 URL
    parsed = urlparse(rest if rest.startswith("//") else "//" + rest)
    host = parsed.hostname or ""
    port = parsed.port or DRIVER_DEFAULT_PORTS.get(driver, 0)
    database = parsed.path.lstrip("/") if parsed.path else ""
    schema = ""
    if parsed.query:
        q = dict(parse_qsl(parsed.query, keep_blank_values=True))
        schema = q.get("currentSchema") or q.get("schema") or ""
    if not schema and driver == "postgresql":
        schema = "public"
    if not schema and driver == "mysql":
        schema = database
    return {
        "driver": driver,
        "host": host,
        "port": port,
        "database": database,
        "schema": schema,
        "raw_url": url,
    }


# ---------------------------------------------------------------------------
# 파일 파서
# ---------------------------------------------------------------------------

def read_file(path: Path) -> str:
    for enc in ("utf-8", "utf-8-sig"):
        try:
            return path.read_text(encoding=enc)
        except UnicodeDecodeError:
            continue
    return path.read_text(encoding="utf-8", errors="replace")


def parse_properties(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("#") or s.startswith("!"):
            continue
        if "=" in s:
            k, v = s.split("=", 1)
        elif ":" in s:
            k, v = s.split(":", 1)
        else:
            continue
        out[k.strip()] = v.strip()
    return out


def parse_yaml(text: str) -> dict[str, Any]:
    """매우 단순한 YAML 파서 (key.path = value 형태로 평탄화)."""
    try:
        import yaml  # type: ignore
        data = yaml.safe_load(text) or {}
        flat: dict[str, str] = {}
        def walk(d: Any, prefix: str) -> None:
            if isinstance(d, dict):
                for k, v in d.items():
                    walk(v, f"{prefix}.{k}" if prefix else str(k))
            elif isinstance(d, list):
                for i, v in enumerate(d):
                    walk(v, f"{prefix}[{i}]")
            else:
                flat[prefix] = "" if d is None else str(d)
        walk(data, "")
        return flat
    except Exception:
        # PyYAML 없으면 들여쓰기 기반 단순 파싱 (문자열 값만)
        flat: dict[str, str] = {}
        stack: list[tuple[int, str]] = []  # (indent, key_path)
        for raw in text.splitlines():
            line = raw.rstrip()
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            indent = len(line) - len(line.lstrip(" "))
            content = line.strip()
            if ":" not in content:
                continue
            key, _, val = content.partition(":")
            key = key.strip()
            val = val.strip()
            while stack and stack[-1][0] >= indent:
                stack.pop()
            path = f"{stack[-1][1]}.{key}" if stack else key
            if val == "":
                stack.append((indent, path))
            else:
                # 따옴표 제거
                if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                    val = val[1:-1]
                flat[path] = val
        return flat


def parse_env(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in text.splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if s.lower().startswith("export "):
            s = s[7:].strip()
        if "=" not in s:
            continue
        k, v = s.split("=", 1)
        v = v.strip()
        if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
            v = v[1:-1]
        out[k.strip()] = v
    return out


# ---------------------------------------------------------------------------
# 후보 추출
# ---------------------------------------------------------------------------

PROFILE_PATTERN = re.compile(
    r"application(?:[._-]([a-z0-9]+))?\.(properties|ya?ml)$",
    re.IGNORECASE,
)


def extract_profile(filename: str) -> str:
    m = PROFILE_PATTERN.search(filename)
    if not m:
        return "default"
    return (m.group(1) or "default").lower()


def candidate_from_props(props: dict[str, str], profile: str, source_file: str) -> dict[str, Any] | None:
    # db.* 우선, 없으면 spring.datasource.*
    url = props.get("db.url") or props.get("spring.datasource.url") or ""
    user = props.get("db.username") or props.get("spring.datasource.username") or ""
    password = props.get("db.password") or props.get("spring.datasource.password") or ""
    driver_class = props.get("db.driverClassName") or props.get("spring.datasource.driver-class-name") or ""

    parsed = parse_jdbc_url(url) if url else {}
    driver = parsed.get("driver") or normalize_driver(driver_class)
    if not driver:
        return None

    cand = {
        "profile": profile,
        "source_file": source_file,
        "driver": driver,
        "host": parsed.get("host", ""),
        "port": parsed.get("port", DRIVER_DEFAULT_PORTS.get(driver, 0)),
        "database": parsed.get("database", ""),
        "schema": parsed.get("schema", ""),
        "user": user,
        "password": password,
        "raw_url": url,
    }
    if not cand["host"] or not cand["database"]:
        return None
    return cand


def candidate_from_env(props: dict[str, str], profile: str, source_file: str) -> dict[str, Any] | None:
    if "DATABASE_URL" in props:
        # postgres://user:pass@host:port/db 형식
        url = props["DATABASE_URL"]
        m = re.match(r"(\w+)://(?:([^:@]+)(?::([^@]*))?@)?([^:/]+)(?::(\d+))?/([^?]+)", url)
        if m:
            scheme, user, password, host, port, database = m.groups()
            driver = normalize_driver(scheme)
            if driver:
                return {
                    "profile": profile,
                    "source_file": source_file,
                    "driver": driver,
                    "host": host,
                    "port": int(port) if port else DRIVER_DEFAULT_PORTS.get(driver, 0),
                    "database": database,
                    "schema": "public" if driver == "postgresql" else database,
                    "user": user or "",
                    "password": password or "",
                    "raw_url": url,
                }
    # 키 별로
    driver = normalize_driver(props.get("DB_DRIVER") or props.get("DB_DIALECT") or "")
    host = props.get("DB_HOST") or ""
    if not driver or not host:
        return None
    return {
        "profile": profile,
        "source_file": source_file,
        "driver": driver,
        "host": host,
        "port": int(props.get("DB_PORT") or DRIVER_DEFAULT_PORTS.get(driver, 0)),
        "database": props.get("DB_NAME") or props.get("DB_DATABASE") or "",
        "schema": props.get("DB_SCHEMA") or ("public" if driver == "postgresql" else ""),
        "user": props.get("DB_USER") or props.get("DB_USERNAME") or "",
        "password": props.get("DB_PASSWORD") or "",
        "raw_url": props.get("DATABASE_URL", ""),
    }


# ---------------------------------------------------------------------------
# 디렉토리 스캔
# ---------------------------------------------------------------------------

EXCLUDE_DIRS = {
    "node_modules", "build", "dist", ".gradle", ".git",
    "target", "bin", ".idea", ".vscode", ".venv", "venv", "__pycache__",
}


def iter_config_files(root: Path):
    for dp, dirnames, filenames in os.walk(root):
        # in-place skip
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS and not d.startswith(".gradle")]
        for fn in filenames:
            low = fn.lower()
            if low.startswith("application") and (low.endswith(".properties") or low.endswith(".yml") or low.endswith(".yaml")):
                yield Path(dp) / fn
            elif low == ".env" or low.startswith(".env."):
                yield Path(dp) / fn
            elif low.endswith(".env"):
                yield Path(dp) / fn


def profile_priority(profile: str) -> int:
    return PROFILE_PRIORITY.get(profile, 9)


def candidate_key(c: dict[str, Any]) -> tuple:
    return (c.get("driver"), c.get("host"), c.get("port"), c.get("database"))


def merge_candidates(cands: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """profile + (driver,host,port,database) 같으면 같은 후보로 병합. 비어있는 user/password는 더 풍부한 쪽으로 채움."""
    by_id: dict[tuple, dict[str, Any]] = {}
    for c in cands:
        key = (c.get("profile"),) + candidate_key(c)
        if key not in by_id:
            by_id[key] = dict(c)
            continue
        prev = by_id[key]
        for k in ("user", "password", "schema", "raw_url"):
            if not prev.get(k) and c.get(k):
                prev[k] = c[k]
    return list(by_id.values())


def main() -> int:
    if len(sys.argv) < 2:
        print("[ERROR] 디렉토리 경로 인자가 필요합니다.", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).expanduser().resolve()
    if not root.exists() or not root.is_dir():
        print(f"[ERROR] 디렉토리가 없습니다: {root}", file=sys.stderr)
        return 2

    TMP_DIR.mkdir(parents=True, exist_ok=True)

    scanned: list[str] = []
    cands: list[dict[str, Any]] = []
    for path in iter_config_files(root):
        scanned.append(str(path))
        text = read_file(path)
        try:
            low = path.name.lower()
            if low.endswith(".properties"):
                profile = extract_profile(path.name)
                props = parse_properties(text)
                cand = candidate_from_props(props, profile, str(path))
                if cand:
                    cands.append(cand)
            elif low.endswith(".yml") or low.endswith(".yaml"):
                profile = extract_profile(path.name)
                flat = parse_yaml(text)
                cand = candidate_from_props(flat, profile, str(path))
                if cand:
                    cands.append(cand)
            elif low == ".env" or low.startswith(".env.") or low.endswith(".env"):
                # .env, .env.local 등의 profile 추출
                m = re.match(r"\.env(?:\.([a-z0-9]+))?$", path.name.lower())
                profile = (m.group(1) if m and m.group(1) else "default") if m else "default"
                env = parse_env(text)
                cand = candidate_from_env(env, profile, str(path))
                if cand:
                    cands.append(cand)
        except Exception as e:
            print(f"[WARN] {path}: {e}", file=sys.stderr)

    cands = merge_candidates(cands)
    cands.sort(key=lambda c: (profile_priority(c.get("profile", "")), c.get("source_file", "")))

    recommended = 0 if cands else -1

    out = {
        "scanned_at": datetime.now().isoformat(timespec="seconds"),
        "scan_root": str(root),
        "scanned_files": scanned,
        "candidates": cands,
        "recommended_index": recommended,
    }
    OUT_FILE.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")

    # 사람이 보기 쉬운 요약 출력
    print(f"[OK] 스캔 완료: {len(scanned)}개 파일, 후보 {len(cands)}건")
    for i, c in enumerate(cands):
        mark = "★" if i == recommended else " "
        pwd_mask = "***" if c.get("password") else "(empty)"
        print(f"  {mark} #{i} profile={c['profile']:<7} {c['driver']}://{c['host']}:{c['port']}/{c['database']} user={c['user']} pw={pwd_mask}")
        print(f"      ← {c['source_file']}")
    print(f"\n저장 완료: {OUT_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
