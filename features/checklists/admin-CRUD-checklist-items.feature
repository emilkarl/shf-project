Feature: Admin creates, views,  edits, or deletes a checklist item

  As an admin
  So that I can add items to checklists
  I need to be able to create, view, edit, or delete checklist items
  (CRUD: Create, Read (view), Edit (update), Delete)


  Background:

    Given the following users exist:
      | email        | admin | member |
      | admin@shf.se | true  |        |


    Given the following checklists exist:
      | name                   | description                      |
      | application completion | steps to complete an application |
      | register as a user     | steps for registering            |


    Given the following checklist items exist:
      | name            | description                                          | checklist              | order in checklist |
      | company number  | provide at least 1 valid company number (Org nummer) | application completion | 0                  |
      | documents       | upload documents for the categories checked          | application completion | 2                  |
      | categories      | a least 1 business category is checked               | application completion | 1                  |
      | password        | provide a login password                             | register as a user     | 1                  |
      | email for login | provide an email for logging in                      | register as a user     | 0                  |


    Given I am logged in as "admin@shf.se"


  # ----------------------
  # VIEW (read) checklist items
  # UX: Can view all checklists associated with an item (linked, buttons, or icons or something)

  Scenario: See all checklist items on the manage checklist items page; they are grouped by checklist and in order
    Given I am on the "manage checklist items" page
    Then I should see t("checklist_items.index.title")
    And I should see 5 checklist items listed
    And I should see the item named "company number" in the checklist items table
    And I should see the item named "categories" in the checklist items table
    And I should see the item named "documents" in the checklist items table
    And I should see the item named "password" in the checklist items table
    And I should see the item named "email for login" in the checklist items table
    And I should see "application completion" as the checklist in the row for "company number"
    And I should see "application completion" as the checklist in the row for "categories"
    And I should see "application completion" as the checklist in the row for "documents"
    And I should see "register as a user" as the checklist in the row for "password"
    And I should see "register as a user" as the checklist in the row for "email for login"
    # Order that they appear in the list
    And I should see "email for login" before "password"
    And I should see "categories" before "documents"
    And I should see "company number" before "categories"


  Scenario: TBD: A checklist item appears in more than 1 checklist, so it appears in the list of all items as...
      # TBD - if/when this happens, we can figure out how we want the list of all checklist items to appear, be sorted, etc.


  Scenario: View a checklist item and be able to click to view the associated checklist(s)
    Given I am on the "manage checklists" page
    When I click on "documents"
    Then I should see t("checklist_items.view.title", name: 'documents')
    And I should see "upload documents for the categories checked" as the description
    And I should see "2" as the order in list
    And I should see "application completion" as a checklist it is in
    When I click on "application completion"
    Then I should see t("checklist_items.view.title", name: 'application completion')


  # -----------------
  # CREATE checklist itemss
  Scenario: Create a checklist item and assign it to a checklist
    Given I am on the "manage checklist itemss" page
    And I click the t("checklist_items.index.new-checklist") button
    Then I should see t("checklist_items.new.title")
    When I fill in t("checklist_items.new.name") with "A new checklist"
    And I fill in t("checklist_items.new.description") with "description for this new checklist"
    And I click the t("submit") button
    Then I should see t("checklist_items.new.success")
    And I should see t("checklist_items.index.title")
    And I should see "A new checklist" in the checklists table
    When I click on the edit icon for "A new checklist" in the checklists table
    Then I should see t("checklist_items.view.title", name: 'A new checklist')
    And I should see "description for this new checklist"


  # ---------------
  # EDIT checklist items

  Scenario: Edit the name and description
    # view the parent list(s); should see the rename
    # any users associated with it will also see the change

  Scenario: Change the order in the list: make it first
    # confirm that the order is changed when viewing the checklist
    # confirm that all other items in the list are moved 'down' (their order in list # is incremented)

  Scenario: Change the order in the list: make it last
    # confirm that the order is changed when viewing the checklist
    # confirm that the other items in the list after it are moved 'up' (their order in list # is decremented)

  Scenario: Change the order: the max. order number is limited to checklist size

  Scenario: Change the order: switch it with an item in the middle
    # confirm that the order is changed when viewing the checklist
    # confirm that the other item in the list are re-ordered correctly


  Scenario: Delete items in a list

  Scenario: Remove a sublist; just removes this as a sublist, does it really delete it?
    # Show information that this just removes it as a sublist; does not delete it
    # Only removes it; does not delete it if users are associated with it
    # If no users associated with it, prompt to ask if it should be deleted


  # -----------------
  # DELETE checklist items

  Scenario: Delete a checklist item (no users are associated with it)
    # confirm that it is in a checklist and shows up in views/pages
    # delete it
    # confirm that it no longer appears in views/pages

  Scenario: Cannot delete a checklist item if users are associated with it
