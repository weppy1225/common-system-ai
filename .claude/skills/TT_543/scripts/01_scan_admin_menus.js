#!/usr/bin/env node
/**
 * [TT_543] 1?④퀎 ??FE + BE ?꾨줈?앺듃 ?ㅼ틪?쇰줈 ?댁쁺??愿由ъ옄) 硫붾돱 ?꾨낫 異붿텧
 *
 * ?ъ슜踰?
 *   node 01_scan_admin_menus.js "<FE ?꾨줈?앺듃 寃쎈줈>" "<BE ?꾨줈?앺듃 寃쎈줈>"
 *
 * 異쒕젰:
 *   output/05 ?댄뻾(TT)/tmp_543/admin_menu_candidates.json
 *
 * ?숈옉:
 *   1) FE 痢? package.json/vite.config ?먯꽌 dev ?ы듃 異붿텧
 *   2) FE 痢? router/views/pages ?먯꽌 ?쇱슦??異붿텧
 *   3) FE 痢? ?댁쁺??硫붾돱 ?꾪꽣 ?곸슜 (path ?먮뒗 code ?⑦꽩 湲곕컲)
 *   4) BE 痢? Controller / @RequestMapping ?먯꽌 URL prefix 異붿텧?섏뿬 蹂닿컯
 *   5) cloud-wms-doc 30-domain/{硫붾돱肄붾뱶}/ui.md ?먮뒗 menu-index.md ?먯꽌 硫붾돱紐?留ㅽ븨
 *   6) JSON ?쇰줈 ??? *
 * ???ㅽ겕由쏀듃??Windows ?ㅼ씠?곕툕 寃쎈줈(C:\...) ? WSL 寃쎈줈(/mnt/c/...) 瑜?紐⑤몢 諛쏅뒗??
 */
'use strict';

const fs = require('fs');
const path = require('path');

// ?? 寃쎈줈 ?뺢퇋??(Windows / WSL ?묐갑?? ??????????????????????????
// 蹂??ㅽ겕由쏀듃??.claude/skills/TT_543/scripts/ ?덉뿉 ?덉쑝誘濡?// repo root = parents[3]. node ?ㅽ뻾 ?꾩튂? 臾닿??섍쾶 ?숈옉?섎룄濡?__dirname 湲곗??쇰줈 怨꾩궛?쒕떎.
const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..', '..', '..');
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 ?댄뻾(TT)', 'tmp_543');
const OUT_FILE = path.join(TMP_DIR, 'admin_menu_candidates.json');

function normalizePath(p) {
    if (!p) return p;
    // Windows -> POSIX 遺꾨━???듭씪 (Node ?먯껜媛 ?묒そ 吏??
    let s = String(p).replace(/\\+/g, '/');
    // WSL 寃쎈줈(/mnt/c/...) 瑜?洹몃?濡??ъ슜 (Node 媛 WSL ?섍꼍?대㈃ fs.existsSync 媛 ?숈옉)
    // Windows native 寃쎈줈(C:/...) ??洹몃?濡??ъ슜 (Node Windows 鍮뚮뱶媛 ?먮룞 泥섎━)
    return s.replace(/\/+$/, '');
}

// ?? ?몄옄 ?뚯떛 ???????????????????????????????????????????????????
let fePath = process.argv[2];
let bePath = process.argv[3];

if (!fePath) {
    console.error('[ERR] FE ?꾨줈?앺듃 寃쎈줈瑜?泥?踰덉㎏ ?몄옄濡??꾨떖?섏꽭??');
    process.exit(1);
}
fePath = normalizePath(fePath);
if (bePath) bePath = normalizePath(bePath);

if (!fs.existsSync(fePath)) {
    console.error(`[ERR] FE 寃쎈줈媛 議댁옱?섏? ?딆뒿?덈떎: ${fePath}`);
    process.exit(1);
}
if (bePath && !fs.existsSync(bePath)) {
    console.error(`[WARN] BE 寃쎈줈媛 議댁옱?섏? ?딆뒿?덈떎 (FE 留뚯쑝濡?吏꾪뻾): ${bePath}`);
    bePath = null;
}

fs.mkdirSync(TMP_DIR, { recursive: true });

// ?? ?좏떥 ????????????????????????????????????????????????????????
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

// ?? ?댁쁺??硫붾돱 ?앸퀎 湲곗? ????????????????????????????????????????

// (A) FE ?쇱슦??寃쎈줈 ?⑦꽩
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

