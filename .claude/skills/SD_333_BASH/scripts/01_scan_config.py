#!/usr/bin/env python3
"""
SD_333_WIN 1단계 - 디렉토리 스캔으로 PostgreSQL 접속정보 후보 추출.

사용법:
    python 01_scan_config.py <디렉토리경로>

산출물:
    output/03 설계(SD)/tmp/db_candidates.json

YAML/TOML/JS 등 외부 라이브러리 없이 표준 라이브러리만 사용한다.
완벽한 파싱은 어려우므로 라인 기반 정규식·간단한 구조 추적으로 후보를 모은다.

PostgreSQL 전용: driver != postgresql 인 후보는 자동 제외한다.
"""

import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse, unquote

# BASE_DIR 자동 추론: scripts/01_scan_config.py → SD_333_WIN → skills → .claude → <repo root>
BASE_DIR = Path(__file__).resolve().parents[4]
TMP_DIR = BASE_DIR / "output" / "03 설계(SD)" / "tmp"

POSTGRES_TOKENS = {
    "postgres", "postgresql", "psql", "pg",
    "psycopg2", "psycopg", "log4jdbc",  # log4jdbc 는 추가 검사로 필터
}

DEFAULT_PG_PORT = 5432

SCAN_FILE_NAMES = {
    "application.yml", "application.yaml", "application.properties",
    "database.yml", "database.yaml",
    "settings.py",
    "schema.prisma",
    "docker-compose.yml", "docker-compose.yaml",
}

SCAN_FILE_PATTERNS = [
    re.compile(r"^\.env(\..+)?$"),
    re.compile(r"^.*\.env$"),
    re.compile(r"^application-.+\.ya?ml$"),
    re.compile(r"^application-.+\.properties$"),
    re.compile(r"^(db|database|datasource)\.(json|ya?ml|properties)$", re.IGNORECASE),
    re.compile(r"^config\.(json|ya?ml)$"),
]

SKIP_DIRS = {
    "node_modules", ".git", ".venv", "venv", "__pycache__", "dist", "build",
    ".idea", ".vscode", "target", "bin", "obj", "out", ".gradle", ".mvn",
}


def normalize_path(p: str) -> str:
    """WSL 경로(/mnt/c/...) ↔ Windows 경로(C:\\...) 자동 변환."""
    if not p:
        return p
    p = p.strip().strip('"').strip("'")
    # /mnt/<drive>/...  →  <DRIVE>:\...
    m = re.match(r"^/mnt/([a-zA-Z])/(.*)$", p)
    if m:
        drive, rest = m.group(1).upper(), m.group(2)
        return f"{drive}:\\" + rest.replace("/", "\\")
    return p


def looks_like_postgres(token: str) -> bool:
    if not token:
        return False
    t = token.lower()
    for kw in POSTGRES_TOKENS:
        if kw in t:
            return True
    return False


def parse_jdbc_url(url: str):
    """jdbc:[log4jdbc:]postgresql://host:port/db?currentSchema=xxx 형태 파싱."""
    if not url:
        return None
    s = url.strip().strip('"').strip("'")
    # 프리픽스 정리
    s_lower = s.lower()
    if not (s_lower.startswith("jdbc:") or s_lower.startswith("postgres://")
            or s_lower.startswith("postgresql://")):
        return None
    s = re.sub(r"^jdbc:log4jdbc:", "jdbc:", s, flags=re.IGNORECASE)
    if not looks_like_postgres(s):
        return None
    # jdbc:postgresql://host:port/db?...
    m = re.match(
        r"^jdbc:postgresql://([^:/]+)(?::(\d+))?/([^?\s]+)(?:\?(.*))?$",
        s, flags=re.IGNORECASE,
    )
    if not m:
        # postgres(ql)://[user[:pass]@]host[:port]/db
        try:
            u = urlparse(s)
            if u.scheme.lower() not in ("postgres", "postgresql"):
                return None
            host = u.hostname
            port = u.port or DEFAULT_PG_PORT
            database = (u.path or "").lstrip("/").split("?")[0] or None
            user = unquote(u.username) if u.username else None
            password = unquote(u.password) if u.password else None
            schema = None
            if u.query:
                for kv in u.query.split("&"):
                    if "=" not in kv:
                        continue
                    k, v = kv.split("=", 1)
                    if k.lower() in ("currentschema", "schema", "searchpath"):
                        schema = v
            return {
                "driver": "postgresql",
                "host": host, "port": int(port) if port else DEFAULT_PG_PORT,
                "database": database, "user": user, "password": password,
                "schema": schema,
            }
        except Exception:
            return None
    host, port, database, query = m.group(1), m.group(2), m.group(3), m.group(4)
    schema = None
    if query:
        for kv in query.split("&"):
            if "=" not in kv:
                continue
            k, v = kv.split("=", 1)
            if k.lower() in ("currentschema", "schema", "searchpath"):
                schema = v
    return {
        "driver": "postgresql",
        "host": host,
        "port": int(port) if port else DEFAULT_PG_PORT,
        "database": database,
        "user": None, "password": None, "schema": schema,
    }


