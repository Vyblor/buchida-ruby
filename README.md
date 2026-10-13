<div align="center">
  <img src="assets/logo-black.svg" alt="buchida" width="280" />
  <p><strong>buchida Ruby SDK — Email API for AI agents</strong></p>

  [**English**](README.md) | [한국어](README.ko.md) | [日本語](README.ja.md) | [中文](README.zh.md)

  [![Gem version](https://img.shields.io/gem/v/buchida)](https://rubygems.org/gems/buchida) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

buchida is the official Ruby SDK for **buchida** — an email API built for AI agents. buchida ships a CLI, an MCP server, and SDKs in 5 languages (Node, Python, Go, Ruby, Java), all sharing the same REST API surface. `@buchida/email` templates render Korean, Japanese, and Chinese natively.

## Install

```bash
gem install buchida
```

## Send your first email

```ruby
require 'buchida'

client = Buchida::Client.new(ENV['BUCHIDA_API_KEY'])

result = client.emails.send(
  from: 'hello@yourapp.com',
  from_name: 'Your App',
  to: 'user@example.com',
  subject: 'Hello',
  html: '<h1>Welcome</h1>'
)
puts result['id'], result['status'] # unwrapped payload (Hash with String keys)

# Lists are Arrays with #cursor / #has_more
page = client.emails.list(limit: 20)
page.each { |e| puts e['id'] }
next_page = client.emails.list(cursor: page.cursor) if page.has_more

# Batch: one result per input, each with "data" or "error"
client.emails.send_batch([
  { from: 'hello@yourapp.com', to: 'a@example.com', subject: 'A', text: 'hi' }
]).each { |r| puts(r['data'] || r['error']) }
```

## Upgrading to 0.2

- The API wraps responses in `{ "data" => ... }`; the SDK now returns the unwrapped payload.
  `emails.send` / `get`, `domains.create` / `get` / `verify`, `api_keys.create`,
  `webhooks.create`, `templates.get` and `metrics.get` return the object Hash (`result['id']`);
  `emails.list`, `emails.send_batch` and the other `list` methods return an Array
  (`#cursor` / `#has_more` on paged lists; batch entries are Hashes with `'data'` or `'error'`).
- Backwards compatible: `result['data']` / `result[:data]` on objects, and `page['data']`,
  `page['cursor']`, `page['hasMore']` on lists still work, but print a one-time deprecation
  warning. Migrate to the unwrapped form; the shim will be removed in a future major version.
- Request bodies now use snake_case (`reply_to`, `scheduled_at`) and `from_name` is supported.
  API errors with a nested `{ "error": { "code", "message" } }` body are surfaced correctly.

## Documentation

Full docs: **[buchida.com/docs](https://buchida.com/docs)**

- API reference: https://buchida.com/docs/api-reference
- Quickstart guide: https://buchida.com/docs/quickstart
- CJK email templates: https://buchida.com/docs/templates
- MCP server setup: https://buchida.com/docs/mcp
- CLI reference: https://buchida.com/docs/cli

## Links

- **Website:** [buchida.com](https://buchida.com)
- **Documentation:** [buchida.com/docs](https://buchida.com/docs)
- **Pricing:** [buchida.com/pricing](https://buchida.com/pricing)
- **GitHub:** https://github.com/Vyblor/buchida-ruby

## License

MIT
