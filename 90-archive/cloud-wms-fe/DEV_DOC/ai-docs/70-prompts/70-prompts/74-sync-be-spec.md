# 프롬프트: BE 80-spec 기반 FE 메뉴 문서 동기화

BE(`../cloud-wms-be`) 80-spec 원본을 직접 읽어 `60-menus/{group}/{menu}/menu.md` 의 API 매핑과 동기화 정보를 생성·갱신한다.

## 사전 규약

- 경로·네이밍·우선순위는 `20-conventions/24-backend-spec-consumption.md` 단일 소스를 따른다.
- 별도 FE 캐시 산출물을 생성하지 않는다. FE 작업은 BE 80-spec 원본을 직접 소비한다.
- Vue 파일·router·store 는 수정하지 않는다.
- 자동 커밋 금지. 변경 리포트만 제시하고 사용자 확인 후 커밋.

## 복사용 프롬프트

```
BE 스펙을 동기화해줘: [메뉴코드1] [메뉴코드2] ...

(생략 시: DEV_DOC/ai-docs/60-menus/ 의 모든 메뉴 재확인)
```

## 작업 절차

### 1. 대상 확정

- 인자가 있으면 그 메뉴코드만 (소문자 변환).
- 없으면 `DEV_DOC/ai-docs/60-menus/{group}/{menu}/menu.md` 구조에서 메뉴코드 목록 추출.
- 메뉴코드 형식 검증: `^[a-z]{4}\d{2}$`. 미일치면 사용자에게 다시 물어봄.

### 2. BE 원본 수집

메뉴당 다음 경로에서 존재하는 파일만 수집:

1. `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/*.md`
   - 우선순위: `{YYYYMMDD}_output.md` (최신일자) > `output.md` > `spec.md`.
   - `ui.md` 는 화면 구성 힌트로 참고 가능.
   - `plan.md`, `task.md`, `db.md` 는 FE 메뉴 문서 동기화에는 사용하지 않음.
2. 필요 시 `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/90-api/20-detail/{menu}-*.md` 를 보조 참고.

한 파일도 없으면 **해당 메뉴는 스킵**하고 리포트에 "BE 원본 없음" 기록.

### 3. FE 메뉴 문서 경로 결정

- 기존 `DEV_DOC/ai-docs/60-menus/{group}/{menu}/menu.md` 가 있으면 해당 파일을 갱신.
- 없으면 `60-menus/_template.md` 기반으로 신규 생성.
- `{group}` 은 router, 80-spec 본문, `00-overview.md` 업무군 코드 맵 순서로 도출.
- 업무군 판단 불가 시 사용자에게 확인 요청.

### 4. 갱신 범위

다음 섹션만 갱신하고 나머지는 유지한다:

| 섹션 | 갱신 내용 |
| --- | --- |
| §3 API 매핑 | 80-spec API 목록 기준. FE URL 은 `regBizSeq` 제외. |
| §4 사용 공통코드 | 80-spec 에서 확인된 commHCd. 기존 항목 삭제 금지, 추가만. |
| §9 BE 동기화 | `최근 동기화: {오늘 날짜}`, BE 원본 경로 링크 갱신. |

BE API URL 에서 FE URL 로 변환:
- `/{bizSeq}/{menuCode}/{res}` → `/{menuCode}/{res}`.
- 단건 복합키 URL 의 `/{resourceSeq}/{bizSeq}` path variable 은 유지.

### 5. 리포트 출력

```
## BE 스펙 동기화 결과

| 메뉴 | 상태 | 문서 경로 | 변경 내용 |
| --- | --- | --- | --- |
| STDC01 | 갱신 | 60-menus/iv3000/stdc01/menu.md | §3 API 2건, §9 날짜 |
| MDCT01 | 변경 없음 | 60-menus/md8000/mdct01/menu.md | - |
| XXXX01 | BE 원본 없음 | - | 스킵 |

다음 단계:
- 변경된 메뉴에 대해 `/util-verify-menu {메뉴코드}` 실행 권장.
- 커밋은 분리: `docs: BE 스펙 동기화 (STDC01)`.
```

## 주의

- BE 저장소가 없거나 경로 접근 불가: 스킵 + 사용자에게 "BE 저장소 확인 필요" 안내. 크래시 X.
- 한글 주석/규칙은 **그대로 유지**. 영문 치환 금지 (`CLAUDE.md` 규칙).
- 파일 수가 많아도 변경분만 씀. 동일 해시면 파일 재작성 금지 (git diff 오염 방지).
