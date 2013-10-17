class RemoveMessageContentFromTestRunLogs < ActiveRecord::Migration
  def change
    remove_column :test_run_logs, :message_content, :string
  end
end
