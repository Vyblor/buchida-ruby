<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>CJKサポートを備えた開発者向けメールAPI</strong></p>

  [English](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

[buchida](https://buchida.com)メールAPIの公式Ruby SDKです。

## インストール

```bash
gem install buchida
```

またはGemfileに追加:

```ruby
gem "buchida"
```

## クイックスタート

```ruby
require "buchida"

client = Buchida::Client.new("bc_live_xxxxxxxxxxxxxxxxxxxxx")

result = client.emails.send(
  from: "hello@yourdomain.com",
  to: "user@example.com",
  subject: "buchidaへようこそ！",
  html: "<h1>こんにちは！</h1><p>ご登録ありがとうございます。</p>"
)

puts "メール送信完了: #{result['id']}"
```

## 特徴

- Ruby 3.2+
- 依存関係ゼロ（標準ライブラリ`net/http`）
- 型付きエラーハンドリング

## ドキュメント

- [クイックスタート](https://buchida.com/ja/docs/quickstart)
- [APIリファレンス](https://buchida.com/ja/docs/sending-email)
- [GitHub](https://github.com/Vyblor/buchida-ruby)

## ライセンス

MIT
