class TestRunLog < ActiveRecord::Base
  belongs_to :test_run
  belongs_to :scenario_execution
end
