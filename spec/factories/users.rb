FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Employee #{n}" }
    role { "employee" }
    team

    trait :support do
      sequence(:name) { |n| "Support #{n}" }
      role { "support" }
      team { nil }
    end
  end
end
