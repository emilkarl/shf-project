Feature: Only admins and company members can edit a company

  As an admin or member of a company
  to control who can change information about the company
  Only admins and current members can edit company information


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                                     | admin | member |
      | paid_member@mutts.com                     |       | true   |
      | unpaid_member@mutts.com                   |       | true   |
      | mere_user@mutts.com                       |       | false  |
      | paid_member-no-name-co@example.com        |       | true   |
      | approved_applicant-no-name-co@example.com |       | false  |
      | new_applicant-no-name-co@example.com      |       | false  |
      | rejected_applicant-no-name-co@example.com |       | false  |
      | admin@shf.se                              | true  | true   |

    Given the following payments exist
      | user_email                         | start_date | expire_date | payment_type | status | hips_id |
      | paid_member@mutts.com              | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | paid_member-no-name-co@example.com | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |


    And the following companies exist:
      | name                  | company_number | email                             |
      | No More Snarky Barky  | 5560360793     | snarky@snarkybarky.com            |
      | Bowsers               | 2120000142     | bowwow@bowsersy.com               |
      | Lapsed Member Company | 6613265393     | lapsed@company.com                |
      |                       | 5867107939     | no-name-no-members-co@example.com |
      |                       | 2202000457     | no-name@example.com               |

    And the following applications exist:
      | user_email                                | company_number | state    |
      | paid_member@mutts.com                     | 5560360793     | accepted |
      | unpaid_member@mutts.com                   | 6613265393     | accepted |
      | mere_user@mutts.com                       | 2120000142     | accepted |
      | paid_member-no-name-co@example.com        | 2202000457     | accepted |
      | approved_applicant-no-name-co@example.com | 2202000457     | accepted |
      | new_applicant-no-name-co@example.com      | 2202000457     | new      |
      | rejected_applicant-no-name-co@example.com | 2202000457     | rejected |


  @time_adjust
  Scenario: Member can edit their company
    Given the date is set to "2017-10-01"
    Given I am logged in as "paid_member@mutts.com"
    And I am on the edit company page for "5560360793"
    Then I should see t("companies.edit.title", company_name: "No More Snarky Barky")


  # FIXME If someone is unpaid, they are not a member. This needs to be cleaned up
  Scenario: Unpaid member cannot edit their company
    Given I am logged in as "unpaid_member@mutts.com"
    And I am on the edit company page for "6613265393"
    Then I should not see t("companies.edit.title", company_name: "Lapsed Member Company")
    And I should see t("errors.not_permitted")

  Scenario: Prospective member can not edit their company
    Given I am logged in as "mere_user@mutts.com"
    And I am on the edit company page for "2120000142"
    Then I should not see t("companies.edit.title", company_name: "Bowsers")
    And I should see t("errors.not_permitted")

  Scenario: Visitor tries to edit a company
    Given I am Logged out
    And I am on the edit company page for "5560360793"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: User can not edit someone else's company
    Given I am logged in as "mere_user@mutts.com"
    And I am on the edit company page for "5560360793"
    Then I should see a message telling me I am not allowed to see that page


  Scenario: Applicant (approved app) cannot edit an incomplete (no name) company they belong to (must be a member)
    Given the date is set to "2017-10-01"
    And I am logged in as "approved_applicant-no-name-co@example.com"
    When I am the page for company number "2202000457"
    Then I should not see t("companies.edit_company")
    When I am on the edit company page for "2202000457"
    And  I should see a message telling me I am not allowed to see that page


  Scenario: Applicant (new app) cannot edit an incomplete (no name) company they belong to (must be a member)
    Given the date is set to "2017-10-01"
    And I am logged in as "new_applicant-no-name-co@example.com"
    When I am the page for company number "2202000457"
    Then I should not see t("companies.edit_company")
    When I am on the edit company page for "2202000457"
    And  I should see a message telling me I am not allowed to see that page


  Scenario: Applicant (rejected app) cannot edit an incomplete (no name) company they belong to (must be a member)
    Given the date is set to "2017-10-01"
    And I am logged in as "rejectedapplicant-no-name-co@example.com"
    When I am the page for company number "2202000457"
    Then I should not see t("companies.edit_company")
    When I am on the edit company page for "2202000457"
    And  I should see a message telling me I am not allowed to see that page


  Scenario: Member can edit an incomplete (no name) company they belong to
    Given the date is set to "2017-10-01"
    And I am logged in as "paid_member-no-name-co@example.com"
    And I am the page for company number "2202000457"
    When I click on t("companies.edit_company")
    Then I am on the edit company page for "2202000457"


  Scenario: Admin can edit a company that is not complete (no name and/or no members)
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5867107939"
    When I click on t("companies.edit_company")
    Then I am on the edit company page for "5867107939"

    When I am the page for company number "2202000457"
    And I click on t("companies.edit_company")
    Then I am on the edit company page for "2202000457"
