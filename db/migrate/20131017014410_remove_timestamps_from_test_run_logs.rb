class RemoveTimestampsFromTestRunLogs < ActiveRecord::Migration
  def change
    remove_column :test_run_logs, :created_at, :datetime
    remove_column :test_run_logs, :updated_at, :datetime
  end
end
