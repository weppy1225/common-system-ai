#!/usr/bin/env node
/**
 * [TT_541] 3단계 — Playwright 헤드리스 화면 캡처
 *
 * 사용법:
 *   node 02_capture_screens.js
 *
 * 입력:  output/05 이행(TT)/tmp/capture_config.json
 * 출력:
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/01-main.png
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/02-search-result.png
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/03-register-popup.png  (선택)
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/04-row-selected.png    (선택)
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/05-edit-popup.png      (선택)
 *   output/05 이행(TT)/tmp/screens/{메뉴코드}/coords.json
 *
 * 표준 시나리오:
 *   메뉴 진입 → 메인 캡처 → 검색 → 등록 팝업 → 행 선택 → 수정 팝업
 *   (실제 데이터 변경 절대 금지: 팝업은 열기만, 취소/ESC로 닫음)
 */
'use strict';

// node_modules 위치 명시 (스크립트 디렉토리 내부)
module.paths.push(require('path').join(__dirname, 'node_modules'));

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const REPO_ROOT = '/mnt/c/zinide/workspace/cloud-wms-doc';
const TMP_DIR = path.join(REPO_ROOT, 'output', '05 이행(TT)', 'tmp');
const CFG_FILE = path.join(TMP_DIR, 'capture_config.json');
const SCREENS_ROOT = path.join(TMP_DIR, 'screens');

if (!fs.existsSync(CFG_FILE)) {
    console.error(`[ERR] config 파일이 없습니다: ${CFG_FILE}`);
    console.error('      먼저 01_scan_project.js 를 실행하고, 사용자 입력 결과로 capture_config.json 을 작성하세요.');
    process.exit(1);
}

const cfg = JSON.parse(fs.readFileSync(CFG_FILE, 'utf8'));
const BASE_URL = cfg.baseUrl;
const VIEWPORT = cfg.viewport || { width: 1440, height: 900 };
const HIDE_SIDEBAR = cfg.viewport?.hideSidebar !== false; // 기본 true

if (!BASE_URL) {
    console.error('[ERR] capture_config.json 에 baseUrl 이 없습니다.');
    process.exit(1);
}
if (!Array.isArray(cfg.menus) || cfg.menus.length === 0) {
    console.error('[ERR] capture_config.json 의 menus[] 가 비어있습니다.');
    process.exit(1);
}

fs.mkdirSync(SCREENS_ROOT, { recursive: true });

// ── 유틸 ────────────────────────────────────────────────────────
function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function tryFirstVisible(page, selectors, timeout = 1500) {
    for (const sel of selectors) {
        try {
            const loc = page.locator(sel).first();
            if (await loc.isVisible({ timeout }).catch(() => false)) return loc;
        } catch (_) {}
    }
    return null;
}

async function getBBox(page, selectors, timeout = 2500) {
    if (typeof selectors === 'string') selectors = [selectors];
    for (const sel of selectors) {
        try {
            const loc = page.locator(sel).first();
            if (await loc.isVisible({ timeout }).catch(() => false)) {
                const bb = await loc.boundingBox();
                if (bb) return bb;
            }
        } catch (_) {}
    }
    return null;
}

async function shot(page, dir, name) {
    fs.mkdirSync(dir, { recursive: true });
    const p = path.join(dir, `${name}.png`);
    await page.screenshot({ path: p, fullPage: false });
    console.log(`  [SHOT] ${name}.png`);
    return p;
}

async function hideSidebar(page) {
    if (!HIDE_SIDEBAR) return;
    await page.evaluate(() => {
        const sels = ['aside.menu-container', '.left-menu', 'nav.sidebar', '.sidebar', '.gnb', '.lnb'];
        for (const s of sels) {
            document.querySelectorAll(s).forEach(el => el.style.setProperty('display', 'none', 'important'));
        }
        const mains = ['section.app-main', 'main.main-content', '.content-wrap', 'main', '.app-main'];
        for (const s of mains) {
            document.querySelectorAll(s).forEach(el => {
                el.style.setProperty('margin-left', '0', 'important');
                el.style.setProperty('width', '100vw', 'important');
            });
        }
    });
    await page.addStyleTag({
        content: `
            .header-container, header { margin-left: 0 !important; }
            #layer-popup-container > .layer-container { left: 0 !important; width: 100vw !important; }
        `,
    }).catch(() => {});
    await sleep(250);
}

