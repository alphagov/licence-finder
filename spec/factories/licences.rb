# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :licence do
    sequence(:correlation_id) # deprecated attr should be removed once licences are migrated.
    sequence(:legal_ref_id)
    name "Test Licence"
    regulation_area "Test Regulation Area"
    da_england true
    da_scotland false
    da_wales false
    da_northern_ireland false
  end
end
