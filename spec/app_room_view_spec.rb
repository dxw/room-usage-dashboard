require "spec_helper"

RSpec.describe "Room view", type: :feature do
  before do
    Capybara.app = Sinatra::Application
    stub_const("CACHE_EXPIRY_TIMEOUT", 0) # Overriding this constant so the response won't stay cached between examples
  end

  context 'get "/room/:slug"' do
    context "when there are no meetings for the day" do
      it "shows the room is empty until the next day" do
        stub_gcal_request(gcal_fake_response([]))

        visit "/room/hoxton_test03"

        expect(page).to have_selector(".event.empty")
        expect(page).to have_selector(".datetime", text: "UntilTomorrow")
      end
    end

    context "when the room is empty now but there are meetings scheduled later on the day" do
      it "shows the room is empty at the current moment" do
        stub_gcal_request(gcal_fake_response(gcal_fake_events_with_attendees))
        visit "/room/hoxton_test03"

        expect(page).to have_selector(".event.empty")
      end

      it "shows the following meetings and displays the meeting details" do
        stub_gcal_request(gcal_fake_response(gcal_fake_events_with_attendees))
        visit "/room/hoxton_test03"

        expect(find("ul")).to have_selector("li", count: 3) # Three 'li' elements: The two meetings and the room being empty at the moment
        expect(page).to have_selector(".title", text: "sales - pipeline")
        expect(page).to have_selector(".title", text: "sales - forward planning")
        expect(page).to have_selector(".datetime", text: "3:00 pm – 3:30 pm")
        expect(page).to have_selector(".datetime", text: "3:30 pm – 4:00 pm")
        expect(page).to have_selector(".organiser", text: "Sales Person", count: 2) # The organiser is the same for both meetings
      end
    end

    context "when there is a meeting going on at the moment" do
      it "shows the details of the ongoing meeting and the following ones" do
        ongoing_meeting_start_time = Time.current.rfc3339
        ongoing_meeting_end_time = (Time.current + 30.minutes).rfc3339
        second_meeting_start_time = (Time.current + 60.minutes).rfc3339
        second_meeting_end_time = (Time.current + 120.minutes).rfc3339
        stub_gcal_request(gcal_fake_response(gcal_fake_events_with_ongoing_meeting(ongoing_meeting_start_time, ongoing_meeting_end_time, second_meeting_start_time, second_meeting_end_time)))
        visit "/room/hoxton_test03"

        expect(page).to have_selector(".event.now")
        expect(page).to have_selector(".title", text: "sales - pipeline")
        expect(page).to have_selector(".datetime", text: "(29 mins)")
        expect(find("ul")).to have_selector("li", count: 2)
        expect(page).to have_selector(".title", text: "sales - forward planning")
      end
    end
  end
end
