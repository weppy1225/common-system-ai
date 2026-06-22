---
title: Controller 작성규칙
description: {MenuCode}Controller 클래스 선언·메서드 패턴·파라미터 어노테이션·응답 처리 코드 예시를 코드 작성 시 참조
status: active
version: 1.0.0
repo_role: ai-hub
agent_usage: instruction
domain: backend
tags:
  - controller
  - rest-api
  - mockmvc
  - pathvariable
  - requestbody
related:
  - patterns/30-backend/30-convention/01-coding-convention.md
last_verified: 2026-04-07
---

# Controller 작성규칙 ({MenuCode}Controller Writing Rules)

> **규칙 참조**: 클래스 어노테이션·URL 설계·예외 처리·메서드 네이밍 등 일반 규칙은
> [30-convention/01-coding-convention.md](../30-convention/01-coding-convention.md) 참조.
> 이 문서는 Controller 레이어 작성 시 참고할 **실제 코드 패턴·예시**만 기술합니다.

## 1. 개요

- **패키지**: `be.{메뉴그룹_인스턴스}.{메뉴코드_인스턴스}`
- **컨트롤러명**: `{메뉴코드}Controller`
- **역할**: HTTP 요청/응답 처리 및 API 엔드포인트 제공 (비즈니스 로직은 `{메뉴코드}Comp`에 위임)
- **기본 경로**: `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}`

## 2. 클래스 선언 예시

```java
@Validated
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Slf4j
@RequestMapping("/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}")
public class {메뉴코드}Controller {
    private final {메뉴코드}Comp {메뉴코드_인스턴스}Comp;
}
```

> 어노테이션 의무·금지 사항은 컨벤션 §3 참조.

## 3. 메서드 작성 패턴

### 3.1 공통 로깅 패턴

```java
log.info(FwPool.CONTROLLER_START_LOG);
log.debug(String.format(LOG_FORM, "paramName", paramValue));
// ... Comp 호출 ...
log.info(FwPool.CONTROLLER_END_LOG);
```

### 3.2 목록 조회 (POST + @RequestBody)

```java
@PostMapping
public ResponseEntity<{메뉴코드}Response> search{리소스}s(
        @RequestBody {메뉴코드}Search search) {
    log.info(FwPool.CONTROLLER_START_LOG);
    GsonTool.printBean(search);
    {메뉴코드}Response response = {메뉴코드_인스턴스}Comp.search{리소스}s(search);
    log.info(FwPool.CONTROLLER_END_LOG);
    return ResponseEntity.ok(response);
}
```

### 3.3 단건 조회 (GET + @PathVariable)

```java
@GetMapping("{seq}")
public ResponseEntity<{메뉴코드}Response> select{리소스}(
        @PathVariable Integer seq) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.select{리소스}(seq));
}

// 계층적 URI
@GetMapping("label/{labelPaperTypeCd}")
@GetMapping("label/{labelPaperTypeCd}/{labelPaperSeq}")
```

### 3.4 등록 (파일 포함)

```java
@PostMapping("/insert")
public ResponseEntity<{메뉴코드}Response> insert{리소스}(
        @Valid {메뉴코드}{리소스} {리소스_소문자},
        @RequestPart(required = false) MultipartFile file) {
    return ResponseEntity.status(HttpStatus.CREATED)
                         .body({메뉴코드_인스턴스}Comp.insert{리소스}({리소스_소문자}, file));
}
```

### 3.5 수정 (파일 포함)

```java
@PostMapping("/update")
public ResponseEntity<{메뉴코드}Response> update{리소스}(
        @Valid {메뉴코드}{리소스} update{리소스},
        @RequestPart(required = false) MultipartFile file) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.update{리소스}(update{리소스}, file));
}
```

### 3.6 삭제 (다건)

```java
@DeleteMapping
public ResponseEntity<{메뉴코드}Response> delete{리소스}s(
        @PathVariable Integer bizSeq,
        @RequestParam List<Integer> seqs) {
    return ResponseEntity.ok({메뉴코드_인스턴스}Comp.delete{리소스}s(bizSeq, seqs));
}
```

## 4. 파라미터 어노테이션 사용 예

| 타입 | 어노테이션 | 사용처 |
|------|------------|---------|
| 단일 경로변수 | `@PathVariable Integer prodSeq` | 단일 조회 |
| 다중 경로변수 | `@PathVariable("bizSeq") Integer bizSeq` | 변수명 다른 경우 |
| 검색 조건 | `@RequestBody {메뉴코드}Search` | POST 검색 |
| 등록/수정 데이터 | `@Valid {메뉴코드}{리소스}` | 유효성 검증 필요 |
| 파일 | `@RequestPart(required = false) MultipartFile` | 파일 업로드 |
| 쿼리 파라미터 | `@RequestParam List<Integer> {리소스}Seqs` | 다중 삭제 등 |

> **유효성 검증**: 클래스 레벨 `@Validated` 필수. 등록·수정 데이터는 `@Valid` 명시. 기존 Controller에 누락된 경우도 미준수 레거시로 보고, 해당 파일 수정 시 함께 보완한다.

## 5. 응답 처리 예시

### 5.1 HTTP Status

| 상황 | Status | 사용 메서드 |
|------|---------|-------------|
| 조회 / 수정 / 삭제 성공 | 200 OK | `ResponseEntity.ok(response)` |
| 등록 성공 | 201 CREATED | `ResponseEntity.status(HttpStatus.CREATED).body(response)` |

### 5.2 응답 DTO

```java
public class {메뉴코드}Response extends ResponseData {
    private List<{메뉴코드}Search> post{리소스}s; // 목록 조회 결과
    private {메뉴코드}{리소스}     {리소스_소문자}; // 단건 조회 결과
    // procCnt, warn, systemError 등은 ResponseData 상속
}
```

## 6. API 엔드포인트 예시 목록

| Method | URL | 기능 |
|--------|-----|------|
| POST | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}` | 목록 검색 |
| POST | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/insert` | 단건 등록 (파일) |
| GET | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/{seq}` | 단건 조회 |
| POST | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}/update` | 단건 수정 (파일) |
| DELETE | `/{bizSeq}/{메뉴코드_인스턴스}/{리소스_소문자}` | 다중 삭제 |

> URL 설계 규칙은 컨벤션 §4 참조.

## 7. 메서드 JavaDoc 템플릿 (퍼블릭 메서드 필수)

```java
/**
 * {리소스} 목록 조회
 *
 * @param bizSeq 사업장 seq
 * @param search 검색 조건
 * @return 목록 조회 결과
 */
@PostMapping
public ResponseEntity<ResponseData> search{리소스}s(
        @PathVariable Integer bizSeq,
        @RequestBody {메뉴코드}Search search) { ... }
```

> `@author` / `@version` 작성 금지. 첫 줄 설명 + `@param` + `@return` 만 작성. 기존 JavaDoc에 남아 있는 `@author` / `@version`도 미준수 레거시이므로, 해당 파일 수정 시 제거한다.

## 8. 작성 시 주의사항

1. **PathVariable 변수명 매칭**: `@PathVariable("bizSeq")`처럼 명시적 지정 필요
2. **파일 업로드**: `@RequestPart` + `required=false`
3. **다중 삭제**: `@RequestParam List<Integer>`, 빈 리스트 처리 고려
4. **로그 레벨**: 정보성은 info, 상세 데이터는 debug
5. **비즈니스 로직 금지**: Controller는 HTTP 처리만 담당, 모든 로직은 `{메뉴코드}Comp`에 위임
