<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>支持CJK的开发者优先邮件API</strong></p>

  [English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

[buchida](https://buchida.com)邮件API的官方Ruby SDK。

## 安装

```bash
gem install buchida
```

或添加到Gemfile:

```ruby
gem "buchida"
```

## 快速开始

```ruby
require "buchida"

client = Buchida::Client.new("bc_live_xxxxxxxxxxxxxxxxxxxxx")

result = client.emails.send(
  from: "hello@yourdomain.com",
  to: "user@example.com",
  subject: "欢迎使用buchida！",
  html: "<h1>你好！</h1><p>欢迎加入。</p>"
)

puts "邮件发送成功: #{result['id']}"
```

## 特性

- Ruby 3.2+
- 零依赖（标准库`net/http`）
- 类型化错误处理

## 文档

- [快速开始](https://buchida.com/zh/docs/quickstart)
- [API参考](https://buchida.com/zh/docs/sending-email)
- [GitHub](https://github.com/Vyblor/buchida-ruby)

## 许可证

MIT
