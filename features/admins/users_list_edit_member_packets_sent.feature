Feature: Admin sets when member packets were sent on the all users page

  As an admin
  So that I can manage who has and has not had a membership packet sent to them,
  For each user, I need to be able to set or clear the date I've sent the packet
  On the 'all users' page


  Background:

    Given the following users exists
      | email                  | admin | membership_number | member |
      | emma@bowsers.se        |       | 100               | true   |
      | lars@happymutts.se     |       | 101               | true   |
      | hannah@happymutts.se   |       | 102               | true   |
      | nils@kitty.se          |       |                   |        |
      | admin@shf.se           | true  |                   |        |
      | rejected@happymutts.se |       |                   |        |

    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name        | company_number | email               | region       |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Västerbotten |


    And the following applications exist:
      | user_email             | contact_email          | company_number | state    |
      | lars@happymutts.se     | lars@happymutts.se     | 5560360793     | accepted |
      | hannah@happymutts.se   | hannah@happymutts.se   | 5560360793     | accepted |
      | emma@bowsers.se        | emma@bowsers.se        | 2120000142     | new      |
      | rejected@happymutts.se | rejected@happymutts.se | 5560360793     | rejected |


    And the following membership packets have been sent:
      | user_email         | date_sent  |
      | lars@happymutts.se | 2019-03-01 |


    And I am logged in as "admin@shf.se"


  Scenario: I see the membership packet info for users
    Given I am on the "all users" page
    Then I should see the checkbox with id "date_membership_packet_sent" checked in the row for user "lars@happymutts.se"
    And I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "hannah@happymutts.se"
    And I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "emma@bowsers.se"
    And I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "rejected@happymutts.se"
    And I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "nils@kitty.se"


  @selenium
  Scenario: I set the membership packet sent to today for a user
    Given the App Configuration is not mocked and is seeded
    And I am on the "all users" page
    And the date is set to "2019-03-01"
    Then I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "hannah@happymutts.se"
    When I check the checkbox with id "date_membership_packet_sent" for the row with "hannah@happymutts.se"
    Then I should see the checkbox with id "date_membership_packet_sent" checked in the row for user "hannah@happymutts.se"
    When I am on the "user details" page for "hannah@happymutts.se"
    Then I should see t("users.show.member_packet")
    And I should see t("users.show.sent")
    And I should not see t("users.show.not_sent")
    And I should see "2019-03-01"


  @selenium
  Scenario: I clear the membership packet sent date for a user
    Given the App Configuration is not mocked and is seeded
    And I am on the "all users" page
    Then I should see the checkbox with id "date_membership_packet_sent" checked in the row for user "lars@happymutts.se"
    When I uncheck the checkbox with id "date_membership_packet_sent" for the row with "lars@happymutts.se"
    Then I should see the checkbox with id "date_membership_packet_sent" unchecked in the row for user "lars@happymutts.se"
    When I am on the "user details" page for "lars@happymutts.se"
    Then I should see t("users.show.member_packet")
    And I should see t("users.show.not_sent")
    And I should not see "2019-03-01"
