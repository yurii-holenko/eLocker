Feature: Blocking a locker after wrong access codes
  A locker is blocked when one person enters too many wrong codes. How many,
  and for how long, is set by the company. While it is blocked only an
  eLocker support engineer can open it.

  Background:
    Given the following companies:
      | name | max wrong codes | block minutes |
      | DPD  | 2               | 5             |
    And the following teams:
      | name       | company |
      | North crew | DPD     |
    And the following employees:
      | name   | team       |
      | Dmytro | North crew |
      | Elena  | North crew |
    And a support engineer "Sam"
    And the following lockers:
      | name    | team       |
      | DPD-001 | North crew |

  Scenario: A wrong code is counted but does not block the locker yet
    Given I am signed in as "Dmytro"
    When I press "Wrong code" in the "DPD-001" row
    Then I should see "Wrong code for DPD-001. Attempts left: 1."
    And the "DPD-001" row should show "Closed"

  Scenario: Reaching the company's limit blocks the locker for everyone in the team
    Given I am signed in as "Dmytro"
    When I press "Wrong code" in the "DPD-001" row
    And I press "Wrong code" in the "DPD-001" row
    Then I should see "Too many wrong codes: DPD-001 is blocked for 5 min."
    And the "DPD-001" row should show "Blocked"
    And the "DPD-001" row should have no buttons
    When I am signed in as "Elena"
    Then the "DPD-001" row should have no buttons

  Scenario: Wrong codes are counted separately for each person
    Given I am signed in as "Dmytro"
    When I press "Wrong code" in the "DPD-001" row
    And I am signed in as "Elena"
    And I press "Wrong code" in the "DPD-001" row
    Then I should see "Wrong code for DPD-001. Attempts left: 1."
    And the "DPD-001" row should show "Closed"

  Scenario: A support engineer opens a blocked locker
    Given I am signed in as "Dmytro"
    And I press "Wrong code" in the "DPD-001" row
    And I press "Wrong code" in the "DPD-001" row
    When I am signed in as "Sam"
    Then the "DPD-001" row should have the buttons "Open"
    When I press "Open" in the "DPD-001" row
    Then I should see "DPD-001 is now open."

  Scenario: The locker unblocks by itself when the company's block time is over
    Given I am signed in as "Dmytro"
    And I press "Wrong code" in the "DPD-001" row
    And I press "Wrong code" in the "DPD-001" row
    When 4 minutes pass
    And I open the "Lockers" page
    Then the "DPD-001" row should show "Blocked"
    When 1 minute passes
    And I open the "Lockers" page
    Then the "DPD-001" row should show "Closed"
    And the "DPD-001" row should have the buttons "Open and Wrong code"
