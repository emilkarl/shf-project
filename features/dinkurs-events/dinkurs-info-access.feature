Feature: Only current Company members and admins can see the dinkurs id, button to get events

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                         | admin | membership_status | member | agreed_to_membership_guidelines | first_name | last_name |
      | mutts_member_1@mutts.com      |       | current_member    | true   | true                            | First      | Member    |
      | mutts_member_2@mutts.com      |       | current_member    | true   | true                            | Second     | Member    |
      | mutts_lapsed@mutts.com        |       | in_grace_period   |        | true                            | PastDue    | Member    |
      | mutts_former_member@mutts.com |       | former_member     |        | true                            | Former     | Member    |
      | registered-only@mail.com      |       |                   |        |                                 | Registered | Only      |
      | admin@shf.se                  | true  |                   |        |                                 |            |           |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following kommuns exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name  | company_number | email          | region    | kommun    | dinkurs_company_id      | show_dinkurs_events |
      | Mutts | 5560360793     | info@mutts.com | Stockholm | Stockholm | fake-dinkurs-company-id | true                |

    And the following payments exist
      | user_email                    | start_date | expire_date | payment_type | status | hips_id | company_number |
      | mutts_member_1@mutts.com      | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |
      | mutts_member_1@mutts.com      | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | mutts_member_2@mutts.com      | 2017-01-01 | 2017-12-31  | member_fee   | betald | none    |                |
      | mutts_lapsed@mutts.com        | 2016-06-01 | 2017-05-31  | member_fee   | betald | none    |                |
      | mutts_former_member@mutts.com | 2012-01-01 | 2012-12-31  | member_fee   | betald | none    |                |

    And the following applications exist:
      | user_email                    | company_number | state    |
      | mutts_member_1@mutts.com      | 5560360793     | accepted |
      | mutts_member_2@mutts.com      | 5560360793     | accepted |
      | mutts_lapsed@mutts.com        | 5560360793     | accepted |
      | mutts_former_member@mutts.com | 5560360793     | accepted |

    And the following memberships exist:
      | email                         | first_day  | last_day   |
      | mutts_member_1@mutts.com      | 2017-01-01 | 2017-12-31 |
      | mutts_member_2@mutts.com      | 2017-01-01 | 2017-12-31 |
      | mutts_lapsed@mutts.com        | 2016-06-01 | 2017-05-31 |
      | mutts_former_member@mutts.com | 2012-01-01 | 2012-12-31 |


    And the date is set to "2017-06-06"

    # ---------------------------------------------------------------------------------------------

  Scenario: Visitors cannot see the company Dinkurs id or get Dinkurs events button
    Given I am logged out
    And I am the page for company number "5560360793"
    Then I should not see t("companies.show.dinkurs_key")
    And I should not see "fake-dinkurs-company-id"
    And I should not see t("companies.show.dinkurs_fetch_events")


  Scenario: Users cannot see the company Dinkurs id or get Dinkurs events button
    Given I am logged in as "registered-only@mail.com"
    And I am the page for company number "5560360793"
    Then I should not see t("companies.show.dinkurs_key")
    And I should not see "fake-dinkurs-company-id"
    And I should not see t("companies.show.dinkurs_fetch_events")


  Scenario Outline: Company members that are not current cannot see the company Dinkurs id and get Dinkurs events button
    Given I am logged in as "<shf_user>"
    And I am the page for company number "5560360793"
    Then I should not see t("companies.show.dinkurs_key")
    And I should not see "fake-dinkurs-company-id"
    And I should not see t("companies.show.dinkurs_fetch_events")
    And I am logged out

    Scenarios:
      | shf_user                      |
      | mutts_former_member@mutts.com |
      | mutts_lapsed@mutts.com        |


  Scenario Outline: Current company members can see the company Dinkurs id and get Dinkurs events button
    Given I am logged in as "<shf_user>"
    And I am the page for company number "5560360793"
    Then I should see t("companies.show.dinkurs_key")
    And I should see "fake-dinkurs-company-id"
    And I should see button t("companies.show.dinkurs_fetch_events")

    Scenarios:
      | shf_user                 |
      | mutts_member_1@mutts.com |
      | mutts_member_2@mutts.com |


  Scenario: Admin can see the company Dinkurs id and get Dinkurs events button
    Given I am logged in as "admin@shf.se"
    And I am the page for company number "5560360793"
    Then I should see t("companies.show.dinkurs_key")
    And I should see "fake-dinkurs-company-id"
    And I should see button t("companies.show.dinkurs_fetch_events")
