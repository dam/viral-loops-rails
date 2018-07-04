require 'httparty'
require 'json'

module VLoopsRails
  class Client
    include HTTParty
    include VLoopsRails::Campaigns::ReferAFriend

    base_uri 'https://app.viral-loops.com/api'

    def initialize(config = {})
      @config = VLoopsRails.config.merge(config)
      @base_url = 'https://app.viral-loops.com/api'
      @user_agent = "VLoopsRails/#{VLoopsRails::VERSION}/ruby"
      @default_headers = {
        'Content-Type' => 'application/json',
        'User-Agent' => @user_agent
      }
      validate_credentials!
    end

    private

    def validate_credentials!
      raise(MisconfiguredClientError, 'api_token is mandatory') unless @config[:api_token]
    end

    def request(http_method, path, opts = {})
      http_method = http_method.to_sym.downcase

      header_params = @default_headers.merge(opts[:header_params] || {})
      query_params = opts[:query_params] || {}
      form_params = opts[:form_params] || {}

      req_opts = {
        method: http_method,
        headers: header_params,
        query: query_params,
        debug_output: (@config[:debug] ? $stderr : nil),
        timeout: @config[:timeout]
      }

      if %i[post patch put delete].include?(http_method)
        req_body = build_request_body(header_params, form_params, opts[:body])
        req_opts.update body: req_body
      end

      self.class.send(http_method, path, req_opts)
    end

    def build_request_body(header_params, form_params, body)
      if header_params['Content-Type'] == 'application/x-www-form-urlencoded' ||
         header_params['Content-Type'] == 'multipart/form-data'
        data = {}
        form_params.each do |key, value|
          case value
          when ::File, ::Array, nil
            data[key] = value
          else
            data[key] = value.to_s
          end
        end
      elsif body
        # TODO: see if we can simplify opts[:body] id same code needed for all endpoints
        data = body.is_a?(String) ? body : body.to_json
      else
        data = nil
      end
      data
    end
  end
end
