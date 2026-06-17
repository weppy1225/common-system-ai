#!/usr/bin/env python3
"""
PI_412 — 1단계: 프로젝트 스캔 및 스택 감지.

지정된 프로젝트 디렉토리에서:
  - 마커 파일(pom.xml/build.gradle/build.xml/.classpath/package.json/...)로 스택 감지
  - 스택별 후보 소스 파일 목록 수집 (파일 단위)
결과: deliverables/30-output/04 구현(PI)/tmp/scan.json

템플릿(PI_412-프로그램목록.xlsx)이 파일 단위로 행을 구성하므로,
컨트롤러 외 Comp/Dao/Mapper(.java/.xml) 등 모든 소스 파일을 수집한다.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Set

REPO_BASE = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
OUT_DIR = REPO_BASE / "deliverables" / "30-output" / "04 구현(PI)"
TMP_DIR = OUT_DIR / "tmp"
OUT_JSON = TMP_DIR / "scan.json"

EXCLUDE_DIRS = {
    "node_modules", "dist", "build", "target", ".git", ".next", ".nuxt",
    ".svelte-kit", "out", "__pycache__", ".venv", "venv", "env",
    ".idea", ".vscode", "coverage", "tmp", ".gradle", ".mvn",
    ".cache", ".turbo", ".parcel-cache", ".tox", ".mypy_cache", ".pytest_cache",
    "bin", "obj",
}

# Spring(Java/Kotlin) 백엔드 — 파일 확장자
SPRING_EXTS = {".java", ".kt", ".xml"}
# FE 후보 확장자
FE_EXTS = {".vue", ".tsx", ".jsx", ".ts", ".js", ".mjs", ".scss", ".css"}
# Python 백엔드
PY_EXTS = {".py"}

# scan.json에 노출할 스택 키
STACKS = ["spring", "frontend", "python"]


def iter_files(root: Path) -> List[Path]:
    out: List[Path] = []
    root_resolved = root.resolve()
    for dirpath, dirnames, filenames in os.walk(root_resolved):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS and not d.startswith(".")]
        for fn in filenames:
            out.append(Path(dirpath) / fn)
    return out


def read_text(path: Path, max_bytes: int = 200_000) -> str:
    try:
        with open(path, "rb") as f:
            return f.read(max_bytes).decode("utf-8", errors="ignore")
    except Exception:
        return ""


def detect_stacks(files: List[Path]) -> Dict[str, bool]:
    """마커와 파일 분포를 보고 활성 스택을 결정한다."""
    stacks: Dict[str, bool] = {s: False for s in STACKS}

    by_name: Dict[str, List[Path]] = {}
    for p in files:
        by_name.setdefault(p.name, []).append(p)

    # Spring(Java/Kotlin): Maven/Gradle/Ant/Eclipse 마커
    if (by_name.get("pom.xml") or by_name.get("build.gradle") or by_name.get("build.gradle.kts")
            or by_name.get("settings.gradle") or by_name.get("build.xml")
            or by_name.get(".classpath") or by_name.get(".project")):
        stacks["spring"] = True
    # 마커 없어도 .java/.kt 다수면 Spring 추정
    if not stacks["spring"]:
        if sum(1 for p in files if p.suffix in (".java", ".kt")) >= 5:
            stacks["spring"] = True

    # Frontend: package.json + Vue/React/JS/TS 다수
    pkg_paths = by_name.get("package.json", [])
    has_pkg = bool(pkg_paths)
    has_vue = any(p.suffix == ".vue" for p in files)
    has_tsx = any(p.suffix in (".tsx", ".jsx") for p in files)
    if has_pkg or has_vue or has_tsx:
        stacks["frontend"] = True

    # Python 백엔드
    if (by_name.get("requirements.txt") or by_name.get("pyproject.toml")
            or by_name.get("setup.py") or by_name.get("manage.py")):
        stacks["python"] = True

    return stacks


def is_under(path_parts: List[str], anchors: List[str]) -> bool:
    """경로 일부 시퀀스에 anchors가 포함되는지 검사 (예: src/main/java)."""
    n = len(anchors)
    for i in range(len(path_parts) - n + 1):
        if path_parts[i:i + n] == anchors:
            return True
    return False


def collect_files(files: List[Path], root: Path, stacks: Dict[str, bool]) -> Dict[str, List[str]]:
    """활성 스택별 후보 소스 파일 수집 (파일 단위)."""
    result: Dict[str, List[str]] = {s: [] for s in STACKS}
    root_resolved = root.resolve()

    for p in files:
        suffix = p.suffix.lower()
        rel = str(p.relative_to(root_resolved)).replace("\\", "/")
        parts = rel.split("/")

        # Spring: src/main/java 또는 src/main/kotlin 하위 .java/.kt/.xml만
        # (resources 하위 logback/sqlmap-config 등 설정 파일은 제외)
        if stacks["spring"] and suffix in SPRING_EXTS:
            in_src_java = is_under(parts, ["src", "main", "java"]) or is_under(parts, ["src", "main", "kotlin"])
            if in_src_java:
                # 테스트 패키지 제외 (src/main/java/test/...)
                if "test" in parts or "tests" in parts:
                    continue
                # ZTEST_*, *Test.java 같은 테스트 파일 제외
                fname = parts[-1]
                if fname.startswith("ZTEST_") or fname.endswith("Test.java") or fname.endswith("Tests.java"):
                    continue
                result["spring"].append(rel)
                continue
            # src/main 구조가 아닌 단순 java 프로젝트도 허용
            if "src" not in parts and suffix in (".java", ".kt"):
                result["spring"].append(rel)
                continue

        # Frontend: src/ 하위 .vue/.tsx/.jsx/.ts/.js/.scss/.css
        if stacks["frontend"] and suffix in FE_EXTS:
            if "src" in parts:
                result["frontend"].append(rel)
                continue

        # Python: 루트 레벨 또는 app/api 하위
        if stacks["python"] and suffix in PY_EXTS:
            if not any(seg in ("tests", "test", "migrations") for seg in parts):
                result["python"].append(rel)
                continue

    # dedup + sort
    for k in result:
        seen: Set[str] = set()
        deduped = []
        for x in result[k]:
            if x not in seen:
                seen.add(x)
                deduped.append(x)
        result[k] = sorted(deduped)
    return result


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: 01_scan_project.py <project_dir>", file=sys.stderr)
        return 2
    target = Path(sys.argv[1]).expanduser()
    if not target.exists() or not target.is_dir():
        print(f"[PI_412] 디렉토리가 존재하지 않거나 디렉토리가 아닙니다: {target}", file=sys.stderr)
        return 2

    TMP_DIR.mkdir(parents=True, exist_ok=True)

    print(f"[PI_412] 1단계 스캔 시작: {target}")
    files = iter_files(target)
    print(f"[PI_412]   - 전체 파일 {len(files)}개 (제외 디렉토리 적용 후)")

    stacks_map = detect_stacks(files)
    active = [s for s, on in stacks_map.items() if on]
    print(f"[PI_412]   - 감지된 스택: {', '.join(active) if active else '(없음)'}")

    by_stack = collect_files(files, target, stacks_map)
    matched = sum(len(v) for v in by_stack.values())
    print(f"[PI_412]   - 후보 파일: {matched}개")
    for s in STACKS:
        if by_stack[s]:
            print(f"[PI_412]       {s}: {len(by_stack[s])}")

    out = {
        "target_dir": str(target.resolve()),
        "stacks": active,
        "files": by_stack,
        "stats": {"scanned": len(files), "matched": matched},
    }
    OUT_JSON.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[PI_412] 완료 → {OUT_JSON}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
