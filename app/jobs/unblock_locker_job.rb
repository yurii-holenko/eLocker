# Scheduled for the moment a locker's block runs out.
class UnblockLockerJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(locker)
    locker.unblock_if_expired!
  end
end
