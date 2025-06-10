FactoryBot.define do
  factory :episode do
    association :tv_show
    title { Faker::Lorem.sentence(word_count: 3) }
    season_number { rand(1..5) }
    episode_number { rand(1..24) }
    air_date { Faker::Date.between(from: 2.years.ago, to: Date.current) }
    runtime_minutes { [30, 45, 60].sample }
    summary { Faker::Lorem.paragraph }
  end
end
