---
title: 폴더 구조 재설계 이전 계획서 (AS-IS → TO-BE)
description: STRUCTURE-TARGET.md 목표 구조로의 단계별 이전 실행 계획. Phase별 이동 대상·참조 치환 규칙·검증·커밋·롤백을 고정한다. 실제 마이그레이션 작업의 체크리스트.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: plan
domain: common
depends_on:
  - STRUCTURE-TARGET.md
last_verified: 2026-06-17
---

# 폴더 구조 재설계 이전 계획서

> ✅ **Phase A~F + 모바일 평탄화 완료 (2026-06-17, 브랜치 `restructure/folder-target`).** 후속 작업으로 남은 것: KB_100/KB_200 출력 대상 `spec/` 재설계.

`STRUCTURE-TARGET.md`의 목표 구조로 현행 레포를 이전한다. 단순 치환이 아니라 **3개는 기계 치환 / 3개는 수작업 분할**이므로 단계를 나눈다.

## 측정된 churn (2026-06-17 기준)

| 옛 경로 | 전체 참조 | 스킬 내 | 유형 |
|---|---|---|---|
| `10-src-pattern` | 38 | 0 | 기계 치환 |
| `20-deliverables` | 9 | 13 | 기계 치환 |
| `60-system` | 3 | 0 | 기계 치환(깊이변경) |
| `30-domain` | 33 | 14 | 수작업 분할 |
| `50-prototype` | 15 | 9 | 수작업 재구성 |
| `70-knowledgebase` | 24 | 2 | 수작업 분할 |

실제 메뉴: `30-domain` = mdbz01·mdpr01 / `70-kb` = mdbz01·mdwh01.

---

## 원칙 (BLOCKING)

1. **브랜치에서 작업**: `restructure/folder-target`. main 직접 금지.
2. **Phase 단위 원자성**: 각 Phase는 `이동 → 참조수정 → 검증 → 커밋`을 한 묶음으로. Phase 간 의존 없음(독립 롤백 가능).
3. **검증 게이트**: 각 Phase 종료 시 `grep -r "옛경로"` 결과가 **0건**이어야 다음으로 넘어간다(STRUCTURE/CLAUDE/AGENTS 문서 내 의도적 언급 제외).
4. **이동은 `git mv`** 로 히스토리 보존.
5. **삭제 전 확인**: `70-knowledgebase/{메뉴}` 폐기는 내용이 어디에도 참조되지 않음을 확인 후 진행.

---

## Phase 0 — 준비

```
git checkout -b restructure/folder-target
```
- 기준 커밋 기록, 작업 트리 clean 확인.

---

## Phase A — 기계 치환 (저위험)

**대상**
- `10-src-pattern/` → `patterns/`
- `20-deliverables/` → `deliverables/`

**절차**
1. `git mv 10-src-pattern patterns` / `git mv 20-deliverables deliverables`
2. 참조 치환: 전 파일에서 `10-src-pattern` → `patterns`, `20-deliverables` → `deliverables`
3. 검증: `grep -r "10-src-pattern\|20-deliverables"` → 0건
4. 커밋: `restructure(A): 10-src-pattern→patterns, 20-deliverables→deliverables`

---

## Phase B — install-guide (저위험, 깊이 변경)

**대상**: `60-system/` → `knowledgebase/40-install-guide/`

**절차**
1. `mkdir -p knowledgebase` → `git mv 60-system knowledgebase/40-install-guide`
2. 참조 치환: `60-system` → `knowledgebase/40-install-guide`
3. 검증 0건 → 커밋: `restructure(B): 60-system→knowledgebase/40-install-guide`

---

## Phase C — 70-knowledgebase 분할/폐기

**대상**
- `70-knowledgebase/_common/*` (기술 아키텍처) → `patterns/`
- `70-knowledgebase/{mdbz01,mdwh01}/` (역공학 요약) → **폐기**
- `70-knowledgebase/{menu-list.md, overview.html, *.zip, 생성프롬프트.md}` → 개별 판단(보존 시 `knowledgebase/`, 아니면 폐기)

