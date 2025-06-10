FactoryBot.define do
  factory :distributor do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    website_url { Faker::Internet.url }
    country_code { ['US', 'UK', 'CA', 'AU', 'DE', 'FR'].sample }
    active { true }
  end
end
