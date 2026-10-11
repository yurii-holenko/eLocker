Feature: Lockers list
  Company staff work with the lockers of their own team.
  eLocker support engineers work with every locker on the platform.

  Background:
    Given the following companies:
      | name   |
      | Amazon |
      | DPD    |
    And the following teams:
      | name        | company |
      | Day shift   | Amazon  |
      | Night shift | Amazon  |
      | North crew  | DPD     |
    And the following employees:
      | name   | team        |
      | Alice  | Day shift   |
      | Chloe  | Night shift |
      | Dmytro | North crew  |
    And a support engineer "Sam"
    And the following lockers:
      | name    | team        | state  |
      | AMZ-001 | Day shift   | closed |
      | AMZ-002 | Day shift   | open   |
      | AMZ-101 | Night shift | closed |
      | DPD-001 | North crew  | closed |

  Scenario: An employee sees only the lockers of their team
    Given I am signed in as "Alice"
    When I open the "Lockers" page
    Then I should see the table:
      | Locker  | Company | Team      | State  |
      | AMZ-001 | Amazon  | Day shift | Closed |
      | AMZ-002 | Amazon  | Day shift | Open   |
    And I should not see "AMZ-101"
    And I should not see "DPD-001"

  Scenario: A support engineer sees the lockers of every company
    Given I am signed in as "Sam"
    When I open the "Lockers" page
    Then I should see the table:
      | Locker  | Company | Team        |
      | AMZ-001 | Amazon  | Day shift   |
      | AMZ-002 | Amazon  | Day shift   |
      | AMZ-101 | Amazon  | Night shift |
      | DPD-001 | DPD     | North crew  |

  Scenario: An employee opens and closes a locker
    Given I am signed in as "Alice"
    When I press "Open" in the "AMZ-001" row
    Then I should see "AMZ-001 is now open."
    And the "AMZ-001" row should show "Open"
    When I press "Close" in the "AMZ-001" row
    Then I should see "AMZ-001 is now closed."
    And the "AMZ-001" row should show "Closed"

  Scenario: A support engineer operates a locker of any company
    Given I am signed in as "Sam"
    When I press "Open" in the "DPD-001" row
    Then I should see "DPD-001 is now open."

  Scenario: The page can be read in Ukrainian
    Given I am signed in as "Alice"
    When I select "Українська" as the language
    Then I should see "Локери"
    And the "AMZ-001" row should show "Зачинено"

  @javascript
  Scenario: The page works the same once React has loaded in a browser
    Given I am signed in as "Alice"
    When I press "Open" in the "AMZ-001" row
    Then I should see "AMZ-001 is now open."
    And the "AMZ-001" row should have the buttons "Close"
