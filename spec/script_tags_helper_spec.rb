require 'spec_helper'

describe VLoopsRails::ScriptTagsHelper do
  include VLoopsRails::ScriptTagsHelper

  it 'provided an helper that generates a refer a friend widget' do
    expect(VLoopsRails::ReferAFriendWidget).to receive(:new)
    options = { type: :refer_a_friend }
    vloops_script_tag(options)
  end

  it 'sets instance variable to record that it was called' do
    VLoopsRails.configure(campaign_id: 'fake_campaign')
    fake_action_view = fake_action_view_class.new
    obj = Object.new

    fake_action_view.instance_variable_set(:@controller, obj)

    options = { type: :refer_a_friend }
    fake_action_view.vloops_script_tag(options)

    expect(obj.instance_variable_get(VLoopsRails::SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE)).to eq(true)
  end
end
