require "spec_helper"

RSpec.describe "app API" do
  context "when hitting a single room API point" do
    before do # Overriding this constant so the response won't stay cached between examples
      stub_const("CACHE_EXPIRY_TIMEOUT", 0)
    end

    it "returns a valid response when there are no events" do
      stub_gcal_request(gcal_fake_response([]))
      response = get "/room/zoom_test01.json"

      expect(JSON.parse(response.body)["empty"]).to be true
      expect(JSON.parse(response.body)["events"]).to be_empty
    end

    it "returns a valid response including the events when there are any" do
      stub_gcal_request(gcal_fake_response(gcal_fake_events_with_attendees))
      response = get "/room/zoom_test01.json"

      expect(JSON.parse(response.body)["events"].count).to eq 2
    end

    it "returns a valid response not including events without attendees or when all attendees have declined" do
      stub_gcal_request(gcal_fake_response(gcal_fake_events_without_attendees))
      response = get "/room/zoom_test01.json"

      expect(JSON.parse(response.body)["events"]).to be_empty
    end
  end
end
