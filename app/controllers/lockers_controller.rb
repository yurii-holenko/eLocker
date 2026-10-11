class LockersController < ApplicationController
  def index
    lockers = Locker.accessible_to(current_user).includes(team: :company).order(:name)

    @props = page_props(lockers: LockerSerializer.collection(lockers, viewer: current_user))
  end
end
