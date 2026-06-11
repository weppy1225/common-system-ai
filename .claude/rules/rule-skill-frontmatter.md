---
description: rules·skills 파일을 새로 만들거나 수정할 때 frontmatter 작성 규칙. 모든 rule/skill 이 한 번에 로딩되지 않고 description·globs·alwaysApply 로 항상로딩·동적로딩·자동트리거 되도록 한다.
globs: [".claude/rules/**/*.md", ".claude/skills/**/SKILL.md"]
alwaysApply: false
title: Rule·Skill Frontmatter 작성 규칙
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: rule
tags:
  - frontmatter
  - rules
  - skills
  - dynamic-loading
---

# Rule·Skill Frontmatter 작성 규칙

`.claude/rules/*.md` 와 `.claude/skills/*/SKILL.md` 를 새로 만들거나 의미 있게 수정할 때 적용한다.
목적은 **모든 rule/skill 이 컨텍스트에 한 번에 로딩되는 것을 막고**, frontmatter로 로딩 시점을 제어하여 필요한 것만 동적으로 불러오는 것이다.

> 일반 Markdown 문서 메타데이터(`title`·`status`·`agent_usage` 등) 규칙은 → `.claude/rules/md-frontmatter.md` 참조. 이 문서는 **로딩 제어 필드**(`globs`·`alwaysApply`·`description` 트리거)에만 집중한다.

---

## 1. 핵심 원칙 — 전체 로딩 금지

- rule/skill 은 기본적으로 **컨텍스트 절약을 위해 동적 로딩**한다. `alwaysApply: true` 는 정말 모든 화면·모든 작업에 예외 없이 필요한 규칙에만 부여한다.
- 특정 파일 유형·특정 작업에서만 필요한 규칙은 `globs`(경로/글로브) 또는 `description`(자동트리거)으로 조건부 로딩한다.
- frontmatter 값은 추정하지 않는다. 실제 적용 대상 경로·파일을 확인한 뒤 적는다.

---

## 2. 로딩 모드 3가지

| 모드 | 한글 | 적용 필드 | 로딩 시점 |
|---|---|---|---|
| 항상로딩 | always | `alwaysApply: true` | 세션 시작부터 항상 컨텍스트에 존재 |
| 동적로딩(path 기반 자동첨부) | dynamic | `alwaysApply: false` + `globs` | **`globs` 의 path 글로브에 매칭되는 파일을 다룰 때만** 첨부 |
| 자동트리거(의도 기반) | auto-trigger | `description` (의도/키워드) | path 로 좁힐 수 없을 때, 요청·작업 의도가 `description` 과 맞으면 로딩 |

- **rule 의 동적 트리거는 기본적으로 path 기반이다.** 즉 `globs` 에 적은 경로 글로브에 해당하는 파일을 다룰 때 자동 첨부된다. path 로 대상을 특정할 수 있는 규칙은 반드시 `globs` 로 path 를 지정한다.
- **별도의 `path` 키는 사용하지 않는다.** path 정보는 모두 `globs` 배열 안에 글로브 패턴으로 담는다. (실제 레포 rule 전부 `globs` 사용 — `area_*`, `popup_*`, `common_ui` 등)
- 셋은 배타적이지 않다. `alwaysApply: false` 인 rule 은 `globs` path 매칭(동적로딩)과 `description` 의도(자동트리거)를 **함께** 사용해 로딩될 수 있다.
- skill 은 `globs`·`alwaysApply` 를 쓰지 않고 **항상 `description` 자동트리거**로만 로딩된다(아래 §4).

---

## 3. Rule frontmatter (`.claude/rules/*.md`)

```yaml
---
description: 이 규칙을 언제 적용하는지 한 문장 (자동트리거 판단 기준)
globs: ["**/*.html"]          # 적용할 경로/글로브 패턴 (path·glob)
alwaysApply: false            # true=항상로딩 / false=동적로딩·자동트리거
---
```

