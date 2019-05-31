Feature: Membership status updated due to payments or expiration

  As a member
  So that my membership status is always current and accurate
  The system must review dates, payments, and actions nightly

  Membership application state, membership payments, and H-branding (license) payments
  all affect membership status.
  The particular date also affects status:  has a membership expired?
  These all need to accurately change membership status.

  Background:

    Given the App Configuration is not mocked and is seeded

    Given the following users exist
      | email               | admin | member | membership_number |
      | emma@mutts.com      |       | true   | 1001              |
      | bob@snarkybarky.com |       | true   | 1002              |
      | lars@newapp.com     |       | false  |                   |
      | admin@shf.se        | true  | false  |                   |

    Given the following companies exist:
      | name                 | company_number | email                  | region    |
      | HappyMutts           | 2120000142     | woof@happymutts.com    | Stockholm |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |
      | LarsCo               | 5562252998     | lars@newapp.com        | Stockholm |

    Given the following applications exist:
      | user_email          | company_number | category_name | state    |
      | emma@mutts.com      | 2120000142     | rehab         | accepted |
      | bob@snarkybarky.com | 5560360793     | grooming      | accepted |
      | lars@newapp.com     | 5562252998     | rehab         | new      |


    Given the date is set to "2017-12-31"

    Given the following payments exist
      | user_email          | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com      | 2017-12-31 | 2018-12-31  | member_fee   | betald | none    | 2120000142     |
      | emma@mutts.com      | 2017-12-31 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
      | bob@snarkybarky.com | 2018-03-01 | 2019-02-28  | member_fee   | betald | none    | 5560360793     |
      | bob@snarkybarky.com | 2018-03-02 | 2019-03-01  | branding_fee | betald | none    | 5560360793     |



  # TODO should these be put into already existing .feature files?

  # --- MEMBERSHIP PAYMENTS -------------

  @time_adjust
  Scenario: Membership payment made before membership expires
    Given the date is set to "2018-11-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    Then I should be a member
    And My membership expiration date is 2018-12-31
    And I should see "1001"
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should be a member
    And My membership expiration date is 2019-12-31
    And I should see "2019-12-31"


  @time_adjust
  Scenario: Membership payment made 1 day after membership expires
    Given the date is set to "2019-01-01"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should not be a member
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should be a member
    And My membership expiration date is 2019-12-31
    And I should see "2019-12-31"


  @time_adjust
  Scenario: Membership payment is made on expiration date
    Given the date is set to "2018-12-31"
    And I am logged in as "emma@mutts.com"
    And I am on the "user details" page for "emma@mutts.com"
    And I should not be a member
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    And I should see "2019-12-30"
    And I should be a member
    And My membership expiration date is 2019-12-30



  # H-BRANDING (LICENSE) PAYMENT


  # H-branding expires for a company



  # APPLICATION STATE


  # CODE OF CONDUCT (TBD)

