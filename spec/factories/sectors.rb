# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :sector do
    sequence(:correlation_id)
    name "Test Sector"
  end
end
