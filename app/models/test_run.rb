class TestRun < ActiveRecord::Base
  has_many :test_run_logs
  has_many :test_machine_configs
end
