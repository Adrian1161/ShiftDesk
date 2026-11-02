require 'rails_helper'

RSpec.describe "Employee Access Control", type: :request do
    # Create the businesses
    let(:business_1) { Business.create!(name: "Business 1") }
    let(:business_2) { Business.create!(name: "Business 2") }

    # Create user
    let(:user_1) { User.create!(name: "Adam", email: "ad@am.com", password: "password") }

    # Create employee
    let!(:membership_1) { Membership.create!(user: user_1, business: business_1, role: "employee") }
    let!(:employee_1) { Employee.create!(name: "Employee Adam", business: business_1) }

    # Simulate logged in
    before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)
    end

    describe "cross-business access" do
        it "denies employee access to the data of another business" do
            get business_path(business_2)
            expect(response).not_to have_http_status(:success)
        end
    end

    describe "manager-only access" do
        it "denies an employee access to manager-only area" do
            post session_path, params: { email: user_1.email, password: "password" }
            get new_business_invitation_path(business_1)
            expect(response).not_to have_http_status(:success)
        end
    end
end
