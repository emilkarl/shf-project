Feature: Admin can create and delete business subcategories

  As an admin
  So that members can select the subcategories that apply to their business
  & so that visitors can search for the business subcategories they are interested in,
  I need to be able to create business subcategories


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And the following business categories exist
      | name         | description      | subcategories          |
      | dog grooming | grooming dogs    | light trim, custom cut |

    And I am logged in as "admin@shf.com"

  @selenium
  Scenario Outline: Admin creates new Business Subcategories
    Given I am on the "business categories" page
    And I click the icon with CSS class "add-entity-button" for the row with "dog grooming"
    And I should see t("business_categories.index.add_subcategory")
    When I fill in the translated form with data:
      | activerecord.attributes.business_category.name | activerecord.attributes.business_category.description |
      | <subcategory_name>                             | <subcategory_description>                             |

    When I click on t("save")
    Then I should see "<subcategory_name>"

    Scenarios:
      | subcategory_name    | subcategory_description         |
      | overall grooming    | full service grooming           |
      | trim nails          | so you don't get scratched!     |
      | light trim          | make him or her presentable     |
      | custom cut          | impress your friends            |


  @selenium
  Scenario Outline: Create new subcategory - when things go wrong
    Given I am on the "business categories" page
    And I click the icon with CSS class "add-entity-button" for the row with "dog grooming"
    And I should see t("business_categories.index.add_subcategory")

    When I fill in the translated form with data:
      | activerecord.attributes.business_category.name | activerecord.attributes.business_category.description |
      | <subcategory_name>                             | <subcategory_description>                             |

    When I click on t("save")
    Then I should see <error>

    Scenarios:
      | subcategory_name | subcategory_description | error                      |
      |                  |                         | t("errors.messages.blank") |
      |                  | some description        | t("errors.messages.blank") |


  @selenium
  Scenario: Delete a subcategory
    Given I am on the "business categories" page
    Then I should see "light trim"
    When I click and accept the first icon with CSS class "fa-trash-alt"
    Then I should not see "light trim"


  @selenium
  Scenario: Indicate required field
    Given I am on the "business categories" page
    And I click the icon with CSS class "add-entity-button" for the row with "dog grooming"
    Then the field t("activerecord.attributes.business_category.name") should have a required field indicator
