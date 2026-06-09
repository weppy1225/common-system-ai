#!/usr/bin/env node
/**
 * [TT_542] 1?④퀎 ??FE ?꾨줈?앺듃 ?ㅼ틪?쇰줈 PDA(紐⑤컮?? ?ъ슜??硫붾돱 ?꾨낫 異붿텧
 *
 * ?ъ슜踰?
 *   node 01_scan_project.js "<FE ?꾨줈?앺듃 寃쎈줈>"
 *
 * 異쒕젰:
 *   output/05 ?댄뻾(TT)/tmp_542/menu_candidates.json
 *
 * ?숈옉:
 *   1) package.json / vite.config / next.config ?깆뿉??dev ?ы듃 異붿텧
 *   2) router ?뚯씪 ?먮뒗 views/pages ?붾젆?좊━?먯꽌 ?쇱슦??硫붾돱) 異붿텧
 *   3) menu-index.md / menus.json ?뚯씪???덉쑝硫?硫붾돱紐?留ㅽ븨
 *   4) cloud-wms-doc ??50-prototype/20-mobile/{洹몃９}/{硫붾돱}.html ???덉쑝硫?硫붾돱紐??곗꽑 留ㅽ븨
 *   5) PDA 硫붾돱留?異붿텧 ??肄붾뱶 ??m ?먮뒗 寃쎈줈 /bm/쨌/pda/쨌/mobile/ ?먮뒗 遺紐?segment 媛 *m ?⑦꽩
 *   6) PC 硫붾돱(/be/...)???먮룞 ?쒖쇅
 *   7) JSON ?쇰줈 ??? *
 * ???ㅽ겕由쏀듃??Windows ?ㅼ씠?곕툕 寃쎈줈(C:\...) ? WSL 寃쎈줈(/mnt/c/...) 瑜?紐⑤몢 諛쏅뒗??
 */
'use strict';

const fs = require('fs');
const path = require('path');

// ?? 寃쎈줈 ?뺢퇋??(Windows / WSL ?묐갑?? ??????????????????????????
// 蹂??ㅽ겕由쏀듃??.claude/skills/TT_542/scripts/ ?덉뿉 ?덉쑝誘濡?// repo root = parents[3]. node ?ㅽ뻾 ?꾩튂? 臾닿??섍쾶 __dirname 湲곗??쇰줈 怨꾩궛?쒕떎.
const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..', '..', '..');
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 ?댄뻾(TT)', 'tmp_542');
const OUT_FILE = path.join(TMP_DIR, 'menu_candidates.json');

function normalizePath(p) {
    if (!p) return p;
    let s = String(p).replace(/\\+/g, '/');
    return s.replace(/\/+$/, '');
}

// ?? ?몄옄 ?뚯떛 ???????????????????????????????????????????????????
let fePath = process.argv[2];
if (!fePath) {
    console.error('[ERR] FE ?꾨줈?앺듃 寃쎈줈瑜?泥?踰덉㎏ ?몄옄濡??꾨떖?섏꽭??');
    process.exit(1);
}
fePath = normalizePath(fePath);

if (!fs.existsSync(fePath)) {
    console.error(`[ERR] 寃쎈줈媛 議댁옱?섏? ?딆뒿?덈떎: ${fePath}`);
    process.exit(1);
}

fs.mkdirSync(TMP_DIR, { recursive: true });

// ?? PDA 硫붾돱 ?앸퀎 ??????????????????????????????????????????????
// cloud-wms-fe 湲곗? PDA ?쇱슦???⑦꽩:
//   - 寃쎈줈: /bm/{洹몃９肄붾뱶m}/{硫붾돱肄붾뱶m}  (?? /bm/iv3000m/ivad01m)
//   - 洹몃９ segment: ?곷Ц + ?レ옄 + 'm' (?? iv3000m, md8000m)
//   - 硫붾돱 肄붾뱶: ?앹씠 'm' (?? ivad01m, ivmvrq01m, sksp01m)
// PC ?쇱슦???⑦꽩:
//   - 寃쎈줈: /be/{洹몃９肄붾뱶}/{硫붾돱肄붾뱶}  (?? /be/iv3000/ivad01)
function isPdaMenu(code, p) {
    if (p) {
        const ps = String(p).toLowerCase();
        // 1. 紐낆떆??PDA 寃쎈줈 prefix
        if (ps.includes('/bm/') || ps.includes('/pda/') || ps.includes('/mobile/')) return true;
        // 2. 遺紐?segment 媛 'm' ?쇰줈 ?앸궓 (?? /iv3000m/ivad01m)
        const segs = ps.split('/').filter(Boolean);
        for (const seg of segs.slice(0, -1)) {
            if (/^[a-z]+\d+m$/i.test(seg)) return true;
        }
    }
    // 3. 硫붾돱 肄붾뱶 ?앹씠 'm' (?? ivad01m, ivmvrq01m)
    if (code && /^[a-z][a-z0-9]+m$/i.test(code)) return true;
    if (code && /^pda/i.test(code)) return true;
    return false;
}

