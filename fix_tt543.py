
target = r'C:\zinide\workspace\cloud-wms-doc\.claude\skills\TT_543\scripts\01_scan_admin_menus.js'

with open(target, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# (줄번호 0-based): 새 내용
fixes = {
    128: '// (C) 메뉴명 키워드\nconst ADMIN_NAME_KEYWORDS = [\n',
    129: "    '관리자', '사용자관리', '사용자 관리', '권한', '메뉴관리', '메뉴 관리',\n",
    130: "    '공통코드', '공통 코드', '시스템알림설정', '시스템사용자',\n",
    131: "    '시스템설정', '시스템환경', '사업장', '센터', '창고', '로그인이력',\n",
    132: "    '그룹 관리', '그룹관리', '관리', '설정',\n",
    133: '];\n',
    135: '// (E) 제외 기준 → 현장운영 메뉴\n',
    137: '    /^iw\\d/i,    // 입고\n',
    138: '    /^ob\\d/i,    // 출고\n',
    139: '    /^iv\\d/i,    // 재고\n',
    140: '    /^rt\\d/i,    // 반품\n',
    141: '    /^pk\\d/i,    // 피킹\n',
    142: '    /^dl\\d/i,    // 배송\n',
    147: "    '입고', '출고', '재고', '반품', '피킹', '배송', '현장',\n",
    164: '        // "재고관리" 류의 키워드가 있어도 현장 메뉴로 분류\n',
    165: '        // 단 "사용자관리", "메뉴관리", "권한관리" 등 강한 관리자 키워드가 있으면 관리자로 분류\n',
    166: "        const ADMIN_STRONG = ['사용자관리', '메뉴관리', '권한', '공통코드',\n",
    167: "            '사용자 관리', '메뉴 관리', '시스템알림설정', '시스템사용자',\n",
    168: "            '시스템설정', '시스템환경', '관리자'];\n",
    175: "    if (menu.path && PDA_PATH.test(menu.path)) return 'PDA 메뉴';\n",
    177: "        return '현장운영메뉴(입고/출고/재고/반품/피킹/배송)';\n",
    180: "        return `현장운영메뉴(${NON_ADMIN_NAME_KEYWORDS.find(k => menu.name.includes(k))})`;\n",
    182: "    return '관리자 메뉴 기준 미해당';\n",
    188: "    if (/^mdm/i.test(c) || /(\\/|^)md(\\/|$)/i.test(p)) return '마스터';\n",
    189: "    if (/(\\/|^)auth(\\/|$)/i.test(p) || /^auth|^role|^perm/i.test(c)) return '권한관리';\n",
    190: "    if (/(\\/|^)sm(\\/|$)/i.test(p) || /^sm/i.test(c)) return '시스템관리';\n",
    191: "    if (/(\\/|^)admin(\\/|$)/i.test(p) || /^adm/i.test(c)) return '관리자';\n",
    192: "    if (/(\\/|^)system(\\/|$)/i.test(p) || /^sys/i.test(c)) return '시스템';\n",
    193: "    return '관리';\n",
}

for lineno, newline in fixes.items():
    if lineno < len(lines):
        lines[lineno] = newline

with open(target, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print(f'Done: {len(fixes)} lines fixed')
