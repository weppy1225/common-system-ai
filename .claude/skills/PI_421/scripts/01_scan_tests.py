#!/usr/bin/env python3
"""PI_421 1단계 — JUnit 테스트 메서드 스캔.

사용법:
    python3 01_scan_tests.py <백엔드_디렉토리>

출력:
    output/04 구현(PI)/tmp/tests.json
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

BASE_DIR = Path("/mnt/c/zinide/workspace/cloud-wms-doc")
TMP_DIR = BASE_DIR / "output/04 구현(PI)/tmp"
OUT_JSON = TMP_DIR / "tests.json"

EXCLUDE_DIRS = {
    "node_modules", "dist", "build", "target", ".git",
    ".gradle", ".mvn", "bin", "obj", "out",
    "__pycache__", ".venv", "venv", ".idea", ".vscode",
}

# lv2(또는 lv1) 키워드 → (대메뉴, 플랫폼)
LV2_MAP = [
    # 기준정보
    ("md8000", "기준정보", "WEB"),
    ("master", "기준정보", "WEB"),
    # 입고
    ("iw1000", "입고", "WEB"),
    ("inbound", "입고", "WEB"),
    ("receive", "입고", "WEB"),
    # 반품
    ("rt2000", "반품", "WEB"),
    ("return", "반품", "WEB"),
    # 재고
    ("iv3000", "재고", "WEB"),
    ("iv3100", "재고", "WEB"),
    ("iv3200", "재고", "WEB"),
    ("inventory", "재고", "WEB"),
    ("stock", "재고", "WEB"),
    # 출고
    ("ow5000", "출고", "WEB"),
    ("outbound", "출고", "WEB"),
    ("delivery", "출고", "WEB"),
    ("shipping", "출고", "WEB"),
    # 시스템관리
    ("mm9200", "시스템관리", "WEB"),
    ("sm9000", "시스템관리", "WEB"),
    ("ss9300", "시스템관리", "WEB"),
    ("admin", "시스템관리", "WEB"),
    ("system", "시스템관리", "WEB"),
    # 인터페이스
    ("if9100", "인터페이스", "I/F"),
    ("interface", "인터페이스", "I/F"),
]

# sif/ 또는 if9100 경로면 무조건 I/F
INTERFACE_HINTS = ("if9100", "sif/", "/sif/", "interface")

# 도메인 코드 prefix 정규식 (클래스명에서 추출)
# ZTEST_LGER01Comp → LGER01
# ZTEST_OBRQ01MComp → OBRQ01M
DOMAIN_CODE_RE = re.compile(r"^(?:ZTEST_)?([A-Z]{2,5}[0-9]{2,3}M?)")

# 모듈 타입 suffix → 한글 변환
MODULE_SUFFIX_KO = {
    "Comp": "Comp",
    "Controller": "Controller",
    "Dao": "Dao",
    "Mapper": "Mapper",
    "Service": "Service",
    "SUITE": "Suite",
    "Util": "Util",
}

# method_name → 한글 휴리스틱
METHOD_PATTERNS = [
    (re.compile(r"^findAll[_A-Z]?"), "전체 목록 조회"),
    (re.compile(r"^findById[_A-Z]?"), "단건 조회"),
    (re.compile(r"^getById[_A-Z]?"), "단건 조회"),
    (re.compile(r"^find[_A-Z]"), "조회"),
    (re.compile(r"^get[_A-Z]"), "조회"),
    (re.compile(r"^search[_A-Z]?"), "검색"),
    (re.compile(r"^select[_A-Z]?"), "조회"),
    (re.compile(r"^create[_A-Z]?"), "등록"),
    (re.compile(r"^register[_A-Z]?"), "등록"),
    (re.compile(r"^save[_A-Z]?"), "저장"),
    (re.compile(r"^insert[_A-Z]?"), "등록"),
    (re.compile(r"^update[_A-Z]?"), "수정"),
    (re.compile(r"^modify[_A-Z]?"), "수정"),
    (re.compile(r"^delete[_A-Z]?"), "삭제"),
    (re.compile(r"^remove[_A-Z]?"), "삭제"),
    (re.compile(r"^test_search"), "검색"),
    (re.compile(r"^test_select"), "조회"),
    (re.compile(r"^test_insert"), "등록"),
    (re.compile(r"^test_update"), "수정"),
    (re.compile(r"^test_delete"), "삭제"),
    (re.compile(r"^test_"), "기능 테스트"),
]


def normalize_path(p: str) -> str:
    """Windows 경로(C:\\...)를 WSL 경로로 변환."""
    p = p.strip().strip('"').strip("'")
    if re.match(r"^[A-Za-z]:[\\/]", p):
        drive = p[0].lower()
        rest = p[2:].replace("\\", "/").lstrip("/")
        return f"/mnt/{drive}/{rest}"
    return p


def find_test_files(root: Path) -> list[Path]:
    """JUnit 테스트 후보 파일 수집."""
    candidates: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        # 제외 디렉토리 가지치기
        dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
        for fn in filenames:
            if not (fn.endswith(".java") or fn.endswith(".kt")):
                continue
            # 표준 패턴: src/test/(java|kotlin) 하위
            rel_str = str(Path(dirpath))
            in_test_root = "/src/test/java" in rel_str or "/src/test/kotlin" in rel_str
            name_hits_test = (
                fn.endswith("Test.java") or fn.endswith("Tests.java")
                or fn.startswith("Test") or fn.startswith("ZTEST_")
                or fn.endswith("Test.kt") or fn.endswith("Tests.kt")
            )
            if in_test_root or name_hits_test:
                candidates.append(Path(dirpath) / fn)
    return candidates


_BLOCK_COMMENT_RE = re.compile(r"/\*.*?\*/", re.DOTALL)
_TEST_ANN_RE = re.compile(
    r"@(?:org\.junit\.jupiter\.api\.|org\.junit\.)?Test\b"
    r"(?:\s*\([^)]*\))?",
    re.MULTILINE,
)
_DISPLAY_RE = re.compile(r'@DisplayName\s*\(\s*"([^"]*)"\s*\)')
# 단순화된 메서드 시그니처 매처: void / 타입 + 메서드명(...) { 만 캡처
_METHOD_RE = re.compile(
    r"\b(?:void|[\w<>\[\]\.]+)\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*(?:throws[^{;]*)?\s*\{",
)
_KEYWORDS = {"if", "for", "while", "switch", "return", "new", "catch", "synchronized", "try"}

# 도메인 코드 → 한글 메뉴명 내장 사전 (WMS 표준 코드)
BUILTIN_NAME_DICT = {
    "MDBZ01": "사업장관리",
    "MDCT01": "거래처관리",
    "MDPD01": "품목관리",
    "MDWH01": "창고관리",
    "MDUS01": "사용자관리",
    "MDLC01": "위치관리",
    "MDCR01": "운반사관리",
    "MDSP01": "공급처관리",
    "MDLP01": "로케이션프린트",
    "IWRQ01": "입고예정",
    "IWPC01": "입고처리",
    "IWLB01": "입고라벨",
    "RTRQ01": "반품예정",
    "RTPC01": "반품처리",
    "IVMV01": "재고이동",
    "IVAD01": "재고조정",
    "IVIO01": "수불현황",
    "IVPD01": "재고조회-품목별",
    "IVWH01": "재고조회-창고별",
    "IVMC01": "재고현황",
    "IVST01": "재고현황",
    "IVSK01": "SKU재고",
    "SKHT01": "SKU이력",
    "OBRQ01": "출고예정",
    "OBPC01": "출고처리",
    "OWRC01": "출고처리",
    "OWRB01": "출고예정",
    "OWPC01": "출고처리",
    "DLPC01": "송장처리",
    "DLCX01": "배송취소",
    "DLPB01": "배송점검",
    "LDPC01": "상차확정",
    "SMCC01": "공통코드",
    "SMMN01": "메뉴관리",
    "SMMG01": "시스템관리",
    "SMBD01": "게시판",
    "USCD01": "사용자코드",
    "STRG01": "스캔규칙",
    "STSC01": "스캔체크",
    "SCRG01": "스캔규칙",
    "ALSH01": "알람경보",
    "ALST01": "알람이력",
    "PDST01": "품목상태",
    "BRSC01": "바코드스캔",
    "LGAP01": "로그인",
    "LGCO01": "로그아웃",
    "LGER01": "로그인오류",
    "LGMN01": "로그메뉴",
    "IFBH01": "IF배치이력",
    "SHA256": "SHA256암호화",
}


def strip_block_comments(src: str) -> str:
    return _BLOCK_COMMENT_RE.sub(lambda m: " " * len(m.group(0)), src)


def extract_tests_from_file(path: Path, project_root: Path) -> tuple[list[dict], int]:
    """파일에서 @Test 메서드를 추출. (tests, junit_version) 반환.

    junit_version: 5 / 4 / 0(미정)
    """
    try:
        raw = path.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        print(f"[WARN] read failed: {path} → {e}", file=sys.stderr)
        return [], 0

    junit_v = 0
    if "org.junit.jupiter.api.Test" in raw:
        junit_v = 5
    elif re.search(r"import\s+org\.junit\.Test\b", raw):
        junit_v = 4

    src = strip_block_comments(raw)

    # 라인 시작이 //으로 시작하는 라인을 모두 마스킹
    lines = src.split("\n")
    masked: list[str] = []
    for ln in lines:
        stripped = ln.lstrip()
        if stripped.startswith("//"):
            masked.append(" " * len(ln))
        else:
            # 라인 중간의 // 도 마스킹(거친 처리)
            idx = ln.find("//")
            if idx >= 0:
                masked.append(ln[:idx] + " " * (len(ln) - idx))
            else:
                masked.append(ln)
    src = "\n".join(masked)

    out: list[dict] = []
    # 각 @Test 위치를 찾고, 그 다음에 등장하는 메서드 선언을 매칭
    test_positions = [m.start() for m in _TEST_ANN_RE.finditer(src)]
    if not test_positions:
        return [], junit_v

    rel_file = path.relative_to(project_root)
    class_name = path.stem
    package_path = _derive_package_path(rel_file)

    for pos in test_positions:
        tail = src[pos:pos + 600]  # @Test 이후 600자 윈도우면 충분
        # @DisplayName 이 같은 윈도우 안에 있으면 사용 (Test 어노테이션 이전이 일반적이지만, 그 다음 위치에도 잡힘)
        # → DisplayName은 @Test 전에 올 수도 있으니 -200..+600 윈도우로 따로 본다
        ctx = src[max(0, pos - 200):pos + 600]
        d = _DISPLAY_RE.search(ctx)
        display_name = d.group(1).strip() if d else None
        # 메서드명 추출
        method_name = None
        for m in _METHOD_RE.finditer(tail):
            cand = m.group(1)
            if cand in _KEYWORDS:
                continue
            method_name = cand
            break
        if not method_name:
            continue
        out.append({
            "class_file": str(rel_file).replace("\\", "/"),
            "class_name": class_name,
            "method_name": method_name,
            "display_name": display_name,
            "package_path": package_path,
            "junit_version": junit_v or 5,
        })
    return out, junit_v


def _derive_package_path(rel_file: Path) -> str:
    parts = rel_file.parts
    # src/test/java/<...>/Foo.java 구조에서 java 이후 디렉토리만 추출
    if "java" in parts:
        i = parts.index("java")
        sub = parts[i + 1 : -1]
        return "/".join(sub)
    if "kotlin" in parts:
        i = parts.index("kotlin")
        sub = parts[i + 1 : -1]
        return "/".join(sub)
    # 표준이 아닌 경우 디렉토리 그대로 사용
    return "/".join(rel_file.parts[:-1])


def classify_menu(package_path: str, class_file: str) -> tuple[str, str]:
    """(big_menu, platform) 반환."""
    pkg = package_path.lower()
    cf = class_file.lower()
    # 인터페이스 우선 판정
    for h in INTERFACE_HINTS:
        if h in pkg or h in cf:
            return ("인터페이스", "I/F")
    # fw/ 또는 test/ 시작이면 공통(프레임워크/테스트 헬퍼)
    if pkg.startswith("fw/") or pkg.startswith("test/") or pkg == "test":
        return ("공통", "WEB")
    # bm/ 시작이면 PDA (모바일 백엔드)
    if pkg.startswith("bm/") or "/bm/" in cf:
        platform = "PDA"
    else:
        platform = "WEB"

    # lv2 매핑 검색 (lv1=be|bm 인 경우 lv2 기준)
    segments = pkg.split("/")
    candidates = segments[1:3] if len(segments) >= 2 else segments
    # bm/ 의 경우 lv2 에서 끝의 'm' 제거(예: iv3000m → iv3000)
    norm_candidates = []
    for c in candidates:
        norm_candidates.append(c)
        if c.endswith("m") and len(c) > 3:
            norm_candidates.append(c[:-1])

    for cand in norm_candidates:
        for key, big, _plat in LV2_MAP:
            if cand == key or cand.startswith(key):
                return (big, platform)

    # 매핑 실패: lv1 기준 fallback
    if segments and segments[0] in {"be", "bm"} and len(segments) > 1:
        return (segments[1] or "기타", platform)
    return ("기타", platform)


def extract_domain_code(class_name: str) -> str | None:
    m = DOMAIN_CODE_RE.match(class_name)
    if m:
        return m.group(1)
    return None


def humanize_method(method_name: str) -> str:
    for rx, label in METHOD_PATTERNS:
        if rx.match(method_name):
            return f"{label} - {method_name}"
    return method_name


def make_content(test: dict) -> str:
    if test.get("display_name"):
        return test["display_name"]
    return humanize_method(test["method_name"])


def load_program_name_dict() -> dict[str, str]:
    """PI_412-프로그램목록.xlsx 에서 도메인코드→한글명 사전 학습 (선택적).

    BE 시트 컬럼: Lv1(1) Lv2 ... Lv7(7) 프로그램ID(8) 프로그램명(9) 모듈명(10) ...
    프로그램ID 는 소문자(`mdbz01`) 형태이므로 대문자로 정규화하여 저장한다.
    """
    tpl = BASE_DIR / "template/04 구현(PI)/PI_412-프로그램목록.xlsx"
    result: dict[str, str] = {}
    if not tpl.exists():
        return result
    try:
        import openpyxl
        wb = openpyxl.load_workbook(tpl, data_only=True, read_only=True)
        for sheet_name in wb.sheetnames:
            if "프로그램목록" not in sheet_name:
                continue
            ws = wb[sheet_name]
            for row in ws.iter_rows(min_row=3, values_only=True):
                if not row or len(row) < 9:
                    continue
                pid = row[7]  # 프로그램ID
                pnm = row[8]  # 프로그램명
                if not (isinstance(pid, str) and isinstance(pnm, str)):
                    continue
                pid = pid.strip().upper()
                pnm = pnm.strip()
                if not pid or not pnm or pnm in {"공통"}:
                    continue
                # 같은 program_id에 여러 한글명이 매핑될 수 있으니 첫 값 우선
                result.setdefault(pid, pnm)
        wb.close()
    except Exception as e:
        print(f"[INFO] PI_412 사전 학습 스킵: {e}", file=sys.stderr)
    return result


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Usage: 01_scan_tests.py <백엔드_디렉토리>", file=sys.stderr)
        return 2

    root = Path(normalize_path(argv[1])).resolve()
    if not root.exists() or not root.is_dir():
        print(f"[ERR] 디렉토리가 존재하지 않습니다: {root}", file=sys.stderr)
        return 2

    TMP_DIR.mkdir(parents=True, exist_ok=True)

    print(f"[1/3] 스캔 시작: {root}")
    files = find_test_files(root)
    print(f"  • JUnit 후보 파일: {len(files)}건")
    if not files:
        print("[ERR] Java/Kotlin 테스트 파일이 발견되지 않았습니다.", file=sys.stderr)
        return 1

    name_dict = load_program_name_dict()
    if name_dict:
        print(f"  • PI_412 한글명 사전: {len(name_dict)}개 학습")

    all_tests: list[dict] = []
    junit4 = junit5 = 0
    for i, f in enumerate(files, 1):
        if i % 50 == 0 or i == len(files):
            print(f"  ... {i}/{len(files)} 파일 처리", flush=True)
        tests, jv = extract_tests_from_file(f, root)
        if jv == 4:
            junit4 += 1
        elif jv == 5:
            junit5 += 1
        for t in tests:
            big_menu, platform = classify_menu(t["package_path"], t["class_file"])
            domain_code = extract_domain_code(t["class_name"])
            if domain_code:
                base_code = domain_code.rstrip("M") if domain_code.endswith("M") else domain_code
                # PI_412 사전 → 내장 사전 → 클래스명 fallback
                ko = (
                    name_dict.get(domain_code)
                    or name_dict.get(base_code)
                    or BUILTIN_NAME_DICT.get(domain_code)
                    or BUILTIN_NAME_DICT.get(base_code)
                )
                if not ko:
                    bare = re.sub(r"^ZTEST_", "", t["class_name"])
                    bare = re.sub(r"(Comp|Controller|Dao|Mapper|Service|Util|Suite|Biz)$", "", bare)
                    ko = bare
                menu = f"{ko}({domain_code})"
            else:
                menu = re.sub(r"^ZTEST_", "", t["class_name"])
            t.update({
                "big_menu": big_menu,
                "platform": platform,
                "menu": menu,
                "category": "기능",
                "content": make_content(t),
                "result": "O",
            })
            all_tests.append(t)

    # 정렬: 플랫폼(WEB→PDA→I/F) → 대메뉴 → class_name → 파일 내 등장순서
    PLAT_ORDER = {"WEB": 0, "PDA": 1, "I/F": 2}
    all_tests.sort(key=lambda t: (
        PLAT_ORDER.get(t["platform"], 9),
        t["big_menu"],
        t["class_name"],
    ))

    # 테스트ID 채번
    for idx, t in enumerate(all_tests, start=1):
        t["test_id"] = f"WMS-BE-{idx:03d}"

    result = {
        "scanned_dir": str(root),
        "junit_files": len(files),
        "test_count": len(all_tests),
        "junit4_files": junit4,
        "junit5_files": junit5,
        "tests": all_tests,
    }

    OUT_JSON.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"  • 추출된 @Test 메서드: {len(all_tests)}건")
    print(f"  • JUnit 4 / JUnit 5 파일: {junit4} / {junit5}")
    # 플랫폼별 분포
    for p in ("WEB", "PDA", "I/F"):
        n = sum(1 for t in all_tests if t["platform"] == p)
        print(f"  • {p:<3}: {n}건")
    print(f"[OK] tests.json → {OUT_JSON}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
