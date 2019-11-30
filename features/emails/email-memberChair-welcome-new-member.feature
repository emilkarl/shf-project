Feature: Membership chair gets an email when a new membership has been granted.

  As the membership chair,
  So that I can welcome a new member on social media, send a membership package, etc.,
  I should get an email when someone has been granted membership for the first time.


  Pivotal Tracker story: https://www.pivotaltracker.com/story/show/169273314


  Background:

    Given the date is set to "2018-10-01"
    And the App Configuration is not mocked and is seeded


    Given the following users exist:
      | email                               | admin | member |
      | emma-approved@happymutts.se         |       | false  |
      | lars-approved@no-license-payment.se |       | false  |
      | admin@shf.com                       | true  |        |


    And the following business categories exist
      | name    |
      | Groomer |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name                   | company_number | email                      | region    |
      | Happy Mutts            | 5562252998     | voof@happymutts.se         | Stockholm |
      | No License Payment Co. | 2120000142     | voof@no-license-payment.se | Stockholm |

    And the following applications exist:
      | user_email                          | company_number | categories | state    |
      | emma-approved@happymutts.se         | 5562252998     | Groomer    | accepted |
      | lars-approved@no-license-payment.se | 2120000142     | Groomer    | accepted |

    And the following payments exist
      | user_email                  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma-approved@happymutts.se | 2018-10-1  | 2019-09-30  | branding_fee | betald | none    | 5562252998     |



  @time_adjust @selenium @focus
  Scenario: A new membership is granted; membership chair gets email
    Given the date is set to "2019-01-01"
    And I am logged in as "emma-approved@happymutts.se"
    And I am on the "user details" page for "emma-approved@happymutts.se"
    And I should see t("menus.nav.members.pay_membership")
    And I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    Then I should see t("payments.success.success")
    And "medlem@sverigeshundforetagare.se" should receive an email with subject t("mailers.admin_mailer.new_membership_granted_co_hbrand_paid.subject")


  @time_adjust @selenium
  Scenario: [SAD PATH] Applicant does not pay all fees, membership is not granted; no email is sent (post 2017)
    Given the date is set to "2019-01-01"
    And I am logged in as "emma-approved@happymutts.se"
    And I am on the "user details" page for "emma-approved@happymutts.se"
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I abandon the payment
    And I should not see t("payments.success.success")
    Then "medlem@sverigeshundforetagare.se" should receive no emails


  @time_adjust @selenium
  Scenario: [SAD PATH] License fee for company is not paid, so no email is sent
    Given the date is set to "2019-01-01"
    And I am logged in as "lars-approved@no-license-payment.se"
    And I am on the "user details" page for "lars-approved@no-license-payment.se"
    And I should see t("menus.nav.members.pay_membership")
    Then I click on t("menus.nav.members.pay_membership")
    And I complete the membership payment
    And I should see t("payments.success.success")
    Then "medlem@sverigeshundforetagare.se" should receive no emails
