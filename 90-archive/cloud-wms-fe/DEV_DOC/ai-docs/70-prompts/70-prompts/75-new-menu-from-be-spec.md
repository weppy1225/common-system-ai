# 프롬프트: BE 스펙 기반 신규 메뉴 생성

이미 BE 가 구현·문서화한 메뉴에 대해 FE 스켈레톤을 생성. `70-new-crud-menu.md` 의 BE-aware 확장판.

## 사전 조건

- BE 원본: FE 저장소 기준 `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/` 존재.
- 필요 시 `../cloud-wms-be/DEV_DOC/ai-docs/20-backend/90-api/20-detail/{menu}-*.md` 보조 참고.
- 참조 규약: `20-conventions/24-backend-spec-consumption.md`, `10-architecture/13-be-fe-contract.md`.

## 복사용 프롬프트

```
BE 스펙 기반으로 [메뉴코드] 프론트 메뉴를 만들어줘.

(업무군·리소스명은 80-spec 산출물과 FE 라우터에서 도출)
```

## 작업 절차

### 1. BE 원본 확인

`../cloud-wms-be/DEV_DOC/ai-docs/20-backend/80-spec/{menu}/` 아래 산출물을 확인한다.
- 우선순위: `{YYYYMMDD}_output.md` 최신 > `output.md` > `spec.md`.
- 없으면 중단하고 사용자에게 안내.

### 2. 80-spec 산출물 파싱

추출 대상:
- **업무군 코드** (`iv3000`, `md8000` 등) — router, 80-spec 본문, `00-overview.md` 업무군 코드 맵 순서로 도출.
- **리소스명** — API URL 의 복수형 (`/stdc01/stsets` → `stsets`, 변수명 루트는 `stset`).
- **메서드별 URL** — 리스트/단건/등록/수정/삭제.
- **복합키 순서** — `{resourceSeq}/{bizSeq}`.
- **응답 네이밍** — `res.data.post{Resource}s` 예상 키.

### 3. dev-fe-menu 명령 위임

`.claude/commands/dev-fe-menu.md` 의 절차를 실행한다:

```
/dev-fe-menu <메뉴코드>
예: /dev-fe-menu stdc01
```

이 명령이 생성하는 파일:
- `src/views/be/{업무군}/{메뉴}/{메뉴}.vue`
- `src/views/be/{업무군}/{메뉴}/{메뉴}Edt.vue`

### 4. BE 스펙 반영 포인트

dev-fe-menu 구현에 BE 스펙에서 얻은 정보를 실제로 꽂아 넣어야 함:

| 위치 | BE 스펙에서 가져올 것 |
| --- | --- |
| `initSearch{Resource}Obj` | 80-spec Request 의 검색 조건 필드 |
| 그리드 컬럼 `dataField` | 80-spec Response 의 리스트 원소 필드 |
| `initEdit{Resource}Obj` | 80-spec 등록/수정 Request 필드 |
| URL 상수 | 80-spec API 목록 (FE URL 로 변환, `regBizSeq` 제외) |
| `commCdList` | BE `spec.md` §6 비즈니스 규칙에 언급된 공통코드 (있는 경우) |

없는 정보는 **TODO 주석**으로 남기고 사용자에게 보고. 추측으로 채우지 않음.

### 5. 메뉴 문서 생성

`60-menus/{업무군}/{메뉴코드}/menu.md` 를 `60-menus/_template.md` 복사로 생성. 채울 섹션:

- §2 화면 구성 — 실제로 생성한 .vue 파일 경로.
- §3 API 매핑 — 80-spec API 목록과 일치.
- §9 BE 동기화: `- 최근 동기화: {오늘 날짜}` + BE 원본 링크.

프롬프트 본문 복사 금지 — 기존 규칙대로 링크만 (`mdct01` 참고).

### 6. 자기 검증

생성 직후 **`/util-verify-menu <메뉴코드>`** 를 호출. 결과가 "감사 통과" 가 아니면 리포트에 불일치 테이블을 첨부하고 수정 없이 사용자 확인 요청.

### 7. 완료 보고

```
수정 파일:
- src/views/be/iv3000/stdc01/stdc01.vue (신규)
- src/views/be/iv3000/stdc01/stdc01Edt.vue (신규)
- DEV_DOC/ai-docs/60-menus/iv3000/stdc01/menu.md (신규)

변경 요약:
- BE 80-spec(`../cloud-wms-be/.../80-spec/stdc01`) 기반 스켈레톤 생성
- API 2건 (POST /stdc01/stsets, POST /stdc01/stsets/process) 연결
- util-verify-menu: 감사 통과 / 불일치 N건 (별첨)

후속 (수동):
- src/router/modules/be/iv3000.js 에 라우트 등록
- 메뉴 DB 등록
```

## 주의

- 라우팅·메뉴 DB 등록은 이 프롬프트 범위 밖. 반드시 보고에 명시.
- BE 스펙에 없는 필드/로직은 **추측 금지** — TODO 주석.
- 80-spec 산출물과 실제 코드가 어긋나면 80-spec 산출물이 기준.
