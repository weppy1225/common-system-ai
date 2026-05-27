#!/usr/bin/env node
/**
 * [TT_543] 1단계 — FE + BE 프로젝트 스캔으로 운영자(관리자) 메뉴 후보 추출
 *
 * 사용법:
 *   node 01_scan_admin_menus.js "<FE 프로젝트 경로>" "<BE 프로젝트 경로>"
 *
 * 출력:
 *   output/05 이행(TT)/tmp_543/admin_menu_candidates.json
 *
 * 동작:
 *   1) FE 측: package.json/vite.config 에서 dev 포트 추출
 *   2) FE 측: router/views/pages 에서 라우트 추출
 *   3) FE 측: 운영자 메뉴 필터 적용 (path 또는 code 패턴 기반)
 *   4) BE 측: Controller / @RequestMapping 에서 URL prefix 추출하여 보강
 *   5) cloud-wms-doc dist/{메뉴코드}/ui.md 또는 menu-index.md 에서 메뉴명 매핑
 *   6) JSON 으로 저장
 *
 * 이 스크립트는 Windows 네이티브 경로(C:\...) 와 WSL 경로(/mnt/c/...) 를 모두 받는다.
 */
'use strict';

const fs = require('fs');
const path = require('path');

// ── 경로 정규화 (Windows / WSL 양방향) ──────────────────────────
// 본 스크립트는 .claude/skills/TT_543/scripts/ 안에 있으므로
// repo root = parents[3]. node 실행 위치와 무관하게 동작하도록 __dirname 기준으로 계산한다.
const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..', '..', '..');
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 이행(TT)', 'tmp_543');
const OUT_FILE = path.join(TMP_DIR, 'admin_menu_candidates.json');

function normalizePath(p) {
    if (!p) return p;
    // Windows -> POSIX 분리자 통일 (Node 자체가 양쪽 지원)
    let s = String(p).replace(/\\+/g, '/');
    // WSL 경로(/mnt/c/...) 를 그대로 사용 (Node 가 WSL 환경이면 fs.existsSync 가 동작)
    // Windows native 경로(C:/...) 도 그대로 사용 (Node Windows 빌드가 자동 처리)
    return s.replace(/\/+$/, '');
}

// ── 인자 파싱 ───────────────────────────────────────────────────
let fePath = process.argv[2];
let bePath = process.argv[3];

if (!fePath) {
    console.error('[ERR] FE 프로젝트 경로를 첫 번째 인자로 전달하세요.');
    process.exit(1);
}
fePath = normalizePath(fePath);
if (bePath) bePath = normalizePath(bePath);

if (!fs.existsSync(fePath)) {
    console.error(`[ERR] FE 경로가 존재하지 않습니다: ${fePath}`);
    process.exit(1);
}
if (bePath && !fs.existsSync(bePath)) {
    console.error(`[WARN] BE 경로가 존재하지 않습니다 (FE 만으로 진행): ${bePath}`);
    bePath = null;
}

fs.mkdirSync(TMP_DIR, { recursive: true });

// ── 유틸 ────────────────────────────────────────────────────────
function safeRead(p) {
    try { return fs.readFileSync(p, 'utf8'); }
    catch (_) { return ''; }
}

function findFiles(rootDir, predicate, opts = {}) {
    const {
        skipDirs = [
            'node_modules', '.git', 'dist', 'build', '.next', '.nuxt',
            'coverage', 'target', '.gradle', '.mvn', 'bin', 'obj', 'out',
            '__pycache__', '.venv', 'venv', '.idea', '.vscode',
        ],
        maxDepth = 10,
    } = opts;
    const out = [];
    function walk(dir, depth) {
        if (depth > maxDepth) return;
        let entries;
        try { entries = fs.readdirSync(dir, { withFileTypes: true }); }
        catch (_) { return; }
        for (const ent of entries) {
            if (ent.name.startsWith('.') && ent.name !== '.env') continue;
            const full = path.join(dir, ent.name);
            if (ent.isDirectory()) {
                if (skipDirs.includes(ent.name)) continue;
                walk(full, depth + 1);
            } else if (ent.isFile() && predicate(full, ent.name)) {
                out.push(full);
            }
        }
    }
    walk(rootDir, 0);
    return out;
}

// ── 운영자 메뉴 식별 기준 ────────────────────────────────────────

