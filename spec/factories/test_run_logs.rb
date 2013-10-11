# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_run_log do
    logged_at "2013-10-05 01:30:48"
    message_type "MyString"
    message_content "MyText"
    execution_in_microseconds 1
    test_run nil
  end
end
