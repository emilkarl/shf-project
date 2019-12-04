Feature: Admin creates, views,  edits, or deletes a checklist

  As an admin
  So that I can set up a list of things that users should do
  And so I can later track the progress of users with the list
  I need to be able to create, view, edit, or delete checklists
  (CRUD: Create, Read (view), Edit (update), Delete)


  Background:

    Given the following users exist:
      | email        | admin | member |
      | admin@shf.se | true  |        |

    Given I am logged in as "admin@shf.se"


    Given the following checklists exist:
      | name                   | description                               |
      | register as a user     | provide an email for login and a password |
      | application completion | steps to complete an application          |
      | membership             | everything needed to become a member      |


    Given these checklists have these entries:
      | name                   | order | item_name                         | item_description                                                   | sublist_name           |
      | register as a user     | 0     | email                             | provide a valid email for logging in and where we'll send email to |                        |
      | register as a user     | 1     | password                          | provide a password                                                 |                        |
      | application completion | 0     | company number                    | at least 1 company number is listed                                |                        |
      | application completion | 1     | skills                            |  a least 1 business skill is checked                               |                        |
      | application completion | 2     | documents                         | documents proving business skills have been provided               |                        |
      | membership             | 0     |                                   |                                                                    | register as a user     |
      | membership             | 1     |                                   |                                                                    | application completion |
      | membership             | 2     | SHF has approved your application |                                                                    |                        |
      | membership             | 3     | pay membership fee                | pay your membership fee                                            |                        |


  # ----------------------
  # VIEW (read) checklists
  # UX: Can edit/view all items in the list (linked, buttons, or icons or something)

  Scenario: See all checklists on the manage checklists page
    Given I am on the "manage checklists" page
    Then I should see t("checklists.index.title")
    And I should see 3 checklists listed
    And I should see "register as a user" in the checklists table
    And I should see "application completion" in the checklists table
    And I should see "membership" in the checklists table



  Scenario: View the membership list and be able to click to view all of the entries for it
    Given I am on the "manage checklists" page
    When I click on "membership"
    Then I should see t("checklists.view.title", name: 'membership')
    And I should see "everything needed to become a member"
    And I should see "register as a user" in order position 0
    And I should see "email" in order position 0 in the "register as a user" sublist
    And I should see "password" in order position 1 in the "register as a user" sublist
    And I should see "application completion" in order position 1
    And I should see "company number" in order position 0 in the "application completion" sublist
    And I should see "skills" in order position 0 in the "application completion" sublist
    And I should see "documents" in order position 0 in the "application completion" sublist
    And I should see "SHF has approved your application" in order position 2
    And I should see "pay membership fee" in order position 3
    When I click on "register as a user"
    Then I should see t("checklists.view.title", name: 'register as a user')
    And I should see "membership" as a parent list
    And I should see "email" in order position 0
    And I should see "password" in order position 1
    When I click on "membership"
    Then I should see t("checklists.view.title", name: 'membership')
    When I click on "skills"
    Then I should see t("checklist_item.view.title", name: 'skills')
    And I should see "a least 1 business skill is checked"
    # is in this checklist:
    And I should see t("checklist_item.view.checklist", name: "application completion")



  # -----------------
  # CREATE checklists
  Scenario: Create a checklist with no items. It should show on the list of checklists on the manage checklists page
    Given I am on the "manage checklists" page
    And I click the t("checklists.index.new-checklist") button
    Then I should see t("checklists.new.title")
    When I fill in t("checklists.new.name") with "A new checklist"
    And I fill in t("checklists.new.description") with "description for this new checklist"
    And I click the t("submit") button
    Then I should see t("checklists.new.success")
    And I should see t("checklists.index.title")
    And I should see "A new checklist" in the checklists table
    When I click on the edit icon for "A new checklist" in the checklists table
    Then I should see t("checklists.view.title", name: 'A new checklist')
    And I should see "description for this new checklist"


  Scenario: Create a checklist with just items
    Given I am on the "manage checklists" page
    And I click the t("checklists.index.new-checklist") button
    When I fill in t("checklists.new.name") with "2 items list"
    And I fill in t("checklists.new.description") with "checklist with just 2 items"
    Then I should see t("checklists.new.success")
    And I should see t("checklists.index.title")
    And I should see "2 item list" in the checklists table
    When I am on the "checklist" page for "2 item list"
    Then I should see t("checklists.view.title", name: '2 item list')
    # And I should see the items in the right order



  Scenario: Create a checklist with items and sublists with items



  # ---------------
  # EDIT checklists

  Scenario: Rename a checklist that is a sublist in another list
    # view the parent list(s); should see the rename
    # any users associated with it will also see the change


  Scenario: Re-order items and sublists in a list

  Scenario: Delete items in a list

  Scenario: Remove a sublist; just removes this as a sublist, does it really delete it?
    # Show information that this just removes it as a sublist; does not delete it
    # Only removes it; does not delete it if users are associated with it
    # If no users associated with it, prompt to ask if it should be deleted


  # -----------------
  # DELETE checklists

  Scenario: Cannot delete a checklist if users are associated with it

  Scenario: Delete a checklist that is a sublist of other checklists

  Scenario: Delete a checklist that only has items (no sublists)

  Scenario: Delete a checklist that has no items or sublists