def merge_candidate(cands, new):
    """중복 후보 병합. (driver, host, port, database) 기준."""
    if not new:
        return
    if new.get("driver") != "postgresql":
        return
    if not new.get("host") or not new.get("database"):
        return
    key = (new["driver"], new.get("host"), int(new.get("port") or DEFAULT_PG_PORT), new.get("database"))
    for c in cands:
        c_key = (c["driver"], c.get("host"), int(c.get("port") or DEFAULT_PG_PORT), c.get("database"))
        if c_key == key:
            # 더 풍부한 값으로 채움
            for k in ("user", "password", "schema"):
                if not c.get(k) and new.get(k):
                    c[k] = new[k]
            # source_files 합치기
            sf = set(c.get("source_files", []))
            sf.update(new.get("source_files", []))
            c["source_files"] = sorted(sf)
            return
    if "port" not in new or not new["port"]:
        new["port"] = DEFAULT_PG_PORT
    new.setdefault("schema", None)
    new.setdefault("user", None)
    new.setdefault("password", None)
    cands.append(new)


# --- 파일 타입별 파서 ----------------------------------------------------

def parse_properties(text: str, src: str):
    """application.properties / application-test.properties 파싱."""
    out = []
    props = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        props[k.strip()] = v.strip()

    # 1) Spring Boot style
    url = props.get("spring.datasource.url") or props.get("db.url") or props.get("datasource.url")
    user = props.get("spring.datasource.username") or props.get("db.username") or props.get("datasource.username")
    pwd = props.get("spring.datasource.password") or props.get("db.password") or props.get("datasource.password")
    driver_class = (props.get("spring.datasource.driver-class-name") or props.get("db.driver") or "").lower()

    if url and looks_like_postgres(url) or looks_like_postgres(driver_class):
        cand = parse_jdbc_url(url) if url else None
        if cand:
            if user: cand["user"] = user
            if pwd: cand["password"] = pwd
            cand["source_files"] = [src]
            out.append(cand)

    return out


