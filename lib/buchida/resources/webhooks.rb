# frozen_string_literal: true

module Buchida
	module Resources
		class Webhooks
			def initialize(client)
				@client = client
			end

			def create(url:, events:)
				@client.request_object(:post, "/webhooks", { url: url, events: events })
			end

			def list
				@client.request_list(:get, "/webhooks")
			end

			def delete(id)
				@client.request(:delete, "/webhooks/#{id}")
			end
		end
	end
end
