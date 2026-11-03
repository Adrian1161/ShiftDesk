require "rails_helper"

RSpec.describe "Publishing a week's schedule", type: :request do
  let(:business) { Business.create!(name: "Corner Cafe") }
  let(:schedule_week) { business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2)) }

  def member(role, name)
    user = User.create!(name: name, email: "#{name.parameterize}@example.com",
                        password: "secret123", password_confirmation: "secret123")
    Membership.create!(user: user, business: business, role: role)
  end

  def sign_in(membership)
    post session_path, params: { email: membership.user.email, password: "secret123" }
  end

  let!(:manager) { member("manager", "Morgan Manager") }
  let!(:employee) { member("employee", "Sam Employee") }

  before do
    schedule_week.shifts.create!(membership: employee,
                                 starts_at: Time.zone.local(2026, 11, 3, 9),
                                 ends_at: Time.zone.local(2026, 11, 3, 17))
  end

  it "requires signing in" do
    get business_schedule_weeks_path(business)

    expect(response).to redirect_to(new_session_path)
  end

  context "as a manager" do
    before { sign_in(manager) }

    it "lists draft weeks with their status" do
      get business_schedule_weeks_path(business)

      expect(response.body).to include("Week of Nov 2, 2026", "Draft")
    end

    it "shows a draft week with its shifts and a publish button" do
      get business_schedule_week_path(business, schedule_week)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tuesday, Nov 3", "9:00 AM", "Sam Employee", "Publish schedule")
    end

    it "publishes the week" do
      patch publish_business_schedule_week_path(business, schedule_week)

      expect(schedule_week.reload).to be_published
      expect(response).to redirect_to(business_schedule_week_path(business, schedule_week))
      follow_redirect!
      expect(response.body).to include("Week of Nov 2, 2026 is published. Employees can now see it.")
      expect(response.body).not_to include("Publish schedule")
    end

    it "says so when the week is already published" do
      schedule_week.publish

      patch publish_business_schedule_week_path(business, schedule_week)

      follow_redirect!
      expect(response.body).to include("Week of Nov 2, 2026 is already published.")
    end
  end

  context "as an owner" do
    it "can publish the week" do
      sign_in(member("owner", "Alex Owner"))

      patch publish_business_schedule_week_path(business, schedule_week)

      expect(schedule_week.reload).to be_published
    end
  end

  context "as an employee" do
    before { sign_in(employee) }

    it "cannot see a draft week" do
      get business_schedule_weeks_path(business)
      expect(response.body).not_to include("Week of Nov 2, 2026")
      expect(response.body).to include("No schedules have been published yet.")

      get business_schedule_week_path(business, schedule_week)
      expect(response).to have_http_status(:not_found)
    end

    it "cannot publish a week" do
      patch publish_business_schedule_week_path(business, schedule_week)

      expect(response).to have_http_status(:not_found)
      expect(schedule_week.reload).to be_draft
    end

    it "sees the week once it is published, without a publish button" do
      schedule_week.publish

      get business_schedule_weeks_path(business)
      expect(response.body).to include("Week of Nov 2, 2026")

      get business_schedule_week_path(business, schedule_week)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sam Employee", "Published")
      expect(response.body).not_to include("Publish schedule")
    end
  end

  context "as a member of another business" do
    it "cannot see or publish this business's schedules" do
      other_business = Business.create!(name: "Other Cafe")
      outsider = User.create!(name: "Olly Outsider", email: "olly@example.com",
                              password: "secret123", password_confirmation: "secret123")
      Membership.create!(user: outsider, business: other_business, role: "owner")
      post session_path, params: { email: "olly@example.com", password: "secret123" }

      get business_schedule_weeks_path(business)
      expect(response).to have_http_status(:not_found)

      patch publish_business_schedule_week_path(business, schedule_week)
      expect(response).to have_http_status(:not_found)
      expect(schedule_week.reload).to be_draft
    end
  end
end
