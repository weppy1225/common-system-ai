---
name: skill_list
description: 이 레포의 커스텀 슬래시 스킬 현황을 그룹(개발/산출물/유틸)별 표로 화면에 출력한다. /skill_list
when_to_use: "스킬 목록", "스킬 현황", "어떤 명령 있어", "skill_list 실행" 요청 시 사용.
allowed-tools: Bash
---

# 스킬 현황표 [skill_list]

`.claude/skills/` 의 모든 커스텀 스킬을 스캔해 **그룹별 현황표**로 출력한다.

## 1단계 — 스캔 (Bash)

아래를 실행해 `그룹순번·그룹명 | /명령어 | 설명` 형태로 추출한다.

```bash
cd "$(git rev-parse --show-toplevel)"
for d in .claude/skills/*/; do
  name=$(basename "$d")
  [ -f "$d/SKILL.md" ] || continue
  desc=$(grep -m1 '^description:' "$d/SKILL.md" | sed 's/^description:[[:space:]]*//' | sed 's/【[^】]*】//')
  case "$name" in
    SD_310_UI|SD_db|SD_api|SD_db_apply|PI_be_*|PI_fe_*|PI_test_*) grp="1·개발 자동화";;
    RA_222|SD_311|SD_312|SD_33*|PI_411|PI_412|PI_421|PI_422|TT_54*|TT_550|TT_551) grp="2·산출물 자동화";;
    *) grp="3·유틸";;
  esac
  echo "$grp|/$name|$desc"
done | sort -t'|' -k1,1
```

## 2단계 — 화면 출력 (3컬럼 + 짧은 설명, 한 화면)

추출 결과를 **3컬럼 표 1개**로 출력한다. 한 화면에 들어가도록 각 칸은 `` `/명령` 짧은설명 `` 형태로, 설명은 **핵심 명사구(약 6~12자)** 로 압축한다.

- 컬럼: `🛠️ 개발 자동화 (N)` · `📦 산출물 자동화 (N)` · `🔧 유틸 (N)`
- 각 컬럼에 소속 명령어를 위에서부터 나열, 행은 가장 많은 그룹 수만큼 (빈 칸은 공백)
- 짧은 설명 예: `/SD_311` PC 프로토타입, `/SD_db` DB 설계, `/PI_be_mapper` BE Mapper, `/RA_222` 요구사항정의서, `/TT_541` PC매뉴얼 PPTX
- 표 아래 **총 스킬 수**(그룹별 개수) 1줄.

> 긴 설명은 frontmatter `description`에 있으니, 사용자가 특정 명령을 물으면 그때 전체 설명을 보여준다.

> 분류 기준: 개발 자동화 = 설계·코드·테스트 생성(SD·PI·KB) / 산출물 자동화 = 고객 제출 문서 생성(RA·SD·PI·TT) / 유틸 = 배포·레드마인·메타.
