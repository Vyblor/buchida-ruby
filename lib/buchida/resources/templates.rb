# frozen_string_literal: true

module Buchida
	module Resources
		class Templates
			def initialize(client)
				@client = client
			end

			def list
				@client.request(:get, "/templates")
			end

			def get(id)
				@client.request(:get, "/templates/#{id}")
			end
		end
	end
end
