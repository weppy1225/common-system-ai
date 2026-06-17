---
name: deploy
description: 화면설계 산출물(prototype + 30-domain)을 서버의 dist/ 평탄 구조로 변환해 zinDev FTP에 배포. /deploy [{메뉴코드}]
when_to_use: "배포해줘", "FTP 올려줘", "화면 올려줘", "메뉴 배포해줘" 요청 시 사용.
argument-hint: "[메뉴코드(선택)]"
disable-model-invocation: true
allowed-tools: Bash, Read, AskUserQuestion
---

# FTP 배포 [deploy]

메뉴코드: **$ARGUMENTS**

화면설계 검토 공유용 미리보기 서버에 배포한다. 서버는 레포 구조 그대로가 아니라 **평탄화·리네임된 `dist/` 구조**로 서빙하므로, 업로드 전 staging 디렉토리에서 변환 후 올린다.

---

## 서버 dist/ 구조 (배포 결과)

```
/WEB_BASE/CLOUD_WMS_DOC/dist/
├── index.html
├── common/            # 공통 자산 (좌측메뉴·CSS·JS·검색 팝업)
│   ├── left-menu.html
│   ├── wms-ui.css
│   ├── wms-common.js
│   ├── CPCT01_popup.html
│   ├── CPPD01_popup.html
│   └── icon-preview.html
└── {메뉴코드}/        # 메뉴별 화면설계
    ├── wireframe.html
    ├── mock-data.js
    └── ui.md
```

---

## 변환 규칙 (로컬 → dist) — MUST 적용

| 로컬 원본 | dist 대상 | 내부 경로 변환 |
| --- | --- | --- |
| `prototype/index.html` | `dist/index.html` | `loadContent('../30-domain/30-wms-business/{c}/{c}-02-wireframe.html'` → `loadContent('{c}/wireframe.html'` |
| `prototype/_common/left-menu.html` | `dist/common/left-menu.html` | `loadContent('../../30-domain/30-wms-business/{c}/{c}-02-wireframe.html'` → `loadContent('../{c}/wireframe.html'` |
| `prototype/_common/{wms-ui.css, wms-common.js, CPCT01_popup.html, CPPD01_popup.html, icon-preview.html}` | `dist/common/<동일파일명>` | 변환 없음 (동일 디렉토리 참조) |
| `30-domain/30-wms-business/{c}/{c}-02-wireframe.html` | `dist/{c}/wireframe.html` | `../../../prototype/_common/` → `../common/`, `./{c}-02-mock-data.js` → `./mock-data.js` |
| `30-domain/30-wms-business/{c}/{c}-02-mock-data.js` | `dist/{c}/mock-data.js` | 리네임만 |
| `30-domain/30-wms-business/{c}/{c}-02-ui.md` | `dist/{c}/ui.md` | 리네임만 |

> `{c}` = 메뉴코드. `index.html` 과 `left-menu.html` 은 메뉴 링크가 추가되므로 항상 함께 배포한다.
> `wms-ui.css` / `wms-common.js` 는 모든 화면이 참조하는 공통 자산이므로 항상 함께 배포한다.

---

## FTP 서버 정보

| 항목 | 값 |
| --- | --- |
| 서버 | 168.126.28.62 |
| 포트 | 21 |
| 계정 | zinDev01 |
| 비밀번호 | Z1nPass01!Q2w3e4r |
| 원격 기본 경로 | `/WEB_BASE/CLOUD_WMS_DOC/dist/` |

---

## 배포 범위

### 메뉴코드 지정 (`/deploy {메뉴코드}`)
`index.html` + `common/` 전체 + 해당 `{메뉴코드}/` 만 배포한다.

### 메뉴코드 없이 (`/deploy`)
1. 최근 변경 메뉴코드를 감지한다.
```bash
git diff --name-only HEAD | grep -oP '30-domain/30-wms-business/\K[^/]+(?=/)' | sort -u
```
2. 1개면 해당 코드로 지정 배포한다.
3. 여러 개면 사용자에게 배포 대상을 선택받는다.
4. 0개면 전체(`30-domain/30-wms-business/` 모든 메뉴 + `index.html` + `common/`) 배포 여부를 사용자에게 확인받는다.

