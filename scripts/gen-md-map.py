# -*- coding: utf-8 -*-
"""
cloud-wms-doc 파일·폴더 지도(knowledgebase/20-md-index.html) 생성기.

실행: python scripts/gen-md-map.py   (CWD 무관 — 레포 루트 기준으로 동작)
출력: 레포 루트의 knowledgebase/20-md-index.html  (※ gitignore 대상, 생성물)

- 전체 폴더 구조 + MD 파일을 영역별/계층별 트리로 렌더링 (접기·검색 지원)
- 비-MD 파일은 폴더별 개수만 표시 (node_modules·이미지 노이즈 제외)
- .claude/skills, .claude/rules 는 성격별 그룹으로 분류
  스킬/규칙을 추가·이동하면 아래 SKILL_DEV/SKILL_OUT, RULE_GROUP 만 갱신하면 된다.
"""
import os, html, datetime, re, subprocess

# 레포 루트 기준으로 동작
try:
    ROOT = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], text=True).strip()
except Exception:
    ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

BS = chr(92)
META = [
 ('root','\U0001F3E0','루트 문서','진입점·구조·지침','전체','마크다운'),
 ('knowledgebase','\U0001F4D5','knowledgebase','메뉴 횡단 공통 배경지식 — AI 도서관','AI·개발자','마크다운'),
 ('spec','\U0001F4D0','spec','메뉴별 설계 정본 (00-domain~07+99)','AI·개발자','마크다운'),
 ('prototype','\U0001F5A5','prototype','검증용 화면 (대부분 HTML)','PL·PM·고객','HTML'),
 ('patterns','\U0001F527','patterns','소스코드 패턴 표준 — HOW','AI·개발자','마크다운'),
 ('deliverables','\U0001F4E6','deliverables','산출물 (템플릿·원천·결과)','고객','문서'),
 ('.claude/skills','⚙️','.claude/skills','슬래시 커맨드 (개발/산출물/유틸)','AI','SKILL.md'),
 ('.claude/rules','\U0001F4CF','.claude/rules','항상/조건부 적용 규칙','AI','마크다운'),
]
AREA_KEYS = [m[0] for m in META]
NOISE = {'png','jpg','jpeg','gif','svg','ico','map','woff','woff2','ttf','eot','lock'}
SKILL_DEV = {'SD_310_UI','SD_db','SD_api','SD_db_apply',
 'PI_be_all','PI_be_comp','PI_be_dao','PI_be_excel','PI_be_inven','PI_be_mapper',
 'PI_fe_all','PI_fe_edit','PI_fe_list','PI_test_be','PI_test_fe'}
SKILL_OUT = {'RA_222','SD_311','SD_312','SD_331','SD_332','SD_333','SD_334',
 'PI_411','PI_412','PI_421','PI_422','TT_541','TT_542','TT_543','TT_550','TT_551'}
def classify_skill(s):
    if s in SKILL_DEV: return '개발 자동화'
    if s in SKILL_OUT: return '산출물 자동화'
    return '유틸'
RULE_GROUP = {'common_ui':'UI·화면','area_btn':'UI·화면','area_search':'UI·화면','area_result_grid':'UI·화면',
 'area_multi_input_grid':'UI·화면','popup_biz':'UI·화면','popup_reg':'UI·화면',
 'backend-convention':'BE·DB·연동','db-convention':'BE·DB·연동','biz-framework':'BE·DB·연동','sif-convention':'BE·DB·연동',
 'md-frontmatter':'문서·메타','rule-skill-frontmatter':'문서·메타','repo-paths':'경로·환경'}
def classify_rule(stem):
    return RULE_GROUP.get(stem, '기타')
GROUP_ORDER = {'개발 자동화':0,'산출물 자동화':1,'유틸':2,
 'UI·화면':0,'BE·DB·연동':1,'문서·메타':2,'경로·환경':3,'기타':9}
