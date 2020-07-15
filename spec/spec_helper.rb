require "rack/test"
require "../app.rb"

module RspecHelper
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RspecHelper
end
