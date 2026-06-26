---
title: AES-256 개인정보 암호화 패턴
description: CryptoTool을 이용해 개인정보 필드를 AES-256으로 암호화/복호화하는 방법. post_no·addr·addr_dtl·tel·ceo_nm 등 처리 방식 포함.
status: active
version: 1.0.0
author: binaryarc
repo_role: be
agent_usage: reference
tags:
  - be
  - crypto
  - aes256
  - personal-info
last_verified: 2026-06-26
---

# AES-256 개인정보 암호화 패턴

## CryptoTool 개요

| 항목 | 값 |
|---|---|
| 알고리즘 | AES/CBC/PKCS7Padding (BouncyCastle) |
| 키 도출 | PBKDF2WithHmacSHA1, salt=20byte, 70,000회 반복, 256bit |
| 초기화 위치 | `fw/config/SecurityConfig.java` — `cryptoTool()` @Bean |
| 설정 키 | `aes.alg`, `aes.key`, `aes.iv` (application-{profile}.properties, 🔒 평문 노출 금지) |
| 클래스 경로 | `fw/tool/CryptoTool.java` |

```java
// SecurityConfig.java
@Value("${aes.key}") String aesKey;
@Value("${aes.iv}")  String aesIv;

@Bean
public CryptoTool cryptoTool() {
    return new CryptoTool(aesAlg, aesKey, aesIv);
}
```

---

## 암호화 / 복호화 API

```java
// 암호화: String → byte[]
byte[] encrypted = CryptoTool.encryptAES256(plainText);

// 복호화: byte[] → String
String plain = CryptoTool.decryptAES256(encrypted);
```

- 입력이 null/empty이면 암호화는 `null`, 복호화는 `""` 반환
- DB 저장 타입: **PostgreSQL `bytea`**

---

## 암호화 대상 필드

| 필드 | 원본 테이블/타입 | 암호화 저장 컬럼/타입 | 처리 위치 |
|---|---|---|---|
| `post_no` (우편번호) | MDM_CONT varchar | SHOP_CONT `post_no` bytea | `SHPD01TxComp.ensureShopContFromMdmCont()` |
| `addr` (주소) | MDM_CONT varchar | SHOP_CONT `addr` bytea | 동일 |
| `addr_dtl` (주소상세) | MDM_CONT varchar | SHOP_CONT `addr_dtl` bytea | 동일 |
| `tel` (전화번호) | 회원가입·사용자관리 | SM_USER `tel_encrypt` bytea | `SignupComp`, `MDUS01Comp` |
| `ceo_nm` (대표자명) | ERP→OMS 거래처 연동 | MDM_CONT `ceo_nm` bytea | `MDCT01ErpRegComp`, `MDCT01ErpRegDao` |

---

## SHOP_CONT 보정 등록 패턴 (post_no·addr·addr_dtl)

MDM_CONT(ERP DB, varchar 평문) 데이터를 SHOP_CONT(OMS DB, bytea 암호화)로 복사 등록할 때 암호화한다.

```java
// SHPD01TxComp.java — ensureShopContFromMdmCont()
if (EmptyTool.notEmpty(mdmCont.getPostNo())) {
    mdmCont.setPostNoEncrypt(CryptoTool.encryptAES256(mdmCont.getPostNo()));
}
if (EmptyTool.notEmpty(mdmCont.getAddr())) {
    mdmCont.setAddrEncrypt(CryptoTool.encryptAES256(mdmCont.getAddr()));
}
if (EmptyTool.notEmpty(mdmCont.getAddrDtl())) {
    mdmCont.setAddrDtlEncrypt(CryptoTool.encryptAES256(mdmCont.getAddrDtl()));
}
```

DTO 구조 (`SHPD01ShopCont.java`):

```java
private String postNo;         // MDM_CONT에서 읽은 평문
private String addr;
private String addrDtl;
private byte[] postNoEncrypt;  // 암호화 후 SHOP_CONT에 저장
private byte[] addrEncrypt;
private byte[] addrDtlEncrypt;
```

---

## 복호화 패턴

복호화는 주로 **Bean 생성자 또는 Dao 조회 직후**에 처리한다.

```java
// Bean 생성자에서 즉시 복호화 (MDCT01Cont.java 등)
public MDCT01Cont(...) {
    this.ceoNm = CryptoTool.decryptAES256(ceoNmEncrypt);
}

// Dao 조회 직후 복호화 (MDUS01Dao.java)
retUser.setTel(CryptoTool.decryptAES256(retUser.getTelEncrypt()));
```

---

## NEVER

- `aes.key`, `aes.iv` 값을 코드·로그·문서에 평문으로 기록하지 않는다.
- 암호화 없이 `bytea` 컬럼에 직접 평문 varchar를 저장하지 않는다.
- `encryptAES256()` 결과인 `byte[]`를 String으로 캐스팅하지 않는다 (데이터 손상).
