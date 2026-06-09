---
name: deploy
description: 【FTP 배포】 cloud-wms-doc 프로젝트의 50-prototype/ 및 30-domain/ 산출물(메인 진입점, 공통 메뉴/CSS/JS, 메뉴별 wireframe·mock-data·ui.md)을 zinDev FTP 서버(168.126.28.62)의 `/WEB_BASE/CLOUD_WMS_DOC/` 경로로 업로드합니다. `/deploy {메뉴코드}` 형식으로 실행하면 해당 메뉴 폴더와 공통 자산을 함께 배포하고, 인자 없이 `/deploy` 만 실행하면 `git diff`로 최근 변경된 메뉴코드 폴더를 감지하여 배포 대상을 자동으로 정합니다(변경된 폴더가 여러 개면 선택 요청, 0개면 전체 배포 확인). 시스템에 `ftp` 클라이언트가 있으면 ftp 방식, 없으면 `curl` 방식으로 자동 선택해 업로드합니다. FTP 배포, 화면설계 산출물 배포, 30-domain/50-prototype 업로드, 메뉴 배포, WMS 와이어프레임 배포 요청 시 반드시 이 스킬을 사용합니다. 사용자가 "배포해줘", "FTP 올려줘", "30-domain 배포", "deploy 실행해줘", "화면 올려줘", "메뉴 배포해줘" 라고 말해도 이 스킬을 사용합니다.
allowed-tools: Bash, Read, AskUserQuestion
---

# FTP 배포 [deploy]

메뉴코드: **$ARGUMENTS**

---

## 배포 범위

### 메뉴코드 지정 배포 (`/deploy {메뉴코드}`)

| 대상 | 로컬 경로 | 원격 경로 |
| --- | --- | --- |
| 진입점 | `50-prototype/index.html` | `/WEB_BASE/CLOUD_WMS_DOC/50-prototype/index.html` |
| 공통 메뉴 | `50-prototype/10-common/left-menu.html` | `/WEB_BASE/CLOUD_WMS_DOC/50-prototype/10-common/left-menu.html` |
| 공통 CSS | `50-prototype/10-common/wms-ui.css` | `/WEB_BASE/CLOUD_WMS_DOC/50-prototype/10-common/wms-ui.css` |
| 공통 JS | `50-prototype/10-common/wms-common.js` | `/WEB_BASE/CLOUD_WMS_DOC/50-prototype/10-common/wms-common.js` |
| 메뉴 화면 | `30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html` | `/WEB_BASE/CLOUD_WMS_DOC/30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html` |
| 메뉴 데이터 | `30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js` | `/WEB_BASE/CLOUD_WMS_DOC/30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js` |
| 화면설계 문서 | `30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md` | `/WEB_BASE/CLOUD_WMS_DOC/30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md` |

> `index.html`과 `left-menu.html`은 메뉴 링크가 추가되므로 항상 함께 배포한다.
> `wms-ui.css` / `wms-common.js` 는 모든 메뉴 화면이 참조하는 공통 자산이므로 항상 함께 배포한다.

### 메뉴코드 없이 실행 (`/deploy`)

1. 최근 변경 메뉴코드를 감지한다.
```bash
git diff --name-only HEAD | grep -oP '30-domain/\K[^/]+(?=/)' | sort -u
```
2. 1개면 해당 코드로 메뉴코드 지정 배포를 수행한다.
3. 여러 개면 사용자에게 배포 대상을 선택받는다.
4. 0개면 전체 `30-domain/` 및 `50-prototype/` 배포 여부를 사용자에게 확인받는다.

---

## FTP 서버 정보

| 항목 | 값 |
| --- | --- |
| 서버 | 168.126.28.62 |
| 포트 | 21 |
| 계정 | zinDev01 |
| 비밀번호 | Z1nPass01!Q2w3e4r |
| 원격 기본 경로 | `/WEB_BASE/CLOUD_WMS_DOC/` |

---

## 실행 절차

### 1단계. 업로드 도구 감지

```bash
which ftp 2>/dev/null && echo "USE_FTP" || echo "USE_CURL"
```

### 2단계. 대상 파일 확인

```bash
ls -la 30-domain/$ARGUMENTS/
ls 50-prototype/index.html
ls 50-prototype/10-common/left-menu.html
```

### 3단계. 메뉴코드 지정 업로드

#### ftp 방식

```bash
ftp -n 168.126.28.62 <<FTPEOF
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC
put 50-prototype/index.html 50-prototype/index.html
mkdir 50-prototype/10-common
cd 50-prototype/10-common
put 50-prototype/10-common/left-menu.html left-menu.html
put 50-prototype/10-common/wms-ui.css wms-ui.css
put 50-prototype/10-common/wms-common.js wms-common.js
cd /WEB_BASE/CLOUD_WMS_DOC
mkdir 30-domain/$ARGUMENTS
cd 30-domain/$ARGUMENTS
put 30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html $ARGUMENTS-02-wireframe.html
put 30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js $ARGUMENTS-02-mock-data.js
put 30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md $ARGUMENTS-02-ui.md
bye
FTPEOF
```

#### curl 방식

