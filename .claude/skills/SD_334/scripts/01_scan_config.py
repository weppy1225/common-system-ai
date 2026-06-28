#!/usr/bin/env python3
"""
SD_334 1단계 - 디렉토리 스캔으로 DB 접속정보 후보 추출.

사용법:
    python3 01_scan_config.py <디렉토리경로>

산출물:
    deliverables/30-output/03 설계(SD)/tmp/db_candidates.json

YAML/TOML/JS 등 외부 라이브러리 없이 표준 라이브러리만 사용한다.
완벽한 파싱은 어려우므로 라인 기반 정규식·간단한 구조 추적으로 후보를 모은다.
"""

import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse, unquote

BASE_DIR = Path(__file__).resolve().parents[4]
TMP_DIR = BASE_DIR / "deliverables/30-output/03 설계(SD)/tmp"

DRIVER_ALIASES = {
    "postgres": "postgresql",
    "postgresql": "postgresql",
    "psql": "postgresql",
    "pg": "postgresql",
    "psycopg2": "postgresql",
    "psycopg": "postgresql",
    "mysql": "mysql",
    "mariadb": "mysql",
    "mysql2": "mysql",
    "pymysql": "mysql",
    "mssql": "mssql",
    "sqlserver": "mssql",
    "sql_server": "mssql",
    "tedious": "mssql",
    "pymssql": "mssql",
    "pyodbc": "mssql",
    "oracle": "oracle",
    "oracledb": "oracle",
    "cx_oracle": "oracle",
}

DEFAULT_PORTS = {
    "postgresql": 5432,
    "mysql": 3306,
    "mssql": 1433,
    "oracle": 1521,
}

SCAN_FILE_NAMES = {
    "application.yml", "application.yaml", "application.properties",
    "database.yml", "database.yaml",
    "settings.py",
    "knexfile.js", "knexfile.ts", "knexfile.cjs",
    "web.config",
    "schema.prisma",
    "docker-compose.yml", "docker-compose.yaml",
}

SCAN_FILE_PATTERNS = [
    re.compile(r"^\.env(\..+)?$"),
    re.compile(r"^.*\.env$"),
    re.compile(r"^appsettings.*\.json$", re.IGNORECASE),
    re.compile(r"^application-.+\.ya?ml$"),
    re.compile(r"^application-.+\.properties$"),
    re.compile(r"^(db|database|datasource)\.(json|ya?ml|properties)$", re.IGNORECASE),
    re.compile(r"^config\.(json|ya?ml)$"),
    re.compile(r"^.*\.connstr$", re.IGNORECASE),
]

SKIP_DIRS = {"node_modules", ".git", ".venv", "venv", "__pycache__", "dist", "build", ".idea", ".vscode", "target", "bin", "obj"}


def normalize_driver(value):
    if not value:
        return None
    v = str(value).lower().strip()
    # JDBC URL일 수 있음 - jdbc:postgresql://...
    if v.startswith("jdbc:"):
        v = v[5:].split(":", 1)[0]
    # mysql+pymysql:// 같은 SQLAlchemy 형식
    if "+" in v:
        v = v.split("+", 1)[0]
    if "://" in v:
        v = v.split("://", 1)[0]
    return DRIVER_ALIASES.get(v, None)


def parse_url(url):
    """다양한 형식의 DB URL을 파싱한다."""
    if not url:
        return None
    url = url.strip().strip('"').strip("'")
    if not url:
        return None

    # log4jdbc / p6spy 등 wrapper prefix 제거: jdbc:log4jdbc:postgresql:// → jdbc:postgresql://
    url = re.sub(r"^jdbc:(log4jdbc|p6spy|jdbcdslog):", "jdbc:", url, flags=re.IGNORECASE)

    # JDBC URL: jdbc:postgresql://host:port/db?params
    jdbc_match = re.match(r"^jdbc:([^:]+):(?://)?(.*)$", url, re.IGNORECASE)
    if jdbc_match:
        sub_driver = jdbc_match.group(1)
        rest = jdbc_match.group(2)
        # SQL Server JDBC: jdbc:sqlserver://host:port;databaseName=xxx
        if sub_driver.lower() in {"sqlserver", "mssql"}:
            return _parse_sqlserver_jdbc(rest)
        if sub_driver.lower() == "oracle":
            return _parse_oracle_jdbc(rest)
        # 일반: postgresql, mysql 등 - URL 형식과 유사
        url = f"{sub_driver}://{rest}"

    # SQLAlchemy / 일반 URL 형식
    try:
        u = urlparse(url)
    except Exception:
        return None
    if not u.scheme:
        return None
    driver = normalize_driver(u.scheme)
    if not driver:
        return None
    host = u.hostname or ""
    port = u.port or DEFAULT_PORTS.get(driver)
    db = (u.path or "").lstrip("/") or ""
    user = unquote(u.username) if u.username else ""
    password = unquote(u.password) if u.password else ""
    if not host and not db:
        return None
    return {
        "driver": driver,
        "host": host,
        "port": port,
        "database": db,
        "user": user,
        "password": password,
    }


