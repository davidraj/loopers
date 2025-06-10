FactoryBot.define do
  factory :tv_show do
    title { Faker::TvShows::Friends.character }
    tvmaze_id { Faker::Number.unique.number(digits: 6) }
    description { Faker::Lorem.paragraph }
    summary { Faker::Lorem.paragraph }
    genre { "Drama" }
    total_seasons { Faker::Number.between(from: 1, to: 10) }
    total_episodes { Faker::Number.between(from: 10, to: 200) }
    status { "upcoming" }  # Use string value
    imdb_rating { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    language { "en" }
    runtime_minutes { [30, 60].sample }
    original_air_date { Faker::Date.between(from: 2.years.ago, to: 1.year.ago) }
    country_of_origin { "US" }
    premiered_at { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    image_url { Faker::Internet.url }
    network_name { Faker::Company.name }
    rating { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
  end
end
