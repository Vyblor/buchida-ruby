# frozen_string_literal: true

module Buchida
	module Resources
		class Metrics
			def initialize(client)
				@client = client
			end

			def get(from:, to:, granularity: nil)
				# The API filters on from_date/to_date; plain from/to were silently ignored.
				params = { from_date: from, to_date: to }
				params[:granularity] = granularity if granularity
				qs = URI.encode_www_form(params)
				@client.request_object(:get, "/metrics?#{qs}")
			end
		end
	end
end
