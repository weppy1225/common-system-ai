# AI 협업 워크플로우

## 1. 작업 전 체크리스트

- [ ] `00-overview.md` 의 "작업 전 필수 확인 순서" 를 따랐는가?
- [ ] 수정 대상 메뉴의 `60-menus/{업무군}-{메뉴코드}.md` 가 존재하면 읽었는가?
- [ ] 비슷한 기능이 `assets/js/common.js` / `components/` 에 이미 있는지 검색했는가?
- [ ] BE 변경이 필요하면 `C:\zinide\cloud-wms-be\DEV_DOC\ai-docs` 를 함께 확인했는가?

## 2. 금지사항

### 코드
- **새 유틸 함수 금지** — `EmptyTool`, `DateTool`, `IconTool`, `OptionTool`, `searchRef` 등 기존 헬퍼를 먼저 쓴다.
- **새 Z\* 컴포넌트 금지** — `ZText`, `ZSelect`, `ZCodeSelect`, `ZCodeMulti`, `ZBtn*`, `ZAuiGrid`, `ZCellBox` 등 조합으로 해결.
- **swal 직접 호출 금지** — `errorSwal`, `successSwal`, `confirmSwal`, `noSelectSwal`, `oneSelectSwal` 래퍼 사용.
- **axios 공통코드/사업장 호출 금지** — `commCdStore.convertCommDNms`, `bizCenterStore.convertBizCenterNms` 사용.
- **영어 주석으로 치환 금지** — 기존 한글 주석 유지. 신규 주석도 한글.

### Git
- 커밋 메시지는 **한글**로 작성
- 커밋 메시지에 `Co-Authored-By` / AI 작성 표기 **포함 금지**
- 커밋 `--no-verify` 금지

### 범위
- 요청에 없는 리팩토링, 스타일 정리, import 정렬 변경 금지
- "잠깐, 이것도 같이 고치면 좋겠다" 판단은 사용자에게 먼저 묻는다

## 3. 응답 포맷

작업 완료 후 응답은 다음 형식으로:

```
수정 파일:
- src/views/be/md8000/mdct01/mdct01.vue:153
- src/views/be/md8000/mdct01/mdct01Edt.vue:42

변경 요약:
- 그리드에 repContNm 컬럼 추가
- commCdList에 REP_CONT_CD → repContNm 변환 항목 추가
```

- 긴 설명 금지. 불릿 2-5줄로 끝.
- 변경 이유가 비자명할 때만 간단히 덧붙인다.

## 4. 검증 명령어

UI/로직 수정 후 다음을 실행해 회귀를 확인:

```bash
npm run lint        # ESLint - 반드시 통과
npm run test:unit   # 관련 단위테스트가 있으면
npm run dev:dev     # 브라우저 확인 (사용자가 요청할 때만)
```

- 타입/린트 통과 ≠ 기능 정상. UI 변경은 사용자에게 브라우저 확인을 요청.

## 5. 빌드 모드

- `dev` / `test` / `prod` 3모드. 각 모드에 `.env.*` 존재.
- 모드별 API baseURL 이 달라지므로 하드코딩 금지. `loginStore.baseUrl` 사용.