def _parse_sqlserver_jdbc(rest):
    """jdbc:sqlserver://host:port;databaseName=xxx;user=...;password=..."""
    parts = rest.split(";")
    host_port = parts[0]
    host, port = host_port, DEFAULT_PORTS["mssql"]
    if ":" in host_port:
        host, p = host_port.split(":", 1)
        try:
            port = int(p)
        except ValueError:
            pass
    info = {"driver": "mssql", "host": host, "port": port, "database": "", "user": "", "password": ""}
    for kv in parts[1:]:
        if "=" not in kv:
            continue
        k, v = kv.split("=", 1)
        k = k.strip().lower()
        v = v.strip()
        if k in ("databasename", "database"):
            info["database"] = v
        elif k in ("user", "username", "userid"):
            info["user"] = v
        elif k == "password":
            info["password"] = v
    return info


def _parse_oracle_jdbc(rest):
    """jdbc:oracle:thin:@host:port:SID  또는  jdbc:oracle:thin:user/pass@host:port/service"""
    info = {"driver": "oracle", "host": "", "port": DEFAULT_PORTS["oracle"], "database": "", "user": "", "password": ""}
    if rest.startswith("thin:"):
        rest = rest[5:]
    if "@" in rest:
        cred, conn = rest.split("@", 1)
        if "/" in cred:
            info["user"], info["password"] = cred.split("/", 1)
        # conn: host:port:SID 또는 host:port/service
        m = re.match(r"^([^:/]+)(?::(\d+))?[:/](.+)$", conn)
        if m:
            info["host"] = m.group(1)
            if m.group(2):
                info["port"] = int(m.group(2))
            info["database"] = m.group(3)
            return info
    return None


def detect_driver_from_dialect(value):
    """`spring.datasource.driver-class-name`이나 client 이름에서 driver 추출."""
    if not value:
        return None
    v = str(value).lower()
    if "postgres" in v:
        return "postgresql"
    if "mariadb" in v or "mysql" in v:
        return "mysql"
    if "sqlserver" in v or "mssql" in v:
        return "mssql"
    if "oracle" in v:
        return "oracle"
    return None


def merge(a, b):
    """후보 a에 b의 부족한 필드를 보충한다."""
    for k, v in b.items():
        if v in (None, ""):
            continue
        if a.get(k) in (None, ""):
            a[k] = v
    return a


def fingerprint(c):
    return (c.get("driver") or "", (c.get("host") or "").lower(), c.get("port") or 0, (c.get("database") or "").lower())


# ---------- 파서들 ----------

