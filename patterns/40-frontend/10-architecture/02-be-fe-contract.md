---
title: BE ↔ FE 연동 규약
description: FE와 BE 간 HTTP 메서드·URL 패턴·응답 네이밍·인증·에러 처리 런타임 계약을 정의한다. FE API 호출 코드 작성 시 반드시 참조.
status: active
version: 1.0.0
wms_meta: true
project: cloud-wms-doc
agent_usage: reference
domain: frontend
tags:
  - api-contract
  - http
  - axios
  - authentication
related:
  - patterns/40-frontend/20-convention/03-backend-spec-consumption.md
---

# BE ↔ FE 연동 규약

대응 백엔드: `cloud-wms-be` (Spring + MyBatis).

## 1. API 경로 규약

### 기본 패턴

```
/{메뉴코드}/{리소스명}[/복합키...]
```

| 메서드 | 경로 예 | 용도 |
| --- | --- | --- |
| POST   | `/mdct01/conts` | 리스트 조회 (검색조건이 body) |
| GET    | `/mdct01/conts/{contSeq}/{bizSeq}` | 단건 조회 (복합키는 `{리소스}Seq/{bizSeq}` 순) |
| GET    | `/mdwh01/whs/{whSeq}` | 단건 조회 (단일키 리소스) |
| PUT    | `/mdct01/conts` | 신규 등록 |
| PATCH  | `/mdct01/conts` | 수정 |
| DELETE | `/mdct01/conts` (body 또는 쿼리) | 다건 삭제 |

> ⚠ 실제 코드 기준. `mdct01Edt.vue` / `mdwh01Edt.vue` 참조. FE 표준은 **등록=PUT, 수정=PATCH** 이며 `POST=리스트 조회` 로 사용한다 (일반 REST 관례와 다름).

### regBizSeq 자동 prepend

`zAxios` 인터셉터(`lfn_setRegBizSeq`) 가 자동으로:

```
요청:   axios.post('/mdct01/conts', ...)
실제:   POST /{regBizSeq}/mdct01/conts
```

→ FE 코드에서 `regBizSeq` 를 URL 에 **절대 직접 포함하지 말 것**.

예외 (regBizSeq 자동 부여 제외):
- `/login`, `/logout/*`, `/signup/*`, `/updatePwd`, `/send-message`
- `/lpa/*`, `/etrc01m/*` (전자수령 등)

## 2. 복합키 규약

- 거의 모든 리소스는 **`bizSeq + {리소스}Seq` 복합키**
- 예: 거래처 `(bizSeq, contSeq)`, 상품 `(bizSeq, prdSeq)`, 위치 `(bizSeq, locSeq)`
- URL 또는 body 양쪽 모두 복합키 유지

## 3. 요청/응답 필드 규약

| 관례 | 설명 |
| --- | --- |
| DB 컬럼: `snake_case` | 예: `cont_div_cd` |
| Java/FE 필드: `camelCase` | 예: `contDivCd` |
| MyBatis `<resultMap>` 이 변환 | Mapper XML 에 AS alias 추가 필요 없음 (대부분) |
| 단, alias 가 필요한 동적 컬럼은 XML 에 `AS camelCase` 명시 | |

### 응답 네이밍
- 리스트: `res.data.post{Resource}s` (예: `postConts`, `postPrds`)
- 단건: `res.data.{resource}` — 소문자 리소스 키. 예: `res.data.cont`, `res.data.wh`
- 성공 메시지: `res.data` (string) — `successSwal(res.data)` 에 그대로

## 4. 인증 헤더

`zAxios` 가 자동으로:
- `Authorization: {grantType}{accessToken}` 세팅
- 만료 임박 시 `refresh-token` 헤더 추가
- 리프레시 토큰 만료 시 로그아웃 유도

→ 화면 코드에서 헤더 조작 금지.

## 5. 에러 포맷

BE 예외 응답:
```json
{
    "message": "거래처를 찾을 수 없습니다.",
    "code": "ERR_CONT_NOT_FOUND"
}
```

FE 처리:
```js
try {
    await axios.post(...);
} catch (error) {
    errorSwal(error);   // 내부에서 error.response.data.message 표시
}
```

`IF_ERROR_CODE = 'SifResponseWarnException'` 은 경고 처리 (zAxios 상수 참조).

## 6. 공통코드 / 사업장

| 리소스 | BE 경로 | FE 진입점 |
| --- | --- | --- |
| 공통코드 | `POST /code/commcds?bizSeq=X` | `commCdStore.convertCommDNms` / `getCommHCd` |
| 사업장-센터 | `GET /code/bizCenter?authTypeCd=X` | `bizCenterStore` (앱 부팅 시 1회) |

둘 다 **스토어를 거치므로 화면에서 직접 호출 금지**.

## 7. 파일 업/다운로드

- 엑셀 업로드: `ZXlsAllUp` (`/{메뉴}/excel/upload`)
- 엑셀 다운로드: `gfn_exportTo(type, options, target)` — 클라이언트 사이드 변환 (서버 왕복 X). 사용 예: `gfn_exportTo('xlsx', excelOptions, ctGrid.value.grid)`
- 바이너리 업로드: `multipart/form-data`, `FormData` 직접 구성

## 8. BE 문서와의 교차 참조

BE 스펙 원천 경로·네이밍·동기화 절차는 **`patterns/40-frontend/20-convention/03-backend-spec-consumption.md` 단일 소스**에 있다.
이 파일은 런타임 계약(HTTP 메서드·응답 네이밍·복합키)만 다루고, "어떤 BE 문서를 어떻게 읽는가" 는 03번을 따른다.

FE 메뉴 작업 시 순서:
1. `patterns/30-backend/90-api/` 에서 BE 산출물 확인.
2. 최신 `{YYYYMMDD}_output.md`, 없으면 `output.md`, 없으면 `spec.md` 로 API 목록·Request·Response 확인.
3. 부족하면 `patterns/30-backend/90-api/20-detail/{menu-lower}-*.md` 를 보조 참고.
