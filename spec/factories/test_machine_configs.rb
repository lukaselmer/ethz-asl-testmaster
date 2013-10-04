# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_machine_config do
    name "MyString"
    command_line_arguments "MyText"
    test_run nil
  end
end
