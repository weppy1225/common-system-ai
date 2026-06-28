---
title: 이미지 미리보기 — blob URL 패턴
description: 수정 팝업에서 기존 업로드 이미지를 미리보기로 표시할 때 fileSeq 기반 다운로드 API + blob URL을 사용하는 패턴
status: active
version: 1.0.0
author: binaryarc
repo_role: ai-hub
agent_usage: reference
tags:
  - fe
  - image
  - blob
  - file
last_verified: 2026-06-26
---

# 이미지 미리보기 — blob URL 패턴

## 배경 — SM_FILE.file_path는 서버 물리경로

`SM_FILE.file_path` 컬럼에는 서버 로컬 디스크 경로가 저장된다.

```
D:/WEB_BASE/oms-be-resources/omsFile/images/prod
```

이 값을 `<img :src="">` 에 그대로 넣으면 브라우저가 접근할 수 없어 이미지가 표시되지 않는다.

## 해결 패턴 — fileSeq → 다운로드 API → blob URL

수정 팝업 오픈 시 이미지의 `fileSeq`로 BE 파일 다운로드 API를 호출하고, 응답 blob을 브라우저 임시 URL로 변환해 `previewUrl`에 설정한다.

```javascript
async function lfn_getImagePreviewUrl(fileSeq) {
    if (EmptyTool.isEmpty(fileSeq)) return null;
    const res = await axios.post(`/file/${fileSeq}/download`, undefined, { responseType: 'blob' });
    return URL.createObjectURL(res.data);
}
```

## 전체 흐름

```
상품 상세 조회 (GET /shpd01/detail/{prodSeq})
  → 응답: mainImgs[{ fileSeq, fileNm, ... }]
  → fileSeq 확인
  → POST /file/{fileSeq}/download  (responseType: 'blob')
  → blob 수신
  → URL.createObjectURL(blob)  →  "blob:http://localhost:5173/..."
  → img.previewUrl 에 할당
  → <img :src="img.previewUrl"> 표시
```

## 적용 파일

| 파일 | 함수 |
|---|---|
| `kyochon-oms-fe/src/views/be/sh7000/shpd01/shpd01Edt.vue` | `lfn_getImagePreviewUrl` |

## 사용 API

| 메서드 | 경로 | 위치 |
|---|---|---|
| POST | `/file/{fileSeq}/download` | `fw/file/FileController.java` — `downloadFile()` |

## 주의사항

- `URL.createObjectURL(blob)`으로 생성한 URL은 **해당 브라우저 탭 세션에서만 유효**하다. 팝업을 닫으면 메모리에서 해제된다.
- 이미지를 새로 업로드할 때는 `URL.createObjectURL(file)` 방식을 그대로 사용하므로 패턴이 동일하다.
- 이 패턴은 파일 경로를 FE에 노출하지 않아 보안상 안전하다.
