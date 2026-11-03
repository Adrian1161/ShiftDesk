require "rails_helper"

RSpec.describe "TimeOffRequests", type: :request do
  describe "GET /time_off_requests/new" do
    it "shows the form to a signed-in employee" do
      user = User.create!(
        name: "philip",
        email: "philipsa@business.com",
        password: "password123"
      )
      business = Business.create!(name: "ShiftDesk")
      Membership.create!(user: user, business: business, role: "employee")

      post session_path, params: {
        email: user.email,
        password: "password123"
      }

      get new_time_off_request_path

      expect(response).to have_http_status(:success)
    end

    it "redirects a visitor to sign in" do
      get new_time_off_request_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end
