Feature: Only the Admin sees the db id for a company, list of companies

  As the admin,
  So that I can help debug problems,
  show me the database id for companies
  on the individual company pages
  and on the list of companies.

  Only the admin can see the db-id.

  PivotalTracker: https://www.pivotaltracker.com/story/show/177249720


  Background:

    Given the date is set to "2019-06-06"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name         |
      | Stockholm    |

    Given the following kommuns exist:
      | name     |
      | Alingsås |

    Given the following companies exist:
      | name                       | company_number | email                      | region       | kommun   | city      | visibility     |
      | Company 1                  | 5560360793     | hello@company-1.com        | Stockholm    | Alingsås | Harplinge | street_address |


    And the following users exist:
      | email                            | admin | member |
      | member@company-1.com             |       | true   |
      | applicant@company-1.com          |       | false  |
      | admin@shf.se                     | true  | false  |


    And the following business categories exist
      | name    |
      | Groomer |

    And the following applications exist:
      | user_email                       | company_number | categories | state    |
      | member@company-1.com             | 5560360793     | Groomer    | accepted |
      | applicant@company-1.com          | 5560360793     | Groomer    | new      |


    And the following payments exist
      | user_email                       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@company-1.com             | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |


  # -----------------------------------------------------------------------------------------------

  Scenario: Admin sees the database id in list of Companies
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "db id"

  Scenario: Admin sees db id on Company page
    Given I am logged in as "admin@shf.se"
    When I am on the page for company number "5560360793"
    Then I should see "db id"


  Scenario: Member does not see database id in list of Companies
    Given I am logged in as "member@company-1.com"
    When I am on the "all companies" page
    Then I should not see "db id"


  Scenario: Member does not see db id on Company page
    Given I am logged in as "member@company-1.com"
    When I am on the page for company number "5560360793"
    Then I should not see "db id"


  Scenario: Applicant does not see database id in list of Companies
    Given I am logged in as "applicant@company-1.com"
    When I am on the "all companies" page
    Then I should not see "db id"


  Scenario: Applicant does not see db id on Company page
    Given I am logged in as "applicant@company-1.com"
    When I am on the page for company number "5560360793"
    Then I should not see "db id"

  Scenario: Visitor does not see database id in list of Companies
    Given I am logged out
    When I am on the "all companies" page
    Then I should not see "db id"


  Scenario: Visitor does not see db id on Company page
    Given I am logged out
    When I am on the page for company number "5560360793"
    Then I should not see "db id"
