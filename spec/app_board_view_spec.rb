require "spec_helper"

RSpec.describe "Board view", type: :feature do
  before do
    Capybara.app = Sinatra::Application
    stub_const("CACHE_EXPIRY_TIMEOUT", 0)
  end

  context "get '/board/dxw'" do
    it "shows today's date" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/dxw"

      expect(page).to have_selector("#datetime_date", text: Date.today.strftime("%A, %B %-d"))
    end
    it "shows all the Zoom Meeting Rooms" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/dxw"

      expect(page).to have_content("Zoom Test01 Meeting Room")
      expect(page).to have_content("Zoom Test02 Meeting Room")
      expect(page).to have_content("Zoom Test03 Meeting Room")
      expect(page).not_to have_content("Hoxton Test01 Meeting Room")
      expect(page).not_to have_content("Leeds Test01 Meeting Room")
    end
  end

  context "get '/board/hoxton" do
    it "shows the three meeting rooms" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/hoxton"

      expect(page).to have_content("Hoxton Test01 Meeting Room")
      expect(page).to have_content("Hoxton Test02 Meeting Room")
      expect(page).to have_content("Hoxton Test03 Meeting Room")
      expect(page).not_to have_content("Leeds Test01 Meeting Room")
      expect(page).not_to have_content("Zoom Test01 Meeting Room")
    end
  end

  context "get '/board/leeds" do
    it "shows the current time" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/leeds"

      expect(page).to have_selector("#datetime_time", text: Time.now.strftime("%l:%M %P").strip)
    end

    it "shows the four meeting rooms" do
      stub_gcal_request(gcal_fake_response([]))
      visit "/board/leeds"

      expect(page).to have_content("Leeds Test01 Meeting Room")
      expect(page).to have_content("Leeds Test02 Meeting Room")
      expect(page).to have_content("Leeds Test03 Meeting Room")
      expect(page).to have_content("Leeds Test04 Meeting Room")
      expect(page).not_to have_content("Hoxton Test01 Meeting Room")
      expect(page).not_to have_content("Zoom Test01 Meeting Room")
    end
  end
end
