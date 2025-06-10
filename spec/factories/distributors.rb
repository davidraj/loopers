FactoryBot.define do
  factory :distributor do
    name { Faker::Company.unique.name }
    website_url { Faker::Internet.url }
    country_code { "US" }
    description { Faker::Lorem.paragraph }

    active { true }
  end
end