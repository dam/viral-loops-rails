require 'spec_helper'

describe VLoopsRails::AutoInclude::Method do
  include VLoopsRails::AutoInclude::Method

  it 'provides a function that can be called as a filter' do
    expect(VLoopsRails::AutoInclude::Filter).to receive(:filter)
    vloops_rails_auto_include
  end
end

