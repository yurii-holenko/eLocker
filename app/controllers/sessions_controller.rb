# Mock sign-in: switches the current user from the header dropdown.
class SessionsController < ApplicationController
  def update
    session[:user_id] = User.find(params[:user_id]).id
    redirect_to root_path
  end
end
