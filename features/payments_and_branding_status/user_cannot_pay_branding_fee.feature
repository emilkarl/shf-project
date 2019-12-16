Feature: User cannot pay a branding license fee

  As a user
  Because my application needs to be reviewed and approved to ensure I am a qualified member of the company on my application
  I cannot pay a branding license fee until I become a member

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the following users exist
      | email          | admin | member |
      | emma@mutts.com |       | false  |
      | admin@shf.se   | true  | false  |

    Given the following business categories exist
      | name  | description           |
      | rehab | physical rehabitation |

    Given the following companies exist:
      | name       | company_number | email               | region    |
      | HappyMutts | 2120000142     | woof@happymutts.com | Stockholm |

    And the following applications exist:
      | user_email     | company_number | categories | state        |
      | emma@mutts.com | 2120000142     | rehab      | under_review |


  @time_adjust
  Scenario: User does not see button to pay the branding license fee
    Given the date is set to "2018-7-01"
    And I am logged in as "emma@mutts.com"
    And I am the page for company number "2120000142"
    Then I should not see t("menus.nav.company.pay_branding_fee")
