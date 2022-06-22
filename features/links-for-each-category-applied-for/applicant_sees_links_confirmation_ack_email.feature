Feature: Applicant sees link for each category they applied for in submission confirmation and aknowledgement email

  Background:
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email                 | admin | first_name | last_name |
      | applicant@example.com |       | Applicant  | Applicant |

    And the following business categories exist
      | name         | apply_qs_url |
      | Groomer      | https://example.com/groomer   |
      | Psychologist | https://example.com/psych     |
      | Blorf        | https://example.com/blorf     |

    And the following companies exist:
      | name                 | company_number | email                  | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |

    And the application file upload options exist

    And I am logged in as "applicant@example.com"
    And I am on the "user account" page
    And I click on first t("menus.nav.users.apply_for_membership") link
    And I fill in the translated form with data:
      | shf_applications.show.company_number | shf_applications.new.phone_number | shf_applications.new.contact_email |
      | 5560360793                          | 031-1234567                       | applicant@example.com              |

    And I select files delivery radio button "upload_later"

  # =================================================================================================

  @selenium @applicant @user
  Scenario: Applicant applies for 1 category, sees the instructions and 1 link in confirmation message displayed
    Given I select "Groomer" Category
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success_with_app_files_missing")
    And I should see t("shf_applications.create.success_more_questions_instructions")
    And I should see "Groomer https://example.com/groomer"
    And I should see t("shf_applications.create.success_more_questions_instructions")

  @selenium @applicant @user
  Scenario: Applicant applies for 3 categories, sees the instructions once and the 3 links in confirmation message displayed
    Given I select "Groomer" Category
    And I select "Psychologist" Category
    And I select "Blorf" Category
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success_with_app_files_missing")
    And I should see t("shf_applications.create.success_more_questions_instructions")
    And I should see "Psychologist https://example.com/psych"
    And I should see "Groomer https://example.com/groomer"
    And I should see "Blorf https://example.com/blorf"


  @selenium @applicant @user
  Scenario: Applicant applies for 1 category, sees the instructions and 1 link in the acknowledgment email
    Given I select "Groomer" Category
    When I click on t("shf_applications.new.submit_button_label")
    Then I should see t("shf_applications.create.success_with_app_files_missing")

    And "applicant@example.com" should receive an email with subject t("mailers.shf_application_mailer.acknowledge_received.subject")

    When I open the email
    Then I should see t("mailers.shf_application_mailer.acknowledge_received.more_questions_instructions") in the email body
    And I should see "Groomer https://example.com/groomer" in the email body


  @selenium @applicant @user
  Scenario: Applicant applies for 3 categories, sees the instructions once and the 3 links in the acknowledgment email
    Given I select "Groomer" Category
    And I select "Psychologist" Category
    And I select "Blorf" Category
    And I select files delivery radio button "upload_later"
    And I click on t("shf_applications.new.submit_button_label")

    Then I should see t("shf_applications.create.success_with_app_files_missing")
    And I should be on the "user account" page for "applicant@example.com"
    And "applicant@example.com" should receive an email with subject t("mailers.shf_application_mailer.acknowledge_received.subject")

    When I open the email
    Then I should see t("mailers.shf_application_mailer.acknowledge_received.more_questions_instructions") in the email body
    And I should see "Groomer https://example.com/groomer" in the email body
    And I should see "Psychologist https://example.com/psych" in the email body
    And I should see "Blorf https://example.com/blorf" in the email body
