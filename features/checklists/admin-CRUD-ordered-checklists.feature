Feature: Admin creates, views,  edits, or deletes an ordered checklist

  As an admin
  So that I can set up a list of things that users should do
  And so I can later track the progress of users with the list
  I need to be able to create, view, edit, or delete ordered checklists
  (CRUD: Create, Read (view), Edit (update), Delete)


  Background:

    Given the following users exist:
      | email        | admin | member |
      | admin@shf.se | true  |        |

    Given I am logged in as "admin@shf.se"


    Given the following ordered list entries exist:
      | name                         | description                                                | list position | parent name             |
      | Submit Your Application      | top level list with no parent                              |               |                         |
      | Your Business Categories     | Indicate your business categories (skills)                 | 0             | Submit Your Application |
      | Provide Company Number       | provide the Org Nm. for at least 1 company                 | 1             | Submit Your Application |
      | Document Business Categories | Provide documents for your business categories (skills)    | 2             | Submit Your Application |
      | Membership                   |                                                            |               |                         |
      | Submit Your Application      | Complete and submit a membership application               | 0             | Membership              |
      | SHF Approved Application     | SHF has approved your application                          | 1             | Membership              |
      | Pay your membership fee      | Pay your membership (good for 1 year)                      | 2             | Membership              |
      | Some other list (SOL)        | some other top level list                                  |               |                         |
      | SOL entry 0                  | entry 0 in Some other list (SOL); not a list (no children) | 0             | Some other list (SOL)   |
      | SOL entry 2                  | entry 2 in Some other list (SOL); not a list (no children) | 2             | Some other list (SOL)   |
      | SOL entry 1                  | entry 1 in Some other list (SOL); not a list (no children) | 1             | Some other list (SOL)   |



  # ----------------------
  # VIEW (read) checklists
  # UX: Can edit/view all items in the list (linked, buttons, or icons or something)

  Scenario: See all checklists on the manage checklists page
    Given I am on the "manage ordered checklists" page
    Then I should see t("ordered_list_entries.index.title")
    And I should see 12 checklist entries listed
    # Verify that all entries are shown
    And I should see "Submit Your Application" in the checklists table
    And I should see "Membership" in the checklists table
    And I should see "Some other list (SOL)" in the checklists table
    And I should see entry named "Your Business Categories" in the checklists table and it shows position 0
    And I should see entry named "Provide Company Number" in the checklists table and it shows position 1
    And I should see entry named "Document Business Categories" in the checklists table and it shows position 2
    And I should see entry named "Submit Your Application" in the checklists table and it shows position 0
    And I should see entry named "SHF Approved Application" in the checklists table and it shows position 1
    And I should see entry named "Pay your membership fee" in the checklists table and it shows position 2
    And I should see entry named "SOL entry 0" in the checklists table and it shows position 0
    And I should see entry named "SOL entry 1" in the checklists table and it shows position 1
    And I should see entry named "SOL entry 2" in the checklists table and it shows position 2

    # TODO: Verify that they are sorted correctly (displayed in the right order)
    # And ... this entry is before that entry....


  Scenario: Clicking on an entry name will go to the view for it
    Given I am on the "manage ordered checklists" page
    Then I should see t("ordered_list_entries.index.title")
    When I click on "SOL entry 0"
    Then I should see t("ordered_list_entries.show.title", name: "SOL entry 0")


  Scenario: Clicking on an entry description will go to the view for it
    Given I am on the "manage ordered checklists" page
    Then I should see t("ordered_list_entries.index.title")
    When I click on "some other top level list"
    Then I should see t("ordered_list_entries.show.title", name: "Some other list (SOL)")


  Scenario: The parent list for an entry is shown and clicking on it goes to the view for it
    Given I am on the page for ordered list entry named "SOL entry 0"
    Then I should see t("ordered_list_entries.show.title", name: "SOL entry 0")
    And I should see "Some other list (SOL)"
    When I click on "Some other list (SOL)"
    Then I should see t("ordered_list_entries.show.title", name: "Some other list (SOL)")


  # -----------------
  # CREATE checklists

  Scenario: Create a new entry and do not pick a parent list. It should show on the list of checklists on the manage checklists page at the top level
    Given I am on the "manage ordered checklists" page
    Then I should see t("ordered_list_entries.index.title")
    When I click on the t("ordered_list_entries.new.title") link
    Then I should see t("ordered_list_entries.new.title")
    When I fill in t("ordered_list_entries.new.name") with "A new checklist"
    And I fill in t("ordered_list_entries.new.description") with "description for this new checklist"
    And I click on the t("submit") button
    Then I should see t("ordered_list_entries.create.success", name: "A new checklist")
    And I should see t("ordered_list_entries.index.title")
    When I am on the "manage ordered checklists" page
    Then I should see "A new checklist" in the checklists table


  Scenario: Create an entry in a list and do not specify the position. It should be put at the end
    Given I am on the "manage ordered checklists" page
    Then I should see t("ordered_list_entries.index.title")
    When I click on the t("ordered_list_entries.new.title") link
    Then I should see t("ordered_list_entries.new.title")
    When I fill in t("ordered_list_entries.new.name") with "last item in SOL"
    And I fill in t("ordered_list_entries.new.description") with "this is the last item"
    And I select "Some other list (SOL)" as the parent list
    And I click on the t("submit") button
    Then I should see t("ordered_list_entries.create.success", name: "last item in SOL")
    And I should see t("ordered_list_entries.index.title")
    When I am on the "manage ordered checklists" page
    Then I should see entry named "last item in SOL" in the checklists table and it shows position 3


  Scenario: Create an entry in a list; cannot specify a position larger than the size


  Scenario: Create an entry in a list. Give a position that already exists.  Entry already at the position and all after should move down (be incremented)



  # ---------------
  # EDIT checklists

  Scenario: Rename a checklist that is a sublist in another list
    # view the parent list(s); should see the rename
    # any users associated with it will also see the change


  # ----------------
  # Reordering Lists

  Scenario: Change the list position to the first item in the list. All other items are moved down (positions incremented)


  Scenario: Change the list position to the last item in the list. All other items are moved up (positions decremented)


  Scenario: Change the list position to the middle of the list. Other list entry positions are changed appropriately



  # -----------------
  # DELETE checklists

  Scenario: Delete an entry that is a sublist of other checklists

  Scenario: Delete an entry that has sub-items (a mix of sublists and entries)

  Scenario: Delete an entry that has no sub-items

  Scenario: Cannot delete an entry if users are associated with it
