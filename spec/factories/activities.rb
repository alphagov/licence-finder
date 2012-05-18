# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    sequence(:public_id)
    sequence(:correlation_id)
    name "Test Activity"
  end
end
