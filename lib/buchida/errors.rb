# frozen_string_literal: true

module Buchida
	class Error < StandardError
		attr_reader :status_code, :code

		def initialize(message, status_code, code = nil)
			super(message)
			@status_code = status_code
			@code = code
		end
	end

	class AuthenticationError < Error
		def initialize(message = "Invalid API key")
			super(message, 401, "authentication_error")
		end
	end

	class RateLimitError < Error
		def initialize(message = "Rate limit exceeded")
			super(message, 429, "rate_limit_error")
		end
	end

	class NotFoundError < Error
		def initialize(message = "Resource not found")
			super(message, 404, "not_found")
		end
	end

	class ValidationError < Error
		def initialize(message = "Validation failed")
			super(message, 422, "validation_error")
		end
	end
end