// (A) FE 라우트 경로 패턴
const ADMIN_PATH_PATTERNS = [
    /(^|\/)sm(\/|$)/i,                    // /sm/...
    /(^|\/)admin(\/|$)/i,                 // /admin/...
    /(^|\/)mgmt(\/|$)/i,                  // /mgmt/...
    /(^|\/)manage(\/|$)/i,                // /manage/...
    /(^|\/)system(\/|$)/i,                // /system/...
    /(^|\/)setting(s)?(\/|$)/i,           // /setting(s)/...
    /(^|\/)config(\/|$)/i,                // /config/...
    /(^|\/)permission(s)?(\/|$)/i,        // /permission/...
    /(^|\/)role(s)?(\/|$)/i,              // /role/...
    /(^|\/)auth(\/|$)/i,                  // /auth/...
    /(^|\/)md(\/|$)/i,                    // /md/...  (master data)
];

// (B) 메뉴 코드 접두사 패턴 (영문 prefix 기반)
const ADMIN_CODE_PREFIXES = [
    /^sm[a-z]{0,4}\d/i,    // smus01, smmn01, smcd01, smgr01, smbz01
    /^mdm[a-z]{0,4}\d/i,   // mdmbz01, mdmce01, mdmwh01, mdmlc01
    /^adm[a-z]{0,4}\d/i,   // adm*
    /^sys[a-z]{0,4}\d/i,   // sys*
    /^cfg[a-z]{0,4}\d/i,   // cfg*
    /^usr[a-z]{0,4}\d/i,   // usr*
    /^auth[a-z]{0,4}\d/i,  // auth*
    /^role[a-z]{0,4}\d/i,  // role*
    /^perm[a-z]{0,4}\d/i,  // perm*
];

// (C) 메뉴명 키워드
const ADMIN_NAME_KEYWORDS = [
    '관리자', '사용자관리', '사용자 관리', '권한', '메뉴관리', '메뉴 관리',
    '공통코드', '공통 코드', '시스템 파라미터', '시스템파라미터',
    '시스템 설정', '시스템설정', '사업장', '센터', '창고', '로케이션',
    '그룹 관리', '그룹관리', '관리', '설정',
];

// (E) 제외 기준 — 일반 업무 메뉴
const NON_ADMIN_CODE_PREFIXES = [
    /^iw\d/i,    // 입고
    /^ob\d/i,    // 출고
    /^iv\d/i,    // 재고
    /^rt\d/i,    // 반품
    /^pk\d/i,    // 피킹
    /^dl\d/i,    // 배송
    /^br[a-z]+\d.*m$/i,  // PDA (브랜치 + m 접미사)
    /^pda/i,     // pda*
];
const NON_ADMIN_NAME_KEYWORDS = [
    '입고', '출고', '재고', '반품', '피킹', '배송', '주문',
];
const PDA_PATH = /(^|\/)pda(\/|$)/i;

function isAdminByPath(p) {
    if (!p) return false;
    if (PDA_PATH.test(p)) return false;
    return ADMIN_PATH_PATTERNS.some(re => re.test(p));
}
function isAdminByCode(code) {
    if (!code) return false;
    if (NON_ADMIN_CODE_PREFIXES.some(re => re.test(code))) return false;
    return ADMIN_CODE_PREFIXES.some(re => re.test(code));
}
function isAdminByName(name) {
    if (!name) return false;
    if (NON_ADMIN_NAME_KEYWORDS.some(k => name.includes(k))) {
        // "재고관리" 처럼 두 키워드가 다 들어가면 일반 메뉴로 본다
        // 단, "사용자관리"·"메뉴관리"·"권한관리" 등 운영자 키워드가 있으면 운영자로 본다
        const ADMIN_STRONG = ['사용자관리', '메뉴관리', '권한', '공통코드',
            '사용자 관리', '메뉴 관리', '시스템 파라미터', '시스템파라미터',
            '시스템 설정', '시스템설정', '관리자'];
        if (!ADMIN_STRONG.some(k => name.includes(k))) return false;
    }
    return ADMIN_NAME_KEYWORDS.some(k => name.includes(k));
}
function rejectReason(menu) {
    if (!menu) return 'unknown';
    if (menu.path && PDA_PATH.test(menu.path)) return 'PDA 메뉴';
    if (NON_ADMIN_CODE_PREFIXES.some(re => re.test(menu.code || ''))) {
        return '일반업무메뉴(입출고/재고/반품/피킹/배송)';
    }
    if (NON_ADMIN_NAME_KEYWORDS.some(k => (menu.name || '').includes(k))) {
        return `일반업무메뉴(${NON_ADMIN_NAME_KEYWORDS.find(k => menu.name.includes(k))})`;
    }
    return '운영자 메뉴 패턴 미일치';
}

