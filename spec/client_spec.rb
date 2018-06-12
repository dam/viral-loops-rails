require 'spec_helper'

describe VLoopsRails::Client do
  let(:client) { VLoopsRails::Client.new(api_token: 'token') }

  it 'should raise on nil credentials' do
    expect { VLoopsRails::Client.new }.to raise_error(VLoopsRails::MisconfiguredClientError, 'api_token is mandatory')
  end

  it 'overwrites global configuration on new client creation' do
    client = VLoopsRails::Client.new(api_token: 'token', debug: true)
    expect(client.instance_variable_get(:@config)).to eq(api_token: 'token', campaign_id: nil, debug: true)
  end

  it 'has a method to registera participant' do
    VCR.use_cassette('register_participant') do
      new_participant = { first_name: 'Damien', last_name: 'Imberdis', email: 'dimberdis@liveqos.com' }

      res = client.register(new_participant)
      expect(res[:referral_code]).to be_present
      expect(res[:is_new]).to be_truthy
    end
  end

  it 'register a participant with referrer data' do
    VCR.use_cassette('register_participant_referrer_data') do
      new_participant = { first_name: 'Conchita', last_name: 'Martinez', email: 'dimberdis+conchita@liveqos.com' }
      referrer = { referral_code: 'H1uHrwhl7' }

      res = client.register(new_participant, referrer)
      expect(res[:referral_code]).to be_present
      expect(res[:is_new]).to be_truthy

      # TODO: test referral relation
    end
  end

  it 'register a participant with channel information' do
    VCR.use_cassette('register_participant_channel_data') do
      new_participant = { first_name: 'David', last_name: 'Luiz', email: 'dimberdis+luiz@liveqos.com' }
      referrer = { referral_code: 'H1uHrwhl7' }

      res = client.register(new_participant, referrer, 'email') # NOTE: referrer mandatory
      expect(res[:referral_code]).to be_present
      expect(res[:is_new]).to be_truthy

      # TODO: test channel
    end
  end
end
