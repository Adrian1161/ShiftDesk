Feature: Publish a week's schedule
  As a manager
  I want to publish a week's schedule
  So that employees can see it

  Background:
    Given "Corner Cafe" has a manager "Morgan Manager" and an employee "Sam Employee"
    And "Corner Cafe" has a draft schedule for the week of "2026-11-02"
    And "Sam Employee" works on "2026-11-03" from "09:00" to "17:00"

  Scenario: Manager publishes a draft week
    Given I am signed in as "Morgan Manager"
    When I open the schedule for the week of "2026-11-02"
    Then I should see "Draft: employees cannot see this schedule yet."
    When I press "Publish schedule"
    Then I should see "Week of Nov 2, 2026 is published. Employees can now see it."
    And I should not see a "Publish schedule" button

  Scenario: Employee cannot see a draft week
    Given I am signed in as "Sam Employee"
    When I go to the schedules for "Corner Cafe"
    Then I should see "No schedules have been published yet."
    And I should not see "Week of Nov 2, 2026"

  Scenario: Employee sees the week after it is published
    Given the schedule for the week of "2026-11-02" is published
    And I am signed in as "Sam Employee"
    When I go to the schedules for "Corner Cafe"
    And I follow "Week of Nov 2, 2026"
    Then I should see "Tuesday, Nov 3"
    And I should see "9:00 AM – 5:00 PM"
    And I should see "Sam Employee"
    And I should not see a "Publish schedule" button
