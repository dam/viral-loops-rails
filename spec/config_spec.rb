require 'spec_helper'

describe VLoopsRails do
  it 'possess a default global configuration' do
    expect(VLoopsRails.config).to be_a(Hash)
    expect(VLoopsRails.config).to eq(api_token: nil, campaign_id: nil, debug: false, timeout: 60)
  end

  it 'gets/sets global configuration' do
    VLoopsRails.configure(api_token: '1234', campaign_id: 1, timeout: 60)
    VLoopsRails.valid_config_keys.each do |key|
      expect(VLoopsRails.config[key]).not_to be_nil
    end
  end

  it 'filters extra parameters that are not valid' do
    VLoopsRails.configure(api_token: '5678', campaign_id: 2, hello: 'world', useless: 'param')

    expect(VLoopsRails.config).to eq(api_token: '5678', campaign_id: 2, debug: false, timeout: 60)
  end
end
