# syntax=docker/dockerfile:1
# Development image. Source code is bind-mounted by compose.yaml.

ARG RUBY_VERSION=3.4.11
FROM docker.io/library/ruby:$RUBY_VERSION-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential curl git libpq-dev libyaml-dev pkg-config postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS="4"

# Gemfile.lock is optional on the very first build; bundler will create it.
COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
