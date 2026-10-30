Feature: See my upcoming shifts
  As an employee
  I want to see my upcoming shifts
  So that I know when to work

  Background:
    Given today is "2026-11-04 12:00"
    And "Corner Cafe" has a manager "Morgan Manager" and an employee "Sam Employee"
    And "Corner Cafe" has a draft schedule for the week of "2026-11-02"
    And "Corner Cafe" has a draft schedule for the week of "2026-11-09"
    And "Sam Employee" works on "2026-11-03" from "09:00" to "17:00"
    And "Sam Employee" works on "2026-11-05" from "09:00" to "17:00"
    And "Sam Employee" works on "2026-11-10" from "08:00" to "12:00"

  Scenario: Employee sees upcoming shifts from published weeks
    Given the schedule for the week of "2026-11-02" is published
    And the schedule for the week of "2026-11-09" is published
    And I am signed in as "Sam Employee"
    When I follow "My upcoming shifts"
    Then I should see "Thursday, Nov 5, 2026"
    And I should see "9:00 AM – 5:00 PM"
    And I should see "Tuesday, Nov 10, 2026"
    And I should see "8:00 AM – 12:00 PM"
    But I should not see "Tuesday, Nov 3, 2026"

  Scenario: Shifts in a draft week stay hidden
    Given the schedule for the week of "2026-11-02" is published
    And I am signed in as "Sam Employee"
    When I follow "My upcoming shifts"
    Then I should see "Thursday, Nov 5, 2026"
    But I should not see "Tuesday, Nov 10, 2026"

  Scenario: Employee with no published shifts
    Given I am signed in as "Sam Employee"
    When I follow "My upcoming shifts"
    Then I should see "You have no upcoming shifts."
