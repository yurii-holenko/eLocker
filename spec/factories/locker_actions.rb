FactoryBot.define do
  factory :locker_action do
    locker
    user { association :user, team: locker.team }
    kind { "open" }
  end
end
