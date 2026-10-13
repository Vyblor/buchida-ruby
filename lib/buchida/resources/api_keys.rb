# frozen_string_literal: true

module Buchida
	module Resources
		class ApiKeys
			def initialize(client)
				@client = client
			end

			def create(name:, permission:)
				@client.request_object(:post, "/api-keys", { name: name, permission: permission })
			end

			def list
				@client.request_list(:get, "/api-keys")
			end

			def delete(id)
				@client.request(:delete, "/api-keys/#{id}")
			end
		end
	end
end
