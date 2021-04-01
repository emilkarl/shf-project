Feature: Member pays membership fee

  As a member
  So that I can get or renew my membership
  I need to be able to pay my membership fee

  Background:
    Given the App Configuration is not mocked and is seeded
    And the grace period is 4 days

    And the Membership Ethical Guidelines Master Checklist exists

    Given the date is set to "2018-01-01"

    Given the following users exist:
      | email          | admin | member | membership_number | agreed_to_membership_guidelines |
      | emma@mutts.com |       | true   | 1001              | true                            |
      | admin@shf.se   | true  | false  |                   |                                 |


    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |

    Given these files have been uploaded:
      | user_email     | file name | description                               |
      | emma@mutts.com | image.png | Image of a class completion certification |

    Given the following memberships exist:
      | email          | first_day | last_day   |
      | emma@mutts.com | 2018-01-1 | 2018-12-31 |


  @time_adjust
  Scenario: Member pays membership fee after term expires (after prior payment expiration date)
    Given the date is set to "2019-01-02"
    And I am logged in as "emma@mutts.com"
    And I am in the grace period
    And I have met all the non-payment requirements for renewing my membership
    And I am on the "user account" page for "emma@mutts.com"
    Then I should see t("users.renewal.renewal_overdue_warning")
    When I click on t("users.renewal.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And the user is paid through "2020-01-01"
    And I should be a current member
    And I should see "1001"


  @time_adjust
  Scenario: Member pays fee before term expires and extends membership
    Given the date is set to "2018-12-01"
    And I am logged in as "emma@mutts.com"
    And I am a current member
    And I have met all the non-payment requirements for membership
    When I am on the "user account" page for "emma@mutts.com"
    And show me the page
    Then I should see "1001"
    And I should see t("payors.due_by", due_date: '2018-12-31')
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And the user is paid through "2019-12-31"
    And I should be a current member
    #And I should see t("payors.paying_now_extends_until", fee_name: 'membership fee', term_name: 'membership', extended_end_date: '2019-12-31')


  @time_adjust
  Scenario: Member pays fee early and extends membership
    Given the date is set to "2018-11-20"
    And I am logged in as "emma@mutts.com"
    And I am a current member
    When I am on the "user account" page for "emma@mutts.com"
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And the user is paid through "2019-12-31"
    And I should be a current member


  @time_adjust
  Scenario: Membership expires so member can no longer edit company
    Given the date is set to "2018-10-01"
    And I am logged in as "emma@mutts.com"
    And I am a member
    When I am on the page for company number "2120000142"
    Then I should see t("companies.edit_company")
    And I should see t("companies.show.add_address")
    Given I am logged out
    And the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am not a current member
    When I am on the page for company number "2120000142"
    Then I should not see t("companies.edit_company")
    And I should not see t("companies.show.add_address")


  @selenium
  Scenario: Member starts payment process then abandons it so no payment is made
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    When I am on the "user account" page for "emma@mutts.com"
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I abandon the payment by going back to the previous page
    Then I should not see t("payments.success.success")
    And the user is paid through "2018-12-31"


  Scenario: Member incurs error in payment processing so no payment is made
    Given the date is set to "2018-12-30"
    And I am logged in as "emma@mutts.com"
    And I am a current member
    When I am on the "user account" page for "emma@mutts.com"
    Then I should see "1001"
    When I click on t("menus.nav.members.pay_membership")
    And I incur an error in payment processing
    Then I should see t("payments.error.error")
    And the user is paid through "2018-12-31"