FOLDER_ROLE = {
 'knowledgebase/10-domain':'메뉴 횡단 공통 업무규칙(WHY)','knowledgebase/30-src-index':'소스코드 위치 색인',
 'knowledgebase/40-install-guide':'설치·셋업·배포 가이드','knowledgebase/40-install-guide/deploy':'배포 가이드',
 'knowledgebase/50-dev-workflow':'개발 워크플로우',
 'patterns/10-screen-design':'화면 패턴(WEB/PDA)','patterns/10-screen-design/10-web':'WEB 화면 패턴','patterns/10-screen-design/20-pda':'PDA 화면 패턴',
 'patterns/20-database':'DB 설계·네이밍 패턴','patterns/20-database/20-rule':'DB 규칙','patterns/30-backend':'BE 구현 패턴',
 'patterns/40-frontend':'FE 구현 패턴','patterns/40-frontend/20-convention':'FE 컨벤션','patterns/50-interface':'인터페이스(IF) 패턴',
 'patterns/_common-arch':'공통 기술 아키텍처',
 'deliverables/10-templates':'산출물 템플릿 (PS/RA/SD/PI/TT)','deliverables/20-sources':'산출물 원천 자료','deliverables/30-output':'생성 결과물 (gitignored)',
 'prototype/_common':'PC 공통 셸','prototype/_common-m':'모바일 공통 셸',
 '.claude/skills/개발 자동화':'설계·코드·테스트 생성 (SD·PI)',
 '.claude/skills/산출물 자동화':'고객 제출물·프로토타입 생성 (SD·RA·PI·TT)',
 '.claude/skills/유틸':'배포·레드마인·KB·메타',
 '.claude/rules/UI·화면':'와이어프레임 HTML 작성 규칙','.claude/rules/BE·DB·연동':'BE·Mapper·재고·외부연동(SIF) 규칙',
 '.claude/rules/문서·메타':'MD·rule/skill frontmatter 작성 규칙','.claude/rules/경로·환경':'워크스페이스 레포 경로 규약',
}
SUFFIX = {'00-domain':'업무지식(WHY·사람전용)','01-basic-design':'기본설계','02-ui':'화면요건','03-data-model':'데이터모델(DB)','04-be-mapper-sql':'쿼리 명세','05-api':'API 명세','06-be-flow':'BE 흐름','07-fe-flow':'FE 흐름','99-issues':'설계 미결·이슈'}

def fm(path):
    try:
        t = open(path, encoding='utf-8', errors='ignore').read(2500)
    except Exception:
        return ''
    if not t.startswith('---'): return ''
    m = re.search(r'^description:\s*(.+)$', t, re.M)
    if m: return m.group(1).strip().strip('"').strip("'")
    m = re.search(r'^title:\s*(.+)$', t, re.M)
    return m.group(1).strip() if m else ''

def short(s, n=90):
    return s if len(s) <= n else s[:n-1] + '…'

def file_role(f):
    d = fm(f)
    if d: return d
    for suf, r in SUFFIX.items():
        if f.endswith('-' + suf + '.md'): return r
    return ''

def folder_role(full):
    if full in FOLDER_ROLE: return FOLDER_ROLE[full]
    if os.path.exists(full + '/SKILL.md'):
        r = fm(full + '/SKILL.md'); return short(r.split('.')[0], 70) if r else '슬래시 커맨드'
    if full.startswith('spec/') and full.count('/') == 1: return '메뉴 설계 문서 세트'
    return ''

