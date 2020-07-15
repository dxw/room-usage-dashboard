require "spec_helper"

RSpec.describe "app API" do
  context "when hitting a single room API point" do
    before do # Overriding this constant so the response won't stay cached between examples
      stub_const("CACHE_EXPIRY_TIMEOUT", 0)
    end

    it "returns a valid response when there are no events" do
      stub_gcal_request(gcal_fake_response([]))
      response = get "/room/zoom_a.json"
      body = {"colour" => [255, 255, 255],
              "enable_presence_device" => true,
              "empty" => true,
              "minutes_to_next_event" => false,
              "minutes_to_end_of_event" => false,
              "upcoming_event_today" => false,
              "events" => []}

      expect(JSON.parse(response.body)).to eq(body)
    end

    it "returns a valid response including the events when there are any" do
      stub_gcal_request(gcal_fake_response(gcal_fake_events_with_attendees))
      response = get "/room/zoom_a.json"
      body_with_meetings = {
              "colour" => [255, 255, 255],
              "enable_presence_device" => true,
              "empty" => true,
              "upcoming_event_today" => true,
              "events" => [{
                            "summary" => "sales - pipeline",
                            "start_time" => "2020-07-20T15:00:00+01:00",
                            "start_time_string" => " 3:00 pm",
                            "end_time" => "2020-07-20T15:30:00+01:00",
                            "end_time_string" => " 3:30 pm",
                            "organiser" => "Sales Person",
                            "now" => false
                          },
                          {
                            "summary" => "sales - forward planning",
                            "start_time" => "2020-07-20T15:30:00+01:00",
                            "start_time_string" => " 3:30 pm",
                            "end_time" => "2020-07-20T16:00:00+01:00",
                            "end_time_string" => " 4:00 pm",
                            "organiser" => "Sales Person",
                            "now" => false
                          }]
              }
      expect(JSON.parse(response.body)).to include(body_with_meetings)
    end

    it "returns a valid response not including events without attendees or when all attendees have declined" do
      stub_gcal_request(gcal_fake_response(gcal_fake_events_without_attendees))
      response = get "/room/zoom_a.json"
      body_with_no_attendees = {"colour" => [255, 255, 255],
                                "enable_presence_device" => true,
                                "empty" => true,
                                "minutes_to_next_event" => false,
                                "minutes_to_end_of_event" => false,
                                "upcoming_event_today" => false,
                                "events" => []}

      expect(JSON.parse(response.body)).to eq(body_with_no_attendees)
    end
  end
end
