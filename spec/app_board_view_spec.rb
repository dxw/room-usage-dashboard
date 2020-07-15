require "spec_helper"

RSpec.describe "Board view", type: :feature do
  before do
    Capybara.app = Sinatra::Application
    Capybara.server = :webrick
    Capybara.javascript_driver = :selenium_headless
    stub_const("CACHE_EXPIRY_TIMEOUT", 0)
  end

  context "get '/board/dxw'" do
    it "shows today's date" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/dxw"

      expect(page).to have_selector("#datetime_date", text: Date.today.strftime('%A, %B %e'))
    end
    it "shows the Zoom call rooms A, B, and C" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/dxw"

      expect(page).to have_content("Zoom Call A")
      expect(page).to have_content("Zoom Call B")
      expect(page).to have_content("Zoom Call C")
    end
  end

  context "get '/board/hoxton" do
    it "shows the three meeting rooms" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/hoxton"

      expect(page).to have_content("Main Meeting Room")
      expect(page).to have_content("The Hide")
      expect(page).to have_content("Wellbeing Room")
    end
  end

  context "get '/board/leeds" do
    it "shows the current time", js: true do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/leeds"

      expect(page).to have_selector("#datetime_time", text: Time.now.strftime("%l:%M %P").strip)
    end

    it "shows the four meeting rooms" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/leeds"

      expect(page).to have_content("Col. Mustard")
      expect(page).to have_content("Dr. Peacock")
      expect(page).to have_content("Prof. Plum")
      expect(page).to have_content("Revd. Green")
    end
  end
end