function categorize(menu) {
    const p = menu.path || '';
    const c = menu.code || '';
    if (/^mdm/i.test(c) || /(^|\/)md(\/|$)/i.test(p)) return '마스터';
    if (/(^|\/)auth(\/|$)/i.test(p) || /^auth|^role|^perm/i.test(c)) return '권한관리';
    if (/(^|\/)sm(\/|$)/i.test(p) || /^sm/i.test(c)) return '시스템관리';
    if (/(^|\/)admin(\/|$)/i.test(p) || /^adm/i.test(c)) return '관리자';
    if (/(^|\/)system(\/|$)/i.test(p) || /^sys/i.test(c)) return '시스템';
    return '운영';
}

// ── FE 프레임워크 / dev 포트 감지 ──────────────────────────────
function detectFramework(fePath) {
    const pkgPath = path.join(fePath, 'package.json');
    if (!fs.existsSync(pkgPath)) return { framework: 'unknown', devPort: null };

    let pkg;
    try { pkg = JSON.parse(safeRead(pkgPath)); }
    catch (_) { return { framework: 'unknown', devPort: null }; }

    const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
    let framework = 'unknown';
    if (deps['next']) framework = 'next';
    else if (deps['nuxt'] || deps['nuxt3']) framework = 'nuxt';
    else if (deps['@vitejs/plugin-vue'] || (deps['vue'] && deps['vite'])) framework = 'vue3-vite';
    else if (deps['vue'] && (deps['@vue/cli-service'] || deps['vue-cli-plugin-webpack'])) framework = 'vue-cli';
    else if (deps['vue']) framework = 'vue';
    else if (deps['react'] && deps['vite']) framework = 'react-vite';
    else if (deps['react']) framework = 'react';
    else if (deps['svelte']) framework = 'svelte';

    let devPort = null;
    const devScripts = [pkg?.scripts?.dev, pkg?.scripts?.start, pkg?.scripts?.serve].filter(Boolean);
    for (const s of devScripts) {
        const m = s.match(/--port[= ](\d{2,5})/) || s.match(/-p\s+(\d{2,5})/);
        if (m) { devPort = parseInt(m[1], 10); break; }
    }
    if (!devPort) {
        const cfgCandidates = [
            'vite.config.ts', 'vite.config.js', 'vite.config.mjs',
            'next.config.js', 'next.config.mjs', 'next.config.ts',
            'nuxt.config.ts', 'nuxt.config.js',
            'vue.config.js', 'webpack.config.js',
        ];
        for (const f of cfgCandidates) {
            const fp = path.join(fePath, f);
            if (!fs.existsSync(fp)) continue;
            const txt = safeRead(fp);
            const m = txt.match(/port\s*:\s*(\d{2,5})/);
            if (m) { devPort = parseInt(m[1], 10); break; }
        }
    }
    if (!devPort) {
        if (framework === 'next') devPort = 3000;
        else if (framework === 'nuxt') devPort = 3000;
        else if (framework.startsWith('vue3-vite') || framework === 'react-vite') devPort = 5173;
        else if (framework === 'vue-cli' || framework === 'react') devPort = 8080;
    }
    return { framework, devPort };
}

// ── FE 라우트 추출 ─────────────────────────────────────────────
const ROUTE_FILE_PATTERNS = [
    /router\/index\.(js|ts)$/i,
    /router\/routes\.(js|ts)$/i,
    /routes\/index\.(js|ts|tsx)$/i,
    /src\/router\.[jt]s$/i,
    /src\/routes\.[jt]s$/i,
    /App\.(jsx|tsx)$/,
];