def sz(p):
    try:
        b = os.path.getsize(p); return (str(b//1024) + 'K') if b >= 1024 else (str(b) + 'B')
    except Exception:
        return ''

def area_of(p):
    for k in AREA_KEYS:
        if k != 'root' and (p == k or p.startswith(k + '/')): return k
    return 'root'

def newnode():
    return {'dirs': {}, 'files': [], 'nonmd': 0}

areatrees = {k: newnode() for k in AREA_KEYS}

def node_for(area, within):
    node = areatrees[area]
    if not within: return node
    segs = within.split('/')
    if area == '.claude/skills':
        segs = [classify_skill(segs[0])] + segs
    for s in segs:
        node = node['dirs'].setdefault(s, newnode())
    return node

mdtotal = 0
for dp, dns, fns in os.walk('.'):
    dns[:] = [d for d in dns if d not in ('node_modules', '.git')]
    reld = os.path.relpath(dp, '.').replace(BS, '/')
    if reld == '.': reld = ''
    if reld:
        a = area_of(reld)
        if a != 'root':
            within = '' if reld == a else reld[len(a)+1:]
            node_for(a, within)
    for f in fns:
        rp = (reld + '/' + f) if reld else f
        a = area_of(rp)
        if a == '.claude/rules' and f.endswith('.md'):
            grp = classify_rule(f[:-3])
            node = areatrees[a]['dirs'].setdefault(grp, newnode())
            node['files'].append(rp); mdtotal += 1
            continue
        within = '' if (reld == a or reld == '') else (reld[len(a)+1:] if reld.startswith(a + '/') else '')
        node = node_for(a, within)
        if f.endswith('.md'):
            node['files'].append(rp); mdtotal += 1
        else:
            ext = f.rsplit('.', 1)[-1].lower() if '.' in f else ''
            if ext not in NOISE:
                node['nonmd'] += 1

def cmd(node):
    return len(node['files']) + sum(cmd(c) for c in node['dirs'].values())
def cnm(node):
    return node['nonmd'] + sum(cnm(c) for c in node['dirs'].values())

def render(node, prefix):
    out = ''
    for name in sorted(node['dirs'].keys(), key=lambda x: (GROUP_ORDER.get(x, 50), x)):
        full = (prefix + '/' + name) if prefix else name
        child = node['dirs'][name]
        rr = folder_role(full)
        rtxt = (' <span class="sr">— ' + html.escape(rr) + '</span>') if rr else ''
        nm = cnm(child); nmb = (' <span class="nm">비MD ' + str(nm) + '</span>') if nm else ''
        out += ('<details class="dir"><summary><span class="fn">' + html.escape(name) + '</span> <span class="c">md ' + str(cmd(child)) + '</span>' + nmb + rtxt + '</summary>'
                + render(child, full) + '</details>')
    for f in sorted(node['files']):
        r = file_role(f)
        rt = ('<span class="fr" title="' + html.escape(r) + '">' + html.escape(short(r)) + '</span>') if r else ''
        out += ('<div class="file"><a href="' + html.escape(f) + '">' + html.escape(f.split('/')[-1]) + '</a>' + rt + '<span class="z">' + sz(f) + '</span></div>')
    return out

cards = []
for k, icon, name, role, who, media in META:
    node = areatrees[k]
    nm = cnm(node); nmb = (' <span class="nm">비MD ' + str(nm) + '</span>') if nm else ''
    cards.append('<details class="area" open data-area="' + html.escape(name) + '">'
      + '<summary><span class="ic">' + icon + '</span> <span class="an">' + html.escape(name) + '</span> <span class="cnt">md ' + str(cmd(node)) + '</span>' + nmb
      + '<span class="arole">' + html.escape(role) + '</span>'
      + '<span class="badge">' + html.escape(who) + '</span><span class="badge md">' + html.escape(media) + '</span></summary>'
      + '<div class="body">' + render(node, k if k != 'root' else '') + '</div></details>')

chips = ''.join('<span class="chip" onclick="fa(this,\'' + html.escape(n) + '\')">' + icon + ' ' + html.escape(n) + ' ' + str(cmd(areatrees[k])) + '</span>' for k, icon, n, a, b, c in META)

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Malgun Gothic',sans-serif;background:#eef2f7;color:#1e293b;font-size:13px;padding:22px;max-width:1200px;margin:0 auto}
h1{font-size:21px} .sub{color:#64748b;margin:4px 0 12px}
.tools{display:flex;gap:8px;margin-bottom:12px}
#q{flex:1;height:36px;border:1px solid #cbd5e1;border-radius:8px;padding:0 14px;font-size:14px}
button.x{height:36px;border:1px solid #cbd5e1;background:#fff;border-radius:8px;padding:0 12px;cursor:pointer;font-size:12px}
.chips{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:18px}
.chip{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:4px 11px;cursor:pointer;font-size:12px}
.chip:hover,.chip.on{background:#304a6e;color:#fff;border-color:#304a6e}
details{border:1px solid #e2e8f0;border-radius:8px;margin-bottom:6px;background:#fff}
details.area{margin-bottom:14px;box-shadow:0 1px 2px rgba(0,0,0,.04)}
summary{cursor:pointer;list-style:none;display:flex;align-items:center;gap:8px;padding:9px 14px;user-select:none}
summary::-webkit-details-marker{display:none}
summary::before{content:'\\25B8';color:#94a3b8;font-size:10px;transition:.12s}
details[open]>summary::before{transform:rotate(90deg)}
details.area>summary{background:#f8fafc;font-size:14px;border-radius:8px}
.ic{font-size:16px} .an{font-weight:700}
.cnt{background:#304a6e;color:#fff;border-radius:11px;padding:1px 9px;font-size:11px}
.nm{background:#fef3c7;color:#92400e;border-radius:9px;padding:1px 7px;font-size:10.5px}
.arole{color:#475569;font-size:12px;margin-left:4px}
.badge{display:inline-block;background:#e2e8f0;border-radius:10px;padding:1px 8px;font-size:11px;color:#475569;margin-left:auto}
.badge.md{background:#dbeafe;color:#1e40af;margin-left:6px}
details.dir{border:none;border-radius:0;margin:0}
details.dir>summary{padding:5px 10px;font-size:12.5px}
.fn{font-weight:700;color:#334155} .c{color:#94a3b8;font-size:11px} .sr{color:#0891b2;font-size:11px}
.body{padding:4px 6px 8px}
details.dir>.body,details.dir>details,details.dir>.file{margin-left:14px;border-left:1px solid #eef2f7}
.file{display:flex;align-items:center;gap:10px;padding:3px 10px;border-top:1px solid #f5f8fc}
.file a{color:#1d4ed8;text-decoration:none;font-weight:600;min-width:210px} .file a:hover{text-decoration:underline}
.fr{color:#475569;font-size:11.5px;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.z{color:#94a3b8;font-size:11px;min-width:40px;text-align:right}
.file.hide,details.hide{display:none}
"""
JS = """
function se(v){v=v.toLowerCase().trim();
 document.querySelectorAll('.file').forEach(function(f){f.classList.toggle('hide',v&&!f.textContent.toLowerCase().includes(v));});
 document.querySelectorAll('details').forEach(function(d){
   if(!v){d.classList.remove('hide');return;}
   var has=Array.prototype.some.call(d.querySelectorAll('.file'),function(f){return !f.classList.contains('hide');});
   d.classList.toggle('hide',!has); if(has)d.open=true;});}
function fa(el,n){document.querySelectorAll('.chip').forEach(function(c){c.classList.remove('on');});el.classList.add('on');
 document.querySelectorAll('details.area').forEach(function(a){a.classList.toggle('hide',n&&a.dataset.area!==n);});}
function setAll(o){document.querySelectorAll('details').forEach(function(d){d.open=o;});}
"""
doc = ('<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><title>cloud-wms-doc 파일 지도</title>'
 + '<style>' + CSS + '</style></head><body>'
 + '<h1>cloud-wms-doc · 파일·폴더 지도</h1>'
 + '<div class="sub">MD <b>' + str(mdtotal) + '</b>개 + 전체 폴더 구조 (비MD는 개수만, node_modules·이미지 제외) · 생성 ' + str(datetime.date.today()) + '</div>'
 + '<div class="tools"><input id="q" placeholder="파일명·경로·역할 검색…" oninput="se(this.value)">'
 + '<button class="x" onclick="setAll(true)">모두 펼치기</button><button class="x" onclick="setAll(false)">모두 접기</button></div>'
 + '<div class="chips"><span class="chip on" onclick="fa(this,\'\')">전체</span>' + chips + '</div>'
 + ''.join(cards)
 + '<script>' + JS + '</script></body></html>')
open('knowledgebase/20-md-index.html', 'w', encoding='utf-8').write(doc)
print('knowledgebase/20-md-index.html 생성 완료 (md ' + str(mdtotal) + '개)')
