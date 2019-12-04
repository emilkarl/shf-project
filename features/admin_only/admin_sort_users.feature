Feature: Admin sorts users

  As an admin
  I would like to sort users
  to quickly and easily find users I am interested in


  Background:

    Given the date is set to "2019-11-01"

    Given the following users exist
      | first_name            | last_name    | email                              | admin | membership_number | member | date_membership_packet_sent | sign_in_count | created_at |
      | WaitingForApplicant   | Not-A-Member | not_member1@example.com            | false |                   | false  |                             |               | 2019-01-15 |
      | Number-1              | Member       | member-1@example.com               | false | 1                 | true   | 2019-01-10                  | 5             | 2019-01-01 |
      | Number-2              | Member       | member-2@example.com               | false | 2                 | true   | 2019-02-10                  | 4             | 2019-02-02 |
      | Number-3-Very-Active  | Member       | member-3-veryactive@example.com    | false | 3                 | true   | 2019-03-10                  | 100           | 2019-03-03 |
      | Number-4-LatestMember | Member       | member-4-latest-member@example.com | false | 4                 | true   | 2019-04-10                  | 1             | 2019-04-04 |
      | FormerMember          | Not-A-Member | former-member@happymutts.com       | false |                   | false  | 2018-08-08                  |               | 2018-08-01 |
      | admin                 | admin        | admin@shf.se                       | true  |                   | false  |                             |               | 2018-01-01 |


    And the following applications exist:
      | user_email                         | state                 | company_number |
      | not_member1@example.com            | waiting_for_applicant | 0000000000     |
      | member-1@example.com               | accepted              | 0000000000     |
      | member-4-latest-member@example.com | accepted              | 0000000000     |
      | member-2@example.com               | accepted              | 5560360793     |
      | member-3-veryactive@example.com    | accepted              | 5560360793     |

    And the following membership packets have been sent:
      | user_email                   | date_sent  |
      | member-1@example.com         | 2019-03-01 |
      | member-2@example.com         | 2019-02-01 |
      | former-member@happymutts.com | 2018-02-01 |


    And I am logged in as "admin@shf.se"
    And I am on the "all users" page


  Scenario: Admin sorts users by email
    Given I am on the "all users" page
    When I click on t("users.users_list.email")
    Then I should see "admin@shf.se" before "former-member@happymutts.com"
    Then I should see "former-member@happymutts.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-4-latest-member@example.com"
    Then I should see "member-4-latest-member@example.com" before "not_member1@example.com"

    # descending order
    When I click on t("users.users_list.email")
    Then I should see "not_member1@example.com" before "member-4-latest-member@example.com"
    Then I should see "member-4-latest-member@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "former-member@happymutts.com"
    Then I should see "former-member@happymutts.com" before "admin@shf.se"


  Scenario: Admin sorts users by membership number
    When I click on t("users.users_list.membership_number")
    Then I should see "member-1@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-4-latest-member@example.com"
    Then I should see "member-4-latest-member@example.com" before "admin@shf.se"
    Then I should see "member-4-latest-member@example.com" before "not_member1@example.com"
    Then I should see "member-4-latest-member@example.com" before "former-member@happymutts.com"

    # descending order
    When I click on t("users.users_list.membership_number")
    Then I should see "admin@shf.se" before "member-4-latest-member@example.com"
    Then I should see "not_member1@example.com" before "member-4-latest-member@example.com"
    Then I should see "former-member@happymutts.com" before "member-4-latest-member@example.com"
    Then I should see "member-4-latest-member@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-1@example.com"


  Scenario: Sort by member packet sent status
    When I click on t("users.users_list.member_packet")
    Then I should see "member-1@example.com" before "not_member1@example.com"
    And I should see "member-2@example.com" before "not_member1@example.com"
    And I should see "former-member@happymutts.com" before "not_member1@example.com"

    # descending order
    When I click on t("users.users_list.member_packet")
    Then I should see "member-4-latest-member@example.com" before "member-1@example.com"
    And I should see "member-4-latest-member@example.com" before "member-2@example.com"
    And I should see "member-4-latest-member@example.com" before "former-member@happymutts.com"


  Scenario: Sort by when user was created ( = user registered)
    When I click on t("users.users_list.created")
    Then I should see "admin@shf.se" before "former-member@happymutts.com"
    Then I should see "former-member@happymutts.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "not_member1@example.com"
    Then I should see "not_member1@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-4-latest-member@example.com"

    # descending order
    When I click on t("users.users_list.created")
    Then I should see "member-4-latest-member@example.com" before "member-3-veryactive@example.com"
    Then I should see "member-3-veryactive@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "not_member1@example.com"
    Then I should see "not_member1@example.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "former-member@happymutts.com"
    Then I should see "former-member@happymutts.com" before "admin@shf.se"


  Scenario: Sort by number of logins
    When I click on t("users.users_list.logged_in_count")
    Then I should see "former-member@happymutts.com" before "member-4-latest-member@example.com"
    Then I should see "admin@shf.se" before "member-4-latest-member@example.com"
    Then I should see "not_member1@example.com" before "member-4-latest-member@example.com"

    Then I should see "member-4-latest-member@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "member-3-veryactive@example.com"

    # descending order (most to fewest)
    When I click on t("users.users_list.logged_in_count")
    Then I should see "member-3-veryactive@example.com" before "member-1@example.com"
    Then I should see "member-1@example.com" before "member-2@example.com"
    Then I should see "member-2@example.com" before "member-4-latest-member@example.com"

    Then I should see "member-4-latest-member@example.com" before "admin@shf.se"
    Then I should see "member-4-latest-member@example.com" before "not_member1@example.com"
    Then I should see "member-4-latest-member@example.com" before "former-member@happymutts.com"


  Scenario: Sort by membership status
    When I click on third t("users.users_list.member") link
    # can only guarantee that "not members" will be sorted before members
    Then I should see "admin@shf.se" before "member-4-latest-member@example.com"
    Then I should see "not_member1@example.com" before "member-4-latest-member@example.com"
    Then I should see "former-member@happymutts.com" before "member-4-latest-member@example.com"

    # descending order
    # can only guarantee that members will be sorted before "not members"
    When I click on third t("users.users_list.member") link
    Then I should see "member-1@example.com" before "not_member1@example.com"
    Then I should see "member-2@example.com" before "not_member1@example.com"
    Then I should see "member-3-veryactive@example.com" before "not_member1@example.com"
    Then I should see "member-4-latest-member@example.com" before "not_member1@example.com"
