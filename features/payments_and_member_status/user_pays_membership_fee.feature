Feature: User pays membership fee

  As a user
  So that I can be approved for membership
  I need to be able to pay my membership fee

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the following users exist:
      | email                    | admin | member |
      | emma-applicant@mutts.com |       | false  |
      | admin@shf.se             | true  | false  |

    Given the following business categories exist
      | name  | description           |
      | rehab | physical rehabitation |

    And the following applications exist:
      | user_email               | company_number | categories | state    |
      | emma-applicant@mutts.com | 5562252998     | rehab      | accepted |


  @time_adjust
  Scenario: User pays membership fee (post-2017)
    Given the date is set to "2018-7-01"
    And I am logged in as "emma-applicant@mutts.com"
    And I am on the "user account" page for "emma-applicant@mutts.com"
    And I should see t("menus.nav.members.pay_membership")
    And I should see t("payors.due")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2019-06-30"
    Then the user is paid through "2019-06-30"

  @selenium
  Scenario: User starts payment process then abandons it so no payment is made
    Given the date is set to "2017-12-31"
    And I am logged in as "emma-applicant@mutts.com"
    And I am on the "user account" page for "emma-applicant@mutts.com"
    When I click on t("menus.nav.members.pay_membership")
    And I abandon the payment
    Then user "emma-applicant@mutts.com" has no payments
    And I should not see t("payments.success.success")
    And the user is paid through ""

  Scenario: User incurs error in payment processing so no payment is made
    Given the date is set to "2017-12-31"
    And I am logged in as "emma-applicant@mutts.com"
    And I am on the "user account" page for "emma-applicant@mutts.com"
    Then I click on t("menus.nav.members.pay_membership")
    And I incur an error in payment processing
    And I should see t("payments.error.error")
    Then the user is paid through ""
