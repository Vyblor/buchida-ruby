# buchida

Official Ruby SDK for the [buchida](https://buchida.com) email API.

## Installation

```ruby
gem "buchida"
```

## Quick Start

```ruby
require "buchida"

client = Buchida::Client.new("bc_live_xxxxxxxxxxxxxxxxxxxxx")

result = client.emails.send(
  from: "hello@yourdomain.com",
  to: "user@example.com",
  subject: "Welcome to buchida!",
  html: "<h1>Hello!</h1><p>Welcome aboard.</p>"
)

puts "Email sent: #{result['id']}"
```

## Features

- Ruby 3.2+
- Zero dependencies (stdlib `net/http`)
- Typed error handling

## Error Handling

```ruby
begin
  client.emails.send(...)
rescue Buchida::AuthenticationError => e
  # 401 - invalid API key
rescue Buchida::RateLimitError => e
  # 429 - too many requests
rescue Buchida::Error => e
  # Other API errors
  puts "#{e.status_code}: #{e.message}"
end
```

## License

MIT
