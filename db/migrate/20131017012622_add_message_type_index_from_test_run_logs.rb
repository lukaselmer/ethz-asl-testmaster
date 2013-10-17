class AddMessageTypeIndexFromTestRunLogs < ActiveRecord::Migration
  def change
    add_index :test_run_logs, :message_type
  end
end
