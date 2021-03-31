Feature: Show the 'is information complete? status to Admins and Members of a company

  As a member of a company or the admin
  So that the company is displayed to the public
  So that I can get business
  Show me if information required to display the company is still needed

  PivotalTracker: https://www.pivotaltracker.com/story/show/177274707


  Background:

    Given the date is set to "2019-06-06"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    Given the following kommuns exist:
      | name     |
      | Alingsås |
      | Bromölla |

    Given the following companies exist:
      | name                                  | company_number | email                      | region       | kommun   | city      | visibility     |
      | Co.1 - Addr Visible to Street Address | 5560360793     | hello@company-1.com        | Stockholm    | Alingsås | Harplinge | street_address |
      | Company2                              | 2120000142     | hello@company-2.com        | Västerbotten | Bromölla | Harplinge | street_address |
      | Company3                              | 6613265393     | hello@company-3.com        | Stockholm    | Alingsås | Harplinge | post_code      |
      | Company4                              | 6222279082     | hello@company-4.com        | Stockholm    | Alingsås | Harplinge | city           |
      | Company5                              | 8025085252     | hello@company-5.com        | Stockholm    | Alingsås | Harplinge | kommun         |
      | Co.6 - Address Not Visible            | 6914762726     | hello@addr-not-visible.com | Stockholm    | Alingsås | Harplinge | none           |
      | Company7                              | 7661057765     | hello@company-7.com        | Stockholm    | Alingsås | Harplinge | street_address |
      | Company8                              | 7736362901     | hello@company-8.com        | Stockholm    | Alingsås | Harplinge | street_address |

    And the following users exist:
      | email                            | admin | member |
      | member-1@addr-all-visible-1.com  |       | true   |
      | member@company-2.com             |       | true   |
      | applicant-6@addr-not-visible.com |       | false  |
      | member-6@addr-not-visible.com    |       | true   |
      | member-no-payments@company-3.com |       | true   |
      | member-no-payments@company-2.com |       | true   |
      | member-2@addr-all-visible-1.com  |       | true   |
      | admin@shf.se                     | true  | false  |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Rehab        |
      | Walker       |
      | JustForFun   |

    And the following applications exist:
      | user_email                       | company_number | categories                        | state    |
      | member-1@addr-all-visible-1.com  | 5560360793     | Groomer, JustForFun               | accepted |
      | member@company-2.com             | 2120000142     | Groomer, Trainer, Rehab           | accepted |
      | applicant-6@addr-not-visible.com | 6914762726     | Groomer                           | new      |
      | member-6@addr-not-visible.com    | 6914762726     | Psychologist, Groomer             | accepted |
      | member-no-payments@company-3.com | 6613265393     | Groomer                           | accepted |
      | member-no-payments@company-2.com | 2120000142     | Psychologist                      | accepted |
      | member-2@addr-all-visible-1.com  | 5560360793     | Groomer, JustForFun, Psychologist | accepted |


    And the following payments exist
      | user_email                       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member-1@addr-all-visible-1.com  | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member@company-2.com             | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-6@addr-not-visible.com    | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com  | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | member-2@addr-all-visible-1.com  | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | member@company-2.com             | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 2120000142     |
      | member-no-payments@company-3.com | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6613265393     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6222279082     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 8025085252     |
      | member-6@addr-not-visible.com    | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 6914762726     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7661057765     |
      | admin@shf.se                     | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 7736362901     |


    # -----------------------------------
  Scenario: Visitor does not see the is info complete status
    Given I am Logged out
    When I am the page for company number "5560360793"
    Then I should see "Co.1 - Addr Visible to Street Address"
    And I should not see t("companies.show.info_is_complete")

    When I am the page for company number "2120000142"
    Then I should see "Company2"
    And I should not see t("companies.show.info_is_complete")


  Scenario: Member of the company sees information_complete? status
    Given I am logged in as "member-1@addr-all-visible-1.com"
    When I am the page for company number "5560360793"
    And I should see "Co.1 - Addr Visible to Street Address"
    And I should see t("companies.show.info_is_complete")


  Scenario: Admin sees information_complete? status for all companies
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5560360793"
    Then I should see "Co.1 - Addr Visible to Street Address"
    And I should see t("companies.show.info_is_complete")

    When I am the page for company number "2120000142"
    Then I should see "Company2"
    And I should see t("companies.show.info_is_complete")
