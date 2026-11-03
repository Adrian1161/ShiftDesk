# frozen_string_literal: true

require_relative "../../spec/rails_helper"

RSpec.describe TimeOffRequest, type: :model do
  let(:user) do
    User.create!(
      name: "Alex",
      email: "alex@example.com",
      password: "password123"
    )
  end

  let(:business) { Business.create!(name: "ShiftDesk") }

  let(:membership) do
    Membership.create!(user: user, business: business, role: "employee")
  end

  def build_request(**changes)
    TimeOffRequest.new(
      {
        membership: membership,
        start_date: Date.current + 1,
        end_date: Date.current + 3
      }.merge(changes)
    )
  end

  it "accepts a valid future date range" do
    expect(build_request).to be_valid
  end

  it "accepts a one-day request starting today" do
    request = build_request(start_date: Date.current, end_date: Date.current)

    expect(request).to be_valid
  end

  it "rejects an end date before the start date" do
    request = build_request(
      start_date: Date.current + 3,
      end_date: Date.current + 1
    )

    expect(request).not_to be_valid
    expect(request.errors[:end_date]).to include("cannot be before the start date")
  end

  it "rejects a start date in the past" do
    request = build_request(start_date: Date.current - 1)

    expect(request).not_to be_valid
    expect(request.errors[:start_date]).to include("cannot be in the past")
  end

  it "rejects an end date in the past" do
    request = build_request(end_date: Date.current - 1)

    expect(request).not_to be_valid
    expect(request.errors[:end_date]).to include("cannot be in the past")
  end

  it "requires both dates" do
    expect(build_request(start_date: nil)).not_to be_valid
    expect(build_request(end_date: nil)).not_to be_valid
  end
end