// ?? ?좏떥 ????????????????????????????????????????????????????????
function safeRead(p) {
    try { return fs.readFileSync(p, 'utf8'); }
    catch (_) { return ''; }
}

function findFiles(rootDir, predicate, opts = {}) {
    const { skipDirs = ['node_modules', '.git', 'dist', 'build', '.next', '.nuxt', 'coverage'], maxDepth = 8 } = opts;
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

// ?? 1) ?꾨젅?꾩썙??媛먯? + dev ?ы듃 異붿텧 ????????????????????????
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
    else if (deps['@vitejs/plugin-vue'] || deps['vue'] && deps['vite']) framework = 'vue3-vite';
    else if (deps['vue'] && (deps['@vue/cli-service'] || deps['vue-cli-plugin-webpack'])) framework = 'vue-cli';
    else if (deps['vue']) framework = 'vue';
    else if (deps['react'] && deps['vite']) framework = 'react-vite';
    else if (deps['react']) framework = 'react';
    else if (deps['svelte']) framework = 'svelte';

    // dev script ??--port ?듭뀡?먯꽌 異붿텧
    let devPort = null;
    const devScripts = [pkg?.scripts?.dev, pkg?.scripts?.start, pkg?.scripts?.serve].filter(Boolean);
    for (const s of devScripts) {
        const m = s.match(/--port[= ](\d{2,5})/) || s.match(/-p\s+(\d{2,5})/);
        if (m) { devPort = parseInt(m[1], 10); break; }
    }

    // vite.config / next.config / nuxt.config / vue.config / webpack.config ?먯꽌 fallback 異붿텧
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

    // 湲곕낯媛?    if (!devPort) {
        if (framework === 'next') devPort = 3000;
        else if (framework === 'nuxt') devPort = 3000;
        else if (framework.startsWith('vue3-vite') || framework === 'react-vite') devPort = 5173;
        else if (framework === 'vue-cli' || framework === 'react') devPort = 8080;
    }
    return { framework, devPort };
}

// ?? 2) ?쇱슦??硫붾돱) 異붿텧 ???????????????????????????????????????
const ROUTE_FILE_PATTERNS = [
    /router\/index\.(js|ts)$/i,
    /router\/routes\.(js|ts)$/i,
    /routes\/index\.(js|ts|tsx)$/i,
    /src\/router\.[jt]s$/i,
    /src\/routes\.[jt]s$/i,
    /router\/modules\/.+\.(js|ts)$/i,   // cloud-wms-fe: src/router/modules/{be,bm}/{group}.js
    /App\.(jsx|tsx)$/,
];

