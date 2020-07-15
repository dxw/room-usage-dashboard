ENV["RACK_ENV"] = "test"
require "rack/test"
require "capybara/rspec"
require "active_support/testing/time_helpers"
require "active_support/time"
require_relative "../app.rb"
require_relative "./helpers.rb"
require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

module RspecHelper
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RspecHelper
  config.include Helpers
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
  config.before(:all, type: :feature) do
    WebMock.allow_net_connect!
  end
end