def parse_yaml_like(text: str, src: str):
    """간단한 YAML 라인 추적 (들여쓰기 + key: value)."""
    out = []
    lines = text.splitlines()
    # 컨텍스트 스택 형식: [(indent, key)]
    stack = []
    flat = {}
    for raw in lines:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        # 들여쓰기 깊이
        indent = len(raw) - len(raw.lstrip(" "))
        line = raw.strip()
        # 스택 정리
        while stack and stack[-1][0] >= indent:
            stack.pop()
        # key: value 형식?
        if ":" in line:
            key, _, val = line.partition(":")
            key = key.strip()
            val = val.strip().strip('"').strip("'")
            path = ".".join([s[1] for s in stack] + [key])
            if val and not val.startswith("|") and not val.startswith(">"):
                flat[path] = val
            stack.append((indent, key))

    # spring.datasource 류
    url = (flat.get("spring.datasource.url")
           or flat.get("datasource.url")
           or flat.get("db.url"))
    user = (flat.get("spring.datasource.username")
            or flat.get("datasource.username")
            or flat.get("db.username"))
    pwd = (flat.get("spring.datasource.password")
           or flat.get("datasource.password")
           or flat.get("db.password"))
    driver_class = (flat.get("spring.datasource.driver-class-name") or "").lower()

    if (url and looks_like_postgres(url)) or looks_like_postgres(driver_class):
        cand = parse_jdbc_url(url) if url else None
        if cand:
            if user: cand["user"] = user
            if pwd: cand["password"] = pwd
            cand["source_files"] = [src]
            out.append(cand)

    # docker-compose: services.*.environment.POSTGRES_*
    pg_user = None
    pg_pwd = None
    pg_db = None
    for k, v in flat.items():
        kl = k.lower()
        if kl.endswith(".postgres_user"):
            pg_user = v
        elif kl.endswith(".postgres_password"):
            pg_pwd = v
        elif kl.endswith(".postgres_db"):
            pg_db = v
    if pg_db:
        merge_candidate(out, {
            "driver": "postgresql",
            "host": "localhost", "port": DEFAULT_PG_PORT,
            "database": pg_db, "user": pg_user, "password": pg_pwd,
            "schema": None, "source_files": [src],
        })

    # Rails database.yml: production: adapter: postgresql ...
    adapter_lines = [k for k in flat if k.endswith(".adapter")]
    for ak in adapter_lines:
        if "postgres" not in flat[ak].lower():
            continue
        prefix = ak[: -len(".adapter")]
        host = flat.get(prefix + ".host", "localhost")
        port = flat.get(prefix + ".port", str(DEFAULT_PG_PORT))
        db = flat.get(prefix + ".database")
        user = flat.get(prefix + ".username")
        pwd = flat.get(prefix + ".password")
        if db:
            try:
                port_i = int(port)
            except Exception:
                port_i = DEFAULT_PG_PORT
            merge_candidate(out, {
                "driver": "postgresql", "host": host, "port": port_i,
                "database": db, "user": user, "password": pwd,
                "schema": None, "source_files": [src],
            })

    return out


def parse_env(text: str, src: str):
    out = []
    env = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[len("export "):]
        if "=" not in line:
            continue
        k, _, v = line.partition("=")
        env[k.strip().upper()] = v.strip().strip('"').strip("'")

    url = (env.get("DATABASE_URL") or env.get("DB_URL")
           or env.get("POSTGRES_URL") or env.get("PG_URL"))
    if url:
        cand = parse_jdbc_url(url)
        if cand:
            cand["source_files"] = [src]
            out.append(cand)

    host = env.get("DB_HOST") or env.get("POSTGRES_HOST") or env.get("PGHOST")
    port = env.get("DB_PORT") or env.get("POSTGRES_PORT") or env.get("PGPORT")
    db = env.get("DB_NAME") or env.get("POSTGRES_DB") or env.get("PGDATABASE") or env.get("DB_DATABASE")
    user = env.get("DB_USER") or env.get("POSTGRES_USER") or env.get("PGUSER") or env.get("DB_USERNAME")
    pwd = env.get("DB_PASSWORD") or env.get("POSTGRES_PASSWORD") or env.get("PGPASSWORD")
    driver = (env.get("DB_DRIVER") or env.get("DB_DIALECT") or "").lower()

    if host and db and (looks_like_postgres(driver) or not driver):
        try:
            port_i = int(port) if port else DEFAULT_PG_PORT
        except Exception:
            port_i = DEFAULT_PG_PORT
        merge_candidate(out, {
            "driver": "postgresql", "host": host, "port": port_i,
            "database": db, "user": user, "password": pwd,
            "schema": None, "source_files": [src],
        })

    return out


