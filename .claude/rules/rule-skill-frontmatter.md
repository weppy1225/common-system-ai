---
description: rules·skills 파일을 새로 만들거나 수정할 때 frontmatter 작성 규칙. Claude Code 공식 `paths` 필드로 동적 로딩하고, `paths` 가 없으면 항상 로딩된다.
paths:
  - ".claude/rules/**/*.md"
  - ".claude/skills/**/SKILL.md"
---

# Rule·Skill Frontmatter 작성 규칙

`.claude/rules/*.md` 와 `.claude/skills/*/SKILL.md` 를 새로 만들거나 의미 있게 수정할 때 적용한다.
목적은 **모든 rule/skill 이 컨텍스트에 한 번에 로딩되는 것을 막고**, frontmatter 로 로딩 시점·자동 호출 여부·인자 힌트를 제어하는 것이다.

> 일반 Markdown 문서 메타데이터(`title`·`status`·`agent_usage` 등) 규칙은 → `.claude/rules/md-frontmatter.md` 참조. 이 문서는 **Claude Code 공식 스펙**(rule = `paths`, skill = `description`/`paths`/호출제어/인자) 에만 집중한다.

---

## 1. 핵심 원칙 — 전체 로딩 금지

- rule/skill 은 기본적으로 **컨텍스트 절약을 위해 동적 로딩**한다. `paths` 를 생략한 항상로딩 rule 은 정말 모든 화면·모든 작업에 예외 없이 필요한 규칙에만 부여한다.
- 특정 파일 유형·특정 작업에서만 필요한 규칙은 `paths`(경로/글로브) 로 조건부 로딩한다.
- frontmatter 값은 추정하지 않는다. 실제 적용 대상 경로·파일을 확인한 뒤 적는다.

---

## 2. 로딩 모드 (Claude Code 공식 스펙)

| 모드 | 적용 방식 | 로딩 시점 |
|---|---|---|
| 항상로딩 | `paths` 필드를 **생략** | 세션 시작부터 항상 컨텍스트에 존재 (CLAUDE.md 와 동일 우선순위) |
| 동적로딩(path 기반) | `paths: [...]` 글로브 배열 지정 | Claude 가 `paths` 글로브에 매칭되는 파일을 **읽을 때만** 첨부 |

- **rule 의 동적 트리거는 path 기반이다.** `paths` 에 적은 글로브에 매칭되는 파일을 다룰 때 자동 첨부된다.
- **`paths` 필드를 생략하면 항상 로딩된다.** Cursor 의 `alwaysApply: true` 와 동일한 효과. 별도 `alwaysApply` 키는 사용하지 않는다.
- **필드명은 반드시 `paths` 다.** `globs`·`path`·`applies_to` 등 다른 이름은 Claude Code 가 인식하지 못한다.
- skill 도 `paths` 를 **선택적으로** 지원한다(§4-2). 지정하면 매칭 파일 작업 시에만 자동 호출 후보가 된다.

---

## 3. Rule frontmatter (`.claude/rules/*.md`)

```yaml
---
description: 이 규칙을 언제 적용하는지 한 문장 (로딩 판단 기준)
paths:
  - "**/*.html"            # 적용할 경로/글로브 패턴
  - "src/**/*.{ts,tsx}"
---
```

| 필드 | 필수 | 의미 |
|---|---|---|
| `description` | ✅ | 규칙을 **언제** 써야 하는지 한 문장. 화면 영역명·작업 종류·키워드를 포함한다. |
| `paths` | 조건부 | **path 기반 동적 로딩**의 기준. 적용할 경로 글로브 패턴 배열. 생략하면 모든 세션에서 항상 로딩된다. |

> **path 는 `paths` 키로만 표기한다.** rule frontmatter 에 `globs`·`path`·`applies_to` 같은 다른 키는 Claude Code 가 인식하지 못한다.

- 작업 종류·파일 유형과 무관하게 모든 작업에 필요한 규칙(예: 워크스페이스 경로 규칙)만 `paths` 를 **생략**한다. 그 외는 반드시 `paths` 를 지정한다.
- **path 로 대상을 특정할 수 있는 규칙**(HTML·SQL·특정 디렉토리 전용)은 `paths` 에 글로브를 적어 동적로딩한다 — 이것이 rule 의 기본 트리거 방식이다.
- path(파일 유형)로 좁힐 수 없고 작업 의도로만 판단되는 규칙(예: 백엔드 컨벤션)도 가능한 한 `paths` 로 대상 파일 패턴(`**/*Controller.java` 등)을 적어 컨텍스트 폭증을 막는다.

### Glob 패턴 예시

