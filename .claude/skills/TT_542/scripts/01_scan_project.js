#!/usr/bin/env node
/**
 * [TT_542] 1단계 — FE 프로젝트 스캔으로 PDA(모바일) 사용자 메뉴 후보 추출
 *
 * 사용법:
 *   node 01_scan_project.js "<FE 프로젝트 경로>"
 *
 * 출력:
 *   output/05 이행(TT)/tmp_542/menu_candidates.json
 *
 * 동작:
 *   1) package.json / vite.config / next.config 등에서 dev 포트 추출
 *   2) router 파일 또는 views/pages 디렉토리에서 라우트(메뉴) 추출
 *   3) menu-index.md / menus.json 파일이 있으면 메뉴명 매핑
 *   4) cloud-wms-doc 의 dist-mobile/{그룹}/{메뉴}.html 이 있으면 메뉴명 우선 매핑
 *   5) PDA 메뉴만 추출 — 코드 끝 m 또는 경로 /bm/·/pda/·/mobile/ 또는 부모 segment 가 *m 패턴
 *   6) PC 메뉴(/be/...)는 자동 제외
 *   7) JSON 으로 저장
 *
 * 이 스크립트는 Windows 네이티브 경로(C:\...) 와 WSL 경로(/mnt/c/...) 를 모두 받는다.
 */
'use strict';

const fs = require('fs');
const path = require('path');

// ── 경로 정규화 (Windows / WSL 양방향) ──────────────────────────
// 본 스크립트는 .claude/skills/TT_542/scripts/ 안에 있으므로
// repo root = parents[3]. node 실행 위치와 무관하게 __dirname 기준으로 계산한다.
const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..', '..', '..');
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 이행(TT)', 'tmp_542');
const OUT_FILE = path.join(TMP_DIR, 'menu_candidates.json');

function normalizePath(p) {
    if (!p) return p;
    let s = String(p).replace(/\\+/g, '/');
    return s.replace(/\/+$/, '');
}

// ── 인자 파싱 ───────────────────────────────────────────────────
let fePath = process.argv[2];
if (!fePath) {
    console.error('[ERR] FE 프로젝트 경로를 첫 번째 인자로 전달하세요.');
    process.exit(1);
}
fePath = normalizePath(fePath);

if (!fs.existsSync(fePath)) {
    console.error(`[ERR] 경로가 존재하지 않습니다: ${fePath}`);
    process.exit(1);
}

fs.mkdirSync(TMP_DIR, { recursive: true });

// ── PDA 메뉴 식별 ──────────────────────────────────────────────
// cloud-wms-fe 기준 PDA 라우트 패턴:
//   - 경로: /bm/{그룹코드m}/{메뉴코드m}  (예: /bm/iv3000m/ivad01m)
//   - 그룹 segment: 영문 + 숫자 + 'm' (예: iv3000m, md8000m)
//   - 메뉴 코드: 끝이 'm' (예: ivad01m, ivmvrq01m, sksp01m)
// PC 라우트 패턴:
//   - 경로: /be/{그룹코드}/{메뉴코드}  (예: /be/iv3000/ivad01)
function isPdaMenu(code, p) {
    if (p) {
        const ps = String(p).toLowerCase();
        // 1. 명시적 PDA 경로 prefix
        if (ps.includes('/bm/') || ps.includes('/pda/') || ps.includes('/mobile/')) return true;
        // 2. 부모 segment 가 'm' 으로 끝남 (예: /iv3000m/ivad01m)
        const segs = ps.split('/').filter(Boolean);
        for (const seg of segs.slice(0, -1)) {
            if (/^[a-z]+\d+m$/i.test(seg)) return true;
        }
    }
    // 3. 메뉴 코드 끝이 'm' (예: ivad01m, ivmvrq01m)
    if (code && /^[a-z][a-z0-9]+m$/i.test(code)) return true;
    if (code && /^pda/i.test(code)) return true;
    return false;
}

// ── 유틸 ────────────────────────────────────────────────────────
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

