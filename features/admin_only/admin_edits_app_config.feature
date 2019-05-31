Feature: Admin edits application configuration
  As an admin
  I want to be able to edit application configuration
  including images for the site meta image, chair signature, SHF logo images, and company h-brand;
  site name, and meta information: title, keywords, and description.


  Background:
    Given the following users exists
      | email             | password | admin | member    | first_name | last_name |
      | admin@random.com  | password | true  | false     | emma       | admin     |

    And the App Configuration is not mocked and is seeded

    And I am logged in as "admin@random.com"
    And I am on the "admin edit app configuration" page


  Scenario: Admin uploads SHF logo and chairperson signature
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[chair_signature]" file named "chair_signature.png" to upload
    And I choose an application configuration "admin_only_app_configuration[shf_logo]" file named "shf_logo.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")

  Scenario: Admin uploads images for company h-brand
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[h_brand_logo]" file named "h_brand_logo.png" to upload
    And I choose an application configuration "admin_only_app_configuration[sweden_dog_trainers]" file named "sweden_dog_trainers.png" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.success")

  Scenario: Admin edits app configuration and tries to upload non-image file
    Then I should see t("admin_only.app_configuration.edit.title")
    And I choose an application configuration "admin_only_app_configuration[shf_logo]" file named "specifications.txt" to upload
    And I click on t("submit") button
    Then I should see t("admin_only.app_configuration.update.error")
