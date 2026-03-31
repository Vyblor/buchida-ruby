# frozen_string_literal: true

module Buchida
	module Resources
		class Emails
			def initialize(client)
				@client = client
			end

			def send(from:, to:, subject:, html: nil, text: nil, reply_to: nil, cc: nil, bcc: nil, tags: nil, scheduled_at: nil)
				body = { from: from, to: to, subject: subject }
				body[:html] = html if html
				body[:text] = text if text
				body[:replyTo] = reply_to if reply_to
				body[:cc] = cc if cc
				body[:bcc] = bcc if bcc
				body[:tags] = tags if tags
				body[:scheduledAt] = scheduled_at if scheduled_at
				@client.request(:post, "/emails", body)
			end

			def get(id)
				@client.request(:get, "/emails/#{id}")
			end

			def list(cursor: nil, limit: nil, status: nil, from: nil, to: nil)
				params = {}
				params[:cursor] = cursor if cursor
				params[:limit] = limit if limit
				params[:status] = status if status
				params[:from] = from if from
				params[:to] = to if to
				qs = URI.encode_www_form(params) unless params.empty?
				path = qs ? "/emails?#{qs}" : "/emails"
				@client.request(:get, path)
			end

			def cancel(id)
				@client.request(:post, "/emails/#{id}/cancel")
			end

			def send_batch(emails)
				@client.request(:post, "/emails/batch", emails)
			end
		end
	end
end
