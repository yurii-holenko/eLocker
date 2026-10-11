# Smoke test: bin/rails runner 'HelloJob.perform_later("eLocker")' → check worker logs
class HelloJob < ApplicationJob
  queue_as :default

  def perform(name)
    Rails.logger.info "Hello from Sidekiq, #{name}!"
  end
end