def parse_env_text(text):
    """KEY=VALUE 형식, 라인 단위 파싱."""
    cands = []
    kv = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.lower().startswith("export "):
            line = line[7:]
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        kv[k] = v

    # DATABASE_URL 류 우선
    for url_key in ("DATABASE_URL", "DB_URL", "JDBC_URL", "SPRING_DATASOURCE_URL"):
        if url_key in kv:
            c = parse_url(kv[url_key])
            if c:
                cands.append(c)

    # 일반 KEY=VALUE 조합
    base = {"driver": None, "host": None, "port": None, "database": None, "user": None, "password": None}
    base["driver"] = (
        detect_driver_from_dialect(kv.get("DB_DIALECT"))
        or detect_driver_from_dialect(kv.get("DB_DRIVER"))
        or normalize_driver(kv.get("DB_TYPE"))
        or normalize_driver(kv.get("DB_CONNECTION"))
    )
    for hk in ("DB_HOST", "POSTGRES_HOST", "MYSQL_HOST", "DATABASE_HOST", "PGHOST", "MYSQLHOST"):
        if hk in kv:
            base["host"] = kv[hk]
            break
    for pk in ("DB_PORT", "POSTGRES_PORT", "MYSQL_PORT", "DATABASE_PORT", "PGPORT", "MYSQLPORT"):
        if pk in kv:
            try:
                base["port"] = int(kv[pk])
            except ValueError:
                pass
            break
    for dk in ("DB_NAME", "DB_DATABASE", "POSTGRES_DB", "MYSQL_DATABASE", "DATABASE_NAME", "PGDATABASE"):
        if dk in kv:
            base["database"] = kv[dk]
            break
    for uk in ("DB_USER", "DB_USERNAME", "POSTGRES_USER", "MYSQL_USER", "DATABASE_USER", "PGUSER"):
        if uk in kv:
            base["user"] = kv[uk]
            break
    for pk in ("DB_PASSWORD", "DB_PASS", "POSTGRES_PASSWORD", "MYSQL_PASSWORD", "DATABASE_PASSWORD", "PGPASSWORD"):
        if pk in kv:
            base["password"] = kv[pk]
            break

    if any(base[k] for k in ("host", "database", "user")):
        if not base["driver"]:
            # host 변수명에서 추론
            if any(k.startswith("POSTGRES") for k in kv):
                base["driver"] = "postgresql"
            elif any(k.startswith("MYSQL") for k in kv):
                base["driver"] = "mysql"
        if base["driver"] and not base["port"]:
            base["port"] = DEFAULT_PORTS.get(base["driver"])
        cands.append({k: (v or "") for k, v in base.items() if v is not None or k in ("user", "password", "database", "host")})
        # 위 줄이 빈 None을 살리도록 정규화
        cands[-1] = {
            "driver": base["driver"],
            "host": base["host"] or "",
            "port": base["port"] or (DEFAULT_PORTS.get(base["driver"]) if base["driver"] else None),
            "database": base["database"] or "",
            "user": base["user"] or "",
            "password": base["password"] or "",
        }

    return [c for c in cands if c.get("driver")]


def parse_yaml_text(text):
    """간단한 YAML 파서: spring.datasource.* 와 database.yml(Rails) 양쪽을 라인 들여쓰기 기반으로 추적."""
    cands = []
    indent_stack = []  # [(indent, key)]
    flat = {}

    for raw in text.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        # 들여쓰기 수준
        indent = len(raw) - len(raw.lstrip(" "))
        line = raw.strip()
        if line.startswith("- "):
            continue  # 리스트 항목은 단순 무시
        if ":" not in line:
            continue
        key, _, val = line.partition(":")
        key = key.strip()
        val = val.strip().strip('"').strip("'")

        # 들여쓰기 스택 정리
        while indent_stack and indent_stack[-1][0] >= indent:
            indent_stack.pop()
        path = ".".join([k for _, k in indent_stack] + [key]).lower()

        if val == "":
            indent_stack.append((indent, key))
        else:
            flat[path] = val

    # spring.datasource.*
    sd_keys = {k: v for k, v in flat.items() if "datasource" in k}
    if sd_keys:
        url = sd_keys.get("spring.datasource.url") or sd_keys.get("datasource.url")
        c = parse_url(url) if url else None
        if not c:
            c = {"driver": None, "host": "", "port": None, "database": "", "user": "", "password": ""}
        for k, v in sd_keys.items():
            if k.endswith("username") and not c.get("user"):
                c["user"] = v
            elif k.endswith("password") and not c.get("password"):
                c["password"] = v
            elif k.endswith("driver-class-name") or k.endswith("driverclassname"):
                d = detect_driver_from_dialect(v)
                if d and not c.get("driver"):
                    c["driver"] = d
        if c.get("driver"):
            if not c.get("port"):
                c["port"] = DEFAULT_PORTS.get(c["driver"])
            cands.append(c)

    # Rails database.yml 형식: top-level env -> {adapter, host, port, database, username, password}
    # 위 flat 추적이 환경별로 키를 만들어주므로 환경별 단위로 뽑는다.
    # 예: development.adapter, development.host ...
    envs = {}
    for k, v in flat.items():
        parts = k.split(".")
        if len(parts) < 2:
            continue
        env = parts[0]
        sub = parts[-1]
        if sub in {"adapter", "host", "port", "database", "username", "password", "encoding", "pool"}:
            envs.setdefault(env, {})[sub] = v
    for env, info in envs.items():
        if "adapter" not in info:
            continue
        driver = normalize_driver(info["adapter"])
        if not driver:
            continue
        port = None
        if info.get("port"):
            try:
                port = int(info["port"])
            except ValueError:
                port = None
        cands.append({
            "driver": driver,
            "host": info.get("host", "") or "",
            "port": port or DEFAULT_PORTS.get(driver),
            "database": info.get("database", "") or "",
            "user": info.get("username", "") or "",
            "password": info.get("password", "") or "",
        })

    return cands


