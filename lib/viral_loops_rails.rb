require 'viral-loops-rails/exceptions'
require 'viral-loops-rails/utils'
require 'viral-loops-rails/scroll_collection_proxy'
require 'viral-loops-rails/campaigns/refer_a_friend'
require 'viral-loops-rails/auto_include_filter'
require 'viral-loops-rails/client'
require 'viral-loops-rails/script_tags'
require 'viral-loops-rails/script_tags_helper'
require 'viral-loops-rails/version'
require 'viral-loops-rails/railtie' if defined?(Rails::Railtie)

module VLoopsRails
  @config = { api_token: nil, campaign_id: nil, debug: false, timeout: 60 }
  @valid_config_keys = %i[api_token campaign_id debug timeout]

  class << self
    attr_accessor :config
    attr_reader :valid_config_keys

    def configure(opts = {})
      opts.each { |k, v| config[k.to_sym] = v if valid_config_keys.include?(k.to_sym) }
    end
  end
end
