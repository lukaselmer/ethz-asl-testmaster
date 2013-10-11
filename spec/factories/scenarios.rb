# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scenario do
    name "MyString"
    execution_multiplicity 1
    config_template "MyText"
    test_run nil
  end
end
