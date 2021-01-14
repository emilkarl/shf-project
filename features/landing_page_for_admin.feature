Feature: Landing (home) page for Admin is the list of all applications

  As an Admin
  So that I can deal with member applications that need attention,
  Show me a landing page with all member applications

  PT: https://www.pivotaltracker.com/story/show/135683887

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email              | admin | member |
      | admin@shf.se       | true  | false  |



  Scenario: After login, admin sees all memberships as their landing page
    Given I am logged in as "admin@shf.se"
    When I am on the "landing" page
    Then I should see t("shf_applications.index.title")
