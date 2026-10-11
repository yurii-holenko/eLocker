module ApplicationHelper
  # Users for the mock sign-in dropdown, grouped as "Company · Team" with
  # eLocker support staff in their own group.
  def user_switcher_options(selected_user)
    users = User.includes(team: :company).order(:name)
    groups = users.group_by { |user| user.support? ? t("layout.support_group") : "#{user.team.company.name} · #{user.team.name}" }

    grouped_options_for_select(groups.sort.to_h.transform_values { |members| members.map { |user| [ user.name, user.id ] } }, selected_user.id)
  end

  def flash_toasts_props
    {
      messages: flash.map { |type, text| { type: type, text: text } },
      closeLabel: t("layout.dismiss")
    }
  end

  # Each language is shown with its flag and its own name, whatever the current locale.
  LOCALE_LABELS = { en: "🇬🇧 English", uk: "🇺🇦 Українська" }.freeze

  def locale_switcher_options
    options_for_select(I18n.available_locales.map { |locale| [ LOCALE_LABELS.fetch(locale), locale ] }, I18n.locale)
  end
end
