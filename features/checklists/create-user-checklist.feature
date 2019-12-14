Feature:  Create a user checklist based on a checklist


  Background:

    Given the following users exist:
      | email                | admin | member | first_name | last_name |
      | applicant@random.com |       |        | Kicki      | Applicant |
      | member@random.com    |       | true   | Lars       | IsaMember |
      | admin@shf.se         | yes   |        |            |           |


    Given the following ordered list entries exist:
      | name                 | description                                 | list position | parent name          |
      | Application Progress | top level list with no parent               |               |                      |
      | List 1               | list 1 entry in top list 1                  | 0             | Application Progress |
      | list 1 entry 1       |                                             | 0             | List 1               |
      | list 1 entry 2       |                                             | 1             | List 1               |
      | top list entry 2     | entry in top list; not a list (no children) | 1             | Application Progress |
      | List 2               | list 2 entry in top list 1                  | 2             | Application Progress |
      | list 2 entry 1       |                                             | 0             | List 2               |


  Scenario: Checklist is created for an applicant
#    Given I am logged in as "applicant@random.com"
    # TODO this page may change in the future; perhaps they view their progress on some other page
#    And I am on the "my checklists" page
#    Then I should see the item named "Application Progress" in the user checklist items table


