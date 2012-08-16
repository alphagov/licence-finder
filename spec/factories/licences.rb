# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :licence do
    sequence(:correlation_id)
    sequence(:gds_id) { |n| "#{n}-3-1" }
    name "Test Licence"
    regulation_area "Test Regulation Area"
    da_england true
    da_scotland false
    da_wales false
    da_northern_ireland false
  end
end