// ── 1) 프레임워크 감지 + dev 포트 추출 ────────────────────────
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

    // dev script 의 --port 옵션에서 추출
    let devPort = null;
    const devScripts = [pkg?.scripts?.dev, pkg?.scripts?.start, pkg?.scripts?.serve].filter(Boolean);
    for (const s of devScripts) {
        const m = s.match(/--port[= ](\d{2,5})/) || s.match(/-p\s+(\d{2,5})/);
        if (m) { devPort = parseInt(m[1], 10); break; }
    }

    // vite.config / next.config / nuxt.config / vue.config / webpack.config 에서 fallback 추출
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

    // 기본값
    if (!devPort) {
        if (framework === 'next') devPort = 3000;
        else if (framework === 'nuxt') devPort = 3000;
        else if (framework.startsWith('vue3-vite') || framework === 'react-vite') devPort = 5173;
        else if (framework === 'vue-cli' || framework === 'react') devPort = 8080;
    }
    return { framework, devPort };
}

// ── 2) 라우트(메뉴) 추출 ───────────────────────────────────────
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
    // path: '/be/.../mdpr01' 또는 path: "..." 패턴
    const pathRegex = /path\s*:\s*['"`]([^'"`]+)['"`][\s\S]{0,200}?(?:component|element|name)\s*:\s*[^,\n]+/g;
    let m;
    while ((m = pathRegex.exec(txt)) !== null) {
        const p = m[1];
        if (!p || p === '/' || p === '*' || p === '/:catchAll(.*)') continue;
        // 메뉴코드 후보 = 마지막 segment (`/be/md8000/mdpr01` → `mdpr01`)
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

    // views/pages 자동 인식 (라우트 파일이 없거나 추출 실패한 경우 보조)
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

// ── 3) 메뉴명 매핑 ─────────────────────────────────────────────
function buildMenuNameMap(fePath) {
    const map = {};

    // a) cloud-wms-doc 의 dist/{메뉴코드}/ui.md (PC 메뉴명을 PDA 메뉴 매핑에도 활용)
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
                    const code = ent.name.toLowerCase();
                    const name = titleMatch[1].trim();
                    map[code] = name;
                    // PDA 변형 코드도 동일 메뉴명으로 매핑 (mdpr01 → mdpr01m)
                    map[code + 'm'] = name;
                }
            }
        } catch (_) {}
    }

    // a2) cloud-wms-doc 의 dist-mobile/{그룹m}/{메뉴}.html — PDA 전용 메뉴명 매핑
    const distMobileDir = path.join(REPO_ROOT, 'dist-mobile');
    if (fs.existsSync(distMobileDir)) {
        try {
            for (const grp of fs.readdirSync(distMobileDir, { withFileTypes: true })) {
                if (!grp.isDirectory()) continue;
                if (!/^[a-z]+\d+m$/i.test(grp.name)) continue;   // *m 패턴 그룹만
                const grpPath = path.join(distMobileDir, grp.name);
                let files;
                try { files = fs.readdirSync(grpPath); } catch (_) { continue; }
                for (const f of files) {
                    if (!/\.html$/i.test(f)) continue;
                    if (/-data\./i.test(f)) continue;
                    const baseCode = f.replace(/\.html$/i, '').toLowerCase();
                    // PDA 메뉴 코드는 보통 'm'으로 끝나므로 보정
                    const pdaCode = /m$/i.test(baseCode) ? baseCode : baseCode + 'm';
                    const html = safeRead(path.join(grpPath, f));
                    // HTML 안의 <title>...</title> 또는 첫번째 헤더 텍스트에서 메뉴명 추출 시도
                    const titleTag = html.match(/<title>\s*([^<]+?)\s*<\/title>/i);
                    if (titleTag && titleTag[1] && titleTag[1] !== '메뉴') {
                        map[pdaCode] = titleTag[1].trim();
                    }
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
            // markdown 표: | mdpr01 | 사은품관리 |
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

// ── 4) 뷰포트 힌트 (path + code 기반) ────────────────────────
function viewportHint(code, p) {
    return isPdaMenu(code, p) ? 'pda' : 'desktop';
}

// ── 메인 실행 ──────────────────────────────────────────────────
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

// PDA 메뉴만 keep (PC 메뉴는 /TT_541 범위로 분리)
const menus = [];
const rejected = [];
for (const m of rawMenus) {
    if (isPdaMenu(m.code, m.path)) {
        // PDA 메뉴: viewportHint 강제 'pda'
        menus.push({ ...m, viewportHint: 'pda' });
    } else {
        rejected.push({ code: m.code, name: m.name, reason: 'PC 메뉴(/be/... 또는 코드 끝이 m이 아님) — /TT_541 에서 처리' });
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
    console.log('[WARN] 메뉴 후보를 추출하지 못했습니다. 다음 단계에서 사용자에게 메뉴 목록을 직접 입력받으세요.');
}
