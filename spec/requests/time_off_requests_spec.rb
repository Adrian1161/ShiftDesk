require 'rails_helper'

RSpec.describe "TimeOffRequests", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/time_off_requests/new"
      expect(response).to have_http_status(:success)
    end
  end
end
