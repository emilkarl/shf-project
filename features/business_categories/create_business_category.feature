Feature: Admin creates business categories; access

  As an admin
  So that members can select the categories that their business falls into
  & so that visitors can search for the business categories they are interested in,
  I need to be able to create business categories

  PT: https://www.pivotaltracker.com/story/show/135009339

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    Given the following users exist:
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And I am logged in as "admin@shf.com"

  # =================================================================================================

  @selenium @admin
  Scenario Outline: Admin creates a new Business Category
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    When I fill in the translated form with data:
      | business_categories.category_new_row.name | business_categories.category_new_row.description | business_categories.category_new_row.apply_qs_url |
      | <category_name>                           | <category_description>                           | <link>                                            |
    And I click on t("business_categories.form.save")

    Then I should see "<category_name>"
    And I should see "<category_description>"
    And I should see "<link>"

    Scenarios:
      | category_name    | category_description                                                                                | link                       |
      | dog grooming     | washing, brushing, cutting, and trimming hair and nails on dogs                                     |                            |
      | agility training | training dogs to complete agility courses, from beginners to expert competition level               | http://example.com/agility |
      | dog psychology   | addresses behavioural issues of dogs, including the emotional, cognitive, and psycho-social aspects |                            |
      | carting/drafting |                                                                                                     | http://example.com         |


  @selenium @admin
  Scenario Outline: Create a new category - when things go wrong
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    When I fill in the translated form with data:
      | business_categories.category_new_row.name | business_categories.category_new_row.description |
      | <category_name>                           | <category_description>                           |
    When I click on t("business_categories.form.save")
    Then I should see <error>

    Scenarios:
      | category_name | category_description | error                      |
      |               |                      | t("errors.messages.blank") |
      |               | some description     | t("errors.messages.blank") |


  @selenium @admin
  Scenario: Category name is a required field
    Given I am on the "business categories" page
    And I click on t("business_categories.new.title")
    Then the field t("business_categories.category_new_row.name") should have a required field indicator


  @user
  Scenario: Listing Business Categories restricted for Non-admins
    Given I am logged in as "applicant@random.com"
    And I am on the "business categories" page
    Then I should see a message telling me I am not allowed to see that page


  @visitor
  Scenario: Listing Business Categories restricted for visitors
    Given I am Logged out
    And I am on the "business categories" page
    Then I should see a message telling me I am not allowed to see that page
