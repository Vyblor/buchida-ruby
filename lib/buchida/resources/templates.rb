# frozen_string_literal: true

module Buchida
	module Resources
		class Templates
			def initialize(client)
				@client = client
			end

			def list
				@client.request_list(:get, "/templates")
			end

			def get(id)
				@client.request_object(:get, "/templates/#{id}")
			end
		end
	end
end