def parse_properties_text(text):
    """key=value 형식의 .properties 파일."""
    cands = []
    kv = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        kv[k.strip()] = v.strip()

    url = kv.get("spring.datasource.url") or kv.get("datasource.url") or kv.get("db.url")
    c = parse_url(url) if url else None
    if not c:
        c = {"driver": None, "host": "", "port": None, "database": "", "user": "", "password": ""}
    for k, v in kv.items():
        kl = k.lower()
        if kl.endswith(".username") or kl.endswith(".user"):
            c["user"] = c.get("user") or v
        elif kl.endswith(".password") or kl.endswith(".pass"):
            c["password"] = c.get("password") or v
        elif kl.endswith(".driver-class-name") or kl.endswith(".driverclassname"):
            d = detect_driver_from_dialect(v)
            if d and not c.get("driver"):
                c["driver"] = d
    if c.get("driver"):
        if not c.get("port"):
            c["port"] = DEFAULT_PORTS.get(c["driver"])
        cands.append(c)
    return cands


def parse_json_text(text):
    """일반 JSON에서 host/port/database/user/password 키 자동 인식."""
    try:
        data = json.loads(text)
    except Exception:
        return []
    found = []

    def visit(node):
        if isinstance(node, dict):
            # 1) ConnectionStrings 류 (.NET appsettings.json)
            cs = node.get("ConnectionStrings")
            if isinstance(cs, dict):
                for name, val in cs.items():
                    parsed = _parse_dotnet_connstr(val)
                    if parsed:
                        found.append(parsed)
            # 2) 직접 형태: {"host": "...", "port": ..., "database": ...} 등
            keys_lower = {k.lower(): k for k in node.keys() if isinstance(k, str)}
            host_key = next((keys_lower[k] for k in ("host", "server", "hostname", "address") if k in keys_lower), None)
            db_key = next((keys_lower[k] for k in ("database", "dbname", "db", "databasename") if k in keys_lower), None)
            user_key = next((keys_lower[k] for k in ("user", "username", "userid", "uid") if k in keys_lower), None)
            pw_key = next((keys_lower[k] for k in ("password", "pwd") if k in keys_lower), None)
            port_key = next((keys_lower[k] for k in ("port",) if k in keys_lower), None)
            client_key = next((keys_lower[k] for k in ("client", "dialect", "driver", "type") if k in keys_lower), None)

            if (host_key or db_key) and (user_key or pw_key or port_key or client_key):
                driver = None
                if client_key:
                    driver = normalize_driver(node[client_key]) or detect_driver_from_dialect(node[client_key])
                port = None
                if port_key:
                    try:
                        port = int(node[port_key])
                    except (ValueError, TypeError):
                        pass
                cand = {
                    "driver": driver,
                    "host": str(node[host_key]) if host_key else "",
                    "port": port,
                    "database": str(node[db_key]) if db_key else "",
                    "user": str(node[user_key]) if user_key else "",
                    "password": str(node[pw_key]) if pw_key else "",
                }
                if cand["driver"]:
                    if not cand["port"]:
                        cand["port"] = DEFAULT_PORTS.get(cand["driver"])
                    found.append(cand)

            for v in node.values():
                visit(v)
        elif isinstance(node, list):
            for item in node:
                visit(item)

    visit(data)
    return found


