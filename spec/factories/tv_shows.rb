FactoryBot.define do
  factory :tv_show do
    title { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    genre { ['Drama', 'Comedy', 'Action', 'Thriller', 'Sci-Fi'].sample }
    total_seasons { rand(1..10) }
    total_episodes { rand(10..200) }
    status { ['upcoming', 'running', 'ended'].sample }
    imdb_rating { rand(1.0..10.0).round(1) }
    language { 'en' }
    runtime_minutes { [30, 45, 60].sample }
    original_air_date { Faker::Date.between(from: 2.years.ago, to: 1.year.from_now) }
    country_of_origin { 'US' }
    tvmaze_id { rand(100000..999999) }
    premiered_at { Faker::Date.between(from: 1.year.ago, to: 1.year.from_now) }
    image_url { Faker::Internet.url }
    summary { Faker::Lorem.paragraph }
    network_name { Faker::Company.name }
    rating { rand(0.1..10.0).round(1) }

    # Don't create release_dates by default to avoid circular dependencies
    trait :with_release_dates do
      after(:create) do |tv_show|
        create_list(:release_date, 2, tv_show: tv_show)
      end
    end

    trait :us_show do
      country_of_origin { 'United States' }
    end

    trait :uk_show do
      country_of_origin { 'United Kingdom' }
    end

    trait :high_rated do
      imdb_rating { 9.0 }
    end
  end
end
