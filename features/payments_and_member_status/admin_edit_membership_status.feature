Feature: Admin edits membership status, dates, notes (membership info)

  As an admin
  I need to be able to change the membership status
  So that I can fix problems and grant or revoke membership for special reasons

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the following users exist:
      | email                     | admin | member | membership_number |
      | emma@mutts.com            |       | true   | 1001              |
      | bad-member@mutts.com      |       | true   |                   |
      | never-paid-user@mutts.com |       | false  |                   |
      | admin@shf.se              | true  | false  |                   |

    Given the following business categories exist
      | name  | description                     |
      | groom | grooming dogs from head to tail |
      | rehab | physical rehabilitation         |

    Given the following applications exist:
      | user_email           | company_number | categories   | state    |
      | emma@mutts.com       | 5562252998     | rehab, groom | accepted |
      | bad-member@mutts.com | 5562252998     | rehab, groom | accepted |


    Given the following payments exist
      | user_email           | start_date | expire_date | payment_type | status | hips_id |
      | emma@mutts.com       | 2017-10-1  | 2017-12-31  | member_fee   | betald | none    |
      | bad-member@mutts.com | 2017-10-31 | 2018-10-30  | member_fee   | betald | none    |


    Given the date is set to "2017-11-01"

    Given I am logged in as "admin@shf.se"


  @selenium @time_adjust
  Scenario: Admin edits membership expiration date and note
    Given I am on the "user details" page for "emma@mutts.com"
    Then user "emma@mutts.com" is paid through "2017-12-31"
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.payment.expire_date")
    And I should see t("activerecord.attributes.payment.notes")
    When I select radio button t("No")
    And I select "2018" in select list "payment[expire_date(1i)]"
    And I select "juni" in select list "payment[expire_date(2i)]"
    And I select "1" in select list "payment[expire_date(3i)]"
    And I fill in t("activerecord.attributes.payment.notes") with "Extended their membership to 1 juni 2018."
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)
    Then I should see "Extended their membership to 1 juni 2018."
    And user "emma@mutts.com" is paid through "2018-06-01"

  @selenium @time_adjust
  Scenario: Admin changes membership status from member to not a member
    Given I am on the "user details" page for "bad-member@mutts.com"
    When I click on t("users.user.edit_member_status")
    Then I should see t("users.user.edit_member_status")
    And I should see t("users.show.member")
    And I should see t("activerecord.attributes.payment.expire_date")
    And I should see t("activerecord.attributes.payment.notes")
    When I select radio button t("No")
    And I fill in t("activerecord.attributes.payment.notes") with "Changed to not a member."
    And I click on t("users.user.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades. (DOM/page partial _is_ updated in real life, but not with capybara)
    Then I should see membership status is t("users.show.not_a_member")
    And I should see "Changed to not a member."


  @selenium @time_adjust
  Scenario: Admin cannot change member status for someone that has never made a payment
    Given I am on the "user account" page for "never-paid-user@mutts.com"
    And user "emma@mutts.com" is paid through "2017-12-31"
    Then I should see t("payors.admin_cant_edit")
    And the link button t("users.user.edit_member_status") should be disabled

