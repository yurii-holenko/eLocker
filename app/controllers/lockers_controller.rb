class LockersController < ApplicationController
  HISTORY_LIMIT = 50

  def index
    lockers = accessible_lockers.order(:name)

    @props = page_props(lockers: LockerSerializer.collection(lockers, viewer: current_user))
  end

  def show
    # Lockers outside the user's scope are simply not found (404).
    @locker = accessible_lockers.find(params[:id])
    actions = @locker.actions.includes(:user).order(id: :desc).limit(HISTORY_LIMIT)

    @props = page_props(
      locker: LockerSerializer.new(@locker, viewer: current_user).detailed_json,
      actions: LockerActionSerializer.collection(actions),
      lockersPath: lockers_path
    )
  end

  private

  def accessible_lockers
    Locker.accessible_to(current_user).includes(team: :company)
  end
end
