#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
[TT_543_WIN] Vue 소스 파서

특정 메뉴 폴더(예: wms-bnk-fe/src/views/be/sm9000/smmg01)의 .vue 파일을 읽어
운영자 매뉴얼 우측 설명 패널을 채우는 데 필요한 정보를 추출한다.

추출 항목:
    has_search        : <SearchSection> 컴포넌트 존재 여부 (검색 영역 유무)
    search_title      : SearchSection 의 :title 값 ($t('message.XXX') 의 XXX 추출)
    search_code       : SearchSection 의 code 속성 (보통 화면 코드)
    search_fields     : <ZCell :title="..."> 또는 ZCellBox 내 label="..." 등의 검색 필드명
    grid_columns      : columnLayout 의 headerText 값 (visible:false 제외)
    toolbar_buttons   : <ZBtn>, <ZBtnRowAdd>, <ZBtnRowDel>, <ZBtnRowSave>, <ZBtnProc> 등
    has_popup_edit    : 별도 *Edt.vue 파일 또는 ZPopup 컴포넌트 존재 여부
    apis              : axios.{get,post,put,delete} 호출의 URL 패턴
    purpose_hint      : 화면 상단 주석/제목에서 추출한 한 줄 목적

설계 원칙:
    - 정규식 기반 라이트 파서. AST 파싱은 하지 않음.
    - 한 메뉴에 여러 .vue 파일이 있으면 (예: smmn01.vue + smmn01Edt.vue) 모두 합쳐서 분석.
    - 다국어 키 $t('message.XXX') 는 XXX 만 추출 (대괄호 형식 $t("message['XXX']") 도 지원).
    - 결과가 비어있는 항목은 빈 리스트/None 으로 반환.

사용:
    info = parse_menu(menu_code, fe_path)
    info -> dict
