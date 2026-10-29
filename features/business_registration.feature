Feature: Business registration and employee invitations
  An owner can set up a business and invite an employee to join it.

  Scenario: Owner registers and an employee accepts an invitation
    Given I am on the business registration page
    When I register "Corner Cafe" as "Alex Owner" with email "alex@example.com" and password "secret123"
    Then I should see "Corner Cafe"
    And I should see "Alex Owner (owner)"
    When I invite "sam@example.com" to the business
    Then an invitation email should be sent to "sam@example.com"
    When the employee accepts the invitation as "Sam Employee" with password "employee123"
    Then I should see "Sam Employee (employee)"
