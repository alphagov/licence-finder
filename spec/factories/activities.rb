# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :activity do
    sequence(:correlation_id)
    name "Test Activity"
  end
end
