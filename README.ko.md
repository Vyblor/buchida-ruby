<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>buchida Ruby SDK — AI 에이전트를 위한 이메일 API</strong></p>

  [English](README.md) | [**한국어**](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

buchida는 AI 에이전트를 위해 만들어진 이메일 API의 공식 Ruby SDK입니다. buchida는 CLI, MCP 서버, 그리고 5개 언어 SDK (Node, Python, Go, Ruby, Java)를 제공하며, 모두 동일한 REST API 표면을 공유합니다. `@buchida/email` 템플릿은 한국어, 일본어, 중국어를 네이티브로 렌더링합니다.

## 설치

```bash
gem install buchida
```

## 첫 이메일 보내기

```ruby
require 'buchida'

Buchida.api_key = ENV['BUCHIDA_API_KEY']

Buchida::Emails.send(
  from: 'hello@yourapp.com',
  to: 'user@example.com',
  subject: '안녕하세요',
  html: '<h1>환영합니다</h1>'
)
```

## 문서

전체 문서: **[buchida.com/docs](https://buchida.com/docs)**

- API 레퍼런스: https://buchida.com/docs/api-reference
- 빠른 시작 가이드: https://buchida.com/docs/quickstart
- CJK 이메일 템플릿: https://buchida.com/docs/templates
- MCP 서버 설정: https://buchida.com/docs/mcp
- CLI 레퍼런스: https://buchida.com/docs/cli

## 링크

- **웹사이트:** [buchida.com](https://buchida.com)
- **문서:** [buchida.com/docs](https://buchida.com/docs)
- **요금제:** [buchida.com/pricing](https://buchida.com/pricing)
- **GitHub:** https://github.com/Vyblor/buchida-ruby

## 라이선스

MIT
