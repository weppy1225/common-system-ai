---
name: SD-api
description: ?륚PI 紐낆꽭???ㅺ퀎???붾㈃?ㅺ퀎쨌DB ?ㅺ퀎 湲곕컲?쇰줈 api.md(API ?ㅺ퀎+湲곕뒫紐낆꽭 ?듯빀臾몄꽌)瑜??묒꽦?쒕떎. API 紐⑸줉쨌VO쨌DTO쨌鍮꾩쫰?덉뒪 濡쒖쭅쨌寃利?洹쒖튃 ?뺤쓽. /design-db ?꾨즺 ???ㅽ뻾. /SD-api {硫붾돱肄붾뱶} ?뺤떇?쇰줈 ?ㅽ뻾?쒕떎. ?ъ슜?먭? "api.md ?묒꽦?댁쨾", "API ?ㅺ퀎??留뚮뱾?댁쨾", "湲곕뒫紐낆꽭 留뚮뱾?댁쨾", "SD-api ?ㅽ뻾?댁쨾", "design-spec ?ㅽ뻾?댁쨾" ?쇨퀬 留먰빐?????ㅽ궗???ъ슜?쒕떎.
user-invocable: true
allowed-tools: Read, Write, Glob, Grep
model: claude-opus-4-7
---

# API 紐낆꽭???ㅺ퀎 [SD-api]

?ㅼ쓬 吏?쒖뿉 ?곕씪 湲곕뒫 紐낆꽭??api.md)瑜??묒꽦?쒕떎.

## ?ㅽ뻾 ?덉감

### Step 0 ???꾨줈?앺듃 寃쎈줈 ?꾩텧 (?먮룞)

?꾩옱 BE ?덊룷紐낆뿉???꾨줈?앺듃 肄붾뱶瑜?異붿텧?섏뿬 DOC ?덊룷 寃쎈줈瑜??꾩텧?쒕떎:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
PROJECT_CODE=$(basename "$REPO_ROOT" | sed 's/^wms-//' | sed 's/-be$//')
DOC_DIR="$(dirname "$REPO_ROOT")/wms-${PROJECT_CODE}-doc"

# ui.md??PC쨌紐⑤컮??怨듯넻?쇰줈 30-domain/ ???꾩튂
UI_MD="$DOC_DIR/30-domain/{硫붾돱肄붾뱶}/ui.md"

# wireframe: PC / PDA 紐⑤컮???먮룞 遺꾧린
if [ -f "$DOC_DIR/30-domain/{硫붾돱肄붾뱶}/wireframe.html" ]; then
  # PC ?붾㈃
  WIREFRAME="$DOC_DIR/30-domain/{硫붾돱肄붾뱶}/wireframe.html"
else
  # PDA 紐⑤컮???붾㈃ ??50-prototype/20-mobile/ ?섏쐞 洹몃９ ?대뜑 寃??  WIREFRAME=$(find "$DOC_DIR/50-prototype/20-mobile" -iname "{硫붾돱肄붾뱶?臾몄옄}.html" 2>/dev/null | head -1)