def _parse_dotnet_connstr(s):
    """SQL Server style: 'Server=host,port;Database=xxx;User Id=...;Password=...'"""
    if not isinstance(s, str):
        return None
    parts = [p.strip() for p in s.split(";") if p.strip()]
    if not parts or "=" not in parts[0]:
        return None
    info = {"driver": "mssql", "host": "", "port": DEFAULT_PORTS["mssql"], "database": "", "user": "", "password": ""}
    for kv in parts:
        if "=" not in kv:
            continue
        k, v = kv.split("=", 1)
        k = k.strip().lower()
        v = v.strip()
        if k in ("server", "data source", "address", "host"):
            host = v
            if "," in host:
                host, port = host.split(",", 1)
                try:
                    info["port"] = int(port.strip())
                except ValueError:
                    pass
            elif ":" in host:
                host, port = host.split(":", 1)
                try:
                    info["port"] = int(port.strip())
                except ValueError:
                    pass
            info["host"] = host.strip()
        elif k in ("database", "initial catalog"):
            info["database"] = v
        elif k in ("user id", "uid", "user", "username"):
            info["user"] = v
        elif k in ("password", "pwd"):
            info["password"] = v
        elif k == "provider":
            d = detect_driver_from_dialect(v)
            if d:
                info["driver"] = d
    return info if info["host"] or info["database"] else None


