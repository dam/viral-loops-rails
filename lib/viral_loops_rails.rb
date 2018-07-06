Dir[File.dirname(__FILE__) + '/viral-loops-rails/**/*.rb'].each do |file|
  if File.basename(file, '.rb') == 'railtie'
    require file if defined?(Rails)
  else
    require file
  end
end

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
