require 'rails_helper'

# Create the business and employees for testing
RSpec.describe Shift, type: :model do
    let(:business){ Business.create!(name: "Business1Test Corp") }
    let(:employee){ Employee.create!(name: "John Doe", business: business) }
    let(:employee_other){ Employee.create!(name: "Jane Smith", business: business) }

    # Create first shift of first employee
    let!(:existing_shift) do
        Shift.create!(
            employee: employee,
            business: business,
            start_time: Time.zone.parse("2026-12-01 09:00:00"),
            end_time: Time.zone.parse("2026-12-01 17:00:00")
        )
    end

    # Overlapping shifts
    describe "overlapping shifts" do

        ################################################################################
        # Fail when new shift overlaps (same employee) #################################
        ################################################################################

        it "fails when new shift is completely inside existing shift (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 10:00:00"),
                end_time: Time.zone.parse("2026-12-01 16:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when new shift starts before and ends during existing shift (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 02:00:00"),
                end_time: Time.zone.parse("2026-12-01 10:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when new shift starts during and ends after existing shift (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 15:00:00"),
                end_time: Time.zone.parse("2026-12-01 23:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        it "fails when existing shift is completely inside new shift (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 08:00:00"),
                end_time: Time.zone.parse("2026-12-01 18:00:00")
            )
            expect(new_shift).not_to be_valid
            expect(new_shift.errors[:base]).to include("This employee has an overlapping shift in this time window.")
        end

        ################################################################################
        # Valid when new shift does not overlap (same employee) ########################
        ################################################################################

        it "is valid when new shift does not overlap existing shift (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 01:00:00"),
                end_time: Time.zone.parse("2026-12-01 08:00:00")
            )
            expect(new_shift).to be_valid
        end

        it "is valid when new shift ends at the same time existing shift starts (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 01:00:00"),
                end_time: Time.zone.parse("2026-12-01 09:00:00")
            )
            expect(new_shift).to be_valid
        end

        it "is valid when new shift starts at the same time existing shift ends (same employee)" do
            new_shift = Shift.new(
                employee: employee,
                business: business,
                start_time: Time.zone.parse("2026-12-01 17:00:00"),
                end_time: Time.zone.parse("2026-12-02 06:00:00")
            )
            expect(new_shift).to be_valid
        end

        ################################################################################
        # Valid when new shift overlaps (different employee) ###########################
        ################################################################################

        it "is valid when new shift of one employee overlaps existing shift of another employee" do
            new_shift = Shift.new(
                employee: employee_other,
                business: business,
                start_time: Time.zone.parse("2026-12-01 17:00:00"),
                end_time: Time.zone.parse("2026-12-02 06:00:00")
            )
            expect(new_shift).to be_valid
        end

    end

end