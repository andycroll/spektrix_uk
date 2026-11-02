# frozen_string_literal: true

require "json"

module SpektrixUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads a venue's events and instances from the public Spektrix API v3,
    # which needs no token. Each venue's Spektrix account is its client.
    class Api
      BASE_URL = "https://system.spektrix.com"
      READ_TIMEOUT = 120

      # @param [String] client the Spektrix client name, e.g. 'tynesidecinema'
      def initialize(client)
        @client = client
        @http = Cinebase::Http.new(read_timeout: READ_TIMEOUT)
      end

      # Events with an instance starting within the range
      # @param [Date] from first day
      # @param [Date] to the day after the last, as the API reads a date as
      #   its midnight
      # @return [Array<Hash>]
      def events(from, to)
        get_json("events", instanceStart_from: from.iso8601, instanceStart_to: to.iso8601)
      end

      # Instances, or performances, starting within the range
      # @param [Date] from first day
      # @param [Date] to the day after the last
      # @return [Array<Hash>]
      def instances(from, to)
        get_json("instances", startFrom: from.iso8601, startTo: to.iso8601)
      end

      private

      def get_json(resource, query)
        JSON.parse(@http.get("#{BASE_URL}/#{@client}/api/v3/#{resource}?#{URI.encode_www_form(query)}"))
      end
    end
  end
end
