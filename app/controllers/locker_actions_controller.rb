class LockerActionsController < ApplicationController
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