// (B) 硫붾돱 肄붾뱶 ?묐몢???⑦꽩 (?곷Ц prefix 湲곕컲)
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
    '공통코드', '공통 코드', '시스템알림설정', '시스템사용자',
    '시스템설정', '시스템환경', '사업장', '센터', '창고', '로그인이력',
    '그룹 관리', '그룹관리', '관리', '설정',
];
// (E) ?쒖쇅 湲곗? ???쇰컲 ?낅Т 硫붾돱
// (E) 제외 기준 → 현장운영 메뉴
    /^iw\d/i,    // ?낃퀬
    /^iw\d/i,    // 입고
    /^ob\d/i,    // 출고
    /^iv\d/i,    // 재고
    /^rt\d/i,    // 반품
    /^pk\d/i,    // 피킹
    /^dl\d/i,    // 배송
    /^pda/i,     // pda*
];
const NON_ADMIN_NAME_KEYWORDS = [
    '?낃퀬', '異쒓퀬', '?ш퀬', '諛섑뭹', '?쇳궧', '諛곗넚', '二쇰Ц',
    '입고', '출고', '재고', '반품', '피킹', '배송', '현장',
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
        // "?ш퀬愿由? 泥섎읆 ???ㅼ썙?쒓? ???ㅼ뼱媛硫??쇰컲 硫붾돱濡?蹂몃떎
        // "재고관리" 류의 키워드가 있어도 현장 메뉴로 분류
        // 단 "사용자관리", "메뉴관리", "권한관리" 등 강한 관리자 키워드가 있으면 관리자로 분류
        const ADMIN_STRONG = ['사용자관리', '메뉴관리', '권한', '공통코드',
            '사용자 관리', '메뉴 관리', '시스템알림설정', '시스템사용자',
            '시스템설정', '시스템환경', '관리자'];
    }
    return ADMIN_NAME_KEYWORDS.some(k => name.includes(k));
}
function rejectReason(menu) {
    if (!menu) return 'unknown';
    if (menu.path && PDA_PATH.test(menu.path)) return 'PDA 硫붾돱';
    if (menu.path && PDA_PATH.test(menu.path)) return 'PDA 메뉴';
        return '?쇰컲?낅Т硫붾돱(?낆텧怨??ш퀬/諛섑뭹/?쇳궧/諛곗넚)';
        return '현장운영메뉴(입고/출고/재고/반품/피킹/배송)';
    if (NON_ADMIN_NAME_KEYWORDS.some(k => (menu.name || '').includes(k))) {
        return `?쇰컲?낅Т硫붾돱(${NON_ADMIN_NAME_KEYWORDS.find(k => menu.name.includes(k))})`;
        return `현장운영메뉴(${NON_ADMIN_NAME_KEYWORDS.find(k => menu.name.includes(k))})`; 
    return '?댁쁺??硫붾돱 ?⑦꽩 誘몄씪移?;
    return '관리자 메뉴 기준 미해당';

function categorize(menu) {
    const p = menu.path || '';
    const c = menu.code || '';
    if (/^mdm/i.test(c) || /(^|\/)md(\/|$)/i.test(p)) return '留덉뒪??;
    if (/^mdm/i.test(c) || /(^|\/)md(\/|$)/i.test(p)) return '마스터';
    if (/(^|\/)auth(\/|$)/i.test(p) || /^auth|^role|^perm/i.test(c)) return '권한관리';
    if (/(^|\/)sm(\/|$)/i.test(p) || /^sm/i.test(c)) return '시스템관리';
    if (/(^|\/)admin(\/|$)/i.test(p) || /^adm/i.test(c)) return '관리자';
    if (/(^|\/)system(\/|$)/i.test(p) || /^sys/i.test(c)) return '시스템';
    return '관리';

// ?? FE ?꾨젅?꾩썙??/ dev ?ы듃 媛먯? ??????????????????????????????
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

// ?? FE ?쇱슦??異붿텧 ?????????????????????????????????????????????
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

    // views/pages ?먮룞 ?몄떇 (蹂댁“)
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
                // ?뚯씪 寃쎈줈?먯꽌 異붾줎??媛吏?path ???댁쁺???붾젆?좊━???덈뒗吏 ?뺤씤??                const rel = v.replace(/\\/g, '/').slice(fePath.replace(/\\/g, '/').length);
                if (!found.has(code)) {
                    found.set(code, { code, path: rel.replace(/\.(vue|tsx|jsx|svelte)$/, '') });
                }
            }
        }
    }
    return Array.from(found.values());
}

