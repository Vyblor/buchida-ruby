# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require_relative "../lib/buchida"

class TestBuchidaClient < Minitest::Test
	BASE_URL = "https://api.buchida.com"

	def setup
		@client = Buchida::Client.new("bc_test_xxx")
	end

	def test_requires_api_key
		assert_raises(ArgumentError) { Buchida::Client.new("") }
		assert_raises(ArgumentError) { Buchida::Client.new(nil) }
	end

	def test_custom_base_url
		client = Buchida::Client.new("bc_test_xxx", base_url: "https://custom.api.com")
		stub_request(:get, "https://custom.api.com/domains").to_return(
			status: 200, body: "[]", headers: { "Content-Type" => "application/json" }
		)
		client.domains.list
		assert_requested(:get, "https://custom.api.com/domains")
	end

	# ── Emails ──────────────────────────────────────────────────────────

	def test_emails_send
		stub_request(:post, "#{BASE_URL}/emails").to_return(
			status: 200,
			body: '{"id":"email_123"}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.send(
			from: "hi@buchida.com",
			to: "user@example.com",
			subject: "Hello",
			html: "<p>Hi</p>"
		)
		assert_equal "email_123", result["id"]
	end

	def test_emails_get
		stub_request(:get, "#{BASE_URL}/emails/email_123").to_return(
			status: 200,
			body: '{"id":"email_123","from":"hi@buchida.com","to":["user@example.com"],"subject":"Hello","status":"delivered","createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.get("email_123")
		assert_equal "delivered", result["status"]
	end

	def test_emails_list
		stub_request(:get, /#{BASE_URL}\/emails/).to_return(
			status: 200,
			body: '{"data":[],"cursor":null}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.list(limit: 10, status: "delivered")
		assert_kind_of Hash, result
	end

	def test_emails_cancel
		stub_request(:post, "#{BASE_URL}/emails/email_123/cancel").to_return(status: 204, body: "")
		@client.emails.cancel("email_123")
		assert_requested(:post, "#{BASE_URL}/emails/email_123/cancel")
	end

	def test_emails_send_batch
		stub_request(:post, "#{BASE_URL}/emails/batch").to_return(
			status: 200,
			body: '[{"id":"email_1"},{"id":"email_2"}]',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.send_batch([
			{ from: "hi@buchida.com", to: "a@example.com", subject: "A" },
			{ from: "hi@buchida.com", to: "b@example.com", subject: "B" }
		])
		assert_equal 2, result.length
	end

	# ── Domains ─────────────────────────────────────────────────────────

	def test_domains_create
		stub_request(:post, "#{BASE_URL}/domains").to_return(
			status: 200,
			body: '{"id":"dom_1","name":"example.com","status":"pending","records":[],"createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.domains.create(name: "example.com")
		assert_equal "example.com", result["name"]
	end

	def test_domains_list
		stub_request(:get, "#{BASE_URL}/domains").to_return(
			status: 200, body: "[]", headers: { "Content-Type" => "application/json" }
		)
		result = @client.domains.list
		assert_kind_of Array, result
	end

	def test_domains_verify
		stub_request(:post, "#{BASE_URL}/domains/dom_1/verify").to_return(
			status: 200,
			body: '{"id":"dom_1","name":"example.com","status":"verified","records":[],"createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.domains.verify("dom_1")
		assert_equal "verified", result["status"]
	end

	# ── API Keys ────────────────────────────────────────────────────────

	def test_api_keys_create
		stub_request(:post, "#{BASE_URL}/api-keys").to_return(
			status: 200,
			body: '{"id":"key_1","name":"test","key":"bc_live_newkey","permission":"full_access","createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.api_keys.create(name: "test", permission: "full_access")
		assert_equal "bc_live_newkey", result["key"]
	end

	def test_api_keys_delete
		stub_request(:delete, "#{BASE_URL}/api-keys/key_1").to_return(status: 204, body: "")
		@client.api_keys.delete("key_1")
		assert_requested(:delete, "#{BASE_URL}/api-keys/key_1")
	end

	# ── Webhooks ────────────────────────────────────────────────────────

	def test_webhooks_create
		stub_request(:post, "#{BASE_URL}/webhooks").to_return(
			status: 200,
			body: '{"id":"wh_1","url":"https://example.com/wh","events":["email.delivered"],"createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.webhooks.create(url: "https://example.com/wh", events: ["email.delivered"])
		assert_equal "wh_1", result["id"]
	end

	# ── Templates ───────────────────────────────────────────────────────

	def test_templates_list
		stub_request(:get, "#{BASE_URL}/templates").to_return(
			status: 200, body: "[]", headers: { "Content-Type" => "application/json" }
		)
		result = @client.templates.list
		assert_kind_of Array, result
	end

	def test_templates_get
		stub_request(:get, "#{BASE_URL}/templates/tpl_1").to_return(
			status: 200,
			body: '{"id":"tpl_1","name":"Welcome","createdAt":"2026-03-31T00:00:00Z"}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.templates.get("tpl_1")
		assert_equal "Welcome", result["name"]
	end

	# ── Metrics ─────────────────────────────────────────────────────────

	def test_metrics_get
		stub_request(:get, /#{BASE_URL}\/metrics/).to_return(
			status: 200,
			body: '{"sent":100,"delivered":95,"opened":50,"clicked":10,"bounced":3,"complained":1,"timeseries":[]}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.metrics.get(from: "2026-03-01", to: "2026-03-31", granularity: "day")
		assert_equal 100, result["sent"]
	end

	# ── Error Handling ──────────────────────────────────────────────────

	def test_401_raises_authentication_error
		stub_request(:get, "#{BASE_URL}/emails").to_return(
			status: 401, body: '{"message":"Invalid API key"}'
		)
		assert_raises(Buchida::AuthenticationError) { @client.emails.list }
	end

	def test_429_raises_rate_limit_error
		stub_request(:get, "#{BASE_URL}/emails").to_return(
			status: 429, body: '{"message":"Rate limit exceeded"}'
		)
		assert_raises(Buchida::RateLimitError) { @client.emails.list }
	end

	def test_500_raises_error
		stub_request(:get, "#{BASE_URL}/emails").to_return(
			status: 500, body: '{"message":"Internal server error"}'
		)
		assert_raises(Buchida::Error) { @client.emails.list }
	end
end
