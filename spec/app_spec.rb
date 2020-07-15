require "spec_helper"

RSpec.describe "App" do
  context "GET '/check'" do
    let(:response) { get '/check' }
    it "shows a message" do
      expect(response.body).to eq("I'm alive!")
    end
  end
end
