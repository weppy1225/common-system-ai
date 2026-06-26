---
name: md_index
description: 레포 파일·폴더 지도(edu/md-index.html)를 scripts/gen-md-map.py 로 재생성해 최신화한다. /md_index
when_to_use: "파일 지도 최신화", "md-index 갱신", "md-index.html 다시 생성", "문서 지도 업데이트", "md_index 실행" 요청 시 사용.
allowed-tools: Bash
---

# 파일 지도 최신화 [md_index]

레포의 파일·폴더 지도 `edu/md-index.html` (교육자료) 를 **생성 스크립트로 재생성**한다.
이 HTML은 생성물이므로 **직접 편집하지 않고 항상 스크립트로 갱신**한다. (스킬·규칙·문서를 추가/이동한 뒤 실행)

## 1단계 — 재생성 (Bash)

```bash
cd "$(git rev-parse --show-toplevel)"
python scripts/gen-md-map.py || py scripts/gen-md-map.py
```

- `python` 이 없으면 `py` 런처로 폴백한다(Windows).
- 스크립트는 CWD와 무관하게 레포 루트 기준으로 동작하며, 출력은 `edu/md-index.html`.

## 2단계 — 결과 확인

```bash
cd "$(git rev-parse --show-toplevel)"
git status -s edu/md-index.html
ls -l edu/md-index.html
```

- 생성 성공 여부와 변경(diff 발생) 여부를 한 줄로 보고한다.
- 스킬/규칙을 새로 추가했다면, 분류가 누락되지 않았는지 확인한다. 누락 시 `scripts/gen-md-map.py` 의 `SKILL_DEV`/`SKILL_OUT`/`RULE_GROUP` 매핑을 보강해야 한다(스크립트 주석 참조).

## 3단계 — 커밋 (선택)

변경이 생겼고 사용자가 요청하면 `.claude/rules/git-workflow.md` 의 AI 허브 규칙(main 직접 푸시)에 따라 커밋·푸시한다. 자동으로 커밋하지 않는다.
