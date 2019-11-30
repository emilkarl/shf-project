Feature: Edit a User Profile
  TODO: this should be moved into the features/user_profile directory and then scenarios reorganized as appropriate with scenarios that already exist in that directory.

  As a registered user
  in order to be able to change my login email and password,
  and to edit what is displayed to the public
  I need to be able to edit my profile

  Background:
    Given the following users exist:
      | first_name | last_name | email              | password | admin |
      | emma       | andersson | emma@andersson.com | password | false |

    And I am logged in as "emma@andersson.com"

  Scenario: Editing my user profile - change first, last names
    Given I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson"
    And the t("activerecord.attributes.user.email") field should be set to "emma@andersson.com"
    #And I should see t("show_in_english") image
    When I fill in t("activerecord.attributes.user.first_name") with "emma (changed)"
    When I fill in t("activerecord.attributes.user.last_name") with "andersson (changed)"
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see t("devise.registrations.edit.success")
    When I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma (changed)"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson (changed)"

  Scenario: Sad path: Missing first name
    Given I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson"
    And the t("activerecord.attributes.user.email") field should be set to "emma@andersson.com"
    When I fill in t("activerecord.attributes.user.first_name") with ""
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see error t("activerecord.attributes.user.first_name") t("errors.messages.blank")
    And I should not see t("devise.registrations.edit.success")
    And I should see t("cannot_change_language") image
    When I am on the "edit registration for a user" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma"

  Scenario: Sad path: Missing last name
    Given I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.first_name") field should be set to "emma"
    And the t("activerecord.attributes.user.last_name") field should be set to "andersson"
    And the t("activerecord.attributes.user.email") field should be set to "emma@andersson.com"
    When I fill in t("activerecord.attributes.user.last_name") with ""
    And I fill in t("devise.registrations.edit.current_password") with "password"
    And I click on t("devise.registrations.edit.submit_button_label")
    Then I should see error t("activerecord.attributes.user.last_name") t("errors.messages.blank")
    And I should not see t("devise.registrations.edit.success")
    And I should see t("cannot_change_language") image
    When I am on the "edit my user profile" page
    Then the t("activerecord.attributes.user.last_name") field should be set to "andersson"
