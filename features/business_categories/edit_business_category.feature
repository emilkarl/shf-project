Feature: Admin edits business categories

  As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to edit and update them

  PT: https://www.pivotaltracker.com/story/show/135009339


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    Given the following users exist:
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |

  @selenium
  Scenario: Admin wants to edit a business category
    Given I am logged in as "admin@shf.com"
    And I am on the "business categories" page
    When I click the icon with CSS class "edit" for the row with "dog grooming"
    Then I should see t("business_categories.index.edit_category")
    And I fill in t("activerecord.attributes.business_category.name") with "doggy grooming"
    And I click on t("save")
    And I should see "doggy grooming"

  @selenium
  Scenario: Admin makes a mistake when editing a business category = sad path
    Given I am logged in as "admin@shf.com"
    And I am on the "business categories" page
    Then I should see "dog crooning"
    And I should see "dog grooming"
    When I click the icon with CSS class "edit" for the row with "dog crooning"

    Then I should see t("business_categories.index.edit_category")
    And I fill in t("activerecord.attributes.business_category.name") with ""
    And I click on t("save")
    Then I should see error t("activerecord.attributes.business_category.name") t("errors.messages.blank")

  Scenario: A non-admin user cannot edit business categories
    Given I am logged in as "applicant@random.com"
    And I navigate to the business category edit page for "dog grooming"
    Then I should see a message telling me I am not allowed to see that page

  Scenario: A visitor cannot edit business categories
    Given I am Logged out
    And I navigate to the business category edit page for "dog grooming"
    Then I should see a message telling me I am not allowed to see that page