| 필드 | 필수 | 의미 |
|---|---|---|
| `description` | ✅ | 규칙을 **언제** 써야 하는지 한 문장. 의도 기반 자동트리거의 판단 근거. 화면 영역명·작업 종류·키워드를 포함한다. |
| `globs` | 조건부 | **path 기반 동적 트리거**의 기준. 적용할 경로 글로브 패턴 배열을 적는다. 특정 파일 유형/디렉토리에만 적용되는 규칙은 반드시 지정한다. (예: HTML 화면규칙 → `["**/*.html"]`, 특정 디렉토리 → `["src/views/**"]`) |
| `alwaysApply` | ✅ | `true` 면 항상로딩, `false` 면 `globs`(path)·`description`(의도) 기반 동적로딩. **기본값은 `false`** 로 둔다. |

> **path 는 `globs` 로만 표기한다.** rule frontmatter 에 `path`·`paths` 같은 별도 키는 없다. 경로 조건은 전부 `globs` 배열의 글로브 패턴으로 적는다.

- 작업 종류·파일 유형과 무관하게 모든 작업에 필요한 규칙(예: 워크스페이스 경로 규칙)만 `alwaysApply: true` 후보다. 그 외는 `false`.
- **path 로 대상을 특정할 수 있는 규칙**(HTML·SQL·특정 디렉토리 전용)은 `alwaysApply: false` + `globs`(path 글로브) 조합으로 동적로딩한다 — 이것이 rule 의 기본 동적 트리거 방식이다.
- path(파일 유형)로 좁힐 수 없고 작업 의도로만 판단되는 규칙(예: 백엔드 컨벤션)은 `globs` 대신 `description` 에 트리거 의도를 명확히 적어 의도 기반 자동트리거시킨다.

---

## 4. Skill frontmatter (`.claude/skills/*/SKILL.md`)

skill 은 `description` 자동트리거로만 로딩되며, `globs`·`alwaysApply` 를 사용하지 않는다.

```yaml
---
name: PI-be-mapper
description: BE Mapper 레이어 개발 (...). "Mapper 만들어줘", "Mapper.xml 만들어줘" 요청 시 사용. /PI-be-mapper {메뉴코드}
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---
```

| 필드 | 필수 | 의미 |
|---|---|---|
| `name` | ✅ | skill 식별자. 디렉토리명과 일치시킨다. |
| `description` | ✅ | **무엇을** 하는지 + **언제** 부르는지. 사용자 트리거 문구("…만들어줘")와 호출 형식(`/명령 {메뉴코드}`)을 포함한다. 자동트리거 정확도가 여기서 결정된다. |
| `user-invocable` | 선택 | 슬래시 커맨드로 직접 호출 가능하면 `true`. |
| `allowed-tools` | 권장 | skill 이 사용하는 도구만 콤마로 나열해 권한을 최소화한다. |
| `model` | 선택 | 특정 모델 고정이 필요할 때만 지정한다. |

- `description` 은 한 줄에 **동작 요약 → 트리거 키워드 → 호출 형식** 순으로 적는다. 키워드가 부족하면 자동트리거가 안 되고, 너무 광범위하면 오발동한다.

---

## 5. 작성 체크리스트

- [ ] `alwaysApply` 를 기본 `false` 로 두었는가? `true` 라면 "모든 작업에 예외 없이 필요"가 정당한가?
- [ ] 특정 파일 유형 전용 rule 에 `globs` 를 지정했는가?
- [ ] `description` 만 읽고도 로딩 시점(자동트리거)을 판단할 수 있는가?
- [ ] skill `description` 에 트리거 문구와 `/명령 {메뉴코드}` 형식이 들어 있는가?
- [ ] skill `allowed-tools` 를 실제 사용하는 도구로만 한정했는가?
- [ ] `globs`·경로 값을 추정 없이 실제 대상으로 확인했는가?

---

## 상세 참조

- 일반 Markdown frontmatter(meta) 규칙: → `.claude/rules/md-frontmatter.md`
- 실제 rule frontmatter 예: `.claude/rules/area_btn.md`(동적로딩), `.claude/rules/repo-paths.md`(항상로딩 후보)
- 실제 skill frontmatter 예: `.claude/skills/PI-be-mapper/SKILL.md`
