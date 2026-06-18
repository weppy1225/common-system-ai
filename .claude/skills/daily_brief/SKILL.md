---
name: daily_brief
description: 원격 저장소를 fetch·pull 하고, 새로 들어온 커밋을 「목록(누가·언제·왜)」과 「상세(변경 내용)」 두 섹션으로 분리해 리포팅한다. /daily_brief
when_to_use: "아침 브리핑", "저장소 최신화하고 뭐 바뀐지 알려줘", "pull 받고 변경내역 정리", "daily_brief 실행" 요청 시 사용.
disable-model-invocation: true
allowed-tools: Bash
---

# 일일 브리핑 [daily_brief]

원격(`origin/{현재브랜치}`)을 받아 최신화하고, **로컬에 없던 커밋**을 두 섹션으로 리포팅한다.
- 📜 **목록** — 누가·언제·무슨 커밋을 했는지 한눈에 (아침에 훑는 용도)
- 🔍 **상세** — 커밋별 실제 변경 내용 (궁금한 것만 찾아보는 용도)

## 1단계 — 현재 상태 확인 (Bash)

```bash
cd "$(git rev-parse --show-toplevel)"
BR=$(git rev-parse --abbrev-ref HEAD)
git fetch origin --prune
echo "=== 로컬 변경(working tree) ==="
git status -s
echo "=== 로컬 HEAD vs origin/$BR ==="
git log --oneline -1 HEAD
git log --oneline -1 "origin/$BR"
```

- working tree에 **미커밋 변경이 있으면** pull 하지 말고 사용자에게 먼저 알린다(stash/커밋 여부 확인).
- `origin/$BR`이 HEAD와 같으면 아래 한 줄만 출력하고 종료한다.
  ```
  📋 일일 브리핑 — {오늘날짜}
  ✅ 이미 최신입니다 (origin/$BR 과 동일, 새 커밋 없음)
  ```

## 2단계 — 받기 (fast-forward 우선)

```bash
RANGE="HEAD..origin/$BR"   # pull 전에 범위를 먼저 기억 (pull 후엔 비어버림)
git pull --ff-only origin "$BR"
```

- ff-only가 실패하면(로컬·원격 갈라짐) **자동 merge/rebase 하지 않고** 상황을 보고한 뒤 사용자 지시를 받는다.

## 3단계 — 새 커밋 수집

```bash
echo "=== 목록용 (해시 | 작성자 | 날짜 | 제목) ==="
git log "$RANGE" --pretty=format:'%h|%an|%ad|%s' --date=short
echo
echo "=== 상세용 (커밋별 본문 + 변경파일) ==="
git log "$RANGE" --pretty=format:'%n● %h | %an <%ae> | %ad%n%s%n%b' --date=short --stat
echo "=== 새 원격 브랜치 ==="
git branch -r --no-merged "origin/$BR" 2>/dev/null
```

필요 시 개별 커밋은 `git show {해시}` 로 확인한다.

## 4단계 — 리포팅 (목록 먼저 → 상세 나중)

수집한 내용을 아래 구조로 화면에 출력한다. **커밋 메시지를 그대로 붙여넣지 말고 "무엇이 어떻게 바뀌었는지"를 사람 말로 요약**한다.

### 📜 커밋 목록 (상단)
- 헤더 한 줄: `새 커밋 N개 · 작성자(들) · 이슈번호`
- 표: `# | 해시 | 작성자 | 날짜 | 커밋 내용`
- **한 줄 요약**: 누가 왜 몇 개 했는지 한 문장 + 충돌/fast-forward 여부
- 참고 한 줄: 새 브랜치, working tree 상태 등

### 🔍 상세 (하단)
- 커밋별 섹션: `# 번호. {해시} — 한 줄 제목` + 대상 파일 경로
- 핵심 변경을 `변경 전 → 변경 후` 표 또는 불릿으로 (경로·파일명·버전 등 구체 값 포함)
- 영향받는 스킬/문서/규칙이 무엇인지 명시

> 변경 파일이 spec/prototype/skills/rules 중 무엇인지에 따라, 진행 중인 작업에 영향을 주는지 한 줄 코멘트를 덧붙이면 더 좋다.

## 설계 메모
- `disable-model-invocation: true` — `git pull`은 로컬을 바꾸는 부작용이 있어 사용자가 `/daily_brief` 칠 때만 동작한다.
- `RANGE`는 pull **전에** 캡처한다. pull 후 `HEAD..origin`은 비어버려 새 커밋을 못 뽑는다.
- ff-only로만 받고, 갈라지면 멈춰서 묻는다(자동 merge 금지).
