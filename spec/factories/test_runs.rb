# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_run do
    name 'MyString'
    config 'MyText'
    started_at '2013-10-12 00:38:33'
    ended_at '2013-10-12 00:38:33'
  end
end
