
When("I create a shift for {string} on {string} from {string} to {string}") do |employee_name, date, start_time, end_time|
  membership = Membership.joins(:user).find_by!(users: { name: employee_name })
  schedule_week = membership.business.schedule_weeks.first!

  visit new_business_schedule_week_shift_path(membership.business, schedule_week)

  fill_in "Date:", with: date
  fill_in "Start Time:", with: start_time
  fill_in "End Time:", with: end_time
  select employee_name, from: "Assign Employee:"
  click_button "Create Shift"
end

Then("{string} should be assigned to the shift") do |employee_name|
  shift = Shift.last
  expect(shift.membership.user.name).to eq(employee_name)
end

When("I try to open the new shift form") do
  business = Business.find_by!(name: "Walmart")
  schedule_week = business.schedule_weeks.first!

  visit new_business_schedule_week_shift_path(business, schedule_week)
end

Then("I should see a forbidden response") do
  expect(page.status_code).to eq(403)
end