"""
from __future__ import annotations

import re
from pathlib import Path


# 컴포넌트 명에서 사람이 읽는 한국어 라벨로 매핑
BUTTON_NAME_MAP = {
    # 행 단위
    'ZBtnRowAdd': '행추가',
    'ZBtnRowDel': '행삭제',
    'ZBtnRowCopy': '행복사',
    'ZBtnRowSave': '행저장',
    # 단건 / 처리
    'ZBtnProc': '실행',
    'ZBtnSearch': '검색',
    'ZBtnReset': '초기화',
    'ZBtnExcelDown': '엑셀다운로드',
    'ZBtnExcelUp': '엑셀업로드',
    'ZBtnPrint': '인쇄',
    # generic
    'ZBtn': None,  # 슬롯 텍스트로부터 추출
    'ZBtnAdd': '추가',
    'ZBtnSave': '저장',
    'ZBtnDel': '삭제',
    'ZBtnDelete': '삭제',
    'ZBtnModify': '수정',
}

# Vue 컴포넌트 → 의미 매핑 (검색 영역)
SEARCH_COMPONENT_RE = re.compile(
    r'<(?P<tag>SearchSection|search-section)\b(?P<attrs>[^>]*)>',
    re.IGNORECASE
)
SEARCH_CLOSE_RE = re.compile(
    r'</(?:SearchSection|search-section)>', re.IGNORECASE
)

# 다국어 키 추출: $t('message.XXX') 또는 $t("message['XXX']") / $t(`message.XXX`)
I18N_DOT_RE = re.compile(
    r"\$t\(\s*['\"`]message\.([^'\"`)]+)['\"`]\s*\)"
)
I18N_BRACKET_RE = re.compile(
    r"\$t\(\s*['\"`]message\[\s*['\"]([^'\"]+)['\"]\s*\]['\"`]\s*\)"
)

# <ZCell :title="$t('message.XXX')"> 또는 <ZCell title="XXX">
ZCELL_RE = re.compile(
    r'<ZCell\b[^>]*?(?::title|title)\s*=\s*"([^"]+)"',
    re.IGNORECASE
)
# 라벨 직접 지정: label="$t('message.XXX')" 또는 :label="..."
LABEL_RE = re.compile(
    r'<(?:ZText|ZNumber|ZDate|ZSelect|ZCodeSelect|ZRadio|ZCheckbox|ZBizPopup|ZCpctPopup|ZPdPopup|ZCenterPopup|ZWhPopup)\b'
    r'[^>]*?(?::label|label)\s*=\s*"([^"]+)"',
    re.IGNORECASE
)
# slot text: <ZBtn ...>슬롯텍스트</ZBtn>
ZBTN_RE = re.compile(
    r'<(ZBtn[A-Za-z]*)\b[^>]*?>([^<]{0,40})</\1>',
    re.IGNORECASE
)
# self-closing or no slot: <ZBtnRowAdd /> or <ZBtnRowAdd ...></ZBtnRowAdd>
ZBTN_BARE_RE = re.compile(
    r'<(ZBtn[A-Za-z]+)\b[^>]*?(?:/>|>\s*</\1>)',
    re.IGNORECASE
)

# columnLayout 안의 headerText
HEADER_TEXT_RE = re.compile(
    r"headerText\s*:\s*['\"]([^'\"]+)['\"]"
)
# 비가시 컬럼: visible: false 가 가까이 있으면 제외
VISIBLE_FALSE_RE = re.compile(
    r"visible\s*:\s*false"
)

# axios 호출
AXIOS_RE = re.compile(
    r"axios\.(get|post|put|delete|patch)\s*\(\s*[`'\"]([^`'\")\s]+)"
)


def _strip_i18n(s: str) -> str:
    """$t('message.XXX') → XXX 또는 평문이면 그대로 반환."""
    s = (s or '').strip()
    m = I18N_DOT_RE.search(s)
    if m:
        return m.group(1).strip()
    m = I18N_BRACKET_RE.search(s)
    if m:
        return m.group(1).strip()
    # 따옴표 제거
    return s.strip("'\"` ")


def _read(p: Path) -> str:
    try:
        return p.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return ''


def _extract_search_block(src: str) -> str | None:
    """<SearchSection> ... </SearchSection> 블록 텍스트 반환. 없으면 None."""
    m = SEARCH_COMPONENT_RE.search(src)
    if not m:
        return None
    start = m.end()
    end_m = SEARCH_CLOSE_RE.search(src, start)
    if end_m:
        return src[m.start():end_m.end()]
    return src[m.start():]


def _extract_search_attrs(search_block_open: str) -> dict:
    """SearchSection 열기 태그의 :title, code 속성 추출."""
    out = {'title': None, 'code': None}
    m = re.search(r':title\s*=\s*"([^"]+)"', search_block_open)
    if m:
        out['title'] = _strip_i18n(m.group(1))
    m = re.search(r'\bcode\s*=\s*"([^"]+)"', search_block_open)
    if m:
        out['code'] = m.group(1).strip()
    return out


def _column_layouts(src: str) -> list[str]:
    """모든 columnLayout / column 정의에서 headerText 추출.
    visible:false 직전/직후에 붙은 항목은 제외 (정확하진 않지만 휴리스틱)."""
    # 한 객체 단위로 분리하기 어려우니 단순히 headerText 와 인접 visible:false 를 페어링
    cols = []
    for m in HEADER_TEXT_RE.finditer(src):
        # 같은 객체 안에 visible:false 가 있는지 ±300자 윈도우로 확인
        wstart = max(0, m.start() - 300)
        wend = min(len(src), m.end() + 300)
        window = src[wstart:wend]
        # 같은 중괄호 그룹 안인지 확인하기 위해 직전 { 부터 직후 } 까지 잘라봄
        before_brace = window.rfind('{', 0, m.start() - wstart)
        after_brace = window.find('}', m.end() - wstart)
        if before_brace >= 0 and after_brace >= 0 and before_brace < after_brace:
            obj = window[before_brace:after_brace + 1]
            if VISIBLE_FALSE_RE.search(obj):
                continue
        text = _strip_i18n(m.group(1))
        if text and text not in cols:
            cols.append(text)
    return cols


def _search_fields(search_block: str) -> list[str]:
    """SearchSection 블록 내부의 <ZCell :title="..."> + 컴포넌트 label 을 합쳐 반환."""
    fields = []
    seen = set()

    def _add(label_raw: str):
        label = _strip_i18n(label_raw)
        if not label:
            return
        if label in seen:
            return
        seen.add(label)
        fields.append(label)

    for m in ZCELL_RE.finditer(search_block):
        _add(m.group(1))
    # ZCell title 이 비어있는 케이스를 대비해 보조로 컴포넌트 label 도 수집
    for m in LABEL_RE.finditer(search_block):
        _add(m.group(1))
    return fields


def _toolbar_buttons(src: str) -> list[str]:
    """ZBtn* 컴포넌트에서 버튼 이름 추출. 슬롯 텍스트가 있으면 그것, 없으면 컴포넌트명 매핑."""
    buttons = []
    seen = set()

    def _add(name: str):
        name = (name or '').strip()
        if not name:
            return
        if name in seen:
            return
        seen.add(name)
        buttons.append(name)

    # 슬롯 텍스트가 있는 형태
    for m in ZBTN_RE.finditer(src):
        comp = m.group(1)
        text = _strip_i18n(m.group(2)).strip()
        if text:
            _add(text)
        else:
            mapped = BUTTON_NAME_MAP.get(comp)
            if mapped:
                _add(mapped)
    # self-closing / 빈 슬롯
    for m in ZBTN_BARE_RE.finditer(src):
        comp = m.group(1)
        mapped = BUTTON_NAME_MAP.get(comp)
        if mapped:
            _add(mapped)
    return buttons


def _apis(src: str) -> list[str]:
    """axios 호출의 (method, url) 페어 추출."""
    out = []
    seen = set()
    for m in AXIOS_RE.finditer(src):
        method = m.group(1).upper()
        url = m.group(2)
        # 템플릿 변수 치환 ${xxx} → :xxx, ${xxx.yyy} → :yyy
        url = re.sub(r"\$\{[^}]*?([A-Za-z]\w*)\}", r":\1", url)
        key = f"{method} {url}"
        if key in seen:
            continue
        seen.add(key)
        out.append((method, url))
    return out


def parse_menu(menu_code: str, fe_path: str | Path) -> dict:
    """메뉴 폴더(views 하위 어디든) 를 찾아 합쳐서 분석."""
    fe_root = Path(fe_path)
    views_root = fe_root / 'src' / 'views'
    menu_dirs = []
    if views_root.exists():
        # 정확한 폴더명 매칭 (재귀)
        for d in views_root.rglob(menu_code):
            if d.is_dir():
                menu_dirs.append(d)

    info = {
        'menu_code': menu_code,
        'has_search': False,
        'search_title': None,
        'search_code': None,
        'search_fields': [],
        'grid_columns': [],
        'toolbar_buttons': [],
        'apis': [],
        'vue_files': [],
        'has_popup_edit': False,
    }

    if not menu_dirs:
        return info

    combined_src = ''
    for d in menu_dirs:
        for vue in sorted(d.glob('*.vue')):
            info['vue_files'].append(str(vue.relative_to(fe_root)))
            if vue.name.lower().endswith('edt.vue') or 'popup' in vue.name.lower():
                info['has_popup_edit'] = True
            combined_src += '\n' + _read(vue)

    if not combined_src.strip():
        return info

    # SearchSection
    sc_open = SEARCH_COMPONENT_RE.search(combined_src)
    if sc_open:
        info['has_search'] = True
        attrs = _extract_search_attrs(sc_open.group(0))
        info['search_title'] = attrs['title']
        info['search_code'] = attrs['code']
        sc_block = _extract_search_block(combined_src) or ''
        info['search_fields'] = _search_fields(sc_block)

    # 그리드 컬럼
    info['grid_columns'] = _column_layouts(combined_src)

    # 툴바 버튼
    info['toolbar_buttons'] = _toolbar_buttons(combined_src)

    # API
    info['apis'] = _apis(combined_src)

    return info


# ── CLI (단독 실행 시 디버깅용 출력) ────────────────────────────
if __name__ == '__main__':
    import sys
    import json
    if len(sys.argv) < 3:
        print("usage: parse_vue_source.py <menu_code> <fe_path>")
        sys.exit(1)
    print(json.dumps(parse_menu(sys.argv[1], sys.argv[2]), ensure_ascii=False, indent=2))
