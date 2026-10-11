class LockersController < ApplicationController
  # The lockers the user may see, one page at a time, optionally narrowed by a
  # search text, a state and a team. Every filter is applied on top of the
  # access scope, so it can only narrow what the user is already allowed to see.
  def index
    teams = Team.where(id: Locker.accessible_to(current_user).select(:team_id)).includes(:company).order(:name)

    query = params[:q].to_s.strip.presence
    state = params[:state].presence_in(Locker.aasm.states.map { |known| known.name.to_s })
    team = teams.find_by(id: params[:team_id])

    lockers = accessible_lockers.order(:name)
    lockers = lockers.search(query) if query
    lockers = lockers.where(state: state) if state
    lockers = lockers.where(team: team) if team
    list = Pagination.new(lockers, page: params[:page])

    @props = page_props(
      lockers: LockerSerializer.collection(list.records, viewer: current_user),
      pagination: pagination_props(list) do |page|
        lockers_path(q: query, state: state, team_id: team&.id, page: page)
      end,
      filter: {
        path: lockers_path,
        query: query.to_s,
        state: state,
        states: Locker.aasm.states.map(&:name),
        teamId: team&.id,
        teams: teams.map { |option| { id: option.id, name: "#{option.company.name} · #{option.name}" } }
      }
    )
  end

  def show
    # Lockers outside the user's scope are simply not found (404).
    @locker = accessible_lockers.find(params[:id])
    history = Pagination.new(@locker.actions.includes(:user).newest_first, page: params[:page])

    @props = page_props(
      locker: LockerSerializer.new(@locker, viewer: current_user).detailed_json,
      actions: LockerActionSerializer.collection(history.records),
      pagination: pagination_props(history) { |page| locker_path(@locker, page: page) },
      lockersPath: lockers_path
    )
  end

  private

  def accessible_lockers
    Locker.accessible_to(current_user).includes(team: :company)
  end
end
