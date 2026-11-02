require 'rails_helper'

RSpec.describe "Employee Access Control", type: :request do

    # Create users
    let(:user_1) { User.create!(name: "Adam", email: "ad@am.com", password: "password") }
    let(:user_1) { User.create!(name: "Harrison", email: "harr@ison.com", password: "password") }

    # Create the businesses
    let(:business_1) { Business.create!(:business, name: "Business 1") }
    let(:business_2) { Business.create!(:business, name: "Business 2") }

    # Create employees
    let!(:employee_1) { Employee.create!(name: "Employee Adam", business: business_1) }
    let!(:employee_2) { Employee.create!(name: "Employee Harrison", business: business_2) }

    describe "cross-business access" do

        it "denies employee access to the data of another business" do
            post login_path, params: { email: user_1.email, password: "password" }
            get business_path(business_2)
            expect(response).not_to have_http_status(:success)
            expect(response).to redirect_to(root_path)
            expect(flash[:alert]).to include("Access denied")
        end

    end

    describe "manager-only access" do

        it "denies an employee access to manager-only area" do
            post session_path, params: { email: user_1.email, password: "password" }
            get new_business_invitation_path(business_1)
            expect(response).not_to have_http_status(:success)
            expect(response).to redirect_to(root_path)
        end

    end

end