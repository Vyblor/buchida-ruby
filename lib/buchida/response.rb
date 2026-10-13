# frozen_string_literal: true

module Buchida
	# Deprecation helper for the pre-0.2 raw-envelope access (`res["data"]`).
	module Legacy
		@warned = false

		def self.warn_once(what)
			return if @warned

			@warned = true
			Kernel.warn("[buchida] DEPRECATION: #{what} is deprecated. Since buchida 0.2 the SDK " \
				"returns the unwrapped payload; use the result directly.")
		end

		def self.data_key?(key)
			key == "data" || key == :data
		end
	end

	# An unwrapped single-object response (a Hash with String keys, as before).
	# `result["data"]` / `result[:data]` still return the same object, with a one-time
	# deprecation warning, so code written against the raw `{ "data" => {...} }` envelope keeps working.
	# No self-reference is stored, so `to_json` / `JSON.generate` are unaffected.
	class Result < Hash
		REAL_KEY = Hash.instance_method(:key?)

		def [](key)
			if Legacy.data_key?(key) && !REAL_KEY.bind(self).call("data")
				Legacy.warn_once("result[\"data\"]")
				return self
			end
			super
		end

		def key?(key)
			Legacy.data_key?(key) || super
		end
		alias_method :has_key?, :key?
		alias_method :include?, :key?
		alias_method :member?, :key?

		def fetch(key, *args, &block)
			if Legacy.data_key?(key) && !REAL_KEY.bind(self).call("data")
				Legacy.warn_once("result.fetch(\"data\")")
				return self
			end
			super
		end

		def dig(key, *rest)
			value = self[key]
			rest.empty? || value.nil? ? value : value.dig(*rest)
		end
	end

	# An unwrapped list response: an Array of items plus `cursor` and `has_more`.
	# The old envelope keys (`res["data"]`, `res["cursor"]`, `res["hasMore"]`) still work, with a
	# one-time deprecation warning.
	class ListResult < Array
		attr_reader :cursor, :has_more

		def initialize(items = [], cursor: nil, has_more: false)
			super(items)
			@cursor = cursor
			@has_more = has_more
		end

		def data
			self
		end

		def has_more?
			@has_more ? true : false
		end

		LEGACY_KEYS = %w[data cursor hasMore has_more].freeze

		def self.legacy_key?(key)
			(key.is_a?(String) || key.is_a?(Symbol)) && LEGACY_KEYS.include?(key.to_s)
		end

		def key?(key)
			ListResult.legacy_key?(key)
		end
		alias_method :has_key?, :key?

		def include?(item)
			ListResult.legacy_key?(item) || super
		end

		def fetch(key, *args, &block)
			return self[key] if ListResult.legacy_key?(key)

			super
		end

		def dig(key, *rest)
			if ListResult.legacy_key?(key)
				value = self[key]
				return rest.empty? || value.nil? ? value : value.dig(*rest)
			end

			super
		end

		def [](*args)
			key = args.first
			if args.length == 1 && (key.is_a?(String) || key.is_a?(Symbol))
				case key.to_s
				when "data" then (Legacy.warn_once("list[\"data\"]"); return self)
				when "cursor" then (Legacy.warn_once("list[\"cursor\"]"); return @cursor)
				when "hasMore", "has_more" then (Legacy.warn_once("list[\"hasMore\"]"); return @has_more)
				end
				return nil
			end
			super
		end
	end
end