function extractRoutesFromText(txt) {
    const out = [];
    // path: '/be/.../mdpr01' ?먮뒗 path: "..." ?⑦꽩
    const pathRegex = /path\s*:\s*['"`]([^'"`]+)['"`][\s\S]{0,200}?(?:component|element|name)\s*:\s*[^,\n]+/g;
    let m;
    while ((m = pathRegex.exec(txt)) !== null) {
        const p = m[1];
        if (!p || p === '/' || p === '*' || p === '/:catchAll(.*)') continue;
        // 硫붾돱肄붾뱶 ?꾨낫 = 留덉?留?segment (`/be/md8000/mdpr01` ??`mdpr01`)
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

    // views/pages ?먮룞 ?몄떇 (?쇱슦???뚯씪???녾굅??異붿텧 ?ㅽ뙣??寃쎌슦 蹂댁“)
    if (found.size === 0) {
        const viewDirs = ['src/views', 'src/pages', 'pages', 'app'];
        for (const vd of viewDirs) {
            const dir = path.join(fePath, vd);
            if (!fs.existsSync(dir)) continue;
            const vues = findFiles(dir, (_full, name) => /\.(vue|tsx|jsx|svelte)$/.test(name), { maxDepth: 6 });
            for (const v of vues) {
                const base = path.basename(v).replace(/\.(vue|tsx|jsx|svelte)$/, '');
                if (base === 'index' || base === '_app' || base === '_layout' || base === 'default') continue;
                const code = base.toLowerCase().replace(/[^a-zA-Z0-9_-]/g, '');
                if (!code) continue;
                if (!found.has(code)) {
                    found.set(code, { code, path: '/' + code });
                }
            }
        }
    }
    return Array.from(found.values());
}

// ?? 3) 硫붾돱紐?留ㅽ븨 ?????????????????????????????????????????????
function buildMenuNameMap(fePath) {
    const map = {};

    // a) cloud-wms-doc ??30-domain/{硫붾돱肄붾뱶}/ui.md (PC 硫붾돱紐낆쓣 PDA 硫붾돱 留ㅽ븨?먮룄 ?쒖슜)
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
                    const code = ent.name.toLowerCase();
                    const name = titleMatch[1].trim();
                    map[code] = name;
                    // PDA 蹂??肄붾뱶???숈씪 硫붾돱紐낆쑝濡?留ㅽ븨 (mdpr01 ??mdpr01m)
                    map[code + 'm'] = name;
                }
            }
        } catch (_) {}
    }

    // a2) cloud-wms-doc ??50-prototype/20-mobile/{洹몃９m}/{硫붾돱}.html ??PDA ?꾩슜 硫붾돱紐?留ㅽ븨
    const distMobileDir = path.join(REPO_ROOT, '50-prototype', '20-mobile');
    if (fs.existsSync(distMobileDir)) {
        try {
            for (const grp of fs.readdirSync(distMobileDir, { withFileTypes: true })) {
                if (!grp.isDirectory()) continue;
                if (!/^[a-z]+\d+m$/i.test(grp.name)) continue;   // *m ?⑦꽩 洹몃９留?                const grpPath = path.join(distMobileDir, grp.name);
                let files;
                try { files = fs.readdirSync(grpPath); } catch (_) { continue; }
                for (const f of files) {
                    if (!/\.html$/i.test(f)) continue;
                    if (/-data\./i.test(f)) continue;
                    const baseCode = f.replace(/\.html$/i, '').toLowerCase();
                    // PDA 硫붾돱 肄붾뱶??蹂댄넻 'm'?쇰줈 ?앸굹誘濡?蹂댁젙
                    const pdaCode = /m$/i.test(baseCode) ? baseCode : baseCode + 'm';
                    const html = safeRead(path.join(grpPath, f));
                    // HTML ?덉쓽 <title>...</title> ?먮뒗 泥ル쾲吏??ㅻ뜑 ?띿뒪?몄뿉??硫붾돱紐?異붿텧 ?쒕룄
                    const titleTag = html.match(/<title>\s*([^<]+?)\s*<\/title>/i);
                    if (titleTag && titleTag[1] && titleTag[1] !== '硫붾돱') {
                        map[pdaCode] = titleTag[1].trim();
                    }
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
            // markdown ?? | mdpr01 | ?ъ??덇?由?|
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

// ?? 4) 酉고룷???뚰듃 (path + code 湲곕컲) ????????????????????????
function viewportHint(code, p) {
    return isPdaMenu(code, p) ? 'pda' : 'desktop';
}

// ?? 硫붿씤 ?ㅽ뻾 ??????????????????????????????????????????????????
const { framework, devPort } = detectFramework(fePath);
const routes = extractRoutesFromFiles(fePath);
const nameMap = buildMenuNameMap(fePath);

const rawMenus = routes
    .filter(r => /^[a-z][a-z0-9_]{2,}$/.test(r.code))
    .map(r => ({
        code: r.code,
        name: nameMap[r.code] || r.code.toUpperCase(),
        path: r.path,
        viewportHint: viewportHint(r.code, r.path),
    }));

// PDA 硫붾돱留?keep (PC 硫붾돱??/TT_541 踰붿쐞濡?遺꾨━)
const menus = [];
const rejected = [];
for (const m of rawMenus) {
    if (isPdaMenu(m.code, m.path)) {
        // PDA 硫붾돱: viewportHint 媛뺤젣 'pda'
        menus.push({ ...m, viewportHint: 'pda' });
    } else {
        rejected.push({ code: m.code, name: m.name, reason: 'PC 硫붾돱(/be/... ?먮뒗 肄붾뱶 ?앹씠 m???꾨떂) ??/TT_541 ?먯꽌 泥섎━' });
    }
}
menus.sort((a, b) => a.code.localeCompare(b.code));
rejected.sort((a, b) => a.code.localeCompare(b.code));

const result = {
    fePath,
    framework,
    devPort,
    guessedBaseUrl: devPort ? `http://localhost:${devPort}` : null,
    menus,
    rejected,
    scannedAt: new Date().toISOString(),
};

fs.writeFileSync(OUT_FILE, JSON.stringify(result, null, 2), 'utf8');
console.log(`[OK] ${OUT_FILE}`);
console.log(`     framework=${framework}, devPort=${devPort || 'unknown'}, menus=${menus.length}`);
if (menus.length === 0) {
    console.log('[WARN] 硫붾돱 ?꾨낫瑜?異붿텧?섏? 紐삵뻽?듬땲?? ?ㅼ쓬 ?④퀎?먯꽌 ?ъ슜?먯뿉寃?硫붾돱 紐⑸줉??吏곸젒 ?낅젰諛쏆쑝?몄슂.');
}
