require "rails_helper"

RSpec.describe "Viewing my upcoming shifts", type: :request do
  let(:business) { Business.create!(name: "Corner Cafe") }
  let(:this_week) { business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2)) }
  let(:next_week) { business.schedule_weeks.create!(week_start: Date.new(2026, 11, 9)) }

  def member(role, name, business: self.business)
    user = User.create!(name: name, email: "#{name.parameterize}@example.com",
                        password: "secret123", password_confirmation: "secret123")
    Membership.create!(user: user, business: business, role: role)
  end

  def sign_in(membership)
    post session_path, params: { email: membership.user.email, password: "secret123" }
  end

  def add_shift(week, membership, day, from, to, notes: nil)
    week.shifts.create!(membership: membership, notes: notes,
                        starts_at: Time.zone.parse("#{day} #{from}"), ends_at: Time.zone.parse("#{day} #{to}"))
  end

  let(:employee) { member("employee", "Sam Employee") }

  # "Now" is Wednesday, Nov 4, 2026 at noon.
  around { |example| travel_to(Time.zone.local(2026, 11, 4, 12)) { example.run } }

  it "requires signing in" do
    get business_upcoming_shifts_path(business)

    expect(response).to redirect_to(new_session_path)
  end

  context "as an employee" do
    before { sign_in(employee) }

    it "lists my shifts from published weeks with their dates and times, soonest first" do
      this_week.publish
      next_week.publish
      add_shift(next_week, employee, "2026-11-10", "08:00", "12:00")
      add_shift(this_week, employee, "2026-11-05", "09:00", "17:00", notes: "Open the store")

      get business_upcoming_shifts_path(business)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Thursday, Nov 5, 2026", "9:00 AM – 5:00 PM", "Open the store")
      expect(response.body).to include("Tuesday, Nov 10, 2026", "8:00 AM – 12:00 PM")
      expect(response.body.index("Nov 5, 2026")).to be < response.body.index("Nov 10, 2026")
    end

    it "includes a shift that is in progress but leaves out shifts that have ended" do
      this_week.publish
      add_shift(this_week, employee, "2026-11-03", "09:00", "17:00")
      add_shift(this_week, employee, "2026-11-04", "08:00", "16:00")

      get business_upcoming_shifts_path(business)

      expect(response.body).to include("Wednesday, Nov 4, 2026")
      expect(response.body).not_to include("Tuesday, Nov 3, 2026")
    end

    it "leaves out shifts in weeks that are still drafts" do
      this_week.publish
      add_shift(next_week, employee, "2026-11-10", "08:00", "12:00")

      get business_upcoming_shifts_path(business)

      expect(response.body).not_to include("Nov 10, 2026")
      expect(response.body).to include("You have no upcoming shifts.")
    end

    it "leaves out other employees' shifts and unassigned shifts" do
      this_week.publish
      coworker = member("employee", "Casey Coworker")
      add_shift(this_week, coworker, "2026-11-06", "09:00", "17:00")
      this_week.shifts.create!(starts_at: Time.zone.parse("2026-11-07 09:00"), ends_at: Time.zone.parse("2026-11-07 17:00"))

      get business_upcoming_shifts_path(business)

      expect(response.body).not_to include("Nov 6, 2026")
      expect(response.body).not_to include("Nov 7, 2026")
      expect(response.body).to include("You have no upcoming shifts.")
    end

    it "only shows shifts for the business in the address" do
      other_business = Business.create!(name: "Other Cafe")
      other_membership = Membership.create!(user: employee.user, business: other_business, role: "employee")
      other_week = other_business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2))
      other_week.publish
      add_shift(other_week, other_membership, "2026-11-06", "09:00", "17:00")

      get business_upcoming_shifts_path(business)

      expect(response.body).not_to include("Nov 6, 2026")
    end
  end

  it "shows a manager their own shifts too" do
    manager = member("manager", "Morgan Manager")
    this_week.publish
    add_shift(this_week, manager, "2026-11-06", "10:00", "18:00")
    sign_in(manager)

    get business_upcoming_shifts_path(business)

    expect(response.body).to include("Friday, Nov 6, 2026", "10:00 AM – 6:00 PM")
  end

  it "does not let a member of another business see this business's page" do
    outsider = member("owner", "Olly Outsider", business: Business.create!(name: "Other Cafe"))
    sign_in(outsider)

    get business_upcoming_shifts_path(business)

    expect(response).to have_http_status(:not_found)
  end
end