def parse_prisma(text: str, src: str):
    out = []
    # datasource db { provider = "postgresql" url = env("DATABASE_URL") }
    if not re.search(r"provider\s*=\s*\"postgres", text, flags=re.IGNORECASE):
        return out
    m = re.search(r"url\s*=\s*\"([^\"]+)\"", text)
    if m:
        cand = parse_jdbc_url(m.group(1))
        if cand:
            cand["source_files"] = [src]
            out.append(cand)
    return out


def parse_django(text: str, src: str):
    """settings.py 의 DATABASES 블록을 매우 단순하게 파싱."""
    out = []
    if "DATABASES" not in text:
        return out
    if "postgres" not in text.lower():
        return out
    def grab(key):
        m = re.search(rf"['\"]{key}['\"]\s*:\s*['\"]([^'\"]+)['\"]", text)
        return m.group(1) if m else None
    host = grab("HOST") or "localhost"
    port = grab("PORT") or str(DEFAULT_PG_PORT)
    db = grab("NAME")
    user = grab("USER")
    pwd = grab("PASSWORD")
    if not db:
        return out
    try:
        port_i = int(port)
    except Exception:
        port_i = DEFAULT_PG_PORT
    merge_candidate(out, {
        "driver": "postgresql", "host": host, "port": port_i,
        "database": db, "user": user, "password": pwd,
        "schema": None, "source_files": [src],
    })
    return out


# --- 파일 스캔 -----------------------------------------------------------

def should_scan(name: str) -> bool:
    if name in SCAN_FILE_NAMES:
        return True
    for p in SCAN_FILE_PATTERNS:
        if p.match(name):
            return True
    return False


def read_text(path: Path):
    for enc in ("utf-8", "utf-8-sig", "cp949", "latin-1"):
        try:
            return path.read_text(encoding=enc, errors="strict")
        except UnicodeDecodeError:
            continue
        except Exception:
            return None
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None


def scan_dir(root: Path):
    cands = []
    seen_files = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for fn in filenames:
            if not should_scan(fn):
                continue
            fpath = Path(dirpath) / fn
            try:
                rel = str(fpath.relative_to(root)).replace("\\", "/")
            except Exception:
                rel = str(fpath)
            text = read_text(fpath)
            if text is None:
                continue
            new_cands = []
            try:
                if fn.endswith(".properties"):
                    new_cands += parse_properties(text, rel)
                elif fn.endswith((".yml", ".yaml")):
                    new_cands += parse_yaml_like(text, rel)
                elif fn == "schema.prisma":
                    new_cands += parse_prisma(text, rel)
                elif fn == "settings.py":
                    new_cands += parse_django(text, rel)
                elif fn.startswith(".env") or fn.endswith(".env"):
                    new_cands += parse_env(text, rel)
            except Exception as e:
                print(f"[SD_333_WIN] WARN: 파싱 실패 {rel}: {e}", file=sys.stderr)
                continue
            if new_cands:
                seen_files.append(rel)
            for nc in new_cands:
                merge_candidate(cands, nc)
    return cands, seen_files


def main():
    if len(sys.argv) < 2:
        print("usage: 01_scan_config.py <디렉토리경로>", file=sys.stderr)
        sys.exit(2)
    raw = sys.argv[1]
    target = Path(normalize_path(raw))
    if not target.exists() or not target.is_dir():
        print(f"[SD_333_WIN] 디렉토리가 존재하지 않습니다: {target}", file=sys.stderr)
        sys.exit(2)

    TMP_DIR.mkdir(parents=True, exist_ok=True)
    cands, files = scan_dir(target)

    out = {
        "scanned_dir": str(target).replace("\\", "/"),
        "scanned_files": files,
        "candidates": cands,
    }
    out_path = TMP_DIR / "db_candidates.json"
    out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[SD_333_WIN] 후보 {len(cands)} 건 → {out_path}")
    for i, c in enumerate(cands, 1):
        host = c.get("host"); port = c.get("port"); db = c.get("database")
        user = c.get("user") or "(no user)"
        has_pw = "***" if c.get("password") else "(no password)"
        print(f"  [{i}] postgresql {host}:{port}/{db}  user={user}  password={has_pw}")


if __name__ == "__main__":
    main()
