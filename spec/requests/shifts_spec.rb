require "rails_helper"

RSpec.describe "Shifts", type: :request do
    let(:manager) do
        User.create!(
            name: "Test Manager",
            email: "Testmanager@example.com",
            password: "Test123"
        )
    end

    let(:employee) do
        User.create!(
            name: "Test Employee",
            email: "employee@example.com",
            password: "Test123"
        )
    end

    let(:business) do
        Business.create!(name: "Test Business")
    end

    let(:manager_membership) do
        Membership.create!(
            business: business,
            user: manager,
            role: "manager"
        )
    end

    let(:employee_membership) do
        Membership.create!(
            business: business,
            user: employee,
            role: "employee"
        )
    end

    let(:schedule_week) do
        ScheduleWeek.create!(
            business: business,
            week_start: Date.current.beginning_of_week(:monday)
        )
    end

    def sign_in(user)
        post session_path, params: {
            email: user.email,
            password: "Test123"
        }
    end

    describe "GET new shift form" do
        it "allows a manager to view the new shift form" do
            manager_membership
            employee_membership
            schedule_week

            sign_in(manager)

            get new_business_schedule_week_shift_path(business, schedule_week)

            expect(response).to have_http_status(:ok)
            expect(response.body).to include("Create Shift")
            expect(response.body).to include("Test Employee")
        end
    end

    describe "POST create shift" do
        it "creates a shift and assigns it to an employee" do
            manager_membership
            employee_membership
            schedule_week

            sign_in(manager)

            post business_schedule_week_shifts_path(business, schedule_week), params: {
                date: schedule_week.week_start.to_s,
                start_time: "10:00",
                end_time: "18:00",
                shift: {
                    membership_id: employee_membership.id
                }
            }

            expect(response).to have_http_status(:redirect)

            shift = Shift.last
            expect(shift.membership).to eq(employee_membership)
            expect(shift.schedule_week).to eq(schedule_week)
        end
    end

    describe "POST create shift with invalid time" do
        it "does not allow a shift that has an end time before the start time" do
            manager_membership
            employee_membership
            schedule_week

            sign_in(manager)

            expect {
                post business_schedule_week_shifts_path(business, schedule_week), params: {
                    date: schedule_week.week_start.to_s,
                    start_time: "18:00",
                    end_time: "10:00",
                    shift: {
                        membership_id: employee_membership.id
                    }
                }
            }.not_to change(Shift, :count)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "POST create shift with invalid time" do
        it "does not allow a shift that has an equal start and end time" do
            manager_membership
            employee_membership
            schedule_week

            sign_in(manager)

            expect {
                post business_schedule_week_shifts_path(business, schedule_week), params: {
                    date: schedule_week.week_start.to_s,
                    start_time: "10:00",
                    end_time: "10:00",
                    shift: {
                        membership_id: employee_membership.id
                    }
                }
            }.not_to change(Shift, :count)

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "POST create shift as employee" do 
        it "Does not allow an employee create a shift" do 
            manager_membership
            employee_membership
            schedule_week

            sign_in(employee)

            expect{
                post business_schedule_week_shifts_path(business, schedule_week), params: {
                    date: schedule_week.week_start.to_s,
                    start_time: "10:00",
                    end_time: "18:00",
                    shift: {
                        membership_id: employee_membership.id
                    }
                }
            }.not_to change(Shift, :count)
        end
    end
end