require "spec_helper"

RSpec.describe "app API" do
  context "when hitting a single room API point" do

    def gcal_fake_response(items)
      {
        "kind" => "calendar#events",
        "etag" => "test etag",
        "summary" => "test summary",
        "description" => "test description",
        "updated" => "2020-05-31T23:59:60Z",
        "timeZone" => "test timezone",
        "accessRole" => "test accessrole",
        "defaultReminders" => [
          {
            "method" => "test method",
            "minutes" => 30
          }
        ],
        "nextPageToken" => "test nextpagetoken",
        "nextSyncToken" => "test nextsynctoken",
        "items" => items
      }.to_json
    end

    def stub_gcal_request(body)
      stub_request(:any, /www.googleapis.com/).
        to_return(body: body, headers: {"Content-Type" => "application/json"})
    end

    it " returns a response when there are no events" do
      stub_gcal_request(gcal_fake_response([]))
      response = get "/room/zoom_c.json"
      body = {"colour" => [255,255,255],
              "enable_presence_device" => true,
              "empty" => true,
              "minutes_to_next_event" => false,
              "minutes_to_end_of_event" => false,
              "upcoming_event_today" => false,
              "events" => []}

      expect(JSON.parse(response.body)).to eq(body)
    end
  end
end
