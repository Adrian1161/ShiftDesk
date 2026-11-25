require 'rails_helper'

RSpec.describe Shift, type: :model do
    # Overlapping shifts
    describe "overlapping shifts" do
        let(:business) do
            Business.create!(name: "Tamu Corp")
        end

        let(:user) do
            User.create!(
                name: "Jane Doe",
                email: "Jane@example.com",
                password: "password123"
            )
        end

        let(:other_user) do
            User.create!(
                name: "John Doe",
                email: "john@example.com",
                password: "password123"
            )
        end

        let(:membership) do
            Membership.create!(
                user: user,
                business: business,
                role: "employee"
            )
        end

        let(:other_membership) do
            Membership.create!(
                user: other_user,
                business: business,
                role: "employee"
            )
        end

        let(:schedule_week) do
            ScheduleWeek.create!(
                business: business,
                week_start: Date.new(2026, 11, 30),
                status: "draft"
            )
        end

        let!(:existing_shift) do
            Shift.create!(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 08:00:00"),
                ends_at: Time.zone.parse("2026-12-01 18:00:00")
            )
        end

        ################################################################################
        # Fail when new shift overlaps (same employee) #################################
        ################################################################################

        it "fails when new shift is completely inside existing shift (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 09:00:00"),
                ends_at: Time.zone.parse("2026-12-01 17:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when new shift starts before and ends during existing shift (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 02:00:00"),
                ends_at: Time.zone.parse("2026-12-01 10:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when new shift starts during and ends after existing shift (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 15:00:00"),
                ends_at: Time.zone.parse("2026-12-01 23:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when existing shift is completely inside new shift (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 08:00:00"),
                ends_at: Time.zone.parse("2026-12-01 18:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        ################################################################################
        # Valid when new shift does not overlap (same employee) ########################
        ################################################################################

        it "is valid when new shift does not overlap existing shift (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 18:00:00"),
                ends_at: Time.zone.parse("2026-12-01 22:00:00")
            )
            expect(new_shift).to be_valid
        end

        it "is valid when new shift ends at the same time existing shift starts (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 01:00:00"),
                ends_at: Time.zone.parse("2026-12-01 08:00:00")
            )
            expect(new_shift).to be_valid
        end

        it "is valid when new shift starts at the same time existing shift ends (same employee)" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: membership,
                starts_at: Time.zone.parse("2026-12-01 18:00:00"),
                ends_at: Time.zone.parse("2026-12-02 06:00:00")
            )
            expect(new_shift).to be_valid
        end

        ################################################################################
        # Valid when new shift overlaps (different employee) ###########################
        ################################################################################

        it "is valid when new shift of one employee overlaps existing shift of another employee" do
            new_shift = Shift.new(
                schedule_week: schedule_week,
                membership: other_membership,
                starts_at: Time.zone.parse("2026-12-01 10:00:00"),
                ends_at: Time.zone.parse("2026-12-02 16:00:00")
            )
            expect(new_shift).to be_valid
        end
    end
end
