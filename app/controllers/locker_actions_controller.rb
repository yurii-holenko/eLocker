class LockerActionsController < ApplicationController
  # The action log: every action on the lockers the user may see, one page at
  # a time, optionally narrowed by a search text, a locker, a kind of action
  # and a user. Every filter is applied on top of the access scope, so it can
  # only narrow what the user is already allowed to see.
  def index
    visible = LockerAction.accessible_to(current_user)
    lockers = Locker.accessible_to(current_user).order(:name)
    users = User.where(id: visible.select(:user_id)).order(:name)

    query = params[:q].to_s.strip.presence
    kind = params[:kind].presence_in(LockerAction::KINDS)
    locker = lockers.find_by(id: params[:locker_id])
    user = users.find_by(id: params[:user_id])

    actions = visible.includes(:user, :locker).newest_first
    actions = actions.search(query) if query
    actions = actions.where(kind: kind) if kind
    actions = actions.where(locker: locker) if locker
    actions = actions.where(user: user) if user
    log = Pagination.new(actions, page: params[:page])

    @props = page_props(
      actions: LockerActionSerializer.collection(log.records),
      pagination: pagination_props(log) do |page|
        actions_path(q: query, locker_id: locker&.id, kind: kind, user_id: user&.id, page: page)
      end,
      filter: {
        path: actions_path,
        query: query.to_s,
        lockerId: locker&.id,
        lockers: lockers.map { |option| { id: option.id, name: option.name } },
        kind: kind,
        kinds: LockerAction::KINDS,
        userId: user&.id,
        users: users.map { |option| { id: option.id, name: option.name } }
      }
    )
  end

  def create
    # Lockers outside the user's scope are simply not found (404).
    locker = Locker.accessible_to(current_user).find(params[:locker_id])
    locker.perform!(params[:kind], by: current_user)

    redirect_back_or_to lockers_path, flash: { flash_type => result_message(locker) }
  rescue Locker::InvalidAction => e
    redirect_back_or_to lockers_path, alert: e.message
  end

  private

  def flash_type
    params[:kind] == "fail_attempt" ? :alert : :notice
  end

  def result_message(locker)
    t("lockers.notices.#{params[:kind]}.#{locker.state}",
      name: locker.name,
      remaining: locker.failed_attempts_left_for(current_user),
      minutes: locker.company.settings.block_duration_minutes)
  end
end
