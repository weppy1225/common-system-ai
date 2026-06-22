#!/usr/bin/env node
/**
 * [TT_543] 1단계 - FE + BE 프로젝트 스캔으로 관리자 메뉴 후보 추출
 *
 * 사용법:
 *   node 01_scan_admin_menus.js "<FE 프로젝트 경로>" "<BE 프로젝트 경로>"
 *
 * 출력:
 *   deliverables/30-output/05 이행(TT)/tmp_543/admin_menu_candidates.json
 *
 * 동작:
 *   1) FE 측 package.json / vite.config 등에서 dev 포트 추출
 *   2) FE 측 router/views/pages 에서 라우터 추출
 *   3) FE 측 관리자 메뉴 필터 적용 (path 또는 code 패턴 기준)
 *   4) BE 측 Controller / @RequestMapping 에서 URL prefix 를 추출하여 보강
 *   5) common-system-ai 의 spec/{메뉴코드}/{메뉴코드}-02-ui.md 또는 menu-index.md 에서 메뉴명 매핑
 *   6) JSON 으로 저장
 * 이 스크립트는 Windows 드라이브 경로(C:\...) 와 WSL 경로(/mnt/c/...)를 모두 받는다.
 */
'use strict';

const fs = require('fs');
const path = require('path');

// 공통 경로 정의 (Windows / WSL 겸용)
// 본 스크립트는 .claude/skills/TT_543/scripts/ 안에 있으므로
// repo root = parents[3]. node 실행 위치와 무관하게 __dirname 기준으로 계산한다.
const SCRIPT_DIR = __dirname;
const REPO_ROOT = path.resolve(SCRIPT_DIR, '..', '..', '..', '..');
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 이행(TT)', 'tmp_543');
const OUT_FILE = path.join(TMP_DIR, 'admin_menu_candidates.json');

function normalizePath(p) {
    if (!p) return p;
    const s = String(p).replace(/\\+/g, '/');
    return s.replace(/\/+$/, '');
}

// 입력 인자 파싱
let fePath = process.argv[2];
let bePath = process.argv[3];

if (!fePath) {
    console.error('[ERR] FE 프로젝트 경로를 첫 번째 인자로 전달해주세요.');
    process.exit(1);
}
fePath = normalizePath(fePath);
if (bePath) bePath = normalizePath(bePath);

if (!fs.existsSync(fePath)) {
    console.error(`[ERR] FE 경로가 존재하지 않습니다: ${fePath}`);
    process.exit(1);
}
if (bePath && !fs.existsSync(bePath)) {
    console.error(`[WARN] BE 경로가 존재하지 않습니다 (FE만으로 진행): ${bePath}`);
    bePath = null;
}

fs.mkdirSync(TMP_DIR, { recursive: true });