fi
```

?? DOC ?덊룷媛 ?녾굅??`30-domain/{硫붾돱肄붾뱶}/` ?대뜑媛 ?놁쑝硫??ъ슜?먯뿉寃?寃쎈줈瑜?吏곸젒 臾삳뒗??

### Step 1 ??湲곕뒫 ?뺣낫 ?뚯븙

?ъ슜?먭? ?쒓났??湲곕뒫紐??먮뒗 ?꾩옱 ???而⑦뀓?ㅽ듃?먯꽌 ?꾨옒 ?뺣낫瑜??뺤씤?쒕떎:

- 湲곕뒫紐?(?? "?낃퀬?붿껌 愿由?, "?덈ぉ ?쇰꺼 異쒕젰")
- 硫붾돱肄붾뱶 (?덈떎硫?
- ?꾨찓??(MDM/IW/OW/IV/RT/SIF 以?

### Step 2 ??湲곗〈 ?대뜑 ?뺤씤

`DEV_DOC/ai-docs/20-backend/80-spec/` ?섏쐞 ?대뜑瑜??뺤씤?쒕떎.

耳?댁뒪???곕씪 ?꾨옒? 媛숈씠 泥섎━?쒕떎:

| 耳?댁뒪                                | 議곌굔                            | 泥섎━ 諛⑸쾿                                                                                                                   |
| ------------------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **A. 湲곗〈 湲곕뒫 + api.md ?덉쓬** | ?대떦 ?대뜑 + api.md 議댁옱        | api.md瑜??댁뼱 ?댁슜???낅뜲?댄듃?쒕떎                                                                                          |
| **B. 湲곗〈 湲곕뒫 + api.md ?놁쓬** | ?대떦 ?대뜑???덉쑝??api.md ?놁쓬 | `src/main/java/` ?섏쐞 ?대떦 ?⑦궎吏??湲곗〈 肄붾뱶瑜??쎌뼱 援ы쁽 ?곹깭瑜??뚯븙???? ?대떦 ?대뜑??api.md瑜?**?좉퇋 ?묒꽦**?쒕떎 |
| **C. ?좉퇋 湲곕뒫**                | ?대뜑 ?먯껜媛 ?놁쓬                | `{硫붾돱肄붾뱶}` ?뺤떇?쇰줈 ???대뜑瑜??앹꽦?섍퀬 api.md瑜??묒꽦?쒕떎                                                               |

> ?대뜑紐??덉떆: `mdpd01`, `iwrq01`, `owpk01`

### Step 3 ??愿??臾몄꽌 ?쎄린 (BLOCKING)

肄붾뱶 ?묒꽦 ??諛섎뱶???꾨옒 臾몄꽌瑜??쎈뒗??

1. `DEV_DOC/ai-docs/20-backend/20-rule/02-api-naming-rule.md` ??硫붾돱肄붾뱶 洹쒖튃
2. 湲곕뒫 ?대뜑 ??`db.md` ??DB ?ㅺ퀎 寃곌낵 (議댁옱?섎뒗 寃쎌슦 **?곗꽑 李몄“**)
3. `$UI_MD` (`30-domain/{硫붾돱肄붾뱶}/ui.md`) ???붾㈃?ㅺ퀎 UI 紐낆꽭 (Step 0?먯꽌 ?꾩텧??蹂???ъ슜)
4. `$WIREFRAME` ???붾㈃ ?꾨줈?좏???(PC: `30-domain/{硫붾돱肄붾뱶}/wireframe.html` / PDA: `50-prototype/20-mobile/??{硫붾돱肄붾뱶?臾몄옄}.html`)
5. `DEV_DOC/ai-docs/10-database/00-database-overview.md` ??愿???뚯씠釉??뚯븙
6. ?대떦 ?꾨찓???뚯씠釉?而щ읆 紐낆꽭 (`DEV_DOC/ai-docs/10-database/90-schema/20-tables/`)
7. `DEV_DOC/ai-docs/20-backend/30-convention/02-backend-coding-convention.md` ??肄붾뵫 ?⑦꽩

### Step 4 ??api.md ?묒꽦

?꾨옒 ?쒗뵆由우쑝濡?`api.md`瑜??묒꽦?쒕떎:

```markdown
# {湲곕뒫紐? API 紐낆꽭??
> ?묒꽦?? {YYYY-MM-DD} | ?묒꽦?? AI | ?곹깭: 珥덉븞

---

## 1. 湲곕낯 ?뺣낫

