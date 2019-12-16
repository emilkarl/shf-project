Feature: Member pays membership fee

  As a member
  So that I can maintain my membership
  I need to be able to pay my membership fee

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the date is set to "2018-01-01"

    Given the following users exist:
      | email          | admin | member    | membership_number |
      | emma@mutts.com |       | true      | 1001              |
      | admin@shf.se   | true  | false     |                   |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |

    Given the following applications exist:
      | user_email     | company_number | state    |
      | emma@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com | 2018-01-1  | 2018-12-31  | member_fee   | betald | none    |

  @time_adjust
  Scenario: Member pays membership fee after term expires (after prior payment expiration date)
    Given the date is set to "2019-02-12"
    And I am logged in as "emma@mutts.com"
    And I am on the "user account" page for "emma@mutts.com"
    And I should see "1001"
    And I should see t("payors.past_due")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    #And I should see t("payors.paying_now_extends_until", fee_name: 'membership fee', term_name: 'membership', extended_end_date: '2020-02-11')
    Then the user is paid through "2020-02-11"

  @time_adjust
  Scenario: Member pays fee before term expires and extends membership
    Given the date is set to "2018-12-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user account" page for "emma@mutts.com"
    And I should see "1001"
    And I should see t("payors.due_by", due_date: '2018-12-31')
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    Then the user is paid through "2019-12-31"
    #And I should see t("payors.paying_now_extends_until", fee_name: 'membership fee', term_name: 'membership', extended_end_date: '2019-12-31')


  @time_adjust
  Scenario: Member pays fee 'too soon' (way early) and extends membership
    Given the date is set to "2018-01-02"
    And I am logged in as "emma@mutts.com"
    And I am on the "user account" page for "emma@mutts.com"
    And I should see "1001"
    And I should see t("payors.too_early")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    Then the user is paid through "2019-12-31"
    #And I should see t("payors.paying_now_extends_until", fee_name: 'membership fee', term_name: 'membership', extended_end_date: '2019-12-31')


  @time_adjust
  Scenario: Membership expires so member can no longer edit company
    Given the date is set to "2018-10-01"
    And I am logged in as "emma@mutts.com"
    And I am on the page for company number "2120000142"
    And I should see t("companies.edit_company")
    And I should see t("companies.show.add_address")
    And I am logged out
    Then the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am on the page for company number "2120000142"
    And I should not see t("companies.edit_company")
    And I should not see t("companies.show.add_address")

  @selenium
  Scenario: Member starts payment process then abandons it so no payment is made
    Given the date is set to "2018-12-31"
    And I am logged in as "emma@mutts.com"
    And I am on the "user account" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I abandon the payment
    And I should not see t("payments.success.success")
    Then the user is paid through "2018-12-31"

  Scenario: Member incurs error in payment processing so no payment is made
    Given the date is set to "2018-12-31"
    And I am logged in as "emma@mutts.com"
    And I am on the "user account" page for "emma@mutts.com"
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I incur an error in payment processing
    And I should see t("payments.error.error")
    Then the user is paid through "2018-12-31"
