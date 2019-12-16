Feature: Show user account (details) information to me

  As a user
  So that I know what information SHF has about me
  Show me my user account page

  PT:  https://www.pivotaltracker.com/story/show/140358959


  Proof of Membership and Company H-Branding Information: see separate features
  features/user_account/company_h_brand.feature
  features/user_account/proof_of_membership.feature

  Background:

    Given the date is set to "2018-06-06"

    Given the following users exist:
      | email                              | admin | membership_number | member | first_name | last_name     |
      | emma-member@example.com            |       | 1001              | true   | Emma       | IsAMember     |
      | lars-member@example.com            |       | 101               | true   |            |               |
      | admin@shf.se                       | true  |                   |        |            |               |
      | applied@example.com                |       |                   | false  | Applied    | NotAMember    |
      | rejected@example.com               |       |                   | false  | Rejected   | NotAMember    |
      | registered-not-applied@example.com |       |                   | false  | Registered | NotAppliedYet |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name                | company_number | email               | region       |
      | Happy Mutts         | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers             | 2120000142     | bark@bowsers.com    | Västerbotten |


    And the following applications exist:
      | user_email              | contact_email              | company_number | state    |
      | lars-member@example.com | lars-member@happymutts.com | 5560360793     | accepted |
      | emma-member@example.com | emma-member@bowsers.com    | 2120000142     | accepted |
      | applied@example.com     | applied@bowsers.com        | 2120000142     | new      |
      | rejected@example.com    | rejected@bowsers.com       | 2120000142     | rejected |


    And the following payments exist
      | user_email              | start_date | expire_date | payment_type | status | hips_id |
      | emma-member@example.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |
      | lars-member@example.com | 2018-05-05 | 2019-05-04  | member_fee   | betald | none    |


    And the following membership packets have been sent:
      | user_email              | date_sent  |
      | lars-member@example.com | 2018-05-06 |


  Scenario: User sees their full name and login email
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should see "Emma IsAMember"
    And I should see t("users.show.email")
    And I should see "emma-member@example.com"



  # ======================
  # Membership Information

  Scenario: User should see 'Membership' section title
    Given I am logged in as "applied@example.com"
    When I am on the "user details" page for "applied@example.com"
    Then I should see t("membership")


  # Is not a member

  Scenario: User does not have a membership number so doesn't see it
    Given I am logged in as "applied@example.com"
    When I am on the "user details" page for "applied@example.com"
    Then I should not see t("users.show.membership_number")


  Scenario: User sees their membership status: 'not a member'
    Given I am logged in as "rejected@example.com"
    When I am on the "user details" page for "rejected@example.com"
    Then I should see "Status"
    And I should see t("users.show.not_a_member")


  # Is a member

  Scenario: Member sees their membership number
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should see t("users.show.membership_number")
    And I should see "1001"


  Scenario: Member sees their membership status (is a member)
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should see "Status"
    And I should see t("users.show.is_a_member")


  Scenario: Member sees the date their membership term is paid through
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should see t("users.show.term_paid_through")
    And the user is paid through "2018-12-31"


  # ======================
  # Application Information

  Scenario: User should see 'Application' section title
    Given I am logged in as "applied@example.com"
    When I am on the "user details" page for "applied@example.com"
    Then I should see t("application")


  Scenario: If no application, should show 'no application'
    Given I am logged in as "registered-not-applied@example.com"
    When I am on the "user details" page for "registered-not-applied@example.com"
    Then I should see t("application")
    And I should see t("none_n")
    And I should see 0 shf_application rows


  Scenario: User has applied, shows email, status (new), company number and company name
    Given I am logged in as "applied@example.com"
    When I am on the "user details" page for "applied@example.com"
    Then I should see t("application")
    And I should see t("activerecord.attributes.shf_application.contact_email")
    And I should see t("activerecord.attributes.shf_application.state")
    And I should see t("activerecord.attributes.shf_application.company_number")
    And I should see t("activerecord.attributes.company.name")
    And I should see "applied@bowsers.com" in the minimal shf application info row
    And I should see t("shf_applications.state.new") in the minimal shf application info row
    And I should see "Bowsers" in the minimal shf application info row
    And I should see "2120000142" in the minimal shf application info row


  Scenario: User app was rejected; shows 'rejected' status
    Given I am logged in as "rejected@example.com"
    When I am on the "user details" page for "rejected@example.com"
    Then I should see "rejected@bowsers.com" in the minimal shf application info row
    And I should see t("shf_applications.state.rejected") in the minimal shf application info row
    And I should see "Bowsers" in the minimal shf application info row
    And I should see "2120000142" in the minimal shf application info row


  # Proof of Membership and Company H-Branding Information: see separate features


  # ======================================
  # Who can and cannot see the information

  Scenario: a visitor cannot see a user page
    Given I am logged out
    When I am on the "user details" page for "lars-member@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: user cannot see the user page for another user
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "lars-member@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: a user can see their own user page
    Given I am logged in as "emma-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("users.show.email")
    And I should see "emma-member@example.com"


  Scenario: member cannot see the user page for another user
    Given I am logged in as "lars-member@example.com"
    When I am on the "user details" page for "emma-member@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: a member can see their own user page
    Given I am logged in as "lars-member@example.com"
    When I am on the "user details" page for "lars-member@example.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("users.show.email")
    And I should see "lars-member@example.com"
    And I should see t("users.show.membership_number")


