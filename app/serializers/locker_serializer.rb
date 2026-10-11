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
      actionsPath: locker_actions_path(@locker)
    }
  end
end
