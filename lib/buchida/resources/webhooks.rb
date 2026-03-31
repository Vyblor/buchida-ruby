# frozen_string_literal: true

module Buchida
	module Resources
		class Webhooks
			def initialize(client)
				@client = client
			end

			def create(url:, events:)
				@client.request(:post, "/webhooks", { url: url, events: events })
			end

			def list
				@client.request(:get, "/webhooks")
			end

			def delete(id)
				@client.request(:delete, "/webhooks/#{id}")
			end
		end
	end
end
