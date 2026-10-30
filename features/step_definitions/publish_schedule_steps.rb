Given("{string} has a manager {string} and an employee {string}") do |business_name, manager_name, employee_name|
  business = Business.create!(name: business_name)
  { manager_name => "manager", employee_name => "employee" }.each do |name, role|
    user = User.create!(name: name, email: "#{name.parameterize}@example.com",
                        password: "secret123", password_confirmation: "secret123")
    Membership.create!(user: user, business: business, role: role)
  end
end

Given("{string} has a draft schedule for the week of {string}") do |business_name, week_start|
  Business.find_by!(name: business_name).schedule_weeks.create!(week_start: Date.parse(week_start))
end

Given("{string} works on {string} from {string} to {string}") do |name, date, from, to|
  membership = Membership.joins(:user).find_by!(users: { name: name })
  week_start = Date.parse(date).beginning_of_week(:monday)
  membership.business.schedule_weeks.find_by!(week_start: week_start).shifts.create!(
    membership: membership,
    starts_at: Time.zone.parse("#{date} #{from}"),
    ends_at: Time.zone.parse("#{date} #{to}")
  )
end

Given("the schedule for the week of {string} is published") do |week_start|
  ScheduleWeek.find_by!(week_start: Date.parse(week_start)).publish
end

Given("I am signed in as {string}") do |name|
  visit new_session_path
  fill_in "Email", with: User.find_by!(name: name).email
  fill_in "Password", with: "secret123"
  click_button "Sign in"
end

When("I open the schedule for the week of {string}") do |week_start|
  schedule_week = ScheduleWeek.find_by!(week_start: Date.parse(week_start))
  visit business_schedule_week_path(schedule_week.business, schedule_week)
end

When("I go to the schedules for {string}") do |business_name|
  visit business_schedule_weeks_path(Business.find_by!(name: business_name))
end

When("I press {string}") do |button|
  click_button button
end

When("I follow {string}") do |link|
  click_link link
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("I should not see a {string} button") do |button|
  expect(page).not_to have_button(button)
end
