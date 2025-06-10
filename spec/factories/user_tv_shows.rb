FactoryBot.define do
  factory :user_tv_show do
    association :user
    association :tv_show
    status { "watching" }
    watched_at { Time.current }
  end
end
