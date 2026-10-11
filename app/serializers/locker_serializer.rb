# Shapes a locker into the JSON props the React views receive, for one viewer.
class LockerSerializer
  include Rails.application.routes.url_helpers

  def self.collection(lockers, viewer:)
    lockers.map { |locker| new(locker, viewer: viewer).as_json }
  end

  def initialize(locker, viewer:)
    @locker = locker
    @viewer = viewer
  end

  def as_json(*)
    {
      id: @locker.id,
      name: @locker.name,
      location: @locker.location,
      state: @locker.state,
      blockedMinutesLeft: @locker.blocked_minutes_left,
      team: @locker.team.name,
      company: @locker.team.company.name,
      # The state machine decides what the viewer may do; React only renders it.
      availableActions: @locker.available_events_for(@viewer),
      path: locker_path(@locker),
      actionsPath: locker_actions_path(@locker)
    }
  end

  # Extra fields for the locker's own page. Kept out of the list because
  # counting wrong codes costs queries per locker.
  def detailed_json
    as_json.merge(
      maxFailedAttempts: @locker.company.settings.max_failed_attempts,
      # Support engineers open lockers without a code, so nothing to count.
      attemptsLeft: (@locker.failed_attempts_left_for(@viewer) if @viewer.employee?)
    )
  end
end