def parse_settings_py_text(text):
    """Django settings.py의 DATABASES dict 추출."""
    cands = []
    m = re.search(r"DATABASES\s*=\s*\{", text)
    if not m:
        return cands
    # DATABASES 블록을 대괄호 균형으로 잘라낸다
    start = m.end() - 1  # '{' 위치
    depth = 0
    end = start
    for i in range(start, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    block = text[start:end]
    # 'default'든 다른 키든 모두 처리
    for entry in re.finditer(r"['\"](\w+)['\"]\s*:\s*\{([^{}]+(?:\{[^{}]*\}[^{}]*)*)\}", block):
        body = entry.group(2)
        kv = {}
        for km in re.finditer(r"['\"](\w+)['\"]\s*:\s*(['\"][^'\"]*['\"]|\d+)", body):
            kv[km.group(1).upper()] = km.group(2).strip("'\"")
        engine = kv.get("ENGINE", "")
        driver = detect_driver_from_dialect(engine) or normalize_driver(engine)
        if not driver:
            continue
        port = None
        try:
            port = int(kv.get("PORT") or 0) or None
        except ValueError:
            pass
        cands.append({
            "driver": driver,
            "host": kv.get("HOST", "") or "",
            "port": port or DEFAULT_PORTS.get(driver),
            "database": kv.get("NAME", "") or "",
            "user": kv.get("USER", "") or "",
            "password": kv.get("PASSWORD", "") or "",
        })
    return cands


def parse_knexfile_text(text):
    """knexfile.js / knexfile.ts에서 client + connection 추출 (느슨한 정규식)."""
    cands = []
    # client: 'pg' 또는 client: "mysql"
    for m in re.finditer(r"client\s*:\s*['\"]([^'\"]+)['\"]", text):
        client = m.group(1)
        driver = normalize_driver(client) or detect_driver_from_dialect(client)
        if not driver:
            continue
        # 같은 영역에서 connection 추출
        seg_start = m.end()
        # connection: { ... } 또는 connection: 'url'
        conn_match = re.search(r"connection\s*:\s*(\{[^{}]*\}|['\"][^'\"]+['\"])", text[seg_start:seg_start + 4000])
        if not conn_match:
            cands.append({
                "driver": driver, "host": "", "port": DEFAULT_PORTS.get(driver),
                "database": "", "user": "", "password": ""
            })
            continue
        conn = conn_match.group(1)
        if conn.startswith("'") or conn.startswith('"'):
            c = parse_url(conn.strip("'\""))
            if c:
                cands.append(c)
                continue
        # 객체 형식
        kv = {}
        for km in re.finditer(r"(\w+)\s*:\s*['\"]([^'\"]+)['\"]", conn):
            kv[km.group(1).lower()] = km.group(2)
        for km in re.finditer(r"(\w+)\s*:\s*(\d+)", conn):
            kv[km.group(1).lower()] = km.group(2)
        port = None
        try:
            port = int(kv.get("port") or 0) or None
        except ValueError:
            pass
        cands.append({
            "driver": driver,
            "host": kv.get("host", "") or "",
            "port": port or DEFAULT_PORTS.get(driver),
            "database": kv.get("database", "") or kv.get("db", "") or "",
            "user": kv.get("user", "") or kv.get("username", "") or "",
            "password": kv.get("password", "") or "",
        })
    return cands


def parse_web_config_text(text):
    """ASP.NET web.config <connectionStrings>"""
    cands = []
    for m in re.finditer(r'<add\s+[^>]*connectionString\s*=\s*"([^"]+)"', text, re.IGNORECASE):
        c = _parse_dotnet_connstr(m.group(1))
        if c:
            cands.append(c)
    return cands


def parse_prisma_text(text):
    """schema.prisma의 datasource 블록"""
    cands = []
    for m in re.finditer(r"datasource\s+\w+\s*\{([^}]+)\}", text):
        body = m.group(1)
        provider_m = re.search(r"provider\s*=\s*['\"]([^'\"]+)['\"]", body)
        url_m = re.search(r"url\s*=\s*(?:env\([\"']([^\"']+)[\"']\)|['\"]([^'\"]+)['\"])", body)
        if not provider_m:
            continue
        # env() 인 경우 원시 URL을 알 수 없으므로 driver만이라도 추출
        driver = normalize_driver(provider_m.group(1))
        if not driver:
            continue
        if url_m and url_m.group(2):
            c = parse_url(url_m.group(2))
            if c:
                cands.append(c)
                continue
        # placeholder 후보
        cands.append({
            "driver": driver, "host": "", "port": DEFAULT_PORTS.get(driver),
            "database": "", "user": "", "password": ""
        })
    return cands


def parse_docker_compose_text(text):
    """docker-compose의 services.*.environment 에서 POSTGRES_* / MYSQL_* 추출."""
    cands = []
    # 매우 단순한 휴리스틱: image: postgres -> postgresql, image: mysql -> mysql 등
    services = re.split(r"^\s{2}\w+:\s*$", text, flags=re.MULTILINE)
    for seg in services:
        image_m = re.search(r"image\s*:\s*['\"]?([^'\"\s:]+)", seg)
        if not image_m:
            continue
        img = image_m.group(1).lower()
        driver = None
        if "postgres" in img:
            driver = "postgresql"
        elif "mariadb" in img or "mysql" in img:
            driver = "mysql"
        elif "mssql" in img or "sqlserver" in img:
            driver = "mssql"
        elif "oracle" in img:
            driver = "oracle"
        if not driver:
            continue
        info = {"driver": driver, "host": "localhost", "port": DEFAULT_PORTS[driver],
                "database": "", "user": "", "password": ""}
        # ports: "5433:5432" → 외부 포트 5433
        port_m = re.search(r"ports\s*:\s*(?:\n\s*-\s*['\"]?(\d+):(\d+))", seg)
        if port_m:
            try:
                info["port"] = int(port_m.group(1))
            except ValueError:
                pass
        # environment 변수
        env_block = re.search(r"environment\s*:\s*\n((?:\s+[-]?\s*\w+\s*[:=]\s*[^\n]+\n?)+)", seg)
        if env_block:
            block = env_block.group(1)
            for em in re.finditer(r"(\w+)\s*[:=]\s*['\"]?([^'\"\n]+)", block):
                k = em.group(1).upper()
                v = em.group(2).strip()
                if k in ("POSTGRES_DB", "MYSQL_DATABASE", "MARIADB_DATABASE", "MSSQL_DB", "ORACLE_DATABASE"):
                    info["database"] = v
                elif k in ("POSTGRES_USER", "MYSQL_USER", "MARIADB_USER", "ORACLE_USER"):
                    info["user"] = v
                elif k in ("POSTGRES_PASSWORD", "MYSQL_PASSWORD", "MYSQL_ROOT_PASSWORD",
                           "MARIADB_PASSWORD", "MARIADB_ROOT_PASSWORD",
                           "MSSQL_SA_PASSWORD", "SA_PASSWORD", "ORACLE_PASSWORD"):
                    info["password"] = v
        cands.append(info)
    return cands


# ---------- 디스패처 ----------

def parse_file(path: Path):
    name = path.name.lower()
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return []

    if name.startswith(".env") or name.endswith(".env"):
        return parse_env_text(text)
    if name in {"application.yml", "application.yaml", "database.yml", "database.yaml"} or re.match(r"application-.+\.ya?ml$", name) or name == "docker-compose.yml" or name == "docker-compose.yaml":
        if "compose" in name:
            return parse_docker_compose_text(text)
        return parse_yaml_text(text)
    if name == "application.properties" or re.match(r"application-.+\.properties$", name):
        return parse_properties_text(text)
    if name == "settings.py":
        return parse_settings_py_text(text)
    if name in {"knexfile.js", "knexfile.ts", "knexfile.cjs"}:
        return parse_knexfile_text(text)
    if name == "web.config":
        return parse_web_config_text(text)
    if name == "schema.prisma":
        return parse_prisma_text(text)
    # appsettings*.json, *.json
    if name.endswith(".json"):
        return parse_json_text(text)
    if name.endswith(".yml") or name.endswith(".yaml"):
        return parse_yaml_text(text)
    if name.endswith(".properties"):
        return parse_properties_text(text)
    return []


def should_scan(name):
    if name in SCAN_FILE_NAMES:
        return True
    for pat in SCAN_FILE_PATTERNS:
        if pat.match(name):
            return True
    return False


def scan_directory(root: Path):
    found = []  # list of (path, candidate)
    for dirpath, dirnames, filenames in os.walk(root):
        # skip 디렉토리 정리
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".terraform")]
        for fn in filenames:
            if not should_scan(fn):
                continue
            p = Path(dirpath) / fn
            try:
                cands = parse_file(p)
            except Exception as e:
                cands = []
            for c in cands:
                found.append((str(p.relative_to(root) if str(p).startswith(str(root)) else p), c))
    return found