```bash
BASE="ftp://168.126.28.62/WEB_BASE/CLOUD_WMS_DOC"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

curl -T "50-prototype/index.html" --user "$AUTH" "$BASE/50-prototype/index.html" --ftp-create-dirs -s -w "50-prototype/index.html: %{size_upload}bytes\n"
curl -T "50-prototype/10-common/left-menu.html" --user "$AUTH" "$BASE/50-prototype/10-common/left-menu.html" --ftp-create-dirs -s -w "50-prototype/10-common/left-menu.html: %{size_upload}bytes\n"
curl -T "50-prototype/10-common/wms-ui.css" --user "$AUTH" "$BASE/50-prototype/10-common/wms-ui.css" --ftp-create-dirs -s -w "50-prototype/10-common/wms-ui.css: %{size_upload}bytes\n"
curl -T "50-prototype/10-common/wms-common.js" --user "$AUTH" "$BASE/50-prototype/10-common/wms-common.js" --ftp-create-dirs -s -w "50-prototype/10-common/wms-common.js: %{size_upload}bytes\n"
curl -T "30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html" --user "$AUTH" "$BASE/30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html" --ftp-create-dirs -s -w "30-domain/$ARGUMENTS/$ARGUMENTS-02-wireframe.html: %{size_upload}bytes\n"
curl -T "30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js" --user "$AUTH" "$BASE/30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js" --ftp-create-dirs -s -w "30-domain/$ARGUMENTS/$ARGUMENTS-02-mock-data.js: %{size_upload}bytes\n"
curl -T "30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md" --user "$AUTH" "$BASE/30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md" --ftp-create-dirs -s -w "30-domain/$ARGUMENTS/$ARGUMENTS-02-ui.md: %{size_upload}bytes\n"
```

### 4단계. 전체 배포

#### ftp 방식

```bash
ftp -n 168.126.28.62 <<FTPEOF
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC
put 50-prototype/index.html 50-prototype/index.html
mkdir 50-prototype/10-common
cd 50-prototype/10-common
put 50-prototype/10-common/left-menu.html left-menu.html
put 50-prototype/10-common/CPCT01_popup.html CPCT01_popup.html
put 50-prototype/10-common/CPPD01_popup.html CPPD01_popup.html
put 50-prototype/10-common/icon-preview.html icon-preview.html
put 50-prototype/10-common/wms-ui.css wms-ui.css
put 50-prototype/10-common/wms-common.js wms-common.js
bye
FTPEOF

for dir in 30-domain/*/; do
  code=$(basename "$dir")
  [ "$code" = "90-issue" ] && continue
  [ "$code" = "91-install-guide" ] && continue
  [ "$code" = "92-development-workflow" ] && continue
  ftp -n 168.126.28.62 <<FTPEOF2
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC
mkdir 30-domain/$code
cd 30-domain/$code
$([ -f "${dir}${code}-02-wireframe.html" ] && echo "put ${dir}${code}-02-wireframe.html ${code}-02-wireframe.html")
$([ -f "${dir}${code}-02-mock-data.js" ] && echo "put ${dir}${code}-02-mock-data.js ${code}-02-mock-data.js")
$([ -f "${dir}${code}-02-ui.md" ] && echo "put ${dir}${code}-02-ui.md ${code}-02-ui.md")
bye
FTPEOF2
done
```

#### curl 방식

```bash
BASE="ftp://168.126.28.62/WEB_BASE/CLOUD_WMS_DOC"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

curl -T "50-prototype/index.html" --user "$AUTH" "$BASE/50-prototype/index.html" --ftp-create-dirs -s -w "50-prototype/index.html: %{size_upload}bytes\n"

for f in 50-prototype/10-common/*; do
  fname=$(basename "$f")
  curl -T "$f" --user "$AUTH" "$BASE/50-prototype/10-common/$fname" --ftp-create-dirs -s -w "50-prototype/10-common/$fname: %{size_upload}bytes\n"
done

for dir in 30-domain/*/; do
  code=$(basename "$dir")
  [ "$code" = "90-issue" ] && continue
  [ "$code" = "91-install-guide" ] && continue
  [ "$code" = "92-development-workflow" ] && continue
  [ -f "${dir}${code}-02-wireframe.html" ] && curl -T "${dir}${code}-02-wireframe.html" --user "$AUTH" "$BASE/30-domain/$code/${code}-02-wireframe.html" --ftp-create-dirs -s -w "30-domain/$code/${code}-02-wireframe.html: %{size_upload}bytes\n"
  [ -f "${dir}${code}-02-mock-data.js" ] && curl -T "${dir}${code}-02-mock-data.js" --user "$AUTH" "$BASE/30-domain/$code/${code}-02-mock-data.js" --ftp-create-dirs -s -w "30-domain/$code/${code}-02-mock-data.js: %{size_upload}bytes\n"
  [ -f "${dir}${code}-02-ui.md" ] && curl -T "${dir}${code}-02-ui.md" --user "$AUTH" "$BASE/30-domain/$code/${code}-02-ui.md" --ftp-create-dirs -s -w "30-domain/$code/${code}-02-ui.md: %{size_upload}bytes\n"
done
```