| ??ぉ | ?댁슜 |
|---|---|
| 硫붾돱肄붾뱶 | {硫붾돱肄붾뱶} |
| 硫붾돱紐?| {硫붾돱紐? |
| 硫붾돱洹몃９ | {硫붾돱洹몃９} |
| ?⑦궎吏 | `be.{洹몃９}.{硫붾돱肄붾뱶}/` |
| URL prefix | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼???뚮Ц??` |
| ?대떦 ?꾨찓??| MDM / IW / OW / IV / RT / SIF |

---

## 2. 湲곕뒫 媛쒖슂

{湲곕뒫?????2-3臾몄옣 ?ㅻ챸}

---

## 3. API 紐⑸줉

| Interface ID | HTTP Method | URL | ?ㅻ챸 |
|---|---|---|---|
| {硫붾돱肄붾뱶}_POST_{由ъ냼??S | POST | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼??s` | 紐⑸줉 議고쉶 |
| {硫붾돱肄붾뱶}_POST_INSERT | POST | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼??s/insert` | ?④굔 ?깅줉 |
| {硫붾돱肄붾뱶}_GET_{由ъ냼?? | GET | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼??s/{seq}` | ?④굔 議고쉶 |
| {硫붾돱肄붾뱶}_POST_UPDATE | POST | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼??s/update` | ?④굔 ?섏젙 |
| {硫붾돱肄붾뱶}_DELETE_{由ъ냼??S | DELETE | `/{bizSeq}/{硫붾돱肄붾뱶_?몄뒪?댁뒪}/{由ъ냼??s` | ??젣 |

---

## 4. ?ъ슜 ?뚯씠釉?
| ?뚯씠釉붾챸 | ?⑸룄 | 二쇱슂 而щ읆 |
|---|---|---|
| `{?뚯씠釉붾챸}` | {?⑸룄} | `{而щ읆1}`, `{而щ읆2}` |

---

## 5. Bean ?ㅺ퀎

### {硫붾돱肄붾뱶}Response (?묐떟 DTO)
```java
extends ResponseData
- List<{硫붾돱肄붾뱶}Search> post{由ъ냼??s  // 紐⑸줉
- {硫붾돱肄붾뱶}{由ъ냼?? {由ъ냼???뚮Ц??    // ?④굔
```

### Search (議고쉶 ?뚮씪誘명꽣 + 寃곌낵)

```java
extends BaseParam
- Integer bizSeq
- String searchKeyword
// ... 寃?됱“嫄?諛?寃곌낵 而щ읆
```

### (?꾨찓??DTO)

```java
implements Serializable
// 二쇱슂 ?꾨뱶 紐⑸줉
```

---

## 6. 鍮꾩쫰?덉뒪 洹쒖튃

1. {洹쒖튃1}
2. {洹쒖튃2}
3. {洹쒖튃3}

---

## 7. ?좏슚??寃利?
| 寃利???ぉ               | 諛⑸쾿                      | ?ㅻ쪟 硫붿떆吏                |
| ----------------------- | ------------------------- | -------------------------- |
| {?꾨뱶紐? 以묐났           | `checkDuplicate*No()`   | "以묐났??{?꾨뱶紐??낅땲??    |
| {?꾨뱶紐? ?곌? ??젣 諛⑹? | `check*SeqInOtherTbl()` | "?곌? ?곗씠?곌? 議댁옱?⑸땲?? |

---

## 8. 愿??臾몄꽌

- DB ?ㅺ퀎: `db.md` (議댁옱?섎뒗 寃쎌슦)
- DB 紐낆꽭: `DEV_DOC/ai-docs/10-database/90-schema/20-tables/{?뚯씠釉붾챸}.md`
- 肄붾뵫 而⑤깽?? `DEV_DOC/ai-docs/20-backend/30-convention/02-backend-coding-convention.md`
- 媛쒕컻 媛?대뱶: `DEV_DOC/ai-docs/20-backend/80-spec/02-new-backend-api-addition-procedure.md`
```

---

### Step 5 ???꾨즺 ?덈궡

?앹꽦???곗텧臾?紐⑸줉怨??ㅼ쓬 ?④퀎瑜??덈궡?쒕떎:

```
??api.md ?앹꽦 ?꾨즺

?ㅼ쓬 ?④퀎: /PI-be-all (?먮뒗 /PI-be-mapper ??/PI-be-dao ??/PI-be-comp ?쒖꽌)
```