// ── 로그인 ──────────────────────────────────────────────────────
async function login(page, login) {
    if (!login || !login.needed) return;
    const loginUrl = login.url ? (login.url.startsWith('http') ? login.url : BASE_URL + login.url) : BASE_URL;
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForSelector('input[type="password"]', { timeout: 15000 }).catch(() => {});
    await sleep(800);

    // 보이는 input 만 사용 (popup 의 hidden input 회피)
    if (login.originField) {
        const visibleTexts = page.locator('input[type="text"]:visible, input:not([type]):visible');
        const cnt = await visibleTexts.count().catch(() => 0);
        if (cnt >= 2) {
            await visibleTexts.nth(0).fill(login.originField).catch(() => {});
            await visibleTexts.nth(1).fill(login.id || '').catch(() => {});
        } else if (cnt === 1) {
            await visibleTexts.nth(0).fill(login.id || '').catch(() => {});
        }
    } else {
        const idCandidates = ['input[name="userId"]', 'input[name="id"]', 'input[name="username"]', 'input[type="text"]:visible', 'input:not([type]):visible'];
        for (const sel of idCandidates) {
            const loc = page.locator(sel).first();
            if (await loc.isVisible({ timeout: 800 }).catch(() => false)) {
                await loc.fill(login.id || '').catch(() => {});
                break;
            }
        }
    }
    const pwInput = page.locator('input[type="password"]:visible').first();
    await pwInput.fill(login.pw || '').catch(() => {});

    // 로그인 버튼 클릭 (login_btn 클래스 우선 + 가시성 보장)
    const submitCandidates = [
        'button.login_btn:visible',
        'button.btn-login:visible',
        'button[type="submit"]:visible',
        'button:has-text("로그인"):visible',
    ];
    let clicked = false;
    for (const sel of submitCandidates) {
        const loc = page.locator(sel).first();
        if (await loc.isVisible({ timeout: 800 }).catch(() => false)) {
            await loc.click({ timeout: 5000 }).catch(() => {});
            clicked = true;
            break;
        }
    }
    if (!clicked) {
        // 마지막 폴백: enter 키로 submit
        await pwInput.press('Enter').catch(() => {});
    }

    // 로그인 성공 시 /login 에서 다른 URL 로 이동 — URL 변경 대기
    await page.waitForFunction(
        () => !location.pathname.startsWith('/login'),
        null,
        { timeout: 15000 }
    ).catch(() => {});
    await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});
    await sleep(1500);
    console.log(`  [LOGIN] post-login URL = ${page.url()}`);
}

// ── 셀렉터 풀 ───────────────────────────────────────────────────
const SEL = {
    search: [
        'button.zin-button:has-text("검색")',
        'button.btn-search:has-text("검색")',
        'button:has-text("검색"):visible',
        '[role="button"]:has-text("검색")',
    ],
    register: [
        '.addImg[title="등록"]',
        '.ZBtnRowAddImg',
        'button.btn-icon[title="추가"]',
        'button.btn-icon[title="등록"]',
        'button:has-text("추가"):visible',
        'button:has-text("등록"):visible',
    ],
    modify: [
        '.modifyImg[title="수정"]',
        'button.btn-icon[title="수정"]',
        'button:has-text("수정"):visible',
    ],
    firstRow: [
        'tr.aui-grid-row-background td.aui-grid-default-column',
        'tr.aui-grid-row-background td',
        '[class*="aui-grid-body"] tr:first-child td',
        '.grid-wrap tbody tr:not(.empty):first-child td',
        'table.grid tbody tr:nth-child(1) td',
    ],
    popup: [
        '.layer-container:visible .layer-wrapper:visible',
        '.layer-wrapper:visible',
        '.modal[role="dialog"]:visible',
        '.modal-bg:visible .modal',
        '.modal:not(.modal-bg):visible',
    ],
    popupCancel: [
        '.layer-wrapper button:has-text("취소")',
        '.modal button:has-text("취소")',
        '.modal button.close-btn',
        '.modal button:has-text("닫기")',
        '.modal button:has-text("닫 기")',
    ],
    searchArea: [
        '.title-wrapper',
        '.search-area',
        '.search-section',
        '[class*="search-section"]',
        '.search-form',
    ],
    grid: [
        '.content-warpper',
        '.content-wrapper',
        '.grid-wrap',
        '.prm-header-section',
        '[class*="prm-header-section"]',
        '[class*="aui-grid"]',
        'table.grid',
    ],
};

