Feature: Create and assign shifts
  As a manager
  I want to create shifts and assign employees
  So that employees know when they are scheduled

  Background:
    Given "Walmart" has a manager "Adrian Manager" and an employee "Jeff Employee"
    And "Walmart" has a draft schedule for the week of "2026-11-02"

  Scenario: Manager creates and assigns a shift
    Given I am signed in as "Adrian Manager"
    When I create a shift for "Jeff Employee" on "2026-11-03" from "09:00" to "17:00"
    Then I should see "Shift created successfully."
    And "Jeff Employee" should be assigned to the shift

  Scenario: Employee cannot create a shift
    Given I am signed in as "Jeff Employee"
    When I try to open the new shift form
    Then I should see a forbidden response

  Scenario: Manager cannot create a shift with an invalid time
    Given I am signed in as "Adrian Manager"
    When I create a shift for "Jeff Employee" on "2026-11-03" from "17:00" to "09:00"
    Then I should see "Ends at must be after the start time"