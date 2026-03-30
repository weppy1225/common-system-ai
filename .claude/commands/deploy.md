# FTP 배포 명령어

메뉴코드: **$ARGUMENTS**

---

## 배포 범위

메뉴코드가 있는 경우 아래 2가지만 업로드한다.

| 대상        | 로컬 경로                     | 원격 경로                                   |
| ----------- | ----------------------------- | ------------------------------------------- |
| 진입점      | `dist/index.html`           | `/WEB_BASE/CLOUD_WMS_DOC/dist/index.html` |
| 메뉴 화면   | `dist/$ARGUMENTS/*.html`    |                                             |
| 메뉴 데이터 | `dist/$ARGUMENTS/*-data.js` |                                             |
| 화면설계 문서 | `dist/$ARGUMENTS/*.md`     |                                             |

메뉴코드 없이 `/deploy` 만 입력하면 가장최근에 메뉴코드폴더에 메뉴코드-data.js, html, md 파일 작성된 것을 git diff로 확인후 그 메뉴코드 데이터를 배포한다.

---

## FTP 서버 정보

| 항목           | 값                                |
| -------------- | --------------------------------- |
| 서버           | 168.126.28.62                     |
| 포트           | 21                                |
| 계정           | zinDev01                          |
| 비밀번호       | Z1nPass01!Q2w3e4r                 |
| 원격 기본 경로 | `/WEB_BASE/CLOUD_WMS_DOC/dist/` |

---

## 실행 절차

### 1단계 — 업로드 도구 감지

```bash
which ftp 2>/dev/null && echo "USE_FTP" || echo "USE_CURL"
```

- `ftp` 존재 → 이후 모든 업로드를 **ftp** 방식으로 실행
- `ftp` 없음 → 이후 모든 업로드를 **curl** 방식으로 실행

### 2단계 — 업로드 대상 파일 확인

아래 파일이 존재하는지 확인한다. 없으면 사용자에게 알리고 중단한다.

```bash
ls -la dist/$ARGUMENTS/
ls dist/index.html
```

### 3단계 — 파일 업로드

감지된 도구에 따라 실행한다.

#### ▶ ftp 방식

```bash
ftp -n 168.126.28.62 <<'FTPEOF'
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC/dist
put dist/index.html index.html
mkdir $ARGUMENTS
cd $ARGUMENTS
put dist/$ARGUMENTS/$ARGUMENTS.html $ARGUMENTS.html
put dist/$ARGUMENTS/$ARGUMENTS-data.js $ARGUMENTS-data.js
put dist/$ARGUMENTS/$ARGUMENTS.md $ARGUMENTS.md
bye
FTPEOF
```

#### ▶ curl 방식

```bash
BASE="ftp://168.126.28.62/WEB_BASE/CLOUD_WMS_DOC/dist"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

curl -T "dist/index.html" --user "$AUTH" "$BASE/index.html" --ftp-create-dirs -s -w "index.html: %{size_upload}bytes\n"
curl -T "dist/$ARGUMENTS/$ARGUMENTS.html" --user "$AUTH" "$BASE/$ARGUMENTS/$ARGUMENTS.html" --ftp-create-dirs -s -w "$ARGUMENTS.html: %{size_upload}bytes\n"
curl -T "dist/$ARGUMENTS/$ARGUMENTS-data.js" --user "$AUTH" "$BASE/$ARGUMENTS/$ARGUMENTS-data.js" --ftp-create-dirs -s -w "$ARGUMENTS-data.js: %{size_upload}bytes\n"
curl -T "dist/$ARGUMENTS/$ARGUMENTS.md" --user "$AUTH" "$BASE/$ARGUMENTS/$ARGUMENTS.md" --ftp-create-dirs -s -w "$ARGUMENTS.md: %{size_upload}bytes\n"
```

### 4단계 — 결과 보고

각 파일의 업로드 결과를 출력한다.

- 성공: `✓ {파일명} 업로드 완료`
- 실패: `✗ {파일명} 실패 — 오류 내용 출력`

---

## 전체 dist 배포 (`/deploy` 인수 없음)

메뉴코드 없이 호출된 경우, 반드시 사용자에게 확인을 요청한 뒤 실행한다.

#### ▶ ftp 방식 (전체)

```bash
ftp -n 168.126.28.62 <<'FTPEOF'
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC/dist
put dist/index.html index.html
mkdir common
cd common
put dist/common/left-menu.html left-menu.html
put dist/common/CPCT01_popup.html CPCT01_popup.html
put dist/common/CPPD01_popup.html CPPD01_popup.html
put dist/common/icon-preview.html icon-preview.html
bye
FTPEOF

# 메뉴 폴더별 순회
for dir in dist/*/; do
  code=$(basename "$dir")
  [ "$code" = "common" ] && continue
  ftp -n 168.126.28.62 <<FTPEOF2
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
cd /WEB_BASE/CLOUD_WMS_DOC/dist
mkdir $code
cd $code
$(for f in "$dir"*.html "$dir"*.js "$dir"*.md; do [ -f "$f" ] && echo "put $f $(basename $f)"; done)
bye
FTPEOF2
done
```

#### ▶ curl 방식 (전체)

```bash
BASE="ftp://168.126.28.62/WEB_BASE/CLOUD_WMS_DOC/dist"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

curl -T "dist/index.html" --user "$AUTH" "$BASE/index.html" --ftp-create-dirs -s -w "index.html: %{size_upload}bytes\n"

for f in dist/common/*; do
  fname=$(basename "$f")
  curl -T "$f" --user "$AUTH" "$BASE/common/$fname" --ftp-create-dirs -s -w "common/$fname: %{size_upload}bytes\n"
done

for dir in dist/*/; do
  code=$(basename "$dir")
  [ "$code" = "common" ] && continue
  for f in "$dir"*.html "$dir"*.js "$dir"*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    curl -T "$f" --user "$AUTH" "$BASE/$code/$fname" --ftp-create-dirs -s -w "$code/$fname: %{size_upload}bytes\n"
  done
done
```
