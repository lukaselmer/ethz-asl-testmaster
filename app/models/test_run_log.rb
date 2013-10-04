class TestRunLog < ActiveRecord::Base
  belongs_to :test_run
  belongs_to :test_machine_config
end
