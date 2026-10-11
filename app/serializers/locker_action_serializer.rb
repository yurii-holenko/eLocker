# Shapes one row of a locker's history into JSON props for the React views.
class LockerActionSerializer
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
      # nil when the system did it, e.g. the timed unblock.
      user: @action.user&.name,
      # Formatted here, not in the browser, so the server-rendered HTML and
      # the hydrated page always show the same text.
      performedAt: @action.created_at.utc.strftime("%Y-%m-%d %H:%M UTC")
    }
  end
end
