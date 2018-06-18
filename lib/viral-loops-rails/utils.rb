require 'json'
require 'active_support/core_ext/string'

module VLoopsRails
  module Utils
    class << self
      def format_response(http_party_response, format = false, key_to_extract = nil)
        parsed_response = JSON.parse(http_party_response.body, symbolize_names: true)

        response =
          if format
            h = {}
            parsed_response.each { |k, v| h[k.to_s.underscore.to_sym] = v }
            h
          else parsed_response
          end

        response = response[key_to_extract] if key_to_extract
        response
      rescue StandardError => e
        p e.message if @config[:debug]
        nil
      end
    end
  end
end
