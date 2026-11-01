# frozen_string_literal: true

require_relative "../../spec/rails_helper"

RSpec.describe Availability, type: :model do
  let(:user) do
    User.create!(
      name: "Philip",
      email: "philip@tamu.com",
      password: "password123"
    )
  end

  let(:business) { Business.create!(name: "ShiftDesk") }

  let(:membership) do
    Membership.create!(user: user, business: business, role: "employee")
  end

  def build_availability(**changes)
    Availability.new(
      {
        membership: membership,
        day_of_week: 1,
        start_time: "09:00",
        end_time: "12:00"
      }.merge(changes)
    )
  end

  it "accepts a valid availability window" do
    expect(build_availability).to be_valid
  end

  it "rejects a day outside Sunday through Saturday" do
    expect(build_availability(day_of_week: 7)).not_to be_valid
  end

  it "requires a start and end time" do
    expect(build_availability(start_time: nil)).not_to be_valid
    expect(build_availability(end_time: nil)).not_to be_valid
  end

  it "rejects a window that ends before it starts" do
    availability = build_availability(start_time: "17:00", end_time: "09:00")

    expect(availability).not_to be_valid
    expect(availability.errors[:end_time]).to include("must be after the start time")
  end

  it "rejects an overnight window" do
    availability = build_availability(start_time: "22:00", end_time: "06:00")

    expect(availability).not_to be_valid
  end

  it "rejects overlapping windows on the same day" do
    build_availability.save!

    overlapping = build_availability(start_time: "11:00", end_time: "14:00")

    expect(overlapping).not_to be_valid
    expect(overlapping.errors[:base]).to include(
                                           "This availability overlaps an existing window"
                                         )
  end

  it "allows a window that starts when another one ends" do
    build_availability.save!

    next_window = build_availability(start_time: "12:00", end_time: "17:00")

    expect(next_window).to be_valid
  end

  it "allows the same hours on a different day" do
    build_availability.save!

    expect(build_availability(day_of_week: 2)).to be_valid
  end

  it "does not treat a saved window as overlapping itself" do
    availability = build_availability
    availability.save!

    expect(availability).to be_valid
  end
end