Feature: Admin edits H-brand license status

  As an admin
  I want to be able to change certain attributes associated with companies' branding license status
  So that I can fix problems and grant or revoke brand licensing status


  Background:

    Given the date is set to "2017-10-01"

    Given the following users exist:
      | email          | admin | member | membership_number |
      | admin@shf.se   | true  | false  |                   |
      | emma@mutts.com |       | true   | 1001              |

    Given the following companies exist:
      | name       | company_number | email                 | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com   | Stockholm |

    Given the following payments exist
      | user_email     | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@mutts.com | 2017-10-1  | 2017-12-31  | branding_fee | betald | none    | 2120000142     |

    Given I am logged in as "admin@shf.se"


  @selenium @time_adjust
  Scenario: Admin edits branding status
    Given I am the page for company number "2120000142"
    Then I should see t("companies.show.hbrand_status_paid")
    And company number "2120000142" is paid through "2017-12-31"
    When I click on t("companies.show.edit_branding_status")
    Then I should see t("companies.show.edit_branding_status")
    And I should see t("activerecord.attributes.payment.expire_date")
    And I should see t("activerecord.attributes.payment.notes")
    When I select "2018" in select list "payment[expire_date(1i)]"
    And I select "juni" in select list "payment[expire_date(2i)]"
    And I select "1" in select list "payment[expire_date(3i)]"
    And I fill in t("activerecord.attributes.payment.notes") with "This is a note regarding this company."
    And I click on t("companies.company.submit_button_label")
    And I wait for all ajax requests to complete
    And I reload the page
    # ^^ should not have to do this - check later after upgrades
    Then company number "2120000142" is paid through "2018-06-01"
    And I should see "This is a note regarding this company."
