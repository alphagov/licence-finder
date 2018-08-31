# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :licence_link do
    association :sector
    association :activity
    association :licence
  end
end
