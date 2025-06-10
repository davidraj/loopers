FactoryBot.define do
  factory :release_date do
    association :tv_show
    association :distributor
    release_date { Faker::Date.between(from: 1.year.ago, to: 1.year.from_now) }
    region { ['US', 'UK', 'CA', 'AU'].sample }
    release_type { ['theatrical', 'streaming', 'dvd', 'digital'].sample }
    season_number { rand(1..10) }
    episode_number { rand(1..24) }
    notes { Faker::Lorem.sentence }
  end
end
