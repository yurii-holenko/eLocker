Feature: Locker page
  A locker's page shows its details and current state, lets the user operate
  it, and lists everything that has happened to it.

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
    And a support engineer "Sam"
    And the following lockers:
      | name    | team       | location                |
      | DPD-001 | North crew | Hamburg central station |

  Scenario: An employee opens a locker's page from the list
    Given I am signed in as "Dmytro"
    When I follow "DPD-001"
    Then I should see "Hamburg central station"
    And I should see "North crew"
    And I should see "Closed"
    And I should see "No actions yet."

  Scenario: Actions appear in the locker's history, newest first
    Given I am signed in as "Dmytro"
    And I follow "DPD-001"
    When I press "Open"
    And I press "Close"
    Then I should see the table:
      | Action | User   |
      | Closed | Dmytro |
      | Opened | Dmytro |

  Scenario: An employee sees how many wrong codes they have left
    Given I am signed in as "Dmytro"
    And I follow "DPD-001"
    When I press "Wrong code"
    Then I should see "Wrong codes left before blocking"
    And I should see "1 of 2"

  Scenario: The history explains why a locker was blocked and how it was unblocked
    Given I am signed in as "Dmytro"
    And I follow "DPD-001"
    When I press "Wrong code"
    And I press "Wrong code"
    And 5 minutes pass
    And I reload the page
    Then I should see the table:
      | Action     | User   |
      | Unblocked  | System |
      | Blocked    | System |
      | Wrong code | Dmytro |
      | Wrong code | Dmytro |

  Scenario: A support engineer opens a blocked locker from its page
    Given I am signed in as "Dmytro"
    And I follow "DPD-001"
    And I press "Wrong code"
    And I press "Wrong code"
    When I am signed in as "Sam"
    And I follow "DPD-001"
    And I press "Open"
    Then I should see "DPD-001 is now open."
    And I should see the table:
      | Action     | User   |
      | Opened     | Sam    |
      | Blocked    | System |
      | Wrong code | Dmytro |
      | Wrong code | Dmytro |

  Scenario: The user returns to the list
    Given I am signed in as "Dmytro"
    And I follow "DPD-001"
    When I follow "All lockers"
    Then I should see the table:
      | Locker  | State  |
      | DPD-001 | Closed |
