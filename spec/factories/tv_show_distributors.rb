FactoryBot.define do
  factory :tv_show_distributor do
    association :tv_show
    association :distributor
  end
end