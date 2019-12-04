Feature: Show social media links for a company
  As a company
  So that I can have site visitors also view my social media
  Show social media icons for the social media URLs that are recorded for the company

  Background:
    Given the following users exist:
      | email                       | admin | member |
      | member@all-social-media.com |       | true   |
      | member@only-instagram.com   |       | true   |
      | member@no-social-media.com  |       | true   |
      | admin@shf.se                | true  | true   |
    And the following companies exist:
      | name             | company_number | email                      | facebook_url                | youtube_url                | instagram_url                     |
      | All Social Media | 2120000142     | hello@all-social-media.com | http://example.com/facebook | http://example.com/youtube | http://example.com/instagram      |
      | Only Instagram   | 5560360793     | hello@only-instagram.com   |                             |                            | http://example.com/only-instagram |
      | No Social Media  | 7661057765     | hello@no-social-media.com  |                             |                            |                                   |
    And the following applications exist:
      | user_email                  | company_number | state    |
      | member@all-social-media.com | 2120000142     | accepted |
      | member@only-instagram.com   | 5560360793     | accepted |
      | member@no-social-media.com  | 7661057765     | accepted |
    Given the following payments exist
      | user_email                  | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@all-social-media.com | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@all-social-media.com | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 2120000142     |
      | member@only-instagram.com   | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@only-instagram.com   | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 5560360793     |
      | member@no-social-media.com  | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@no-social-media.com  | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 7661057765     |

  Scenario: Company has all social media urls; all social media icons are shown
    Given I am logged in as "member@all-social-media.com"
    And I am on the page for company number "2120000142"
    Then I should see an icon with CSS class "fa-facebook" that is linked to "http://example.com/facebook"
    And I should see an icon with CSS class "fa-youtube" that is linked to "http://example.com/youtube"
    And I should see an icon with CSS class "fa-instagram" that is linked to "http://example.com/instagram"

  Scenario: Company only has Instagram; only that icon is shown
    Given I am logged in as "member@only-instagram.com"
    And I am on the page for company number "5560360793"
    Then I should not see an icon with CSS class "fa-facebook"
    And I should not see an icon with CSS class "fa-youtube"
    And I should see an icon with CSS class "fa-instagram" that is linked to "http://example.com/only-instagram"

  Scenario: Company has no social media urls; no social media icons are shown
    Given I am logged in as "member@no-social-media.com"
    And I am on the page for company number "7661057765"
    Then I should not see an icon with CSS class "fa-facebook"
    And I should not see an icon with CSS class "fa-youtube"
    And I should not see an icon with CSS class "fa-instagram"
