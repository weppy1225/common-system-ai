# FTP 배포 명령어

메뉴코드: **$ARGUMENTS**

---

## 배포 범위

`dist/` 폴더가 배포 단위다. 항상 아래 3가지를 함께 업로드한다.

| 대상 | 경로 | 설명 |
|---|---|---|
| 진입점 | `dist/index.html` | 메뉴 + 탭 프레임 |
| 공통 UI | `dist/common/*` | left-menu, 팝업, 아이콘 |
| 메뉴 화면 | `dist/$ARGUMENTS/*` | html + data.js |

메뉴코드 없이 `/deploy` 만 입력하면 **dist/ 전체**를 배포한다 (실행 전 확인 요청).

---

## FTP 서버 정보

| 항목 | 값 |
|---|---|
| 서버 | 168.126.28.62 |
| 포트 | 21 |
| 계정 | zinDev01 |
| 비밀번호 | Z1nPass01!Q2w3e4r |
| 원격 기본 경로 | `/dist/` |

---

## 실행 절차

### 1단계 — 업로드 도구 감지

```bash
which ftp 2>/dev/null && echo "USE_FTP" || echo "USE_CURL"
```

- `ftp` 존재 → 이후 모든 업로드를 **ftp** 방식으로 실행
- `ftp` 없음 → 이후 모든 업로드를 **curl** 방식으로 실행

### 2단계 — 업로드 대상 파일 확인

메뉴코드가 있는 경우, 아래 파일이 존재하는지 확인한다. 없으면 사용자에게 알리고 중단한다.

```bash
ls -la dist/$ARGUMENTS/
ls -la dist/common/
ls dist/index.html
```

### 3단계 — 파일 업로드

감지된 도구에 따라 실행한다.

#### ▶ ftp 방식

```bash
ftp -n 168.126.28.62 21 <<'FTPEOF'
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
mkdir dist
mkdir dist/common
mkdir dist/$ARGUMENTS
cd dist
put dist/index.html index.html
cd common
put dist/common/left-menu.html left-menu.html
put dist/common/CPCT01_popup.html CPCT01_popup.html
put dist/common/CPPD01_popup.html CPPD01_popup.html
put dist/common/icon-preview.html icon-preview.html
cd ../$ARGUMENTS
put dist/$ARGUMENTS/$ARGUMENTS.html $ARGUMENTS.html
put dist/$ARGUMENTS/$ARGUMENTS-data.js $ARGUMENTS-data.js
bye
FTPEOF
```

#### ▶ curl 방식

```bash
HOST="ftp://168.126.28.62:21"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

# index.html
curl -T "dist/index.html" --user "$AUTH" "$HOST/dist/index.html" --ftp-create-dirs -s -w "index.html: %{size_upload}bytes\n"

# common/
for f in dist/common/*; do
  fname=$(basename "$f")
  curl -T "$f" --user "$AUTH" "$HOST/dist/common/$fname" --ftp-create-dirs -s -w "common/$fname: %{size_upload}bytes\n"
done

# 메뉴 화면
curl -T "dist/$ARGUMENTS/$ARGUMENTS.html" --user "$AUTH" "$HOST/dist/$ARGUMENTS/$ARGUMENTS.html" --ftp-create-dirs -s -w "$ARGUMENTS.html: %{size_upload}bytes\n"
curl -T "dist/$ARGUMENTS/$ARGUMENTS-data.js" --user "$AUTH" "$HOST/dist/$ARGUMENTS/$ARGUMENTS-data.js" --ftp-create-dirs -s -w "$ARGUMENTS-data.js: %{size_upload}bytes\n"
```

### 4단계 — 결과 보고

각 파일의 업로드 결과를 출력한다.

- 성공: `✓ {파일명} 업로드 완료`
- 실패: `✗ {파일명} 실패 — 오류 내용 출력`

---

## 전체 dist 배포 (`/deploy` 인수 없음)

메뉴코드 없이 호출된 경우, 반드시 사용자에게 확인을 요청한 뒤 아래 명령으로 실행한다.

#### ▶ ftp 방식 (전체)

```bash
ftp -n 168.126.28.62 21 <<'FTPEOF'
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
mkdir dist
mkdir dist/common
cd dist
put dist/index.html index.html
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
  ftp -n 168.126.28.62 21 <<FTPEOF2
user zinDev01 Z1nPass01!Q2w3e4r
binary
passive
mkdir dist/$code
cd dist/$code
$(for f in "$dir"*.html "$dir"*.js; do [ -f "$f" ] && echo "put $f $(basename $f)"; done)
bye
FTPEOF2
done
```

#### ▶ curl 방식 (전체)

```bash
HOST="ftp://168.126.28.62:21"
AUTH="zinDev01:Z1nPass01!Q2w3e4r"

curl -T "dist/index.html" --user "$AUTH" "$HOST/dist/index.html" --ftp-create-dirs -s -w "index.html: %{size_upload}bytes\n"

for f in dist/common/*; do
  fname=$(basename "$f")
  curl -T "$f" --user "$AUTH" "$HOST/dist/common/$fname" --ftp-create-dirs -s -w "common/$fname: %{size_upload}bytes\n"
done

for dir in dist/*/; do
  code=$(basename "$dir")
  [ "$code" = "common" ] && continue
  for f in "$dir"*.html "$dir"*.js; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    curl -T "$f" --user "$AUTH" "$HOST/dist/$code/$fname" --ftp-create-dirs -s -w "$code/$fname: %{size_upload}bytes\n"
  done
done
```
