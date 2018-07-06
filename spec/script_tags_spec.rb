require 'spec_helper'

describe VLoopsRails::ReferAFriendWidget do
  it 'should validate the presence of settings' do
    expect do
      VLoopsRails.configure(campaign_id: nil)
      VLoopsRails::ReferAFriendWidget.new
    end.to raise_error(VLoopsRails::MisconfiguredWidget)
  end

  it 'renders the widget with the to_s method' do
    VLoopsRails.configure(campaign_id: 'fake_campaign')
    options = { position: 'top-right' }
    widget = VLoopsRails::ReferAFriendWidget.new(options)
    res = widget.to_s
    expect(res.html_safe?).to be_truthy
    expect(res).to match(/VL.load/)
  end
end