// ── 팝업 좌표 픽셀 분석 (v-show / display:none 토글 fallback) ──
const POPUP_HEADER_RGB = [48, 74, 110]; // #304a6e (cloud-wms-doc 프라이머리)
const ALT_HEADER_RGB = [75, 104, 145];   // #4b6891 (wms-bnk-fe 팝업 헤더)
const COLOR_TOL = 16;

function findPopupBboxByPixel(pngPath) {
    // PNG 헤더만 빠르게 파싱하여 width/height 확인 — 본격적인 PNG 디코딩은 과제 외이므로
    // 본 함수는 stub 으로 두고, DOM 측정 실패 시 호출 측에서 null 처리한다.
    // (실 사용 시 sharp 또는 pngjs 추가 필요)
    return null;
}

async function getPopupBBox(page) {
    // 보이는 layer-wrapper 중 가장 큰 것을 채택 (여러 팝업이 DOM 에 미리 마운트되어 있어 first() 만으로는 위험)
    const bb = await page.evaluate(() => {
        const selectors = [
            '.layer-wrapper',
            '.modal[role="dialog"]',
            '.modal-bg .modal',
        ];
        let best = null;
        for (const sel of selectors) {
            const els = document.querySelectorAll(sel);
            for (const el of els) {
                const r = el.getBoundingClientRect();
                if (r.width > 50 && r.height > 50) {
                    if (!best || (r.width * r.height) > (best.width * best.height)) {
                        best = { x: r.x, y: r.y, width: r.width, height: r.height };
                    }
                }
            }
        }
        return best;
    });
    return bb;
}

// ── 팝업 열기/닫기 ──────────────────────────────────────────────
async function openPopup(page, openSelectors) {
    const btn = await tryFirstVisible(page, openSelectors, 1500);
    if (!btn) return false;
    await btn.click({ timeout: 5000 }).catch(() => {});
    await sleep(1200);
    return true;
}

async function closePopup(page) {
    const cancel = await tryFirstVisible(page, SEL.popupCancel, 800);
    if (cancel) {
        await cancel.click({ timeout: 3000 }).catch(() => {});
    } else {
        await page.keyboard.press('Escape').catch(() => {});
    }
    await sleep(500);
}