**절차**
1. `_common` 4파일 → `patterns/`로 `git mv` (이름 충돌 시 `patterns/_common-arch/` 하위)
2. 메뉴 폴더 참조 여부 확인 후 `git rm -r 70-knowledgebase/mdbz01 70-knowledgebase/mdwh01`
3. 잔여 파일 처리 결정 → 이동/삭제
4. 참조 치환: `70-knowledgebase/_common` → `patterns`, 메뉴 참조는 제거 또는 `30-src-index` 안내로 교체
5. 검증 0건 → 커밋: `restructure(C): 70-knowledgebase 분할(_common→patterns)·역공학 요약 폐기`

---

## Phase D — prototype 재구성

**대상**
- `50-prototype/10-common/` → `prototype/_common/`
- `50-prototype/20-mobile/`(공통 셸) → `prototype/_common-m/`
- 메뉴별 PC wireframe(현재 30-domain 내) → `prototype/{메뉴}/`
- 메뉴별 모바일(`50-prototype/20-mobile/{그룹}m/{메뉴}.html`) → `prototype/{메뉴}m/`

**절차**
1. `prototype/_common`, `prototype/_common-m` 구성
2. mdpr01 PC: `30-domain/.../mdpr01-02-wireframe.html`·`mock-data.js` → `prototype/mdpr01/`
3. mdpr01 모바일: `50-prototype/20-mobile/md8000m/MDPR01.html` → `prototype/mdpr01m/mdpr01m-wireframe.html`
4. `index.html`의 iframe 로드 경로(`loadContent`) 갱신
5. 참조 치환: `50-prototype/10-common`→`prototype/_common` 등
6. 검증 0건 → 커밋: `restructure(D): 50-prototype→prototype(_common/_common-m/m접미사)`

---

## Phase E — 30-domain → spec (최대 작업)

**대상(메뉴별 분할)**
- `30-domain/30-wms-business/{메뉴}/{메뉴}-01~07.md` → `spec/{메뉴}/`
- `{메뉴}-99-issues.md` → `spec/{메뉴}/`
- `{메뉴}-00-domain.md` → **신규 생성**(빈 템플릿, 사람이 채움)
- wireframe·mock-data는 Phase D에서 이미 이동
- `30-domain/30-wms-business/{메뉴}/{메뉴}-02-ui.md`는 spec 유지(요건), 02-wireframe만 prototype

**절차**
1. `git mv 30-domain/30-wms-business/{메뉴} spec/{메뉴}` 후 잔여 정리
2. 각 메뉴에 `{메뉴}-00-domain.md` 빈 템플릿 추가
3. `30-domain`에 남는 메뉴 횡단 공통 지식 → `knowledgebase/10-domain/`
4. 참조 치환: `30-domain/30-wms-business/{메뉴}` → `spec/{메뉴}`
5. 검증 0건 → 커밋: `restructure(E): 30-domain→spec(00-domain 신규)·횡단지식→knowledgebase/10-domain`

---

## Phase F — knowledgebase 골격 + 문서/규칙 갱신

1. `knowledgebase/00-overview.md`(루트 00-overview 이동), `20-md-index.md`, `30-src-index/`, `50-dev-workflow/`(ai-dev-procedure 이동) 생성/배치
2. `CLAUDE.md`·`.claude/rules/repo-paths.md` 경로 규약 갱신
3. 자동화 스킬에 **"`{메뉴}-00-domain.md` 생성/수정 금지"** 규칙 추가
4. `STRUCTURE.md`를 `STRUCTURE-TARGET.md` 내용으로 대체(또는 TARGET을 STRUCTURE로 승격), `MIGRATION-PLAN.md`·`STRUCTURE-TARGET.md`는 완료 표시
5. 전체 검증: 옛 경로 6종 전부 0건
6. 커밋 → `restructure(F): 문서·규칙·스킬 경로 갱신, STRUCTURE 승격`

---

## 완료 기준

- 옛 경로 6종(`10-src-pattern·20-deliverables·30-domain·50-prototype·60-system·70-knowledgebase`) 참조 0건
- 27개 개발 스킬 + 15개 산출물 스킬이 새 경로로 동작
- `restructure/folder-target` → main PR 리뷰 후 머지

## 리스크 / 주의

- 스킬 경로 누락 시 자동화 침묵 실패 → Phase별 grep 0건 게이트로 차단.
- 윈도우 CRLF/대소문자(MDPR01 vs mdpr01) 주의 — 파일명 소문자 통일.
- `index.html` iframe 경로는 정적 문자열이라 grep에 안 걸릴 수 있음 → Phase D에서 수동 확인.
