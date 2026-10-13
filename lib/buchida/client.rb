# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Buchida
	class Client
		DEFAULT_BASE_URL = "https://api.buchida.com/v1"
		DEFAULT_TIMEOUT = 30

		attr_reader :emails, :domains, :api_keys, :webhooks, :templates, :metrics

		def initialize(api_key, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT)
			raise ArgumentError, "API key is required" if api_key.nil? || api_key.empty?

			@api_key = api_key
			@base_url = base_url.chomp("/")
			@timeout = timeout

			@emails = Resources::Emails.new(self)
			@domains = Resources::Domains.new(self)
			@api_keys = Resources::ApiKeys.new(self)
			@webhooks = Resources::Webhooks.new(self)
			@templates = Resources::Templates.new(self)
			@metrics = Resources::Metrics.new(self)
		end

		def request(method, path, body = nil)
			uri = URI("#{@base_url}#{path}")

			req = case method
			when :get then Net::HTTP::Get.new(uri)
			when :post then Net::HTTP::Post.new(uri)
			when :delete then Net::HTTP::Delete.new(uri)
			else raise ArgumentError, "Unsupported method: #{method}"
			end

			req["Authorization"] = "Bearer #{@api_key}"
			req["Content-Type"] = "application/json"
			req["User-Agent"] = "buchida-ruby/#{VERSION}"
			req.body = JSON.generate(body) if body

			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = uri.scheme == "https"
			http.open_timeout = @timeout
			http.read_timeout = @timeout

			response = http.request(req)

			unless response.is_a?(Net::HTTPSuccess) || response.code == "204"
				handle_error(response)
			end

			return nil if response.code == "204" || response.body.nil? || response.body.empty?

			JSON.parse(response.body)
		end

		# Request returning a single object: unwraps `{ "data" => {...} }` (204 => nil).
		def request_object(method, path, body = nil)
			unwrap_object(request(method, path, body))
		end

		# Request returning a list: unwraps `{ "data" => [...], "cursor" =>, "hasMore" => }`.
		def request_list(method, path, body = nil)
			resp = request(method, path, body)
			if resp.is_a?(Hash)
				ListResult.new(resp["data"] || [], cursor: resp["cursor"], has_more: resp["hasMore"] || resp["has_more"] || false)
			elsif resp.is_a?(Array)
				ListResult.new(resp)
			else
				resp
			end
		end

		private

		def unwrap_object(resp)
			return resp unless resp.is_a?(Hash)

			inner = resp.key?("data") ? resp["data"] : resp
			inner.is_a?(Hash) ? Result[inner] : inner
		end

		def handle_error(response)
			body = begin
				JSON.parse(response.body)
			rescue
				{ "message" => response.message }
			end

			err = body["error"]
			if err.is_a?(Hash)
				message = err["message"] || response.message
				error_code = err["code"]
			else
				message = body["message"] || response.message
				error_code = body["code"]
			end
			status = response.code.to_i

			case status
			when 401 then raise AuthenticationError, message
			when 404 then raise NotFoundError, message
			when 422 then raise ValidationError, message
			when 429 then raise RateLimitError, message
			else raise Error.new(message, status, error_code)
			end
		end
	end
end