def dedupe(found):
    """동일 fingerprint 후보 병합."""
    by_fp = {}
    for path, cand in found:
        # 정규화
        cand.setdefault("host", "")
        cand.setdefault("port", DEFAULT_PORTS.get(cand.get("driver", "")))
        cand.setdefault("database", "")
        cand.setdefault("user", "")
        cand.setdefault("password", "")
        cand.setdefault("source_files", [])
        cand["source_files"] = list(dict.fromkeys(cand.get("source_files", []) + [path]))
        fp = fingerprint(cand)
        if fp in by_fp:
            merged = merge(by_fp[fp], cand)
            merged["source_files"] = list(dict.fromkeys(merged.get("source_files", []) + cand["source_files"]))
            by_fp[fp] = merged
        else:
            by_fp[fp] = cand
    return list(by_fp.values())


def main():
    if len(sys.argv) < 2:
        print("사용법: python3 01_scan_config.py <디렉토리경로>", file=sys.stderr)
        sys.exit(2)

    target = Path(sys.argv[1]).expanduser()
    if not target.exists() or not target.is_dir():
        print(f"디렉토리를 찾을 수 없습니다: {target}", file=sys.stderr)
        sys.exit(2)

    TMP_DIR.mkdir(parents=True, exist_ok=True)

    print(f"[SD_334] 디렉토리 스캔 시작: {target}")
    found = scan_directory(target)
    print(f"[SD_334] 후보 발견: {len(found)}개 (병합 전)")

    cands = dedupe(found)
    print(f"[SD_334] 후보 병합 후: {len(cands)}개")

    out = TMP_DIR / "db_candidates.json"
    payload = {
        "scanned_dir": str(target),
        "candidates": cands,
    }
    out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[SD_334] 저장 완료: {out}")

    for i, c in enumerate(cands, 1):
        masked = "***" if c.get("password") else "(none)"
        print(f"  [{i}] {c.get('driver')} {c.get('host')}:{c.get('port')}/{c.get('database')} user={c.get('user') or '(none)'} pw={masked}")
        for sf in c.get("source_files", [])[:3]:
            print(f"      ← {sf}")


if __name__ == "__main__":
    main()
