require "spec_helper"

RSpec.describe "app" do
  context "GET to '/'" do
    let(:response) { get "/" }

    context "if user not authenticated" do
      it "returns 401 not authorized" do
        expect(response.status).to eq 401
      end
    end
    context "if user authenticated" do

      it "returns status 200 OK" do
        expect(response.status).to eq 200
      end

      it "displays Zoom call rooms A, B and C and their current meetings info" do

      end

      it "displays upcoming meetings for Zoom call rooms A, B and C" do

      end

      it "does not display a meeting with no attendees" do

      end
    end
  end

  context "GET to '/hoxton'" do
    it "returns status 200 OK" do

    end

    it "displays the 3 meeting rooms in Hoxton and their current meetings info" do

    end

    it "displays upcoming meetings for each room" do

    end
  end

  context "GET to '/leeds'" do
    it "returns status 200 OK" do

    end

    it "displays the 4 meeting rooms in Leeds and their current meetings info" do

    end

    it "displays upcoming meetings for each room" do

    end
  end
end

