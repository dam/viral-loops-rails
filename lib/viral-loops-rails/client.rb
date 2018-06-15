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

    # cf. https://intercom.help/viral-loops/refer-a-friend/refer-a-friend-http-api-reference
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
      format_response(response, true)
    end

    def get_data
      opts = {}
      opts[:query_params] = { 'apiToken' => @config[:api_token] }

      response = request(:get, '/v2/participant_data', opts)
      format_response(response, false, :data)
    end

    def pending_rewards(user = nil, filtering_opts = {})
      opts = {}
      opts[:query_params] = { 'apiToken' => @config[:api_token] }
      opts[:query_params][:user] = { email: user[:email] } if user && user[:email].present?
      opts[:query_params][:user] = { 'referralCode' => user[:referral_code] } if user && user[:referral_code].present?
      opts[:query_params][:filter] = filtering_opts unless filtering_opts.empty?

      response = request(:get, '/v2/pending_rewards', opts)
      format_response(response, true)
    end

    def redeem(reward_id)
      opts = {}
      opts[:body] = { 'apiToken' => @config[:api_token] }
      opts[:body]['rewardId'] = reward_id if reward_id.is_a?(String)
      if reward_id.is_a?(Hash)
        opts[:body][:user] = { 'referralCode': reward_id[:referral_code] } if reward_id[:referral_code].present?
        opts[:body][:user] = { email: reward_id[:email] } if reward_id[:email].present?
      end

      response = request(:post, '/v2/rewarded', opts)
      format_response(response, false, :redeemed)
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