---

## 실행 절차

### 1단계. 업로드 도구 감지
```bash
which curl >/dev/null 2>&1 && echo "USE_CURL" || echo "USE_FTP"
```

### 2단계. staging 빌드 (변환 적용)

`/deploy {메뉴코드}` 의 경우 `CODES="$ARGUMENTS"`, `/deploy` 전체의 경우 `CODES=$(ls -d 30-domain/30-wms-business/*/ | xargs -n1 basename)`.

```bash
STAGE=$(mktemp -d)
mkdir -p "$STAGE/common"

# index.html — 메뉴 경로 평탄화
sed -E "s#\.\./30-domain/30-wms-business/([a-z0-9]+)/\1-02-wireframe\.html#\1/wireframe.html#g" \
    prototype/index.html > "$STAGE/index.html"

# common/left-menu.html — 메뉴 경로 평탄화 (common 기준 상대경로)
sed -E "s#\.\./\.\./30-domain/30-wms-business/([a-z0-9]+)/\1-02-wireframe\.html#../\1/wireframe.html#g" \
    prototype/_common/left-menu.html > "$STAGE/common/left-menu.html"

# common/ 그 외 공통 자산 — 변환 없이 복사
for f in wms-ui.css wms-common.js CPCT01_popup.html CPPD01_popup.html icon-preview.html; do
  cp "prototype/_common/$f" "$STAGE/common/$f"
done

# 메뉴별 산출물 — 리네임 + 내부 경로 변환
for CODE in $CODES; do
  SRC="30-domain/30-wms-business/$CODE"
  [ -d "$SRC" ] || { echo "skip: $SRC 없음"; continue; }
  mkdir -p "$STAGE/$CODE"
  sed -E -e "s#\.\./\.\./\.\./prototype/_common/#../common/#g" \
         -e "s#\./$CODE-02-mock-data\.js#./mock-data.js#g" \
      "$SRC/$CODE-02-wireframe.html" > "$STAGE/$CODE/wireframe.html"
  [ -f "$SRC/$CODE-02-mock-data.js" ] && cp "$SRC/$CODE-02-mock-data.js" "$STAGE/$CODE/mock-data.js"
  [ -f "$SRC/$CODE-02-ui.md" ] && cp "$SRC/$CODE-02-ui.md" "$STAGE/$CODE/ui.md"
done

echo "=== staging 빌드 결과 ==="; find "$STAGE" -type f | sed "s#$STAGE/#dist/#"
```

### 3단계. 업로드 (staging → 서버 dist/)

#### curl 방식 (기본)
```bash
BASE="ftp://168.126.28.62/WEB_BASE/CLOUD_WMS_DOC/dist"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

find "$STAGE" -type f | while read -r f; do
  rel="${f#$STAGE/}"          # 예: index.html, common/wms-ui.css, mdpr01/wireframe.html
  curl -T "$f" --user "$AUTH" "$BASE/$rel" --ftp-create-dirs -s -w "$rel: %{size_upload}bytes\n"
done
```

#### ftp 방식 (curl 미설치 시)
```bash
cd "$STAGE"
find . -type f | sed 's#^\./##' | while read -r rel; do
  dir=$(dirname "$rel"); base=$(basename "$rel")
  ftp -n 168.126.28.62 <<FTPEOF
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC/dist
$([ "$dir" != "." ] && echo "mkdir $dir")
$([ "$dir" != "." ] && echo "cd $dir")
put $rel $base
bye
FTPEOF
done
cd - >/dev/null
```

### 4단계. 정리
```bash
rm -rf "$STAGE"
```

---

> 이 서버는 화면설계 검토 공유용 미리보기이며 운영 서비스가 아니다. 운영/빌드 파이프라인과는 무관하다.
> 미확인: 배포 결과를 브라우저로 여는 공개 URL 은 nginx 서빙 설정에 의존하므로 서버 설정에서 확인이 필요하다.
