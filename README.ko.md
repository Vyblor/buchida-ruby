<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>CJK 지원을 갖춘 개발자 중심 이메일 API</strong></p>

  [English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

[buchida](https://buchida.com) 이메일 API의 공식 Ruby SDK입니다.

## 설치

```bash
gem install buchida
```

또는 Gemfile에 추가:

```ruby
gem "buchida"
```

## 빠른 시작

```ruby
require "buchida"

client = Buchida::Client.new("bc_live_xxxxxxxxxxxxxxxxxxxxx")

result = client.emails.send(
  from: "hello@yourdomain.com",
  to: "user@example.com",
  subject: "buchida에 오신 것을 환영합니다!",
  html: "<h1>안녕하세요!</h1><p>가입을 환영합니다.</p>"
)

puts "이메일 발송 완료: #{result['id']}"
```

## 주요 기능

- Ruby 3.2+
- 의존성 없음 (표준 라이브러리 `net/http`)
- 타입 기반 에러 처리

## 문서

- [빠른 시작 가이드](https://buchida.com/ko/docs/quickstart)
- [API 레퍼런스](https://buchida.com/ko/docs/sending-email)
- [GitHub](https://github.com/Vyblor/buchida-ruby)

## 라이선스

MIT
