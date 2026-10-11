# eLocker

Rails 7.2 · Ruby 3.4.11 · React 19 (server-rendered via React on Rails) · PostgreSQL 17 · Redis 7 · Sidekiq

A multi-tenant platform for smart lockers: every customer company uses the same
application and sees only its own lockers, while eLocker support can work with any locker.

**Contents:** [Run it](#option-a--rails-on-your-machine-recommended-for-dev) ·
[Try it](#try-it) · [Data model](#data-model) · [Decisions](#decisions) ·
[Assumptions and questions](#assumptions-and-questions-for-the-business) ·
[What next](#what-i-would-do-next) · [AI tools](#how-i-used-ai-tools) ·
[How the UI is rendered](#how-the-ui-is-rendered) · [Tests](#tests) · [Locker states](#locker-states)

Postgres, Redis and the Sidekiq worker always run in Docker. Rails itself can run
**on your machine** (fast reloads, native debugger) or **in Docker**.

## Option A — Rails on your machine (recommended for dev)

One-time setup on macOS:

```bash
brew install libpq
rvm install 3.4.11                # skip if already installed; rvm picks it up from .ruby-version on cd
gem install bundler
bundle config build.pg --with-pg-config=$(brew --prefix libpq)/bin/pg_config
bundle install
bundle lock --add-platform aarch64-linux x86_64-linux   # so the Docker worker can use the same Gemfile.lock
nvm install                       # Node 22, from .nvmrc
npm install
cp .env.example .env
```

Then every day:

```bash
bin/dev        # starts db + redis + worker in Docker, prepares the DB, runs rails server
bin/rails db:seed   # demo companies, teams, users and lockers (already done on first run)
```

Rails rebuilds the JS bundles on demand when files in `app/javascript` change, so there is
no separate watcher process. Run `nvm use` first if your default Node is older than 20.

App: http://localhost:3000 · Sidekiq UI: http://localhost:3000/sidekiq

Other commands run normally: `bin/rails console`, `bin/rails db:migrate`, `bundle exec rspec`, `bin/rubocop`.

## Option B — everything in Docker

```bash
docker compose --profile web up --build
docker compose run --rm web bin/rails console
```

## Try it

There is no real sign-in: pick a user in the header dropdown.

| Sign in as | What to look at |
| --- | --- |
| Alice Carter or Ben Ortiz (Amazon, day shift) | They share 6 lockers and see each other's actions, but nothing of the night shift. |
| Chloe Nguyen (Amazon, night shift) | Same company, different team: a different set of lockers. |
| Dmytro Koval (DPD, north crew) | Press "Wrong code" twice on a closed locker: it gets blocked for 1 minute, then unblocks by itself. |
| Elena Rossi (DPD, south crew) | Another DPD team; cannot see Dmytro's lockers. |
| Sam Support (eLocker) | Sees all 24 lockers and the whole action log, and can open a blocked locker. |

Opening a locker that is not yours by typing its address (`/lockers/<id>`) gives 404.

## Data model

```
Company ──1:1── CompanySetting        max_failed_attempts, block_duration_minutes
   │
   └──1:N── Team ──1:N── User         role: employee (support users have no team)
              │
              └──1:N── Locker ──1:N── LockerAction ──N:1── User (empty for system actions)
                       state: closed / open / blocked
```

| Table | Why it looks this way |
| --- | --- |
| `companies` | The tenant. Everything a customer owns hangs off it through teams. |
| `company_settings` | Rules a company configures for itself (how many wrong codes block a locker, and for how long). A separate table, so new settings do not keep widening `companies`. A company without a row uses the defaults. |
| `teams` | Belongs to one company. The unit of access: a team works with its own set of lockers. |
| `users` | `role` is `employee` or `support`. An employee belongs to exactly one team; a support engineer to none. A database check constraint keeps role and team consistent. |
| `lockers` | Belongs to one team. The company is derived through the team rather than stored on the locker, so a locker can never point at a team of another company. `state` is driven by a state machine. |
| `locker_actions` | One row per event on a locker: who, what, when. It is the audit log shown on the locker page and in the action log, and also the source for counting wrong codes. Append-only. |

**Access and tenant separation** come from one rule in one place, `Locker.accessible_to(user)`:
an employee gets the lockers of their team, a support engineer gets all. Every controller
loads lockers through this scope, and actions are scoped through the lockers
(`LockerAction.accessible_to`). A locker outside the scope is "not found" (404) rather than
"forbidden", so its existence is not revealed. Filters and search are applied on top of the
scope, so they can only narrow it.

**State changes** go through one method, `Locker#perform!`, which fires the state machine
event and writes the action row in the same transaction, under a row lock.

## Decisions

### Why React instead of ERB + Hotwire

The assignment suggests server-rendered views with Hotwire. I used React, rendered on the
server by Rails, for two reasons:

- the position is Ruby + React, so this is the stack the work will be done in;
- components that only receive JSON props make it easier to split frontend and backend later.

It is still not a separate SPA. Every screen is a Rails route that returns complete HTML;
React renders on the server and only hydrates in the browser. Actions are plain form POSTs
followed by a redirect, pagination and filters are links and GET forms, and there is no JSON
API or client-side routing. Every screen works with JavaScript turned off, and most feature
tests run that way. Details are in [How the UI is rendered](#how-the-ui-is-rendered).

### Why there is more than the three screens

I approached the task as a developer thinking about the product, not only about the list of
screens, and added what I considered necessary for it to make sense.

The choice of technologies is based on my experience: I picked tools I have worked with and
wanted to use as many of them as fit the task, to show how I would normally build such a
product.

What was added on top of the three screens:

- **Blocking after wrong codes.** A locker is a physical security device. Each company sets how many wrong codes block a locker and for how long; only support can open it before the block ends. See [Locker states](#locker-states).
- **An explicit state machine** (AASM), so every allowed transition and its rule is written in one place.
- **Search, filters and pagination** on the lists, because the action log only grows.
- **Two languages** (English, Ukrainian), with the Rails locale files as the single source for both Rails and React.
- **Tests** at three levels (models, requests, Gherkin scenarios) and CI that runs the tests and linters on every pull request.

## Assumptions and questions for the business

Assumptions I made:

1. An employee belongs to exactly one team, and a team to exactly one company.
2. A locker is assigned to exactly one team.
3. Support engineers do not belong to any company and can see and operate everything.
4. People in a team see each other's actions on the team's lockers, and the actions of support.
5. The action log shows every kind of event (wrong codes, blocking and unblocking too), not only opening and closing; it can be filtered by kind.
6. Access codes are simulated by a "Wrong code" button, since opening is only a state change here.
7. Wrong codes are counted per user and locker, but the block applies to the locker, so it affects the whole team.
8. Repeating an action (opening an open locker) is rejected and not logged.
9. Times are shown in UTC.

Questions I would ask:

1. Can a locker be shared by several teams, or an employee work in several teams?
2. Is there a company-level role (a manager who sees all lockers of the company)?
3. Should employees see what their teammates did, or only their own actions?
4. Should customers see the actions of eLocker support on their lockers?
5. When a locker moves to another team, who should see its earlier history?
6. After too many wrong codes, should the locker be blocked for everyone or only the person who entered them? Who should be notified?
7. How long must the action log be kept, and does anyone need to export it?
8. In which time zone should each company see times?

## What I would do next

- **Partition the large tables**, at least `locker_actions`: it is append-only and will become the biggest table, so partitioning by time keeps queries and retention manageable.
- **Possibly replace the Rails controllers with GraphQL.** The backend will not be used only through these web pages: mobile applications and third-party services will need to integrate with it.
- **A mobile version of the web UI.**
- **Upgrade to Rails 8.** I used Rails 7.2 as the safe option, because I have not started a project on Rails 8 yet.

## How I used AI tools

I worked with Claude Code as a pair programmer. I set the direction and made the decisions
(stack, data model, access rules, blocking rules, what to build and in which order); the
assistant wrote most of the code and tests, which I reviewed and corrected step by step.
Where my instructions differed from the assignment, I had it point that out so the choice
stayed mine.

## How the UI is rendered

Every screen is a regular Rails route. The controller loads records through the access
scope, a serializer turns them into JSON props, and the view renders a React component
**on the server** (`react_component(..., prerender: true)`); the browser then hydrates it.
Opening or closing a locker is a plain form POST followed by a redirect. There is no JSON
API and no client-side routing, so this is not a separate SPA.

| Piece | Where |
| --- | --- |
| Access rule (team lockers vs. all lockers) | `Locker.accessible_to` in `app/models/locker.rb` |
| Locker states and allowed transitions (AASM) | `aasm` block in `app/models/locker.rb` |
| State change + action record | `Locker#perform!` |
| Timed unblock of a blocked locker | `UnblockLockerJob` (Sidekiq) |
| Props | `app/serializers` |
| React pages (one per screen: lockers list, locker page, action log) | `app/javascript/pages` |
| Tables (TanStack Table) with server-side pagination | `app/javascript/components/tables`, `lib/pagination.rb` |
| Reusable React components (buttons, tables) | `app/javascript/components` |
| TypeScript types of the props Rails sends | `app/javascript/types` |
| UI texts for Rails and React (`en`, `uk`) | `config/locales`; the `react` subtree is passed to React as props |
| Tests, grouped by type | `spec/models`, `spec/requests`, `spec/jobs`, `spec/lib`, `spec/i18n`, `spec/features` |
| Client / server bundle entries | `app/javascript/packs` |
| Mock sign-in (header dropdown) | `SessionsController`, `ApplicationController#current_user` |

## Tests

```bash
bundle exec rspec                 # everything
bundle exec rspec spec/features   # only the Gherkin scenarios
npm run typecheck                 # TypeScript check of app/javascript
```

Feature tests are Gherkin `.feature` files in `spec/features`, run by RSpec through Turnip
and driven by Capybara. Their steps live in `spec/steps` and are generic ("I press "Open" in
the "AMZ-001" row", "5 minutes pass"), so a new scenario rarely needs a new step. Scenarios
run without a browser by default; the one tagged `@javascript` needs Google Chrome.

## Locker states

```
closed --open--> open --close--> closed
closed --fail_attempt--> closed          (a wrong access code; employees only)
closed --block--> blocked                (fired by the system at the company's limit)
blocked --open--> open                   (support only, or anyone once the block ran out)
blocked --unblock--> closed              (fired by UnblockLockerJob when the block runs out)
```

Access codes are simulated: the "Wrong code" button stands for entering a wrong code.
Wrong codes are counted per user and locker, and reset when that user opens the locker
or the locker gets blocked. The limit and the block length are set per company
in the `company_settings` table (`max_failed_attempts`, default 3; `block_duration_minutes`, default 10).
In the seeds DPD uses 2 attempts and 1 minute, so the timed unblock is quick to try.
Every event is written to `locker_actions`; `block` and `unblock` are recorded as done by the system, without a user.

## Useful bits

```bash
docker compose ps                      # what's running
docker compose logs -f worker          # Sidekiq logs
docker compose restart worker          # after changing job or model code
docker compose up -d --build worker    # after adding gems or npm packages
docker compose down                    # stop (data stays in volumes)
bin/rails runner 'HelloJob.perform_later("eLocker")'   # smoke-test the worker
```

Port clash with a local Postgres/Redis? Change `POSTGRES_PORT` / `REDIS_PORT` in `.env`
(and `DATABASE_PORT` / `REDIS_URL` to match).

## Production notes

The `Dockerfile` here is for development. In production set `DATABASE_URL`, `REDIS_URL`
and `SECRET_KEY_BASE` (or use `bin/rails credentials:edit`).
