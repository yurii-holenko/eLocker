# eLocker

Rails 7.2 · Ruby 3.4.11 · React 19 (server-rendered via React on Rails) · PostgreSQL 17 · Redis 7 · Sidekiq

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
| React pages (one per screen: lockers list, locker page) | `app/javascript/pages` |
| Reusable React components (buttons, tables) | `app/javascript/components` |
| TypeScript types of the props Rails sends | `app/javascript/types` |
| UI texts for Rails and React (`en`, `uk`) | `config/locales`; the `react` subtree is passed to React as props |
| Tests, grouped by type | `spec/models`, `spec/requests`, `spec/jobs`, `spec/i18n`, `spec/features` |
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
Every event, including the system ones, is written to `locker_actions`.

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
