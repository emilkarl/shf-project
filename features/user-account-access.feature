Feature: Show user account information only to those that should see it

  As a user
  Because my user account page has private member and payment status information
  Only I (and the admin) should be able to see it

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Background:

    Given the following users exist:
      | email            | admin | membership_number | member |
      | emma@example.com |       |                   |        |
      | lars@example.com |       | 101               | true   |
      | admin@shf.se     | true  |                   |        |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name        | company_number | email               | region       |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Västerbotten |


    And the following applications exist:
      | user_email       | contact_email       | company_number | state    |
      | lars@example.com | lars@happymutts.com | 5560360793     | accepted |
      | emma@example.com | emma@bowsers.com    | 2120000142     | new      |


    And the following membership packets have been sent:
      | user_email       | date_sent  |
      | lars@example.com | 2019-03-01 |


  Scenario: a visitor cannot see a user account page
    Given I am logged out
    When I am on the "user account" page for "lars@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: user cannot see the user account page for another user
    Given I am logged in as "emma@example.com"
    When I am on the "user account" page for "lars@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: a user can see their own user account page
    Given I am logged in as "emma@example.com"
    When I am on the "user account" page for "emma@example.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("users.show.email")
    And I should see "emma@example.com"


  Scenario: member cannot see the user page for another user
    Given I am logged in as "lars@example.com"
    When I am on the "user account" page for "emma@example.com"
    Then I should see t("errors.not_permitted")


  Scenario: a member can see their own user page
    Given I am logged in as "lars@example.com"
    When I am on the "user account" page for "lars@example.com"
    Then I should not see t("errors.not_permitted")
    And I should see t("users.show.email")
    And I should see "lars@example.com"
    And I should see t("users.show.membership_number")


