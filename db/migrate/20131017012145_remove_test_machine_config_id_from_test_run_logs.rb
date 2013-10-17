class RemoveTestMachineConfigIdFromTestRunLogs < ActiveRecord::Migration
  def change
    remove_column :test_run_logs, :test_machine_config_id, :reference
  end
end
