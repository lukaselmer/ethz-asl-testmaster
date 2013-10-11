class TestRun < ActiveRecord::Base
  has_many :test_run_logs
  #has_and_belongs_to_many :machines
end
