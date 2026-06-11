# 프롬프트: 메뉴 계약 정합성 감사 (정적)

`../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/` 산출물과 FE 실제 코드(`src/views/be/{group}/{menu}/*.vue`) 간 드리프트를 **정적**으로 점검. `.claude/commands/audit-docs.md` 의 메뉴 특화판.

## 복사용 프롬프트

```
[메뉴코드] 계약 감사해줘.
```

## 입력·출력

- 입력: 메뉴코드 1개 (소문자/대문자 모두 허용).
- 출력: 불일치 테이블. **자동 수정 안 함** — 사용자가 보고 판단.

## 점검 항목

### 1. HTTP 메서드 규약

FE 표준 (`13-be-fe-contract.md` §1):

- POST `/{menu}/{res}` — 리스트 조회
- GET `/{menu}/{res}/{resSeq}/{bizSeq}` — 단건
- PUT `/{menu}/{res}` — 등록
- PATCH `/{menu}/{res}` — 수정
- DELETE `/{menu}/{res}` — 삭제

.vue 안의 `axios.{method}(url, ...)` 호출을 전부 잡아 80-spec API 목록과 대조.

### 2. URL 경로 리터럴

- `regBizSeq` 가 URL 에 직접 들어가면 오답 (zAxios 인터셉터가 prepend).
- 80-spec 의 BE URL 을 FE URL 로 변환한 값과 정확히 일치해야 함 (`/stdc01/stsets` 등).

### 3. 복합키 순서

- URL path variable 순서: `{resourceSeq}/{bizSeq}` — `mdct01Edt.vue:136` 기준.
- 반대로 `${bizSeq}/${resSeq}` 로 된 경우 오답.

### 4. 응답 네이밍

- 리스트: `res.data.post{Resource}s` (대문자 리소스 접두).
- 단건: `res.data.{resource}` — 소문자 리소스. `postCont` 같은 대문자 P 접두 오답.
- 80-spec Response 예시의 루트 키와 대조.

### 5. 60-menus 문서 일치

- `60-menus/{group}/{menu}/menu.md` §3 API 매핑표 vs 80-spec API 목록.
- 메서드/URL/Controller 경로가 다르면 드리프트.

## 실행 흐름

1. 인자 정규화 (소문자).
2. 다음 파일 존재 확인. 없으면 중단하고 원인 보고:
   - `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/{YYYYMMDD}_output.md` 또는 `output.md` 또는 `spec.md`
   - `src/views/be/*/\{menu\}/{menu}.vue`
3. Grep 으로 axios 호출·URL 리터럴·`res.data.*` 접근을 추출.
4. 80-spec 산출물 파싱 (API 목록, Request/Response 키).
5. 5개 점검 항목 대조.
6. 보고 형식:

```
## {MENU} 계약 감사 결과

BE 산출물: ../cloud-wms-be/.../80-spec/mdct01/20260417_output.md

### 불일치 N건

| 파일 | 라인 | 현재 | 기준 (80-spec) | 비고 |
| --- | --- | --- | --- | --- |
| mdct01.vue | 87 | axios.put 등록 | 80-spec: PUT OK | (일치) |
| mdct01Edt.vue | 220 | `res.data.postCont` | `res.data.cont` | 대문자 P 접두 오답 |

### 60-menus 문서 드리프트

- 60-menus/md8000/mdct01/menu.md §3: DELETE 행 누락 (80-spec 에 존재)

### 수정 제안

- mdct01Edt.vue:220 → `res.data.cont` 로 변경
- 60-menus/md8000-mdct01.md §3 에 DELETE 행 추가
```

불일치 0 건이면 `{MENU} 감사 통과` 한 줄만.

## 주의

- 자동 수정 절대 금지. 사용자 확인 필수.
- 80-spec 산출물 자체가 틀린 것 같으면 BE 저장소에서 산출물 재생성 권고.
- 런타임 동작은 이 프롬프트에서 검증 안 함 (→ `77-run-menu-check`).
- 주석 안의 예제는 제외 (audit-docs 규칙 준수).
