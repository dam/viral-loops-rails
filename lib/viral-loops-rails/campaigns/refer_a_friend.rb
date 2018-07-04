module VLoopsRails
  module Campaigns
    module ReferAFriend
      SUPPORTED_CHANNELS = %w[facebook twitter reddit email copy].freeze

      ## Refer a Friend API endpoints
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
        opts[:body][:params]['refSource'] = source if SUPPORTED_CHANNELS.include?(source)

        response = request(:post, '/v2/events', opts)
        VLoopsRails::Utils.format_response(response, true)
      end

      def get_data(participants = [], filtering_opts = {})
        opts = {}
        opts[:query_params] = { 'apiToken' => @config[:api_token] }

        if participants && !participants.empty?
          opts[:query_params][:params] = { participants: [] }
          participants.each do |participant|
            opts[:query_params][:params][:participants] << { email: participant[:email] } if participant[:email].present?
            opts[:query_params][:params][:participants] << { 'referralCode' => participant[:referral_code] } if participant[:referral_code].present?
          end
        end

        opts[:query_params][:filter] = filtering_opts unless filtering_opts.empty?

        response = request(:get, '/v2/participant_data', opts)
        VLoopsRails::Utils.format_response(response, true, :data)
      end

      def track(participant, source)
        opts = {}
        opts[:body] = { 'apiToken' => @config[:api_token] }
        opts[:body]['referralCode'] = participant[:referral_code] if participant[:referral_code].present?
        opts[:body]['postType'] = source if SUPPORTED_CHANNELS.include?(source)

        response = request(:post, '/v1/social_action', opts)
        response = VLoopsRails::Utils.format_response(response)
        response[:status] == 'ok'
      end

      ## Rewarding API endpoints
      # cf. https://intercom.help/viral-loops/refer-a-friend/api-rewarding

      def pending_rewards(user = nil, filtering_opts = {})
        opts = {}
        opts[:query_params] = { 'apiToken' => @config[:api_token] }
        opts[:query_params][:user] = { email: user[:email] } if user && user[:email].present?
        opts[:query_params][:user] = { 'referralCode' => user[:referral_code] } if user && user[:referral_code].present?
        opts[:query_params][:filter] = filtering_opts unless filtering_opts.empty?

        response = request(:get, '/v2/pending_rewards', opts)
        VLoopsRails::Utils.format_response(response, true)
      end

      def scroll_pending_rewards(by = 25)
        opts = { url: '/v2/pending_rewards', limit: by, format: true, key_to_extract: :pending }
        opts[:query_params] = { 'apiToken' => @config[:api_token] }

        ScrollCollectionProxy.new(self, opts)
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
        VLoopsRails::Utils.format_response(response, false, :redeemed)
      end
    end
  end
end
