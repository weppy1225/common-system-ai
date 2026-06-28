---
description: 코드·문서·커밋에 DB 접속정보·JWT Secret·API Key·운영 설정값·고객 데이터 등 민감정보가 포함되는 것을 방지하는 규칙. OMS 도메인 전 고객사에 적용. 항상 로딩한다.
---

# OMS 보안 규칙 (민감정보 노출 방지)

> OMS 도메인 전 고객사 프로젝트에 적용한다. 고객사별 경로(`$BE_NAME`, `$FE_NAME`) 도출 → `.claude/rules/repo-paths.md`.
> 항상 로딩(`paths` 생략) — 모든 작업에 예외 없이 적용되는 규칙이기 때문.

## 1. 절대 포함 금지 대상 (NEVER)

| 유형 | 예시 |
|---|---|
| DB 접속정보 | `jdbc:postgresql://...`, `jdbc:sqlserver://...`, 실제 호스트·포트·DB명, username/password |
| JWT Secret | HS256/RS256 비밀키, 서명 키 바이트 |
| API Key / Token | 외부 시스템(ERP·WMS·TMS) API 키, Access/Refresh Token |
| 암호화 키 | Jasypt master password, AES key, RSA 개인키 |
| 운영 설정값 | `application-prod.properties` 실제 값, 운영 호스트/포트 |
| 고객 데이터 | 실제 가맹점·거래처·주문 데이터, 개인정보 |
| 인증 정보 | 운영 계정 ID/PW, SSH 키, SSL 인증서 개인키 |

## 2. 허용 패턴 (SHOULD)

- `application-{profile}.properties` 에는 **키만 정의**, 값은 비우거나 치환 변수 사용.
- 문서·예시 코드의 자격증명은 `PLACEHOLDER`, `<your-token>`, `1111` 같은 더미 값 사용.
- 운영(`prod`) 프로파일은 Jasypt 암호화(`ENC(...)`) 문자열만 저장.

## 3. 커밋 전 체크리스트

- [ ] `grep -rE "(password|secret|token|api[_-]?key)\s*[:=]" {$BE_NAME}/src {$FE_NAME}/src` 로 평문 노출 스캔
- [ ] `.env`, `*credentials*`, `*.pem`, `*.key` staging 여부 확인
- [ ] 테스트 데이터에 실제 고객사·거래처·주문 데이터·개인정보 포함 여부 확인
- [ ] 로그(`log.info` 등)에 토큰·비밀번호 출력 여부 확인

## 4. 위반 발견 시

1. 즉시 커밋에서 제거(`git reset`).
2. 이미 push 된 경우: 해당 비밀값 **즉시 폐기·재발급**(히스토리 제거해도 캐시 잔존 가능).
3. 영향 범위 보고: 언제부터 노출, 어떤 시스템 영향.

## 5. 관련 파일 (프로젝트별 경로)

- `{$BE_NAME}/src/main/resource/prop/application-{profile}.properties` — 프로파일별 설정(실제 값 기재 금지)
- `{$FE_NAME}/.env.*` — FE 환경 변수(시크릿 미포함 원칙)
