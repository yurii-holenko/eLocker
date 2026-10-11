class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  helper_method :current_user

  private

  # Authentication is mocked: the user picked in the header dropdown is kept in
  # the session, falling back to the first seeded user.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) || User.order(:id).first!
  end

  def switch_locale(&action)
    locale = session[:locale].presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # Props every React page needs, plus the page's own data. Translations come
  # from the Rails locale files, so there is a single source for all UI text.
  def page_props(**props)
    { translations: t("react"), csrfToken: form_authenticity_token, **props }
  end
end
