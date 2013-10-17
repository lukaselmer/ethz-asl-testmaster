# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

puts 'DEFAULT USERS'
unless User.exists? email: ENV['ADMIN_EMAIL'].dup
  user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
  puts 'user: ' << user.name
end

m1 = Machine.create!
m2 = Machine.create!
scenario1 = Scenario.create!(name: 'broker', execution_multiplicity: 1)
scenario2 = Scenario.create!(name: 'client', execution_multiplicity: 1)
scenario_execution1 = ScenarioExecution.create(machine: m1, scenario: scenario1)
scenario_execution2 = ScenarioExecution.create(machine: m2, scenario: scenario2)
t = TestRun.create(name: 'My Test Run', scenarios: [scenario1, scenario2])
scenario1.test_run = t
scenario1.save!
scenario2.test_run = t
scenario2.save!

srand(1)

100.times do |i|
  10.times do
    TestRunLog.create!(message_type: 'type1', logged_at: i.seconds.ago, execution_in_microseconds: 100 + rand(50), scenario_execution: scenario_execution1, test_run: t)
    TestRunLog.create!(message_type: 'type1', logged_at: i.seconds.ago, execution_in_microseconds: 100 + rand(70), scenario_execution: scenario_execution1, test_run: t)
    TestRunLog.create!(message_type: 'type2', logged_at: i.seconds.ago, execution_in_microseconds: 80 + rand(10), scenario_execution: scenario_execution1, test_run: t)
    TestRunLog.create!(message_type: 'type2', logged_at: i.seconds.ago, execution_in_microseconds: 90 + rand(15), scenario_execution: scenario_execution1, test_run: t)
  end
end
