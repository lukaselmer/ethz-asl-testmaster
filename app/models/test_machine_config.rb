class TestMachineConfig < ActiveRecord::Base
  belongs_to :test_run
  has_many :test_run_logs
end
