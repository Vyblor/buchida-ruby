<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>buchida Ruby SDK — 为 AI 代理打造的邮件 API</strong></p>

  [English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [**中文**](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

buchida 是为 AI 代理打造的邮件 API 的官方 Ruby SDK。buchida 提供 CLI、MCP 服务器和 5 种语言的 SDK (Node、Python、Go、Ruby、Java),所有这些都共享相同的 REST API 表面。`@buchida/email` 模板原生渲染韩语、日语和中文。

## 安装

```bash
gem install buchida
```

## 发送您的第一封邮件

```ruby
require 'buchida'

Buchida.api_key = ENV['BUCHIDA_API_KEY']

Buchida::Emails.send(
  from: 'hello@yourapp.com',
  to: 'user@example.com',
  subject: '你好',
  html: '<h1>欢迎</h1>'
)
```

## 文档

完整文档: **[buchida.com/docs](https://buchida.com/docs)**

- API 参考: https://buchida.com/docs/api-reference
- 快速入门指南: https://buchida.com/docs/quickstart
- CJK 邮件模板: https://buchida.com/docs/templates
- MCP 服务器设置: https://buchida.com/docs/mcp
- CLI 参考: https://buchida.com/docs/cli

## 链接

- **网站:** [buchida.com](https://buchida.com)
- **文档:** [buchida.com/docs](https://buchida.com/docs)
- **定价:** [buchida.com/pricing](https://buchida.com/pricing)
- **GitHub:** https://github.com/Vyblor/buchida-ruby

## 许可证

MIT
