# frozen_string_literal: true

module Buchida
	module Resources
		class Metrics
			def initialize(client)
				@client = client
			end

			def get(from:, to:, granularity: nil)
				params = { from: from, to: to }
				params[:granularity] = granularity if granularity
				qs = URI.encode_www_form(params)
				@client.request(:get, "/metrics?#{qs}")
			end
		end
	end
end
