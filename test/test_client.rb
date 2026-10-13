# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require_relative "../lib/buchida"

class TestBuchidaClient < Minitest::Test
	BASE_URL = "https://api.buchida.com/v1"

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
			status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" }
		)
		client.domains.list
		assert_requested(:get, "https://custom.api.com/domains")
	end

	# ── Emails ──────────────────────────────────────────────────────────

	def test_emails_send
		stub_request(:post, "#{BASE_URL}/emails").to_return(
			status: 200,
			body: '{"data":{"id":"email_123"}}',
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
			body: '{"data":{"id":"email_123","from":"hi@buchida.com","from_name":"Vyblor","to":["user@example.com"],"subject":"Hello","status":"delivered","created_at":"2026-03-31T00:00:00Z"}}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.get("email_123")
		assert_equal "delivered", result["status"]
		assert_equal "Vyblor", result["from_name"]
		assert_equal "2026-03-31T00:00:00Z", result["created_at"]
	end

	def test_emails_list
		stub_request(:get, /#{BASE_URL}\/emails/).to_return(
			status: 200,
			body: '{"data":[{"id":"e1"},{"id":"e2"}],"cursor":"c2","hasMore":true}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.list(limit: 10, status: "delivered")
		assert_kind_of Array, result
		assert_equal %w[e1 e2], result.map { |e| e["id"] }
		assert_equal "c2", result.cursor
		assert_equal true, result.has_more
		assert_same result, result.data
	end

	def test_emails_list_legacy_envelope_access
		stub_request(:get, /#{BASE_URL}\/emails/).to_return(
			status: 200,
			body: '{"data":[{"id":"e1"}],"cursor":"c2","hasMore":true}',
			headers: { "Content-Type" => "application/json" }
		)

		result = nil
		_out, err = capture_io { result = @client.emails.list }
		assert_equal "", err
		Buchida::Legacy.instance_variable_set(:@warned, false)
		_out, err = capture_io do
			assert_equal "e1", result["data"][0]["id"]
			assert_equal "c2", result["cursor"]
			assert_equal true, result["hasMore"]
			assert_equal "e1", result[:data].first["id"]
		end
		assert_equal 1, err.scan("DEPRECATION").length
	end

	def test_emails_send_legacy_data_access
		stub_request(:post, "#{BASE_URL}/emails").to_return(
			status: 200, body: '{"data":{"id":"email_123"}}'
		)
		result = @client.emails.send(from: "a@b.com", to: "c@d.com", subject: "s", text: "t")
		Buchida::Legacy.instance_variable_set(:@warned, false)
		_out, err = capture_io do
			assert_equal "email_123", result["data"]["id"]
			assert_equal "email_123", result[:data]["id"]
		end
		assert_match(/DEPRECATION/, err)
		assert_equal '{"id":"email_123"}', JSON.generate(result)
		assert_equal({ "id" => "email_123" }, result.to_h)
	end

	def test_emails_cancel
		stub_request(:post, "#{BASE_URL}/emails/email_123/cancel").to_return(status: 204, body: "")
		@client.emails.cancel("email_123")
		assert_requested(:post, "#{BASE_URL}/emails/email_123/cancel")
	end

	def test_emails_send_batch
		stub_request(:post, "#{BASE_URL}/emails/batch").to_return(
			status: 200,
			body: '{"data":[{"data":{"id":"email_1","status":"queued"}},{"error":{"code":"invalid_email_address","message":"bad to"}}]}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.emails.send_batch([
			{ from: "hi@buchida.com", to: "a@example.com", subject: "A" },
			{ from: "hi@buchida.com", to: "b@example.com", subject: "B" }
		])
		assert_equal 2, result.length
		assert_equal "email_1", result[0]["data"]["id"]
		assert_nil result[0]["error"]
		assert_equal "invalid_email_address", result[1]["error"]["code"]
	end

	# ── Domains ─────────────────────────────────────────────────────────

	def test_domains_create
		stub_request(:post, "#{BASE_URL}/domains").to_return(
			status: 200,
			body: '{"data":{"id":"dom_1","name":"example.com","status":"pending","dns_records":[{"type":"TXT"}],"created_at":"2026-03-31T00:00:00Z"}}',
			headers: { "Content-Type" => "application/json" }
		)

		result = @client.domains.create(name: "example.com")
		assert_equal "example.com", result["name"]
	end

	def test_domains_list
		stub_request(:get, "#{BASE_URL}/domains").to_return(
			status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" }
		)
		result = @client.domains.list
		assert_kind_of Array, result
	end

	def test_domains_verify
		stub_request(:post, "#{BASE_URL}/domains/dom_1/verify").to_return(
			status: 200,
			body: '{"data":{"id":"dom_1","name":"example.com","status":"verified","dns_records":[{"type":"TXT"}],"created_at":"2026-03-31T00:00:00Z"}}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.domains.verify("dom_1")
		assert_equal "verified", result["status"]
	end

	# ── API Keys ────────────────────────────────────────────────────────

	def test_api_keys_create
		stub_request(:post, "#{BASE_URL}/api-keys").to_return(
			status: 200,
			body: '{"data":{"id":"key_1","name":"test","key":"bc_live_newkey","permission":"full_access","created_at":"2026-03-31T00:00:00Z"}}',
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
			body: '{"data":{"id":"wh_1","url":"https://example.com/wh","events":["email.delivered"],"created_at":"2026-03-31T00:00:00Z"}}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.webhooks.create(url: "https://example.com/wh", events: ["email.delivered"])
		assert_equal "wh_1", result["id"]
	end

	# ── Templates ───────────────────────────────────────────────────────

	def test_templates_list
		stub_request(:get, "#{BASE_URL}/templates").to_return(
			status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" }
		)
		result = @client.templates.list
		assert_kind_of Array, result
	end

	def test_templates_get
		stub_request(:get, "#{BASE_URL}/templates/tpl_1").to_return(
			status: 200,
			body: '{"data":{"id":"tpl_1","name":"Welcome","created_at":"2026-03-31T00:00:00Z"}}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.templates.get("tpl_1")
		assert_equal "Welcome", result["name"]
	end

	# ── Metrics ─────────────────────────────────────────────────────────

	def test_metrics_get
		stub_request(:get, /#{BASE_URL}\/metrics/).to_return(
			status: 200,
			body: '{"data":{"sent":100,"delivered":95,"opened":50,"clicked":10,"bounced":3,"complained":1,"timeseries":[]}}',
			headers: { "Content-Type" => "application/json" }
		)
		result = @client.metrics.get(from: "2026-03-01", to: "2026-03-31", granularity: "day")
		assert_equal 100, result["sent"]
		assert_requested(:get, %r{/metrics\?from_date=2026-03-01&.*to_date=2026-03-31})
	end

	def test_domains_get_snake_case_fields
		stub_request(:get, "#{BASE_URL}/domains/dom_1").to_return(
			status: 200, body: '{"data":{"id":"dom_1","name":"example.com","created_at":"2026-03-31T00:00:00Z","dns_records":[]}}'
		)
		d = @client.domains.get("dom_1")
		assert_equal "2026-03-31T00:00:00Z", d["created_at"]
		assert_equal [], d["dns_records"]
	end

	def test_emails_send_uses_snake_case_keys
		stub = stub_request(:post, "#{BASE_URL}/emails")
			.with { |req|
				b = JSON.parse(req.body)
				b["from_name"] == "Vyblor" && b["reply_to"] == "s@buchida.com" &&
					b["scheduled_at"] == "2026-12-01T00:00:00Z" &&
					!b.key?("replyTo") && !b.key?("scheduledAt")
			}
			.to_return(status: 200, body: '{"id":"email_123"}')

		@client.emails.send(
			from: "hi@buchida.com", from_name: "Vyblor", to: "u@example.com", subject: "Hi",
			reply_to: "s@buchida.com", scheduled_at: "2026-12-01T00:00:00Z"
		)
		assert_requested(stub)
	end

	# ── Error Handling ──────────────────────────────────────────────────

	def test_nested_error_message
		stub_request(:post, "#{BASE_URL}/emails").to_return(
			status: 422, body: '{"error":{"code":"validation_error","message":"from_name is invalid"}}'
		)
		err = assert_raises(Buchida::ValidationError) do
			@client.emails.send(from: "a@b.com", to: "c@d.com", subject: "x")
		end
		assert_equal "from_name is invalid", err.message
	end

	def test_nested_error_code_on_generic_error
		stub_request(:get, "#{BASE_URL}/emails").to_return(
			status: 500, body: '{"error":{"code":"internal_error","message":"boom"}}'
		)
		err = assert_raises(Buchida::Error) { @client.emails.list }
		assert_equal "boom", err.message
		assert_equal "internal_error", err.code
	end

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

	# ── Legacy envelope compatibility ───────────────────────────────────

	def test_result_legacy_key_predicates
		r = Buchida::Result.new
		r["id"] = "e1"
		[:key?, :include?, :has_key?, :member?].each do |m|
			assert r.public_send(m, "data"), m
			assert r.public_send(m, :data), m
			assert r.public_send(m, "id"), m
			refute r.public_send(m, "nope"), m
		end
		capture_io { assert_same r, r["data"] }
		assert_same r, r.fetch("data")
	end

	def test_list_result_legacy_access
		l = Buchida::ListResult.new([{ "id" => "e1" }], cursor: "c2", has_more: true)
		capture_io do
			assert_same l, l.fetch("data")
			assert_equal "c2", l.fetch("cursor")
			assert_equal true, l.fetch("hasMore")
			assert_equal "e1", l.dig("data", 0, "id")
			assert_equal "c2", l.dig("cursor")
			assert_equal({ "id" => "e1" }, l.dig(0))
		end
		%w[data cursor hasMore].each { |k| assert l.key?(k), k }
		assert l.key?(:data)
		assert l.include?("hasMore")
		refute l.key?("other")
		assert l.include?({ "id" => "e1" })
	end
end
