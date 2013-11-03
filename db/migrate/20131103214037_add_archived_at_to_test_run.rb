class AddArchivedAtToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :archived_at, :datetime
  end
end
