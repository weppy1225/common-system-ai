---
name: PI_fe_list
description: FE 검색·목록 화면({메뉴코드}.vue)만 생성. /PI_fe_list {메뉴코드}
when_to_use: "FE 목록 화면 만들어줘", "검색 그리드 개발해줘", "목록 vue 만들어줘" 요청 시 사용.
argument-hint: "[메뉴코드]"
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: claude-sonnet-4-6
---

# FE 검색조건·결과목록 화면 개발 [PI_fe_list]

BE spec.md 기반으로 `{메뉴코드}.vue` 목록 화면을 생성한다. 기본형은 목록 + `{메뉴코드}Edt` 연결이지만, 실제 FE 표본처럼 `mdbz01Sch.vue`/`mdbz01Set.vue` 분리나 `Ivst01Edt`/`Ivst01Proc`/`Ivst01Cancel`/`Ivst01ProcCancel`/`Ivst01ReqInvenMove` 같은 다중 팝업 연결도 고려한다.

## 사용법

```
/PI_fe_list {메뉴코드}
예: /PI_fe_list mdct01
```

## 실행 절차

### STEP 1. 레포 경로 결정 (BLOCKING)

스킬은 AI 허브(`common-system-ai`)에서 실행된다. `.claude/rules/repo-paths.md` 규칙으로 `$AI_DIR`(AI 허브)·`$FE_DIR`(생성 대상 FE 레포)를 결정한다.
- FE 코드 생성: `$FE_DIR/src/views/...` 절대경로로 생성
- 패턴·가이드 문서: `$AI_DIR/patterns/...`, `$AI_DIR/spec/$PROJECT/...` 절대경로 사용

### STEP 2. API 명세 확인

경로: `$AI_DIR/spec/$PROJECT/{메뉴코드}/{메뉴코드}-05-api.md`

파일이 없으면 `-06-be-flow.md` 또는 `-07-fe-flow.md` 를 확인한다.
그래도 없으면 사용자에게 spec 파일 경로를 직접 묻는다.

### STEP 3. spec 파싱 (목록 화면에 필요한 항목만)

- 업무군 코드 (예: `rt2000`, `md8000`)
- 리소스명 (camelCase, 예: `cont`)
- 리스트 조회 API URL 및 응답 네이밍 (`postXxx`)
- 검색 조건 필드 목록
- 결과 그리드 컬럼 목록
- 사용 공통코드 (`commHCd` 목록)

업무군 코드를 spec에서 찾을 수 없으면 `$AI_DIR/spec/$PROJECT/_knowledge/patterns/fe/01-router-menu-register.md`(프로젝트 고유 맵, 있을 때) 또는 공통 `$AI_DIR/patterns/40-frontend/10-architecture/03-menu-registration.md` 의 업무군 파일 예시를 참조한다.

### STEP 4. 목록 화면 생성

기준 템플릿: `$AI_DIR/patterns/40-frontend/20-convention/02-file-template.md` §1

**파일 위치:** `src/views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue`

**구조 (순서 준수):**
```
<style scoped lang="scss"></style>

<template>
  <SearchSection>
    <template #btn>검색/초기화 버튼</template>
    <ZCellBox>검색조건 ZCell 목록</ZCellBox>
  </SearchSection>

  <ContentSection>
    <div class="content-warpper">
      <div class="content-header">버튼 영역</div>
      <div class="content-body">
        <ZAuiGrid ref="xxxGrid" ...></ZAuiGrid>
      </div>
    </div>
  </ContentSection>

  <!-- 팝업 컴포넌트 (실제 FE 파일 확인 후 연결) -->
  <{메뉴코드}Edt ref="editPopup" .../>
  <{메뉴코드}Sch ref="searchPopup" .../>
  <{메뉴코드}Set ref="setPopup" .../>
  <Ivst01Proc ref="procPopup" .../>
</template>

<script setup>
// import 순서: 3rd > 컴포넌트 > 팝업 > store > gfn > 변수선언
</script>
```

**검색 조건 컴포넌트 매핑:**

| spec 타입 | 컴포넌트 |
|---|---|
| 사업장 | `ZSelect :items="searchBizList"` |
| 물류센터 | `ZSelect :items="searchCenterList"` |
| 공통코드 (단수) | `ZCodeSelect commCd="XXX_CD"` |
| 공통코드 (복수) | `ZCodeMulti commCd="XXX_CD"` |
| 텍스트 | `ZText v-model="..."` |
| 날짜 범위 | `ZCalendarRange v-model:from="..." v-model:to="..."` |
| 날짜 단일 | `ZCalendar v-model="..."` |
| 거래처 팝업 | `ZContPopup v-model="..." :callback="lfn_contCallback"` |
| 품목 팝업 | `ZProdPopup :callback="lfn_prodCallback" v-model="..."` |

**그리드 컬럼 스타일:**

| 데이터 성격 | style |
|---|---|
| 좌측 정렬 (텍스트) | `style: 'gridTxt-l'` |
| 중앙 정렬 (코드) | `style: 'gridTxt-c'` (기본) |
| 우측 정렬 (숫자) | `style: 'gridTxt-r'` |
| 숫자 포맷 | `dataType: 'numeric', formatString: '#,##0'` |
| 날짜 포맷 | `dataType: 'date', formatString: 'yyyy-mm-dd'` |

**코드 규칙:**

- `axios.post(url, searchObj.value)` → `res.data.post{Resources}`
- `commCdStore.convertCommDNms(commCdList, data)` 로 공통코드 변환
- `bizCenterStore.convertBizCenterNms(data)` 로 사업장명 변환
- 조회 실패 시 `grid.clearGridData()` + `errorSwal(error)`
- `onActivated`에서 `OptionTool.getSearchOption(route.meta.menuCd)` 로 bizSeq 변경 감지
- `searchRef({ ...initXxxObj.deepCopy() })` 패턴
- `noSelectSwal()`, `oneSelectSwal()` 사용
- `vfn_` 접두사: view 로컬 함수, `lfn_` 접두사: 모듈 내부 함수
- 영어 주석 금지 — 한글 유지
- `regBizSeq` URL 하드코딩 금지
- 팝업 연결 전제는 고정하지 말고 실제 FE 디렉터리의 파일명을 먼저 확인한다
- 기본형: `{메뉴코드}Edt`
- 변형형: `{메뉴코드}Sch`(검색), `{메뉴코드}Set`(설정)
- 다중 업무 팝업형: `Ivst01Proc`, `Ivst01Cancel`, `Ivst01ProcCancel`, `Ivst01ReqInvenMove`처럼 화면별 보조 팝업을 여러 개 import 가능

### STEP 5. 완료 보고

```
생성 파일:
  src/views/be/{업무군}/{메뉴코드}/{메뉴코드}.vue

API 연결:
  리스트: POST /{메뉴코드}/{리소스}s

후속 수동 작업:
  - 실제 확인한 팝업 파일 생성: /PI_fe_edit {메뉴코드}
  - router.js 라우트 등록
  - 메뉴 DB 등록
```

## 주의사항

- BE spec에 없는 정보는 추측 말고 `// TODO:` 주석으로 표시
- 팝업까지 동시에 필요하면 `/PI_fe_all` 사용
- BE 저장소(`$BE_DIR`) 파일은 읽기만 함, 수정 금지
