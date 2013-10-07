# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :machine do
    host "MyString"
    profile "MyString"
    state "MyString"
    private_key "MyText"
    additional_info "MyText"
  end
end