// 공통 유틸
function safeRead(p) {
    try {
        return fs.readFileSync(p, 'utf8');
    } catch (_) {
        return '';
    }
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
        try {
            entries = fs.readdirSync(dir, { withFileTypes: true });
        } catch (_) {
            return;
        }
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

// 관리자 메뉴 탐지 기준

// (A) FE 라우터 경로 패턴
const ADMIN_PATH_PATTERNS = [
    /(^|\/)sm(\/|$)/i,
    /(^|\/)admin(\/|$)/i,
    /(^|\/)mgmt(\/|$)/i,
    /(^|\/)manage(\/|$)/i,
    /(^|\/)system(\/|$)/i,
    /(^|\/)setting(s)?(\/|$)/i,
    /(^|\/)config(\/|$)/i,
    /(^|\/)permission(s)?(\/|$)/i,
    /(^|\/)role(s)?(\/|$)/i,
    /(^|\/)auth(\/|$)/i,
    /(^|\/)md(\/|$)/i,
];

// (B) 메뉴 코드 패턴
const ADMIN_CODE_PREFIXES = [
    /^sm[a-z]{0,4}\d/i,
    /^mdm[a-z]{0,4}\d/i,
    /^adm[a-z]{0,4}\d/i,
    /^sys[a-z]{0,4}\d/i,
    /^cfg[a-z]{0,4}\d/i,
    /^usr[a-z]{0,4}\d/i,
    /^auth[a-z]{0,4}\d/i,
    /^role[a-z]{0,4}\d/i,
    /^perm[a-z]{0,4}\d/i,
    /^mn[a-z]{0,4}\d/i,
    /^rl[a-z]{0,4}\d/i,
];

// (C) 메뉴명 키워드
const ADMIN_NAME_KEYWORDS = [
    '관리자', '사용자관리', '사용자 관리', '권한', '메뉴관리', '메뉴 관리',
    '공통코드', '공통 코드', '시스템알림', '시스템설정', '시스템환경',
    '사업장', '센터', '창고', '로그', '그룹 관리', '그룹관리',
];

// (E) 제외 기준 → 현장운영 메뉴
const NON_ADMIN_CODE_PREFIXES = [
    /^iw\d/i,   // 입고
    /^ob\d/i,   // 출고
    /^iv\d/i,   // 재고
    /^rt\d/i,   // 반품
    /^pk\d/i,   // 피킹
    /^dl\d/i,   // 배송
    /^pda/i,    // pda*
];

const NON_ADMIN_NAME_KEYWORDS = [
    '입고', '출고', '재고', '반품', '피킹', '배송', '주문', '현장',
];

const ADMIN_STRONG_KEYWORDS = [
    '사용자관리', '사용자 관리', '메뉴관리', '메뉴 관리', '권한',
    '공통코드', '공통 코드', '시스템알림', '시스템설정', '시스템환경', '관리자',
];

const PDA_PATH = /(^|\/)(bm|pda|mobile)(\/|$)/i;

function isAdminByPath(p) {
    if (!p) return false;
    if (PDA_PATH.test(p)) return false;
    return ADMIN_PATH_PATTERNS.some((re) => re.test(p));
}

function isAdminByCode(code) {
    if (!code) return false;
    if (NON_ADMIN_CODE_PREFIXES.some((re) => re.test(code))) return false;
    return ADMIN_CODE_PREFIXES.some((re) => re.test(code));
}

function isAdminByName(name) {
    if (!name) return false;
    if (NON_ADMIN_NAME_KEYWORDS.some((keyword) => name.includes(keyword))) {
        return ADMIN_STRONG_KEYWORDS.some((keyword) => name.includes(keyword));
    }
    return ADMIN_NAME_KEYWORDS.some((keyword) => name.includes(keyword));
}

function rejectReason(menu) {
    if (!menu) return 'unknown';
    if (menu.path && PDA_PATH.test(menu.path)) return 'PDA 메뉴';
    if (NON_ADMIN_CODE_PREFIXES.some((re) => re.test(menu.code || ''))) {
        return '현장운영메뉴(입고/출고/재고/반품/피킹/배송)';
    }
    const matchedKeyword = NON_ADMIN_NAME_KEYWORDS.find((keyword) => (menu.name || '').includes(keyword));
    if (matchedKeyword) {
        return `현장운영메뉴(${matchedKeyword})`;
    }
    return '관리자 메뉴 기준 미해당';
}

function categorize(menu) {
    const routePath = menu.path || '';
    const code = menu.code || '';
    if (/^mdm/i.test(code) || /(^|\/)md(\/|$)/i.test(routePath)) return '마스터';
    if (/(^|\/)auth(\/|$)/i.test(routePath) || /^auth|^role|^perm|^rl/i.test(code)) return '권한관리';
    if (/(^|\/)sm(\/|$)/i.test(routePath) || /^sm/i.test(code)) return '시스템관리';
    if (/(^|\/)admin(\/|$)/i.test(routePath) || /^adm/i.test(code)) return '관리자';
    if (/(^|\/)system(\/|$)/i.test(routePath) || /^sys/i.test(code)) return '시스템';
    return '관리';
}

// FE 프레임워크 / dev 포트 감지
function detectFramework(rootPath) {
    const pkgPath = path.join(rootPath, 'package.json');
    if (!fs.existsSync(pkgPath)) return { framework: 'unknown', devPort: null };

    let pkg;
    try {
        pkg = JSON.parse(safeRead(pkgPath));
    } catch (_) {
        return { framework: 'unknown', devPort: null };
    }

    const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
    let framework = 'unknown';
    if (deps.next) framework = 'next';
    else if (deps.nuxt || deps.nuxt3) framework = 'nuxt';
    else if (deps['@vitejs/plugin-vue'] || (deps.vue && deps.vite)) framework = 'vue3-vite';
    else if (deps.vue && (deps['@vue/cli-service'] || deps['vue-cli-plugin-webpack'])) framework = 'vue-cli';
    else if (deps.vue) framework = 'vue';
    else if (deps.react && deps.vite) framework = 'react-vite';
    else if (deps.react) framework = 'react';
    else if (deps.svelte) framework = 'svelte';

    let devPort = null;
    const devScripts = [pkg?.scripts?.dev, pkg?.scripts?.start, pkg?.scripts?.serve].filter(Boolean);
    for (const script of devScripts) {
        const match = script.match(/--port[= ](\d{2,5})/) || script.match(/-p\s+(\d{2,5})/);
        if (match) {
            devPort = parseInt(match[1], 10);
            break;
        }
    }

    if (!devPort) {
        const cfgCandidates = [
            'vite.config.ts', 'vite.config.js', 'vite.config.mjs',
            'next.config.js', 'next.config.mjs', 'next.config.ts',
            'nuxt.config.ts', 'nuxt.config.js',
            'vue.config.js', 'webpack.config.js',
        ];
        for (const file of cfgCandidates) {
            const fp = path.join(rootPath, file);
            if (!fs.existsSync(fp)) continue;
            const txt = safeRead(fp);
            const match = txt.match(/port\s*:\s*(\d{2,5})/);
            if (match) {
                devPort = parseInt(match[1], 10);
                break;
            }
        }
    }

    if (!devPort) {
        if (framework === 'next' || framework === 'nuxt') devPort = 3000;
        else if (framework === 'vue3-vite' || framework === 'react-vite') devPort = 5173;
        else if (framework === 'vue-cli' || framework === 'react') devPort = 8080;
    }
    return { framework, devPort };
}

// FE 라우터 추출
const ROUTE_FILE_PATTERNS = [
    /router\/index\.(js|ts)$/i,
    /router\/routes\.(js|ts)$/i,
    /routes\/index\.(js|ts|tsx)$/i,
    /src\/router\.[jt]s$/i,
    /src\/routes\.[jt]s$/i,
    /router\/modules\/.+\.(js|ts)$/i,
    /App\.(jsx|tsx)$/i,
];

function extractRoutesFromText(txt) {
    const out = [];
    const pathRegex = /path\s*:\s*['"`]([^'"`]+)['"`][\s\S]{0,200}?(?:component|element|name)\s*:\s*[^,\n]+/g;
    let match;
    while ((match = pathRegex.exec(txt)) !== null) {
        const routePath = match[1];
        if (!routePath || routePath === '/' || routePath === '*' || routePath === '/:catchAll(.*)') continue;
        const segs = routePath.split('/').filter(Boolean);
        const last = segs[segs.length - 1];
        if (!last || last.startsWith(':')) continue;
        const code = last.replace(/[^a-zA-Z0-9_-]/g, '').toLowerCase();
        if (!code) continue;
        out.push({ code, path: routePath });
    }
    return out;
}

function extractRoutesFromFiles(rootPath) {
    const found = new Map();
    const candidates = findFiles(rootPath, (full) =>
        ROUTE_FILE_PATTERNS.some((re) => re.test(full.replace(/\\/g, '/'))),
        { maxDepth: 6 }
    );

    for (const file of candidates) {
        const txt = safeRead(file);
        for (const route of extractRoutesFromText(txt)) {
            if (!found.has(route.code)) found.set(route.code, route);
        }
    }

    if (found.size === 0) {
        const viewDirs = ['src/views', 'src/pages', 'pages', 'app'];
        for (const vd of viewDirs) {
            const dir = path.join(rootPath, vd);
            if (!fs.existsSync(dir)) continue;
            const views = findFiles(dir, (_full, name) => /\.(vue|tsx|jsx|svelte)$/.test(name), { maxDepth: 8 });
            for (const view of views) {
                const base = path.basename(view).replace(/\.(vue|tsx|jsx|svelte)$/, '');
                if (['index', '_app', '_layout', 'default'].includes(base)) continue;
                const code = base.toLowerCase().replace(/[^a-zA-Z0-9_-]/g, '');
                if (!code || found.has(code)) continue;
                const rel = view.replace(/\\/g, '/').slice(rootPath.replace(/\\/g, '/').length);
                found.set(code, { code, path: rel.replace(/\.(vue|tsx|jsx|svelte)$/, '') });
            }
        }
    }
    return Array.from(found.values());
}

// 메뉴명 매핑
function buildMenuNameMap(rootPath) {
    const map = {};

    // a) common-system-ai 의 spec/{메뉴코드}/{메뉴코드}-02-ui.md
    const distDir = path.join(REPO_ROOT, 'spec');
    if (fs.existsSync(distDir)) {
        try {
            for (const ent of fs.readdirSync(distDir, { withFileTypes: true })) {
                if (!ent.isDirectory()) continue;
                const uiMd = path.join(distDir, ent.name, `${ent.name}-02-ui.md`);
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
    const indexCandidates = findFiles(
        rootPath,
        (_full, name) => /^menu[-_]?index\.md$/i.test(name) || /^menus?\.json$/i.test(name) || /^menu[-_]list\.json$/i.test(name),
        { maxDepth: 6 }
    );
    for (const file of indexCandidates) {
        const txt = safeRead(file);
        if (file.endsWith('.json')) {
            try {
                const json = JSON.parse(txt);
                const list = Array.isArray(json) ? json : (json.menus || json.items || []);
                for (const item of list) {
                    const code = (item.code || item.id || item.menuCode || '').toLowerCase();
                    const name = item.name || item.menuName || item.title;
                    if (code && name) map[code] = name;
                }
            } catch (_) {}
        } else {
            const re = /\|\s*([a-z][a-z0-9_]*)\s*\|\s*([^|\n]+?)\s*\|/g;
            let match;
            while ((match = re.exec(txt)) !== null) {
                const code = match[1].toLowerCase();
                const name = match[2].trim();
                if (code && name && !/^[-=]+$/.test(name)) map[code] = name;
            }
        }
    }

    return map;
}

// BE Controller 스캔
const ADMIN_URL_PATTERNS_BE = [
    /^\/?sm\//i,
    /^\/?admin\//i,
    /^\/?mgmt\//i,
    /^\/?manage\//i,
    /^\/?system\//i,
    /^\/?config\//i,
    /^\/?setting(s)?\//i,
    /^\/?md(m)?\//i,
    /^\/?auth\//i,
    /^\/?permission(s)?\//i,
    /^\/?role(s)?\//i,
];

const ADMIN_PKG_KEYWORDS = ['sm', 'admin', 'mdm', 'master', 'system', 'config', 'auth', 'permission', 'role'];

function extractBackendAdminUrls(rootPath) {
    if (!rootPath) return [];
    const files = findFiles(rootPath, (_full, name) => /\.(java|kt)$/.test(name), { maxDepth: 12 });
    const adminUrls = [];

    for (const file of files) {
        const txt = safeRead(file);
        const isController =
            /@RestController\b/.test(txt) ||
            /@Controller\b/.test(txt) ||
            /class\s+\w+Controller\b/.test(txt);
        if (!isController) continue;

        let pkg = '';
        const pkgMatch = txt.match(/^\s*package\s+([\w\.]+);?/m);
        if (pkgMatch) pkg = pkgMatch[1];
        const pkgLower = pkg.toLowerCase();
        const pkgIsAdmin = ADMIN_PKG_KEYWORDS.some((keyword) =>
            pkgLower.includes(`.${keyword}.`) || pkgLower.endsWith(`.${keyword}`) || pkgLower.includes(`.${keyword}`)
        );

        let classUrl = '';
        const classUrlMatch = txt.match(/@RequestMapping\s*\(\s*(?:value\s*=\s*)?["']([^"']+)["']/);
        if (classUrlMatch) classUrl = classUrlMatch[1];

        const classNameMatch = txt.match(/class\s+(\w+Controller)\b/);
        const className = classNameMatch ? classNameMatch[1] : '';

        const methodRegex = /@(?:Request|Get|Post|Put|Delete|Patch)Mapping\s*\(\s*(?:value\s*=\s*)?["']([^"']+)["']/g;
        let methodMatch;
        const methodUrls = [];
        while ((methodMatch = methodRegex.exec(txt)) !== null) {
            methodUrls.push(methodMatch[1]);
        }
        if (methodUrls.length === 0 && classUrl) methodUrls.push('');

        for (const methodUrl of methodUrls) {
            const fullUrl = (classUrl + '/' + (methodUrl || '')).replace(/\/+/g, '/').replace(/\/$/, '') || '/';
            if (ADMIN_URL_PATTERNS_BE.some((re) => re.test(fullUrl)) || pkgIsAdmin) {
                adminUrls.push({
                    file: file.replace(/\\/g, '/').slice(rootPath.replace(/\\/g, '/').length),
                    pkg,
                    className,
                    classUrl,
                    methodUrl,
                    fullUrl,
                });
            }
        }
    }
    return adminUrls;
}

function backendUrlsToMenus(beUrls) {
    const map = new Map();
    for (const item of beUrls) {
        const segs = item.fullUrl.split('/').filter(Boolean);
        if (segs.length === 0) continue;

        let code = '';
        for (let i = segs.length - 1; i >= 0; i -= 1) {
            const seg = segs[i].toLowerCase().replace(/[^a-z0-9_]/g, '');
            if (/^[a-z]{2,}\d{1,3}$/.test(seg)) {
                code = seg;
                break;
            }
            if (/^[a-z]{2,5}$/.test(seg) && i === segs.length - 1) {
                code = seg;
                break;
            }
        }
        if (!code) continue;

        const pathPrefix = `/${segs.slice(0, Math.max(1, segs.length - 1)).join('/')}`;
        if (!map.has(code)) {
            map.set(code, {
                code,
                path: `${pathPrefix}/${code}`,
                source: ['be-controller'],
                beHints: [item.className],
            });
        } else {
            const existing = map.get(code);
            if (!existing.beHints.includes(item.className)) existing.beHints.push(item.className);
        }
    }
    return Array.from(map.values());
}

function viewportHint(code, routePath) {
    if (PDA_PATH.test(routePath || '')) return 'pda';
    if (/m$/i.test(code) && /^br/i.test(code)) return 'pda';
    return 'desktop';
}

// 메인 실행
const { framework, devPort } = detectFramework(fePath);
const feRoutes = extractRoutesFromFiles(fePath);
const nameMap = buildMenuNameMap(fePath);
const beUrls = bePath ? extractBackendAdminUrls(bePath) : [];
const beMenus = backendUrlsToMenus(beUrls);

const adminMap = new Map();
const rejected = [];

// 1) FE 라우터 중 관리자 메뉴 필터
for (const route of feRoutes) {
    if (!/^[a-z][a-z0-9_]{1,}$/.test(route.code)) continue;
    const name = nameMap[route.code] || '';
    const isAdmin = isAdminByPath(route.path) || isAdminByCode(route.code) || isAdminByName(name);
    if (!isAdmin) {
        rejected.push({
            code: route.code,
            name: name || route.code.toUpperCase(),
            path: route.path,
            reason: rejectReason({ code: route.code, name, path: route.path }),
        });
        continue;
    }
    adminMap.set(route.code, {
        code: route.code,
        name: name || route.code.toUpperCase(),
        path: route.path,
        category: categorize({ code: route.code, path: route.path }),
        source: ['fe-route'],
        viewportHint: viewportHint(route.code, route.path),
    });
}

// 2) BE 보강 - FE 에 없는 관리자 메뉴 후보 추가
for (const menu of beMenus) {
    const name = nameMap[menu.code] || menu.code.toUpperCase();
    if (adminMap.has(menu.code)) {
        const existing = adminMap.get(menu.code);
        if (!existing.source.includes('be-controller')) existing.source.push('be-controller');
        existing.beHints = menu.beHints;
        continue;
    }
    if (!isAdminByPath(menu.path) && !isAdminByCode(menu.code) && !isAdminByName(name)) {
        continue;
    }
    adminMap.set(menu.code, {
        code: menu.code,
        name,
        path: menu.path,
        category: categorize({ code: menu.code, path: menu.path }),
        source: menu.source,
        beHints: menu.beHints,
        viewportHint: viewportHint(menu.code, menu.path),
    });
}

// 3) 이름 보강
for (const menu of adminMap.values()) {
    if (nameMap[menu.code] && (!menu.name || menu.name === menu.code.toUpperCase())) {
        menu.name = nameMap[menu.code];
    }
}

const adminMenus = Array.from(adminMap.values()).sort((a, b) => {
    const categoryA = a.category || '';
    const categoryB = b.category || '';
    if (categoryA !== categoryB) return categoryA.localeCompare(categoryB);
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
console.log(`     FE 라우터 ${feRoutes.length}개 발견, 관리자 메뉴 ${adminMenus.length}개 (제외 ${rejected.length}개)`);
if (bePath) {
    console.log(`     BE Controller 관리자 URL ${beUrls.length}개 매칭`);
}
if (adminMenus.length === 0) {
    console.log('[WARN] 관리자 메뉴 후보를 추출하지 못했습니다. 다음 단계에서 사용자에게 메뉴 목록을 직접 입력받으세요.');
}
