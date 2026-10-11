# Shapes one recorded locker action into JSON props for the React views.
class LockerActionSerializer
  include Rails.application.routes.url_helpers

  def self.collection(actions)
    actions.map { |action| new(action).as_json }
  end

  def initialize(action)
    @action = action
  end

  def as_json(*)
    {
      id: @action.id,
      kind: @action.kind,
      locker: @action.locker.name,
      lockerPath: locker_path(@action.locker),
      # nil when the system did it, e.g. the timed unblock.
      user: @action.user&.name,
      # Formatted here, not in the browser, so the server-rendered HTML and
      # the hydrated page always show the same text.
      performedAt: @action.created_at.utc.strftime("%Y-%m-%d %H:%M UTC")
    }
  end
end
