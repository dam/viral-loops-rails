require 'spec_helper'
require 'pp'

describe VLoopsRails::Client do
  let(:client) { VLoopsRails::Client.new(api_token: 'token') }

  it 'should raise on nil credentials' do
    expect { VLoopsRails::Client.new }.to raise_error(VLoopsRails::MisconfiguredClientError, 'api_token is mandatory')
  end

  it 'overwrites global configuration on new client creation' do
    client = VLoopsRails::Client.new(api_token: 'token', debug: true)
    expect(client.instance_variable_get(:@config)).to eq(api_token: 'token', campaign_id: nil, debug: true, timeout: 60)
  end

  it 'has a method to register a participant' do
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

  it 'has a method to returns data of all participants' do
    VCR.use_cassette('get_participants_data') do
      res = client.get_data
      expect(res).to be_an_instance_of(Array)

      participant_emails = res.map { |u| u[:user][:email] }
      expect(participant_emails.size).to eq(4)
    end
  end

  it 'has a method to returns data about an user pending rewards, providing its email' do
    VCR.use_cassette('user_pending_rewards_email', match_requests_on: [:path]) do
      user = { email: 'dimberdis+lemar@liveqos.com' }

      res = client.pending_rewards(user)
      expect(res[:total_pending]).to eq(4)
      expect(res[:pending]).not_to be_empty
    end
  end

  it 'has a method to returns data about an user pending rewards, providing its referral code' do
    VCR.use_cassette('user_pending_rewards_refcode', match_requests_on: [:path]) do
      user = { referral_code: 'rkvwClJbX' }

      res = client.pending_rewards(user)
      expect(res[:total_pending]).to eq(2)
      expect(res[:pending]).not_to be_empty
    end
  end

  it 'has a method to return data about all pending rewards' do
    VCR.use_cassette('pending_rewards', match_requests_on: [:path]) do
      res = client.pending_rewards
      expect(res[:total_pending]).to eq(14)
      expect(res[:pending]).not_to be_empty
    end
  end

  it 'has filtering options for #pending_rewards' do
    VCR.use_cassette('filtering_pending_rewards', match_requests_on: [:path]) do
      filtering_opts = { limit: 2, skip: 0 }
      res = client.pending_rewards(nil, filtering_opts)
      expect(res[:total_pending]).to eq(8)
      expect(res[:pending][0][:rewards].length).to eq(2)
    end
  end

  it 'accepts pagination for #pending_rewards' do
    VCR.use_cassette('paginate_pending_rewards', match_requests_on: [:path]) do
      filtering_opts = { limit: 2, skip: 2 }
      res = client.pending_rewards(nil, filtering_opts)
      expect(res[:total_pending]).to eq(8)
      expect(res[:pending].length).to eq(2)
    end
  end

  it 'has a method to redeem a reward, specifying a reward id' do
    VCR.use_cassette('redeem_reward', match_requests_on: [:path]) do
      reward_id = 'reward_YjgwYjI1NTYxMjE5NmJhYzEwODc'
      res = client.redeem(reward_id)
      expect(res[:total]).to eq(1)
      expect(res[:rewards]).not_to be_empty
    end
  end

  it 'has a method to redeem all of an user reward, providing its referral code' do
    VCR.use_cassette('redeem_all_rewards_by_user_refcode', match_requests_on: [:path]) do
      user = { referral_code: 'SkfeD_Axm' }
      res = client.redeem(user)
      expect(res[:total]).to eq(3)
      expect(res[:rewards]).not_to be_empty
    end
  end

  it 'has a method to redeem all of an user reward, providing its referral code' do
    VCR.use_cassette('redeem_all_rewards_by_user_email', match_requests_on: [:path]) do
      user = { email: 'dimberdis+acceptref4@liveqos.com' }
      res = client.redeem(user)
      expect(res[:total]).to eq(2)
      expect(res[:rewards]).not_to be_empty
    end
  end
end
