Feature: Admin filters and searches users

  As an admin
  I would like to filter and search
  to quickly and easily find users I am interested in


  Background:

    Given the following users exist
      | first_name | last_name | email                           | admin | membership_number | member |
      | John       | Adams     | ja@hotmail.com                  | false | 1                 | false  |
      | Sarah      | Connor    | sconnor@example.com             | false | 2                 | true   |
      | Lars       | Member    | lars-member@happymutts.com      | false | 101               | true   |
      | Hannah     | Member    | hannah-member@happymutts.com    | false | 102               | true   |
      | Former     | Member    | former-member@happymutts.com    | false |                   | false  |
      | Luke       | Skywalker | luke@force.net                  | false | 14                | false  |
      | admin      | admin     | admin@sverigeshundforetagare.se | true  | 3                 | false  |


    And the following applications exist:
      | user_email                   | state                 | company_number |
      | ja@hotmail.com               | waiting_for_applicant | 0000000000     |
      | sconnor@example.com          | accepted              | 0000000000     |
      | luke@force.net               | rejected              | 0000000000     |
      | lars-member@happymutts.com   | accepted              | 5560360793     |
      | hannah-member@happymutts.com | accepted              | 5560360793     |

    And the following membership packets have been sent:
      | user_email                   | date_sent  |
      | sconnor@example.com          | 2019-03-01 |
      | lars-member@happymutts.com   | 2019-02-01 |
      | former-member@happymutts.com | 2018-02-01 |


    And I am logged in as "admin@sverigeshundforetagare.se"
    And I am on the "all users" page


  # =================================================================
  # FILTERS

  Scenario: Admin filters users by membership status
    When I click the radio button with id "radio-membership-filter-all"
    And I click on t("search")
    Then I should see "sconnor@example.com"
    And I should see "luke@force.net"
    And I should see "ja@hotmail.com"

    When I click the radio button with id "radio-membership-filter-members"
    And I click on t("search")
    Then I should see "sconnor@example.com"
    And I should not see "luke@force.net"
    And I should not see "ja@hotmail.com"

    When I click the radio button with id "radio-membership-filter-not-members"
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should see "ja@hotmail.com"
    And I should not see "sconnor@example.com"


  # =================================================================
  # SEARCHING

  Scenario: Admin searches for luke
    When I fill in t("users.search_form.profile_email") with "luke"
    And I click on t("search")
    Then I should see "luke@force.net"
    And I should not see "sconnor@example.com"


  Scenario: Admin searches for @sverigeshundföretagare.se
    When I fill in t("users.search_form.profile_email") with "@sverigeshundföretagare.se"
    And I click on t("search")
    Then I should not see "admin@sverigeshundforetagare.se"
    And I should see t("users.index.no_search_results")


  Scenario: Admin searches for membership number
    And I select "1" in select list t("users.search_form.membership_number")
    And I click on t("search")
    Then I should see "ja@hotmail.com"
    And I should not see "luke@force.net"
