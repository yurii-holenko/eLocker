Feature: Action log
  The action log lists everything that happened to the lockers a user may
  see: employees see their team's lockers, support engineers see every locker.

  Background:
    Given the following companies:
      | name   | max wrong codes |
      | Amazon | 50              |
      | DPD    | 5               |
    And the following teams:
      | name       | company |
      | Day shift  | Amazon  |
      | North crew | DPD     |
    And the following employees:
      | name   | team       |
      | Alice  | Day shift  |
      | Dmytro | North crew |
    And a support engineer "Sam"
    And the following lockers:
      | name    | team       |
      | AMZ-001 | Day shift  |
      | DPD-001 | North crew |
    And the following actions happened:
      | user   | action       | locker  |
      | Alice  | open         | AMZ-001 |
      | Dmytro | fail attempt | DPD-001 |
      | Sam    | open         | DPD-001 |
      | Alice  | close        | AMZ-001 |

  Scenario: An employee sees the actions on their team's lockers
    Given I am signed in as "Alice"
    When I follow "Action log"
    Then I should see the table:
      | Locker  | Action | User  |
      | AMZ-001 | Closed | Alice |
      | AMZ-001 | Opened | Alice |
    And I should not see "DPD-001"

  Scenario: A support engineer sees the actions on every locker
    Given I am signed in as "Sam"
    When I follow "Action log"
    Then I should see the table:
      | Locker  | Action     | User   |
      | AMZ-001 | Closed     | Alice  |
      | DPD-001 | Opened     | Sam    |
      | DPD-001 | Wrong code | Dmytro |
      | AMZ-001 | Opened     | Alice  |

  Scenario: The log is filtered by the kind of action
    Given I am signed in as "Sam"
    And I open the "Action log" page
    When I select "Wrong code" from "Action"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action     | User   |
      | DPD-001 | Wrong code | Dmytro |
    When I follow "Reset"
    Then the table should have 4 rows

  Scenario: The log is searched by locker or user name
    Given I am signed in as "Sam"
    And I open the "Action log" page
    When I fill in "Search" with "dpd"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action     | User   |
      | DPD-001 | Opened     | Sam    |
      | DPD-001 | Wrong code | Dmytro |
    When I fill in "Search" with "alice"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action | User  |
      | AMZ-001 | Closed | Alice |
      | AMZ-001 | Opened | Alice |

  Scenario: Search and the kind of action are combined
    Given I am signed in as "Sam"
    And I open the "Action log" page
    When I fill in "Search" with "AMZ"
    And I select "Closed" from "Action"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action | User  |
      | AMZ-001 | Closed | Alice |

  Scenario: The log is filtered by locker and by user
    Given I am signed in as "Sam"
    And I open the "Action log" page
    When I select "DPD-001" from "Locker"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action     | User   |
      | DPD-001 | Opened     | Sam    |
      | DPD-001 | Wrong code | Dmytro |
    When I select "Dmytro" from "User"
    And I press "Filter"
    Then I should see the table:
      | Locker  | Action     | User   |
      | DPD-001 | Wrong code | Dmytro |

  Scenario: An employee can filter only by their team's lockers and the people who used them
    Given I am signed in as "Alice"
    When I open the "Action log" page
    Then the "Locker" select should offer "All lockers and AMZ-001"
    And the "User" select should offer "All users and Alice"

  Scenario: Nothing matches the search
    Given I am signed in as "Alice"
    And I open the "Action log" page
    When I fill in "Search" with "DPD"
    And I press "Filter"
    Then I should see "No actions yet."

  Scenario: A long log is split into pages
    Given the following actions happened:
      | user  | action       | locker  | times |
      | Alice | fail attempt | AMZ-001 | 17    |
    And I am signed in as "Sam"
    When I open the "Action log" page
    Then the table should have 20 rows
    And I should see "Page 1 of 2"
    When I follow "Next"
    Then the table should have 1 row
    And I should see "Page 2 of 2"
    When I follow "Previous"
    Then the table should have 20 rows

  Scenario: A locker in the log links to its page
    Given I am signed in as "Alice"
    And I open the "Action log" page
    When I follow "AMZ-001" in the "Closed" row
    Then I should see "Wrong codes left before blocking"