// ── 메뉴 1개 캡처 ───────────────────────────────────────────────
async function captureMenu(page, menu) {
    const dir = path.join(SCREENS_ROOT, menu.code);
    fs.mkdirSync(dir, { recursive: true });
    const coords = { menuCode: menu.code, menuName: menu.name };

    const url = menu.path?.startsWith('http') ? menu.path : (BASE_URL + (menu.path || `/${menu.code}`));
    console.log(`\n[${menu.code}] ${menu.name}  →  ${url}`);

    try {
        await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 25000 });
    } catch (e) {
        console.log(`  [SKIP] 페이지 진입 실패: ${e.message}`);
        return { menu, captured: [], error: e.message };
    }
    // 메뉴 화면이 SPA 라우팅 + 비동기 컴포넌트 로드를 모두 마칠 때까지 대기
    await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});
    // 검색 영역 또는 그리드 영역이 한쪽이라도 보이면 렌더 완료로 본다
    await Promise.race([
        page.waitForSelector('.search-area, .search-section, [class*="search-section"], .search-form', { timeout: 12000 }).catch(() => {}),
        page.waitForSelector('.grid-wrap, table.grid, [class*="aui-grid"]', { timeout: 12000 }).catch(() => {}),
    ]);
    await sleep(1500);
    if (page.url().includes('/login')) {
        console.log(`  [WARN] 로그인 페이지로 리다이렉트됨: ${page.url()}`);
        return { menu, captured: [], error: 'redirected to login' };
    }
    await hideSidebar(page);
    await sleep(400);

    const captured = [];
    const scenarios = menu.scenarios || ['main', 'search', 'register', 'rowSelect', 'edit'];

    // 01: 메인
    if (scenarios.includes('main')) {
        coords.main = {
            search: await getBBox(page, SEL.searchArea),
            grid: await getBBox(page, SEL.grid),
        };
        await shot(page, dir, '01-main');
        captured.push('01-main.png');
    }

    // 02: 검색 실행
    if (scenarios.includes('search')) {
        const searchBtn = await tryFirstVisible(page, SEL.search, 1500);
        if (searchBtn) {
            await searchBtn.click({ timeout: 4000 }).catch(() => {});
            await sleep(2000);
            coords.search = {
                grid: await getBBox(page, SEL.grid),
            };
            await shot(page, dir, '02-search-result');
            captured.push('02-search-result.png');
        } else {
            console.log('  [SKIP] 검색 버튼을 찾지 못했습니다.');
        }
    }

    // 03: 등록 팝업
    if (scenarios.includes('register')) {
        const opened = await openPopup(page, SEL.register);
        if (opened) {
            coords.register = { popup: await getPopupBBox(page) };
            await shot(page, dir, '03-register-popup');
            captured.push('03-register-popup.png');
            await closePopup(page);
        } else {
            console.log('  [SKIP] 등록 버튼을 찾지 못했습니다.');
        }
    }

    // 04: 행 선택
    if (scenarios.includes('rowSelect')) {
        const row = await tryFirstVisible(page, SEL.firstRow, 1500);
        if (row) {
            await row.click({ timeout: 3000 }).catch(() => {});
            await sleep(1200);
            coords.rowSelect = {
                grid: await getBBox(page, SEL.grid),
            };
            await shot(page, dir, '04-row-selected');
            captured.push('04-row-selected.png');
        } else {
            console.log('  [SKIP] 결과 첫 행을 찾지 못했습니다.');
        }
    }

    // 05: 수정 팝업
    if (scenarios.includes('edit')) {
        const opened = await openPopup(page, SEL.modify);
        if (opened) {
            coords.edit = { popup: await getPopupBBox(page) };
            await shot(page, dir, '05-edit-popup');
            captured.push('05-edit-popup.png');
            await closePopup(page);
        } else {
            console.log('  [SKIP] 수정 버튼을 찾지 못했습니다.');
        }
    }

    fs.writeFileSync(path.join(dir, 'coords.json'), JSON.stringify(coords, null, 2));
    return { menu, captured, error: null };
}

// ── 메인 실행 ──────────────────────────────────────────────────
(async () => {
    const browser = await chromium.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-dev-shm-usage'],
    });
    const ctx = await browser.newContext({
        locale: 'ko-KR',
        viewport: { width: VIEWPORT.width, height: VIEWPORT.height },
    });
    const page = await ctx.newPage();

    try {
        await login(page, cfg.login);
    } catch (e) {
        console.warn(`[WARN] 로그인 단계에서 오류: ${e.message}`);
    }

    const summary = [];
    for (const menu of cfg.menus) {
        const r = await captureMenu(page, menu);
        summary.push({
            code: menu.code,
            name: menu.name,
            captured: r.captured,
            error: r.error,
        });
    }

    fs.writeFileSync(path.join(TMP_DIR, 'capture_summary.json'), JSON.stringify(summary, null, 2));
    await browser.close();

    console.log('\n[DONE] 캡처 요약');
    for (const s of summary) {
        const tag = s.error ? `[ERR ${s.error}]` : `[${s.captured.length}장]`;
        console.log(`  ${tag} ${s.code}  ${s.name}`);
    }
    console.log(`\n캡처 결과: ${SCREENS_ROOT}`);
})().catch(err => {
    console.error('[ERROR]', err);
    process.exit(1);
});
