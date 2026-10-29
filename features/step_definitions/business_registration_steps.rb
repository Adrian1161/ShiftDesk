Given("I am on the business registration page") do
  visit root_path
end

When("I register {string} as {string} with email {string} and password {string}") do |business, owner, email, password|
  fill_in "Business name", with: business
  fill_in "Your name", with: owner
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in "Password confirmation", with: password
  click_button "Create business"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

When("I invite {string} to the business") do |email|
  click_link "Invite an employee"
  fill_in "Employee email", with: email
  click_button "Send invitation"
end

Then("an invitation email should be sent to {string}") do |email|
  expect(ActionMailer::Base.deliveries.last.to).to eq([email])
end

When("the employee accepts the invitation as {string} with password {string}") do |name, password|
  invitation = Invitation.last
  token = invitation.signed_id(purpose: :join, expires_in: 7.days)
  visit accept_invitation_path(token: token)
  fill_in "Your name", with: name
  fill_in "Choose a password", with: password
  fill_in "Password confirmation", with: password
  click_button "Join business"
end
