Feature: Applicant sees links and gets email about additional questions if business categories are changed

  If an applicant edits their application and adds or removes the business categories for it
  then the applicatn should see a (flash) message about the additional questions for any business categories added
  and they should get an email with the additional question links, too.

  The admin does not get any email because the business categories can only be changed if it is not under review or accepted or rejected


  Background:
    Given the Membership Ethical Guidelines Master Checklist exists
    And the application file upload options exist

    Given the following users exist:
      | email                 | admin | first_name | last_name |
      | applicant@example.com |       | Applicant  | Applicant |

    And the following business categories exist
      | name         | apply_qs_url                |
      | Groomer      | https://example.com/groomer |
      | Psychologist | https://example.com/psych   |
      | Trim         | https://example.com/trim    |
      | Butik        | https://example.com/butik   |
      | Blorf        | https://example.com/blorf   |

    And the following companies exist:
      | name                 | company_number | email                  | region    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Stockholm |

    And the following applications exist:
      | user_email            | company_number | state | categories            | uploaded file names |
      | applicant@example.com | 5560360793     | new   | Groomer, Psychologist | diploma.pdf         |


    And I am logged in as "applicant@example.com"
    And I am on the "edit my application" page

  # =================================================================================================

  @selenium @applicant @user
  Scenario: Two business categories are added; message shows info about both and email is sent
    Given I select "Butik" Category
    And I select "Blorf" Category

    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should see t("shf_applications.update.success_more_questions_instructions")
    And I should see "Butik https://example.com/butik"
    And I should see "Blorf https://example.com/blorf"
    And "applicant@example.com" should receive an email with subject t("mailers.shf_application_mailer.additional_qs_for_biz_cats.subject")

    When I open the email
    Then I should see t("mailers.shf_application_mailer.acknowledge_received.more_questions_instructions") in the email body
    And I should see "Butik https://example.com/butik" in the email body
    And I should see "Blorf https://example.com/blorf" in the email body
    And I should not see "Groomer https://example.com/groomer" in the email body
    And I should not see "Psychologist https://example.com/psych" in the email body


  @selenium @applicant @user
  Scenario: One business category is removed; no message or email about additional questions
    Given I unselect "Groomer" Category

    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should not see t("shf_applications.update.success_more_questions_instructions")
    And "applicant@example.com" should receive no email with subject t("mailers.shf_application_mailer.additional_qs_for_biz_cats.subject")


  @selenium @applicant @user
  Scenario: Business categories are not changed; no message or email about additional questions
    Given I fill in t("shf_applications.show.contact_email") with "changedemail@example.com"

    When I click on t("shf_applications.edit.submit_button_label")
    Then I should see t("shf_applications.update.success")
    And I should not see t("shf_applications.update.success_more_questions_instructions")
    And "applicant@example.com" should receive no email with subject t("mailers.shf_application_mailer.additional_qs_for_biz_cats.subject")
