Feature:  Alert for approved applicant telling them they owe the membershsip fee.

  As an applicant with an approved application,
  So that I pay the membership fee and become a member,
  I should get email alerts reminding me to pay my membership fee.


  Background:

    Given the following users exist:
      | email              | admin |
      | emma@happymutts.se |       |
      | admin@shf.com      | true  |


    And the following business categories exist
      | name    |
      | Groomer |

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following companies exist:
      | name        | company_number | email              | region    |
      | Happy Mutts | 5562252998     | voof@happymutts.se | Stockholm |

    And the following applications exist:
      | user_email         | company_number | categories | state    | when_approved |
      | emma@happymutts.se | 5562252998     | Groomer    | accepted | 2018-01-01    |

    # Application approved on 2018-01-01

    Given there is a condition with class_name "FirstMembershipFeeOwedAlert" and timing "after"
    Given the condition has days set to [2, 32, 363 ]

  @time_adjust
  Scenario Outline: Applicant is approved, applicant gets email based on the condition schedule
    Given the date is set to <today>
#    And the App Configuration is not mocked and is seeded
    And the process_condition task sends "condition_response" to the "FirstMembershipFeeOwedAlert" class
    Then "emma@happymutts.se" should receive <this_many_firstMemOwed_alerts> email

     # checking the day before and after the alert day just to be sure no emails are sent then
    Scenarios:
      | today        | this_many_firstMemOwed_alerts |
      | "2018-01-02" | no                            |
      | "2018-01-03" | an                            |
      | "2018-01-04" | no                            |
      | "2018-01-31" | no                            |
      | "2018-02-01" | no                            |
      | "2018-02-02" | an                            |
      | "2018-12-29" | no                            |
      | "2018-12-30" | an                            |
      | "2018-12-31" | no                            |