| 패턴 | 매칭 |
|---|---|
| `**/*.ts` | 모든 디렉토리의 모든 TypeScript 파일 |
| `src/**/*` | `src/` 디렉토리 아래의 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/**/*.{ts,tsx}` | 중괄호 확장으로 여러 확장자 매칭 |

---

### 3-1. Rule 본문 내 patterns 참조 규칙

- rule 본문에는 patterns 문서 내용을 길게 인라인하지 않는다. rule은 판단 기준과 금지/필수 규칙만 담고, 상세 구현 패턴은 `patterns/**/00-overview.md` 또는 핵심 SSoT leaf 문서로 연결한다.
- rule이 특정 영역 전체를 안내해야 하면 개별 leaf 문서를 모두 나열하지 말고 가장 가까운 `00-overview.md`를 우선 참조한다.
- 특정 leaf 문서가 없으면 잘못 구현될 정도로 중요한 경우에만 rule에서 leaf 문서를 직접 참조한다.
- 신규 `patterns/**/*.md` 문서를 추가할 때는 해당 디렉토리 또는 상위 영역의 `00-overview.md`에 반드시 인덱스 항목을 추가한다. 모든 rule에 신규 leaf를 직접 추가하지 않는다.
- 신규 문서가 기존 rule의 핵심 SSoT를 대체하거나, rule의 필수 판단 기준이 되는 경우에만 관련 rule의 `참조 문서 (SSoT)` 표도 함께 갱신한다.
- rule의 참조 표는 "문서 목록"이 아니라 "AI가 어떤 문서를 먼저 열어야 하는지 알려주는 라우팅 표"로 작성한다.
- 참조 경로는 저장소 루트 기준 상대 경로로 쓰고, 작성 후 실제 파일 존재 여부를 확인한다.

| 참조 대상 | 권장 방식 | 예 |
|---|---|---|
| 영역 전체 | 가장 가까운 `00-overview.md` | `patterns/10-screen-design/10-web/00-overview.md` |
| DB 전반 | DB overview | `patterns/20-database/00-overview.md` |
| 구현을 좌우하는 핵심 규칙 | leaf 직접 참조 | `patterns/30-backend/40-guide/05-mapper-xml-writing-rules.md` |
| SIF 방향별 핵심 컨벤션 | leaf 직접 참조 | `patterns/50-interface/10-convention/01-erp-to-wms-convention.md` |

---

## 4. Skill frontmatter (`.claude/skills/*/SKILL.md`)

skill 은 `description` 자동트리거가 기본이며, 추가로 `paths` / 호출제어 / 인자힌트 / 도구권한 등을 지정한다.

> **명명 규칙 (2026-06 통일)**: 스킬 디렉토리명(=슬래시 명령어)은 **언더스코어(snake_case)** 로 통일한다. 하이픈 금지. 번호형(`SD_311`)·동작형(`PI_be_all`) 모두 언더스코어를 쓴다. → `/PI` 입력 시 구분자 예측이 일관된다.

### 4-1. 기본 예시

```yaml
---
name: PI_be_mapper
description: BE Mapper 레이어 개발 (Mapper.java + Mapper.xml, MyBatis 쿼리 + JUnit). /PI_be_mapper {메뉴코드}
when_to_use: "Mapper 만들어줘", "MyBatis 쿼리 작성해줘", "Mapper.xml 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---
```

### 4-2. 전체 필드 표 (공식 스펙)

| 필드 | 필수 | 의미 |
|---|---|---|
| `name` | 선택 | 표시 라벨. **디렉토리명이 곧 명령어**이므로 슬래시 명령은 디렉토리명을 따른다. 생략하면 디렉토리명이 사용된다. |
| `description` | ✅(권장) | 동작 요약 + 호출 형식. Claude 가 자동 호출 여부를 판단하는 기준. **`description` + `when_to_use` 합쳐 1,536자에서 잘린다** — 짧고 명료하게. |
| `when_to_use` | 선택 | 트리거 문구·예시 요청 ("…만들어줘", "…돌려줘"). `description` 끝에 이어붙어 자동트리거 정확도를 높인다. 1,536자 캡 공유. |
| `argument-hint` | 선택 | 자동완성 힌트. 예: `"[메뉴코드]"`, `"[이슈번호] [진행율] [작업내역]"`. |
| `arguments` | 선택 | 명명 인자 선언. 예: `arguments: [menu_code]` → 본문에서 `$menu_code` 치환 가능. 미선언이면 `$ARGUMENTS` / `$0`/`$1` 사용. |
| `disable-model-invocation` | 선택 | `true` 면 Claude 자동 호출 차단(사용자만 슬래시로 호출). 부작용 있는 작업(`/deploy`, `/PI_time_reg`, `/PI_411` 등) 에 권장. |
| `user-invocable` | 선택 | `false` 면 `/` 메뉴에서 숨김. 백그라운드 지식형 skill 에만 사용. 기본 `true`. |
| `allowed-tools` | 권장 | skill 활성 중 권한 없이 쓸 수 있는 도구. 공백/콤마 구분 또는 YAML 리스트. |
| `disallowed-tools` | 선택 | skill 활성 중 차단할 도구. 자율 루프 skill 의 `AskUserQuestion` 차단 등에 사용. |
| `model` | 선택 | skill 활성 동안 사용할 모델. 다음 사용자 입력 시 세션 모델로 복귀. |
| `effort` | 선택 | `low`/`medium`/`high`/`xhigh`/`max`. 세션 effort 보다 우선. |
| `context` | 선택 | `fork` → 서브에이전트 컨텍스트에서 실행. |
| `agent` | 선택 | `context: fork` 시 사용할 서브에이전트 타입. |
| `paths` | 선택 | skill 자동 호출 범위를 글로브로 제한. rule 의 `paths` 와 동일 형식. |
| `hooks` | 선택 | skill 라이프사이클 훅. |
| `shell` | 선택 | `!\`command\`` 동적 컨텍스트 주입 셸. Windows + PowerShell 환경은 `powershell` (+`CLAUDE_CODE_USE_POWERSHELL_TOOL=1`). |

### 4-3. 호출 제어 패턴

| 의도 | frontmatter 조합 |
|---|---|
| 누구나 호출 + Claude 자동 호출 가능 (기본) | (옵션 없음) |
| 사용자만 슬래시로 호출, Claude 자동 호출 차단 | `disable-model-invocation: true` |
| Claude 만 자동 호출, `/` 메뉴 노출 안 함 | `user-invocable: false` |

### 4-4. description / when_to_use 작성 가이드

- `description` 은 **동작 요약 + 슬래시 호출 형식** 만 적는다 (예: `BE 전체 레이어 일괄 개발. /PI_be_all {메뉴코드}`).
- 트리거 문구("…만들어줘", "…돌려줘") 는 **`when_to_use` 로 분리**한다. 1,536자 캡을 description 이 다 쓰지 않도록 한다.
- `description` 한 줄 + `when_to_use` 한 줄 구조가 자동트리거 정확도가 가장 높다.

### 4-5. 인자 힌트·치환

```yaml
---
name: migrate-component
description: 컴포넌트를 다른 프레임워크로 변환. /migrate-component {컴포넌트명} {원본FW} {대상FW}
argument-hint: "[컴포넌트명] [원본FW] [대상FW]"
arguments: [component, from, to]
---

`$component` 를 `$from` 에서 `$to` 로 변환한다.
```

| 치환 | 의미 |
|---|---|
| `$ARGUMENTS` | 전체 인자 문자열 |
| `$ARGUMENTS[N]` / `$N` | 0-based 위치 인자 |
| `$이름` | `arguments` 에 선언한 명명 인자 |
| `${CLAUDE_SESSION_ID}` | 현재 세션 ID |
| `${CLAUDE_SKILL_DIR}` | SKILL.md 가 있는 디렉토리 (스크립트 참조용) |

---

## 5. 작성 체크리스트

- [ ] rule 에 `paths` 를 지정했는가? (생략은 "항상 로딩"이 정당한 경우에만)
- [ ] `paths` 키 이름을 정확히 사용했는가? (`globs`·`applies_to` 등 다른 이름 금지)
- [ ] `alwaysApply` 같은 Cursor 전용 필드를 쓰지 않았는가?
- [ ] skill `description` 이 동작 요약 + 호출 형식 위주로 짧은가? (트리거 문구는 `when_to_use` 로 분리)
- [ ] 부작용 있는 사용자 트리거형 skill 에 `disable-model-invocation: true` 를 붙였는가?
- [ ] 인자 받는 skill 에 `argument-hint` 를 붙였는가?
- [ ] skill `allowed-tools` 를 실제 사용하는 도구로만 한정했는가?
- [ ] `paths` 글로브 값을 추정 없이 실제 대상으로 확인했는가?
- [ ] rule 본문에 상세 패턴을 과도하게 인라인하지 않고 `patterns` 문서로 분리했는가?
- [ ] 영역 전체 참조는 개별 leaf 나열보다 가장 가까운 `00-overview.md`를 우선 사용했는가?
- [ ] 신규 `patterns/**/*.md` 추가 시 해당 `00-overview.md` 인덱스를 갱신했는가?
- [ ] rule에서 직접 참조한 leaf 문서는 핵심 SSoT 또는 BLOCKING 판단 기준인가?

---

## 상세 참조

- 일반 Markdown frontmatter(meta) 규칙: → `.claude/rules/md-frontmatter.md`
- 실제 rule frontmatter 예: `.claude/rules/area_btn.md`(동적로딩), `.claude/rules/repo-paths.md`(항상로딩)
- 실제 skill frontmatter 예: `.claude/skills/PI_be_mapper/SKILL.md`
- Claude Code 공식 문서:
  - [Memory · Path-scoped rules](https://code.claude.com/docs/en/memory#path-specific-rules)
  - [Skills · Frontmatter reference](https://code.claude.com/docs/en/skills#frontmatter-reference)
