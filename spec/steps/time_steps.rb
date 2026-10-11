# Steps for things that happen later, such as scheduled background jobs.
module TimeSteps
  extend Turnip::DSL

  # Moves the clock forward and runs the jobs that have come due by then.
  step ":count minute(s) pass(es)" do |count|
    # Keep microseconds: the default rounds the clock down to a whole second,
    # which could land just before a deadline set earlier in the scenario.
    travel count.to_i.minutes, with_usec: true
    perform_enqueued_jobs(at: Time.current)
  end
end
