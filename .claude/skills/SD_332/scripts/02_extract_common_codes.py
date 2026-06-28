#!/usr/bin/env python3
"""
[SD_332] 2단계 — 공통코드 추출

DB 종류(PostgreSQL/MySQL/MariaDB/MSSQL)에 따라 적절한 라이브러리로 접속하여
sm_comm_h(공통코드 그룹), sm_comm_d(상세코드)를 조회한다.

사용법:
  python3 02_extract_common_codes.py [--check-only]

입력: deliverables/30-output/04 구현(PI)/tmp/db_target.json
출력: deliverables/30-output/04 구현(PI)/tmp/common_codes.json
"""

from __future__ import annotations

import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

BASE = Path(__file__).resolve().parents[4]
TMP_DIR = BASE / "deliverables" / "30-output" / "04 구현(PI)" / "tmp"
IN_FILE = TMP_DIR / "db_target.json"
OUT_FILE = TMP_DIR / "common_codes.json"


REQUIRED_LIBS = {
    "postgresql": [("psycopg2", "psycopg2-binary")],
    "mysql": [("pymysql", "pymysql")],
    "mssql": [("pymssql", "pymssql")],
}


def check_libs(driver: str | None) -> list[tuple[str, str]]:
    """누락된 (모듈명, pip 패키지명) 리스트 반환."""
    missing: list[tuple[str, str]] = []
    needed: list[tuple[str, str]] = []
    if driver and driver in REQUIRED_LIBS:
        needed.extend(REQUIRED_LIBS[driver])
    elif driver is None:
        # check-only 모드: 모든 driver 라이브러리 체크
        for libs in REQUIRED_LIBS.values():
            needed.extend(libs)
    needed.append(("openpyxl", "openpyxl"))

    for mod, pkg in needed:
        try:
            __import__(mod)
        except ImportError:
            missing.append((mod, pkg))
    return missing


# ---------------------------------------------------------------------------
# 공통 SQL
# ---------------------------------------------------------------------------

SQL_GROUPS = """
SELECT
  biz_seq,
  comm_h_cd,
  comm_h_nm,
  user_cd_yn,
  inout_cd,
  use_yn
FROM sm_comm_h
ORDER BY biz_seq, comm_h_cd
""".strip()

SQL_DETAILS = """
SELECT
  biz_seq,
  comm_h_cd,
  comm_d_cd,
  comm_d_nm,
  ref_h_cd,
  ref_d_cd,
  disp_no,
  disp_yn,
  use_yn
FROM sm_comm_d
ORDER BY biz_seq, comm_h_cd, disp_no, comm_d_cd
""".strip()


# ---------------------------------------------------------------------------
# Driver별 connect helper
# ---------------------------------------------------------------------------

def connect(target: dict[str, Any]):
    driver = target["driver"]
    if driver == "postgresql":
        import psycopg2  # type: ignore
        conn = psycopg2.connect(
            host=target["host"],
            port=int(target.get("port") or 5432),
            dbname=target["database"],
            user=target["user"],
            password=target["password"],
            connect_timeout=10,
        )
        # 스키마 search_path 설정
        schema = target.get("schema") or "public"
        with conn.cursor() as cur:
            cur.execute(f"SET search_path TO {schema}, public")
        return conn
    if driver == "mysql":
        import pymysql  # type: ignore
        return pymysql.connect(
            host=target["host"],
            port=int(target.get("port") or 3306),
            database=target["database"],
            user=target["user"],
            password=target["password"],
            charset="utf8mb4",
            connect_timeout=10,
        )
    if driver == "mssql":
        import pymssql  # type: ignore
        return pymssql.connect(
            server=target["host"],
            port=int(target.get("port") or 1433),
            database=target["database"],
            user=target["user"],
            password=target["password"],
            timeout=10,
            login_timeout=10,
            charset="UTF-8",
        )
    raise ValueError(f"지원하지 않는 driver: {driver}")


def fetch_dicts(conn, sql: str) -> list[dict[str, Any]]:
    cur = conn.cursor()
    try:
        cur.execute(sql)
        cols = [d[0].lower() for d in cur.description]
        rows = cur.fetchall()
        out: list[dict[str, Any]] = []
        for r in rows:
            d = dict(zip(cols, r))
            # 값 normalize: bytes → str, datetime은 str
            for k, v in list(d.items()):
                if isinstance(v, bytes):
                    d[k] = v.decode("utf-8", errors="replace")
                elif hasattr(v, "isoformat"):
                    d[k] = v.isoformat()
            out.append(d)
        return out
    finally:
        cur.close()


def main() -> int:
    args = sys.argv[1:]

    # --check-only
    if "--check-only" in args:
        # target이 있으면 driver별 체크, 없으면 전체 체크
        driver: str | None = None
        if IN_FILE.exists():
            try:
                t = json.loads(IN_FILE.read_text(encoding="utf-8"))
                driver = t.get("driver")
            except Exception:
                driver = None
        missing = check_libs(driver)
        if missing:
            print("[MISSING]")
            for mod, pkg in missing:
                print(f"  - {mod}  (pip install --user {pkg})")
            return 1
        print("[OK] 필요한 라이브러리가 모두 설치되어 있습니다.")
        return 0

    if not IN_FILE.exists():
        print(f"[ERROR] {IN_FILE} 가 없습니다. 1단계(스캔/사용자 확인) 먼저 수행하세요.", file=sys.stderr)
        return 2

    target = json.loads(IN_FILE.read_text(encoding="utf-8"))
    driver = target.get("driver")
    if not driver:
        print("[ERROR] db_target.json 에 driver 필드가 없습니다.", file=sys.stderr)
        return 2

    missing = check_libs(driver)
    if missing:
        print("[ERROR] 누락된 Python 라이브러리:", file=sys.stderr)
        for mod, pkg in missing:
            print(f"  - {mod}  (pip install --user {pkg})", file=sys.stderr)
        return 3

    # 접속 + 조회
    print(f"[INFO] DB 접속: {driver}://{target.get('host')}:{target.get('port')}/{target.get('database')}")
    try:
        conn = connect(target)
    except Exception as e:
        print(f"[ERROR] 접속 실패: {e}", file=sys.stderr)
        return 4

    try:
        try:
            groups = fetch_dicts(conn, SQL_GROUPS)
        except Exception as e:
            print(f"[ERROR] sm_comm_h 조회 실패: {e}", file=sys.stderr)
            print(f"  실행한 SQL:\n{SQL_GROUPS}", file=sys.stderr)
            return 5

        try:
            details = fetch_dicts(conn, SQL_DETAILS)
        except Exception as e:
            print(f"[ERROR] sm_comm_d 조회 실패: {e}", file=sys.stderr)
            print(f"  실행한 SQL:\n{SQL_DETAILS}", file=sys.stderr)
            return 5
    finally:
        try:
            conn.close()
        except Exception:
            pass

    out = {
        "extracted_at": datetime.now().isoformat(timespec="seconds"),
        "db": {
            "driver": driver,
            "host": target.get("host"),
            "port": target.get("port"),
            "database": target.get("database"),
            "schema": target.get("schema"),
            "profile": target.get("profile"),
        },
        "groups": groups,
        "details": details,
    }
    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUT_FILE.write_text(json.dumps(out, ensure_ascii=False, indent=2, default=str), encoding="utf-8")

    used = sum(1 for g in groups if (g.get("use_yn") or "Y").upper() == "Y")
    unused = len(groups) - used
    print(f"[OK] 추출 완료: 그룹 {len(groups)}건 (사용 {used} / 미사용 {unused}), 상세 {len(details)}건")
    print(f"저장 완료: {OUT_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
