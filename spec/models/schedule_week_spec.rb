require "rails_helper"

RSpec.describe ScheduleWeek, type: :model do
  let(:business) { Business.create!(name: "Corner Cafe") }

  it "starts on the Monday of whichever day was given" do
    schedule_week = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 5)) # a Thursday

    expect(schedule_week.week_start).to eq(Date.new(2026, 11, 2))
  end

  it "covers seven days from Monday to Sunday" do
    schedule_week = business.schedule_weeks.new(week_start: Date.new(2026, 11, 2))

    expect(schedule_week.days).to eq(Date.new(2026, 11, 2)..Date.new(2026, 11, 8))
  end

  it "starts as an unpublished draft" do
    schedule_week = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2))

    expect(schedule_week).to be_draft
    expect(schedule_week.published_at).to be_nil
  end

  it "allows only one schedule per week for a business" do
    business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2))
    duplicate = business.schedule_weeks.new(week_start: Date.new(2026, 11, 4))

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:week_start]).to include("has already been taken")
  end

  describe "#publish" do
    it "publishes a draft and records when" do
      schedule_week = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2))

      expect(schedule_week.publish).to be(true)
      expect(schedule_week.reload).to be_published
      expect(schedule_week.published_at).to be_within(1.minute).of(Time.current)
    end

    it "does nothing to a week that is already published" do
      first_published_at = Time.zone.local(2026, 10, 30, 12)
      schedule_week = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2),
                                                      status: :published, published_at: first_published_at)

      expect(schedule_week.publish).to be(false)
      expect(schedule_week.reload.published_at).to eq(first_published_at)
    end
  end

  describe ".published" do
    it "returns only published weeks" do
      draft = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 2))
      published = business.schedule_weeks.create!(week_start: Date.new(2026, 11, 9))
      published.publish

      expect(business.schedule_weeks.published).to eq([ published ])
      expect(business.schedule_weeks.published).not_to include(draft)
    end
  end
end
