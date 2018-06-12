require 'httparty'
require 'json'
require 'active_support/core_ext/string'
require 'active_support/hash_with_indifferent_access'

module VLoopsRails
  class MisconfiguredClientError < StandardError; end
  class Client
    include HTTParty
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

    # TODO: they call it a participant
    # cf. https://intercom.help/viral-loops/refer-a-friend/refer-a-friend-http-api-reference
    # TODO: make a test on the api with all the possible optional parameter
    def register(participant, referrer = nil, source = nil)
      opts = {}
      opts[:body] = {
        'apiToken' => @config[:api_token],
        params: {
          event: 'registration',
          user: {
            firstname: participant[:first_name],
            lastname: participant[:last_name],
            email: participant[:email]
          }
        }
      }

      opts[:body][:params][:referrer] = { 'referralCode' => referrer[:referral_code] } if referrer && referrer[:referral_code].present?
      opts[:body][:params]['refSource'] = source if %w[facebook twitter reddit email copy].include?(source)

      response = request(:post, '/v2/events', opts)
      format_response(response)
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

      # TODO: add extra parameters if needed
      req_opts = {
        method: http_method,
        headers: header_params,
        params: query_params,
        debug_output: (@config[:debug] ? $stderr : nil)
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

    # TODO: manage errors, status, etc...
    def format_response(http_party_response)
      response = HashWithIndifferentAccess.new
      JSON.parse(http_party_response.body).each { |k, v| response[k.underscore] = v }
      response
    rescue StandardError => e
      p e.message
      nil
    end
  end
end
