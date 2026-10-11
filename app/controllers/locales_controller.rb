# Switches the UI language from the header dropdown.
class LocalesController < ApplicationController
  def update
    session[:locale] = params[:locale].presence_in(I18n.available_locales.map(&:to_s))
    redirect_back_or_to root_path
  end
end