function extractRoutesFromText(txt) {
    const out = [];
    const pathRegex = /path\s*:\s*['"`]([^'"`]+)['"`][\s\S]{0,200}?(?:component|element|name)\s*:\s*[^,\n]+/g;
    let m;
    while ((m = pathRegex.exec(txt)) !== null) {
        const p = m[1];
        if (!p || p === '/' || p === '*' || p === '/:catchAll(.*)') continue;
        const segs = p.split('/').filter(Boolean);
        const last = segs[segs.length - 1];
        if (!last || last.startsWith(':')) continue;
        const code = last.replace(/[^a-zA-Z0-9_-]/g, '').toLowerCase();
        if (!code) continue;
        out.push({ code, path: p });
    }
    return out;
}

function extractRoutesFromFiles(fePath) {
    const found = new Map();
    const candidates = findFiles(fePath, (full) => {
        return ROUTE_FILE_PATTERNS.some(re => re.test(full.replace(/\\/g, '/')));
    }, { maxDepth: 6 });

    for (const f of candidates) {
        const txt = safeRead(f);
        for (const r of extractRoutesFromText(txt)) {
            if (!found.has(r.code)) found.set(r.code, r);
        }
    }

    // views/pages 자동 인식 (보조)
    if (found.size === 0) {
        const viewDirs = ['src/views', 'src/pages', 'pages', 'app'];
        for (const vd of viewDirs) {
            const dir = path.join(fePath, vd);
            if (!fs.existsSync(dir)) continue;
            const vues = findFiles(dir, (_full, name) => /\.(vue|tsx|jsx|svelte)$/.test(name), { maxDepth: 8 });
            for (const v of vues) {
                const base = path.basename(v).replace(/\.(vue|tsx|jsx|svelte)$/, '');
                if (base === 'index' || base === '_app' || base === '_layout' || base === 'default') continue;
                const code = base.toLowerCase().replace(/[^a-zA-Z0-9_-]/g, '');
                if (!code) continue;
                // 파일 경로에서 추론한 가짜 path — 운영자 디렉토리에 있는지 확인용
                const rel = v.replace(/\\/g, '/').slice(fePath.replace(/\\/g, '/').length);
                if (!found.has(code)) {
                    found.set(code, { code, path: rel.replace(/\.(vue|tsx|jsx|svelte)$/, '') });
                }
            }
        }
    }
    return Array.from(found.values());
}

// ── 메뉴명 매핑 ─────────────────────────────────────────────
function buildMenuNameMap(fePath) {
    const map = {};

    // a) cloud-wms-doc 의 dist/{메뉴코드}/ui.md
    const distDir = path.join(REPO_ROOT, 'dist');
    if (fs.existsSync(distDir)) {
        try {
            for (const ent of fs.readdirSync(distDir, { withFileTypes: true })) {
                if (!ent.isDirectory()) continue;
                const uiMd = path.join(distDir, ent.name, 'ui.md');
                if (!fs.existsSync(uiMd)) continue;
                const txt = safeRead(uiMd);
                const titleMatch = txt.match(/^#\s*([^\n\[]+?)(?:\s*\[([A-Za-z0-9_]+)\])?\s*$/m);
                if (titleMatch) {
                    map[ent.name.toLowerCase()] = titleMatch[1].trim();
                }
            }
        } catch (_) {}
    }

    // b) FE 프로젝트 내 menu-index.md / menus.json
    const indexCandidates = findFiles(fePath, (_full, name) =>
        /^menu[-_]?index\.md$/i.test(name) ||
        /^menus?\.json$/i.test(name) ||
        /^menu[-_]list\.json$/i.test(name),
        { maxDepth: 6 });
    for (const f of indexCandidates) {
        const txt = safeRead(f);
        if (f.endsWith('.json')) {
            try {
                const j = JSON.parse(txt);
                const list = Array.isArray(j) ? j : (j.menus || j.items || []);
                for (const m of list) {
                    const c = (m.code || m.id || m.menuCode || '').toLowerCase();
                    const n = m.name || m.menuName || m.title;
                    if (c && n) map[c] = n;
                }
            } catch (_) {}
        } else {
            const re = /\|\s*([a-z][a-z0-9_]*)\s*\|\s*([^|\n]+?)\s*\|/g;
            let m;
            while ((m = re.exec(txt)) !== null) {
                const c = m[1].toLowerCase();
                const n = m[2].trim();
                if (c && n && !/^[-=]+$/.test(n)) map[c] = n;
            }
        }
    }
    return map;
}

// ── BE Controller 스캔 ─────────────────────────────────────────
const ADMIN_URL_PATTERNS_BE = [
    /^\/?sm\//i,
    /^\/?admin\//i,
    /^\/?mgmt\//i,
    /^\/?manage\//i,
    /^\/?system\//i,
    /^\/?config\//i,
    /^\/?setting(s)?\//i,
    /^\/?md(m)?\//i,    // /md/, /mdm/
    /^\/?auth\//i,
    /^\/?permission(s)?\//i,
    /^\/?role(s)?\//i,
];

const ADMIN_PKG_KEYWORDS = ['sm', 'admin', 'mdm', 'master', 'system', 'config', 'auth', 'permission', 'role'];

function extractBackendAdminUrls(bePath) {
    if (!bePath) return [];
    const files = findFiles(bePath, (_full, name) => /\.(java|kt)$/.test(name), { maxDepth: 12 });
    const adminUrls = [];

    for (const f of files) {
        const txt = safeRead(f);
        const isController =
            /@RestController\b/.test(txt) ||
            /@Controller\b/.test(txt) ||
            /class\s+\w+Controller\b/.test(txt);
        if (!isController) continue;

        // 패키지 추출
        let pkg = '';
        const mPkg = txt.match(/^\s*package\s+([\w\.]+);?/m);
        if (mPkg) pkg = mPkg[1];
        const pkgLower = pkg.toLowerCase();
        const pkgIsAdmin = ADMIN_PKG_KEYWORDS.some(k => pkgLower.includes('.' + k + '.') || pkgLower.endsWith('.' + k) || pkgLower.includes('.' + k));

        // 클래스 레벨 @RequestMapping
        let classUrl = '';
        const mClassRm = txt.match(/@RequestMapping\s*\(\s*(?:value\s*=\s*)?["']([^"']+)["']/);
        if (mClassRm) classUrl = mClassRm[1];

        // 클래스명
        const mClassName = txt.match(/class\s+(\w+Controller)\b/);
        const className = mClassName ? mClassName[1] : '';

        // 메서드 레벨 @GetMapping/@PostMapping/@RequestMapping
        const methodRegex = /@(?:Request|Get|Post|Put|Delete|Patch)Mapping\s*\(\s*(?:value\s*=\s*)?["']([^"']+)["']/g;
        let m;
        const methodUrls = [];
        while ((m = methodRegex.exec(txt)) !== null) {
            methodUrls.push(m[1]);
        }
        if (methodUrls.length === 0 && classUrl) methodUrls.push('');

        for (const mu of methodUrls) {
            const full = (classUrl + '/' + (mu || '')).replace(/\/+/g, '/').replace(/\/$/, '') || '/';
            if (ADMIN_URL_PATTERNS_BE.some(re => re.test(full)) || pkgIsAdmin) {
                adminUrls.push({
                    file: f.replace(/\\/g, '/').slice(bePath.replace(/\\/g, '/').length),
                    pkg, className, classUrl, methodUrl: mu, fullUrl: full,
                });
            }
        }
    }
    return adminUrls;
}

function backendUrlsToMenus(beUrls) {
    // BE URL prefix 에서 운영자 메뉴 후보를 만들어낸다.
    // 마지막 segment 가 영문+숫자 패턴이면 메뉴코드로 채택.
    const map = new Map();
    for (const u of beUrls) {
        const segs = u.fullUrl.split('/').filter(Boolean);
        if (segs.length === 0) continue;
        // 가장 가능성 높은 메뉴코드 후보: 끝에서부터 영문+숫자 패턴
        let code = '';
        for (let i = segs.length - 1; i >= 0; i--) {
            const s = segs[i].toLowerCase().replace(/[^a-z0-9_]/g, '');
            if (/^[a-z]{2,}\d{1,3}$/.test(s)) { code = s; break; }
            if (/^[a-z]{2,5}$/.test(s) && i === segs.length - 1) { code = s; break; }
        }
        if (!code) continue;
        // 패키지나 classUrl 에서 path prefix 추출
        const pathPrefix = '/' + segs.slice(0, Math.max(1, segs.length - 1)).join('/');
        if (!map.has(code)) {
            map.set(code, {
                code,
                path: pathPrefix + '/' + code,
                source: ['be-controller'],
                beHints: [u.className],
            });
        } else {
            const ex = map.get(code);
            if (!ex.beHints.includes(u.className)) ex.beHints.push(u.className);
        }
    }
    return Array.from(map.values());
}

// ── 뷰포트 힌트 (운영자 메뉴는 거의 항상 desktop) ─────────────
function viewportHint(code, p) {
    if (PDA_PATH.test(p || '')) return 'pda';
    if (/m$/i.test(code) && /^br/i.test(code)) return 'pda';
    return 'desktop';
}

// ── 메인 실행 ──────────────────────────────────────────────────
const { framework, devPort } = detectFramework(fePath);
const feRoutes = extractRoutesFromFiles(fePath);
const nameMap = buildMenuNameMap(fePath);
const beUrls = bePath ? extractBackendAdminUrls(bePath) : [];
const beMenus = backendUrlsToMenus(beUrls);

// 1) FE 라우트 중 운영자 메뉴 필터
const adminMap = new Map();
const rejected = [];

for (const r of feRoutes) {
    if (!/^[a-z][a-z0-9_]{1,}$/.test(r.code)) continue;
    const name = nameMap[r.code] || '';
    const isAdmin = isAdminByPath(r.path) || isAdminByCode(r.code) || isAdminByName(name);
    if (!isAdmin) {
        rejected.push({
            code: r.code,
            name: name || r.code.toUpperCase(),
            path: r.path,
            reason: rejectReason({ code: r.code, name, path: r.path }),
        });
        continue;
    }
    adminMap.set(r.code, {
        code: r.code,
        name: name || r.code.toUpperCase(),
        path: r.path,
        category: categorize({ code: r.code, path: r.path }),
        source: ['fe-route'],
        viewportHint: viewportHint(r.code, r.path),
    });
}

// 2) BE 보강 — FE 에 없는 운영자 메뉴를 추가
for (const bm of beMenus) {
    const name = nameMap[bm.code] || bm.code.toUpperCase();
    if (adminMap.has(bm.code)) {
        const ex = adminMap.get(bm.code);
        if (!ex.source.includes('be-controller')) ex.source.push('be-controller');
        ex.beHints = bm.beHints;
        continue;
    }
    // FE 라우트에 없지만 BE Controller 가 운영자 prefix 인 경우 → 후보로 추가
    if (!isAdminByPath(bm.path) && !isAdminByCode(bm.code) && !isAdminByName(name)) {
        // BE 만 있고 운영자 패턴이 아니면 skip
        continue;
    }
    adminMap.set(bm.code, {
        code: bm.code,
        name,
        path: bm.path,
        category: categorize({ code: bm.code, path: bm.path }),
        source: bm.source,
        beHints: bm.beHints,
        viewportHint: viewportHint(bm.code, bm.path),
    });
}

// 3) 이름 보강: nameMap 적용
for (const v of adminMap.values()) {
    if (nameMap[v.code] && (!v.name || v.name === v.code.toUpperCase())) {
        v.name = nameMap[v.code];
    }
}

const adminMenus = Array.from(adminMap.values()).sort((a, b) => {
    // 카테고리 → 코드 순으로 정렬
    const ca = a.category || '';
    const cb = b.category || '';
    if (ca !== cb) return ca.localeCompare(cb);
    return a.code.localeCompare(b.code);
});

const result = {
    fePath,
    bePath: bePath || null,
    framework,
    devPort,
    guessedBaseUrl: devPort ? `http://localhost:${devPort}` : null,
    adminMenus,
    rejected: rejected.slice(0, 40),
    beUrlsFound: beUrls.length,
    feRoutesFound: feRoutes.length,
    scannedAt: new Date().toISOString(),
};

fs.writeFileSync(OUT_FILE, JSON.stringify(result, null, 2), 'utf8');

console.log(`[OK] ${OUT_FILE}`);
console.log(`     framework=${framework}, devPort=${devPort || 'unknown'}`);
console.log(`     FE 라우트 ${feRoutes.length}개 발견 → 운영자 메뉴 ${adminMenus.length}개 (제외 ${rejected.length}개)`);
if (bePath) {
    console.log(`     BE Controller 운영자 URL ${beUrls.length}개 매칭`);
}
if (adminMenus.length === 0) {
    console.log('[WARN] 운영자 메뉴 후보를 추출하지 못했습니다. 다음 단계에서 사용자에게 메뉴 목록을 직접 입력받으세요.');
}
