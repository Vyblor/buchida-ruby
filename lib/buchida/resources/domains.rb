# frozen_string_literal: true

module Buchida
	module Resources
		class Domains
			def initialize(client)
				@client = client
			end

			def create(name:)
				@client.request(:post, "/domains", { name: name })
			end

			def list
				@client.request(:get, "/domains")
			end

			def get(id)
				@client.request(:get, "/domains/#{id}")
			end

			def verify(id)
				@client.request(:post, "/domains/#{id}/verify")
			end
		end
	end
end
