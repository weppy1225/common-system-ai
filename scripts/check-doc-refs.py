#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check-doc-refs.py — rules <-> patterns 문서 참조 무결성 가드

검출 항목:
  ERROR  깨진 참조 — 문서가 가리키는 patterns/*.md 경로가 실제로 없음
  WARN   미참조 패턴 — patterns/*.md(00-overview 제외)를 아무 문서도 참조하지 않음 (신규 문서 누락 후보)

스캔 대상: .claude/rules/, patterns/, knowledgebase/, CLAUDE.md, STRUCTURE.md, README.md

종료 코드: ERROR 있으면 1, 없으면 0 (CI/커밋 훅 게이트용)

실행: python scripts/check-doc-refs.py
"""
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 참조를 스캔할 문서들
SCAN_DIRS = [".claude/rules", "patterns", "knowledgebase"]
SCAN_FILES = ["CLAUDE.md", "STRUCTURE.md", "README.md"]

# patterns/...md 형태의 repo-상대 참조.
# 앞에 경로구분자(/)·단어문자가 붙은 하위경로 내 'patterns/' 는 제외한다 —
# 예: spec/{$PROJECT}/_knowledge/patterns/... (프로젝트 템플릿 경로),
#     knowledgebase/domains/oms/patterns/... (도메인 상대경로).
# 이들은 repo-root patterns/ 가 아니므로 무결성 검사 대상이 아니다(오탐 방지).
RE_PATTERN_REF = re.compile(r"(?<![/\w])patterns/[A-Za-z0-9/_.\-]+\.md")
# 마크다운 상대 링크 (./xxx.md, ../xxx.md)
RE_REL_LINK = re.compile(r"\]\((\.{1,2}/[A-Za-z0-9/_.\-]+\.md)\)")


def norm(p):
    return os.path.normpath(p).replace(os.sep, "/")


def check_bom():
    """전 .md 파일에서 UTF-8 BOM(EF BB BF) 검출. BOM 은 frontmatter 첫 줄(---)
    파싱을 방해해 rule 조건부 로딩이 깨질 수 있으므로 ERROR 로 막는다.
    재발 방지: .editorconfig(charset=utf-8) 가 에디터 단에서 1차 차단, 본 검사가 게이트."""
    bom_files = []
    for p in glob.glob(os.path.join(ROOT, "**", "*.md"), recursive=True):
        rel = norm(os.path.relpath(p, ROOT))
        if rel.startswith("node_modules/") or "/node_modules/" in rel:
            continue
        try:
            with open(p, "rb") as fh:
                if fh.read(3) == b"\xef\xbb\xbf":
                    bom_files.append(rel)
        except OSError:
            continue
    return sorted(bom_files)


def collect_scan_files():
    files = []
    for d in SCAN_DIRS:
        files += glob.glob(os.path.join(ROOT, d, "**", "*.md"), recursive=True)
    for f in SCAN_FILES:
        fp = os.path.join(ROOT, f)
        if os.path.isfile(fp):
            files.append(fp)
    return files


def main():
    # Windows 콘솔(cp949)에서 em-dash 등 출력 시 크래시 방지
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    scan_files = collect_scan_files()
    referenced = set()   # 참조된 patterns/*.md (repo-상대 정규화)
    broken = []          # (참조한 문서, 깨진 경로)

    for sf in scan_files:
        sf_rel = norm(os.path.relpath(sf, ROOT))
        sf_dir = os.path.dirname(sf)
        with open(sf, encoding="utf-8") as fh:
            text = fh.read()

        refs = set(RE_PATTERN_REF.findall(text))
        # 상대 링크는 해당 파일 기준으로 resolve
        for rel in RE_REL_LINK.findall(text):
            resolved = norm(os.path.relpath(os.path.join(sf_dir, rel), ROOT))
            if resolved.startswith("patterns/"):
                refs.add(resolved)

        for ref in refs:
            ref_n = norm(ref)
            referenced.add(ref_n)
            if not os.path.isfile(os.path.join(ROOT, ref_n)):
                broken.append((sf_rel, ref_n))

    # 미참조 패턴 문서 (00-overview.md = 인덱스이므로 제외)
    all_patterns = {
        norm(os.path.relpath(p, ROOT))
        for p in glob.glob(os.path.join(ROOT, "patterns", "**", "*.md"), recursive=True)
    }
    orphans = sorted(
        p for p in all_patterns
        if not p.endswith("00-overview.md") and p not in referenced
    )

    print("=== rules <-> patterns 참조 무결성 ===")
    print(f"스캔 문서 {len(scan_files)}개 | 참조 {len(referenced)}개 | 패턴 문서 {len(all_patterns)}개\n")

    if broken:
        print(f"[ERROR] 깨진 참조 {len(broken)}건:")
        for src, ref in sorted(broken):
            print(f"  - {src}  ->  {ref}  (없음)")
    else:
        print("[OK] 깨진 참조 없음")

    if orphans:
        print(f"\n[WARN] 미참조 패턴 문서 {len(orphans)}건 (rule/문서에서 안 가리킴 — 누락 후보):")
        for o in orphans:
            print(f"  - {o}")
    else:
        print("[OK] 미참조 패턴 문서 없음")

    # --- BOM 검사 ---
    bom_files = check_bom()
    print("\n=== UTF-8 BOM 검사 (.md 전수) ===")
    if bom_files:
        print(f"[ERROR] BOM 포함 문서 {len(bom_files)}건 (frontmatter 파싱 방해 — 제거 필요):")
        for b in bom_files:
            print(f"  - {b}")
    else:
        print("[OK] BOM 포함 문서 없음")

    return 1 if (broken or bom_files) else 0


if __name__ == "__main__":
    sys.exit(main())
