Feature: Edit the social media urls (links) for a company

  Background:
    Given the following users exist:
      | email            | admin | member |
      | member@mutts.com |       | true   |
      | admin@shf.se     | true  | true   |
    And the following companies exist:
      | name    | company_number | email              | facebook_url          | youtube_url          | instagram_url          |
      | Bowsers | 2120000142     | bowwow@bowsers.com | original-facebook-url | original-youtube-url | original-instagram-url |
    And the following applications exist:
      | user_email       | company_number | state    |
      | member@mutts.com | 2120000142     | accepted |
    Given the following payments exist
      | user_email       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 2120000142     |

  Scenario: All social media urls are changed
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    Then I should see t("activerecord.attributes.company.facebook_url")
    And I should see t("activerecord.attributes.company.youtube_url")
    And I should see t("activerecord.attributes.company.instagram_url")
    When I fill in t("activerecord.attributes.company.facebook_url") with "http://example.com/facebook"
    And I fill in t("activerecord.attributes.company.youtube_url") with "http://example.com/youtube"
    And I fill in t("activerecord.attributes.company.instagram_url") with "http://example.com/instagram"
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And I should see an icon with CSS class "fa-facebook" that is linked to "http://example.com/facebook"
    And I should see an icon with CSS class "fa-youtube" that is linked to "http://example.com/youtube"
    And I should see an icon with CSS class "fa-instagram" that is linked to "http://example.com/instagram"