// ?? 硫붾돱紐?留ㅽ븨 ?????????????????????????????????????????????
function buildMenuNameMap(fePath) {
    const map = {};

    // a) cloud-wms-doc ??30-domain/{硫붾돱肄붾뱶}/ui.md
    const distDir = path.join(REPO_ROOT, '30-domain');
    if (fs.existsSync(distDir)) {
        try {
            for (const ent of fs.readdirSync(distDir, { withFileTypes: true })) {
                if (!ent.isDirectory()) continue;
                const uiMd = path.join(distDir, ent.name, ${ent.name}-02-ui.md);
                if (!fs.existsSync(uiMd)) continue;
                const txt = safeRead(uiMd);
                const titleMatch = txt.match(/^#\s*([^\n\[]+?)(?:\s*\[([A-Za-z0-9_]+)\])?\s*$/m);
                if (titleMatch) {
                    map[ent.name.toLowerCase()] = titleMatch[1].trim();
                }
            }
        } catch (_) {}
    }

    // b) FE ?꾨줈?앺듃 ??menu-index.md / menus.json
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

// ?? BE Controller ?ㅼ틪 ?????????????????????????????????????????
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

        // ?⑦궎吏 異붿텧
        let pkg = '';
        const mPkg = txt.match(/^\s*package\s+([\w\.]+);?/m);
        if (mPkg) pkg = mPkg[1];
        const pkgLower = pkg.toLowerCase();
        const pkgIsAdmin = ADMIN_PKG_KEYWORDS.some(k => pkgLower.includes('.' + k + '.') || pkgLower.endsWith('.' + k) || pkgLower.includes('.' + k));

        // ?대옒???덈꺼 @RequestMapping
        let classUrl = '';
        const mClassRm = txt.match(/@RequestMapping\s*\(\s*(?:value\s*=\s*)?["']([^"']+)["']/);
        if (mClassRm) classUrl = mClassRm[1];

        // ?대옒?ㅻ챸
        const mClassName = txt.match(/class\s+(\w+Controller)\b/);
        const className = mClassName ? mClassName[1] : '';

        // 硫붿꽌???덈꺼 @GetMapping/@PostMapping/@RequestMapping
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
    // BE URL prefix ?먯꽌 ?댁쁺??硫붾돱 ?꾨낫瑜?留뚮뱾?대궦??
    // 留덉?留?segment 媛 ?곷Ц+?レ옄 ?⑦꽩?대㈃ 硫붾돱肄붾뱶濡?梨꾪깮.
    const map = new Map();
    for (const u of beUrls) {
        const segs = u.fullUrl.split('/').filter(Boolean);
        if (segs.length === 0) continue;
        // 媛??媛?μ꽦 ?믪? 硫붾돱肄붾뱶 ?꾨낫: ?앹뿉?쒕????곷Ц+?レ옄 ?⑦꽩
        let code = '';
        for (let i = segs.length - 1; i >= 0; i--) {
            const s = segs[i].toLowerCase().replace(/[^a-z0-9_]/g, '');
            if (/^[a-z]{2,}\d{1,3}$/.test(s)) { code = s; break; }
            if (/^[a-z]{2,5}$/.test(s) && i === segs.length - 1) { code = s; break; }
        }
        if (!code) continue;
        // ?⑦궎吏??classUrl ?먯꽌 path prefix 異붿텧
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

// ?? 酉고룷???뚰듃 (?댁쁺??硫붾돱??嫄곗쓽 ??긽 desktop) ?????????????
function viewportHint(code, p) {
    if (PDA_PATH.test(p || '')) return 'pda';
    if (/m$/i.test(code) && /^br/i.test(code)) return 'pda';
    return 'desktop';
}

// ?? 硫붿씤 ?ㅽ뻾 ??????????????????????????????????????????????????
const { framework, devPort } = detectFramework(fePath);
const feRoutes = extractRoutesFromFiles(fePath);
const nameMap = buildMenuNameMap(fePath);
const beUrls = bePath ? extractBackendAdminUrls(bePath) : [];
const beMenus = backendUrlsToMenus(beUrls);

// 1) FE ?쇱슦??以??댁쁺??硫붾돱 ?꾪꽣
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

// 2) BE 蹂닿컯 ??FE ???녿뒗 ?댁쁺??硫붾돱瑜?異붽?
for (const bm of beMenus) {
    const name = nameMap[bm.code] || bm.code.toUpperCase();
    if (adminMap.has(bm.code)) {
        const ex = adminMap.get(bm.code);
        if (!ex.source.includes('be-controller')) ex.source.push('be-controller');
        ex.beHints = bm.beHints;
        continue;
    }
    // FE ?쇱슦?몄뿉 ?놁?留?BE Controller 媛 ?댁쁺??prefix ??寃쎌슦 ???꾨낫濡?異붽?
    if (!isAdminByPath(bm.path) && !isAdminByCode(bm.code) && !isAdminByName(name)) {
        // BE 留??덇퀬 ?댁쁺???⑦꽩???꾨땲硫?skip
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

// 3) ?대쫫 蹂닿컯: nameMap ?곸슜
for (const v of adminMap.values()) {
    if (nameMap[v.code] && (!v.name || v.name === v.code.toUpperCase())) {
        v.name = nameMap[v.code];
    }
}

const adminMenus = Array.from(adminMap.values()).sort((a, b) => {
    // 移댄뀒怨좊━ ??肄붾뱶 ?쒖쑝濡??뺣젹
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
console.log(`     FE ?쇱슦??${feRoutes.length}媛?諛쒓껄 ???댁쁺??硫붾돱 ${adminMenus.length}媛?(?쒖쇅 ${rejected.length}媛?`);
if (bePath) {
    console.log(`     BE Controller ?댁쁺??URL ${beUrls.length}媛?留ㅼ묶`);
}
if (adminMenus.length === 0) {
    console.log('[WARN] ?댁쁺??硫붾돱 ?꾨낫瑜?異붿텧?섏? 紐삵뻽?듬땲?? ?ㅼ쓬 ?④퀎?먯꽌 ?ъ슜?먯뿉寃?硫붾돱 紐⑸줉??吏곸젒 ?낅젰諛쏆쑝?몄슂.');
}
