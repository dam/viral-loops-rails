SPEC_ROOT = File.dirname(__FILE__)
require 'simplecov'

SimpleCov.minimum_coverage 90
SimpleCov.start do
  add_filter '/.bundle/'
end

require 'viral_loops_rails'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

Dir[File.expand_path(File.join(SPEC_ROOT, 'support', '**', '*.rb'))].each { |f| require f }

RSpec.configure do |config|
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path(File.join(SPEC_ROOT, 'fixtures', 'dish_cassettes'))
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

def fake_action_view_class
  klass = Class.new(Object)
  klass.class_eval do
    include VLoopsRails::ScriptTagsHelper
    attr_reader :controller
  end
  klass
end
