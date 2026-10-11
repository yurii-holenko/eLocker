# eLocker

Rails 7.2 · Ruby 3.4.11 · PostgreSQL 17 · Redis 7 · Sidekiq

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
cp .env.example .env
```

Then every day:

```bash
bin/dev        # starts db + redis + worker in Docker, prepares the DB, runs rails server
```

App: http://localhost:3000 · Sidekiq UI: http://localhost:3000/sidekiq

Other commands run normally: `bin/rails console`, `bin/rails db:migrate`, `bin/rails test`, `bin/rubocop`.

## Option B — everything in Docker

```bash
docker compose --profile web up --build
docker compose run --rm web bin/rails console
```

## Useful bits

```bash
docker compose ps                      # what's running
docker compose logs -f worker          # Sidekiq logs
docker compose restart worker          # after changing job code / adding gems
docker compose down                    # stop (data stays in volumes)
bin/rails runner 'HelloJob.perform_later("eLocker")'   # smoke-test the worker
```

Port clash with a local Postgres/Redis? Change `POSTGRES_PORT` / `REDIS_PORT` in `.env`
(and `DATABASE_PORT` / `REDIS_URL` to match).

## Production notes

The `Dockerfile` here is for development. In production set `DATABASE_URL`, `REDIS_URL`
and `SECRET_KEY_BASE` (or use `bin/rails credentials:edit`).
