require "rails_helper"

RSpec.describe "Business registration and invitations", type: :request do
  let(:owner_details) do
    { name: "Corner Cafe", owner_name: "Alex Owner", email: "alex@example.com",
      password: "secret123", password_confirmation: "secret123" }
  end

  before { ActionMailer::Base.deliveries.clear }

  it "registers a business with its owner and lets the owner invite an employee" do
    expect { post businesses_path, params: { business: owner_details } }
      .to change(Business, :count).by(1).and change(User, :count).by(1)

    business = Business.last
    expect(business.memberships.find_by!(role: "owner").user.email).to eq("alex@example.com")
    expect(response).to redirect_to(business_path(business))

    post business_invitations_path(business), params: { invitation: { email: "SAM@example.com" } }
    expect(response).to redirect_to(business_path(business))
    expect(Invitation.last.email).to eq("sam@example.com")
    expect(ActionMailer::Base.deliveries.last.to).to eq([ "sam@example.com" ])
    expect(ActionMailer::Base.deliveries.last.body.to_s).to include("/invitations/accept/")
  end

  it "lets the invited employee accept once" do
    post businesses_path, params: { business: owner_details }
    business = Business.last
    post business_invitations_path(business), params: { invitation: { email: "sam@example.com" } }
    invitation = Invitation.last
    token = invitation.signed_id(purpose: :join, expires_in: 7.days)

    get accept_invitation_path(token: token)
    expect(response.body).to include("sam@example.com")

    expect do
      post accept_invitation_path(token: token), params: {
        name: "Sam Employee", password: "employee123", password_confirmation: "employee123"
      }
    end.to change { business.memberships.count }.by(1)

    expect(business.memberships.find_by!(role: "employee").user.email).to eq("sam@example.com")
    expect(invitation.reload).to be_accepted

    post accept_invitation_path(token: token), params: { password: "employee123" }
    expect(response).to have_http_status(:gone)
  end

  it "rejects invalid registration without creating partial records" do
    expect do
      post businesses_path, params: { business: owner_details.merge(password_confirmation: "different") }
    end.not_to change(Business, :count)

    expect(User.count).to eq(0)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "does not allow an unauthenticated visitor to invite employees" do
    business = Business.create!(name: "Corner Cafe")
    post business_invitations_path(business), params: { invitation: { email: "sam@example.com" } }
    expect(response).to redirect_to(new_session_path)
    expect(Invitation.count).to eq(0)
  end

  it "lets an invited existing user join with their password" do
    employee = User.create!(name: "Sam Employee", email: "sam@example.com", password: "employee123")
    post businesses_path, params: { business: owner_details }
    business = Business.last
    post business_invitations_path(business), params: { invitation: { email: employee.email } }
    token = Invitation.last.signed_id(purpose: :join, expires_in: 7.days)

    post accept_invitation_path(token: token), params: { password: "wrong-password" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(business.memberships.where(user: employee)).to be_empty

    post accept_invitation_path(token: token), params: { password: "employee123" }
    expect(response).to redirect_to(business_path(business))
    expect(business.memberships.find_by!(user: employee).role).to eq("employee")
  end

  it "does not let an employee invite others" do
    post businesses_path, params: { business: owner_details }
    business = Business.last
    post business_invitations_path(business), params: { invitation: { email: "sam@example.com" } }
    token = Invitation.last.signed_id(purpose: :join, expires_in: 7.days)
    post accept_invitation_path(token: token), params: {
      name: "Sam Employee", password: "employee123", password_confirmation: "employee123"
    }

    post business_invitations_path(business), params: { invitation: { email: "new@example.com" } }
    expect(response).to have_http_status(:forbidden)
    expect(Invitation.count).to eq(1)
  end

  it "lets the owner sign back in to manage the business" do
    post businesses_path, params: { business: owner_details }
    business = Business.last
    delete session_path

    post session_path, params: { email: "alex@example.com", password: "secret123" }
    expect(response).to redirect_to(business_path(business))

    get new_business_invitation_path(business)
    expect(response).to have_http_status(:ok)
  end
end
