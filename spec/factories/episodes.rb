FactoryBot.define do
  factory :episode do
    tv_show { nil }
    title { "MyString" }
    summary { "MyText" }
    air_date { "2025-06-08" }
    season_number { 1 }
    episode_number { 1 }
    tvmaze_id { 1 }
    runtime { 1 }
  end
end
