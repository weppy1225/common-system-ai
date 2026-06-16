# 80-backend-contracts

BE(`cloud-wms-be`) 스펙의 **FE 소비용 스냅샷**. 원본은 BE 저장소에 있고, 여기엔 요약만 둔다.

## 1. 정체성

- 원본(source of truth): `C:\zinide\cloud-wms-be\DEV_DOC\ai-docs\`
  - 메뉴 스펙: `20-backend/80-spec/{menu-lower}/spec.md`, `{YYYYMMDD}_output.md`
  - API 상세: `20-backend/90-api/20-detail/{menu-lower}-{method}-{res}.md`
- 이 디렉토리: FE AI 가 BE 저장소를 매번 크롤링하지 않도록, **엔드포인트·응답 네이밍·비즈니스 규칙**만 요약 보관.
- 원본과 요약이 어긋나면 **원본이 항상 우선**. 요약은 힌트일 뿐.

## 2. 디렉토리 레이아웃

```
80-backend-contracts/
├─ _README.md           ← 지금 이 문서 (정책)
├─ _index.md            ← 메뉴코드 → BE 경로 매핑표
└─ {menu-lower}/        ← 메뉴별 폴더 (ex: stdc01, mdct01)
   ├─ _meta.yml         ← source_files / source_hash / synced_at / menu_code
   ├─ endpoints.md      ← FE 소비용 5섹션 요약
   └─ business-rules.md ← BE spec.md §6 (비즈니스 규칙) 발췌
```

폴더명은 **소문자**, 문서 내 메뉴코드는 **대문자** (`STDC01`). BE 규칙과 일치.

## 3. 갱신 주체

- 이 디렉토리는 **`70-prompts/74-sync-be-spec.md` 프롬프트만이 쓴다**.
- 수기 편집 금지. 요약을 고쳐야 할 상황이면 BE 원본을 먼저 고치고 74 를 다시 돌린다.
- 새 메뉴 추가/삭제 시에도 74 가 `_index.md` 를 갱신.

## 4. 커밋 정책

- BE 동기화 커밋은 **FE 기능 커밋과 분리**. 혼합 금지.
- 커밋 메시지 예: `docs: BE 스펙 동기화 (stdc01, mdct01)` — 한글, AI 표기 없음.
- 동기화가 메뉴 여러 개면 한 커밋에 묶어도 됨. 단, 코드 변경과는 섞지 않음.

## 5. 삭제된 메뉴 처리

- BE 에서 없어진 메뉴는 `{menu-lower}/` 폴더를 **통째로 삭제** + `_index.md` 에서 제거.
- 삭제 기록은 남기지 않음 (git log 가 단일 소스).

## 6. FE 작업 흐름 요약

1. 메뉴 작업 착수 → `_index.md` 에서 메뉴 확인.
2. 없으면 `70-prompts/74-sync-be-spec.md` 로 동기화.
3. `{menu-lower}/endpoints.md` 읽고 FE 코드 작업.
4. 작업 후 `70-prompts/76-verify-menu-contract.md` 로 정합성 확인.
5. 의심 시 `70-prompts/77-run-menu-check.md` 로 live 응답과 대조.

상세 컨벤션: `../20-conventions/24-backend-spec-consumption.md`.
