FactoryBot.define do
  factory :locker do
    team
    sequence(:name) { |n| "LCK-#{n.to_s.rjust(3, '0')}" }
    location { "Main hall" }
    state { "closed" }

    trait :open do
      state { "open" }
    end

    trait :blocked do
      state { "blocked" }
      blocked_until { 10.minutes.from_now }
    end
  end
end
