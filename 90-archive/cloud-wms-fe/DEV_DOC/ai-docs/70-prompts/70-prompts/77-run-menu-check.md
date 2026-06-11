# 프롬프트: 메뉴 계약 런타임 검증 (동적)

**실제 dev 서버에서 엔드포인트를 호출**해 응답 JSON 구조가 `../cloud-wms-be` 80-spec 산출물과 일치하는지 확인. 정적 감사는 `/util-verify-menu {메뉴코드}` 가 담당하고, 여기선 live 응답을 본다.

## 선행 조건 (사용자가 준비)

- `npm run dev:dev` 가 이미 떠 있음. **AI 가 함부로 띄우지 않음**.
- 로그인 세션 또는 유효 `accessToken` 확보.
- 테스트용 `bizSeq` / `centerSeq` 값 제공.

하나라도 없으면 AI 는 **중단하고 사용자에게 요청**. 임의 실행 금지.

## 호출 범위

**읽기 전용 API 만** 자동 호출:

- 리스트 조회 (POST `/{menu}/{res}`)
- 단건 조회 (GET) — 결과가 있을 때만

**절대 자동 호출 안 함**:
- PUT (등록), PATCH (수정), DELETE — 부작용 있음.
- 필요하면 사용자가 명시적으로 "수정 API 도 확인" 이라고 요청해야 함.

## 복사용 프롬프트

```
[메뉴코드] 런타임 검증해줘.

- dev 서버: http://localhost:5173 (또는 별도 지정)
- bizSeq: 1
- 쿠키/토큰: (있다면)
```

## 작업 절차

### 1. 준비물 확인

- dev 서버 URL, bizSeq, 인증 수단 확보.
- 없으면 중단 + 안내.

### 2. 80-spec 산출물 파싱

`../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/` 에서 최신 `{YYYYMMDD}_output.md`, 없으면 `output.md`, 없으면 `spec.md` 를 읽고 읽기 전용 API 만 목록화.

### 3. 호출

각 API 를 `curl` 로 1회:

```bash
curl -s -X POST 'http://localhost:5173/{bizSeq}/{menu}/{res}' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer {token}' \
  -d '{"bizSeq":1, "pageSize":20, "offset":0}'
```

응답 JSON 을 받아 루트 키 추출.

### 4. 대조 항목

| 항목 | 기준 | 실제 |
| --- | --- | --- |
| 응답 루트 키 | `post{Resource}s` | (JSON 최상위 키) |
| 리스트 원소 필드 | 80-spec Response | 첫 원소 키 목록 |
| HTTP 상태 | 200 | 실제 코드 |
| 에러 포맷 (200 외) | `{message, code}` | 실제 body |

### 5. 리포트

```
## {MENU} 런타임 검증

dev_url: http://localhost:5173
bizSeq: 1
synced_at: 2026-04-17

### 호출 결과

| Interface ID | HTTP | 루트 키 | 기준 루트 | 결과 |
| --- | --- | --- | --- | --- |
| MDCT01_POST_CONTS | 200 | postConts | postConts | OK |
| MDCT01_GET_CONT  | 200 | cont | cont | OK |

### 필드 불일치

- MDCT01_POST_CONTS · 실제 원소에 `contStsCd` 없음 (80-spec 에는 있음)
  → 원인: BE 최신 변경 후 80-spec 산출물이 갱신되지 않았을 가능성. BE 산출물 재생성 권고.

### 제안

- BE 저장소에서 80-spec 산출물 재생성
- 변화 있으면 /util-verify-menu mdct01 재실행
```

문제 없으면 `{MENU} 런타임 통과` 한 줄만.

## 주의

- 호출 결과(JSON 본문)는 보고에 가능한 한 싣지 말 것 — 고객 데이터일 수 있음. 루트 키/필드 이름만 비교.
- 인증 토큰은 보고에 절대 기록 X.
- 실제 데이터가 없어 결과가 빈 배열이면 "데이터 없음, 필드 검증 스킵" 명시.
- 여러 메뉴 연속 검증 시에도 쓰기 API 는 자동 호출 금지.
