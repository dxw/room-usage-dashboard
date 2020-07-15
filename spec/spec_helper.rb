ENV['RACK_ENV'] = 'test'
require "rack/test"
require_relative "../app.rb"
require "webmock/rspec"

module RspecHelper
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RspecHelper
end
