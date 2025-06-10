FactoryBot.define do
  factory :tv_show do
    sequence(:title) { |n| "TV Show #{n}" }
    genre { ['Drama', 'Comedy', 'Action', 'Thriller', 'Sci-Fi'].sample }
    status { ['Running', 'Ended', 'In Development'].sample }
    rating { rand(6.0..10.0).round(1) }
    network_name { ['HBO', 'Netflix', 'AMC', 'BBC', 'FOX', 'CBS'].sample }
    country_of_origin { ['United States', 'United Kingdom', 'Canada'].sample }
    language { 'English' }
    runtime_minutes { [30, 45, 60].sample }
    premiered_at { rand(10.years).seconds.ago }
    summary { "This is a summary for #{title}" }
    image_url { "https://example.com/image#{rand(1..100)}.jpg" }
  end
end
