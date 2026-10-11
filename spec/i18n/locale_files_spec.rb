require "rails_helper"

# Rails and React both take their texts from config/locales, so a key missing
# in one language would show up in the UI as a raw key or a "translation
# missing" message.
RSpec.describe "Locale files" do
  # { "lockers.notices.open.open" => "%{name} is now open.", ... }
  def self.translations(locale)
    flatten = lambda do |node, prefix|
      node.flat_map do |key, value|
        path = [ prefix, key ].compact.join(".")
        value.is_a?(Hash) ? flatten.call(value, path) : [ [ path, value ] ]
      end
    end

    flatten.call(YAML.load_file(Rails.root.join("config/locales/#{locale}.yml")).fetch(locale.to_s), nil).to_h
  end

  def placeholders(text)
    text.to_s.scan(/%\{(\w+)\}/).flatten.sort
  end

  reference = translations(I18n.default_locale)

  it "has a file for every available language" do
    files = Rails.root.glob("config/locales/*.yml").map { |file| file.basename(".yml").to_s }

    expect(files).to match_array(I18n.available_locales.map(&:to_s))
  end

  (I18n.available_locales - [ I18n.default_locale ]).each do |locale|
    describe locale.to_s do
      translated = translations(locale)

      it "has every key of #{I18n.default_locale}" do
        expect(reference.keys - translated.keys).to be_empty
      end

      it "has no keys that #{I18n.default_locale} lacks" do
        expect(translated.keys - reference.keys).to be_empty
      end

      it "has no empty translations" do
        expect(translated.select { |_key, text| text.blank? }.keys).to be_empty
      end

      it "uses the same %{placeholders} as #{I18n.default_locale}" do
        mismatched = (reference.keys & translated.keys).reject do |key|
          placeholders(reference[key]) == placeholders(translated[key])
        end

        expect(mismatched).to be_empty
      end
    end
  end
end
