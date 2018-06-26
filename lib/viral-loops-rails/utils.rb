require 'json'
require 'active_support/core_ext/string'

module VLoopsRails
  module Utils
    class << self
      def format_response(http_party_response, format = false, key_to_extract = nil)
        response = JSON.parse(http_party_response.body, symbolize_names: true)
        response.deep_transform_keys! { |k| k.to_s.underscore.to_sym } if format
        response = response[key_to_extract] if key_to_extract
        response
      rescue StandardError => e
        p e.message if @config[:debug]
        nil
      end
    end
  end
end
