/**
 * Playwright 인증 상태 초기화 스크립트
 * e2e/.auth-state.json 이 없거나 만료된 경우 수동 실행:
 *   node .claude/skills/e2e-menu-test/scripts/gen-auth-setup.js
 */
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const USER_ID   = process.env.TEST_USER_ID   || 'zintest';
const PASSWORD  = process.env.TEST_PASSWORD  || '1111';
const BASE_URL  = process.env.BASE_URL       || 'http://localhost:5173';
const OUT_PATH  = path.resolve('e2e/.auth-state.json');

(async () => {
    const browser = await chromium.launch();
    const ctx = await browser.newContext();
    const page = await ctx.newPage();

    console.log(`[auth] ${BASE_URL}/login 으로 이동 중...`);
    await page.goto(`${BASE_URL}/login`);

    await page.locator('input[type="text"]').first().fill(USER_ID);
    await page.locator('input[type="password"]').fill(PASSWORD);
    await page.locator('button[type="submit"], .login-btn').click();

    await page.waitForURL('**/be/**', { timeout: 15_000 })
        .catch(() => { throw new Error('[auth] 로그인 실패. 계정/서버 확인 필요.'); });

    await ctx.storageState({ path: OUT_PATH });
    console.log(`[auth] 저장 완료: ${OUT_PATH}`);

    await browser.close();
})();
